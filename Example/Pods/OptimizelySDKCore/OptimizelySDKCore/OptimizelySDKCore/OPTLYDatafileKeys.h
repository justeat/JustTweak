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

/*
    This class contains all the project datafile JSON keys.
*/

#import <Foundation/Foundation.h>

// ---- Datafile Keys ----
extern NSString * const OPTLYDatafileKeysAccountId;
extern NSString * const OPTLYDatafileKeysProjectId;
extern NSString * const OPTLYDatafileKeysVersion;
extern NSString * const OPTLYDatafileKeysRevision;
extern NSString * const OPTLYDatafileKeysExperiments;
extern NSString * const OPTLYDatafileKeysEvents;
extern NSString * const OPTLYDatafileKeysAudiences;
extern NSString * const OPTLYDatafileKeysAttributes;
extern NSString * const OPTLYDatafileKeysGroups;
// Experiment
extern NSString * const OPTLYDatafileKeysExperimentId;
extern NSString * const OPTLYDatafileKeysExperimentKey;
extern NSString * const OPTLYDatafileKeysExperimentStatus;
extern NSString * const OPTLYDatafileKeysExperimentTrafficAllocation;
extern NSString * const OPTLYDatafileKeysExperimentAudienceIds;
extern NSString * const OPTLYDatafileKeysExperimentAudienceConditions;
extern NSString * const OPTLYDatafileKeysExperimentVariations;
extern NSString * const OPTLYDatafileKeysExperimentForcedVariations;
extern NSString * const OPTLYDatafileKeysExperimentLayerId;
// Events
extern NSString * const OPTLYDatafileKeysEventExperimentIds;
extern NSString * const OPTLYDatafileKeysEventId;
extern NSString * const OPTLYDatafileKeysEventKey;
// Audiences
extern NSString * const OPTLYDatafileKeysAudienceId;
extern NSString * const OPTLYDatafileKeysAudienceName;
extern NSString * const OPTLYDatafileKeysAudienceConditions;
// Attributes
extern NSString * const OPTLYDatafileKeysAttributeId;
extern NSString * const OPTLYDatafileKeysAttributeKey;
// Groups
extern NSString * const OPTLYDatafileKeysGroupPolicy;
extern NSString * const OPTLYDatafileKeysGroupTrafficAllocation;
extern NSString * const OPTLYDatafileKeysGroupExperiments;
extern NSString * const OPTLYDatafileKeysGroupId;
// Traffic Allocation
extern NSString * const OPTLYDatafileKeysTrafficAllocationEntityId;
extern NSString * const OPTLYDatafileKeysTrafficAllocationEndOfRange;
// Variations
extern NSString * const OPTLYDatafileKeysVariationId;
extern NSString * const OPTLYDatafileKeysVariationKey;
extern NSString * const OPTLYDatafileKeysVariationVariables;
extern NSString * const OPTLYDatafileKeysVariationFeatureEnabled;
// Conditions
extern NSString * const OPTLYDatafileKeysConditionName;
extern NSString * const OPTLYDatafileKeysConditionType;
extern NSString * const OPTLYDatafileKeysConditionValue;
extern NSString * const OPTLYDatafileKeysConditionMatch;
extern NSString * const OPTLYDatafileKeysAndCondition;
extern NSString * const OPTLYDatafileKeysNotCondition;
extern NSString * const OPTLYDatafileKeysOrCondition;
// Match Types
extern NSString * const OPTLYDatafileKeysMatchTypeExact;
extern NSString * const OPTLYDatafileKeysMatchTypeExists;
extern NSString * const OPTLYDatafileKeysMatchTypeSubstring;
extern NSString * const OPTLYDatafileKeysMatchTypeGreaterThan;
extern NSString * const OPTLYDatafileKeysMatchTypeLessThan;
extern NSString * const OPTLYDatafileKeysMatchTypeRegex;
// Custom Attribute Condition Types
extern NSString * const OPTLYDatafileKeysCustomAttributeConditionType;
// User Profile Service (not in datafile yet)
extern NSString * const OPTLYDatafileKeysUserProfileServiceUserId;
extern NSString * const OPTLYDatafileKeysUserProfileServiceExperimentBucketMap;
extern NSString * const OPTLYDatafileKeysUserProfileServiceVariationId;
// Feature Flag
extern NSString * const OPTLYDatafileKeysFeatureFlagId;
extern NSString * const OPTLYDatafileKeysFeatureFlagKey;
extern NSString * const OPTLYDatafileKeysFeatureFlagRolloutId;
extern NSString * const OPTLYDatafileKeysFeatureFlagExperimentIds;
extern NSString * const OPTLYDatafileKeysFeatureFlagVariables;
extern NSString * const OPTLYDatafileKeysFeatureFlagGroupId;
// Feature Variable
extern NSString * const OPTLYDatafileKeysFeatureVariableId;
extern NSString * const OPTLYDatafileKeysFeatureVariableKey;
extern NSString * const OPTLYDatafileKeysFeatureVariableType;
extern NSString * const OPTLYDatafileKeysFeatureVariableDefaultValue;
// Variable Usage
extern NSString * const OPTLYDatafileKeysVariableUsageId;
extern NSString * const OPTLYDatafileKeysVariableUsageValue;
// Rollout
extern NSString * const OPTLYDatafileKeysRolloutId;
extern NSString * const OPTLYDatafileKeysRolloutExperiments;

@interface OPTLYDatafileKeys : NSObject

@end
