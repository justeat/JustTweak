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

#ifdef UNIVERSAL
    #import "OPTLYUserProfileServiceBasic.h"
    #import "OPTLYLogger.h"
    #import "OPTLYDataStore.h"
    #import "OPTLYExperimentBucketMapEntity.h"
    #import "OPTLYUserProfile.h"
#else
    #import <OptimizelySDKCore/OPTLYExperimentBucketMapEntity.h>
    #import <OptimizelySDKCore/OPTLYUserProfileServiceBasic.h>
    #import <OptimizelySDKCore/OPTLYLogger.h>
    #import <OptimizelySDKCore/OPTLYUserProfile.h>
    #import <OptimizelySDKShared/OPTLYDataStore.h>
#endif
#import "OPTLYUserProfileService.h"

@interface OPTLYUserProfileServiceDefault()
@property (nonatomic, strong) OPTLYDataStore *dataStore;
@end

@implementation OPTLYUserProfileServiceDefault

+ (nullable instancetype)init:(nonnull OPTLYUserProfileServiceBuilderBlock)builderBlock {
    return [[self alloc] initWithBuilder:[OPTLYUserProfileServiceBuilder builderWithBlock:builderBlock]];
}

- (instancetype)init {
    return [self initWithBuilder:nil];
}

- (nullable instancetype)initWithBuilder:(nullable OPTLYUserProfileServiceBuilder *)builder {
    self = [super init];
    if (self != nil) {
        _logger = builder.logger;
        _dataStore = [OPTLYDataStore dataStore];
        _dataStore.logger = builder.logger;
        [self migrateLegacyUserProfileIfNeeded];
    }
    return self;
}

// checks to see if the legacy user profile exists
// if so, the legacy user profile data is migrated to
// the new data format before it is removed
- (void)migrateLegacyUserProfileIfNeeded
{
    NSDictionary *legacyUserProfileData = [self.dataStore getUserDataForType:OPTLYDataStoreDataTypeUserProfile];
    if ([legacyUserProfileData count] > 0)
    {
        NSMutableDictionary *newUserProfileDict = [NSMutableDictionary new];
        NSArray *userIds = [legacyUserProfileData allKeys];
        
        for (NSString *userId in userIds)
        {
            OPTLYUserProfile *userProfile = [OPTLYUserProfile new];
            userProfile.user_id = userId;
            
            // create the experiment bucket map for all the user's experiments
            NSDictionary *legacyUserProfileExperimentToVariationMap = legacyUserProfileData[userId];
            NSArray *experimentIds = [legacyUserProfileExperimentToVariationMap allKeys];
            NSMutableDictionary *experimentBucketMap = [NSMutableDictionary new];
            for (NSString *experimentId in experimentIds) {
                OPTLYExperimentBucketMapEntity *bucketMapEntity = [OPTLYExperimentBucketMapEntity new];
                bucketMapEntity.variation_id = legacyUserProfileExperimentToVariationMap[experimentId];
                NSDictionary *experimentBucketMapEntity = @{ experimentId : [bucketMapEntity toDictionary] };
                [experimentBucketMap addEntriesFromDictionary:experimentBucketMapEntity];
            }
    
            userProfile.experiment_bucket_map = [experimentBucketMap copy];
            [newUserProfileDict addEntriesFromDictionary: [userProfile toDictionary]];
            if ([newUserProfileDict count] > 0) {
                [self save:[newUserProfileDict copy]];
            }
        }
        
        // remove all legacy user profile data
        [self.dataStore removeUserDataForType:OPTLYDataStoreDataTypeUserProfile];
    }
}

- (NSDictionary *)lookup:(NSString *)userId
{
    NSDictionary *userProfilesDict = [self.dataStore getUserDataForType:OPTLYDataStoreDataTypeUserProfileService];
    NSDictionary *userProfileDict = [userProfilesDict objectForKey:userId];
    
    if (!userProfileDict) {
        [self.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesUserProfileNotExist, userId]
                      withLevel:OptimizelyLogLevelDebug ];
        return nil;
    }
    
    // convert map to a User Profile object to check data type
    NSError *userProfileError;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"
    [[OPTLYUserProfile alloc] initWithDictionary:userProfileDict error:&userProfileError];
#pragma clang diagnostic pop
    if (userProfileError) {
        [self.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesUserProfileLookupInvalidFormat, userProfileError]
                      withLevel:OptimizelyLogLevelWarning];
    }
    
    return userProfileDict;
}
    
- (void)save:(nonnull NSDictionary *)userProfileDict
{
    // convert map to a User Profile object to check data type
    NSError *error = nil;
    OPTLYUserProfile *userProfile = [[OPTLYUserProfile alloc] initWithDictionary:userProfileDict error:&error];
    if (error) {
        [self.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesUserProfileSaveInvalidFormat, error]
                      withLevel:OptimizelyLogLevelWarning];
    }

    // a map of userIds to user profiles is created to store multiple user profiles
    NSMutableDictionary *userProfilesDict = [[self.dataStore getUserDataForType:OPTLYDataStoreDataTypeUserProfileService] mutableCopy];
    if (!userProfilesDict) {
        userProfilesDict = [NSMutableDictionary new];
    }
    NSString *userId = userProfile.user_id;
    if ([userId length] > 0) {
        userProfilesDict[userId] = userProfileDict;
    } else {
        [self.logger logMessage:OPTLYLoggerMessagesUserProfileSaveInvalidUserId
                      withLevel:OptimizelyLogLevelWarning];
        return;
    }
    
    [self.dataStore saveUserData:userProfilesDict type:OPTLYDataStoreDataTypeUserProfileService];
    [self.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesUserProfileServiceSaved, userProfilesDict, userProfile.user_id]
                  withLevel:OptimizelyLogLevelDebug];
}

#pragma mark - Helper Methods
    
- (void)removeUserExperimentRecordsForUserId:(nonnull NSString *)userId {
    [self.dataStore removeObjectInUserData:userId type:OPTLYDataStoreDataTypeUserProfileService];
}

- (void)removeAllUserExperimentRecords {
    [self.dataStore removeAllUserData];
}

- (void)removeInvalidExperimentsForAllUsers:(NSArray<NSString *> *)validExperimentIds {
    
    NSMutableDictionary*userProfileService = [[self.dataStore getUserDataForType:OPTLYDataStoreDataTypeUserProfileService] mutableCopy];
    
    for (NSString *key in userProfileService.allKeys) {
        NSMutableDictionary *userProfileDict = [userProfileService[key] mutableCopy];
        NSDictionary * bucketMap = userProfileDict[@"experiment_bucket_map"];
        NSMutableDictionary *newBucketMap = [bucketMap mutableCopy];
        if (bucketMap.count < 100) {
            continue;
        }
        for (NSString *exId in bucketMap.allKeys) {
            if (![validExperimentIds containsObject:exId]) {
                [newBucketMap removeObjectForKey:exId];
            }
        }
        userProfileDict[@"experiment_bucket_map"] = newBucketMap;
        userProfileService[key] = userProfileDict;
    }
    
    [self.dataStore saveUserData:userProfileService type:OPTLYDataStoreDataTypeUserProfileService];
}
    
@end

