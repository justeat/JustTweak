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
#import "OPTLYLoggerMessages.h"

/**
 * These are the various Optimizely Log Levels.
 * Normally, when messages are logged with priority levels greater than the filter level, they will be suppressed.
 */

typedef NS_ENUM(NSUInteger, OptimizelyLogLevel) {
    /// If the filter level is set to OptimizelyLogLevelOff, all log messages will be suppressed.
    OptimizelyLogLevelOff = 0,
    /// Any error that is causing a crash of the application.
    OptimizelyLogLevelCritical = 1,
    /// Any error that is not causing a crash of the application: unknown experiment referenced.
    OptimizelyLogLevelError = 2,
    /// Anything that can potentially cause problems: method will be deprecated.
    OptimizelyLogLevelWarning = 3,
    /// Useful information: Lifecycle events, successfully activated experiment, parsed datafile.
    OptimizelyLogLevelInfo= 4,
    /// Information diagnostically helpful: sending events, assigning buckets.
    OptimizelyLogLevelDebug = 5,
    /// Used for the most granular logging: method flows, variable values.
    OptimizelyLogLevelVerbose = 6,
    /// If the filter level is set to OptimizelyLogLevelAll, no log messages will be suppressed.
    OptimizelyLogLevelAll = 7,
};

NS_ASSUME_NONNULL_BEGIN
extern NSString *const OPTLYLogLevelCriticalTag;
extern NSString *const OPTLYLogLevelErrorTag;
extern NSString *const OPTLYLogLevelWarningTag;
extern NSString *const OPTLYLogLevelInfoTag;
extern NSString *const OPTLYLogLevelDebugTag;
extern NSString *const OPTLYLogLevelVerboseTag;
NS_ASSUME_NONNULL_END

/**
 * Any logger must implement these following methods.
 */
@protocol OPTLYLogger <NSObject>

/// The log level the Logger is initialized with.
@property (readonly) OptimizelyLogLevel logLevel;

/**
 * Initialize a new Optimizely Logger instance.
 */
- (nullable instancetype)initWithLogLevel:(OptimizelyLogLevel)logLevel;

/**
 Log a message at a certain level.
 @param message The message to log.
 @param level The priority level of the log.
 */
- (void)logMessage:(nonnull NSString *)message withLevel:(OptimizelyLogLevel)level;

@end

@interface OPTLYLoggerUtility : NSObject
/**
 * Utility method to check if a class conforms to the OPTLYLogger protocol
 * This method uses compile and run time checks
 */
+ (BOOL)conformsToOPTLYLoggerProtocol:(nonnull Class)instanceClass;
@end

/**
 * Default logger that logs info level values.
 */
@interface OPTLYLoggerDefault : NSObject <OPTLYLogger>

/// The log you initialize the logger with.
@property (readonly) OptimizelyLogLevel logLevel;

@end
