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
 This class contains all the log messages that will be called by the SDK.
 */

#import <Foundation/Foundation.h>

// ---- Optimizely ----
// debug
extern NSString *const OPTLYLoggerMessagesVariationUserAssigned;
// info
extern NSString *const OPTLYLoggerMessagesActivationSuccess;
extern NSString *const OPTLYLoggerMessagesConversionSuccess;
extern NSString *const OPTLYLoggerMessagesConversionFailure;
// error
extern NSString *const OPTLYLoggerMessagesUserIdInvalid;
extern NSString *const OPTLYLoggerMessagesActivateExperimentKeyEmpty;
extern NSString *const OPTLYLoggerMessagesActivateExperimentKeyInvalid;
extern NSString *const OPTLYLoggerMessagesTrackEventKeyEmpty;
extern NSString *const OPTLYLoggerMessagesTrackEventKeyInvalid;
extern NSString *const OPTLYLoggerMessagesTrackEventNoAssociation;
extern NSString *const OPTLYLoggerMessagesTrackExperimentNoAssociation;
extern NSString *const OPTLYLoggerMessagesTrackExperimentNotTracked;
extern NSString *const OPTLYLoggerMessagesFeatureDisabledUserIdInvalid;
extern NSString *const OPTLYLoggerMessagesFeatureDisabledFlagKeyInvalid;
extern NSString *const OPTLYLoggerMessagesFeatureDisabled;
extern NSString *const OPTLYLoggerMessagesFeatureEnabledNotExperimented;
extern NSString *const OPTLYLoggerMessagesFeatureEnabled;
extern NSString *const OPTLYLoggerMessagesFeatureVariableValueFlagKeyInvalid;
extern NSString *const OPTLYLoggerMessagesFeatureVariableValueVariableKeyInvalid;
extern NSString *const OPTLYLoggerMessagesFeatureVariableValueUserIdInvalid;
extern NSString *const OPTLYLoggerMessagesFeatureVariableValueVariableInvalid;
extern NSString *const OPTLYLoggerMessagesFeatureVariableValueVariableTypeInvalid;
extern NSString *const OPTLYLoggerMessagesFeatureVariableValueVariableType;
extern NSString *const OPTLYLoggerMessagesFeatureVariableValueNotUsed;
extern NSString *const OPTLYLoggerMessagesFeatureVariableValueNotBucketed;
extern NSString *const OPTLYLoggerMessagesFeatureDisabledReturnDefault;

// ---- Bucketer ----
// debug
extern NSString *const OPTLYLoggerMessagesBucketAssigned;
// info
extern NSString *const OPTLYLoggerMessagesForcedVariationUser;
extern NSString *const OPTLYLoggerMessagesUserMutuallyExcluded;
// error
extern NSString *const OPTLYLoggerMessagesForcedBucketingFailed;

// ---- Client ----
// error
extern NSString *const OPTLYLoggerMessagesActivationFailure;
extern NSString *const OPTLYLoggerMessagesClientDummyOptimizelyError;
extern NSString *const OPTLYLoggerMessagesGetVariationFailure;
extern NSString *const OPTLYLoggerMessagesTrackFailure;

// ---- Data Store ----
// Event Data Store
// debug
extern NSString *const OPTLYLoggerMessagesDataStoreDatabaseEventDataStoreError;
extern NSString *const OPTLYLoggerMessagesDataStoreDatabaseSaveError;
extern NSString *const OPTLYLoggerMessagesDataStoreDatabaseGetError;
extern NSString *const OPTLYLoggerMessagesDataStoreDatabaseGetNumberEvents;
extern NSString *const OPTLYLoggerMessagesDataStoreDatabaseRemoveError;
extern NSString *const OPTLYLoggerMessagesDataStoreDatabaseRemoveEventError;
// warning
extern NSString *const OPTLYLoggerMessagesDataStoreEventsRemoveAllWarning;
extern NSString *const OPTLYLoggerMessagesDataStoreDatabaseGetNoEvents;
extern NSString *const OPTLYLoggerMessagesDataStoreDatabaseRemovingOldEvents;

// File Manager
// debug
extern NSString *const OPTLYLoggerMessagesDataStoreFileManagerGetFile;
extern NSString *const OPTLYLoggerMessagesDataStoreFileManagerRemoveAllFilesError;
extern NSString *const OPTLYLoggerMessagesDataStoreFileManagerRemoveFileForDataTypeError;
extern NSString *const OPTLYLoggerMessagesDataStoreFileManagerRemoveFilesForDataTypeError;
extern NSString *const OPTLYLoggerMessagesDataStoreFileManagerSaveFile;

// ---- Datafile Manager ----
// debug
extern NSString *const OPTLYLoggerMessagesDatafileManagerDatafileNotDownloadedInvalidStatusCode;
extern NSString *const OPTLYLoggerMessagesDatafileManagerDatafileNotDownloadedError;
extern NSString *const OPTLYLoggerMessagesDatafileManagerDatafileNotDownloadedNoChanges;
extern NSString *const OPTLYLoggerMessagesDatafileManagerLastModifiedDate;
extern NSString *const OPTLYLoggerMessagesDatafileManagerLastModifiedDateFound;
extern NSString *const OPTLYLoggerMessagesDatafileManagerLastModifiedDateNotFound;
// info
extern NSString *const OPTLYLoggerMessagesDatafileManagerDatafileDownloaded;
extern NSString *const OPTLYLoggerMessagesDatafileManagerDatafileDownloading;
extern NSString *const OPTLYLoggerMessagesDatafileManagerDatafileSaved;

// Datafile Manager Builder
// warning
extern NSString *const OPTLYLoggerMessagesDatafileManagerInitializedWithoutProjectIdMessage;
// error
extern NSString *const OPTLYLoggerMessagesDatafileFetchIntervalInvalid;

// ---- Datafile Versioning ----
// warning
extern NSString *const OPTLYLoggerMessagesDatafileVersion;

// ---- Event Builder ----
// debug
extern NSString *const OPTLYLoggerMessagesAttributeInvalidFormat;
extern NSString *const OPTLYLoggerMessagesAttributeValueInvalidFormat;
extern NSString *const OPTLYLoggerMessagesEventNotAssociatedWithExperiment;
extern NSString *const OPTLYLoggerMessagesExperimentNotPartOfEvent;
// warning
extern NSString *const OPTLYLoggerMessagesEventKeyInvalid;
extern NSString *const OPTLYLoggerMessagesUserIdInvalid;
extern NSString *const OPTLYLoggerMessagesVariationIdInvalid;
extern NSString *const OPTLYLoggerMessagesEventNotPassAudienceEvaluation;
extern NSString *const OPTLYLoggerMessagesRevenueValueFloat;
extern NSString *const OPTLYLoggerMessagesRevenueValueString;
extern NSString *const OPTLYLoggerMessagesRevenueValueIntegerOverflow;
extern NSString *const OPTLYLoggerMessagesRevenueValueFloatOverflow;
extern NSString *const OPTLYLoggerMessagesRevenueValueInvalidBoolean;
extern NSString *const OPTLYLoggerMessagesRevenueValueInvalid;
extern NSString *const OPTLYLoggerMessagesNumericValueString;
extern NSString *const OPTLYLoggerMessagesNumericValueInvalidBoolean;
extern NSString *const OPTLYLoggerMessagesNumericValueInvalidFloat;
extern NSString *const OPTLYLoggerMessagesNumericValueInvalidString;
extern NSString *const OPTLYLoggerMessagesNumericValueInvalid;
extern NSString *const OPTLYLoggerMessagesEventTagValueInvalid;

// ---- Event Dispatcher ----
// info
extern NSString *const OPTLYLoggerMessagesEventDispatcherActivationFailure;
extern NSString *const OPTLYLoggerMessagesEventDispatcherEventNotTracked;
extern NSString *const OPTLYLoggerMessagesEventDispatcherAttemptingToSendConversionEvent;
extern NSString *const OPTLYLoggerMessagesEventDispatcherAttemptingToSendImpressionEvent;
extern NSString *const OPTLYLoggerMessagesEventDispatcherTrackingSuccess;
extern NSString *const OPTLYLoggerMessagesEventDispatcherActivationSuccess;
// warning
extern NSString *const OPTLYLoggerMessagesEventDispatcherInvalidInterval;

// debug
extern NSString *const OPTLYLoggerMessagesEventDispatcherProperties;
extern NSString *const OPTLYLoggerMessagesEventDispatcherNetworkTimerEnabled;
extern NSString *const OPTLYLoggerMessagesEventDispatcherNetworkTimerDisabled;
extern NSString *const OPTLYLoggerMessagesEventDispatcherFlushingEvents;
extern NSString *const OPTLYLoggerMessagesEventDispatcherFlushEventsNoEvents;
extern NSString *const OPTLYLoggerMessagesEventDispatcherFlushEventsMax;
extern NSString *const OPTLYLoggerMessagesEventDispatcherFlushingSavedEvents;
extern NSString *const OPTLYLoggerMessagesEventDispatcherFlushSavedEventsNoEvents;
extern NSString *const OPTLYLoggerMessagesEventDispatcherDispatchFailed;
extern NSString *const OPTLYLoggerMessagesEventDispatcherPendingEvent;
extern NSString *const OPTLYLoggerMessagesEventDispatcherEventSaved;
extern NSString *const OPTLYLoggerMessagesEventDispatcherRemovedEvent;
extern NSString *const OPTLYLoggerMessagesEventDispatcherInvalidEvent;

// error

// ---- Manager ----
// error
extern NSString *const OPTLYLoggerMessagesManagerBuilderBlockNotValid;
extern NSString *const OPTLYLoggerMessagesManagerBuilderNotValid;
extern NSString *const OPTLYLoggerMessagesManagerDatafileManagerDoesNotConformToOPTLYDatafileManagerProtocol;
extern NSString *const OPTLYLoggerMessagesManagerErrorHandlerDoesNotConformToOPTLYErrorHandlerProtocol;
extern NSString *const OPTLYLoggerMessagesManagerEventDispatcherDoesNotConformToOPTLYEventDispatcherProtocol;
extern NSString *const OPTLYLoggerMessagesManagerLoggerDoesNotConformToOPTLYLoggerProtocol;
extern NSString *const OPTLYLoggerMessagesManagerMustBeInitializedWithProjectId;
extern NSString *const OPTLYLoggerMessagesManagerProjectIdCannotBeEmptyString;
extern NSString *const OPTLYLoggerMessagesManagerInit;
extern NSString *const OPTLYLoggerMessagesManagerInitWithCallback;
extern NSString *const OPTLYLoggerMessagesManagerInitWithCallbackErrorDatafileDownload;
extern NSString *const OPTLYLoggerMessagesManagerInitWithCallbackNoDatafileUpdates;
extern NSString *const OPTLYLoggerMessagesManagerBundledDataLoaded;

// ---- Project Config Getters ----
// debug
extern NSString *const OPTLYLoggerMessagesAttributeUnknownForAttributeKey;
extern NSString *const OPTLYLoggerMessagesAudienceUnknownForAudienceId;
extern NSString *const OPTLYLoggerMessagesEventIdUnknownForEventKey;
extern NSString *const OPTLYLoggerMessagesEventUnknownForEventKey;
extern NSString *const OPTLYLoggerMessagesExperimentIdUnknownForExperimentKey;
extern NSString *const OPTLYLoggerMessagesExperimentUnknownForExperimentId;
extern NSString *const OPTLYLoggerMessagesExperimentUnknownForExperimentKey;
extern NSString *const OPTLYLoggerMessagesFeatureFlagUnknownForFeatureFlagKey;
extern NSString *const OPTLYLoggerMessagesVariableUsageUnknownForVariableId;
extern NSString *const OPTLYLoggerMessagesRolloutUnknownForRolloutId;
extern NSString *const OPTLYLoggerMessagesGroupUnknownForGroupId;
extern NSString *const OPTLYLoggerMessagesGetVariationNilVariation;
extern NSString *const OPTLYLoggerMessagesVariationKeyUnknownForExperimentKey;
extern NSString *const OPTLYLoggerMessagesProjectConfigUserIdInvalid;
extern NSString *const OPTLYLoggerMessagesProjectConfigExperimentKeyInvalid;
extern NSString *const OPTLYLoggerMessagesProjectConfigVariationKeyInvalid;
extern NSString *const OPTLYLoggerMessagesAttributeIsReserved;
extern NSString *const OPTLYLoggerMessagesAttributeNotFound;

// ---- User Profile ----
// debug
extern NSString *const OPTLYLoggerMessagesUserProfileBucketerUserDataRetrieved;
extern NSString *const OPTLYLoggerMessagesUserProfileAttemptToSaveVariation;
extern NSString *const OPTLYLoggerMessagesUserProfileNoVariation;
extern NSString *const OPTLYLoggerMessagesUserProfileRemoveVariation;
extern NSString *const OPTLYLoggerMessagesUserProfileRemoveVariationNotFound;
extern NSString *const OPTLYLoggerMessagesUserProfileServiceSaved;
extern NSString *const OPTLYLoggerMessagesUserProfileVariation;
extern NSString *const OPTLYLoggerMessagesUserProfileNotExist;
// warning
extern NSString *const OPTLYLoggerMessagesUserProfileUnableToSaveVariation;
extern NSString *const OPTLYLoggerMessagesUserProfileVariationNoLongerInDatafile;
extern NSString *const OPTLYLoggerMessagesUserProfileSaveInvalidUserId;
extern NSString *const OPTLYLoggerMessagesUserProfileLookupInvalidFormat;
extern NSString *const OPTLYLoggerMessagesUserProfileSaveInvalidFormat;

// ---- Decision Service ----
extern NSString *const OPTLYLoggerMessagesDecisionServiceExperimentNotRunning;
extern NSString *const OPTLYLoggerMessagesDecisionServiceFailAudienceTargeting;
extern NSString *const OPTLYLoggerMessagesDecisionServiceSavedVariationInvalid;
extern NSString *const OPTLYLoggerMessagesDecisionServiceUserProfileNotExist;
extern NSString *const OPTLYLoggerMessagesDecisionServiceSavedVariationParseError;
extern NSString *const OPTLYLoggerMessagesDecisionServiceGetVariationParseError;
extern NSString *const OPTLYLoggerMessagesDecisionServiceReplaceBucketEntity;
extern NSString *const OPTLYLoggerMessagesDecisionServiceSettingTheBucketingID;
// FF = Feature Flag
extern NSString *const OPTLYLoggerMessagesDecisionServiceFFNotUsed;
extern NSString *const OPTLYLoggerMessagesDecisionServiceFFUserBucketed;
extern NSString *const OPTLYLoggerMessagesDecisionServiceFFUserNotBucketed;
// FF = Feature Rollout
extern NSString *const OPTLYLoggerMessagesDecisionServiceFRNotUsed;
extern NSString *const OPTLYLoggerMessagesDecisionServiceFRUserBucketed;
extern NSString *const OPTLYLoggerMessagesDecisionServiceFRUserExcluded;
extern NSString *const OPTLYLoggerMessagesDecisionServiceFRUserNotBucketed;
extern NSString *const OPTLYLoggerMessagesDecisionServiceUserBucketed;
extern NSString *const OPTLYLoggerMessagesDecisionServiceUserNotBucketed;
extern NSString *const OPTLYLoggerMessagesDecisionServiceUserInVariation;
extern NSString *const OPTLYLoggerMessagesDecisionServiceGroupIdNotFound;
extern NSString *const OPTLYLoggerMessagesDecisionServiceGroupUnknownForGroupId;

// ---- HTTP Request Manager ----
// Debug (not through logger handler)
extern NSString *const OPTLYHTTPRequestManagerGETWithParametersAttempt;
extern NSString *const OPTLYHTTPRequestManagerGETIfModifiedSince;
extern NSString *const OPTLYHTTPRequestManagerPOSTWithParameters;
extern NSString *const OPTLYHTTPRequestManagerBackoffRetryStates;

// ---- Audience Evaluator ----
// info
extern NSString *const OPTLYLoggerMessagesAudienceEvaluatorEvaluationCompletedWithResult;
extern NSString *const OPTLYLoggerMessagesAudienceEvaluatorExperimentEvaluationCompletedWithResult;
// warning
extern NSString *const OPTLYLoggerMessagesAudienceEvaluatorConditionEvaluatedAsUnknownForUnexpectedType;
extern NSString *const OPTLYLoggerMessagesAudienceEvaluatorUnknownMatchType;
extern NSString *const OPTLYLoggerMessagesAudienceEvaluatorUnknownConditionType;
extern NSString *const OPTLYLoggerMessagesAudienceEvaluatorUnsupportedValueType;
// debug
extern NSString *const OPTLYLoggerMessagesAudienceEvaluatorEvaluationStartedWithConditions;
extern NSString *const OPTLYLoggerMessagesAudienceEvaluatorEvaluationStartedForExperiment;
extern NSString *const OPTLYLoggerMessagesAudienceEvaluatorConditionEvaluatedAsUnknownForMissingAttribute;
extern NSString *const OPTLYLoggerMessagesAudienceEvaluatorConditionEvaluatedAsUnknownForUnexpectedTypeNull;
extern NSString *const OPTLYLoggerMessagesAudienceEvaluatorConditionEvaluatedAsUnknownForUnexpectedTypeNanInfinity;
// error

@interface OPTLYLoggerMessages : NSObject

@end
