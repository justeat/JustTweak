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

#import <Foundation/Foundation.h>
#import "OPTLYHTTPRequestManager.h"

NS_ASSUME_NONNULL_BEGIN
extern NSString * const OPTLYNetworkServiceCDNServerURL;
extern NSString * const OPTLYNetworkServiceS3ServerURL;
extern const NSInteger OPTLYNetworkServiceEventDispatchMaxBackoffRetryAttempts;
extern const NSInteger OPTLYNetworkServiceEventDispatchMaxBackoffRetryTimeInterval_ms;
extern const NSInteger OPTLYNetworkServiceDatafileDownloadMaxBackoffRetryAttempts;
extern const NSInteger OPTLYNetworkServiceDatafileDownloadMaxBackoffRetryTimeInterval_ms;
NS_ASSUME_NONNULL_END

@interface OPTLYNetworkService : NSObject
/**
 * Download the project config file from remote server
 *
 * @param projectUrl The project URL of the datafile to download
 * @param backoffRetry Indicates if the exponential backoff retry should be enabled
 * @param completion The completion block of type OPTLYHTTPRequestManagerResponse
 */
- (void)downloadProjectConfig:(nonnull NSURL *)projectUrl
                 backoffRetry:(BOOL)backoffRetry
            completionHandler:(nullable OPTLYHTTPRequestManagerResponse)completion;

/**
 * Download the project config file from remote server only if it
 * has been modified.
 *
 * @param projectURL The project URL of the datafile to download
 * @param backoffRetry Indicates if backoff retry should be enabled
 * @param lastModifiedDate The date the datafile was last modified
 * @param completion The completion block of type OPTLYHTTPRequestManagerResponse
 */
- (void)downloadProjectConfig:(nonnull NSURL *)projectURL
                 backoffRetry:(BOOL)backoffRetry
                 lastModified:(nonnull NSString *)lastModifiedDate
            completionHandler:(nullable OPTLYHTTPRequestManagerResponse)completion;

/**
 * Dispatches an event to a url
 * @param params Dictionary of the event parameter values
 * @param backoffRetry Indicates if the exponential backoff retry should be enabled
 * @param url The url to dispatch the event
 * @param completion The completion handler
 */
- (void)dispatchEvent:(nonnull NSDictionary *)params
         backoffRetry:(BOOL)backoffRetry
                toURL:(nonnull NSURL *)url
    completionHandler:(nullable OPTLYHTTPRequestManagerResponse)completion;

@end
