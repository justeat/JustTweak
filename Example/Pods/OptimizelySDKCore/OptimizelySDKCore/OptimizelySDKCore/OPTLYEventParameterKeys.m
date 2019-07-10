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

#import "OPTLYEventParameterKeys.h"

// --- Base Parameters ----
NSString * const OPTLYEventParameterKeysAccountId                       = @"account_id";        // nonnull
NSString * const OPTLYEventParameterKeysProjectId                       = @"project_id";
NSString * const OPTLYEventParameterKeysEnrichDecisions                 = @"enrich_decisions";
NSString * const OPTLYEventParameterKeysVisitors                        = @"visitors";          // nonnull
NSString * const OPTLYEventParameterKeysAnonymizeIP                     = @"anonymize_ip";
NSString * const OPTLYEventParameterKeysClientEngine                    = @"client_name";
NSString * const OPTLYEventParameterKeysClientVersion                   = @"client_version";
NSString * const OPTLYEventParameterKeysRevision                        = @"revision";

// --- Visitor Parameters ----
NSString * const OPTLYEventParameterKeysSnapshots                       = @"snapshots";         // nonnull
NSString * const OPTLYEventParameterKeysVisitorId                       = @"visitor_id";        // nonnull
NSString * const OPTLYEventParameterKeysAttributes                      = @"attributes";

// --- Snapshot Parameters ----
NSString * const OPTLYEventParameterKeysDecisions                       = @"decisions";         // nonnull
NSString * const OPTLYEventParameterKeysEvents                          = @"events";            // nonnull

// --- Attribute Parameters ----
NSString * const OPTLYEventParameterKeysFeaturesType                    = @"type";              // nonnull
NSString * const OPTLYEventParameterKeysFeaturesValue                   = @"value";             // nonnull
NSString * const OPTLYEventParameterKeysFeaturesId                      = @"entity_id";
NSString * const OPTLYEventParameterKeysFeaturesKey                     = @"key";
NSString * const OPTLYEventParameterKeysFeaturesShouldIndex             = @"shouldIndex";
NSString * const OPTLYEventParameterKeysFeaturesName                    = @"name";

// --- Decision Parameters ----
NSString * const OPTLYEventParameterKeysDecisionCampaignId              = @"campaign_id";       // nonnull
NSString * const OPTLYEventParameterKeysDecisionExperimentId            = @"experiment_id";     // nonnull
NSString * const OPTLYEventParameterKeysDecisionVariationId             = @"variation_id";      // nonnull

// --- Common Event Parameters ----
NSString * const OPTLYEventParameterKeysTimestamp                       = @"timestamp";         // nonnull
NSString * const OPTLYEventParameterKeysUUID                            = @"uuid";              // nonnull
NSString * const OPTLYEventParameterKeysEntityId                        = @"entity_id";
NSString * const OPTLYEventParameterKeysKey                             = @"key";

// --- Impression Event Parameters ----

// --- Conversion Event Parameters ----
NSString * const OPTLYEventParameterKeysTags                            = @"tags";

@implementation OPTLYEventParameterKeys

@end
