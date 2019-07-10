/****************************************************************************
 * Copyright 2016,2018-2019, Optimizely, Inc. and contributors              *
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

#import "OPTLYBaseCondition.h"
#import "OPTLYDatafileKeys.h"
#import "OPTLYNSObject+Validation.h"
#import "OPTLYLoggerMessages.h"
#import "OPTLYLogger.h"

@interface OPTLYBaseCondition()
/// String representation of self
@property (nonatomic, strong) NSString<Ignore> *stringRepresentation;
@end

@implementation OPTLYBaseCondition

- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err {
    self.stringRepresentation = [NSString stringWithFormat:@"%@", dict];;
    return [super initWithDictionary:dict error:err];
}

- (nonnull NSString *)toString {
    return _stringRepresentation ?: @"";
}

/**
 * Given a json, this mapper finds JSON keys for each key in the provided dictionary and maps the json value to the class property with name corresponding to the dictionary value
 */
+ (OPTLYJSONKeyMapper*)keyMapper
{
    return [[OPTLYJSONKeyMapper alloc] initWithDictionary:@{ OPTLYDatafileKeysConditionName   : @"name",
                                                             OPTLYDatafileKeysConditionType  : @"type",
                                                             OPTLYDatafileKeysConditionValue  : @"value",
                                                             OPTLYDatafileKeysConditionMatch : @"match"
                                                             }];
}

+ (BOOL)isBaseConditionJSON:(nonnull NSData *)jsonData {
    return [jsonData isKindOfClass:[NSDictionary class]];
}

- (nullable NSNumber *)evaluateMatchTypeExact:(NSDictionary<NSString *, id> *)attributes projectConfig:(nullable OPTLYProjectConfig *)config {
    // check if user attributes contain a value that is of similar class type to our value and also equals to our value, else return Null
    
    // check if condition value is invalid
    if (![self.value isValidExactMatchTypeValue]) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorUnsupportedValueType, self.stringRepresentation];
        [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelWarning];
        return NULL;
    }
    // check if attributes exists
    if (![attributes.allKeys containsObject:self.name]) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorConditionEvaluatedAsUnknownForMissingAttribute, self.stringRepresentation, self.name];
        [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
        return NULL;
    }
    
    NSObject *userAttribute = [attributes objectForKey:self.name];
    if ([self.value isValidStringType] && [userAttribute isValidStringType]) {
        return [NSNumber numberWithBool:[self.value isEqual:userAttribute]];
    }
    else if ([self.value isNumericAttributeValue] && [userAttribute isNumericAttributeValue]) {
        if ([userAttribute isFiniteNumber]) {
            return [NSNumber numberWithBool:[self.value isEqual:userAttribute]];
        }
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorConditionEvaluatedAsUnknownForUnexpectedTypeNanInfinity, self.stringRepresentation, self.name];
        [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
        return NULL;
    }
    else if ([self.value isKindOfClass:[NSNull class]] && [userAttribute isKindOfClass:[NSNull class]]) {
        return [NSNumber numberWithBool:[self.value isEqual:userAttribute]];
    }
    else if ([self.value isValidBooleanAttributeValue] && [userAttribute isValidBooleanAttributeValue]) {
        return [NSNumber numberWithBool:[self.value isEqual:userAttribute]];
    }
    
    // Log Invalid Attribute Value Type
    if ([userAttribute class] != nil) {
        NSString *userAttributeClassName = NSStringFromClass([userAttribute class]);
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorConditionEvaluatedAsUnknownForUnexpectedType, self.stringRepresentation, userAttributeClassName, self.name];
        [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelWarning];
    }
    else {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorConditionEvaluatedAsUnknownForUnexpectedTypeNull, self.stringRepresentation, self.name];
        [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    }
    return NULL;
}

- (nullable NSNumber *)evaluateMatchTypeExist:(NSDictionary<NSString *, id> *)attributes projectConfig:(nullable OPTLYProjectConfig *)config {
    // check if user attributes contain our name as a key to a Non nullable object
    return [NSNumber numberWithBool:([attributes objectForKey:self.name] && ![attributes[self.name] isKindOfClass:[NSNull class]])];
}

- (nullable NSNumber *)evaluateMatchTypeSubstring:(NSDictionary<NSString *, id> *)attributes projectConfig:(nullable OPTLYProjectConfig *)config {
    // check if user attributes contain our value as substring
    
    // check if condition value is invalid
    if (![self.value isValidStringType]) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorUnsupportedValueType, self.stringRepresentation];
        [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelWarning];
        return NULL;
    }
    // check if attributes exists
    if (![attributes.allKeys containsObject:self.name]) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorConditionEvaluatedAsUnknownForMissingAttribute, self.stringRepresentation, self.name];
        [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
        return NULL;
    }
    // check if user attributes are invalid
    NSObject *userAttribute = [attributes objectForKey:self.name];
    if (![userAttribute isKindOfClass: [NSString class]]) {
        // Log Invalid Attribute Value Type
        if (!userAttribute || [userAttribute isKindOfClass:[NSNull class]]) {
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorConditionEvaluatedAsUnknownForUnexpectedTypeNull, self.stringRepresentation, self.name];
            [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
        }
        else {
            NSString *userAttributeClassName = NSStringFromClass([userAttribute class]);
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorConditionEvaluatedAsUnknownForUnexpectedType, self.stringRepresentation, userAttributeClassName, self.name];
            [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelWarning];
        }
        return NULL;
    }
    
    BOOL containsSubstring = [((NSString *)userAttribute) containsString: (NSString *)self.value];
    return [NSNumber numberWithBool:containsSubstring];
}

- (nullable NSNumber *)evaluateMatchTypeGreaterThan:(NSDictionary<NSString *, id> *)attributes projectConfig:(nullable OPTLYProjectConfig *)config {
    // check if user attributes contain a value greater than our value
    
    // check if condition value is invalid
    if (![self.value isValidGTLTMatchTypeValue]) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorUnsupportedValueType, self.stringRepresentation];
        [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelWarning];
        return NULL;
    }
    // check if attributes exists
    if (![attributes.allKeys containsObject:self.name]) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorConditionEvaluatedAsUnknownForMissingAttribute, self.stringRepresentation, self.name];
        [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
        return NULL;
    }
    // check if user attributes are invalid
    NSObject *userAttribute = [attributes objectForKey:self.name];
    if (![userAttribute isNumericAttributeValue]) {
        // Log Invalid Attribute Value Type
        if (!userAttribute || [userAttribute isKindOfClass:[NSNull class]]) {
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorConditionEvaluatedAsUnknownForUnexpectedTypeNull, self.stringRepresentation, self.name];
            [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
        }
        else {
            NSString *userAttributeClassName = NSStringFromClass([userAttribute class]);
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorConditionEvaluatedAsUnknownForUnexpectedType, self.stringRepresentation, userAttributeClassName, self.name];
            [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelWarning];
        }
        return NULL;
    }
    if (![userAttribute isFiniteNumber]) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorConditionEvaluatedAsUnknownForUnexpectedTypeNanInfinity, self.stringRepresentation, self.name];
        [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
        return NULL;
    }
    
    NSNumber *ourValue = (NSNumber *)self.value;
    NSNumber *userValue = (NSNumber *)userAttribute;
    return [NSNumber numberWithBool: ([userValue doubleValue] > [ourValue doubleValue])];
}

- (nullable NSNumber *)evaluateMatchTypeLessThan:(NSDictionary<NSString *, id> *)attributes projectConfig:(nullable OPTLYProjectConfig *)config {
    // check if user attributes contain a value lesser than our value
    
    // check if condition value is invalid
    if (![self.value isValidGTLTMatchTypeValue]) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorUnsupportedValueType, self.stringRepresentation];
        [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelWarning];
        return NULL;
    }
    // check if attributes exists
    if (![attributes.allKeys containsObject:self.name]) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorConditionEvaluatedAsUnknownForMissingAttribute, self.stringRepresentation, self.name];
        [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
        return NULL;
    }
    // check if user attributes are invalid
    NSObject *userAttribute = [attributes objectForKey:self.name];
    if (![userAttribute isNumericAttributeValue]) {
        // Log Invalid Attribute Value Type
        if (!userAttribute || [userAttribute isKindOfClass:[NSNull class]]) {
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorConditionEvaluatedAsUnknownForUnexpectedTypeNull, self.stringRepresentation, self.name];
            [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
        }
        else {
            NSString *userAttributeClassName = NSStringFromClass([userAttribute class]);
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorConditionEvaluatedAsUnknownForUnexpectedType, self.stringRepresentation, userAttributeClassName, self.name];
            [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelWarning];
        }
        return NULL;
    }
    if (![userAttribute isFiniteNumber]) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorConditionEvaluatedAsUnknownForUnexpectedTypeNanInfinity, self.stringRepresentation, self.name];
        [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
        return NULL;
    }
    
    NSNumber *ourValue = (NSNumber *)self.value;
    NSNumber *userValue = (NSNumber *)userAttribute;
    return [NSNumber numberWithBool: ([userValue doubleValue] < [ourValue doubleValue])];
}

- (nullable NSNumber *)evaluateCustomMatchType:(NSDictionary<NSString *, id> *)attributes projectConfig:(nullable OPTLYProjectConfig *)config {
    
    if (![self.type isEqual:OPTLYDatafileKeysCustomAttributeConditionType]){
        //Check if given type is the required type
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorUnknownConditionType, self.stringRepresentation];
        [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelWarning];
        return NULL;
    }
    else if (self.value == NULL && ![self.match isEqualToString:OPTLYDatafileKeysMatchTypeExists]){
        //Check if given value is null, which is only acceptable if match type is Exists
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorUnsupportedValueType, self.stringRepresentation];
        [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelWarning];
        return NULL;
    }
    if (!self.match || [self.match isEqualToString:@""]){
        //Check if given match is empty, if so, opt for legacy Exact Matching
        self.match = OPTLYDatafileKeysMatchTypeExact;
    }

    SWITCH(self.match){
        CASE(OPTLYDatafileKeysMatchTypeExact) {
            return [self evaluateMatchTypeExact: attributes projectConfig:config];
        }
        CASE(OPTLYDatafileKeysMatchTypeExists) {
            return [self evaluateMatchTypeExist: attributes projectConfig:config];
        }
        CASE(OPTLYDatafileKeysMatchTypeSubstring) {
            return [self evaluateMatchTypeSubstring: attributes projectConfig:config];
        }
        CASE(OPTLYDatafileKeysMatchTypeGreaterThan) {
            return [self evaluateMatchTypeGreaterThan: attributes projectConfig:config];
        }
        CASE(OPTLYDatafileKeysMatchTypeLessThan) {
            return [self evaluateMatchTypeLessThan: attributes projectConfig:config];
        }
        DEFAULT {
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorUnknownMatchType, self.stringRepresentation];
            [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelWarning];
            return NULL;
        }
    }
}

/**
 * Evaluates the condition against the user attributes, returns NULL if invalid.
 */
- (nullable NSNumber *)evaluateConditionsWithAttributes:(nullable NSDictionary<NSString *, id> *)attributes projectConfig:(nullable OPTLYProjectConfig *)config {
    // check user attribute value for the condition and match type against our condition value
    return [self evaluateCustomMatchType: attributes projectConfig:config];
}

@end

