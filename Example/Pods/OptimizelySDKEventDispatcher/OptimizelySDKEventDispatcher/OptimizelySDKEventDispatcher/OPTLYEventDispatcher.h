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
#import <UIKit/UIKit.h>
#ifdef UNIVERSAL
    #import "OptimizelySDKShared.h"
    #import "OptimizelySDKCore.h"
    #import "OPTLYEventDataStore.h"
#else
    #import <OptimizelySDKShared/OptimizelySDKShared.h>
    #import <OptimizelySDKCore/OptimizelySDKCore.h>
#endif
#import "OPTLYEventDispatcherBuilder.h"

/*
 * This class handles the dispatching of the two Optimizely events:
 *   - Impression Event
 *   - Conversion Event
 * The events are dispatched immediately and are only saved if the dispatch fails.
 * The saved events will be dispatched again opportunistically in the following cases:
 *   - Another event dispatch is called
 *   - The app enters the background or foreground
 */

// Default dispatch interval if not set by users
extern NSInteger const OPTLYEventDispatcherDefaultDispatchIntervalTime_s;
// The max number of events that can be flushed at a time
extern NSInteger const OPTLYEventDispatcherMaxDispatchEventBatchSize;
// The max number of times flush events are attempted
extern NSInteger const OPTLYEventDispatcherMaxFlushEventAttempts;
// Default max number of events to store before overwriting older events
extern NSInteger const OPTLYEventDispatcherDefaultMaxNumberOfEventsToSave;

@protocol OPTLYEventDispatcher;

typedef void (^OPTLYEventDispatcherResponse)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);

@interface OPTLYEventDispatcherDefault : NSObject <OPTLYEventDispatcher>

/// The interval at which the SDK will attempt to dispatch any events remaining in our events queue (in ms)
@property (nonatomic, assign, readonly) NSInteger eventDispatcherDispatchInterval;

/// Max number of events to store before overwriting older events (value must be greater than 1)
@property (nonatomic, assign, readonly) NSInteger maxNumberOfEventsToSave;

/// Logger provided by the user
@property (nonatomic, strong, nullable) id<OPTLYLogger> logger;


/**
 * Initializer for Optimizely Event Dispatcher object
 *
 * @param builderBlock The builder block with which to initialize the Optimizely Event Dispatcher object
 * @return An instance of OPTLYEventDispatcher
 */
+ (nullable instancetype)init:(nonnull OPTLYEventDispatcherBuilderBlock)builderBlock
__attribute((deprecated("Use OPTLYEventDispatcherDefault initWithBuilder method instead.")));

/**
 * Initializer for Optimizely Event Dispatcher object
 *
 * @param builder The OPTLYEventDispatcherBuilder object with which to initialize the Optimizely Event Dispatcher object
 * @return An instance of OPTLYEventDispatcher
 */
- (nullable instancetype)initWithBuilder:(nullable OPTLYEventDispatcherBuilder *)builder;

/**
 * Dispatch an impression event.
 * @param params Dictionary of the event parameter values
 * @param callback The completion handler
 */

- (void)dispatchImpressionEvent:(nonnull NSDictionary *)params
                       callback:(nullable OPTLYEventDispatcherResponse)callback;

/**
 * Dispatch a conversion event.
 * @param params Dictionary of the event parameter values
 * @param callback The completion handler
 */
- (void)dispatchConversionEvent:(nonnull NSDictionary *)params
                       callback:(nullable OPTLYEventDispatcherResponse)callback;

/**
 * Flush all events in queue (cached and saved).
 */
- (void)flushEvents;

@end
