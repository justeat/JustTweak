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

#import "Optimizely.h"
#import "OPTLYAttribute.h"
#import "OPTLYAudience.h"
#import "OPTLYBaseCondition.h"
#import "OPTLYAudienceBaseCondition.h"
#import "OPTLYBucketer.h"
#import "OPTLYBuilder.h"
#import "OPTLYCondition.h"
#import "OPTLYDatafileKeys.h"
#import "OPTLYDecisionService.h"
#import "OPTLYDecisionEventTicket.h"
#import "OPTLYErrorHandler.h"
#import "OPTLYErrorHandlerMessages.h"
#import "OPTLYEvent.h"
#import "OPTLYEventAudience.h"
#import "OPTLYEventBuilder.h"
#import "OPTLYEventDecision.h"
#import "OPTLYEventDecisionTicket.h"
#import "OPTLYEventDispatcherBasic.h"
#import "OPTLYEventFeature.h"
#import "OPTLYEventHeader.h"
#import "OPTLYEventLayerState.h"
#import "OPTLYEventMetric.h"
#import "OPTLYEventParameterKeys.h"
#import "OPTLYEventRelatedEvent.h"
#import "OPTLYEventView.h"
#import "OPTLYExperiment.h"
#import "OPTLYExperimentBucketMapEntity.h"
#import "OPTLYFeatureDecision.h"
#import "OPTLYFeatureFlag.h"
#import "OPTLYFeatureVariable.h"
#import "OPTLYGroup.h"
#import "OPTLYHTTPRequestManager.h"
#import "OPTLYLog.h"
#import "OPTLYLogger.h"
#import "OPTLYLoggerMessages.h"
#import "OPTLYNetworkService.h"
#import "OPTLYNotificationCenter.h"
#import "OPTLYProjectConfig.h"
#import "OPTLYProjectConfigBuilder.h"
#import "OPTLYQueue.h"
#import "OPTLYRollout.h"
#import "OPTLYTrafficAllocation.h"
#import "OPTLYUserProfile.h"
#import "OPTLYUserProfileServiceBasic.h"
#import "OPTLYVariableUsage.h"
#import "OPTLYVariation.h"
#import "OPTLYControlAttributes.h"

#import "OPTLYJSONModel.h"
#import "OPTLYJSONModelClassProperty.h"
#import "OPTLYJSONModelError.h"
#import "OPTLYJSONModelLib.h"
#import "OPTLYJSONKeyMapper.h"
#import "OPTLYJSONValueTransformer.h"

FOUNDATION_EXPORT double OptimizelySDKCoreVersionNumber;
FOUNDATION_EXPORT const unsigned char OptimizelySDKCoreVersionString[];

