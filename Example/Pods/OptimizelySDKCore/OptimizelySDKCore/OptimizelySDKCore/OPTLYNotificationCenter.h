/****************************************************************************
 * Copyright 2018-2019, Optimizely, Inc. and contributors                   *
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

@class OPTLYProjectConfig, OPTLYExperiment, OPTLYVariation;

/// Enum representing notification types.
typedef NS_ENUM(NSUInteger, OPTLYNotificationType) {
    OPTLYNotificationTypeActivate,
    OPTLYNotificationTypeTrack,
    OPTLYNotificationTypeDecision
};

typedef void (^ActivateListener)(OPTLYExperiment * _Nonnull experiment,
                                 NSString * _Nonnull userId,
                                 NSDictionary<NSString *, id> * _Nullable attributes,
                                 OPTLYVariation * _Nonnull variation,
                                 NSDictionary<NSString *,id> * _Nonnull event) __deprecated;

typedef void (^TrackListener)(NSString * _Nonnull eventKey,
                              NSString * _Nonnull userId,
                              NSDictionary<NSString *, id> * _Nullable attributes,
                              NSDictionary * _Nullable eventTags,
                              NSDictionary<NSString *,id> * _Nonnull event);

typedef void (^DecisionListener)(NSString * _Nonnull type,
                                 NSString * _Nonnull userId,
                                 NSDictionary<NSString *, id> * _Nullable attributes,
                                 NSDictionary<NSString *,id> * _Nonnull decisionInfo);

typedef void (^GenericListener)(NSDictionary * _Nonnull args);

typedef NSMutableDictionary<NSNumber *, GenericListener > OPTLYNotificationHolder;

extern NSString * _Nonnull const OPTLYNotificationExperimentKey;
extern NSString * _Nonnull const OPTLYNotificationVariationKey;
extern NSString * _Nonnull const OPTLYNotificationUserIdKey;
extern NSString * _Nonnull const OPTLYNotificationAttributesKey;
extern NSString * _Nonnull const OPTLYNotificationEventKey;
extern NSString * _Nonnull const OPTLYNotificationEventTagsKey;
extern NSString * _Nonnull const OPTLYNotificationLogEventParamsKey;
extern NSString * _Nonnull const OPTLYNotificationDecisionTypeKey;

struct DecisionInfoStruct {
    NSString * _Nonnull const FeatureKey;
    NSString * _Nonnull const FeatureEnabledKey;
    NSString * _Nonnull const Key;
    NSString * _Nonnull const SourceKey;
    NSString * _Nonnull const SourceInfoKey;
    NSString * _Nonnull const VariableKey;
    NSString * _Nonnull const VariableTypeKey;
    NSString * _Nonnull const VariableValueKey;
};
extern const struct DecisionInfoStruct DecisionInfo;

struct ExperimentDecisionInfoStruct {
    NSString * _Nonnull const ExperimentKey;
    NSString * _Nonnull const VariationKey;
};
extern const struct ExperimentDecisionInfoStruct ExperimentDecisionInfo;

/// Notification decision types.
extern NSString * _Nonnull const OPTLYDecisionTypeABTest;
extern NSString * _Nonnull const OPTLYDecisionTypeFeature;
extern NSString * _Nonnull const OPTLYDecisionTypeFeatureVariable;
extern NSString * _Nonnull const OPTLYDecisionTypeFeatureTest;

@interface OPTLYNotificationCenter : NSObject

// Notification Id represeting id of notification.
@property (nonatomic, readonly) NSUInteger notificationId;

/**
 * Initializer for the Notification Center.
 *
 * @param config The project configuration.
 * @return An instance of the notification center.
 */
- (nullable instancetype)initWithProjectConfig:(nonnull OPTLYProjectConfig *)config;

/**
 * Add an activate notification listener to the notification center.
 *
 * @param activateListener - Notification to add.
 * @return the notification id used to remove the notification. It is greater than 0 on success.
 */
- (NSInteger)addActivateNotificationListener:(nonnull ActivateListener)activateListener __deprecated_msg("Use DecisionListener instead");

/**
 * Add a track notification listener to the notification center.
 *
 * @param trackListener - Notification to add.
 * @return the notification id used to remove the notification. It is greater than 0 on success.
 */
- (NSInteger)addTrackNotificationListener:(TrackListener _Nonnull )trackListener;

/**
 * Add a decision notification listener to the notification center.
 *
 * @param decisionListener - Notification to add.
 * @return the notification id used to remove the notification. It is greater than 0 on success.
 */
- (NSInteger)addDecisionNotificationListener:(nonnull DecisionListener)decisionListener;

/**
 * Remove the notification listener based on the notificationId passed back from addNotification.
 * @param notificationId the id passed back from add notification.
 * @return true if removed otherwise false (if the notification is already removed, it returns false).
 */
- (BOOL)removeNotificationListener:(NSUInteger)notificationId;

/**
 * Clear notification listeners by notification type.
 * @param type type of OPTLYNotificationType to remove.
 */
- (void)clearNotificationListeners:(OPTLYNotificationType)type;

/**
 * Clear out all the notification listeners.
 */
- (void)clearAllNotificationListeners;

//
/**
 * fire notificaitons of a certain type.
 * @param type type of OPTLYNotificationType to fire.
 * @param args The arg list changes depending on the type of notification sent.
 */
- (void)sendNotifications:(OPTLYNotificationType)type args:(nullable NSDictionary *)args;
@end
