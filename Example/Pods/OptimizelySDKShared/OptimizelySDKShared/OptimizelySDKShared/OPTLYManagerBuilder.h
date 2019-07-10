/****************************************************************************
 * Copyright 2016-2017, Optimizely, Inc. and contributors                   *
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

@protocol OPTLYDatafileManager, OPTLYErrorHandler, OPTLYEventDispatcher, OPTLYLogger, OPTLYUserProfileService;
@class OPTLYManagerBuilder;

typedef void (^OPTLYManagerBuilderBlock)(OPTLYManagerBuilder * _Nullable builder);

@interface OPTLYManagerBuilder : NSObject

/// The default datafile to initialize an Optimizely Client with before polling the CDN for a datafile
@property (nonatomic, readwrite, strong, nullable) NSData *datafile;
/// The dispatch interval for the event dispatcher.
@property (nonatomic, readwrite) NSTimeInterval eventDispatchInterval;
/// The ID of the Optimizely Project the manager will oversee
@property (nonatomic, readwrite, strong, nullable) NSString *projectId;
/// The ID of the Optimizely Project SDK key the manager will oversee
@property (nonatomic, readwrite, strong, nullable) NSString *sdkKey;
/// The datafile manager to be used for the manager
@property (nonatomic, readwrite, strong, nonnull) id<OPTLYDatafileManager> datafileManager;
/// The error handler to be used for the manager, client, and all subcomponents
@property (nonatomic, readwrite, strong, nullable) id<OPTLYErrorHandler> errorHandler;
/// The event dispatcher to initialize an Optimizely Client with
@property (nonatomic, readwrite, strong, nullable) id<OPTLYEventDispatcher> eventDispatcher;
/// The logger to be used for the manager, client, and all subcomponents
@property (nonatomic, readwrite, strong, nullable) id<OPTLYLogger> logger;
/// User profile to be used by the client to store user-specific data.
@property (nonatomic, readwrite, strong, nullable) id<OPTLYUserProfileService> userProfileService;

/// init is disabled. Please use builderWithBlock to create a Manager Builder
- (nonnull instancetype)init NS_UNAVAILABLE;
/// Create the Optimizely Manager Builder object.
+ (nullable instancetype)builderWithBlock:(nonnull OPTLYManagerBuilderBlock)block;

@end
