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
    #import "Optimizely.h"
    #import "OPTLYLogger.h"
#else
    #import <OptimizelySDKCore/Optimizely.h>
    #import <OptimizelySDKCore/OPTLYLogger.h>
#endif
#import "OPTLYClientBuilder.h"

@implementation OPTLYClientBuilder: NSObject

+ (instancetype)builderWithBlock:(OPTLYClientBuilderBlock)block {
    return [[self alloc] initWithBlock:block];
}

- (id)init {
    return [self initWithBlock:nil];
}

- (id)initWithBlock:(OPTLYClientBuilderBlock)block {
    self = [super init];
    if (self) {
        if (block != nil) {
            block(self);
        }
        _optimizely = [[Optimizely alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:^(OPTLYBuilder * _Nullable builder) {
            builder.datafile = self->_datafile;
            builder.errorHandler = self->_errorHandler;
            builder.eventDispatcher = self->_eventDispatcher;
            builder.logger = self->_logger;
            builder.userProfileService = self->_userProfileService;
            builder.clientEngine = self->_clientEngine;
            builder.clientVersion = self->_clientVersion;
        }]];
        _logger = _optimizely.logger;
        if (!_logger) {
            _logger = [[OPTLYLoggerDefault alloc] initWithLogLevel:OptimizelyLogLevelAll];
        }
    }
    return self;
}

@end
