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

#ifdef UNIVERSAL
    #import "OPTLYJSONModelLib.h"
#else
    #import <OptimizelySDKCore/OPTLYJSONModelLib.h>
#endif
#import "OPTLYCondition.h"

// Switchcase implementation for strings
#define CASE(str)                       if ([__s__ isEqualToString:(str)])
#define SWITCH(s)                       for (NSString *__s__ = (s); ; )
#define DEFAULT

@protocol OPTLYBaseCondition
@end

@interface OPTLYBaseCondition : OPTLYJSONModel <OPTLYCondition>

/// Condition name
@property (nonatomic, strong, nonnull) NSString *name;
/// Condition type
@property (nonatomic, strong, nullable) NSString<OPTLYOptional> *type;
/// Condition value
@property (nonatomic, strong, nullable) NSObject<OPTLYOptional> *value;
/// Condition match type
@property (nonatomic, strong, nullable) NSString<OPTLYOptional> *match;

/// Returns string representation
- (nonnull NSString *)toString;

+(BOOL)isBaseConditionJSON:(nonnull NSData *)jsonData;

@end
