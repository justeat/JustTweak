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
#import "OPTLYErrorHandler.h"
#import "OPTLYEventDispatcher.h"
#import "OPTLYLogger.h"
#import "OPTLYLoggerMessages.h"
#else
#import <OptimizelySDKCore/OPTLYExperiment.h>
#import <OptimizelySDKCore/OPTLYProjectConfig.h>
#import <OptimizelySDKCore/OPTLYErrorHandler.h>
#import <OptimizelySDKCore/OPTLYEventDispatcherBasic.h>
#import <OptimizelySDKCore/OPTLYLogger.h>
#import <OptimizelySDKCore/OPTLYLoggerMessages.h>
#endif
#import "OPTLYDatafileConfig.h"
#import "OPTLYClient.h"
#import "OPTLYDatafileManagerBasic.h"
#import "OPTLYManagerBase.h"
#import "OPTLYManagerBuilder.h"

@import UIKit;

// Currently, Optimizely only supports tvOS and iOS, but this #if...#endif
// could be elaborated with TARGET_OS_MAC or TARGET_OS_WATCH also defined in
// usr/include/TargetConditionals.h in the future if the need should arise.
#if TARGET_OS_TV
// Code compiled only when building for tvOS.
NSString * _Nonnull const OptimizelyAppVersionKey = @"optimizely_tvos_app_version";
NSString * _Nonnull const OptimizelyDeviceModelKey = @"optimizely_tvos_device_model";
NSString * _Nonnull const OptimizelyOSVersionKey = @"optimizely_tvos_os_version";
NSString * _Nonnull const OptimizelySDKVersionKey = @"optimizely_tvos_sdk_version";
#else
// for iOS
NSString * _Nonnull const OptimizelyAppVersionKey = @"optimizely_ios_app_version";
NSString * _Nonnull const OptimizelyDeviceModelKey = @"optimizely_ios_device_model";
NSString * _Nonnull const OptimizelyOSVersionKey = @"optimizely_ios_os_version";
NSString * _Nonnull const OptimizelySDKVersionKey = @"optimizely_ios_sdk_version";
#endif

NSString * _Nonnull const OptimizelyBundleDatafilePrefix = @"optimizely";
NSString * _Nonnull const OptimizelyBundleDatafileFileTypeExtension = @"json";

@interface OPTLYManagerBase()
@property (strong, readwrite, nonatomic, nullable) OPTLYClient *optimizelyClient;
/// Version number of the Optimizely iOS SDK
@property (nonatomic, readwrite, strong, nonnull) NSString *clientVersion;
/// iOS Device Model
@property (nonatomic, readwrite, strong, nonnull) NSString *deviceModel;
/// iOS OS Version
@property (nonatomic, readwrite, strong, nonnull) NSString *osVersion;
/// iOS App Version
@property (nonatomic, readwrite, strong, nonnull) NSString *appVersion;
@end

@implementation OPTLYManagerBase

- (void)cleanUserProfileService:(NSArray<OPTLYExperiment *><OPTLYExperiment> *)experiments {
    if (experiments == nil) return;
    
    SEL selector = NSSelectorFromString(@"removeInvalidExperimentsForAllUsers:");
    
    if (_userProfileService != nil && [(NSObject *)_userProfileService respondsToSelector:selector]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (self.userProfileService != nil) {
                NSMutableArray<NSString*> *ids = [[NSMutableArray alloc] initWithCapacity:experiments.count];
                for (int i = 0; i < experiments.count; i++) {
                    NSString *exKey = ((OPTLYExperiment *)experiments[i]).experimentId;
                    [ids addObject:exKey];
                }
// can't suppress the warning because travis-ci keeps complaining.
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                @try {
                    // cast to NSObject.  If the user profile service is not the default service, then an exception will be thrown when trying to access this selector.
                    IMP imp = [((NSObject *)(self.userProfileService)).class instanceMethodForSelector:selector];
                    // cast the function
                    void (*func)(id, SEL, NSArray *) = (void *)imp;
                    // call it.
                    func(self.userProfileService, selector, ids);
                }
                @catch(NSException *e) {
                    [self.logger logMessage:@"Error cleaning up user profile service" withLevel:OptimizelyLogLevelError];
                }
//#pragma clang diagnostic pop
            }
        });
    }
}

#pragma mark - Constructors

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        // _clientVersion is properly initialized by OPTLYManager subclass .
        // _clientVersion starts life initialized to empty string which is better
        // for unit testing (XCTest).
        _clientVersion = @"";
        _deviceModel = [[[UIDevice currentDevice] model] copy];
        _osVersion = [[[UIDevice currentDevice] systemVersion] copy];
        {
            // Get _appVersion from the app's main bundle
            NSDictionary *dict = [[NSBundle mainBundle] infoDictionary];
            _appVersion = [dict[@"CFBundleShortVersionString"] copy];
            if (_appVersion == nil) {
                // This will happen if there is no @"CFBundleShortVersionString" key in dict,
                // which will be the case during unit testing (XCTest).  Empty string seems
                // like the best default alternative to nil since empty string but not nil can
                // be stuffed as a value in defaultAttributes .
                _appVersion = @"";
            }
        }
    };
    return self;
}

#pragma mark - Client Getters

- (OPTLYClient *)initialize {
    [self.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesManagerInit, self.projectId, self.sdkKey]
                  withLevel:OptimizelyLogLevelInfo];
    
    // attempt to get the cached datafile
    NSData *data = [self.datafileManager getSavedDatafile:nil];
    BOOL cleanUserProfile = NO;
    // fall back to the datafile provided by the manager builder if we can't get the saved datafile
    if (data == nil) {
        data = self.datafile;
        [self.logger logMessage:OPTLYLoggerMessagesManagerBundledDataLoaded withLevel:OptimizelyLogLevelInfo]; 
    }
    else {
        // cleanup user profile service in background
        cleanUserProfile = YES;
    }
    
    OPTLYClient *client = [self initializeWithDatafile:data];
    
    if (cleanUserProfile) {
        [self cleanUserProfileService:client.optimizely.config.experiments];
    }

    return client;
}

- (OPTLYClient *)initializeWithDatafile:(NSData *)datafile {
    self.optimizelyClient = [self initializeClientWithManagerSettingsAndDatafile:datafile];
    return self.optimizelyClient;
}

- (void)initializeWithCallback:(void (^)(NSError * _Nullable, OPTLYClient * _Nullable))callback {
    [self.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesManagerInitWithCallback, self.projectId, self.sdkKey]
                  withLevel:OptimizelyLogLevelInfo];
    
    [self.datafileManager downloadDatafile:self.datafileConfig completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            [self.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesManagerInitWithCallbackErrorDatafileDownload, error.localizedDescription]
                          withLevel:OptimizelyLogLevelError];
            data = [self.datafileManager getSavedDatafile:&error];
        } else {
            // 304 response code means there is not datafile updates
            if ([(NSHTTPURLResponse *)response statusCode] == 304) {
                [self.logger logMessage:OPTLYLoggerMessagesManagerInitWithCallbackNoDatafileUpdates
                              withLevel:OptimizelyLogLevelError];
                data = [self.datafileManager getSavedDatafile:&error];
            }
        }
        
        // fall back to the datafile provided by the manager builder if we can't get the saved datafile
        BOOL cleanUserProfileService = NO;
        if (data == nil) {
            data = self.datafile;
            [self.logger logMessage:OPTLYLoggerMessagesManagerBundledDataLoaded withLevel:OptimizelyLogLevelInfo];
        }
        else {
            // update user profile service in the background.
            cleanUserProfileService = YES;
        }
        
        OPTLYClient *client = [self initializeWithDatafile:data];
        
        if (cleanUserProfileService) {
            [self cleanUserProfileService:client.optimizely.config.experiments];
        }
        
        if (callback) {
            callback(error, client);
        }
    }];
}

- (OPTLYClient *)getOptimizely {
    return self.optimizelyClient;
}

- (nonnull NSDictionary *)newDefaultAttributes {
    return @{OptimizelyDeviceModelKey:_deviceModel,
             OptimizelySDKVersionKey:_clientVersion,
             OptimizelyOSVersionKey:_osVersion,
             OptimizelyAppVersionKey:_appVersion};
}

- (OPTLYClient *)initializeClientWithManagerSettingsAndDatafile:(NSData *)datafile {
    OPTLYClient *client = [[OPTLYClient new] initWithBuilder:[OPTLYClientBuilder builderWithBlock:^(OPTLYClientBuilder * _Nonnull builder) {
        builder.datafile = datafile;
        builder.errorHandler = self.errorHandler;
        builder.eventDispatcher = self.eventDispatcher;
        builder.logger = self.logger;
        builder.userProfileService = self.userProfileService;
        builder.clientEngine = self.clientEngine;
        builder.clientVersion = self.clientVersion;
    }]];
    client.defaultAttributes = [self newDefaultAttributes];
    return client;
}

#pragma mark - Helper Methods

- (NSString *)description {
    return [NSString stringWithFormat:@"projectId: %@ \nclientEngine: %@\nclientVersion: %@\ndatafile:%@\nlogger:%@\nerrorHandler:%@\ndatafileManager:%@\neventDispatcher:%@\nuserProfile:%@", self.projectId, self.clientEngine, self.clientVersion, self.datafile, self.logger, self.errorHandler, self.datafileManager, self.eventDispatcher, self.userProfileService];
}
@end
