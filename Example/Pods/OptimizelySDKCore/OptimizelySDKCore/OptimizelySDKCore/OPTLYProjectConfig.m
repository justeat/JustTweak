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

#import "OPTLYAttribute.h"
#import "OPTLYAudience.h"
#import "OPTLYBucketer.h"
#import "OPTLYDatafileKeys.h"
#import "OPTLYDecisionService.h"
#import "OPTLYErrorHandler.h"
#import "OPTLYEvent.h"
#import "OPTLYExperiment.h"
#import "OPTLYGroup.h"
#import "OPTLYLog.h"
#import "OPTLYLogger.h"
#import "OPTLYProjectConfig.h"
#import "OPTLYUserProfileServiceBasic.h"
#import "OPTLYVariation.h"
#import "OPTLYFeatureFlag.h"
#import "OPTLYRollout.h"

NSString * const kExpectedDatafileVersion = @"4";
NSString * const kReservedAttributePrefix = @"$opt_";
// Array representing supported datafile versions.
static NSArray *supportedDatafileVersions = nil;

@interface OPTLYProjectConfig()

@property (nonatomic, strong) NSDictionary<NSString *, OPTLYAudience *><Ignore> *audienceIdToAudienceMap;
@property (nonatomic, strong) NSDictionary<NSString *, OPTLYEvent *><Ignore> *eventKeyToEventMap;
@property (nonatomic, strong) NSDictionary<NSString *, NSString *><Ignore> *eventKeyToEventIdMap;
@property (nonatomic, strong) NSDictionary<NSString *, OPTLYExperiment *><Ignore> *experimentIdToExperimentMap;
@property (nonatomic, strong) NSDictionary<NSString *, OPTLYExperiment *><Ignore> *experimentKeyToExperimentMap;
@property (nonatomic, strong) NSDictionary<NSString *, OPTLYFeatureFlag *><Ignore> *featureFlagKeyToFeatureFlagMap;
@property (nonatomic, strong) NSDictionary<NSString *, OPTLYRollout *><Ignore> *rolloutIdToRolloutMap;
@property (nonatomic, strong) NSDictionary<NSString *, NSArray *><Ignore> *experimentIdToFeatureIdsMap;
@property (nonatomic, strong) NSDictionary<NSString *, NSString *><Ignore> *experimentKeyToExperimentIdMap;
@property (nonatomic, strong) NSDictionary<NSString *, OPTLYGroup *><Ignore> *groupIdToGroupMap;
@property (nonatomic, strong) NSDictionary<NSString *, OPTLYAttribute *><Ignore> *attributeKeyToAttributeMap;
//@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, NSString *>><Ignore> *forcedVariationMap;
//    userId --> experimentId --> variationId
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableDictionary *><Ignore> *forcedVariationMap;

@end

@implementation OPTLYProjectConfig

+ (nullable instancetype)init:(nonnull OPTLYProjectConfigBuilderBlock)builderBlock {
    return [[self alloc] initWithBuilder:[OPTLYProjectConfigBuilder builderWithBlock:builderBlock]];
}

- (instancetype)initWithBuilder:(OPTLYProjectConfigBuilder *)builder {

    // initialize all class static objects
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // static objects which should be initialized once
        supportedDatafileVersions = @[@"2", @"3", @"4"];
    });
    
    // check for valid error handler
    if (builder.errorHandler) {
        if (![OPTLYErrorHandler conformsToOPTLYErrorHandlerProtocol:[builder.errorHandler class]]) {
            NSError *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                                 code:OPTLYErrorTypesErrorHandlerInvalid
                                             userInfo:@{NSLocalizedDescriptionKey :
                                                            NSLocalizedString(OPTLYErrorHandlerMessagesErrorHandlerInvalid, nil)}];
            [[[OPTLYErrorHandlerNoOp alloc] init] handleError:error];
            
            NSString *logMessage = OPTLYErrorHandlerMessagesErrorHandlerInvalid;
            [[[OPTLYLoggerDefault alloc] initWithLogLevel:OptimizelyLogLevelAll] logMessage:logMessage withLevel:OptimizelyLogLevelError];
            return nil;
        }
    }
    
    // check for valid logger
    if (builder.logger) {
        if (![builder.logger conformsToProtocol:@protocol(OPTLYLogger)]) {
            builder.logger = [OPTLYLoggerDefault new];
            NSError *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                                 code:OPTLYErrorTypesLoggerInvalid
                                             userInfo:@{NSLocalizedDescriptionKey :
                                                            NSLocalizedString(OPTLYErrorHandlerMessagesLoggerInvalid, nil)}];
            [builder.errorHandler handleError:error];
            
            NSString *logMessage = OPTLYErrorHandlerMessagesLoggerInvalid;
            [builder.logger logMessage:logMessage withLevel:OptimizelyLogLevelError];
            return nil;
        }
    }
    
    // check that datafile exists
    if (!builder.datafile) {
        NSError *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                             code:OPTLYErrorTypesDatafileInvalid
                                         userInfo:@{NSLocalizedDescriptionKey :
                                                        NSLocalizedString(OPTLYErrorHandlerMessagesDataFileInvalid, nil)}];
        [builder.errorHandler handleError:error];
        
        NSString *logMessage = OPTLYErrorHandlerMessagesDataFileInvalid;
        [builder.logger logMessage:logMessage withLevel:OptimizelyLogLevelError];
        return nil;
    }
    
    // check datafile is valid
    @try {
        NSError *datafileError;
        OPTLYProjectConfig *projectConfig = [[OPTLYProjectConfig alloc] initWithData:builder.datafile error:&datafileError];
        
        if (!datafileError && ![supportedDatafileVersions containsObject:projectConfig.version]) {
            NSString *description = [NSString stringWithFormat:OPTLYErrorHandlerMessagesDataFileInvalid, projectConfig.version];
            datafileError = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                                code:OPTLYErrorTypesDatafileInvalid
                                            userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(description, nil)}];
        }
        
        // check if project config's datafile version matches expected datafile version
        if (![projectConfig.version isEqualToString:kExpectedDatafileVersion]) {
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesDatafileVersion, projectConfig.version];
            [builder.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
        }
        
        if (projectConfig.anonymizeIP == nil) {
            NSString *logMessage = @"Forcing old datafile to include anonymizeIP required by V4 format.";
            [builder.logger logMessage:logMessage withLevel:OptimizelyLogLevelWarning];
            projectConfig.anonymizeIP = @1;
        }

        if (datafileError)
        {
            NSError *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                                 code:OPTLYErrorTypesDatafileInvalid
                                             userInfo:datafileError.userInfo];
            [builder.errorHandler handleError:error];
            return nil;
        }
        else {
            self = projectConfig;
        }
    }
    @catch (NSException *datafileException) {
        [builder.errorHandler handleException:datafileException];
    }
    
    if (builder.userProfileService) {
        if (![OPTLYUserProfileServiceUtility conformsToOPTLYUserProfileServiceProtocol:[builder.userProfileService class]]) {
            [builder.logger logMessage:OPTLYErrorHandlerMessagesUserProfileInvalid withLevel:OptimizelyLogLevelWarning];
        } else {
            _userProfileService = (id<OPTLYUserProfileService, Ignore>)builder.userProfileService;
        }
    }
    
    _clientEngine = builder.clientEngine;
    _clientVersion = builder.clientVersion;
    
    _errorHandler = (id<OPTLYErrorHandler, Ignore>)builder.errorHandler;
    _logger = (id<OPTLYLogger, Ignore>)builder.logger;
    return self;
}

- (nullable instancetype)initWithDatafile:(nonnull NSData *)datafile {
    return [[OPTLYProjectConfig alloc] initWithBuilder:[OPTLYProjectConfigBuilder builderWithBlock:^(OPTLYProjectConfigBuilder * _Nullable builder) {
        builder.datafile = datafile;
    }]];
}

#pragma mark -- Getters --
- (OPTLYAudience *)getAudienceForId:(NSString *)audienceId
{
    OPTLYAudience *audience = self.audienceIdToAudienceMap[audienceId];
    if (!audience) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceUnknownForAudienceId, audienceId];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    }
    return audience;
}

- (OPTLYAttribute *)getAttributeForKey:(NSString *)attributeKey {
    OPTLYAttribute *attribute = self.attributeKeyToAttributeMap[attributeKey];
    if (!attribute) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAttributeUnknownForAttributeKey, attributeKey];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    }
    return attribute;
}

- (nullable NSString *)getAttributeIdForKey:(nonnull NSString *)attributeKey {
    OPTLYAttribute *attribute = self.attributeKeyToAttributeMap[attributeKey];
    BOOL hasReservedPrefix = [attributeKey hasPrefix:kReservedAttributePrefix];
    NSString *attributeId;
    if (attribute) {
        if (hasReservedPrefix) {
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAttributeIsReserved, attributeKey, kReservedAttributePrefix];
            [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelWarning];
        }
        attributeId = attribute.attributeId;
    } else if (hasReservedPrefix) {
        attributeId = attributeKey;
    }
    
    if (attributeId == nil) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAttributeNotFound, attributeKey];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelError];
    }
    return attributeId;
}

- (NSString *)getEventIdForKey:(NSString *)eventKey {
    NSString *eventId = self.eventKeyToEventIdMap[eventKey];
    if (!eventId) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventIdUnknownForEventKey, eventKey];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    }
    return eventId;
}

- (OPTLYEvent *)getEventForKey:(NSString *)eventKey{
    OPTLYEvent *event = self.eventKeyToEventMap[eventKey];
    if (!event) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventUnknownForEventKey, eventKey];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    }
    return event;
}

- (OPTLYExperiment *)getExperimentForId:(NSString *)experimentId {
    OPTLYExperiment *experiment = self.experimentIdToExperimentMap[experimentId];
    if (!experiment) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesExperimentUnknownForExperimentId, experimentId];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    }
    return experiment;
}

- (OPTLYExperiment *)getExperimentForKey:(NSString *)experimentKey {
    OPTLYExperiment *experiment = self.experimentKeyToExperimentMap[experimentKey];
    if (!experiment) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesExperimentUnknownForExperimentKey, experimentKey];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    }
    return experiment;
}

- (NSString *)getExperimentIdForKey:(NSString *)experimentKey
{
    NSString *experimentId = self.experimentKeyToExperimentIdMap[experimentKey];
    if (!experimentId) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesExperimentIdUnknownForExperimentKey, experimentKey];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    }
    return experimentId;
}

- (BOOL)isFeatureExperiment:(NSString *)experimentId
{
    return [self.experimentIdToFeatureIdsMap.allKeys containsObject:experimentId];
}

- (OPTLYGroup *)getGroupForGroupId:(NSString *)groupId {
    OPTLYGroup *group = self.groupIdToGroupMap[groupId];
    if (!group) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesGroupUnknownForGroupId, groupId];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    }
    return group;
}

- (OPTLYFeatureFlag *)getFeatureFlagForKey:(NSString *)featureFlagKey {
    OPTLYFeatureFlag *featureFlag = self.featureFlagKeyToFeatureFlagMap[featureFlagKey];
    if (!featureFlag) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesFeatureFlagUnknownForFeatureFlagKey, featureFlagKey];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    }
    return featureFlag;
}

- (OPTLYRollout *)getRolloutForId:(NSString *)rolloutId {
    OPTLYRollout *rollout = self.rolloutIdToRolloutMap[rolloutId];
    if (!rollout) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesRolloutUnknownForRolloutId, rolloutId];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    }
    return rollout;
}

#pragma mark -- Forced Variation Methods --

- (OPTLYVariation *)getForcedVariation:(nonnull NSString *)experimentKey
                                userId:(nonnull NSString *)userId {

    NSMutableDictionary<NSString *, NSString *> *dictionary = self.forcedVariationMap[userId];
    if (dictionary == nil) {
        return nil;
    }
    // Get experiment from experimentKey .
    OPTLYExperiment *experiment = [self getExperimentForKey:experimentKey];
    // this case is logged in getExperimentFromKey
    if (!experiment || [self isNullOrEmpty:experiment.experimentId]) {
        return nil;
    }
    
    OPTLYVariation *variation = nil;
    @synchronized (self.forcedVariationMap) {
        // Get variation from experimentId and variationId .
        NSString *variationId = dictionary[experiment.experimentId];
        if ([self isNullOrEmpty:variationId]) {
            return nil;
        }
        variation = [experiment getVariationForVariationId:variationId];
        
        if (!variation || [self isNullOrEmpty:variation.variationKey]) {
            return nil;
        }
    }
    
    return variation;
}

- (BOOL)setForcedVariation:(nonnull NSString *)experimentKey
                    userId:(nonnull NSString *)userId
              variationKey:(nullable NSString *)variationKey {
    // Return YES if there were no errors, OW return NO .
    //Check if variationKey is empty string
    if (variationKey != nil && [variationKey isEqualToString:@""]) {
        [self.logger logMessage:OPTLYLoggerMessagesProjectConfigVariationKeyInvalid withLevel:OptimizelyLogLevelDebug];
        return NO;
    }
    
    // Get experiment from experimentKey .
    OPTLYExperiment *experiment = [self getExperimentForKey:experimentKey];
    if (!experiment) {
        // NOTE: getExperimentForKey: will log any non-existent experimentKey and return experiment == nil for us.
        return NO;
    }
    NSString *experimentId = experiment.experimentId;
    //Check if experimentId is valid
    if ([self isNullOrEmpty:experimentId]) {
        return NO;
    }
    
    @synchronized (self.forcedVariationMap) {
        // clear the forced variation if the variation key is null
        if (variationKey == nil) {
            // Locate relevant dictionary inside forcedVariationMap
            NSMutableDictionary<NSString *, NSString *> *dictionary = self.forcedVariationMap[userId];
            if (dictionary != nil) {
                [dictionary removeObjectForKey:experimentId];
                self.forcedVariationMap[userId] = dictionary;
            }
            return YES;
        }
    }
    
    // Get variation from experiment and non-nil variationKey, if applicable.
    OPTLYVariation *variation = [experiment getVariationForVariationKey:variationKey];
    if (!variation || [self isNullOrEmpty:variation.variationId]) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesVariationKeyUnknownForExperimentKey, variationKey, experimentKey];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
        // Leave in current state, and report NO meaning there was an error.
        return NO;
    }
    
    @synchronized (self.forcedVariationMap) {
        // Add User if not exist.
        NSMutableDictionary<NSString *, NSString *> *dictionary = self.forcedVariationMap[userId];
        if (dictionary == nil) {
            // We need a non-nil dictionary to store an OPTLYVariation .
            dictionary = [[NSMutableDictionary alloc] init];
            self.forcedVariationMap[userId] = dictionary;
        }
        // Add/Replace Experiment to Variation ID map.
        self.forcedVariationMap[userId][experimentId] = variation.variationId;
    };
    return YES;
}

#pragma mark -- Property Getters --

- (NSArray *)allExperiments
{
    if (!_allExperiments) {
        NSMutableArray *all = [[NSMutableArray alloc] initWithArray:self.experiments];
        for (OPTLYGroup *group in self.groups) {
            for (OPTLYExperiment *experiment in group.experiments) {
                [all addObject:experiment];
            }
        }
        _allExperiments = [all copy];
    }
    return _allExperiments;
}

- (NSDictionary *)audienceIdToAudienceMap
{
    if (!_audienceIdToAudienceMap) {
        _audienceIdToAudienceMap = [self generateAudienceIdToAudienceMap];
    }
    return _audienceIdToAudienceMap;
}


- (NSDictionary *)attributeKeyToAttributeMap
{
    if (!_attributeKeyToAttributeMap) {
        _attributeKeyToAttributeMap = [self generateAttributeToKeyMap];
    }
    return _attributeKeyToAttributeMap;
}

- (NSDictionary *)eventKeyToEventIdMap {
    if (!_eventKeyToEventIdMap) {
        _eventKeyToEventIdMap = [self generateEventKeyToEventIdMap];
    }
    return _eventKeyToEventIdMap;
}

- (NSDictionary *)eventKeyToEventMap {
    if (!_eventKeyToEventMap) {
        _eventKeyToEventMap = [self generateEventKeyToEventMap];
    }
    return _eventKeyToEventMap;
}

- (NSDictionary<NSString *, OPTLYExperiment *> *)experimentIdToExperimentMap {
    if (!_experimentIdToExperimentMap) {
        _experimentIdToExperimentMap = [self generateExperimentIdToExperimentMap];
    }
    return _experimentIdToExperimentMap;
}

- (NSDictionary<NSString *, OPTLYExperiment *> *)experimentKeyToExperimentMap {
    if (!_experimentKeyToExperimentMap) {
        _experimentKeyToExperimentMap = [self generateExperimentKeyToExperimentMap];
    }
    return  _experimentKeyToExperimentMap;
}

- (NSDictionary<NSString *, NSString *> *)experimentKeyToExperimentIdMap
{
    if (!_experimentKeyToExperimentIdMap) {
        _experimentKeyToExperimentIdMap = [self generateExperimentKeyToIdMap];
    }
    return _experimentKeyToExperimentIdMap;
}

- (NSDictionary<NSString *,NSArray *><Ignore> *)experimentIdToFeatureIdsMap
{
    if (!_experimentIdToFeatureIdsMap) {
        _experimentIdToFeatureIdsMap = [self generateExperimentIdToFeatureIdsMap];
    }
    return _experimentIdToFeatureIdsMap;
}

- (NSDictionary<NSString *, OPTLYGroup *> *)groupIdToGroupMap {
    if (!_groupIdToGroupMap) {
        _groupIdToGroupMap = [OPTLYProjectConfig generateGroupIdToGroupMapFromGroupsArray:_groups];
    }
    return _groupIdToGroupMap;
}

//- (NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, NSString *>> *)forcedVariationMap {
- (NSMutableDictionary<NSString *, NSMutableDictionary *> *)forcedVariationMap {
    @synchronized (self) {
        if (!_forcedVariationMap) {
            _forcedVariationMap = [[NSMutableDictionary alloc] init];
        }
    }
    return _forcedVariationMap;
}

- (NSDictionary<NSString *, OPTLYFeatureFlag *> *)featureFlagKeyToFeatureFlagMap {
    if (!_featureFlagKeyToFeatureFlagMap) {
        _featureFlagKeyToFeatureFlagMap = [self generateFeatureFlagKeyToFeatureFlagMap];
    }
    return  _featureFlagKeyToFeatureFlagMap;
}

- (NSDictionary<NSString *, OPTLYRollout *> *)rolloutIdToRolloutMap {
    if (!_rolloutIdToRolloutMap) {
        _rolloutIdToRolloutMap = [self generateRolloutIdToRolloutMap];
    }
    return _rolloutIdToRolloutMap;
}

#pragma mark -- Generate Mappings --

- (NSDictionary *)generateAudienceIdToAudienceMap
{
    NSMutableDictionary *map = [NSMutableDictionary new];
    for (OPTLYAudience *audience in self.audiences) {
        NSString *audienceId = audience.audienceId;
        map[audienceId] = audience;
    }
    //override previously mapped audience objects with typed audience objects
    if (self.typedAudiences) {
        for (OPTLYAudience *audience in self.typedAudiences) {
            NSString *audienceId = audience.audienceId;
            map[audienceId] = audience;
        }
    }
    return map;
}

- (NSDictionary *)generateAttributeToKeyMap
{
    NSMutableDictionary *map = [NSMutableDictionary new];
    for (OPTLYAttribute *attribute in self.attributes) {
        NSString *attributeKey = attribute.attributeKey;
        map[attributeKey] = attribute;
    }
    return map;
}

+ (NSDictionary<NSString *, OPTLYEvent *> *)generateEventIdToEventMapFromEventArray:(NSArray<OPTLYEvent *> *) events {
    NSMutableDictionary *map = [[NSMutableDictionary alloc] initWithCapacity:events.count];
    for (OPTLYEvent *event in events) {
        map[event.eventId] = event;
    }
    return [NSDictionary dictionaryWithDictionary:map];
}

- (NSDictionary<NSString *, NSString *> *)generateEventKeyToEventIdMap
{
    NSMutableDictionary *map = [[NSMutableDictionary alloc] initWithCapacity:self.events.count];
    for (OPTLYEvent *event in self.events) {
        map[event.eventKey] = event.eventId;
    }
    return [map copy];
}

- (NSDictionary<NSString *, OPTLYEvent *> *)generateEventKeyToEventMap
{
    NSMutableDictionary *map = [[NSMutableDictionary alloc] initWithCapacity:self.events.count];
    for (OPTLYEvent *event in self.events) {
        map[event.eventKey] = event;
    }
    return [map copy];
}

- (NSDictionary<NSString *, OPTLYExperiment *> *)generateExperimentIdToExperimentMap {
    NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
    for (OPTLYExperiment *experiment in self.allExperiments) {
        map[experiment.experimentId] = experiment;
    }
    
    return [NSDictionary dictionaryWithDictionary:map];
}

- (NSDictionary<NSString *, OPTLYExperiment *> *)generateExperimentKeyToExperimentMap {
    NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
    for (OPTLYExperiment *experiment in self.allExperiments) {
        map[experiment.experimentKey] = experiment;
    }
    return [NSDictionary dictionaryWithDictionary:map];
}

- (NSDictionary<NSString *, NSString *> *)generateExperimentKeyToIdMap {
    NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
    for (OPTLYExperiment *experiment in self.allExperiments) {
        map[experiment.experimentKey] = experiment.experimentId;
    }
    return [map copy];
}

- (NSDictionary<NSString *, NSArray *> *)generateExperimentIdToFeatureIdsMap {
    NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
    for (OPTLYFeatureFlag *featureFlag in self.featureFlags) {
        for (NSString *experimentId in featureFlag.experimentIds) {
            if ([map.allKeys containsObject:experimentId]) {
                NSMutableArray *featureIdsArray = [[NSMutableArray alloc] initWithArray:map[experimentId]];
                [featureIdsArray addObject:featureFlag.flagId];
                map[experimentId] = [featureIdsArray copy];
            }
            else {
                NSArray *featureIdsArray = @[featureFlag.flagId];
                map[experimentId] = featureIdsArray;
            }
        }
    }
    return [map copy];
}

+ (NSDictionary<NSString *, OPTLYGroup *> *)generateGroupIdToGroupMapFromGroupsArray:(NSArray<OPTLYGroup *> *) groups{
    NSMutableDictionary *map = [[NSMutableDictionary alloc] initWithCapacity:groups.count];
    for (OPTLYGroup *group in groups) {
        map[group.groupId] = group;
    }
    return [NSDictionary dictionaryWithDictionary:map];
}

- (NSDictionary<NSString *, OPTLYFeatureFlag *> *)generateFeatureFlagKeyToFeatureFlagMap {
    NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
    for (OPTLYFeatureFlag *featureFlag in self.featureFlags) {
        map[featureFlag.key] = featureFlag;
    }
    return [NSDictionary dictionaryWithDictionary:map];
}

- (NSDictionary<NSString *, OPTLYRollout *> *)generateRolloutIdToRolloutMap {
    NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
    for (OPTLYRollout *rollout in self.rollouts) {
        map[rollout.rolloutId] = rollout;
    }
    
    return [NSDictionary dictionaryWithDictionary:map];
}

# pragma mark - Helper Methods

// TODO: Remove bucketer from parameters -- this is not needed
- (OPTLYVariation *)getVariationForExperiment:(NSString *)experimentKey
                                       userId:(NSString *)userId
                                   attributes:(NSDictionary<NSString *, id> *)attributes
                                     bucketer:(id<OPTLYBucketer>)bucketer
{
    OPTLYExperiment *experiment = [self getExperimentForKey:experimentKey];
    OPTLYDecisionService *decisionService = [[OPTLYDecisionService alloc] initWithProjectConfig:self
                                                                                       bucketer:bucketer];
    OPTLYVariation *bucketedVariation = [decisionService getVariation:userId
                                                           experiment:experiment
                                                           attributes:attributes];
    
    NSString *logMessage = nil;
    
    if (bucketedVariation) {
        logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesVariationUserAssigned, userId, bucketedVariation.variationKey, experimentKey];
    } else {
        logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesGetVariationNilVariation, userId, experimentKey];
    }
    
    [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    
    return bucketedVariation;
}

- (BOOL)isNullOrEmpty:(nullable NSString *)value {
    return ((value == nil) || [value isKindOfClass: [NSNull class]] || [value isEqualToString:@""]);
}
@end
