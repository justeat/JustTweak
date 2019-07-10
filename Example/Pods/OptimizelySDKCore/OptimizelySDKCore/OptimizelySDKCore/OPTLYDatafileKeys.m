/****************************************************************************
 * Copyright 2017-2019, Optimizely, Inc. and contributors                   *
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

#import "OPTLYDatafileKeys.h"

// ---- Datafile Keys ----
NSString * const OPTLYDatafileKeysAccountId = @"accountId";
NSString * const OPTLYDatafileKeysProjectId = @"projectId";
NSString * const OPTLYDatafileKeysVersion = @"version";
NSString * const OPTLYDatafileKeysRevision =  @"revision";
NSString * const OPTLYDatafileKeysExperiments = @"experiments";
NSString * const OPTLYDatafileKeysEvents = @"events";
NSString * const OPTLYDatafileKeysAudiences = @"audiences";
NSString * const OPTLYDatafileKeysAttributes = @"attributes";
NSString * const OPTLYDatafileKeysGroups = @"groups";
// Experiment
NSString * const OPTLYDatafileKeysExperimentId = @"id";
NSString * const OPTLYDatafileKeysExperimentKey = @"key";
NSString * const OPTLYDatafileKeysExperimentStatus = @"status";
NSString * const OPTLYDatafileKeysExperimentTrafficAllocation = @"trafficAllocation";
NSString * const OPTLYDatafileKeysExperimentAudienceIds = @"audienceIds";
NSString * const OPTLYDatafileKeysExperimentAudienceConditions = @"audienceConditions";
NSString * const OPTLYDatafileKeysExperimentVariations = @"variations";
NSString * const OPTLYDatafileKeysExperimentForcedVariations = @"forcedVariations";
NSString * const OPTLYDatafileKeysExperimentLayerId = @"layerId";
// Events
NSString * const OPTLYDatafileKeysEventExperimentIds = @"experimentIds";
NSString * const OPTLYDatafileKeysEventId = @"id";
NSString * const OPTLYDatafileKeysEventKey = @"key";
// Audiences
NSString * const OPTLYDatafileKeysAudienceId = @"id";
NSString * const OPTLYDatafileKeysAudienceName = @"name";
NSString * const OPTLYDatafileKeysAudienceConditions = @"conditions";
// Attributes
NSString * const OPTLYDatafileKeysAttributeId = @"id";
NSString * const OPTLYDatafileKeysAttributeKey = @"key";
// Groups
NSString * const OPTLYDatafileKeysGroupPolicy = @"policy";
NSString * const OPTLYDatafileKeysGroupTrafficAllocation = @"trafficAllocation";
NSString * const OPTLYDatafileKeysGroupExperiments = @"experiments";
NSString * const OPTLYDatafileKeysGroupId = @"id";
// Traffic Allocation
NSString * const OPTLYDatafileKeysTrafficAllocationEntityId = @"entityId";
NSString * const OPTLYDatafileKeysTrafficAllocationEndOfRange = @"endOfRange";
// Variations
NSString * const OPTLYDatafileKeysVariationId = @"id";
NSString * const OPTLYDatafileKeysVariationKey = @"key";
NSString * const OPTLYDatafileKeysVariationVariables = @"variables";
NSString * const OPTLYDatafileKeysVariationFeatureEnabled = @"featureEnabled";
// Conditions
NSString * const OPTLYDatafileKeysConditionName = @"name";
NSString * const OPTLYDatafileKeysConditionType = @"type";
NSString * const OPTLYDatafileKeysConditionValue = @"value";
NSString * const OPTLYDatafileKeysConditionMatch = @"match";
NSString * const OPTLYDatafileKeysAndCondition = @"and";
NSString * const OPTLYDatafileKeysNotCondition = @"not";
NSString * const OPTLYDatafileKeysOrCondition = @"or";
// Match Types
NSString * const OPTLYDatafileKeysMatchTypeExact = @"exact";
NSString * const OPTLYDatafileKeysMatchTypeExists = @"exists";
NSString * const OPTLYDatafileKeysMatchTypeSubstring = @"substring";
NSString * const OPTLYDatafileKeysMatchTypeGreaterThan = @"gt";
NSString * const OPTLYDatafileKeysMatchTypeLessThan = @"lt";
NSString * const OPTLYDatafileKeysMatchTypeRegex = @"regex";
// Custom Attribute Condition Types
NSString * const OPTLYDatafileKeysCustomAttributeConditionType = @"custom_attribute";
// User Profile Service (not in datafile yet)
NSString * const OPTLYDatafileKeysUserProfileServiceUserId = @"user_id";
NSString * const OPTLYDatafileKeysUserProfileServiceExperimentBucketMap = @"experiment_bucket_map";
NSString * const OPTLYDatafileKeysUserProfileServiceVariationId = @"variation_id";
// Feature Flag
NSString * const OPTLYDatafileKeysFeatureFlagId             = @"id";
NSString * const OPTLYDatafileKeysFeatureFlagKey            = @"key";
NSString * const OPTLYDatafileKeysFeatureFlagRolloutId      = @"rolloutId";
NSString * const OPTLYDatafileKeysFeatureFlagExperimentIds  = @"experimentIds";
NSString * const OPTLYDatafileKeysFeatureFlagVariables      = @"variables";
NSString * const OPTLYDatafileKeysFeatureFlagGroupId        = @"groupId";
// Feature Variable
NSString * const OPTLYDatafileKeysFeatureVariableId             = @"id";
NSString * const OPTLYDatafileKeysFeatureVariableKey            = @"key";
NSString * const OPTLYDatafileKeysFeatureVariableType           = @"type";
NSString * const OPTLYDatafileKeysFeatureVariableDefaultValue   = @"defaultValue";
// Variable Usage
NSString * const OPTLYDatafileKeysVariableUsageId       = @"id";
NSString * const OPTLYDatafileKeysVariableUsageValue    = @"value";
// Rollout
NSString * const OPTLYDatafileKeysRolloutId             = @"id";
NSString * const OPTLYDatafileKeysRolloutExperiments    = @"experiments";

@implementation OPTLYDatafileKeys
@end
