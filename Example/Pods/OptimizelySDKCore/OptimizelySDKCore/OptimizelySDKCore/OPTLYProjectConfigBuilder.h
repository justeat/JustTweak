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

/**
 * This class contains details related to how the Optimizely Project Config instance is built.
 */

@class OPTLYProjectConfigBuilder;
@protocol OPTLYErrorHandler, OPTLYLogger, OPTLYUserProfileService;

/// This is a block that takes the builder values.
typedef void (^OPTLYProjectConfigBuilderBlock)(OPTLYProjectConfigBuilder * _Nullable builder);

@interface OPTLYProjectConfigBuilder : NSObject

/**
 * Initializer for Optimizely Project Config Builder object
 *
 * @param block The builder block with which to initialize the Optimizely Project Config Builder object
 * @return An instance of OPTLYProjectConfigBuilder
 */
+ (nullable instancetype)builderWithBlock:(nonnull OPTLYProjectConfigBuilderBlock)block;

/// optional error handler
@property (nonatomic, strong, nullable) id<OPTLYErrorHandler> errorHandler;
/// optional logger
@property (nonatomic, strong, nullable) id<OPTLYLogger> logger;
/// optional user profile
@property (nonatomic, strong, nullable) id<OPTLYUserProfileService> userProfileService;
/// the non optional datafile contents
@property (nonatomic, strong, nonnull) NSData *datafile;
/// The client version
@property (nonatomic, strong, nonnull) NSString *clientVersion;
/// The client engine
@property (nonatomic, strong, nonnull) NSString *clientEngine;


@end
