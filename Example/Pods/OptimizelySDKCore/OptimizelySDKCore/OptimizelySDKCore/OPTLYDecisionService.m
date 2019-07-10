/****************************************************************************
 * Copyright 2017-2019, Optimizely, Inc. and contributors                   *
 *                                                                          *
 * Licensed under the Apache License, Version 2.0 (the "License");          *
 * you may not use this file except in compliance with the License.         *
 * You may obtain a copy of the License at                                  *
 *                                                                          *
 *    http://www.apache.org/licenses/LICENSE-2.0                            *
 *                                                                          *
 * Unless required by applicable law or agreed to in writing, software      *
 * distributed under the License is distributed on an "AS IS" BASIS,        *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. *
 * See the License for the specific language governing permissions and      *
 * limitations under the License.                                           *
 ***************************************************************************/

#import "OPTLYAudience.h"
#import "OPTLYBucketer.h"
#import "OPTLYDatafileKeys.h"
#import "OPTLYDecisionService.h"
#import "OPTLYErrorHandler.h"
#import "OPTLYExperiment.h"
#import "OPTLYLogger.h"
#import "OPTLYLoggerMessages.h"
#import "OPTLYProjectConfig.h"
#import "OPTLYUserProfile.h"
#import "OPTLYUserProfileServiceBasic.h"
#import "OPTLYVariation.h"
#import "OPTLYFeatureFlag.h"
#import "OPTLYRollout.h"
#import "OPTLYFeatureDecision.h"
#import "OPTLYGroup.h"
#import "OPTLYControlAttributes.h"
#import "OPTLYNSObject+Validation.h"

@interface OPTLYDecisionService()
@property (nonatomic, strong) OPTLYProjectConfig *config;
@property (nonatomic, strong) id<OPTLYBucketer> bucketer;
@end

@implementation OPTLYDecisionService

- (instancetype) initWithProjectConfig:(OPTLYProjectConfig *)config
                              bucketer:(id<OPTLYBucketer>)bucketer
{
    self = [super init];
    if (self) {
        _config = config;
        _bucketer = bucketer;
    }
    return self;
}

- (OPTLYVariation *)getVariation:(NSString *)userId
                      experiment:(OPTLYExperiment *)experiment
                      attributes:(NSDictionary<NSString *, id> *)attributes
{
    NSDictionary *userProfileDict = nil;
    OPTLYVariation *bucketedVariation = nil;
    NSString *experimentKey = experiment.experimentKey;
    NSString *experimentId = experiment.experimentId;
    
    // Acquire bucketingId .
    NSString *bucketingId = [self getBucketingId:userId attributes:attributes];
    
    // ---- check if the experiment is running ----
    if (![self isExperimentActive:self.config
                    experimentKey:experimentKey]) {
        return nil;
    }
    
    // ---- check for forced variation ----
    bucketedVariation = [self.config getForcedVariation:experimentKey userId:userId];
    if (bucketedVariation != nil) {
        return bucketedVariation;
    }
    
    // ---- check if the experiment is whitelisted ----
    if ([self checkWhitelistingForUser:userId experiment:experiment]) {
        OPTLYVariation *whitelistedVariation = [self getWhitelistedVariationForUser:userId experiment:experiment];
        if (whitelistedVariation) {
            return whitelistedVariation;
        }
    }
    
    // ---- check if a valid variation is stored in the user profile ----
    if (self.config.userProfileService) {
        userProfileDict = [self.config.userProfileService lookup:userId];
        NSString *storedVariationId = [self getVariationIdFromUserProfile:userProfileDict
                                                                   userId:userId
                                                               experiment:experiment];
        if ([storedVariationId length] > 0) {
            [self.config.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesUserProfileBucketerUserDataRetrieved, userId, experimentId, storedVariationId]
                                 withLevel:OptimizelyLogLevelDebug];
            // make sure that the variation still exists in the datafile
            OPTLYVariation *storedVariation = [[self.config getExperimentForId:experimentId] getVariationForVariationId:storedVariationId];
            if (storedVariation) {
                return storedVariation;
            } else {
                [self.config.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesDecisionServiceSavedVariationInvalid, storedVariation.variationKey]
                                     withLevel:OptimizelyLogLevelDebug];
            }
        }
    } else {
        [self.config.logger logMessage:OPTLYLoggerMessagesDecisionServiceUserProfileNotExist
                             withLevel:OptimizelyLogLevelDebug];
    }
    
    // ---- check if the user passes audience targeting before bucketing ----
    if ([self userPassesTargeting:self.config
                       experiment:experiment
                           userId:userId
                       attributes:attributes]) {
        
        // bucket user into a variation
        bucketedVariation = [self.bucketer bucketExperiment:experiment
                                            withBucketingId:bucketingId];
        
        if (bucketedVariation) {
            [self saveUserProfile:userProfileDict variation:bucketedVariation experiment:experiment userId:userId];
        }
    }
    
    return bucketedVariation;
}

- (OPTLYFeatureDecision *)getVariationForFeature:(OPTLYFeatureFlag *)featureFlag
                                          userId:(NSString *)userId
                                      attributes:(NSDictionary<NSString *, id> *)attributes {
    
    //Evaluate in this order:
    
    //1. Attempt to check if the feature is in a mutex group.
    OPTLYFeatureDecision *decision = [self getVariationForFeatureGroup:featureFlag groupId:featureFlag.groupId userId:userId attributes:attributes];
    if (decision) {
        return decision;
    }
    
    //2. Attempt to bucket user into experiment using feature flag.
    // Check if the feature flag is under an experiment and the the user is bucketed into one of these experiments
    decision = [self getVariationForFeatureExperiment:featureFlag userId:userId attributes:attributes];
    if (decision) {
        return decision;
    }
    
    //2. Attempt to bucket user into rollout using the feature flag.
    // Check if the feature flag has rollout and the user is bucketed into one of it's rules
    decision = [self getVariationForFeatureRollout:featureFlag userId:userId attributes:attributes];
    if (decision) {
        return decision;
    }
    [self.config.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesDecisionServiceFRUserNotBucketed, userId, featureFlag.key]
                         withLevel:OptimizelyLogLevelDebug];
    
    decision = [[OPTLYFeatureDecision alloc] init];
    decision.source = DecisionSource.Rollout;
    
    return decision;
}

# pragma mark - Helper Methods

- (NSString *)getBucketingId:(NSString *)userId
                  attributes:(NSDictionary<NSString *, id> *)attributes {
    
    // By default, the bucketing ID should be the user ID .
    NSString *bucketingId = userId;
    // If the bucketing ID key is defined in attributes, then use that
    // in place of the userID for the murmur hash key
    
    if (attributes != nil) {
        BOOL isValidStringType = [attributes[OptimizelyBucketId] isValidStringType];
        if (isValidStringType) {
            bucketingId = [attributes[OptimizelyBucketId] getStringOrEmpty];
            [self.config.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesDecisionServiceSettingTheBucketingID,
                                            bucketingId]
                                 withLevel:OptimizelyLogLevelDebug];
        }
    }
    return bucketingId;
}

- (OPTLYExperiment *)getExperimentInGroup:(OPTLYGroup *)group bucketingId:(NSString *)bucketingId {
    OPTLYBucketer *bucketer = (OPTLYBucketer *)_bucketer;
    OPTLYExperiment *experiment = nil;
    NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesDecisionServiceUserNotBucketed, bucketingId, group.groupId];
    if (bucketer)
        experiment = [bucketer bucketToExperiment:group withBucketingId:bucketingId];
    if (experiment)
        logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesDecisionServiceUserBucketed, bucketingId, experiment.experimentKey, group.groupId];
    
    [self.config.logger logMessage:logMessage
                         withLevel:OptimizelyLogLevelDebug];
    return experiment;
}

- (OPTLYFeatureDecision *)getVariationForFeatureGroup:(OPTLYFeatureFlag *)featureFlag
                                              groupId:(NSString *)groupId
                                               userId:(NSString *)userId
                                           attributes:(NSDictionary<NSString *, id> *)attributes {
    
    OPTLYFeatureDecision *decision = nil;
    NSString *logMessage = nil;
    
    if ([groupId getValidString] == nil) {
        logMessage = OPTLYLoggerMessagesDecisionServiceGroupIdNotFound;
    } else {
        NSString *bucketing_id = [self getBucketingId:userId attributes:attributes];
        OPTLYGroup *group = [self.config getGroupForGroupId:groupId];
        if (group) {
            OPTLYExperiment *experiment = [self getExperimentInGroup:group bucketingId:bucketing_id];
            if (experiment && [featureFlag.experimentIds containsObject:experiment.experimentId]) {
                OPTLYVariation *variation = [self getVariation:userId experiment:experiment attributes:attributes];
                if (variation) {
                    logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesDecisionServiceUserInVariation, userId, variation.variationKey, experiment.experimentKey];
                    decision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment
                                                                      variation:variation
                                                                         source:DecisionSource.FeatureTest];
                }
            }
        } else {
            logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesDecisionServiceGroupUnknownForGroupId, groupId];
        }
    }
    
    if (logMessage) {
        [self.config.logger logMessage:logMessage
                             withLevel:OptimizelyLogLevelDebug];
        
    }
    return decision;
}

- (OPTLYFeatureDecision *)getVariationForFeatureExperiment:(OPTLYFeatureFlag *)featureFlag
                                                    userId:(NSString *)userId
                                                attributes:(NSDictionary<NSString *, id> *)attributes {
    
    NSString *featureFlagKey = featureFlag.key;
    NSArray *experimentIds = featureFlag.experimentIds;
    // Check if there are any experiment IDs inside feature flag
    if ([experimentIds getValidArray] == nil) {
        [self.config.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesDecisionServiceFFNotUsed, featureFlagKey]
                             withLevel:OptimizelyLogLevelDebug];
        return nil;
    }
    
    // Evaluate each experiment ID and return the first bucketed experiment variation
    for (NSString *experimentId in experimentIds) {
        OPTLYExperiment *experiment = [self.config getExperimentForId:experimentId];
        if (!(experiment && experiment.experimentKey)) {
            // Error logged and exception thrown in ProjectConfig-getExperimentFromId
            continue;
        }
        OPTLYVariation *variation = [self getVariation:userId experiment:experiment attributes:attributes];
        if (variation && variation.variationKey) {
            [self.config.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesDecisionServiceFFUserBucketed, userId, experiment.experimentKey, featureFlagKey]
                                 withLevel:OptimizelyLogLevelDebug];
            
            OPTLYFeatureDecision *decision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment
                                                                                    variation:variation
                                                                                       source:DecisionSource.FeatureTest];
            return decision;
        }
    }
    [self.config.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesDecisionServiceFFUserNotBucketed, userId, featureFlagKey]
                         withLevel:OptimizelyLogLevelDebug];
    return nil;
}

- (OPTLYFeatureDecision *)getVariationForFeatureRollout:(OPTLYFeatureFlag *)featureFlag
                                                 userId:(NSString *)userId
                                             attributes:(NSDictionary<NSString *, id> *)attributes {
    
    NSString *bucketing_id = [self getBucketingId:userId attributes:attributes];
    NSString *featureFlagKey = featureFlag.key;
    NSString *rolloutId = featureFlag.rolloutId;
    if ([rolloutId getValidString] == nil) {
        [self.config.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesDecisionServiceFFNotUsed, featureFlagKey]
                             withLevel:OptimizelyLogLevelDebug];
        return nil;
    }
    OPTLYRollout *rollout = [self.config getRolloutForId:rolloutId];
    if (!(rollout && rollout.rolloutId)) {
        // Error logged and thrown in getRolloutFromId
        return nil;
    }
    NSArray *rolloutRules = rollout.experiments;
    if ([rolloutRules getValidArray] == nil) {
        return nil;
    }
    // Evaluate all rollout rules except for last one
    for (int i = 0; i < rolloutRules.count - 1; i++) {
        OPTLYExperiment *experiment = rolloutRules[i];
        // Evaluate if user meets the audience condition of this rollout rule
        if (![self userPassesTargeting:self.config experiment:experiment userId:userId attributes:attributes]) {
            // Evaluate this user for the next rule
            continue;
        }
        
        // Evaluate if user satisfies the traffic allocation for this rollout rule
        OPTLYVariation *variation = [self.bucketer bucketExperiment:experiment withBucketingId:bucketing_id];
        if (!variation || !variation.variationKey) {
            break;
        }
        
        [self.config.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesDecisionServiceFRUserBucketed, userId, featureFlagKey]
                             withLevel:OptimizelyLogLevelDebug];
        OPTLYFeatureDecision *decision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment
                                                                                variation:variation
                                                                                   source:DecisionSource.Rollout];
        return decision;
    }
    // Evaluate fall back rule / last rule now
    OPTLYExperiment *experiment = rolloutRules[rolloutRules.count - 1];
    if ([self userPassesTargeting:self.config experiment:experiment userId:userId attributes:attributes]) {
        OPTLYVariation *variation = [self.bucketer bucketExperiment:experiment withBucketingId:bucketing_id];
        if (variation && variation.variationKey) {
            OPTLYFeatureDecision *decision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment
                                                                                    variation:variation
                                                                                       source:DecisionSource.Rollout];
            return decision;
        }
    }
    
    return nil;
}

- (void)saveUserProfile:(NSDictionary *)userProfileDict
              variation:(nonnull OPTLYVariation *)variation
             experiment:(nonnull OPTLYExperiment *)experiment
                 userId:(nonnull NSString *)userId {
    if (!userId || !experiment || !variation) {
        [self.config.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesUserProfileUnableToSaveVariation,
                                        experiment.experimentId,
                                        variation.variationId,
                                        userId]
                             withLevel:OptimizelyLogLevelDebug];
        return;
    }
    
    // convert the user profile map to a user profile object to add new values
    NSError *userProfileModelInitError;
    OPTLYUserProfile *userProfile = nil;
    
    if (!userProfileDict) {
        userProfile = [OPTLYUserProfile new];
        userProfile.user_id = userId;
        
        OPTLYExperimentBucketMapEntity *bucketMapEntity = [OPTLYExperimentBucketMapEntity new];
        bucketMapEntity.variation_id = variation.variationId;
        
        // update the experiment bucket map with the new values
        userProfile.experiment_bucket_map = @{ experiment.experimentId : [bucketMapEntity toDictionary] };
    } else {
        userProfile = [[OPTLYUserProfile alloc] initWithDictionary:userProfileDict error:&userProfileModelInitError];
        
        if (userProfileModelInitError) {
            [self.config.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesDecisionServiceSavedVariationParseError, userProfileModelInitError, userId]
                                 withLevel:OptimizelyLogLevelWarning];
        }
        
        OPTLYExperimentBucketMapEntity *newBucketMapEntity = [OPTLYExperimentBucketMapEntity new];
        newBucketMapEntity.variation_id = variation.variationId;
        
        NSMutableDictionary *experimentBucketMap = [userProfile.experiment_bucket_map mutableCopy];
        NSDictionary *existingBucketMapEntity = [experimentBucketMap objectForKey:experiment.experimentId];
        
        // log that we are going to replace existing bucket map entity with a new value
        if (existingBucketMapEntity) {
            
            [self.config.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesDecisionServiceReplaceBucketEntity, userId, existingBucketMapEntity, newBucketMapEntity]
                                 withLevel:OptimizelyLogLevelDebug];
            
            experimentBucketMap[experiment.experimentId] = [newBucketMapEntity toDictionary];
        } else {
            NSDictionary *newExperimentBucketMapEntry = @{ experiment.experimentId : [newBucketMapEntity toDictionary] };
            [experimentBucketMap addEntriesFromDictionary:newExperimentBucketMapEntry];
        }
        
        // update the experiment bucket map with the new values
        userProfile.experiment_bucket_map =  [experimentBucketMap copy];
    }
    
    // save the new user profile service
    [self.config.userProfileService save:[userProfile toDictionary]];
}

// check if the user is in the whitelisted mapping
- (BOOL)checkWhitelistingForUser:(NSString *)userId
                      experiment:(OPTLYExperiment *)experiment
{
    BOOL isUserWhitelisted = false;
    
    if (experiment.forcedVariations[userId] != nil) {
        isUserWhitelisted = true;
    }
    
    return isUserWhitelisted;
}

// get the variation the user was whitelisted into
- (OPTLYVariation *)getWhitelistedVariationForUser:(NSString *)userId
                                        experiment:(OPTLYExperiment *)experiment
{
    NSString *forcedVariationKey = [experiment.forcedVariations objectForKey:userId];
    OPTLYVariation *forcedVariation = [experiment getVariationForVariationKey:forcedVariationKey];
    
    if (forcedVariation != nil) {
        // Log user forced into variation
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesForcedVariationUser, userId, forcedVariation.variationKey];
        [self.config.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
    }
    else {
        // Log error: variation not in datafile not activating user
        [OPTLYErrorHandler handleError:self.config.errorHandler
                                  code:OPTLYErrorTypesDataUnknown
                           description:NSLocalizedString(OPTLYErrorHandlerMessagesVariationUnknown, variationId)];
    }
    return forcedVariation;
}

- (NSString *)getVariationIdFromUserProfile:(NSDictionary *)userProfileDict
                                     userId:(NSString *)userId
                                 experiment:(OPTLYExperiment *)experiment
{
    if ([userProfileDict count] == 0) {
        return nil;
    }
    
    // convert the user profile map to a user profile object to get values more easily
    NSError *userProfileModelInitError;
    OPTLYUserProfile *userProfile = [[OPTLYUserProfile alloc] initWithDictionary:userProfileDict
                                                                           error:&userProfileModelInitError];
    
    if (userProfileModelInitError) {
        [self.config.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesDecisionServiceGetVariationParseError, userProfileModelInitError, userId] withLevel:OptimizelyLogLevelDebug];
        return nil;
    }
    
    NSDictionary *experimentBucketMap = userProfile.experiment_bucket_map;
    OPTLYExperimentBucketMapEntity *bucketMapEntity = [[OPTLYExperimentBucketMapEntity alloc] initWithDictionary:[experimentBucketMap objectForKey:experiment.experimentId] error:nil];
    NSString *variationId = bucketMapEntity.variation_id;
    
    NSString *logMessage = @"";
    if ([variationId length] > 0) {
        logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesUserProfileVariation, variationId, userId, experiment.experimentId];
    } else {
        logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesUserProfileNoVariation, userId, experiment.experimentId];
    }
    [self.config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    
    return variationId;
}

- (nullable NSNumber *)evaluateAudienceWithId:(NSString *)audienceId
                                       config:(OPTLYProjectConfig *)config
                                   attributes:(NSDictionary<NSString *, id> *)attributes
{
    OPTLYAudience *audience = [config getAudienceForId:audienceId];
    return [audience evaluateConditionsWithAttributes:attributes projectConfig:config];
}

- (BOOL)evaluateAudienceIdsForExperiment:(OPTLYExperiment *)experiment
                                  config:(OPTLYProjectConfig *)config
                              attributes:(NSDictionary<NSString *, id> *)attributes
{
    NSArray *audienceIds = experiment.audienceIds;
    // if there are no audiences, ALL users should be part of the experiment
    if ([audienceIds count] == 0) {
        return true;
    }
    
    for (NSString *audienceId in audienceIds) {
        BOOL areAttributesValid = [[self evaluateAudienceWithId:audienceId config:config attributes:attributes] boolValue];
        if (areAttributesValid) {
            return true;
        }
    }
    return false;
}

- (BOOL)evaluateAudienceConditionsForExperiment:(OPTLYExperiment *)experiment
                                         config:(OPTLYProjectConfig *)config
                                     attributes:(NSDictionary<NSString *, id> *)attributes
{
    if (experiment.audienceConditions.count == 0) {
        return true;
    }
    
    // Log Experiment Evaluation Started
    NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorEvaluationStartedForExperiment, experiment.experimentKey, [experiment getAudienceConditionsString]];
    [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    NSNumber *result = [experiment evaluateConditionsWithAttributes:attributes projectConfig:config];
    
    // Log Evaluation Result
    logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorExperimentEvaluationCompletedWithResult, experiment.experimentKey, ([result boolValue] ? @"TRUE" : @"FALSE")];
    [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
    if (result == nil) {
        return false;
    }
    return [result boolValue];
}

// Returns true if evaluation should be done using audience conditions, else returns false
- (BOOL)shouldEvaluateUsingAudienceConditions:(OPTLYExperiment *)experiment
{
    return experiment.audienceConditions != nil;
}

// Returns empty dictionary if attributes nil
- (NSDictionary<NSString *, id> *)validateAttributes:(NSDictionary<NSString *, id> *)attributes
{
    // if there are audiences, but no user attributes, Defaults to empty attributes
    if (attributes == nil) {
        return @{};
    }
    return attributes;
}

- (BOOL)isUserInExperiment:(OPTLYProjectConfig *)config
                experiment:(OPTLYExperiment *)experiment
                attributes:(NSDictionary<NSString *, id> *)attributes
{
    attributes = [self validateAttributes:attributes];
    
    // if there are audience conditions, evaluate them, else evaluate audience Ids
    if ([self shouldEvaluateUsingAudienceConditions:experiment]) {
        return [self evaluateAudienceConditionsForExperiment:experiment config:config attributes:attributes];
    }
    
    return [self evaluateAudienceIdsForExperiment:experiment config:config attributes:attributes];
}

- (BOOL)userPassesTargeting:(OPTLYProjectConfig *)config
                 experiment:(OPTLYExperiment *)experiment
                     userId:(NSString *)userId
                 attributes:(NSDictionary<NSString *, id> *)attributes
{
    // check if the user is in the experiment
    BOOL isUserInExperiment = [self isUserInExperiment:config experiment:experiment attributes:attributes];
    if (!isUserInExperiment) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesDecisionServiceFailAudienceTargeting, userId, experiment.experimentKey];
        [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    }
    
    return isUserInExperiment;
}

- (BOOL)isExperimentActive:(OPTLYProjectConfig *)config
             experimentKey:(NSString *)experimentKey
{
    // check if experiments are running
    OPTLYExperiment *experiment = [config getExperimentForKey:experimentKey];
    BOOL isExperimentRunning = [experiment isExperimentRunning];
    if (!isExperimentRunning)
    {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesDecisionServiceExperimentNotRunning, experimentKey];
        [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
        return false;
    }
    return true;
}

@end

