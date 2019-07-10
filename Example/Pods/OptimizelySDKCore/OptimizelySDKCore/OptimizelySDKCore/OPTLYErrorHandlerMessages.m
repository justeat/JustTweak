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

#import "OPTLYErrorHandlerMessages.h"

NSString * const OPTLYErrorHandlerMessagesDomain = @"com.optimizely.optimizelySDK";

NSString * const OPTLYErrorHandlerMessagesDataFileInvalid = @"Provided 'datafile' is in an invalid format.";
NSString * const OPTLYErrorHandlerMessagesDataFileVersionInvalid = @"Provided 'datafile' version %@ is not supported.";
NSString * const OPTLYErrorHandlerMessagesEventDispatcherInvalid = @"Provided 'event dispatcher' is in an invalid format.";
NSString * const OPTLYErrorHandlerMessagesLoggerInvalid = @"Provided 'logger' is in an invalid format.";
NSString * const OPTLYErrorHandlerMessagesErrorHandlerInvalid = @"Provided 'error handler' is in an invalid format.";
NSString * const OPTLYErrorHandlerMessagesExperimentUnknown = @"Experiment %@ is not in the datafile."; // experiment id
NSString * const OPTLYErrorHandlerMessagesEventUnknown = @"Event %@ is not in the datafile." ; //event key
NSString * const OPTLYErrorHandlerMessagesBuilderInvalid = @"Provided OPTLYBuilder object is invalid";
NSString * const OPTLYErrorHandlerMessagesUserProfileInvalid = @"Provided user profile object is invalid";

// possibly change to just log
NSString * const OPTLYErrorHandlerMessagesEventNoExperimentAssociation = @"Event %@ is not associated with any running experiments."; // event key
NSString * const OPTLYErrorHandlerMessagesBucketingIdUnknown = @"Unable to generate hash key for bucketing ID: %@."; // bucketing id

NSString * const OPTLYErrorHandlerMessagesAttributeUnknown = @"Attribute(s) %@ not in the datafile."; // attribute ids
NSString * const OPTLYErrorHandlerMessagesAttributeFormatInvalid = @"Attributes provided in invalid format." ;
NSString * const OPTLYErrorHandlerMessagesGroupUnknown = @"Provided group is not in datafile.";

NSString *const OPTLYErrorHandlerMessagesVariationUnknown = @"Provided variation %@ is not in datafile.";
NSString *const OPTLYErrorHandlerMessagesEventTypeUnknown = @"Provided event type is not in datafile.";

// added
NSString * const OPTLYErrorHandlerMessagesTrafficAllocationNotInRange= @"Traffic allocation %ld is not in range.";
NSString * const OPTLYErrorHandlerMessagesBucketingIdInvalid = @"Invalid bucketing ID: %ld."; // bucketing id
NSString * const OPTLYErrorHandlerMessagesTrafficAllocationUnknown = @"Traffic allocations for %@ does not exist in datafile."; // experiment or group id
NSString * const OPTLYErrorHandlerMessagesEventDispatchFailed = @"Event %@ failed to dispatch.";
NSString * const OPTLYErrorHandlerMessagesConfigInvalid = @"Project config is nil or invalid.";

// Manager Errors
NSString *const OPTLYErrorHandlerMessagesManagerBuilderInvalid = @"Provided OPTLYManagerBuilder object is invalid.";

// Event Data Store
NSString *const OPTLYErrorHandlerMessagesDataStoreDatabaseNoSavedEvents = @"[EVENT DATA STORE] Unable to remove events for event type: %@. No saved events.";
NSString *const OPTLYErrorHandlerMessagesDataStoreDatabaseNoDataToSave = @"[DATABASE] No data to save for %@.";
NSString *const OPTLYErrorHandlerMessagesDataStoreInvalidDataStoreEntityValue = @"[EVENT DATA STORE] Invalid data store entity value.";

// ---- HTTP Request Manager ----
NSString *const OPTLYErrorHandlerMessagesHTTPRequestManagerPOSTRetryFailure = @"[HTTP] The max backoff retry has been exceeded. POST failed with error: %@.";
NSString *const OPTLYErrorHandlerMessagesHTTPRequestManagerGETRetryFailure = @"[HTTP] The max backoff retry has been exceeded. GET failed with error: %@.";
NSString *const OPTLYErrorHandlerMessagesHTTPRequestManagerGETIfModifiedFailure = @"[HTTP] The max backoff retry has been exceeded. GET if modified failed with error: %@.";

// ---- Project Config ----
NSString *const OPTLYErrorHandlerMessagesProjectConfigInvalidAudienceCondition = @"[CONFIG] Invalid audience condition.";

@implementation OPTLYErrorHandlerMessages
@end
