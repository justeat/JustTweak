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

#import "Optimizely.h"
#import "OPTLYBucketer.h"
#import "OPTLYDatafileKeys.h"
#import "OPTLYDecisionEventTicket.h"
#import "OPTLYErrorHandler.h"
#import "OPTLYEventBuilder.h"
#import "OPTLYEventDecision.h"
#import "OPTLYEventDispatcherBasic.h"
#import "OPTLYEventLayerState.h"
#import "OPTLYEventMetric.h"
#import "OPTLYEventParameterKeys.h"
#import "OPTLYEvent.h"
#import "OPTLYExperiment.h"
#import "OPTLYLogger.h"
#import "OPTLYProjectConfig.h"
#import "OPTLYUserProfileServiceBasic.h"
#import "OPTLYVariation.h"
#import "OPTLYFeatureFlag.h"
#import "OPTLYFeatureDecision.h"
#import "OPTLYDecisionService.h"
#import "OPTLYFeatureVariable.h"
#import "OPTLYVariableUsage.h"
#import "OPTLYNotificationCenter.h"
#import "OPTLYNSObject+Validation.h"

@implementation Optimizely

+ (instancetype)init:(OPTLYBuilderBlock)builderBlock {
    return [[self alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:builderBlock]];
}

- (instancetype)init {
    return [self initWithBuilder:nil];
}

- (instancetype)initWithBuilder:(OPTLYBuilder *)builder {
    self = [super init];
    if (self != nil) {
        if (builder != nil) {
            _bucketer = builder.bucketer;
            _decisionService = builder.decisionService;
            _config = builder.config;
            _eventBuilder = builder.eventBuilder;
            _eventDispatcher = builder.eventDispatcher;
            _errorHandler = builder.errorHandler;
            _logger = builder.logger;
            _userProfileService = builder.userProfileService;
            _notificationCenter = builder.notificationCenter;
        } else {
            // Provided OPTLYBuilder object is invalid
            if (_logger == nil) {
                _logger = [[OPTLYLoggerDefault alloc] initWithLogLevel:OptimizelyLogLevelAll];
            }
            NSString *logMessage = NSLocalizedString(OPTLYErrorHandlerMessagesBuilderInvalid, nil);
            [_logger logMessage:logMessage
                      withLevel:OptimizelyLogLevelError];
            NSError *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                                 code:OPTLYErrorTypesBuilderInvalid
                                             userInfo:@{NSLocalizedDescriptionKey : logMessage}];
            if (_errorHandler == nil) {
                _errorHandler = [[OPTLYErrorHandlerNoOp alloc] init];
            }
            [_errorHandler handleError:error];
            self = nil;
        }
    }
    return self;
}

- (OPTLYVariation *)activate:(NSString *)experimentKey
                      userId:(NSString *)userId {
    return [self activate:experimentKey
                   userId:userId
               attributes:nil];
}

- (OPTLYVariation *)activate:(NSString *)experimentKey
                      userId:(NSString *)userId
                  attributes:(NSDictionary<NSString *, id> *)attributes
{
    return [self activate:experimentKey userId:userId attributes:attributes callback:nil];
}

- (OPTLYVariation *)activate:(NSString *)experimentKey
                      userId:(NSString *)userId
                  attributes:(NSDictionary<NSString *, id> *)attributes
                    callback:(void (^)(NSError *))callback {
    
    __weak void (^_callback)(NSError *) = callback ? : ^(NSError *error) {};
    
    if ([experimentKey getValidString] == nil) {
        NSError *error = [self handleErrorLogsForActivate:OPTLYLoggerMessagesActivateExperimentKeyEmpty ofLevel:OptimizelyLogLevelError];
        _callback(error);
        return nil;
    }
    
    if (![userId isValidStringType]) {
        NSError *error = [self handleErrorLogsForActivate:OPTLYLoggerMessagesUserIdInvalid ofLevel:OptimizelyLogLevelError];
        _callback(error);
        return nil;
    }
    
    // get experiment
    OPTLYExperiment *experiment = [self.config getExperimentForKey:experimentKey];
    
    if (!experiment) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesActivateExperimentKeyInvalid, experimentKey];
        NSError *error = [self handleErrorLogsForActivate:logMessage ofLevel:OptimizelyLogLevelError];
        _callback(error);
        return nil;
    }
    
    // get variation
    OPTLYVariation *variation = [self variation:experimentKey userId:userId attributes:attributes];

    if (!variation) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherActivationFailure, userId, experimentKey];
        NSError *error = [self handleErrorLogsForActivate:logMessage ofLevel:OptimizelyLogLevelInfo];
        _callback(error);
        return nil;
    }
    
    // send impression event
    __weak typeof(self) weakSelf = self;
    OPTLYVariation *sentVariation = [self sendImpressionEventFor:experiment
                                                       variation:variation
                                                          userId:userId
                                                      attributes:attributes
                                                        callback:^(NSError *error) {
        if (error) {
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherActivationFailure, userId, experimentKey];
            [weakSelf handleErrorLogsForActivate:logMessage ofLevel:OptimizelyLogLevelInfo];
        }
        _callback(error);
    }];
    
    if (!sentVariation) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherActivationFailure, userId, experimentKey];
        NSError *error = [self handleErrorLogsForActivate:logMessage ofLevel:OptimizelyLogLevelInfo];
        _callback(error);
        return nil;
    }

    return variation;
}

#pragma mark getVariation methods
- (OPTLYVariation *)variation:(NSString *)experimentKey
                       userId:(NSString *)userId {
    return [self variation:experimentKey
                    userId:userId
                attributes:nil];
}

- (OPTLYVariation *)variation:(NSString *)experimentKey
                       userId:(NSString *)userId
                   attributes:(NSDictionary<NSString *, id> *)attributes
{
    OPTLYVariation *bucketedVariation = [self.config getVariationForExperiment:experimentKey
                                                                        userId:userId
                                                                    attributes:attributes
                                                                      bucketer:self.bucketer];
    OPTLYExperiment *experiment = [self.config getExperimentForKey:experimentKey];
    NSString *decisionType = [self.config isFeatureExperiment:experiment.experimentId] ? OPTLYDecisionTypeFeatureTest : OPTLYDecisionTypeABTest;
    
    NSMutableDictionary *args = [[NSMutableDictionary alloc] init];
    [args setValue:decisionType forKey:OPTLYNotificationDecisionTypeKey];
    [args setValue:userId forKey:OPTLYNotificationUserIdKey];
    [args setValue:attributes forKey:OPTLYNotificationAttributesKey];
    
    NSMutableDictionary *decisionInfo = [NSMutableDictionary new];
    NSMutableDictionary *sourceInfo = [NSMutableDictionary new];
    sourceInfo[ExperimentDecisionInfo.ExperimentKey] = experimentKey;
    sourceInfo[ExperimentDecisionInfo.VariationKey] = bucketedVariation.variationKey ?: [NSNull null];
    decisionInfo = sourceInfo;
    [args setValue:decisionInfo forKey:DecisionInfo.Key];
    
    [_notificationCenter sendNotifications:OPTLYNotificationTypeDecision args:args];
    
    return bucketedVariation;
}

#pragma mark Forced variation methods
- (OPTLYVariation *)getForcedVariation:(nonnull NSString *)experimentKey
                                userId:(nonnull NSString *)userId {
    NSMutableDictionary<NSString *, NSString *> *inputValues = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                                                    OPTLYNotificationUserIdKey:[self ObjectOrNull:userId],
                                                                                                                    OPTLYNotificationExperimentKey:[self ObjectOrNull:experimentKey]}];
    if (![self validateStringInputs:inputValues logs:@{}]) {
        return nil;
    }
    return [self.config getForcedVariation:experimentKey
                                    userId:userId];
}

- (BOOL)setForcedVariation:(nonnull NSString *)experimentKey
                    userId:(nonnull NSString *)userId
              variationKey:(nullable NSString *)variationKey {
    NSMutableDictionary<NSString *, NSString *> *inputValues = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                                                    OPTLYNotificationUserIdKey:[self ObjectOrNull:userId],
                                                                                                                    OPTLYNotificationExperimentKey:[self ObjectOrNull:experimentKey]}];
    return [self validateStringInputs:inputValues logs:@{}] && [self.config setForcedVariation:experimentKey
                                    userId:userId
                              variationKey:variationKey];
}

#pragma mark - Feature Flag Methods

- (BOOL)isFeatureEnabled:(NSString *)featureKey userId:(NSString *)userId attributes:(nullable NSDictionary<NSString *, id> *)attributes {
    BOOL result = false;
    NSMutableDictionary<NSString *, NSString *> *inputValues = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                                                    OPTLYNotificationUserIdKey:[self ObjectOrNull:userId],
                                                                                                                    OPTLYNotificationExperimentKey:[self ObjectOrNull:featureKey]}];
    NSDictionary <NSString *, NSString *> *logs = @{
                                                    OPTLYNotificationUserIdKey:OPTLYLoggerMessagesFeatureDisabledUserIdInvalid,
                                                    OPTLYNotificationExperimentKey:OPTLYLoggerMessagesFeatureDisabledFlagKeyInvalid};
    
    if (![self validateStringInputs:inputValues logs:logs]) {
        return result;
    }
    
    OPTLYFeatureFlag *featureFlag = [self.config getFeatureFlagForKey:featureKey];
    if ([featureFlag.key getValidString] == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesFeatureDisabledFlagKeyInvalid withLevel:OptimizelyLogLevelError];
        return result;
    }
    if (![featureFlag isValid:self.config]) {
        return result;
    }
    
    OPTLYFeatureDecision *decision = [self.decisionService getVariationForFeature:featureFlag userId:userId attributes:attributes];
    
    NSMutableDictionary *args = [[NSMutableDictionary alloc] init];
    [args setValue:OPTLYDecisionTypeFeature forKey:OPTLYNotificationDecisionTypeKey];
    [args setValue:userId forKey:OPTLYNotificationUserIdKey];
    [args setValue:attributes forKey:OPTLYNotificationAttributesKey];
    
    NSMutableDictionary *decisionInfo = [NSMutableDictionary new];
    [decisionInfo setValue:@{} forKey:DecisionInfo.SourceInfoKey];
    [decisionInfo setValue:featureKey forKey:DecisionInfo.FeatureKey];
    
    if (decision) {
        if ([decision.source isEqualToString:DecisionSource.FeatureTest]) {
            NSMutableDictionary *sourceInfo = [NSMutableDictionary new];
            [sourceInfo setValue:decision.experiment.experimentKey forKey:ExperimentDecisionInfo.ExperimentKey];
            [sourceInfo setValue:decision.variation.variationKey forKey:ExperimentDecisionInfo.VariationKey];
            [decisionInfo setValue:sourceInfo forKey:DecisionInfo.SourceInfoKey];
            [self sendImpressionEventFor:decision.experiment
                               variation:decision.variation
                                  userId:userId
                              attributes:attributes
                                callback:nil];
        } else {
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesFeatureEnabledNotExperimented, userId, featureKey];
            [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
        }

        if (decision.variation.featureEnabled) {
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesFeatureEnabled, featureKey, userId];
            [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
            result = true;
        }
    }
    
    if (!result) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesFeatureDisabled, featureKey, userId];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
    }
    
    [decisionInfo setValue:[NSNumber numberWithBool:result] forKey:DecisionInfo.FeatureEnabledKey];
    [decisionInfo setValue:decision.source forKey:DecisionInfo.SourceKey];
    [args setValue:decisionInfo forKey:DecisionInfo.Key];
    
    [_notificationCenter sendNotifications:OPTLYNotificationTypeDecision args:args];
    
    return result;
}

- (id)getFeatureVariableValueForType:(NSString *)variableType
                          featureKey:(nullable NSString *)featureKey
                         variableKey:(nullable NSString *)variableKey
                              userId:(nullable NSString *)userId
                          attributes:(nullable NSDictionary<NSString *, id> *)attributes {
    
    NSMutableDictionary<NSString *, NSString *> *inputValues = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                                                    OPTLYNotificationUserIdKey:[self ObjectOrNull:userId],
                                                                                                                    DecisionInfo.FeatureKey:[self ObjectOrNull:featureKey],
                                                                                                                    DecisionInfo.VariableKey:[self ObjectOrNull:variableKey]}];
    NSDictionary <NSString *, NSString *> *logs = @{
                                                    OPTLYNotificationUserIdKey:OPTLYLoggerMessagesFeatureVariableValueUserIdInvalid,
                                                    DecisionInfo.VariableKey:OPTLYLoggerMessagesFeatureVariableValueVariableKeyInvalid,
                                                    DecisionInfo.FeatureKey:OPTLYLoggerMessagesFeatureVariableValueFlagKeyInvalid};
    
    if (![self validateStringInputs:inputValues logs:logs]) {
        return nil;
    }
    
    OPTLYFeatureFlag *featureFlag = [self.config getFeatureFlagForKey:featureKey];
    if ([featureFlag.key getValidString] == nil) {
        return nil;
    }
    
    OPTLYFeatureVariable *featureVariable = [featureFlag getFeatureVariableForKey:variableKey];
    if (!featureVariable) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesFeatureVariableValueVariableInvalid, variableKey, featureKey];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelError];
        return nil;
    } else if (![featureVariable.type isEqualToString:variableType]) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesFeatureVariableValueVariableTypeInvalid, featureVariable.type, variableType];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelError];
        return nil;
    }
    
    NSMutableDictionary *decisionInfo = [NSMutableDictionary new];
    [decisionInfo setValue:@{} forKey:DecisionInfo.SourceInfoKey];
    
    NSString *variableValue = featureVariable.defaultValue;
    OPTLYFeatureDecision *decision = [self.decisionService getVariationForFeature:featureFlag userId:userId attributes:attributes];
    if (decision) {
        if ([decision.source isEqualToString:DecisionSource.FeatureTest]) {
            NSMutableDictionary *sourceInfo = [NSMutableDictionary new];
            [sourceInfo setValue:decision.experiment.experimentKey forKey:ExperimentDecisionInfo.ExperimentKey];
            [sourceInfo setValue:decision.variation.variationKey forKey:ExperimentDecisionInfo.VariationKey];
            [decisionInfo setValue:sourceInfo forKey:DecisionInfo.SourceInfoKey];
        }
        OPTLYVariation *variation = decision.variation;
        OPTLYVariableUsage *featureVariableUsage = [variation getVariableUsageForVariableId:featureVariable.variableId];
        if (featureVariableUsage) {
            if (variation.featureEnabled) {
                variableValue = featureVariableUsage.value;
                NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesFeatureVariableValueVariableType, variableValue, variation.variationKey, featureFlag.key];
                [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
            } else {
                NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesFeatureDisabledReturnDefault, featureFlag.key, userId, variableValue];
                [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
            }
        } else {
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesFeatureVariableValueNotUsed, variableKey, variation.variationKey, variableValue];
            [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
        }
    } else {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesFeatureVariableValueNotBucketed, userId, featureFlag.key, variableValue];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
    }
    
    id finalValue = nil;
    if (variableValue) {
        if ([variableType isEqualToString:FeatureVariableTypeBoolean]) {
            finalValue = [NSNumber numberWithBool:[variableValue boolValue]];
        } else if ([variableType isEqualToString:FeatureVariableTypeDouble]) {
            finalValue = [NSNumber numberWithDouble:[variableValue doubleValue]];
        } else if ([variableType isEqualToString:FeatureVariableTypeInteger]) {
            finalValue = [NSNumber numberWithDouble:[variableValue intValue]];
        } else if ([variableType isEqualToString:FeatureVariableTypeString]) {
            finalValue = variableValue;
        }
    }
    
    NSMutableDictionary *args = [[NSMutableDictionary alloc] init];
    [args setValue:OPTLYDecisionTypeFeatureVariable forKey:OPTLYNotificationDecisionTypeKey];
    [args setValue:userId forKey:OPTLYNotificationUserIdKey];
    [args setValue:attributes forKey:OPTLYNotificationAttributesKey];
    
    [decisionInfo setValue:featureKey forKey:DecisionInfo.FeatureKey];
    [decisionInfo setValue:[NSNumber numberWithBool:decision.variation.featureEnabled] forKey:DecisionInfo.FeatureEnabledKey];
    [decisionInfo setValue:variableKey forKey:DecisionInfo.VariableKey];
    [decisionInfo setValue:variableType forKey:DecisionInfo.VariableTypeKey];
    [decisionInfo setValue:finalValue forKey:DecisionInfo.VariableValueKey];
    [decisionInfo setValue:decision.source forKey:DecisionInfo.SourceKey];
    [args setValue:decisionInfo forKey:DecisionInfo.Key];
    
    [_notificationCenter sendNotifications:OPTLYNotificationTypeDecision args:args];
    
    return finalValue;
}

- (NSNumber *)getFeatureVariableBoolean:(nullable NSString *)featureKey
                      variableKey:(nullable NSString *)variableKey
                           userId:(nullable NSString *)userId
                       attributes:(nullable NSDictionary<NSString *, id> *)attributes {
    
    NSNumber* booleanValue = [self getFeatureVariableValueForType:FeatureVariableTypeBoolean
                                                        featureKey:featureKey
                                                       variableKey:variableKey
                                                            userId:userId
                                                        attributes:attributes];
    return booleanValue;
}

- (NSNumber *)getFeatureVariableDouble:(nullable NSString *)featureKey
                      variableKey:(nullable NSString *)variableKey
                           userId:(nullable NSString *)userId
                       attributes:(nullable NSDictionary<NSString *, id> *)attributes {
    
    NSNumber* doubleValue = [self getFeatureVariableValueForType:FeatureVariableTypeDouble
                                                        featureKey:featureKey
                                                       variableKey:variableKey
                                                            userId:userId
                                                        attributes:attributes];
    return doubleValue;
}


- (NSNumber *)getFeatureVariableInteger:(nullable NSString *)featureKey
                       variableKey:(nullable NSString *)variableKey
                            userId:(nullable NSString *)userId
                        attributes:(nullable NSDictionary<NSString *, id> *)attributes {
    
    NSNumber* intValue = [self getFeatureVariableValueForType:FeatureVariableTypeInteger
                                                        featureKey:featureKey
                                                       variableKey:variableKey
                                                            userId:userId
                                                        attributes:attributes];
    return intValue;
}

- (NSString *)getFeatureVariableString:(nullable NSString *)featureKey
                           variableKey:(nullable NSString *)variableKey
                                userId:(nullable NSString *)userId
                            attributes:(nullable NSDictionary<NSString *, id> *)attributes {
    return [self getFeatureVariableValueForType:FeatureVariableTypeString
                                     featureKey:featureKey
                                    variableKey:variableKey
                                         userId:userId
                                     attributes:attributes];
}
    
- (NSArray<NSString *> *)getEnabledFeatures:(NSString *)userId
                                attributes:(NSDictionary<NSString *, id> *)attributes {
    
    
    NSMutableArray<NSString *> *enabledFeatures = [NSMutableArray new];
    
    NSMutableDictionary<NSString *, NSString *> *inputValues = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                                                    OPTLYNotificationUserIdKey:[self ObjectOrNull:userId]}];
    NSDictionary <NSString *, NSString *> *logs = @{};
    
    if (![self validateStringInputs:inputValues logs:logs]) {
        return enabledFeatures;
    }
    
    for (OPTLYFeatureFlag *feature in self.config.featureFlags) {
        NSString *featureKey = feature.key;
        if ([self isFeatureEnabled:featureKey userId:userId attributes:attributes]) {
            [enabledFeatures addObject:featureKey];
        }
    }
    return enabledFeatures;
}

#pragma mark trackEvent methods

- (void)track:(NSString *)eventKey userId:(NSString *)userId {
    [self track:eventKey userId:userId attributes:nil eventTags:nil];
}

- (void)track:(NSString *)eventKey
       userId:(NSString *)userId
   attributes:(NSDictionary<NSString *, id> * )attributes {
    [self track:eventKey userId:userId attributes:attributes eventTags:nil];
}

- (void)track:(NSString *)eventKey
       userId:(NSString *)userId
    eventTags:(NSDictionary<NSString *,id> *)eventTags {
    [self track:eventKey userId:userId attributes:nil eventTags:eventTags];
}

- (void)track:(NSString *)eventKey
       userId:(NSString *)userId
   attributes:(NSDictionary<NSString *, id> *)attributes
    eventTags:(NSDictionary<NSString *,id> *)eventTags {
    
    if ([eventKey getValidString] == nil) {
        [self handleErrorLogsForTrack:OPTLYLoggerMessagesTrackEventKeyEmpty ofLevel:OptimizelyLogLevelError];
        return;
    }
    
    if (![userId isValidStringType]) {
        [self handleErrorLogsForTrack:OPTLYLoggerMessagesUserIdInvalid ofLevel:OptimizelyLogLevelError];
        return;
    }
    
    OPTLYEvent *event = [self.config getEventForKey:eventKey];
    
    if (!event) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherEventNotTracked, eventKey, userId];
        [self handleErrorLogsForTrack:logMessage ofLevel:OptimizelyLogLevelInfo];
        return;
    }
    
    NSDictionary *conversionEventParams = [self.eventBuilder buildConversionEventForUser:userId
                                                                                   event:event
                                                                               eventTags:eventTags
                                                                              attributes:attributes];
    if ([conversionEventParams getValidDictionary] == nil) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherEventNotTracked, eventKey, userId];
        [self handleErrorLogsForTrack:logMessage ofLevel:OptimizelyLogLevelInfo];
        return;
    }
    
    NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherAttemptingToSendConversionEvent, eventKey, userId];
    [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
    
    __weak typeof(self) weakSelf = self;
    [self.eventDispatcher dispatchConversionEvent:conversionEventParams
                                         callback:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                             if (error) {
                                                 NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherEventNotTracked, eventKey, userId];
                                                 [weakSelf handleErrorLogsForTrack:logMessage ofLevel:OptimizelyLogLevelInfo];
                                             } else {
                                                 NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherTrackingSuccess, eventKey, userId];
                                                 [weakSelf.logger logMessage:logMessage
                                                                     withLevel:OptimizelyLogLevelInfo];
                                             }
                                         }];
    NSMutableDictionary *args = [[NSMutableDictionary alloc] init];
    [args setValue:eventKey forKey:OPTLYNotificationEventKey];
    [args setValue:userId forKey:OPTLYNotificationUserIdKey];
    [args setValue:attributes forKey:OPTLYNotificationAttributesKey];
    [args setValue:eventTags forKey:OPTLYNotificationEventTagsKey];
    [args setValue:conversionEventParams forKey:OPTLYNotificationLogEventParamsKey];
    
    [_notificationCenter sendNotifications:OPTLYNotificationTypeTrack args:args];
}

#pragma GCC diagnostic pop // "-Wdeprecated-declarations" "-Wdeprecated-implementations"

# pragma mark - Helper methods
// log and propagate error for a track failure
- (void)handleErrorLogsForTrack:(NSString *)logMessage ofLevel:(OptimizelyLogLevel)level {
    NSDictionary *errorDictionary = [NSDictionary dictionaryWithObject:logMessage forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                         code:OPTLYErrorTypesEventTrack
                                     userInfo:errorDictionary];
    [self.errorHandler handleError:error];
    [self.logger logMessage:logMessage withLevel:level];
}

// log and propagate error for a activate failure
- (NSError *)handleErrorLogsForActivate:(NSString *)logMessage ofLevel:(OptimizelyLogLevel)level {
    NSDictionary *errorDictionary = [NSDictionary dictionaryWithObject:logMessage forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                         code:OPTLYErrorTypesUserActivate
                                     userInfo:errorDictionary];
    [self.errorHandler handleError:error];
    [self.logger logMessage:logMessage withLevel:level];
    return error;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"config:%@\nlogger:%@\nerrorHandler:%@\neventDispatcher:%@\nuserProfile:%@", self.config, self.logger, self.errorHandler, self.eventDispatcher, self.userProfileService];
}

- (OPTLYVariation *)sendImpressionEventFor:(OPTLYExperiment *)experiment
                                 variation:(OPTLYVariation *)variation
                                    userId:(NSString *)userId
                                attributes:(NSDictionary<NSString *, id> *)attributes
                                  callback:(void (^)(NSError *))callback {
    
    // send impression event
    NSDictionary *impressionEventParams = [self.eventBuilder buildImpressionEventForUser:userId
                                                                              experiment:experiment
                                                                               variation:variation
                                                                              attributes:attributes];
    
    if ([impressionEventParams getValidDictionary] == nil) {
        return nil;
    }
    
    NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherAttemptingToSendImpressionEvent, userId, experiment.experimentKey];
    [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
    
    __weak typeof(self) weakSelf = self;
    [self.eventDispatcher dispatchImpressionEvent:impressionEventParams
                                         callback:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                             if (!error) {
                                                 NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherActivationSuccess, userId, experiment.experimentKey];
                                                 [weakSelf.logger logMessage:logMessage
                                                                   withLevel:OptimizelyLogLevelInfo];
                                             }
                                             if (callback) {
                                                 callback(error);
                                             }
                                         }];
    
    NSMutableDictionary *args = [[NSMutableDictionary alloc] init];
    [args setValue:experiment forKey:OPTLYNotificationExperimentKey];
    [args setValue:userId forKey:OPTLYNotificationUserIdKey];
    [args setValue:attributes forKey:OPTLYNotificationAttributesKey];
    [args setValue:variation forKey:OPTLYNotificationVariationKey];
    [args setValue:impressionEventParams forKey:OPTLYNotificationLogEventParamsKey];
    
    [_notificationCenter sendNotifications:OPTLYNotificationTypeActivate args:args];
    
    return variation;
}

+ (BOOL)isEmptyArray:(NSObject*)array {
    return (!array
            || ![array isKindOfClass:[NSArray class]]
            || (((NSArray *)array).count == 0));
}

+ (BOOL)isEmptyString:(NSObject*)string {
    return (!string
            || ![string isKindOfClass:[NSString class]]
            || [(NSString *)string isEqualToString:@""]);
}

+ (BOOL)isEmptyDictionary:(NSObject*)dict {
    return (!dict
            || ![dict isKindOfClass:[NSDictionary class]]
            || (((NSDictionary *)dict).count == 0));
}

+ (NSString *)stringOrEmpty:(NSString *)str {
    NSString *string = str ?: @"";
    return string;
}

- (BOOL)validateStringInputs:(NSMutableDictionary<NSString *, NSString *> *)inputs logs:(NSDictionary<NSString *, NSString *> *)logs {
    NSMutableDictionary *_inputs = [inputs mutableCopy];
    BOOL __block isValid = true;
    // Empty user Id is valid value.
    if (_inputs.allKeys.count > 0) {
        if ([_inputs.allKeys containsObject:OPTLYNotificationUserIdKey]) {
            if ([[_inputs objectForKey:OPTLYNotificationUserIdKey] isKindOfClass:[NSNull class]]) {
                isValid = false;
                if ([logs objectForKey:OPTLYNotificationUserIdKey]) {
                    [self.logger logMessage:[logs objectForKey:OPTLYNotificationUserIdKey] withLevel:OptimizelyLogLevelError];
                }
            }
            [_inputs removeObjectForKey:OPTLYNotificationUserIdKey];
        }
    }
    [_inputs enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop) {
        if ([value isKindOfClass:[NSNull class]] || [value isEqualToString:@""]) {
            if ([logs objectForKey:key]) {
                [self.logger logMessage:[logs objectForKey:key] withLevel:OptimizelyLogLevelError];
            }
            isValid = false;
        }
    }];
    return isValid;
}

- (id)ObjectOrNull:(id)object {
    return object ?: [NSNull null];
}
@end
