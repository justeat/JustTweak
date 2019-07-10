/****************************************************************************
 * Copyright 2017-2018, Optimizely, Inc. and contributors                   *
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

@class OPTLYExperiment, OPTLYVariation, OPTLYFeatureFlag, OPTLYFeatureDecision;

@interface OPTLYDecisionService : OPTLYJSONModel

/**
 * Initializer for the Decision Service.
 *
 * @param config The project configuration.
 * @param bucketer The bucketer.
 * @return An instance of the decision service.
 */
- (nullable instancetype)initWithProjectConfig:(nonnull OPTLYProjectConfig *)config
                                      bucketer:(nonnull id<OPTLYBucketer>)bucketer;

/**
 * Gets a variation based on the following rules (evaluated in sequential order):
 *
 * 1. Experiments not running will return a nil variation.
 * 2. If the user is whitelisted for a particular variation, 
 *    then that variation will be returned.
 * 3. If a valid variation for a given experiments is found in the user
 *    profile service, then that variation will be returned.
 * 4. If the user falls through #1-3, than the user will be bucketed
 *    if the user fulfills these criteria:
 *      a. Does the user pass audience targeting?
 *      b. Is the experiment that the user bucketed into NOT mutually excluded?
 *      c. Does traffic allocation exclude the user?
 *
 * @param userId The ID of the user.
 * @param experiment The experiment in which to bucket the user.
 * @return The variation assigned to the specified user ID for an experiment.
 */
- (nullable OPTLYVariation *)getVariation:(nonnull NSString *)userId
                               experiment:(nonnull OPTLYExperiment *)experiment
                               attributes:(nullable NSDictionary<NSString *, id> *)attributes;

/**
 * Get a variation the user is bucketed into for the given FeatureFlag
 * @param featureFlag The feature flag the user wants to access.
 * @param userId The ID of the user.
 * @param attributes User attributes
 * @return The variation assigned to the specified user ID for a feature flag.
 */
- (nullable OPTLYFeatureDecision *)getVariationForFeature:(nonnull OPTLYFeatureFlag *)featureFlag
                                             userId:(nonnull NSString *)userId
                                         attributes:(nullable NSDictionary<NSString *, id> *)attributes;

@end
