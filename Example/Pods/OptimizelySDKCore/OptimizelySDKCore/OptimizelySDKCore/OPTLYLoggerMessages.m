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

#import "OPTLYLoggerMessages.h"

// ---- Optimizely ----
// debug
NSString *const OPTLYLoggerMessagesVariationUserAssigned = @"[OPTIMIZELY] User %@ is in variation %@ of experiment %@.";
// info
NSString *const OPTLYLoggerMessagesActivationSuccess = @"[OPTIMIZELY] Activating user %@ in experiment %@.";
NSString *const OPTLYLoggerMessagesConversionSuccess = @"[OPTIMIZELY] Tracking event %@ for user %@.";
NSString *const OPTLYLoggerMessagesConversionFailure = @"[OPTIMIZELY] No valid experiment for event %@ to track.";
// error
NSString *const OPTLYLoggerMessagesUserIdInvalid = @"[OPTIMIZELY] User ID cannot be nil or an empty string.";
NSString *const OPTLYLoggerMessagesActivateExperimentKeyEmpty = @"[OPTIMIZELY] Experiment Key cannot be nil or an empty string.";
NSString *const OPTLYLoggerMessagesActivateExperimentKeyInvalid = @"[OPTIMIZELY] Experiment not found for Key %@.";
NSString *const OPTLYLoggerMessagesTrackEventKeyEmpty = @"[OPTIMIZELY] Event Key cannot be nil or an empty string.";
NSString *const OPTLYLoggerMessagesTrackEventKeyInvalid = @"[OPTIMIZELY] Event not found for Key %@.";
NSString *const OPTLYLoggerMessagesTrackEventNoAssociation = @"[OPTIMIZELY] Event key %@ is not associated with any experiment.";
NSString *const OPTLYLoggerMessagesTrackExperimentNoAssociation = @"[OPTIMIZELY] Experiment %@ is not associated with event %@.";
NSString *const OPTLYLoggerMessagesTrackExperimentNotTracked = @"[OPTIMIZELY] Not tracking user %@ for experiment %@";
NSString *const OPTLYLoggerMessagesFeatureDisabledUserIdInvalid = @"[OPTIMIZELY] User ID must not be empty for feature enabled.";
NSString *const OPTLYLoggerMessagesFeatureDisabledFlagKeyInvalid = @"[OPTIMIZELY] Feature flag key must not be empty for feature enabled.";
NSString *const OPTLYLoggerMessagesFeatureDisabled = @"[OPTIMIZELY] Feature flag %@ is not enabled for user %@.";
NSString *const OPTLYLoggerMessagesFeatureEnabledNotExperimented = @"[OPTIMIZELY] The user %@ is not being experimented on feature %@.";
NSString *const OPTLYLoggerMessagesFeatureEnabled = @"[OPTIMIZELY] Feature flag %@ is enabled for user %@.";
NSString *const OPTLYLoggerMessagesFeatureVariableValueFlagKeyInvalid = @"[OPTIMIZELY] Feature flag key must not be empty for feature variable value.";
NSString *const OPTLYLoggerMessagesFeatureVariableValueVariableKeyInvalid = @"[OPTIMIZELY] Variable key must not be empty for feature variable value.";
NSString *const OPTLYLoggerMessagesFeatureVariableValueUserIdInvalid = @"[OPTIMIZELY] User ID must not be empty for feature variable value.";
NSString *const OPTLYLoggerMessagesFeatureVariableValueVariableInvalid = @"[OPTIMIZELY] No feature variable was found for key %@ in feature flag %@.";
NSString *const OPTLYLoggerMessagesFeatureVariableValueVariableTypeInvalid = @"[OPTIMIZELY] Variable is of type %@, but you requested it as type %@.";
NSString *const OPTLYLoggerMessagesFeatureVariableValueVariableType = @"[OPTIMIZELY] Returning variable value %@ for variation %@ of feature flag %@";
NSString *const OPTLYLoggerMessagesFeatureVariableValueNotUsed = @"[OPTIMIZELY] Variable %@ is not used in variation %@, returning default value %@.";
NSString *const OPTLYLoggerMessagesFeatureVariableValueNotBucketed = @"[OPTIMIZELY] User %@ is not in any variation for feature flag %@, returning default value %@.";
NSString *const OPTLYLoggerMessagesFeatureDisabledReturnDefault = @"[OPTIMIZELY] Feature %@ is not enabled for user %@, returning default value %@.";

// ---- Bucketer ----
// debug
NSString *const OPTLYLoggerMessagesBucketAssigned = @"[BUCKETER] Assigned bucket %@ to user %@.";
// info
NSString *const OPTLYLoggerMessagesForcedVariationUser = @"[BUCKETER] User %@ is forced in variation %@.";
NSString *const OPTLYLoggerMessagesUserMutuallyExcluded = @"[BUCKETER] User %@ is not in experiment %@ of group %@."; // user id, experiment key, group ID // user id
// error
NSString *const OPTLYLoggerMessagesForcedBucketingFailed = @"[BUCKETER] Entity %@ is not in the datafile. Not activating user %@."; // changed text from from 'variation' to 'entity'

// ---- Client ----
// error
NSString *const OPTLYLoggerMessagesActivationFailure = @"[CLIENT] Not activating user %@ for experiment %@."; // NOTE: also in Optimizely
NSString *const OPTLYLoggerMessagesClientDummyOptimizelyError = @"[CLIENT] Optimizely is not initialized.";
NSString *const OPTLYLoggerMessagesGetVariationFailure = @"[CLIENT] Could not get variation for user %@ for experiment %@."; // user ID, experiment key
NSString *const OPTLYLoggerMessagesTrackFailure = @"[CLIENT] Not tracking event %@ for user %@."; // NOTE: also in Optimizely

// ---- Data Store ----
// Event Data Store
// debug
NSString *const OPTLYLoggerMessagesDataStoreDatabaseEventDataStoreError = @"[DATA STORE] Event data store initialization failed with the following error: %@";
NSString *const OPTLYLoggerMessagesDataStoreDatabaseSaveError = @"[DATA STORE] Error saving events to database. Data: %@, eventType: %@, error: %@.";
NSString *const OPTLYLoggerMessagesDataStoreDatabaseGetError = @"[DATA STORE] Error getting events. Number of events requested: %ld, eventType: %@, error: %@.";
NSString *const OPTLYLoggerMessagesDataStoreDatabaseGetNumberEvents = @"[DATA STORE] Error getting number of events. eventType: %@, error: %@.";
NSString *const OPTLYLoggerMessagesDataStoreDatabaseRemoveError = @"[DATA STORE] Error removing events. Number of events to remove: %ld, eventType: %@, error: %@.";
NSString *const OPTLYLoggerMessagesDataStoreDatabaseRemoveEventError = @"[DATA STORE] Remove event error: %@, eventType: %@, event: %@.";
// warning
NSString *const OPTLYLoggerMessagesDataStoreEventsRemoveAllWarning = @"[DATA STORE] Warning: Removing all events from data store! These events will not be tracked by Optimizely.";
NSString *const OPTLYLoggerMessagesDataStoreDatabaseGetNoEvents = @"[DATA STORE] Get event returned no event. eventType: %@.";
NSString *const OPTLYLoggerMessagesDataStoreDatabaseRemovingOldEvents = @"[DATA STORE] Event storage is full. Removing %lu events.";

// File Manager
// debug
NSString *const OPTLYLoggerMessagesDataStoreFileManagerGetFile = @"[FILE MANAGER] Error getting file for data type %ld. File name: %@. Error: %@.";
NSString *const OPTLYLoggerMessagesDataStoreFileManagerRemoveAllFilesError = @"[FILE MANAGER] Remove all files error: %@.";
NSString *const OPTLYLoggerMessagesDataStoreFileManagerRemoveFileForDataTypeError = @"[FILE MANAGER] Error removing file for data type %ld. File name: %@. Error: %@.";
NSString *const OPTLYLoggerMessagesDataStoreFileManagerRemoveFilesForDataTypeError = @"[FILE MANAGER] Error removing files for data type %ld. Error: %@.";
NSString *const OPTLYLoggerMessagesDataStoreFileManagerSaveFile = @"[FILE MANAGER] Error saving file for data type %ld. File name: %@. Error: %@.";

// ---- Datafile Manager ----
// debug
NSString *const OPTLYLoggerMessagesDatafileManagerDatafileNotDownloadedInvalidStatusCode = @"[DATAFILE MANAGER] Datafile for project %@ NOT downloaded. Invalid status code %d.";
NSString *const OPTLYLoggerMessagesDatafileManagerDatafileNotDownloadedError = @"[DATAFILE MANAGER] Datafile for project %@ NOT downloaded. Error received: %@.";
NSString *const OPTLYLoggerMessagesDatafileManagerDatafileNotDownloadedNoChanges = @"[DATAFILE MANAGER] Datafile for project %@ NOT downloaded. No datafile changes have been made.";
NSString *const OPTLYLoggerMessagesDatafileManagerLastModifiedDateFound = @"[DATAFILE MANAGER] Last modified date %@ found for project %@.";
NSString *const OPTLYLoggerMessagesDatafileManagerLastModifiedDateNotFound = @"[DATAFILE MANAGER] Last modified date not found for project %@.";
NSString *const OPTLYLoggerMessagesDatafileManagerLastModifiedDate = @"[DATAFILE MANAGER] Datafile was last modified on %@.";
// info
NSString *const OPTLYLoggerMessagesDatafileManagerDatafileDownloaded = @"[DATAFILE MANAGER] Datafile for project %@ downloaded. Saving datafile and last modified date: %@.";
NSString *const OPTLYLoggerMessagesDatafileManagerDatafileDownloading = @"[DATAFILE MANAGER] Downloading datafile for project %@.";
NSString *const OPTLYLoggerMessagesDatafileManagerDatafileSaved = @"[DATAFILE MANAGER] Datafile saved for project %@.";

// Datafile Manager Builder
// warning
NSString *const OPTLYLoggerMessagesDatafileManagerInitializedWithoutProjectIdMessage = @"[DATAFILE MANAGER BUILDER] Optimizely Datafile Manager must be initialized with a project ID.";
// error
NSString *const OPTLYLoggerMessagesDatafileFetchIntervalInvalid = @"[DATAFILE MANAGER BUILDER] A datafile fetch interval of %f is invalid. Please set a datafile fetch interval >= 0."; // invalid datafile fetch interval value

// ---- Datafile Versioning ----
// info
NSString *const OPTLYLoggerMessagesDatafileVersion = @"[PROJECT CONFIG] Datafile version is  %@."; // datafile version

// ---- Event Builder ----
// debug
NSString *const OPTLYLoggerMessagesAttributeInvalidFormat = @"[EVENT BUILDER] Provided attribute %@ is in an invalid format."; // added id parameter, changed to singular
NSString *const OPTLYLoggerMessagesAttributeValueInvalidFormat = @"[EVENT BUILDER] Provided value for attribute %@ is in an invalid format.";
NSString *const OPTLYLoggerMessagesEventNotAssociatedWithExperiment = @"[EVENT BUILDER] Event key %@ is not associated with any experiment."; // event key
NSString *const OPTLYLoggerMessagesExperimentNotPartOfEvent = @"[EVENT BUILDER] Experiment %@ is not associated with event %@.";
// warning
NSString *const OPTLYLoggerMessagesEventKeyInvalid = @"[EVENT BUILDER] Event key cannot be an empty string.";
NSString *const OPTLYLoggerMessagesNoExperiment = @"[EVENT BUILDER] Not building decision event ticket for no experiment.";
NSString *const OPTLYLoggerMessagesVariationIdInvalid = @"[EVENT BUILDER] Variation ID cannot be an empty string.";
NSString *const OPTLYLoggerMessagesEventNotPassAudienceEvaluation = @"[EVENT BUILDER] None of the experiments of %@ pass audience evaluation.";
NSString *const OPTLYLoggerMessagesRevenueValueFloat = @"[EVENT BUILDER] Provided float revenue value %@ will be cast to integer %@.";
NSString *const OPTLYLoggerMessagesRevenueValueString = @"[EVENT BUILDER] Provided string revenue value will be cast to integer %@.";
NSString *const OPTLYLoggerMessagesRevenueValueIntegerOverflow = @"[EVENT BUILDER] Provided unsigned long long revenue value %@ overflows long long type and will not be sent to results.";
NSString *const OPTLYLoggerMessagesRevenueValueFloatOverflow = @"[EVENT BUILDER] Provided float revenue value %@ overflows long long type and will not be sent to results.";
NSString *const OPTLYLoggerMessagesRevenueValueInvalidBoolean = @"[EVENT BUILDER] Provided revenue value %@ is an invalid boolean type and will not be sent to results.";
NSString *const OPTLYLoggerMessagesRevenueValueInvalid = @"[EVENT BUILDER] Provided revenue value is in an invalid format and will not be sent to results.";
NSString *const OPTLYLoggerMessagesNumericValueString = @"[EVENT BUILDER] Provided string numeric value will be cast to float %@.";
NSString *const OPTLYLoggerMessagesNumericValueInvalidBoolean = @"[EVENT BUILDER] Provided numeric value %@ is an invalid boolean type and will not be sent to results.";
NSString *const OPTLYLoggerMessagesNumericValueInvalidFloat = @"[EVENT BUILDER] Provided numeric value %@ is an invalid float type and will not be sent to results.";
NSString *const OPTLYLoggerMessagesNumericValueInvalidString = @"[EVENT BUILDER] Provided numeric value is a string %@ that could not be cast to a valid float.";
NSString *const OPTLYLoggerMessagesNumericValueInvalid = @"[EVENT BUILDER] Provided numeric value is in an invalid format and will not be sent to results.";
NSString *const OPTLYLoggerMessagesEventTagValueInvalid = @"[EVENT BUILDER] Provided event tag %@ is neither an integer nor a string and will not be sent to results.";

// ---- Event Dispatcher ----
// info
NSString *const OPTLYLoggerMessagesEventDispatcherActivationFailure = @"[EVENT DISPATCHER] Not activating user %@ for experiment %@.";
NSString *const OPTLYLoggerMessagesEventDispatcherEventNotTracked = @"[EVENT DISPATCHER] Not tracking event %@ for user %@."; // event key, userId
NSString *const OPTLYLoggerMessagesEventDispatcherAttemptingToSendConversionEvent = @"[EVENT DISPATCHER] Attempting to send conversion event %@ for user %@";
NSString *const OPTLYLoggerMessagesEventDispatcherAttemptingToSendImpressionEvent = @"[EVENT DISPATCHER] Attempting to send impression event for user %@ in experiment %@";
NSString *const OPTLYLoggerMessagesEventDispatcherTrackingSuccess = @"[EVENT DISPATCHER] Successfully tracked event %@ for user %@";
NSString *const OPTLYLoggerMessagesEventDispatcherActivationSuccess = @"[EVENT DISPATCHER] Successfully activated user %@ in experiment %@";
// warning
NSString *const OPTLYLoggerMessagesEventDispatcherInvalidInterval =  @"[EVENT DISPATCHER] Invalid dispatch interval set: %ld";

// debug
NSString *const OPTLYLoggerMessagesEventDispatcherProperties =  @"[EVENT DISPATCHER] Event dispatch interval: %ld [second(s)]";
NSString *const OPTLYLoggerMessagesEventDispatcherNetworkTimerEnabled = @"[EVENT DISPATCHER] Network timer enabled with interval: %ld [second(s)].";
NSString *const OPTLYLoggerMessagesEventDispatcherNetworkTimerDisabled = @"[EVENT DISPATCHER] Network timer disabled";
NSString *const OPTLYLoggerMessagesEventDispatcherFlushingEvents = @"[EVENT DISPATCHER] Flushing events";
NSString *const OPTLYLoggerMessagesEventDispatcherFlushEventsNoEvents = @"[EVENT DISPATCHER] No events to flush";
NSString *const OPTLYLoggerMessagesEventDispatcherFlushEventsMax = @"[EVENT DISPATCHER] Max number of flush events attempted %lu.";
NSString *const OPTLYLoggerMessagesEventDispatcherFlushingSavedEvents = @"[EVENT DISPATCHER] Flushing saved %@. Number of events: %lu";
NSString *const OPTLYLoggerMessagesEventDispatcherFlushSavedEventsNoEvents =  @"[EVENT DISPATCHER] No %@ to flush";
NSString *const OPTLYLoggerMessagesEventDispatcherDispatchFailed =  @"[EVENT DISPATCHER] %@ dispatch failed with error: %@";
NSString *const OPTLYLoggerMessagesEventDispatcherPendingEvent = @"[EVENT DISPATCHER] Event already pending dispatch: %@";
NSString *const OPTLYLoggerMessagesEventDispatcherEventSaved = @"[EVENT DISPATCHER] %@ saved: %@"; //event type, event
NSString *const OPTLYLoggerMessagesEventDispatcherRemovedEvent = @"[EVENT DISPATCHER] %@ removed: %@ with error: %@"; //event type, event, error
NSString *const OPTLYLoggerMessagesEventDispatcherInvalidEvent = @"[EVENT DISPATCHER] Invalid event.";

// ---- Manager ----
// error
NSString *const OPTLYLoggerMessagesManagerBuilderBlockNotValid = @"[MANAGER] An Optimizely Manager Builder instance was not able to be initialized because the OPTLYManagerBuilderBlock was nil.";
NSString *const OPTLYLoggerMessagesManagerBuilderNotValid = @"[MANAGER] An Optimizely Manager instance was not able to be initialized because the OPTLYManagerBuilder object was invalid.";
NSString *const OPTLYLoggerMessagesManagerDatafileManagerDoesNotConformToOPTLYDatafileManagerProtocol = @"[MANAGER] Datafile manager does not conform to the OPTLYDatafileManager protocol.";
NSString *const OPTLYLoggerMessagesManagerErrorHandlerDoesNotConformToOPTLYErrorHandlerProtocol = @"[MANAGER] Error handler does not conform to the OPTLYErrorHandler protocol.";
NSString *const OPTLYLoggerMessagesManagerEventDispatcherDoesNotConformToOPTLYEventDispatcherProtocol = @"[MANAGER] Event dispatcher does not conform to the OPTLYEventDispatcher protocol.";
NSString *const OPTLYLoggerMessagesManagerLoggerDoesNotConformToOPTLYLoggerProtocol = @"[MANAGER] Logger does not conform to the OPTLYLogger protocol.";
NSString *const OPTLYLoggerMessagesManagerMustBeInitializedWithProjectId = @"[MANAGER] An Optimizely Manager instance must be initialized with a project ID or SDK Key.";
NSString *const OPTLYLoggerMessagesManagerProjectIdCannotBeEmptyString = @"[MANAGER] The project ID for the Optimizely Manager instance cannot be an empty string";
NSString *const OPTLYLoggerMessagesManagerInit = @"[MANAGER] Initializing client for projectId %@ with SDK Key %@.";
NSString *const OPTLYLoggerMessagesManagerInitWithCallback = @"[MANAGER] Initializing client with callback for projectId %@ with SDK Key %@.";
NSString *const OPTLYLoggerMessagesManagerInitWithCallbackErrorDatafileDownload = @"[MANAGER] Error downloading datafile: %@.";
NSString *const OPTLYLoggerMessagesManagerInitWithCallbackNoDatafileUpdates = @"[MANAGER] Not downloading new datafile — no updates have been made.";
NSString *const OPTLYLoggerMessagesManagerBundledDataLoaded = @"[MANAGER] The bundled datafile was loaded.";

// ---- Project Config Getters ----
// warning
NSString *const OPTLYLoggerMessagesAttributeUnknownForAttributeKey = @"[PROJECT CONFIG] Attribute not found for attribute key: %@. Attribute key is not in the datafile."; // attribute key
NSString *const OPTLYLoggerMessagesAudienceUnknownForAudienceId = @"[PROJECT CONFIG] Audience not found for audience ID: %@. Audience ID is not in the datafile."; // audience id
NSString *const OPTLYLoggerMessagesEventIdUnknownForEventKey = @"[PROJECT CONFIG] Event ID not found for event key: %@. Event ID is not in the datafile."; // event key
NSString *const OPTLYLoggerMessagesEventUnknownForEventKey = @"[PROJECT CONFIG] Event not found for event key: %@. Event key is not in the datafile."; // event key
NSString *const OPTLYLoggerMessagesExperimentIdUnknownForExperimentKey = @"[PROJECT CONFIG] Experiment ID not found for experiment key: %@. Experiment key is not in the datafile."; // experiment key
NSString *const OPTLYLoggerMessagesExperimentUnknownForExperimentId = @"[PROJECT CONFIG] Experiment not found for experiment ID: %@. Experiment ID is not in the datafile."; // experiment id
NSString *const OPTLYLoggerMessagesExperimentUnknownForExperimentKey = @"[PROJECT CONFIG] Experiment key not found for experiment: %@. Experiment key is not in the datafile.";  // experiment key
NSString *const OPTLYLoggerMessagesFeatureFlagUnknownForFeatureFlagKey = @"[PROJECT CONFIG] Feature Flag key not found for feature flag: %@. Feature Flag key is not in the datafile.";  // feature flag key
NSString *const OPTLYLoggerMessagesVariableUsageUnknownForVariableId = @"[PROJECT CONFIG] Rollout not found for rollout ID: %@. Rollout ID is not in the datafile."; // feature variable id
NSString *const OPTLYLoggerMessagesRolloutUnknownForRolloutId = @"[PROJECT CONFIG] Rollout not found for rollout ID: %@. Rollout ID is not in the datafile."; // rollout id
NSString *const OPTLYLoggerMessagesGroupUnknownForGroupId = @"[PROJECT CONFIG] Group not found for group ID: %@. Group ID is not in the datafile."; // group id
NSString *const OPTLYLoggerMessagesGetVariationNilVariation = @"[PROJECT CONFIG] Get variation returned a nil variation for user %@, experiment %@";
NSString *const OPTLYLoggerMessagesVariationKeyUnknownForExperimentKey = @"[PROJECT CONFIG] Variation key %@ not found for experiment key %@.";
NSString *const OPTLYLoggerMessagesProjectConfigUserIdInvalid = @"[PROJECT CONFIG] User ID cannot be nil.";
NSString *const OPTLYLoggerMessagesProjectConfigExperimentKeyInvalid = @"[PROJECT CONFIG] Experiment Key cannot be nil or an empty string.";
NSString *const OPTLYLoggerMessagesProjectConfigVariationKeyInvalid = @"[PROJECT CONFIG] Variation key cannot be an empty string.";
NSString *const OPTLYLoggerMessagesAttributeIsReserved = @"[PROJECT CONFIG] Attribute %@ unexpectedly has reserved prefix %@; using attribute ID instead of reserved attribute name.";
NSString *const OPTLYLoggerMessagesAttributeNotFound = @"[PROJECT CONFIG] Attribute key %@ is not in datafile.";

// ---- User Profile ----
// debug
NSString *const OPTLYLoggerMessagesUserProfileBucketerUserDataRetrieved = @"[USER PROFILE] Retrieved bucketing data for user: %@, experiment ID: %@, variation ID: %@.";
NSString *const OPTLYLoggerMessagesUserProfileAttemptToSaveVariation = @"[USER PROFILE] Attempting to save experiment ID %@ with variation ID %@ for user %@."; // experiment ID, variation ID, user ID
NSString *const OPTLYLoggerMessagesUserProfileNoVariation = @"[USER PROFILE] Variation for user %@, experiment ID %@ not found."; // user ID, experiment ID
NSString *const OPTLYLoggerMessagesUserProfileRemoveVariation = @"[USER PROFILE] Removed variation ID %@ for user %@, experiment ID %@."; // variation ID, user ID, experiment ID
NSString *const OPTLYLoggerMessagesUserProfileRemoveVariationNotFound = @"[USER PROFILE] Not removing variation for user %@, experiment ID %@. Variation not found."; // user ID, experiment ID
NSString *const OPTLYLoggerMessagesUserProfileServiceSaved = @"[USER PROFILE] Saved user profile service %@ for user %@.";
NSString *const OPTLYLoggerMessagesUserProfileVariation = @"[USER PROFILE] Variation ID %@ for user %@, experiment ID %@ found."; // variation ID, user ID, experiment ID
NSString *const OPTLYLoggerMessagesUserProfileNotExist = @"[USER PROFILE SERVICE] User profile for %@ does not exist.";

// warning
NSString *const OPTLYLoggerMessagesUserProfileUnableToSaveVariation = @"[USER PROFILE] Unable to save experiment ID %@ with variation ID %@ for user %@."; // experiment ID, variation ID, user ID
NSString *const OPTLYLoggerMessagesUserProfileVariationNoLongerInDatafile = @"[USER PROFILE] Variation ID: %@ for experiment ID: %@ no longer found in datafile."; // variation ID, experiment ID
NSString *const OPTLYLoggerMessagesUserProfileSaveInvalidUserId = @"[USER PROFILE SERVICE] Invalid userId. Unable to save the user profile.";
NSString *const OPTLYLoggerMessagesUserProfileLookupInvalidFormat = @"[USER PROFILE SERVICE] Invalid format for user profile lookup: %@.";
NSString *const OPTLYLoggerMessagesUserProfileSaveInvalidFormat = @"[USER PROFILE SERVICE] Invalid format for user profile save: %@.";

// ---- Decision Service ----
// info
NSString *const OPTLYLoggerMessagesDecisionServiceExperimentNotRunning = @"[DECISION SERVICE] Experiment %@ is not running.";
NSString *const OPTLYLoggerMessagesDecisionServiceFailAudienceTargeting = @"[DECISION SERVICE] User %@ does not meet conditions to be in experiment %@.";
NSString *const OPTLYLoggerMessagesDecisionServiceSavedVariationInvalid = @"[DECISION SERVICE] Saved variation %@ is invalid. The variation has been paused or archived.";
NSString *const OPTLYLoggerMessagesDecisionServiceUserProfileNotExist = @"[DECISION SERVICE] User profile service does not exist.";
NSString *const OPTLYLoggerMessagesDecisionServiceSavedVariationParseError = @"[DECISION SERVICE] User profile parse error: %@. Unable to save user bucket information for: %@.";
NSString *const OPTLYLoggerMessagesDecisionServiceGetVariationParseError = @"[DECISION SERVICE] User profile parse error: %@. Unable to get user bucket information for: %@.";
NSString *const OPTLYLoggerMessagesDecisionServiceReplaceBucketEntity = @"[DECISION SERVICE] Replacing user %@ experiment bucket map entity %@ with %@.";
NSString *const OPTLYLoggerMessagesDecisionServiceSettingTheBucketingID = @"[DECISION SERVICE] Setting the bucketing ID to %@.";
NSString *const OPTLYLoggerMessagesDecisionServiceFFNotUsed = @"[DECISION SERVICE] Feature flag %@ is not used in any experiments.";
NSString *const OPTLYLoggerMessagesDecisionServiceFFUserBucketed = @"[DECISION SERVICE] User %@ is bucketed into experiment %@ of feature %@.";
NSString *const OPTLYLoggerMessagesDecisionServiceFFUserNotBucketed = @"[DECISION SERVICE] User %@ is not bucketed into any of the experiments using the feature %@.";
NSString *const OPTLYLoggerMessagesDecisionServiceFRNotUsed = @"[DECISION SERVICE] Feature flag %@ is not used in a rollout.";
NSString *const OPTLYLoggerMessagesDecisionServiceFRUserBucketed = @"[DECISION SERVICE] User %@ is bucketed into rollout for feature flag %@.";
NSString *const OPTLYLoggerMessagesDecisionServiceFRUserExcluded = @"[DECISION SERVICE] User %@ was excluded due to traffic allocation. Checking 'Everyone Else' rule now.";
NSString *const OPTLYLoggerMessagesDecisionServiceFRUserNotBucketed = @"[DECISION SERVICE] User %@ is not bucketed into rollout for feature flag %@.";
NSString *const OPTLYLoggerMessagesDecisionServiceUserBucketed = @"[DECISION SERVICE] User with bucketing ID %@ is in experiment %@ of group %@.";
NSString *const OPTLYLoggerMessagesDecisionServiceUserNotBucketed = @"[DECISION SERVICE] User with bucketing ID %@ is not in any experiments of group %@.";
NSString *const OPTLYLoggerMessagesDecisionServiceUserInVariation = @"[DECISION SERVICE] User %@ is in variation %@ of experiment %@.";
NSString *const OPTLYLoggerMessagesDecisionServiceGroupIdNotFound = @"[PROJECT CONFIG] Group Id not found.";
NSString *const OPTLYLoggerMessagesDecisionServiceGroupUnknownForGroupId = @"[PROJECT CONFIG] Group not found for group ID: %@.";

// ---- HTTP Request Manager ----
// Debug (not through logger handler)
NSString *const OPTLYHTTPRequestManagerGETWithParametersAttempt = @"[HTTP] GET with parameter attempt: %lu";
NSString *const OPTLYHTTPRequestManagerGETIfModifiedSince = @"[HTTP] GET if modified attempt: %lu";
NSString *const OPTLYHTTPRequestManagerPOSTWithParameters = @"[HTTP] POST attempt: %lu";
NSString *const OPTLYHTTPRequestManagerBackoffRetryStates = @"[HTTP] Retry attempt: %d exponentialMultiplier: %u delay_ns: %lu, delayTime: %lu";

// ---- Audience Evaluator ----
// info
NSString *const OPTLYLoggerMessagesAudienceEvaluatorEvaluationCompletedWithResult = @"[AUDIENCE EVALUATOR] Audience %@ evaluated to: %@.";
NSString *const OPTLYLoggerMessagesAudienceEvaluatorExperimentEvaluationCompletedWithResult = @"[AUDIENCE EVALUATOR] Audiences for experiment %@ collectively evaluated to %@.";
// warning
NSString *const OPTLYLoggerMessagesAudienceEvaluatorConditionEvaluatedAsUnknownForUnexpectedType = @"[AUDIENCE EVALUATOR] Audience condition %@ evaluated to UNKNOWN because a value of type %@ was passed for user attribute %@.";
NSString *const OPTLYLoggerMessagesAudienceEvaluatorUnknownMatchType = @"[AUDIENCE EVALUATOR] Audience condition %@ uses an unknown match type. You may need to upgrade to a newer release of the Optimizely SDK.";
NSString *const OPTLYLoggerMessagesAudienceEvaluatorUnknownConditionType = @"[AUDIENCE EVALUATOR] Audience condition %@ has an unknown condition type. You may need to upgrade to a newer release of the Optimizely SDK.";
NSString *const OPTLYLoggerMessagesAudienceEvaluatorUnsupportedValueType = @"[AUDIENCE EVALUATOR] Audience condition %@ has an unsupported condition value. You may need to upgrade to a newer release of the Optimizely SDK.";
// debug
NSString *const OPTLYLoggerMessagesAudienceEvaluatorEvaluationStartedWithConditions = @"[AUDIENCE EVALUATOR] Starting to evaluate audience %@ with conditions: %@.";
NSString *const OPTLYLoggerMessagesAudienceEvaluatorEvaluationStartedForExperiment = @"[AUDIENCE EVALUATOR] Evaluating audiences for experiment %@: %@.";
NSString *const OPTLYLoggerMessagesAudienceEvaluatorConditionEvaluatedAsUnknownForMissingAttribute = @"[AUDIENCE EVALUATOR] Audience condition %@ evaluated to UNKNOWN because no value was passed for user attribute %@.";
NSString *const OPTLYLoggerMessagesAudienceEvaluatorConditionEvaluatedAsUnknownForUnexpectedTypeNull = @"[AUDIENCE EVALUATOR] Audience condition %@ evaluated to UNKNOWN because a null value was passed for user attribute %@.";
NSString *const OPTLYLoggerMessagesAudienceEvaluatorConditionEvaluatedAsUnknownForUnexpectedTypeNanInfinity = @"[AUDIENCE EVALUATOR] Audience condition %@ evaluated to UNKNOWN because the number value for user attribute %@ is not in the range [-2^53, +2^53].";
// error

@implementation OPTLYLoggerMessages

@end
