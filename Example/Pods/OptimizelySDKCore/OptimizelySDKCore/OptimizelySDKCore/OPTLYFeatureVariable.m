/****************************************************************************
 * Copyright 2017, Optimizely, Inc. and contributors                        *
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

#import "OPTLYFeatureVariable.h"
#import "OPTLYDatafileKeys.h"

NSString * const FeatureVariableTypeBoolean = @"boolean";
NSString * const FeatureVariableTypeString  = @"string";
NSString * const FeatureVariableTypeInteger = @"integer";
NSString * const FeatureVariableTypeDouble  = @"double";

@implementation OPTLYFeatureVariable

+ (OPTLYJSONKeyMapper*)keyMapper
{
    return [[OPTLYJSONKeyMapper alloc] initWithDictionary:@{ OPTLYDatafileKeysFeatureVariableId             : @"variableId",
                                                             OPTLYDatafileKeysFeatureVariableKey            : @"key",
                                                             OPTLYDatafileKeysFeatureVariableType           : @"type",
                                                             OPTLYDatafileKeysFeatureVariableDefaultValue   : @"defaultValue"
                                                             }];
}

@end
