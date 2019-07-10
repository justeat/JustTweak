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

@class OPTLYExperiment;
@protocol OPTLYExperiment;
@protocol OPTLYRollout
@end

@interface OPTLYRollout : OPTLYJSONModel

/// an NSString to hold the rollout Id
@property (nonatomic, strong) NSString *rolloutId;
/// an NSArray to hold the experiments representing the different rules of the rollout
@property (nonatomic, strong) NSArray<OPTLYExperiment *><OPTLYExperiment> *experiments;

@end
