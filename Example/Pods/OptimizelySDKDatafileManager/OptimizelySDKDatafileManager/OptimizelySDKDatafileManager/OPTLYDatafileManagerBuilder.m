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

#import "OPTLYDatafileManagerBuilder.h"
#ifdef UNIVERSAL
    #import "OPTLYErrorHandler.h"
    #import "OPTLYLogger.h"
    #import "OPTLYLoggerMessages.h"
    #import "OPTLYDatafileConfig.h"
#else
    #import <OptimizelySDKCore/OPTLYErrorHandler.h>
    #import <OptimizelySDKCore/OPTLYLogger.h>
    #import <OptimizelySDKCore/OPTLYLoggerMessages.h>
#endif

@implementation OPTLYDatafileManagerBuilder

+ (instancetype)builderWithBlock:(OPTLYDatafileManagerBuilderBlock)block {
    return [[self alloc] initWithBlock:block];
}

- (id) init {
    return [self initWithBlock:nil];
}

- (id)initWithBlock:(OPTLYDatafileManagerBuilderBlock)block {
    NSParameterAssert(block);
    self = [super init];
    if (self != nil) {
        block(self);
        if (_datafileFetchInterval < 0) {
            [self.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesDatafileFetchIntervalInvalid, _datafileFetchInterval]
                          withLevel:OptimizelyLogLevelError];
            return nil;
        }
        if (_datafileConfig == nil) {
            [self.logger logMessage:OPTLYLoggerMessagesDatafileManagerInitializedWithoutProjectIdMessage
                          withLevel:OptimizelyLogLevelWarning];
            return nil;
        }
    }
    return self;
}

- (NSTimeInterval)datafileFetchInterval {
    if (!_datafileFetchInterval) {
        // set default datafile Fetch interval to 0 so we never poll for the datafile
        _datafileFetchInterval = 0;
    }
    return _datafileFetchInterval;
}

- (id<OPTLYLogger>)logger {
    if (!_logger) {
        _logger = [[OPTLYLoggerDefault alloc] initWithLogLevel:OptimizelyLogLevelAll];
    }
    return _logger;
}

- (id<OPTLYErrorHandler>)errorHandler {
    if (!_errorHandler) {
        _errorHandler = [[OPTLYErrorHandlerNoOp alloc] init];
    }
    return _errorHandler;
}

@end
