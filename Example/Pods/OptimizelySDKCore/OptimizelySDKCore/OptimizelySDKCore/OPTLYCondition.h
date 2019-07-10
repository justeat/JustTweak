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

#import <Foundation/Foundation.h>
#import "OPTLYProjectConfig.h"

@protocol OPTLYCondition

/**
 * Evaluate the condition against the user attributes.
 */
- (nullable NSNumber *)evaluateConditionsWithAttributes:(nullable NSDictionary<NSString *, id> *)attributes projectConfig:(nullable OPTLYProjectConfig *)config;

@end

@interface OPTLYCondition : NSObject

+ (nullable NSArray<OPTLYCondition *><OPTLYCondition> *)deserializeJSON:(nullable id)json
                                                                  error:(NSError *_Nullable __autoreleasing *_Nullable)error;
+ (nullable NSArray<OPTLYCondition *><OPTLYCondition> *)deserializeJSON:(nullable id)json;
+ (nullable NSArray<OPTLYCondition *><OPTLYCondition> *)deserializeAudienceConditionsJSONArray:(nullable NSArray *)jsonArray
                                                                                         error:(NSError *_Nullable __autoreleasing *_Nullable)error;
+ (nullable NSArray<OPTLYCondition *><OPTLYCondition> *)deserializeAudienceConditionsJSONArray:(nullable NSArray *)jsonArray;

@end

@interface OPTLYAndCondition : NSObject <OPTLYCondition>

@property (nonatomic, strong) NSArray<OPTLYCondition *><OPTLYCondition> *_Nullable subConditions;

@end

@interface OPTLYOrCondition : NSObject <OPTLYCondition>

@property (nonatomic, strong) NSArray<OPTLYCondition *><OPTLYCondition> *_Nullable subConditions;

@end

@interface OPTLYNotCondition : NSObject <OPTLYCondition>

@property (nonatomic, strong) NSObject<OPTLYCondition> *_Nullable subCondition;

@end
