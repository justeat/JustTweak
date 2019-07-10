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
#ifdef UNIVERSAL
    #import "OPTLYErrorHandler.h"
#else
    #import <OptimizelySDKCore/OPTLYErrorHandler.h>
#endif
#import "OPTLYDataStore.h"
#import "OPTLYEventDataStore.h"

#if TARGET_OS_IOS
// SQLite tables are only available for iOS
#import "OPTLYDatabase.h"
#import "OPTLYDatabaseEntity.h"

@interface OPTLYEventDataStoreiOS()
@property (nonatomic, strong) OPTLYDatabase *database;
@property (nonatomic, strong) NSString *databaseDirectory;
@end

@implementation OPTLYEventDataStoreiOS

- (nullable instancetype)initWithBaseDir:(nonnull NSString *)baseDir
                                   error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    self = [super init];
    if (self)
    {
        _databaseDirectory = [baseDir stringByAppendingPathComponent:[OPTLYDataStore stringForDataTypeEnum:OPTLYDataStoreDataTypeDatabase]];
        _database = [[OPTLYDatabase alloc] initWithBaseDir:_databaseDirectory];
        
        // create the events table
        NSError *error = nil;
        [self createTable:[OPTLYDataStore stringForDataEventEnum:OPTLYDataStoreEventTypeImpression] error:&error];
        [self createTable:[OPTLYDataStore stringForDataEventEnum:OPTLYDataStoreEventTypeConversion] error:&error];
    }
    
    return self;
}

- (BOOL)createTable:(NSString *)eventTypeName
              error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    return [self.database createTable:eventTypeName error:error];
}

- (BOOL)saveEvent:(nonnull NSDictionary *)data
        eventType:(nonnull NSString *)eventTypeName
            error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
     return [self.database saveEvent:data table:eventTypeName error:error];
}

- (nullable NSArray *)getFirstNEvents:(NSInteger)numberOfEvents
                            eventType:(nonnull NSString *)eventTypeName
                                error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    NSMutableArray *firstNEvents = [NSMutableArray new];
    
    NSArray *firstNEntities = [self.database retrieveFirstNEntries:numberOfEvents table:eventTypeName error:error];
    for (OPTLYDatabaseEntity *entity in firstNEntities) {
        NSString *entityValue = entity.entityValue;
        NSDictionary *event = [NSJSONSerialization JSONObjectWithData:[entityValue dataUsingEncoding:NSUTF8StringEncoding] options:0 error:error];
        
        if ([event count] > 0) {
            if ((error != nil && *error == nil) || error == nil) {
                [firstNEvents addObject:@{@"entityId": entity.entityId, @"json": event}];
            }
        }
    }
    
    return [firstNEvents copy];
}

- (NSInteger)getLastEventId:(nonnull NSString *)eventTypeName
                      error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    NSInteger lastRowId = [self.database retrieveLastEntryId:eventTypeName error:error];
    return lastRowId;
}

- (BOOL)removeFirstNEvents:(NSInteger)numberOfEvents
                 eventType:(nonnull NSString *)eventTypeName
                     error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    BOOL ok = YES;
    NSArray *firstNEvents = [self.database retrieveFirstNEntries:numberOfEvents table:eventTypeName error:error];
    if ([firstNEvents count] <= 0) {
        ok = NO;
        if (error) {
            *error =  [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                          code:OPTLYErrorTypesDataStore
                                      userInfo:@{NSLocalizedDescriptionKey :
                                                     [NSString stringWithFormat:NSLocalizedString(OPTLYErrorHandlerMessagesDataStoreDatabaseNoSavedEvents, nil), eventTypeName]}];
        }
        return ok;
    }
    
    NSMutableArray *entityIds = [NSMutableArray new];
    for (OPTLYDatabaseEntity *entity in firstNEvents) {
        NSString *entityId = [entity.entityId stringValue];
        if ([entityId length] > 0) {
            [entityIds addObject:entityId];
        } else {
            ok = NO;
            if (error != nil) {
                *error =  [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                              code:OPTLYErrorTypesDataStore
                                          userInfo:@{NSLocalizedDescriptionKey :
                                                         [NSString stringWithFormat:NSLocalizedString(OPTLYErrorHandlerMessagesDataStoreInvalidDataStoreEntityValue, nil), eventTypeName]}];
            }
        }
    }
    if (![self.database deleteEntities:entityIds table:eventTypeName error:error]) {
        ok = NO;
    }
    return ok;
}

- (BOOL)removeEvent:(nonnull NSDictionary *)event
          eventType:(nonnull NSString *)eventTypeName
              error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    BOOL retval = false;
    
    if (event[@"entityId"] != nil) {
        retval = [self.database deleteEntity:event[@"entityId"] table:eventTypeName error:error];
    }
    return retval;
}

- (NSInteger)numberOfEvents:(NSString *)eventTypeName
                      error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    NSInteger numberOfEvents = [self.database numberOfRows:eventTypeName error:error];
    return numberOfEvents;
}

@end
#endif

#if TARGET_OS_TV

#ifdef UNIVERSAL
    #import "OPTLYQueue.h"
#else
    #import <OptimizelySDKCore/OPTLYQueue.h>
#endif

@interface OPTLYEventDataStoreTVOS()
@property (nonatomic, strong) NSMutableDictionary *eventsCache;
@end

@implementation OPTLYEventDataStoreTVOS

- (nullable instancetype)initWithBaseDir:(nonnull NSString *)baseDir
                                   error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    self = [super init];
    if (self)
    {
        _eventsCache = [NSMutableDictionary new];
        [_eventsCache setObject:[OPTLYQueue new] forKey:[OPTLYDataStore stringForDataEventEnum:OPTLYDataStoreEventTypeImpression]];
        [_eventsCache setObject:[OPTLYQueue new] forKey:[OPTLYDataStore stringForDataEventEnum:OPTLYDataStoreEventTypeConversion]];
    }
    return self;
}

// queue to make eventsCache threadsafe
dispatch_queue_t eventsStorageCacheQueue()
{
    static dispatch_queue_t _eventsStorageCacheQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _eventsStorageCacheQueue = dispatch_queue_create("com.Optimizely.eventsStorageCache", DISPATCH_QUEUE_SERIAL);
    });
    return _eventsStorageCacheQueue;
}

- (BOOL)saveEvent:(nonnull NSDictionary *)data
        eventType:(nonnull NSString *)eventTypeName
            error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    dispatch_async(eventsStorageCacheQueue(), ^{
        __weak typeof(self) weakSelf = self;
        OPTLYQueue *queue = [weakSelf.eventsCache objectForKey:eventTypeName];
        [queue enqueue:data];
    });
    return YES;
}

- (nullable NSArray *)getFirstNEvents:(NSInteger)numberOfEvents
                            eventType:(nonnull NSString *)eventTypeName
                                error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    __block OPTLYQueue *queue = nil;
    dispatch_sync(eventsStorageCacheQueue(), ^{
        __weak typeof(self) weakSelf = self;
        queue = [weakSelf.eventsCache objectForKey:eventTypeName];
    });
    
    NSArray *firstNEntities = [queue firstNItems:numberOfEvents];
    NSMutableArray *firstNEvents = [NSMutableArray new];
    for (NSDictionary *entity in firstNEntities) {
        if ([entity count] > 0) {
            [firstNEvents addObject:@{@"entityId": @([firstNEntities indexOfObject:entity]) , @"json": entity}];
        }
    }
    return firstNEvents;
}

- (NSInteger)getLastEventId:(nonnull NSString *)eventTypeName
                      error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    __block OPTLYQueue *queue = nil;
    dispatch_sync(eventsStorageCacheQueue(), ^{
        __weak typeof(self) weakSelf = self;
        queue = [weakSelf.eventsCache objectForKey:eventTypeName];
    });
    
    return [queue lastItemIndex];
}

- (BOOL)removeFirstNEvents:(NSInteger)numberOfEvents
                 eventType:(nonnull NSString *)eventTypeName
                     error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    dispatch_async(eventsStorageCacheQueue(), ^{
        __weak typeof(self) weakSelf = self;
        OPTLYQueue *queue = [weakSelf.eventsCache objectForKey:eventTypeName];
        [queue dequeueNItems:numberOfEvents];
    });
    return YES;
}

- (BOOL)removeEvent:(nonnull NSDictionary *)event
          eventType:(nonnull NSString *)eventTypeName
              error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    BOOL retval = NO;
    
    if (event[@"entityId"] != nil) {
        dispatch_async(eventsStorageCacheQueue(), ^{
            __weak typeof(self) weakSelf = self;
            OPTLYQueue *queue = [weakSelf.eventsCache objectForKey:eventTypeName];
            if (queue && [queue.queue count] > [event[@"entityId"] integerValue]) {
                NSDictionary *eventJSON = [queue.queue objectAtIndex:[event[@"entityId"] integerValue]];
                [queue removeItem:eventJSON];
            }
        });
        retval = YES;
    }
    return retval;
}

- (NSInteger)numberOfEvents:(nonnull NSString *)eventTypeName
                      error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    __block OPTLYQueue *queue = nil;
    dispatch_sync(eventsStorageCacheQueue(), ^{
        __weak typeof(self) weakSelf = self;
        queue = [weakSelf.eventsCache objectForKey:eventTypeName];
    });
    
    return [queue size];
}

@end
#endif
