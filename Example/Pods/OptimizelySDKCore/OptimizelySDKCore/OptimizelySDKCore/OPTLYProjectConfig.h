/****************************************************************************
 * Copyright 2017-2019, Optimizely, Inc. and contributors                   *
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
    #import "OPTLYJSONModelLib.h"
#else
    #import <OptimizelySDKCore/OPTLYJSONModelLib.h>
#endif
#import "OPTLYProjectConfigBuilder.h"

NS_ASSUME_NONNULL_BEGIN
extern NSString * const kExpectedDatafileVersion;
NS_ASSUME_NONNULL_END

@class OPTLYAttribute, OPTLYAudience, OPTLYBucketer, OPTLYEvent, OPTLYExperiment, OPTLYGroup, OPTLYUserProfileService, OPTLYVariation, OPTLYVariable, OPTLYFeatureFlag, OPTLYRollout;
@protocol OPTLYAttribute, OPTLYAudience, OPTLYBucketer, OPTLYErrorHandler, OPTLYEvent, OPTLYExperiment, OPTLYGroup, OPTLYLogger, OPTLYVariable, OPTLYVariation, OPTLYFeatureFlag, OPTLYRollout;

/*
    This class represents all the data contained in the project datafile 
    and includes helper methods to efficiently access its data.
 */

@interface OPTLYProjectConfig : OPTLYJSONModel

/// Account Id
@property (nonatomic, strong, nonnull) NSString *accountId;
/// Project Id
@property (nonatomic, strong, nonnull) NSString *projectId;
/// JSON Version
@property (nonatomic, strong, nonnull) NSString *version;
/// Datafile Revision number
@property (nonatomic, strong, nonnull) NSString *revision;
/// Flag for IP anonymization
@property (nonatomic, strong, nonnull) NSNumber<OPTLYOptional> *anonymizeIP;
/// Flag for Bot Filtering
@property (nonatomic, strong, nonnull) NSNumber<OPTLYOptional> *botFiltering;
/// List of Optimizely Experiment objects
@property (nonatomic, strong, nonnull) NSArray<OPTLYExperiment *><OPTLYExperiment> *experiments;
/// List of Optimizely Event Type objects
@property (nonatomic, strong, nonnull) NSArray<OPTLYEvent *><OPTLYEvent> *events;
/// List of audience ids
@property (nonatomic, strong, nonnull) NSArray<OPTLYAudience *><OPTLYAudience> *audiences;
/// List of typed audience objects
@property (nonatomic, strong, nullable) NSArray<OPTLYAudience *><OPTLYAudience, OPTLYOptional> *typedAudiences;
/// List of attributes objects
@property (nonatomic, strong, nonnull) NSArray<OPTLYAttribute *><OPTLYAttribute> *attributes;
/// List of group objects
@property (nonatomic, strong, nonnull) NSArray<OPTLYGroup *><OPTLYGroup> *groups;

/// a comprehensive list of experiments that includes experiments being whitelisted (in Groups)
@property (nonatomic, strong, nullable) NSArray<OPTLYExperiment *><OPTLYExperiment, OPTLYOptional> *allExperiments;
@property (nonatomic, strong, nullable) id<OPTLYLogger, Ignore> logger;
@property (nonatomic, strong, nullable) id<OPTLYErrorHandler, Ignore> errorHandler;
@property (nonatomic, strong, readonly, nullable) id<OPTLYUserProfileService, Ignore> userProfileService;

/// Returns the client type (e.g., objective-c-sdk, ios-sdk, tvos-sdk)
@property (nonatomic, strong, readonly, nonnull) NSString<Ignore> *clientEngine;
/// Returns the client version number
@property (nonatomic, strong, readonly, nonnull) NSString<Ignore> *clientVersion;
/// List of Optimizely Feature Flags objects
@property (nonatomic, strong, nonnull) NSArray<OPTLYFeatureFlag *><OPTLYFeatureFlag, OPTLYOptional> *featureFlags;
/// List of Optimizely Rollouts objects
@property (nonatomic, strong, nonnull) NSArray<OPTLYRollout *><OPTLYRollout, OPTLYOptional> *rollouts;

/**
 * Initialize the Project Config from a builder block.
 */
+ (nullable instancetype)init:(nonnull OPTLYProjectConfigBuilderBlock)builderBlock
__attribute((deprecated("Use OPTLYProjectConfig initWithBuilder method instead.")));

/**
 * Initialize the Project Config from a OPTLYProjectConfigBuilder object.
 * @param builder The OPTLYProjectConfigBuilder object, which has logger, errorHandler, and eventDispatcher to be set.
 * @return OPTLYProjectConfig instance.
 */
- (nullable instancetype)initWithBuilder:(nonnull OPTLYProjectConfigBuilder *)builder;

/**
 * Initialize the Project Config from a datafile.
 */
- (nullable instancetype)initWithDatafile:(nonnull NSData *)datafile;

/**
 * Get an Experiment object for a key.
 */
- (nullable OPTLYExperiment *)getExperimentForKey:(nonnull NSString *)experimentKey;

/**
 * Get an Experiment object for an Id.
 */
- (nullable OPTLYExperiment *)getExperimentForId:(nonnull NSString *)experimentId;

/**
* Get an experiment Id for the human readable experiment key
**/
- (nullable NSString *)getExperimentIdForKey:(nonnull NSString *)experimentKey;

/**
 * Returns true if experiment belongs to any feature, false otherwise.
 **/
- (BOOL)isFeatureExperiment:(nonnull NSString *)experimentId;

/**
 * Get a Group object for an Id.
 */
- (nullable OPTLYGroup *)getGroupForGroupId:(nonnull NSString *)groupId;

/**
 * Get a Feature Flag object for a key.
 */
- (nullable OPTLYFeatureFlag *)getFeatureFlagForKey:(nonnull NSString *)featureFlagKey;

/**
 * Get a Rollout object for an Id.
 */
- (nullable OPTLYRollout *)getRolloutForId:(nonnull NSString *)rolloutId;

/**
 * Gets an event id for a corresponding event key
 */
- (nullable NSString *)getEventIdForKey:(nonnull NSString *)eventKey;

/**
 * Gets an event for a corresponding event key
 */
- (nullable OPTLYEvent *)getEventForKey:(nonnull NSString *)eventKey;

/**
* Get an attribute for a given key.
*/
- (nullable OPTLYAttribute *)getAttributeForKey:(nonnull NSString *)attributeKey;

/**
 * Get an attribute Id for a given key.
 **/
- (nullable NSString *)getAttributeIdForKey:(nonnull NSString *)attributeKey;

/**
 * Get an audience for a given audience id.
 */
- (nullable OPTLYAudience *)getAudienceForId:(nonnull NSString *)audienceId;

/**
 * Get forced variation for a given experiment key and user id.
 */
- (nullable OPTLYVariation *)getForcedVariation:(nonnull NSString *)experimentKey
                                         userId:(nonnull NSString *)userId;

/**
 * Set forced variation for a given experiment key and user id according to a given variation key.
 */
- (BOOL)setForcedVariation:(nonnull NSString *)experimentKey
                    userId:(nonnull NSString *)userId
              variationKey:(nullable NSString *)variationKey;

/**
 * Get variation for experiment and user ID with user attributes.
 */
- (nullable OPTLYVariation *)getVariationForExperiment:(nonnull NSString *)experimentKey
                                                userId:(nonnull NSString *)userId
                                            attributes:(nullable NSDictionary<NSString *, id> *)attributes
                                              bucketer:(nullable id<OPTLYBucketer>)bucketer;

@end
