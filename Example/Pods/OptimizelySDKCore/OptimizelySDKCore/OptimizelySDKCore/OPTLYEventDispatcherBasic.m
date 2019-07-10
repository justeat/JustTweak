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
#import "OPTLYErrorHandler.h"
#import "OPTLYEventDispatcherBasic.h"
#import "OPTLYProjectConfig.h"
#import "OPTLYNetworkService.h"

static NSString * const kEventDispatcherImpressionEventURL   = @"https://logx.optimizely.com/log/decision";
static NSString * const kEventDispatcherConversionEventURL   = @"https://logx.optimizely.com/log/event";

static NSString * const kHTTPRequestMethodPost = @"POST";
static NSString * const kHTTPHeaderFieldContentType = @"Content-Type";
static NSString * const kHTTPHeaderFieldValueApplicationJSON = @"application/json";

@implementation OPTLYEventDispatcherUtility

+ (BOOL)conformsToOPTLYEventDispatcherProtocol:(Class)instanceClass
{
    // compile-time check
    BOOL isValidProtocolDeclaration = [instanceClass conformsToProtocol:@protocol(OPTLYEventDispatcher)];
    
    // runtime checks
    BOOL implementsDispatchImpressionEventMethod = [instanceClass instancesRespondToSelector:@selector(dispatchImpressionEvent:callback:)];
    BOOL implementsDispatchConversionEventMethod = [instanceClass instancesRespondToSelector:@selector(dispatchConversionEvent:callback:)];
    
    return isValidProtocolDeclaration && implementsDispatchImpressionEventMethod && implementsDispatchConversionEventMethod;
}

@end

@implementation OPTLYEventDispatcherBasic

- (void)dispatchImpressionEvent:(nonnull NSDictionary *)params
                       callback:(nullable void(^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))callback {
    NSURL *url = [NSURL URLWithString:kEventDispatcherImpressionEventURL];
    [self dispatchEvent:params toURL:url completionHandler:callback];
}

- (void)dispatchConversionEvent:(nonnull NSDictionary *)params
                       callback:(nullable void(^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))callback {
    
    NSURL *url = [NSURL URLWithString:kEventDispatcherConversionEventURL];
    [self dispatchEvent:params toURL:url completionHandler:callback];
}

- (void)dispatchEvent:(NSDictionary *)params
                toURL:(NSURL *)url
    completionHandler:(void(^)(NSData *data, NSURLResponse *response, NSError *error))completion {
    OPTLYNetworkService *networkService = [OPTLYNetworkService new];
    [networkService dispatchEvent:params backoffRetry:NO toURL:url completionHandler:completion];
}

@end

@implementation OPTLYEventDispatcherNoOp

- (void)dispatchImpressionEvent:(nonnull NSDictionary *)params
                       callback:(nullable void(^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))callback {
    return;
}

- (void)dispatchConversionEvent:(nonnull NSDictionary *)params
                       callback:(nullable void(^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))callback {
    return;
}

@end
