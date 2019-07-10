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

#import <UIKit/UIKit.h>
#ifdef UNIVERSAL
    #import "OPTLYFMDB.h"
    #import "OptimizelySDKCore.h"
#else
    #import <OptimizelySDKShared/OPTLYFMDB.h>
    #import <OptimizelySDKCore/OptimizelySDKCore.h>
#endif
#import "OPTLYDatabase.h"
#import "OPTLYDatabaseEntity.h"

// table file name
static NSString * const kDatabaseFileName = @"optly-database.sqlite";

// database queries
static NSString * const kCreateTableQuery = @"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY AUTOINCREMENT, json TEXT,timestamp INTEGER)";
static NSString * const kInsertEntityQuery = @"INSERT INTO %@ (json,timestamp) VALUES(?,?)";
static NSString * const kDeleteEntityIDQuery = @"DELETE FROM %@ where id IN %@";
static NSString * const kDeleteEntityQuery = @"DELETE FROM %@ where json='%@'";
static NSString * const kRetrieveEntityQuery = @"SELECT * from %@";
static NSString * const kRetrieveLastEntityIdQuery = @"select last_insert_rowid()";
static NSString * const kRetrieveEntityQueryLimit = @" LIMIT %ld";
static NSString * const kEntitiesCountQuery = @"SELECT count(*) FROM %@";

// column names
static NSString * const kColumnKeyId = @"id";
static NSString * const kColumnKeyJSON = @"json";
static NSString * const kColumnKeyTimestamp = @"timestamp";

@interface OPTLYDatabase()
@property (nonatomic, strong) NSString *databaseFileDirectory;
@property (nonatomic, strong) NSString *databaseFilePath;
@property (nonatomic, strong) OPTLYFMDBDatabaseQueue *fmDatabaseQueue;
@property (nonatomic, strong) NSString *baseDir;
@end

@implementation OPTLYDatabase

- (instancetype)initWithBaseDir:(NSString *)baseDir {
    self = [super init];
    if (self != nil) {
        _baseDir = baseDir;
        
        // create directory for the database if it does not exist
        NSFileManager *fileManager = [NSFileManager new];
        BOOL isDir;
        if (![fileManager fileExistsAtPath:_baseDir isDirectory:&isDir]) {
            [fileManager createDirectoryAtPath:_baseDir
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:nil];
        }
        
        // set the database queue
        _databaseFilePath =  [_baseDir stringByAppendingPathComponent:kDatabaseFileName];
        _fmDatabaseQueue =  [OPTLYFMDBDatabaseQueue databaseQueueWithPath:_databaseFilePath];
    }
    return self;
}

- (id)init
{
    NSAssert(true, @"Use initWithBaseDir.");
    self = [super init];
    return self;
}

- (BOOL)createTable:(NSString *)tableName
              error:(NSError * __autoreleasing *)error
{
    __block BOOL ok = YES;
    [self.fmDatabaseQueue inDatabase:^(OPTLYFMDBDatabase *db) {
        NSString *query = [NSString stringWithFormat:kCreateTableQuery, tableName];
        if (![db executeUpdate:query]) {
            ok = NO;
            if (error) {
                *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                             code:OPTLYErrorTypesDatabase
                                         userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString([db lastErrorMessage], nil)}];
            }
            OPTLYLogError(@"Unable to create Optimizely table: %@ %@", tableName, [db lastErrorMessage]);
        }
    }];
    return ok;
}

- (BOOL)saveEvent:(NSDictionary *)data
            table:(NSString *)tableName
            error:(NSError * __autoreleasing *)error
{
    __block BOOL ok = YES;
    if ([data count] == 0) {
        ok = NO;
        if (error) {
            NSString *errorMessage = [NSString stringWithFormat:OPTLYErrorHandlerMessagesDataStoreDatabaseNoDataToSave, tableName];
            
            *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                         code:OPTLYErrorTypesDatabase
                                     userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
            OPTLYLogError(errorMessage);
        }
        return ok;
    }
    
    [self.fmDatabaseQueue inDatabase:^(OPTLYFMDBDatabase *db){
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:error];
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSNumber *timeStamp = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
        NSMutableString *query = [NSMutableString stringWithFormat:kInsertEntityQuery, tableName];
        if (![db executeUpdate:query, json, timeStamp]) {
            ok = NO;
            if (error) {
                *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                             code:OPTLYErrorTypesDatabase
                                         userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString([db lastErrorMessage], nil)}];
            }
            OPTLYLogError(@"Unable to store data to Optimizely table: %@ %@ %@", tableName, json, [db lastErrorMessage]);
        }
    }];
    return ok;
}

- (BOOL)deleteEntity:(NSString *)entityId
               table:(NSString *)tableName
               error:(NSError * __autoreleasing *)error
{
    return [self deleteEntities:@[entityId] table:tableName error:error];
}

- (BOOL)deleteEntities:(NSArray *)entityIds
                 table:(NSString *)tableName
                 error:(NSError * __autoreleasing *)error
{
    __block BOOL ok = YES;
    [self.fmDatabaseQueue inDatabase:^(OPTLYFMDBDatabase *db){
        NSString *commaSeperatedIds = [NSString stringWithFormat:@"(%@)", [entityIds componentsJoinedByString:@","]];
        NSString *query = [NSString stringWithFormat:kDeleteEntityIDQuery, tableName, commaSeperatedIds];
        if (![db executeUpdate:query]) {
            ok = NO;
            if (error) {
                *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                             code:OPTLYErrorTypesDatabase
                                         userInfo:@{NSLocalizedDescriptionKey :
                                                        NSLocalizedString([db lastErrorMessage], nil)}];
            }
            OPTLYLogError(@"Unable to remove rows of Optimizely table: %@ %@", tableName, [db lastErrorMessage]);
        }
    }];
    return ok;
}

- (BOOL)deleteEntityWithJSON:(nonnull NSString *)json
                       table:(nonnull NSString *)tableName
                       error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    __block BOOL ok = YES;
    [self.fmDatabaseQueue inDatabase:^(OPTLYFMDBDatabase *db){
        NSString *query = [NSString stringWithFormat:kDeleteEntityQuery, tableName, json];
        if (![db executeUpdate:query]) {
            ok = NO;
            if (error) {
                *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                             code:OPTLYErrorTypesDatabase
                                         userInfo:@{NSLocalizedDescriptionKey :
                                                        NSLocalizedString([db lastErrorMessage], nil)}];
            }
            OPTLYLogError(@"Unable to remove row of Optimizely table: %@ %@", tableName, [db lastErrorMessage]);
        }
    }];
    return ok;
}

- (NSArray *)retrieveAllEntries:(NSString *)tableName
                          error:(NSError * __autoreleasing *)error
{
    NSArray *allEntries = [self retrieveFirstNEntries:0 table:tableName error:error];
    return allEntries;
}

- (NSArray *)retrieveFirstNEntries:(NSInteger)numberOfEntries
                             table:(NSString *)tableName
                             error:(NSError * __autoreleasing *)error
{
    NSMutableArray *results = [NSMutableArray new];
    
    [self.fmDatabaseQueue inDatabase:^(OPTLYFMDBDatabase *db){
        NSMutableString *query = [NSMutableString stringWithFormat:kRetrieveEntityQuery, tableName];
        if (numberOfEntries) {
            [query appendFormat:kRetrieveEntityQueryLimit, (long)numberOfEntries];
        }
        OPTLYFMDBResultSet *resultSet = [db executeQuery:query];
        if (!resultSet) {
            if (error) {
                *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                             code:OPTLYErrorTypesDatabase
                                         userInfo:@{NSLocalizedDescriptionKey :
                                                        NSLocalizedString([db lastErrorMessage], nil)}];
            }
            OPTLYLogError(@"Unable to retrieve rows of Optimizely table: %@ %@", tableName, [db lastErrorMessage]);
        }
        
        while ([resultSet next]) {
            OPTLYDatabaseEntity *entity = [OPTLYDatabaseEntity new];
            entity.entityId = [NSNumber numberWithLongLong:[resultSet intForColumn:kColumnKeyId]];
            entity.entityValue = [resultSet stringForColumn:kColumnKeyJSON];
            entity.timestamp = [NSNumber numberWithLongLong:[resultSet intForColumn:kColumnKeyTimestamp]];
            [results addObject:entity];
        }
        [resultSet close];
    }];
    
    return results;
}

- (NSInteger)retrieveLastEntryId:(NSString *)tableName
                           error:(NSError * __autoreleasing *)error
{
    __block NSInteger rowId;
    [self.fmDatabaseQueue inDatabase:^(OPTLYFMDBDatabase *db){
        NSMutableString *query = [NSMutableString stringWithFormat:kRetrieveLastEntityIdQuery];
        
        OPTLYFMDBResultSet *resultSet = [db executeQuery:query];
        if (!resultSet) {
            if (error) {
                *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                             code:OPTLYErrorTypesDatabase
                                         userInfo:@{NSLocalizedDescriptionKey :
                                                        NSLocalizedString([db lastErrorMessage], nil)}];
            }
            OPTLYLogError(@"Unable to retrieve rows of Optimizely table: %@ %@", tableName, [db lastErrorMessage]);
        }
        
        if ([resultSet next]) {
            rowId = [resultSet intForColumnIndex:0];
        }
        [resultSet close];
    }];
    
    return rowId;
}

- (NSInteger)numberOfRows:(NSString *)tableName
                    error:(NSError * __autoreleasing *)error
{
    __block NSInteger rows = 0;
    
    [self.fmDatabaseQueue inDatabase:^(OPTLYFMDBDatabase *db){
        NSString *query = [NSString stringWithFormat:kEntitiesCountQuery, tableName];
        OPTLYFMDBResultSet *resultSet = [db executeQuery:query];
        if (!resultSet) {
            if (error) {
                *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                             code:OPTLYErrorTypesDatabase
                                         userInfo:@{NSLocalizedDescriptionKey :
                                                        NSLocalizedString([db lastErrorMessage], nil)}];
            }
            OPTLYLogError(@"Unable to fetch number of rows in Optimizely table: %@ %@", tableName, [db lastErrorMessage]);
        }
        if ([resultSet next]) {
            rows = [resultSet intForColumnIndex:0];
        }
        
        [resultSet close];
    }];
    
    return rows;
}

- (BOOL)deleteDatabase:(NSError * __autoreleasing *)error {
    NSFileManager *fm = [NSFileManager defaultManager];
    self.fmDatabaseQueue = nil;
    return [fm removeItemAtPath:self.databaseFilePath error:error];
}
@end
