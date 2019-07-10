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

/*
    This class contains all the error messages that will be called by the SDK.
    This class does not include the NSException errors that may also be thrown by the OS.
 */

#import <Foundation/Foundation.h>

extern NSString * const OPTLYErrorHandlerMessagesDomain;

extern NSString * const OPTLYErrorHandlerMessagesDataFileInvalid;
extern NSString * const OPTLYErrorHandlerMessagesDataFileVersionInvalid;
extern NSString * const OPTLYErrorHandlerMessagesEventDispatcherInvalid;
extern NSString * const OPTLYErrorHandlerMessagesLoggerInvalid;
extern NSString * const OPTLYErrorHandlerMessagesErrorHandlerInvalid;
extern NSString * const OPTLYErrorHandlerMessagesExperimentUnknown;
extern NSString * const OPTLYErrorHandlerMessagesEventUnknown;
extern NSString * const OPTLYErrorHandlerMessagesBuilderInvalid;
extern NSString * const OPTLYErrorHandlerMessagesEventNoExperimentAssociation;
extern NSString * const OPTLYErrorHandlerMessagesBucketingIdInvalid;
extern NSString * const OPTLYErrorHandlerMessagesAttributeUnknown;
extern NSString * const OPTLYErrorHandlerMessagesAttributeFormatInvalid;
extern NSString * const OPTLYErrorHandlerMessagesGroupInvalid;
extern NSString * const OPTLYErrorHandlerMessagesVariationUnknown;
extern NSString * const OPTLYErrorHandlerMessagesEventTypeUnknown;
extern NSString * const OPTLYErrorHandlerMessagesUserProfileInvalid;

extern NSString * const OPTLYErrorHandlerMessagesTrafficAllocationNotInRange;
extern NSString * const OPTLYErrorHandlerMessagesBucketingIdInvalid;
extern NSString * const OPTLYErrorHandlerMessagesTrafficAllocationUnknown;
extern NSString * const OPTLYErrorHandlerMessagesEventDispatchFailed;
extern NSString * const OPTLYErrorHandlerMessagesConfigInvalid;

extern NSString * const OPTLYErrorHandlerMessagesManagerBuilderInvalid;

extern NSString *const OPTLYErrorHandlerMessagesDataStoreDatabaseNoSavedEvents;
extern NSString *const OPTLYErrorHandlerMessagesDataStoreDatabaseNoDataToSave;
extern NSString *const OPTLYErrorHandlerMessagesDataStoreInvalidDataStoreEntityValue;
extern NSString *const OPTLYErrorHandlerMessagesHTTPRequestManagerPOSTRetryFailure;
extern NSString *const OPTLYErrorHandlerMessagesHTTPRequestManagerGETRetryFailure;
extern NSString *const OPTLYErrorHandlerMessagesHTTPRequestManagerGETIfModifiedFailure;
extern NSString *const OPTLYErrorHandlerMessagesProjectConfigInvalidAudienceCondition;


typedef NS_ENUM(NSUInteger, OPTLYErrorTypes) {
    OPTLYErrorTypesDatafileInvalid = 0,
    OPTLYErrorTypesDataUnknown,
    OPTLYErrorTypesConfigInvalid,
    OPTLYErrorTypesLoggerInvalid,
    OPTLYErrorTypesErrorHandlerInvalid,
    OPTLYErrorTypesBuilderInvalid,
    OPTLYErrorTypesDatabase,
    OPTLYErrorTypesDataStore,
    OPTLYErrorTypesUserProfile,
    OPTLYErrorTypesEventDispatch,
    OPTLYErrorTypesEventTrack,
    OPTLYErrorTypesUserActivate,
    OPTLYErrorTypesHTTPRequestManager,
};

@interface OPTLYErrorHandlerMessages : NSObject

@end
