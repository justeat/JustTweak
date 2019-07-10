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


#import "OPTLYAudience.h"
#import "OPTLYDatafileKeys.h"
#import "OPTLYNSObject+Validation.h"
#import "OPTLYLoggerMessages.h"
#import "OPTLYLogger.h"

@interface OPTLYAudience()
/// String representation of the conditions
@property (nonatomic, strong) NSString<Ignore> *conditionsString;
@end

@implementation OPTLYAudience

+ (OPTLYJSONKeyMapper*)keyMapper
{
    return [[OPTLYJSONKeyMapper alloc] initWithDictionary:@{ OPTLYDatafileKeysAudienceId   : @"audienceId",
                                                             OPTLYDatafileKeysAudienceName : @"audienceName"
                                                        }];
}

- (NSString *)getConditionsString {
    return _conditionsString ?: @"";
}

- (void)setConditionsWithNSString:(NSString *)string {
    NSArray *array = [string getValidConditionsArray];
    [self setConditionsWithNSArray:array];
}

- (void)setConditionsWithNSArray:(NSArray *)array {
    //Retrieving Jsonstring from array
    _conditionsString = [array getJSONArrayStringOrEmpty];
    NSError *err = nil;
    self.conditions = [OPTLYCondition deserializeJSON:array error:nil];
    if (err != nil) {
        NSException *exception = [[NSException alloc] initWithName:err.domain reason:err.localizedFailureReason userInfo:@{@"Error" : err}];
        @throw exception;
    }
}

- (void)setConditionsWithNSDictionary:(NSDictionary *)dictionary {
    NSError *err = nil;
    self.conditions = [OPTLYCondition deserializeJSON:dictionary error:nil];
    if (err != nil) {
        NSException *exception = [[NSException alloc] initWithName:err.domain reason:err.localizedFailureReason userInfo:@{@"Error" : err}];
        @throw exception;
    }
}

- (nullable NSNumber *)evaluateConditionsWithAttributes:(nullable NSDictionary<NSString *, id> *)attributes projectConfig:(nullable OPTLYProjectConfig *)config {
    NSObject<OPTLYCondition> *condition = (NSObject<OPTLYCondition> *)[self.conditions firstObject];
    if (condition) {
        // Log Audience Evaluation Started
        NSString *conditionString = [self getConditionsString];
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorEvaluationStartedWithConditions, self.audienceName, conditionString];
        [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
        
        NSNumber *result = [condition evaluateConditionsWithAttributes:attributes projectConfig:config];
        if (result == NULL) {
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorEvaluationCompletedWithResult, self.audienceName, @"UNKNOWN"];
            [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
        }
        else {
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorEvaluationCompletedWithResult, self.audienceName, [result boolValue] ? @"TRUE" : @"FALSE"];
            [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
        }
        return result;
    }
    return nil;
}

@end
