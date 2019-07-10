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

@class OPTLYProjectConfig;

@protocol OPTLYEventDispatcher <NSObject>

/**
 * Dispatch an impression event.
 * @param params Dictionary of the event parameter values
 * @param callback The completion handler
 */

- (void)dispatchImpressionEvent:(nonnull NSDictionary *)params
                       callback:(nullable void(^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))callback;

/**
 * Dispatch a conversion event.
 * @param params Dictionary of the event parameter values
 * @param callback The completion handler
 */
- (void)dispatchConversionEvent:(nonnull NSDictionary *)params
                       callback:(nullable void(^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))callback;

@end

@interface OPTLYEventDispatcherUtility : NSObject
/**
 * Utility method to check if a class conforms to the OPTLYEventDispatcher protocol
 * This method uses compile and run time checks
 */
+ (BOOL)conformsToOPTLYEventDispatcherProtocol:(nonnull Class)instanceClass;
@end

/**
 * OPTLYEventDispatcherBasic is a very simple implementation of the OPTLYEventDispatcher protocol.
 * It dispatches events without any failure mechanisms (e.g., events are not queued up for a loater 
 * retry.
 */
@interface OPTLYEventDispatcherBasic : NSObject <OPTLYEventDispatcher>
@end

/**
 * OPTLYEventDispatcherNoOp comforms to the OPTLYEventDispatcher protocol,
 * but all methods perform a no op.
 */
@interface OPTLYEventDispatcherNoOp : NSObject<OPTLYEventDispatcher>
@end
