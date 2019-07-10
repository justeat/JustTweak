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

#import <Foundation/Foundation.h>
#ifdef UNIVERSAL
#import "OPTLYJSONModelLib.h"
#else
#import <OptimizelySDKCore/OPTLYJSONModelLib.h>
#endif

extern NSString * const FeatureVariableTypeBoolean;
extern NSString * const FeatureVariableTypeString;
extern NSString * const FeatureVariableTypeInteger;
extern NSString * const FeatureVariableTypeDouble;

@protocol OPTLYFeatureVariable
@end

@interface OPTLYFeatureVariable : OPTLYJSONModel

/// an NSString to hold the feature variable's ID
@property (nonatomic, strong) NSString *variableId;
/// an NSString to hold the feature variable's key
@property (nonatomic, strong) NSString *key;
/// an NSString to hold the feature variable's primitive type. Will be one of 4 possible values: a.	boolean b.	string c.	integer d.	double
@property (nonatomic, strong) NSString *type;
/// an NSString to hold the feature variable's default value in string representation.
@property (nonatomic, strong) NSString *defaultValue;

@end
