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

#import <Foundation/Foundation.h>

@class OPTLYExperiment, OPTLYVariation;

struct DecisionSourceStruct {
    NSString * _Nonnull const FeatureTest;
    NSString * _Nonnull const Rollout;
};
extern const struct DecisionSourceStruct DecisionSource;

/**
 * This class determines how the Optimizely SDK will handle exceptions and errors.
 */
@interface OPTLYFeatureDecision : NSObject

/// an OPTLYExperiment associated with the decision.
@property (nonatomic, strong) OPTLYExperiment * _Nullable experiment;
/// an OPTLYVariation associated with the decision.
@property (nonatomic, strong) OPTLYVariation * _Nullable variation;
/// an NSString to hold the source of the decision. Either experiment or rollout
@property (nonatomic, strong) NSString * _Nonnull source;

/*
 * Initializes the FeatureDecision with an experiment id, variation id & source.
 *
 * @param experimentId The id of experiment.
 * @param variationId The id of variation.
 * @param source The source for which the decision made.
 * @return An instance of the FeatureDecision.
 */
- (nonnull instancetype)initWithExperiment:(OPTLYExperiment * _Nullable)experiment variation:(OPTLYVariation * _Nullable)variation source:(NSString * _Nonnull)source;

@end
