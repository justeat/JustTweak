/****************************************************************************
 * Copyright 2017-2018, Optimizely, Inc. and contributors                        *
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

@class OPTLYProjectConfig, OPTLYFeatureVariable;
@protocol OPTLYFeatureVariable;
@protocol OPTLYFeatureFlag
@end

@interface OPTLYFeatureFlag : OPTLYJSONModel

/// an NSString to hold feature flag ID
@property (nonatomic, strong, nonnull) NSString *flagId;
/// an NSString to hold feature flag Key
@property (nonatomic, strong, nonnull) NSString *key;
/// an NSString to hold the ID of the rollout that is attached to this feature flag
@property (nonatomic, strong, nonnull) NSString *rolloutId;
/// an NSArray of the IDs of the experiments the feature flag is attached to.
@property (nonatomic, strong, nonnull) NSArray<NSString *> *experimentIds;
/// an NSArray of the feature variables that are part of this feature
@property (nonatomic, strong, nonnull) NSArray<OPTLYFeatureVariable *><OPTLYFeatureVariable> *variables;
/// an NSString to hold the group Id the feature belongs to.
@property (nonatomic, strong, nullable) NSString<OPTLYOptional> *groupId;

/**
 * Determines whether all the experiments in the feature flag belongs to the same mutex group
 * @param config The project config object.
 * @return YES if feature belongs to the same mutex group.
 */
- (BOOL)isValid:(nonnull OPTLYProjectConfig *)config;

/**
 * Get Feature Variable object for a key.
 */
- (nullable OPTLYFeatureVariable *)getFeatureVariableForKey:(nonnull NSString *)variableKey;

@end
