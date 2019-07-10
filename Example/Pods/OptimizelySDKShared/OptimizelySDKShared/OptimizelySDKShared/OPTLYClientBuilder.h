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

#import <Foundation/Foundation.h>

@class Optimizely, OPTLYProjectConfig, OPTLYBucketer, OPTLYEventBuilder, OPTLYEventBuilderDefault;
@protocol OPTLYErrorHandler, OPTLYEventBuilder, OPTLYEventDispatcher, OPTLYLogger, OPTLYUserProfileService;

/**
 * This class contains the informaation on how your Optimizely Client instance will be built.
 */
@class OPTLYClientBuilder;

/// This is a block that takes the builder values.
typedef void (^OPTLYClientBuilderBlock)(OPTLYClientBuilder * _Nonnull builder);

@interface OPTLYClientBuilder : NSObject

/// Reference to the Optimizely Core instance
@property (nonatomic, readonly, strong, nullable) Optimizely *optimizely;
/// A datafile is required to create an Optimizely object.
@property (nonatomic, readwrite, strong, nullable) NSData *datafile;
/// The error handler is by default set to one that is created by Optimizely. This default error handler can be overridden by any object that conforms to the OPTLYErrorHandler protocol.
@property (nonatomic, readwrite, strong, nullable) id<OPTLYErrorHandler> errorHandler;
/// The event dispatcher is by default set to one that is created by Optimizely. This default event dispatcher can be overridden by any object that conforms to the OPTLYEventDispatcher protocol.
@property (nonatomic, readwrite, strong, nullable) id<OPTLYEventDispatcher> eventDispatcher;
/// The logger is by default set to one that is created by Optimizely. This default logger can be overridden by any object that conforms to the OPTLYLogger protocol.
@property (nonatomic, readwrite, strong, nullable) id<OPTLYLogger> logger;
/// User profile to be used by the Optimizely instance to store user-specific data.
@property (nonatomic, readwrite, strong, nullable) id<OPTLYUserProfileService> userProfileService;
/// The client version
@property (nonatomic, strong, nonnull) NSString *clientVersion;
/// The client engine
@property (nonatomic, strong, nonnull) NSString *clientEngine;

/// Create an Optimizely Client object.
+ (nonnull instancetype)builderWithBlock:(nonnull OPTLYClientBuilderBlock)block;

@end
