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
#import "OPTLYDataStore.h"

@class OPTLYLogger;

/**
 * Any type of event data storage must implement these following methods.
 */
@protocol OPTLYEventDataStore <NSObject>

/**
 * Initialize a new Optimizely data store instance
 *
 * @param baseDir The base directory to store the events
 * @param error An error object is returned if an error occurs.
 */
- (nullable instancetype)initWithBaseDir:(nonnull NSString *)baseDir
                                   error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
 * Saves Data
 * @param data The data to be saved.
 * @param eventTypeName The name of the event type of the data that needs to be saved.
 * @param error An error object is returned if an error occurs.
 */
- (BOOL)saveEvent:(nonnull NSDictionary *)data
        eventType:(nonnull NSString *)eventTypeName
            error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
 * Gets the first N entries (i.e., the N oldest events).
 *
 * @param numberOfEvents The number of events to retrieve.
 * @param eventTypeName The name of the event type of the data that needs to be removed.
 * @param error An error object is returned if an error occurs.
 */
- (nullable NSArray *)getFirstNEvents:(NSInteger)numberOfEvents
                            eventType:(nonnull NSString *)eventTypeName
                                error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
 * Gets the last entry id.
 *
 * @param eventTypeName The name of the event type of the data that needs to be removed.
 * @param error An error object is returned if an error occurs.
 */
- (NSInteger)getLastEventId:(nonnull NSString *)eventTypeName
                      error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
 * Deletes the first N events (i.e., the N oldest events).
 *
 * @param numberOfEvents The number of events to retrieve.
 * @param eventTypeName The name of The name of the event type of the data that needs to be removed.
 * @param error An error object is returned if an error occurs.
 */
- (BOOL)removeFirstNEvents:(NSInteger)numberOfEvents
                 eventType:(nonnull NSString *)eventTypeName
                     error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
 * Removes an event
 *
 * @param event The event to remove
 * @param eventTypeName The name of The name of the event type of the data that needs to be removed.
 * @param error An error object is returned if an error occurs.
 */
- (BOOL)removeEvent:(nonnull NSDictionary *)event
          eventType:(nonnull NSString *)eventTypeName
              error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
 * Returns the number of saved events.
 *
 * @param eventTypeName The name of the event type of the data.
 * @param error An error object is returned if an error occurs.
 * @return The number of events saved.
 */
- (NSInteger)numberOfEvents:(nonnull NSString *)eventTypeName
                      error:(NSError * _Nullable __autoreleasing * _Nullable)error;
@end

#if TARGET_OS_IOS
@interface OPTLYEventDataStoreiOS : NSObject<OPTLYEventDataStore>
@end
#endif

#if TARGET_OS_TV
@interface OPTLYEventDataStoreTVOS : NSObject<OPTLYEventDataStore>
@end
#endif
