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
#ifdef UNIVERSAL
    #import "OptimizelySDKShared.h"
#else
    #import <OptimizelySDKShared/OptimizelySDKShared.h>
#endif

/**
 * This class contains details related to how the Optimizely Event Dispatcher instance is built.
 */

@class OPTLYEventDispatcherBuilder;

/// This is a block that takes the builder values.
typedef void (^OPTLYEventDispatcherBuilderBlock)(OPTLYEventDispatcherBuilder * _Nullable builder);

@interface OPTLYEventDispatcherBuilder : NSObject

/**
* Initializer for Optimizely Event Dispatcher Builder object
*
* @param block The builder block with which to initialize the Optimizely Event Dispatcher Builder object
* @return An instance of OPTLYEventDispatcherBuilder
*/
+ (nullable instancetype)builderWithBlock:(nonnull OPTLYEventDispatcherBuilderBlock)block;

/// The interval at which the SDK will attempt to dispatch any events remaining in our events queue
@property (nonatomic, assign, readwrite) NSInteger eventDispatcherDispatchInterval;
/// Max number of events to store before overwriting older events (value must be greater than 1)
@property (nonatomic, assign) NSInteger maxNumberOfEventsToSave;
/// Logger provided by the user
@property (nonatomic, strong, nullable) id<OPTLYLogger> logger;

@end
