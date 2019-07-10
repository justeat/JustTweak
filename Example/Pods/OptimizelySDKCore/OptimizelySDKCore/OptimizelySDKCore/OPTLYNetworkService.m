/****************************************************************************
 * Copyright 2016-2017, Optimizely, Inc. and contributors                   *
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

#import "OPTLYNetworkService.h"
#import "OPTLYProjectConfig.h"

// ---- Datafile Download URLs ----
// TODO: Move this to the Datafile manager and parameterize the URL for the datafile download
NSString * const OPTLYNetworkServiceS3ServerURL     = @"https://optimizely.s3.amazonaws.com/";

// ---- The total backoff and retry interval is: pow(2, attempts) * interval ----
const NSInteger OPTLYNetworkServiceEventDispatchMaxBackoffRetryAttempts = 2; // retries after first failed attempt
const NSInteger OPTLYNetworkServiceEventDispatchMaxBackoffRetryTimeInterval_ms = 1000;

const NSInteger OPTLYNetworkServiceDatafileDownloadMaxBackoffRetryAttempts = 2; // retries after first failed attempt
const NSInteger OPTLYNetworkServiceDatafileDownloadMaxBackoffRetryTimeInterval_ms = 1000;

@interface OPTLYNetworkService()
@property (nonatomic, strong)  OPTLYHTTPRequestManager *requestManager;
@end

@implementation OPTLYNetworkService

- (instancetype) init
{
    self = [super init];
    if (self) {
        _requestManager = [OPTLYHTTPRequestManager new];
    }
    return self;
}

- (void)downloadProjectConfig:(nonnull NSURL *)datafileConfigURL
                 backoffRetry:(BOOL)backoffRetry
                 lastModified:(nonnull NSString *)lastModifiedDate
            completionHandler:(nullable OPTLYHTTPRequestManagerResponse)completion
{
    if (backoffRetry) {
        [self.requestManager GETIfModifiedSince:lastModifiedDate
                                            url:datafileConfigURL
                           backoffRetryInterval:OPTLYNetworkServiceDatafileDownloadMaxBackoffRetryTimeInterval_ms
                                        retries:OPTLYNetworkServiceDatafileDownloadMaxBackoffRetryAttempts
                              completionHandler:completion];
    } else {
        [self.requestManager GETIfModifiedSince:lastModifiedDate
                                            url:datafileConfigURL
                              completionHandler:completion];
    }
}

- (void)downloadProjectConfig:(nonnull NSURL *)datafileConfigURL
                 backoffRetry:(BOOL)backoffRetry
            completionHandler:(OPTLYHTTPRequestManagerResponse)completion
{
    if (backoffRetry) {
        [self.requestManager GETWithBackoffRetryInterval:OPTLYNetworkServiceDatafileDownloadMaxBackoffRetryTimeInterval_ms
                                                     url:datafileConfigURL
                                                 retries:OPTLYNetworkServiceDatafileDownloadMaxBackoffRetryAttempts
                                       completionHandler:completion];
    } else {
        [self.requestManager GETWithURL:datafileConfigURL
                             completion:completion];
    }
}

- (void)dispatchEvent:(nonnull NSDictionary *)params
         backoffRetry:(BOOL)backoffRetry
                toURL:(nonnull NSURL *)url
    completionHandler:(nullable OPTLYHTTPRequestManagerResponse)completion
{
    if (backoffRetry) {
        [self.requestManager POSTWithParameters:params
                                            url:url
                           backoffRetryInterval:OPTLYNetworkServiceEventDispatchMaxBackoffRetryTimeInterval_ms
                                        retries:OPTLYNetworkServiceEventDispatchMaxBackoffRetryAttempts
                              completionHandler:completion];
    } else {
        [self.requestManager POSTWithParameters:params
                                            url:url
                              completionHandler:completion];
    }
}

@end
