/****************************************************************************
 * Copyright 2016-2019 Optimizely, Inc. and contributors                   *
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

/*
 This class packages the parameters for impression and conversion events sent to the backend.
 */

#import <Foundation/Foundation.h>

@class OPTLYProjectConfig, OPTLYExperiment, OPTLYVariation, OPTLYEvent;

// --- Event URLs ----
NS_ASSUME_NONNULL_BEGIN
extern NSString * const OptimizelyActivateEventKey;
extern NSString * const OPTLYEventBuilderEventsTicketURL;
NS_ASSUME_NONNULL_END

@protocol OPTLYEventBuilder <NSObject>

/**
 * Create the parameters for an impression event.
 *
 * @param userId The ID of the user.
 * @param experiment The experiment.
 * @param variation The variation.
 * @param attributes A map of attribute names to current user attribute values.
 * @return A map of parameters for an impression event. This value can be nil.
 *
 */
- (nullable NSDictionary *)buildImpressionEventForUser:(nonnull NSString *)userId
                                            experiment:(nonnull OPTLYExperiment *)experiment
                                             variation:(nonnull OPTLYVariation *)variation
                                            attributes:(nullable NSDictionary<NSString *, id> *)attributes;
   
/**
 * Create the parameters for a conversion event.
 *
 * @param userId The ID of the user.
 * @param event The event name.
 * @param eventTags A map of event tag names to event tag values (NSString or NSNumber containing float, double, integer, or boolean).
 * @param attributes A map of attribute names to current user attribute values.
 * @return A map of parameters for a conversion event. This value can be nil.
 *
 */
- (nullable NSDictionary *)buildConversionEventForUser:(nonnull NSString *)userId
                                                 event:(nonnull OPTLYEvent *)event
                                             eventTags:(nullable NSDictionary *)eventTags
                                            attributes:(nullable NSDictionary<NSString *, id> *)attributes;
@end

@interface OPTLYEventBuilderDefault : NSObject<OPTLYEventBuilder>

/// init is disabled. Please use initWithConfig to create an Event Builder
- (nonnull instancetype)init NS_UNAVAILABLE;

/**
 * Initialize the default event build with the project config.
 * @param config The project config that the event builder will use for event building.
 * @return The event builder that has been created.
 */
- (nullable instancetype)initWithConfig:(nonnull OPTLYProjectConfig *)config;

@end
