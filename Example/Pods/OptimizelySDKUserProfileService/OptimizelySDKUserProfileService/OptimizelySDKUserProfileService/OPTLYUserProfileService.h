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
#import "OPTLYUserProfileServiceBuilder.h"

@protocol OPTLYLogger, OPTLYUserProfileService;

@interface OPTLYUserProfileServiceDefault : NSObject<OPTLYUserProfileService>

/// Logger provided by the user
@property (nonatomic, strong, nullable) id<OPTLYLogger> logger;

/**
 * Initializer for Optimizely User Profile object
 *
 * @param builderBlock The builder block with which to initialize the Optimizely User Profile object
 * @return An instance of OPTLYUserProfileService
 */
+ (nullable instancetype)init:(nonnull OPTLYUserProfileServiceBuilderBlock)builderBlock
__attribute((deprecated("Use OPTLYManager initWithBuilder method instead.")));

/**
 * Initializer for Optimizely User Profile object
 *
 * @param builder The OPTLYUserProfileServiceBuilder object with which to initialize the Optimizely User Profile object
 * @return An instance of OPTLYUserProfileService
 */
- (nullable instancetype)initWithBuilder:(nullable OPTLYUserProfileServiceBuilder *)builder;

/**
 * Cleans and removes all bucketing mapping for specific userId.
 * @param userId The user ID to remove all bucketing value.
 **/
- (void)removeUserExperimentRecordsForUserId:(nonnull NSString *)userId;

/**
 * Cleans and removes all bucketing mapping.
 **/
- (void)removeAllUserExperimentRecords;

/**
 * Clean up and remove experiments that are not in the valid experiment list passed in.
 * This is called when initialized from a remote datafile to ensure that the UserProfileService
 * does not grow indefinitely.
 * @param validExperimentIds An array of valid experiment ids.  If default user profile contains
 * experiments not in this list, they are removed from user profile service.
 **/
- (void)removeInvalidExperimentsForAllUsers:(NSArray<NSString *> *_Nullable)validExperimentIds;
@end
