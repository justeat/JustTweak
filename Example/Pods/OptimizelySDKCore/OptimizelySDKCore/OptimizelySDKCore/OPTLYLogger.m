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

#import "OPTLYLogger.h"

NSString *const OPTLYLogLevelCriticalTag = @"CRITICAL";
NSString *const OPTLYLogLevelErrorTag = @"ERROR";
NSString *const OPTLYLogLevelWarningTag = @"WARNING";
NSString *const OPTLYLogLevelInfoTag = @"INFO";
NSString *const OPTLYLogLevelDebugTag = @"DEBUG";
NSString *const OPTLYLogLevelVerboseTag = @"VERBOSE";

@implementation OPTLYLoggerUtility

+ (BOOL)conformsToOPTLYLoggerProtocol:(Class)instanceClass
{
    // compile-time check
    BOOL isValidProtocolDeclaration = [instanceClass conformsToProtocol:@protocol(OPTLYLogger)];
    
    // runtime checks
    BOOL implementsLogLevelProperty = [instanceClass instancesRespondToSelector:@selector(logLevel)];
    BOOL implementsInitWithLogLevelMethod = [instanceClass instancesRespondToSelector:@selector(initWithLogLevel:)];
    BOOL implementsLogMessageMethod = [instanceClass instancesRespondToSelector:@selector(logMessage:withLevel:)];
    
    return isValidProtocolDeclaration && implementsLogLevelProperty && implementsInitWithLogLevelMethod && implementsLogMessageMethod;
}
@end

@implementation OPTLYLoggerDefault

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        _logLevel = OptimizelyLogLevelInfo;         // default log level is info
    }
    return self;
}

- (instancetype)initWithLogLevel:(OptimizelyLogLevel) logLevel {
    self = [super init];
    if (self != nil) {
        _logLevel = logLevel;
    }
    return self;
}

- (void)logMessage:(NSString *)message withLevel:(OptimizelyLogLevel)level {
    if (level > self.logLevel) {
        return;
    }
    else {
        NSString *levelTag = @"";
        switch ((int)level) {
            case (int)OptimizelyLogLevelCritical:
                levelTag = OPTLYLogLevelCriticalTag;
                break;
            case (int)OptimizelyLogLevelError:
                levelTag = OPTLYLogLevelErrorTag;
                break;
            case (int)OptimizelyLogLevelWarning:
                levelTag = OPTLYLogLevelWarningTag;
                break;
            case (int)OptimizelyLogLevelInfo:
                levelTag = OPTLYLogLevelInfoTag;
                break;
            case (int)OptimizelyLogLevelDebug:
                levelTag = OPTLYLogLevelDebugTag;
                break;
            case (int)OptimizelyLogLevelVerbose:
                levelTag = OPTLYLogLevelVerboseTag;
            default:
                break;
        }
        NSLog(@"[OPTIMIZELY SDK][%@]:%@", levelTag, message);

        return;
    }
}

@end
