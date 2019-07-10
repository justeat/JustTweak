#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Default event name for when an experiment is set.
extern NSString *const FIRSetExperimentEventName NS_SWIFT_NAME(DefaultSetExperimentEventName);
/// Default event name for when an experiment is activated.
extern NSString *const FIRActivateExperimentEventName
    NS_SWIFT_NAME(DefaultActivateExperimentEventName);
/// Default event name for when an experiment is cleared.
extern NSString *const FIRClearExperimentEventName
    NS_SWIFT_NAME(DefaultClearExperimentEventName);
/// Default event name for when an experiment times out for being activated.
extern NSString *const FIRTimeoutExperimentEventName
    NS_SWIFT_NAME(DefaultTimeoutExperimentEventName);
/// Default event name for when an experiment is expired as it reaches the end of TTL.
extern NSString *const FIRExpireExperimentEventName
    NS_SWIFT_NAME(DefaultExpireExperimentEventName);

/// An Experiment Lifecycle Event Object that specifies the name of the experiment event to be
/// logged by Firebase Analytics.
NS_SWIFT_NAME(LifecycleEvents)
@interface FIRLifecycleEvents : NSObject

/// Event name for when an experiment is set. It is default to FIRSetExperimentEventName and can be
/// overriden. If experiment payload has a valid string of this field, always use experiment
/// payload.
@property(nonatomic, copy) NSString *setExperimentEventName;

/// Event name for when an experiment is activated. It is default to FIRActivateExperimentEventName
/// and can be overriden. If experiment payload has a valid string of this field, always use
/// experiment payload.
@property(nonatomic, copy) NSString *activateExperimentEventName;

/// Event name for when an experiment is clearred. It is default to FIRClearExperimentEventName and
/// can be overriden. If experiment payload has a valid string of this field, always use experiment
/// payload.
@property(nonatomic, copy) NSString *clearExperimentEventName;
/// Event name for when an experiment is timeout from being STANDBY. It is default to
/// FIRTimeoutExperimentEventName and can be overriden. If experiment payload has a valid string
/// of this field, always use experiment payload.
@property(nonatomic, copy) NSString *timeoutExperimentEventName;

/// Event name when an experiment is expired when it reaches the end of its TTL.
/// It is default to FIRExpireExperimentEventName and can be overriden. If experiment payload has a
/// valid string of this field, always use experiment payload.
@property(nonatomic, copy) NSString *expireExperimentEventName;

@end

NS_ASSUME_NONNULL_END
