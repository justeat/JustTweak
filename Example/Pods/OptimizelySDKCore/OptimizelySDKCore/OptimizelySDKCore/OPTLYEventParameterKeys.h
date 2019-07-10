/****************************************************************************
 * Copyright 2016-2019, Optimizely, Inc. and contributors                   *
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

NS_ASSUME_NONNULL_BEGIN

// --- Base Parameters ----
extern NSString * const OPTLYEventParameterKeysAccountId;
extern NSString * const OPTLYEventParameterKeysProjectId;
extern NSString * const OPTLYEventParameterKeysEnrichDecisions;
extern NSString * const OPTLYEventParameterKeysVisitors;
extern NSString * const OPTLYEventParameterKeysAnonymizeIP;
extern NSString * const OPTLYEventParameterKeysClientEngine;
extern NSString * const OPTLYEventParameterKeysClientVersion;
extern NSString * const OPTLYEventParameterKeysRevision;

// --- Visitor Parameters ----
extern NSString * const OPTLYEventParameterKeysSnapshots;
extern NSString * const OPTLYEventParameterKeysVisitorId;
extern NSString * const OPTLYEventParameterKeysAttributes;

// --- Snapshot Parameters ----
extern NSString * const OPTLYEventParameterKeysDecisions;
extern NSString * const OPTLYEventParameterKeysEvents;

// --- Attribute Parameters ----
extern NSString * const OPTLYEventParameterKeysFeaturesType;
extern NSString * const OPTLYEventParameterKeysFeaturesValue;
extern NSString * const OPTLYEventParameterKeysFeaturesId;
extern NSString * const OPTLYEventParameterKeysFeaturesKey;
extern NSString * const OPTLYEventParameterKeysFeaturesShouldIndex;
extern NSString * const OPTLYEventParameterKeysFeaturesName;

// --- Decision Parameters ----
extern NSString * const OPTLYEventParameterKeysDecisionCampaignId;
extern NSString * const OPTLYEventParameterKeysDecisionExperimentId;
extern NSString * const OPTLYEventParameterKeysDecisionVariationId;

// --- Common Event Parameters ----
extern NSString * const OPTLYEventParameterKeysTimestamp;
extern NSString * const OPTLYEventParameterKeysUUID;
extern NSString * const OPTLYEventParameterKeysEntityId;
extern NSString * const OPTLYEventParameterKeysKey;

// --- Impression Event Parameters ----

// --- Conversion Event Parameters ----
extern NSString * const OPTLYEventParameterKeysTags;
extern NS_ASSUME_NONNULL_END

@interface OPTLYEventParameterKeys : NSObject

@end
