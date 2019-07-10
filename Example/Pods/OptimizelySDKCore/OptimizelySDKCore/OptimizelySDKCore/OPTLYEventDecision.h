/****************************************************************************
 * Copyright 2016, Optimizely, Inc. and contributors                        *
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

// Output of the Client Decision Engine

#import <Foundation/Foundation.h>
#ifdef UNIVERSAL
    #import "OPTLYJSONModelLib.h"
#else
    #import <OptimizelySDKCore/OPTLYJSONModelLib.h>
#endif

@protocol OPTLYEventDecision
@end

@interface OPTLYEventDecision : OPTLYJSONModel

// ID of chosen experiment, null if visitor is not targeted for any experiments
@property (nonatomic, strong, nullable) NSString<OPTLYOptional> *experimentId;
// ID of chosen variation, null if if visitor is not targeted for any experiments
@property (nonatomic, strong, nullable) NSString<OPTLYOptional> *variationId;
// If true, the chosen experience was held back at the layer level
// TODO - Remove later when this ticket is completed: https://optimizely.atlassian.net/browse/NB-1493
@property (nonatomic, assign) BOOL isLayerHoldback;

@end
