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

@protocol OPTLYLogger;

@interface OPTLYUserProfileServiceBuilder : NSObject

/// This is a block that takes the builder values.
typedef void (^OPTLYUserProfileServiceBuilderBlock)(OPTLYUserProfileServiceBuilder * _Nullable builder);

/**
 * Initializer for Optimizely User Profile Builder object
 *
 * @param block The builder block with which to initialize the Optimizely User Profile Builder object
 * @return An instance of OPTYUserProfileBuilder
 */
+ (nullable instancetype)builderWithBlock:(nonnull OPTLYUserProfileServiceBuilderBlock)block;

/// Logger provided by the user
@property (nonatomic, strong, nullable) id<OPTLYLogger> logger;
@end
