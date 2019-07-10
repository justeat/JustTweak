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

// The percentage of events that are removed if the events queue reaches the max capacity
extern NSInteger const OPTLYDataStorePercentageOfEventsToRemoveUponOverflow;

@protocol OPTLYLogger;

// If adding event type, update: stringForDataTypeEnum
typedef NS_ENUM(NSUInteger, OPTLYDataStoreDataType)
{
    OPTLYDataStoreDataTypeDatabase,
    OPTLYDataStoreDataTypeDatafile,
    OPTLYDataStoreDataTypeEventDispatcher,
    OPTLYDataStoreDataTypeUserProfile,
    OPTLYDataStoreDataTypeUserProfileService,
    OPTLYDataStoreDataTypeCOUNT
};

// If adding data store data type, update: removeSavedEvents, totalNumberOfEvents
typedef NS_ENUM(NSUInteger, OPTLYDataStoreEventType)
{
    OPTLYDataStoreEventTypeImpression,
    OPTLYDataStoreEventTypeConversion,
    OPTLYDataStoreEventTypeCOUNT
};

@class OPTLYFileManager;

/*
 * This class handles all Optimizely-related data persistence and caching.
 * Data is persisted for the following purposes:
 *      - NSFileManager for datafile
 *      - SQLite table (or in-memory queue) for events
 *      - NSUserDefault for user data (e.g., bucketing info).
 */
@interface OPTLYDataStore : NSObject

/// Max number of events to store before overwriting older events
@property (nonatomic, assign) NSInteger maxNumberOfEventsToSave;
/// Base directory where Optimizely-related data will persist
@property (nonatomic, strong, readonly, nonnull) NSString *baseDirectory;
/// Optional logger for data store logging
@property (nonatomic, strong, nullable) id<OPTLYLogger> logger;


/**
 * Instantiates the data store as a singleton object
 */
+ (nullable instancetype)dataStore;

/**
 * Wipes all Optimizely data
 *
 **/
- (BOOL)removeAll:(NSError * _Nullable __autoreleasing * _Nullable)error;

// -------- File Storage --------
// Persists data in a file format using NSFileManager.
// iOS documents are written in the Library directory.
// tvOS documents are written in the Temporary directory.

/**
 * Saves a file.
 * If a file of the same name type exists already, then that file will be overwritten.
 *
 * @param fileName A string that represents the name of the file to save.
 *  Can include a file suffix if desired (e.g., .txt or .json).
 * @param data The data to save to the file.
 * @param dataType The type of file (e.g., datafile, user profile, event dispatcher, etc.)
 * @param error An error object which will store any errors if the file save fails.
 *  If error is nil, than the file save was successful.
 *
 **/
- (BOOL)saveFile:(nonnull NSString *)fileName
            data:(nonnull NSData *)data
            type:(OPTLYDataStoreDataType)dataType
           error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
 * Gets a file.
 *
 * @param fileName A string that represents the name of the file to retrieve.
 * @param dataType The type of file (e.g., datafile, user profile, event dispatcher, etc.)
 * @return The file in NSData format.
 * @param error An error object which will store any errors if the file save fails.
 *  If error is nil, than the file save was successful.
 *
 **/
- (nullable NSData *)getFile:(nonnull NSString *)fileName
                        type:(OPTLYDataStoreDataType)dataType
                       error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
 * Determines if a file exists.
 *
 * @param fileName A string that represents the name of the file to check.
 * @param dataType The type of file (e.g., datafile, user profile, event dispatcher, etc.)
 * @return A boolean value that states if a file exists or not (or could not be determined).
 *
 **/
- (bool)fileExists:(nonnull NSString *)fileName
              type:(OPTLYDataStoreDataType)dataType;

/**
 * Determines if a data type exists.
 *
 * @param dataType The type of file (e.g., datafile, user profile, event dispatcher, etc.)
 * @return A boolean value that states if a data type exists or not (or could not be determined).
 *
 **/
- (bool)dataTypeExists:(OPTLYDataStoreDataType)dataType;

/**
 * Deletes a file.
 *
 * @param fileName A string that represents the name of the file to delete.
 * @param dataType The type of file (e.g., datafile, user profile, event dispatcher, etc.)
 * @param error An error object which will store any errors if the file removal fails.
 *  If error is nil, than the file deletion was successful.
 *
 **/
- (BOOL)removeFile:(nonnull NSString *)fileName
              type:(OPTLYDataStoreDataType)dataType
             error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
 * Removes all document files.
 *
 * @param error An error object which will store any errors if the file removal fails.
 *
 **/
- (BOOL)removeAllFiles:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
 * Removes a particular data type.
 *
 * @param dataType The type of file (e.g., datafile, user profile, event dispatcher, etc.)
 * @param error An error object which will store any errors if the directory removal fails.
 *
 **/
- (BOOL)removeFilesForDataType:(OPTLYDataStoreDataType)dataType
                         error:(NSError * _Nullable __autoreleasing * _Nullable)error;


// -------- Events Storage --------
// If data is cached, then the events are stored in a runtime in-memory queue.
// If data is not cached, the events are stored in an SQLite table.
// Events are only persisted in the SQLite table for iOS platforms.
// tvOS events are only cached to save on very limited memory availability.
// A future enhancement for tvOS is to store event data in iCloud.

/**
 * Saves an event.
 *
 * @param data The data to be saved.
 * @param eventType The event type of the data that needs to be saved.
 * @param error An error object is returned if an error occurs.
 */
- (BOOL)saveEvent:(nonnull NSDictionary *)data
        eventType:(OPTLYDataStoreEventType)eventType
            error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
 * Gets the oldest event.
 *
 * @param eventType The event type of the data that needs to be retrieved.
 * @param error An error object is returned if an error occurs.
 */
- (nullable NSDictionary *)getOldestEvent:(OPTLYDataStoreEventType)eventType
                                    error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
 * Gets the first N entries (i.e., the N oldest events).
 *
 * @param numberOfEvents The number of events to retrieve.
 * @param eventType The event type of the data that needs to be removed.
 * @param error An error object is returned if an error occurs.
 */
- (nullable NSArray *)getFirstNEvents:(NSInteger)numberOfEvents
                            eventType:(OPTLYDataStoreEventType)eventType
                                error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
 * Gets the last entry id.
 *
 * @param eventType The event type of the data that needs to be removed.
 * @param error An error object is returned if an error occurs.
 */
- (NSInteger)getLastEventId:(OPTLYDataStoreEventType)eventType
                      error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
 * Gets all events.
 *
 * @param eventType The event type of the data that needs to be retrieved.
 * @param error An error object is returned if an error occurs.
 * @return The return value is an array of OPTLYDatabaseEntity.
 */
- (nullable NSArray *)getAllEvents:(OPTLYDataStoreEventType)eventType
                             error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
 * Deletes the oldest event.
 *
 * @param eventType The event type of the data that needs to be removed.
 * @param error An error object is returned if an error occurs.
 */
- (BOOL)removeOldestEvent:(OPTLYDataStoreEventType)eventType
                    error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
 * Deletes the first N events (i.e., the N oldest events).
 *
 * @param numberOfEvents The number of events to retrieve.
 * @param eventType The event type of the data that needs to be removed.
 * @param error An error object is returned if an error occurs.
 */
- (BOOL)removeFirstNEvents:(NSInteger)numberOfEvents
                 eventType:(OPTLYDataStoreEventType)eventType
                     error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
 * Removes an event
 *
 * @param event The event to remove.
 * @param eventType The event type of the data that needs to be removed.
 * @param error An error object is returned if an error occurs.
 */
- (BOOL)removeEvent:(nonnull NSDictionary *)event
          eventType:(OPTLYDataStoreEventType)eventType
              error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
 * Deletes all events.
 *
 * @param eventType The event type of the data that needs to be removed.
 * @param error An error object is returned if an error occurs.
 */
- (BOOL)removeAllEvents:(OPTLYDataStoreEventType)eventType
                  error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
 * Returns the number of saved events.
 *
 * @param eventType The event type of the data.
 * @param error An error object is returned if an error occurs.
 * @return The number of events saved.
 */
- (NSInteger)numberOfEvents:(OPTLYDataStoreEventType)eventType
                      error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
 * Removes all events.
 *
 * @param error An error object is returned if an error occurs.
 */
- (BOOL)removeAllEvents:(NSError * _Nullable __autoreleasing * _Nullable)error;


// -------- User Data Storage --------
// Saves data in dictionary format in NSUserDefault
// This is available for iOS and tvOS.

/**
 * Saves data in dictionary format in NSUserDefault
 *
 * @param data The dictionary data to save.
 * @param dataType The type of data (e.g., datafile, user profile, event dispatcher, etc.)
 */
- (void)saveUserData:(nonnull NSDictionary *)data type:(OPTLYDataStoreDataType)dataType;

/**
 * Gets saved data from NSUserDefault.
 *
 * @param dataType The type of data (e.g., datafile, user profile, event dispatcher, etc.)
 * @return data retrieved.
 */
- (nullable NSDictionary *)getUserDataForType:(OPTLYDataStoreDataType)dataType;

/**
 * Removes data for a particular type of data in NSUserDefault.
 *
 * @param dataType The type of data (e.g., datafile, user profile, event dispatcher, etc.)
 */
- (void)removeUserDataForType:(OPTLYDataStoreDataType)dataType;

/**
 * Removes all Optimizely-related data in NSUserDefault.
 */
- (void)removeAllUserData;

/**
 * Removes an object from the dictionary data saved in NSUserDefault.
 *
 * @param dataKey The key for the dictionary data to remove.
 * @param dataType The type of data (e.g., datafile, user profile, event dispatcher, etc.)
 */
- (void)removeObjectInUserData:(nonnull id)dataKey type:(OPTLYDataStoreDataType)dataType;

/**
 * Helper method to get the string value of a data type enum.
 *
 * @param dataType The type of data (e.g., datafile, user profile, event dispatcher, etc.)
 */
+ (nullable NSString *)stringForDataTypeEnum:(OPTLYDataStoreDataType)dataType;

/**
 * Helper method to get the string value of a event type enum.
 *
 * @param eventType The event type of the data.
 */
+ (nullable NSString *)stringForDataEventEnum:(OPTLYDataStoreEventType)eventType;

@end
