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
    #import "OPTLYDatafileManager.h"
    #import "OPTLYErrorHandler.h"
    #import "OPTLYEventDispatcher.h"
    #import "OPTLYLogger.h"
    #import "OPTLYManagerBuilder.h"
    #import "OPTLYUserProfileService.h"
#else
    #import <OptimizelySDKCore/OPTLYErrorHandler.h>
    #import <OptimizelySDKCore/OPTLYLogger.h>
    #import <OptimizelySDKDatafileManager/OPTLYDatafileManager.h>
    #import <OptimizelySDKEventDispatcher/OPTLYEventDispatcher.h>
    #import <OptimizelySDKShared/OPTLYManagerBuilder.h>
    #import <OptimizelySDKUserProfileService/OPTLYUserProfileService.h>
#endif

#import "OPTLYManager.h"

static NSString * const kClientEngine = @"ios-sdk";

@implementation OPTLYManager

#pragma mark - Constructors

+ (instancetype)init:(OPTLYManagerBuilderBlock)block {
    return [OPTLYManager initWithBuilder:[OPTLYManagerBuilder builderWithBlock:block]];
}

+ (instancetype)initWithBuilder:(OPTLYManagerBuilder *)builder {
    return [[self alloc] initWithBuilder:builder];
}

- (instancetype)init {
    return [self initWithBuilder:nil];
}

- (instancetype)initWithBuilder:(OPTLYManagerBuilder *)builder {
    self = [super init];
    if (self != nil) {

        // --- logger ---
        if (!builder.logger) {
            self.logger = [OPTLYLoggerDefault new];
        } else {
            self.logger = builder.logger;
        }
        
        // --- error handler ---
        if (!builder.errorHandler) {
            self.errorHandler = [OPTLYErrorHandlerNoOp new];
        } else {
            self.errorHandler = builder.errorHandler;
        }
        
        // check if the builder is nil
        if (!builder) {
            [self.logger logMessage:OPTLYLoggerMessagesManagerBuilderNotValid
                          withLevel:OptimizelyLogLevelError];
            
            NSError *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                                 code:OPTLYErrorTypesBuilderInvalid
                                             userInfo:@{NSLocalizedDescriptionKey :
                                                            [NSString stringWithFormat:NSLocalizedString(OPTLYErrorHandlerMessagesManagerBuilderInvalid, nil)]}];
            [self.errorHandler handleError:error];
            
            return nil;
        }
        
        // --- datafile ----
        self.datafile = builder.datafile;
        
        // --- project id ---
        self.projectId = builder.projectId;
        
        self.sdkKey = builder.sdkKey;
        
        self.datafileConfig = [[OPTLYDatafileConfig alloc] initWithProjectId:self.projectId withSDKKey:self.sdkKey];
        
        // --- datafile manager ---
        if (!builder.datafileManager) {
            // set default datafile manager if no datafile manager is set            
            self.datafileManager = [[OPTLYDatafileManagerDefault alloc] initWithBuilder:[OPTLYDatafileManagerBuilder builderWithBlock:^(OPTLYDatafileManagerBuilder * _Nullable builder) {
                builder.datafileConfig = self.datafileConfig;
                builder.errorHandler = self.errorHandler;
                builder.logger = self.logger;
            }]];
        } else {
            self.datafileManager = builder.datafileManager;
        }
        
        // --- event dispatcher ---
        if (!builder.eventDispatcher) {
            // set default event dispatcher if no event dispatcher is set
            self.eventDispatcher = [[OPTLYEventDispatcherDefault alloc] initWithBuilder:[OPTLYEventDispatcherBuilder builderWithBlock:^(OPTLYEventDispatcherBuilder * _Nullable builder) {
                builder.logger = self.logger;
            }]];
        } else {
            self.eventDispatcher = builder.eventDispatcher;
        }
        
        // --- user profile ---
        if (!builder.userProfileService) {
            // set default user profile if no user profile is set
            self.userProfileService = [[OPTLYUserProfileServiceDefault alloc] initWithBuilder:[OPTLYUserProfileServiceBuilder builderWithBlock:^(OPTLYUserProfileServiceBuilder * _Nullable builder) {
                builder.logger = self.logger;
            }]];
        } else {
            self.userProfileService = builder.userProfileService;
        }
        
        // --- client engine ---
        _clientEngine = kClientEngine;
        
        // --- client version ---
#ifdef UNIVERSAL
        _clientVersion = OPTIMIZELY_SDK_VERSION;
#else
        _clientVersion = OPTIMIZELY_SDK_VERSION;
#endif
    }
    return self;
}

@end
