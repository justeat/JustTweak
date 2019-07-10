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

#import "OPTLYCondition.h"
#import "OPTLYDatafileKeys.h"
#import "OPTLYBaseCondition.h"
#import "OPTLYAudienceBaseCondition.h"
#import "OPTLYErrorHandlerMessages.h"

@implementation OPTLYCondition

+ (nullable NSArray<OPTLYCondition *><OPTLYCondition> *)deserializeJSON:(nullable id)json {
    return [OPTLYCondition deserializeJSON:json error:nil];
}

+ (nullable NSArray<OPTLYCondition *><OPTLYCondition> *)deserializeAudienceConditionsJSONArray:(nullable NSArray *)jsonArray {
    return [OPTLYCondition deserializeAudienceConditionsJSONArray:jsonArray error:nil];
}

// example jsonArray:
//  [“and", [“or", [“or", {"name": "sample_attribute_key", "type": "custom_attribute", "value": “a”}], [“or", {"name": "sample_attribute_key", "type": "custom_attribute", "value": "b"}], [“or", {"name": "sample_attribute_key", "type": "custom_attribute", "value": "c"}]
+ (nullable NSArray<OPTLYCondition *><OPTLYCondition> *)deserializeJSON:(nullable id)json
                                                                  error:(NSError *_Nullable __autoreleasing *_Nullable)error {
    
    NSMutableArray *mutableJsonArray = [NSMutableArray new];
    
    // need to check if the jsonArray is actually an array, otherwise, something is wrong with the audience condition
    if (![json isKindOfClass:[NSArray class]]) {
        if ([OPTLYBaseCondition isBaseConditionJSON:((NSData *)json)]) {
            mutableJsonArray = [[NSMutableArray alloc] initWithArray:@[OPTLYDatafileKeysOrCondition,json]];
        }
        else {
            NSError *err = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                               code:OPTLYErrorTypesDatafileInvalid
                                           userInfo:@{NSLocalizedDescriptionKey : OPTLYErrorHandlerMessagesProjectConfigInvalidAudienceCondition}];
            if (error && err) {
                *error = err;
            }
            return nil;
        }
    }
    else {
        mutableJsonArray = [(NSArray *)json mutableCopy];
    }
    
    if (mutableJsonArray.count < 2) {
        // Should return 'OR' operator in case there is none
        [mutableJsonArray insertObject:OPTLYDatafileKeysOrCondition atIndex:0];
    }
    
    NSMutableArray<OPTLYCondition> *conditions = (NSMutableArray<OPTLYCondition> *)[[NSMutableArray alloc] initWithCapacity:(mutableJsonArray.count - 1)];
    for (int i = 1; i < mutableJsonArray.count; i++) {
        if ([OPTLYBaseCondition isBaseConditionJSON: mutableJsonArray[i]]) {
            // generate base condition
            NSDictionary *info = mutableJsonArray[i];
            NSError *err = nil;
            OPTLYBaseCondition *condition = [[OPTLYBaseCondition alloc] initWithDictionary:info
                                                                                     error:&err];
            
            if (error && err) {
                *error = err;
            }
            else {
                if (condition != nil) {
                    [conditions addObject:condition];
                }
            }
            continue;
        }
        
        // further condition arrays to deserialize
        NSError *err = nil;
        NSArray *deserializedJsonObject = [OPTLYCondition deserializeJSON:mutableJsonArray[i] error:&err];
        if (err) {
            *error = err;
            return nil;
        }
        if (deserializedJsonObject != nil) {
            [conditions addObjectsFromArray:deserializedJsonObject];
        }
    }
    
    // return an (And/Or/Not) Condition handling the base conditions
    NSObject<OPTLYCondition> *condition = [OPTLYCondition createConditionInstanceOfClass:mutableJsonArray[0]
                                                                          withConditions:conditions];
    return (NSArray<OPTLYCondition *><OPTLYCondition> *)@[condition];
}

// example jsonArray:
//  "[\"and\", [\"or\", \"3468206642\", \"3988293898\"], [\"or\", \"3988293899\", \"3468206646\", \"3468206647\", \"3468206644\", \"3468206643\"]]"
+ (nullable NSArray<OPTLYCondition *><OPTLYCondition> *)deserializeAudienceConditionsJSONArray:(nullable NSArray *)jsonArray
                                                                                         error:(NSError *_Nullable __autoreleasing *_Nullable)error {

    NSMutableArray *mutableJsonArray = [NSMutableArray new];
    // need to check if the jsonArray is actually an array, otherwise, something is wrong with the audience condition
    if (![jsonArray isKindOfClass:[NSArray class]]) {
        NSError *err = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                           code:OPTLYErrorTypesDatafileInvalid
                                       userInfo:@{NSLocalizedDescriptionKey : OPTLYErrorHandlerMessagesProjectConfigInvalidAudienceCondition}];
        if (error && err) {
            *error = err;
        }
        return nil;
    }
    if ([jsonArray count] == 0) {
        return (NSArray<OPTLYCondition> *)@[];
    }
    
    mutableJsonArray = [jsonArray mutableCopy];
    // Should return 'OR' operator in case there is none
    if (![mutableJsonArray[0] isEqualToString:OPTLYDatafileKeysAndCondition] && ![mutableJsonArray[0] isEqualToString:OPTLYDatafileKeysOrCondition] && ![mutableJsonArray[0] isEqualToString:OPTLYDatafileKeysNotCondition]) {
        [mutableJsonArray insertObject:OPTLYDatafileKeysOrCondition atIndex:0];
    }
    
    NSMutableArray<OPTLYCondition> *conditions = (NSMutableArray<OPTLYCondition> *)[[NSMutableArray alloc] initWithCapacity:(mutableJsonArray.count - 1)];
    for (int i = 1; i < mutableJsonArray.count; i++) {
        if ([OPTLYAudienceBaseCondition isBaseConditionJSON: mutableJsonArray[i]]) {
            // generate base condition
            NSString *audienceId = mutableJsonArray[i];
            OPTLYAudienceBaseCondition *condition = [OPTLYAudienceBaseCondition new];
            condition.audienceId = audienceId;
            [conditions addObject:condition];
            continue;
        }
        
        // further condition arrays to deserialize
        if ([mutableJsonArray[i] isKindOfClass:[NSArray class]]) {
            NSError *err = nil;
            NSArray *_tmpConditions = [OPTLYCondition deserializeAudienceConditionsJSONArray:(NSArray *)mutableJsonArray[i] error:&err];
            [conditions addObject:[_tmpConditions firstObject]];
            if (err) {
                *error = err;
                return nil;
            }
        }
    }
    // return an (And/Or/Not) Condition handling the base conditions
    NSObject<OPTLYCondition> *condition = [OPTLYCondition createConditionInstanceOfClass:mutableJsonArray[0]
                                                                          withConditions:conditions];
    return (NSArray<OPTLYCondition> *)@[condition];
}

+ (NSObject<OPTLYCondition> *)createConditionInstanceOfClass:(nonnull NSString *)conditionClass withConditions:(nonnull NSArray<OPTLYCondition> *)conditions {
    if ([conditionClass isEqualToString:OPTLYDatafileKeysAndCondition]) {
        OPTLYAndCondition *andCondition = [[OPTLYAndCondition alloc] init];
        andCondition.subConditions = conditions;
        return andCondition;
    }
    else if ([conditionClass isEqualToString:OPTLYDatafileKeysOrCondition]) {
        OPTLYOrCondition *orCondition = [[OPTLYOrCondition alloc] init];
        orCondition.subConditions = conditions;
        return orCondition;
    }
    else if ([conditionClass isEqualToString:OPTLYDatafileKeysNotCondition]) {
        OPTLYNotCondition *notCondition = [[OPTLYNotCondition alloc] init];
        notCondition.subCondition = conditions[0];
        return notCondition;
    }
    else {
        NSString *exceptionDescription = [NSString stringWithFormat:@"Condition Class `%@` is not a recognized Optimizely Condition Class", conditionClass];
        NSException *exception = [[NSException alloc] initWithName:@"Condition Class Exception"
                                                            reason:@"Unrecognized Condition Class"
                                                          userInfo:@{OPTLYErrorHandlerMessagesDataFileInvalid : exceptionDescription}];
        @throw exception;
    }
    return nil;
}

@end

@implementation OPTLYAndCondition

- (nullable NSNumber *)evaluateConditionsWithAttributes:(nullable NSDictionary<NSString *, id> *)attributes projectConfig:(nullable OPTLYProjectConfig *)config {
    // According to the matrix:
    // false and true is false
    // false and null is false
    // true and null is null.
    // true and false is false
    // true and true is true
    // null and null is null
    BOOL foundNull = false;
    for (NSObject<OPTLYCondition> *condition in self.subConditions) {
        // if any of our sub conditions are false or null
        NSNumber * result = [NSNumber new];
        result = [condition evaluateConditionsWithAttributes:attributes projectConfig:config];
        
        if (result == NULL) {
            foundNull = true;
        }
        else if ([result boolValue] == false) {
            // short circuit and return false
            return [NSNumber numberWithBool:false];
        }
    }
    //if found null condition, return null
    if (foundNull) {
        return NULL;
    }
    
    // if all sub conditions are true, return true.
    return [NSNumber numberWithBool:true];
}

@end

@implementation OPTLYOrCondition

- (nullable NSNumber *)evaluateConditionsWithAttributes:(nullable NSDictionary<NSString *, id> *)attributes projectConfig:(nullable OPTLYProjectConfig *)config {
    // According to the matrix:
    // true returns true
    // false or null is null
    // false or false is false
    // null or null is null
    BOOL foundNull = false;
    for (NSObject<OPTLYCondition> *condition in self.subConditions) {
        NSNumber * result = [NSNumber new];
        result = [condition evaluateConditionsWithAttributes:attributes projectConfig:config];
        if (result == NULL) {
            foundNull = true;
        }
        else if ([result boolValue] == true) {
            // if any of our sub conditions are true
            // short circuit and return true
            return [NSNumber numberWithBool:true];
        }
    }
    //if found null condition, return null
    if (foundNull) {
        return NULL;
    }
    
    // if all of the sub conditions are false, return false
    return [NSNumber numberWithBool:false];
}

@end

@implementation OPTLYNotCondition

- (nullable NSNumber *)evaluateConditionsWithAttributes:(nullable NSDictionary<NSString *, id> *)attributes projectConfig:(nullable OPTLYProjectConfig *)config {
    // return the negative of the subcondition
    NSNumber * result = [NSNumber new];
    result = [self.subCondition evaluateConditionsWithAttributes:attributes projectConfig:config];
    if (result == NULL) {
        return NULL;
    }
    return [NSNumber numberWithBool:![result boolValue]];
}

@end
