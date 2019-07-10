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
#import "OPTLYBuilder.h"

@class OPTLYProjectConfig, OPTLYVariation, OPTLYDecisionService, OPTLYNotificationCenter;
@protocol OPTLYBucketer, OPTLYErrorHandler, OPTLYEventBuilder, OPTLYEventDispatcher, OPTLYLogger;

@protocol Optimizely <NSObject>

#pragma mark - activateExperiment methods
/**
 * Use the `activate` method to activate an A/B test for the specified user to start an experiment.
 *
 * The activate call conditionally activates an experiment for a user, based on the provided experiment key and a randomized hash of the provided user ID.
 * If the user satisfies audience conditions for the experiment and the experiment is valid and running, the function returns the variation that the user is bucketed into.
 * Otherwise, `activate` returns nil. Make sure that your code adequately deals with the case when the experiment is not activated (e.g., execute the default variation).
 */

/**
 * Activates an A/B test for a user, determines whether they qualify for the experiment, buckets a qualified
 * user into a variation, and sends an impression event to Optimizely.
 *
 * For more information, see https://docs.developers.optimizely.com/full-stack/docs/activate.
 *
 * @param experimentKey The key of the variation's experiment to activate.
 * @param userId        The user ID.
 *
 * @return              The key of the variation where the user is bucketed, or `nil` if the user doesn't 
 *                      qualify for the experiment.
 */
- (nullable OPTLYVariation *)activate:(nonnull NSString *)experimentKey
                               userId:(nonnull NSString *)userId;

/**
 * Activates an A/B test for a user, determines whether they qualify for the experiment, buckets a qualified
 * user into a variation, and sends an impression event to Optimizely.
 *
 * This method takes into account the user `attributes` passed in, to determine if the user
 * is part of the audience that qualifies for the experiment.
 *
 * For more information, see https://docs.developers.optimizely.com/full-stack/docs/activate.
 *
 * @param experimentKey The key of the variation's experiment to activate.
 * @param userId        The user ID.
 * @param attributes    A map of custom key-value string pairs specifying attributes for the user.
 *
 * @return              The key of the variation where the user is bucketed, or `nil` if the user doesn't 
 *                      qualify for the experiment.
 */
- (nullable OPTLYVariation *)activate:(nonnull NSString *)experimentKey
                               userId:(nonnull NSString *)userId
                           attributes:(nullable NSDictionary<NSString *, id> *)attributes;

#pragma mark - getVariation methods
/**
 * Use the `getVariation` method if `activate` has been called and the current variation assignment
 * is needed for a given experiment and user.
 * This method bypasses redundant network requests to Optimizely.
 */

/**
 * Buckets a qualified user into an A/B test. Takes the same arguments and returns the same values as `activate`, 
 * but without sending an impression network request. The behavior of the two methods is identical otherwise. 
 * Use `getVariation` if `activate` has been called and the current variation assignment is needed for a given
 * experiment and user.
 *
 * For more information, see https://docs.developers.optimizely.com/full-stack/docs/get-variation.
 *
 * @param experimentKey The key of the experiment for which to retrieve the variation.
 * @param userId        The ID of the user for whom to retrieve the variation.
 *
 * @return              The key of the variation where the user is bucketed, or `nil` if the user
 *                      doesn't qualify for the experiment.
 */
- (nullable OPTLYVariation *)variation:(nonnull NSString *)experimentKey
                                userId:(nonnull NSString *)userId;

/**
 * Buckets a qualified user into an A/B test. Takes the same arguments and returns the same values as `activate`, 
 * but without sending an impression network request. The behavior of the two methods is identical otherwise. 
 * Use `getVariation` if `activate` has been called and the current variation assignment is needed for a given
 * experiment and user.
 *
 * This method takes into account the user `attributes` passed in, to determine if the user
 * is part of the audience that qualifies for the experiment.
 *
 * For more information, see https://docs.developers.optimizely.com/full-stack/docs/get-variation.
 *
 * @param experimentKey The key of the experiment for which to retrieve the variation.
 * @param userId        The ID of the user for whom to retrieve the variation.
 * @param attributes    A map of custom key-value string pairs specifying attributes for the user.
 *
 * @return              The key of the variation where the user is bucketed, or `nil` if the user
 *                      doesn't qualify for the experiment.
 */
- (nullable OPTLYVariation *)variation:(nonnull NSString *)experimentKey
                                userId:(nonnull NSString *)userId
                            attributes:(nullable NSDictionary<NSString *, id> *)attributes;

#pragma mark - Forced Variation Methods
/**
 * Use the `setForcedVariation` method to force an experimentKey-userId
 * pair into a specific variation for QA purposes.
 * The forced bucketing feature allows customers to force users into
 * variations in real time for QA purposes without requiring datafile
 * downloads from the network. `activate` and `track` are called
 * as usual after the variation is set, but the user will be bucketed
 * into the forced variation overriding any variation which would be
 * computed via the network datafile.
 */

/**
 * Returns the forced variation set by `setForcedVaration` or `nil` if no variation was forced.
 * A user can be forced into a variation for a given experiment for the lifetime of the
 * Optimizely client. The forced variation value is runtime only and doesn't persist across application launches.
 *
 * For more information, see https://docs.developers.optimizely.com/full-stack/docs/get-forced-variation.
 *
 * @param experimentKey The key of the experiment for which to retrieve the forced variation.
 * @param userId        The ID of the user in the forced variation.
 * 
 * @return              The variation the user was bucketed into, or `nil` if `setForcedVariation` failed to
 *                      force the user into the variation.
 */
- (nullable OPTLYVariation *)getForcedVariation:(nonnull NSString *)experimentKey
                                         userId:(nonnull NSString *)userId;

/**
 * Forces a user into a variation for a given experiment for the lifetime of the Optimizely client.
 * The forced variation value doesn't persist across application launches.
 *
 * For more information, see https://docs.developers.optimizely.com/full-stack/docs/set-forced-variation.
 *
 * @param experimentKey The key of the experiment to set with the forced variation.
 * @param userId        The ID of the user to force into the variation.
 * @param variationKey  The key of the forced variation. Set the value to `nil` to
 *                      clear the existing experiment-to-variation mapping.
 *
 * @return              `YES` if the user was successfully forced into a variation. 
 *                      `NO` if the `experimentKey` isn't in the project file or the `variationKey` isn't in the experiment.
 */
- (BOOL)setForcedVariation:(nonnull NSString *)experimentKey
                    userId:(nonnull NSString *)userId
              variationKey:(nullable NSString *)variationKey;

#pragma mark - Feature Flag Methods

/**
 * Determines whether a feature test or rollout is enabled for a given user, and sends
 * an impression event if the user is bucketed into an experiment using the feature.
 *
 * This method takes into account the user `attributes` passed in, to determine if the user
 * is part of the audience that qualifies for the experiment.
 *
 * For more information, see https://docs.developers.optimizely.com/full-stack/docs/is-feature-enabled.
 *
 * @param featureKey The key of the feature to check.
 * @param userId     The ID of the user to check.
 * @param attributes A map of custom key-value string pairs specifying attributes for the user.
 *
 * @return           `YES` if the feature is enabled. `NO` if the feature is disabled or couldn't be found.
 */
- (BOOL)isFeatureEnabled:(nullable NSString *)featureKey userId:(nullable NSString *)userId attributes:(nullable NSDictionary<NSString *, id> *)attributes;

/**
 * Evaluates the specified boolean feature variable and returns its value.
 *
 * This method takes into account the user `attributes` passed in, to determine if the user
 * is part of the audience that qualifies for the experiment.
 *
 * For more information, see https://docs.developers.optimizely.com/full-stack/docs/get-feature-variable.
 *
 * @param featureKey  The key of the feature whose variable's value is being accessed.
 * @param variableKey The key of the variable whose value is being accessed.
 * @param userId      The ID of the participant in the experiment.
 * @param attributes  A map of custom key-value string pairs specifying attributes for the user.
 *
 * @return            The value of the variable, or `nil` if the feature key is invalid, the variable key is
 *                    invalid, or there is a mismatch with the type of the variable.
 */
- (nullable NSNumber *)getFeatureVariableBoolean:(nullable NSString *)featureKey
                      variableKey:(nullable NSString *)variableKey
                           userId:(nullable NSString *)userId
                       attributes:(nullable NSDictionary<NSString *, id> *)attributes;

/**
 * Evaluates the specified double feature variable and returns its value.
 *
 * This method takes into account the user `attributes` passed in, to determine if the user
 * is part of the audience that qualifies for the experiment.
 *
 * For more information, see https://docs.developers.optimizely.com/full-stack/docs/get-feature-variable.
 *
 * @param featureKey  The key of the feature whose variable's value is being accessed.
 * @param variableKey The key of the variable whose value is being accessed.
 * @param userId      The ID of the participant in the experiment.
 * @param attributes  A map of custom key-value string pairs specifying attributes for the user.
 *
 * @return            The value of the variable, or `nil` if the feature key is invalid, the variable key is
 *                    invalid, or there is a mismatch with the type of the variable.
 */
- (nullable NSNumber *)getFeatureVariableDouble:(nullable NSString *)featureKey
                       variableKey:(nullable NSString *)variableKey
                            userId:(nullable NSString *)userId
                        attributes:(nullable NSDictionary<NSString *, id> *)attributes;

/**
 * Evaluates the specified integer feature variable and returns its value.
 *
 * This method takes into account the user `attributes` passed in, to determine if the user
 * is part of the audience that qualifies for the experiment.
 *
 * For more information, see https://docs.developers.optimizely.com/full-stack/docs/get-feature-variable.
 *
 * @param featureKey  The key of the feature whose variable's value is being accessed.
 * @param variableKey The key of the variable whose value is being accessed.
 * @param userId      The ID of the participant in the experiment.
 * @param attributes  A map of custom key-value string pairs specifying attributes for the user.
 *
 * @return            The value of the variable, or `nil` if the feature key is invalid, the variable key is
 *                    invalid, or there is a mismatch with the type of the variable.
 */
- (nullable NSNumber *)getFeatureVariableInteger:(nullable NSString *)featureKey
                     variableKey:(nullable NSString *)variableKey
                          userId:(nullable NSString *)userId
                      attributes:(nullable NSDictionary<NSString *, id> *)attributes;

/**
 * Evaluates the specified string feature variable and returns its value.
 *
 * This method takes into account the user `attributes` passed in, to determine if the user
 * is part of the audience that qualifies for the experiment.
 *
 * For more information, see https://docs.developers.optimizely.com/full-stack/docs/get-feature-variable.
 *
 * @param featureKey  The key of the feature whose variable's value is being accessed.
 * @param variableKey The key of the variable whose value is being accessed.
 * @param userId      The ID of the participant in the experiment.
 * @param attributes  A map of custom key-value string pairs specifying attributes for the user.
 *
 * @return            The value of the variable, or `nil` if the feature key is invalid, the variable key is
 *                    invalid, or there is a mismatch with the type of the variable.
 */
- (nullable NSString *)getFeatureVariableString:(nullable NSString *)featureKey
                           variableKey:(nullable NSString *)variableKey
                                userId:(nullable NSString *)userId
                            attributes:(nullable NSDictionary<NSString *, id> *)attributes;

/**
 * Retrieves a list of features that are enabled for the user.
 * Invoking this method is equivalent to running `isFeatureEnabled` for each feature in the datafile sequentially.
 *
 * This method takes into account the user `attributes` passed in, to determine if the user
 * is part of the audience that qualifies for the experiment.    
 *
 * For more information, see https://docs.developers.optimizely.com/full-stack/docs/get-enabled-features.
 *
 * @param userId     The ID of the user who may have features enabled in one or more experiments.
 * @param attributes A map of custom key-value string pairs specifying attributes for the user.
 *
 * @return           A list of keys corresponding to the features that are enabled for the user, or an empty list if no
 *                   features could be found for the specified user. 
 */
- (NSArray<NSString *> *_Nonnull)getEnabledFeatures:(nullable NSString *)userId
                                         attributes:(nullable NSDictionary<NSString *, id> *)attributes;

#pragma mark - trackEvent methods
/**
 * Tracks a conversion event for a user who meets the default audience conditions for an experiment. 
 * When the user does not meet those conditions, events are not tracked.
 *
 * This method sends conversion data to Optimizely but doesn't return any values. 
 * 
 * For more information, see https://docs.developers.optimizely.com/full-stack/docs/track.
 *
 * @param eventKey The key of the event to be tracked. This key must match the event key provided
 *                 when the event was created in the Optimizely app.
 * @param userId   The ID of the user associated with the event being tracked. This ID must match the 
 *                 user ID provided to `activate` or `isFeatureEnabled`.
 */
- (void)track:(nonnull NSString *)eventKey
       userId:(nonnull NSString *)userId;

/**
 * Tracks a conversion event for a user whose attributes meet the audience conditions for an experiment. 
 * When the user does not meet those conditions, events are not tracked.
 *
 * This method takes into account the user `attributes` passed in, to determine if the user is part of the audience that qualifies for the experiment.
 *
 * This method sends conversion data to Optimizely but doesn't return any values. 
 *
 * For more information, see https://docs.developers.optimizely.com/full-stack/docs/track.
 *
 * @param eventKey   The key of the event to be tracked. This key must match the event key provided
 *                   when the event was created in the Optimizely app.
 * @param userId     The ID of the user associated with the event being tracked. This ID must match the
 *                   user ID provided to `activate` or `isFeatureEnabled`.
 * @param attributes A map of custom key-value string pairs specifying attributes for the user.
 */
- (void)track:(nonnull NSString *)eventKey
       userId:(nonnull NSString *)userId
   attributes:(nonnull NSDictionary<NSString *, id> *)attributes;

/**
 * Tracks a conversion event for a user whose attributes meet the default audience conditions for an experiment. 
 * When the user does not meet those conditions, events are not tracked.
 *
 * This method sends conversion data to Optimizely but doesn't return any values. 
 *
 * For more information, see https://docs.developers.optimizely.com/full-stack/docs/track.
 *
 * @param eventKey   The key of the event to be tracked. This key must match the event key provided
 *                   when the event was created in the Optimizely app.
 * @param userId     The ID of the user associated with the event being tracked.
 * @param eventTags  A map of key-value string pairs specifying event names and their corresponding event values
 *                   associated with the event.
 */
- (void)track:(nonnull NSString *)eventKey
       userId:(nonnull NSString *)userId
    eventTags:(nonnull NSDictionary<NSString *, id> *)eventTags;

/**
 * Tracks a conversion event for a user whose attributes meet the audience conditions for an experiment. 
 * When the user does not meet those conditions, events are not tracked.
 *
 * This method takes into account the user `attributes` passed in, to determine if the user is part of the audience that qualifies for the experiment. 
 *
 * This method sends conversion data to Optimizely but doesn't return any values. 
 *
 * For more information, see https://docs.developers.optimizely.com/full-stack/docs/track.
 *
 * @param eventKey   The key of the event to be tracked. This key must match the event key provided
 *                   when the event was created in the Optimizely app.
 * @param userId     The ID of the user associated with the event being tracked.
 * @param attributes A map of custom key-value string pairs specifying attributes for the user.
 * @param eventTags  A map of key-value string pairs specifying event names and their corresponding event values
 *                   associated with the event.
 */
- (void)track:(nonnull NSString *)eventKey
       userId:(nonnull NSString *)userId
   attributes:(nullable NSDictionary<NSString *, id> *)attributes
    eventTags:(nullable NSDictionary<NSString *, id> *)eventTags;

@end

/**
 * This class defines the Optimizely SDK interface.
 * Optimizely Instance
 */
@interface Optimizely : NSObject <Optimizely>

@property (nonatomic, strong, readonly, nullable) id<OPTLYBucketer> bucketer;
@property (nonatomic, strong, readonly, nullable) OPTLYDecisionService *decisionService;
@property (nonatomic, strong, readonly, nullable) OPTLYProjectConfig *config;
@property (nonatomic, strong, readonly, nullable) id<OPTLYErrorHandler> errorHandler;
@property (nonatomic, strong, readonly, nullable) id<OPTLYEventBuilder> eventBuilder;
@property (nonatomic, strong, readonly, nullable) id<OPTLYEventDispatcher> eventDispatcher;
@property (nonatomic, strong, readonly, nullable) id<OPTLYLogger> logger;
@property (nonatomic, strong, readonly, nullable) id<OPTLYUserProfileService> userProfileService;
@property (nonatomic, strong, readonly, nullable) OPTLYNotificationCenter *notificationCenter;

/**
 * Instantiate and initialize an `Optimizely` instance using a builder block.
 *
 * @param builderBlock A builder block through which a logger, errorHandler, and eventDispatcher can be set.
 *
 * @return             Optimizely instance.
 */
+ (nullable instancetype)init:(nonnull OPTLYBuilderBlock)builderBlock
__attribute((deprecated("Use Optimizely initWithBuilder method instead.")));

/**
 * Instantiate and initialize an `Optimizely` instance using a builder.
 *
 * @param builder An OPTLYBuilder object containing a logger, errorHandler, and eventDispatcher to use for the Optimizely client object.
 * 
 * @return        Optimizely instance.
 */
- (nullable instancetype)initWithBuilder:(nullable OPTLYBuilder *)builder;

/**
 * Tracks a conversion event.
 *
 * @param eventKey   The key of the event to be tracked. This key must match the event key provided
 *                   when the event was created in the Optimizely app.
 * @param userId     The ID of the user associated with the event being tracked.
 * @param attributes A map of custom key-value string pairs specifying attributes for the user.
 * @param eventTags  A map of key-value string pairs specifying event names and their corresponding event values
 *                   associated with the event.
 *
 * See https://docs.developers.optimizely.com/full-stack/docs/track for more information.
 */
- (void)track:(nonnull NSString *)eventKey
       userId:(nonnull NSString *)userId
   attributes:(nullable NSDictionary<NSString *, id> *)attributes
    eventTags:(nullable NSDictionary<NSString *, id> *)eventTags;

@end
