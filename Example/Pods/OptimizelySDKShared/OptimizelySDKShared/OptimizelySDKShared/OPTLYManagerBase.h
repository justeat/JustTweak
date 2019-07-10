/****************************************************************************
 * Copyright 2016-2018, Optimizely, Inc. and contributors                   *
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

extern NSString * _Nonnull const OptimizelyAppVersionKey;
extern NSString * _Nonnull const OptimizelyDeviceModelKey;
extern NSString * _Nonnull const OptimizelyOSVersionKey;
extern NSString * _Nonnull const OptimizelySDKVersionKey;

extern NSString * _Nonnull const OptimizelyBundleDatafilePrefix;
extern NSString * _Nonnull const OptimizelyBundleDatafileFileTypeExtension;

@class OPTLYClient, OPTLYDatafileConfig, OPTLYManagerBuilder;
@protocol OPTLYDatafileManager, OPTLYErrorHandler, OPTLYEventDispatcher, OPTLYLogger, OPTLYUserProfileService;

typedef void (^OPTLYManagerBuilderBlock)(OPTLYManagerBuilder * _Nullable builder);

@protocol OPTLYManager
/**
 * Init with builder block
 * @param builderBlock The Optimizely Manager Builder Block where datafile manager, event dispatcher, and other configurations will be set.
 * @return OptimizelyManager instance
 */
+ (nullable instancetype)init:(nonnull OPTLYManagerBuilderBlock)builderBlock;
@end

@interface OPTLYManagerBase : NSObject
{
@protected
    NSString *_clientEngine;
    NSString *_clientVersion;
}

/// The ID of the Optimizely Project the manager will oversee
@property (nonatomic, readwrite, strong, nullable) NSString *projectId;
/// The ID of the Optimizely Project SDK key the manager will oversee
@property (nonatomic, readwrite, strong, nullable) NSString *sdkKey;
// The wrapper for project id and sdk key
@property (nonatomic, readwrite, strong, nullable) OPTLYDatafileConfig* datafileConfig;
/// The default datafile to initialize an Optimizely Client with
@property (nonatomic, readwrite, strong, nullable) NSData *datafile;
/// The datafile manager that will download the datafile for the manager
@property (nonatomic, readwrite, strong, nullable) id<OPTLYDatafileManager> datafileManager;
/// The error handler to be used for the manager, client, and all subcomponents
@property (nonatomic, readwrite, strong, nullable) id<OPTLYErrorHandler> errorHandler;
/// The event dispatcher to initialize an Optimizely Client with
@property (nonatomic, readwrite, strong, nullable) id<OPTLYEventDispatcher> eventDispatcher;
/// The logger to be used for the manager, client, and all subcomponents
@property (nonatomic, readwrite, strong, nullable) id<OPTLYLogger> logger;
/// User profile to be used by the client to store user-specific data.
@property (nonatomic, readwrite, strong, nullable) id<OPTLYUserProfileService> userProfileService;
/// The client engine
@property (nonatomic, readonly, strong, nonnull) NSString *clientEngine;
/// Version number of the Optimizely iOS SDK
@property (nonatomic, readonly, strong, nonnull) NSString *clientVersion;
/// iOS Device Model
@property (nonatomic, readonly, strong, nonnull) NSString *deviceModel;
/// iOS OS Version
@property (nonatomic, readonly, strong, nonnull) NSString *osVersion;
/// iOS App Version
@property (nonatomic, readonly, strong, nonnull) NSString *appVersion;


/**
 * Synchronously initializes the client using the latest
 * cached datafile with a fallback of the bundled datafile
 * (i.e., the datafile provided in the OPTLYManagerBuilder
 * during the manager initialization).
 *
 * If the cached datafile fails to load, the bundled datafile
 * is used.
 *
 */
- (nullable OPTLYClient *)initialize;

/**
 * Asynchronously initializes the client using the latest
 * downloaded datafile with a fallback of the bundled datafile
 * (i.e., the datafile provided in the OPTLYManagerBuilder
 * during the manager initialization).
 *
 * In the case that there is an error in the datafile download,
 *  the latest cached datafile (if one exists) is used.
 *
 * If there are no updates in the datafile, then the datafile is not
 *  downloaded and the latest cached datafile is used.
 *
 * If the cached datafile fails to load, the bundled datafile
 *  is used.
 *
 * @param callback The block called following the initialization
 *   of the client.
 */
- (void)initializeWithCallback:(void(^ _Nullable)(NSError * _Nullable error,
                                      OPTLYClient * _Nullable client))callback;

/**
 * Synchronously instantiates the client from the provided datafile
 * with no fallbacks. If the datafile is invalid, then a dummy client instance
 * will be returned (i.e., all method calls on the client will be NoOps).
 *
 * @param datafile The datafile used to instantiate the client.
 */
- (nullable OPTLYClient *)initializeWithDatafile:(nonnull NSData *)datafile;

/*
 * Gets the cached Optimizely client.
 */
- (nullable OPTLYClient *)getOptimizely;
@end
