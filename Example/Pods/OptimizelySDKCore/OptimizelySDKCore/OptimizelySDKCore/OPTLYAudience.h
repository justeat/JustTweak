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
#ifdef UNIVERSAL
    #import "OPTLYJSONModelLib.h"
#else
    #import <OptimizelySDKCore/OPTLYJSONModelLib.h>
#endif
#import "OPTLYCondition.h"

@protocol OPTLYAudience
@end

@interface OPTLYAudience : OPTLYJSONModel <OPTLYCondition>

/// The audience id
@property (nonatomic, strong) NSString *audienceId;
/// The audience name
@property (nonatomic, strong) NSString *audienceName;
/// Audience evaluator conditionals
@property (nonatomic, strong) NSArray<OPTLYCondition *><OPTLYCondition> *conditions;

/// Override OPTLYJSONModel set conditions
- (void)setConditionsWithNSString:(NSString *)string;
- (void)setConditionsWithNSArray:(NSArray *)array;
- (void)setConditionsWithNSDictionary:(NSDictionary *)dictionary;

/// Returns conditions string
- (NSString *)getConditionsString;

@end
