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

#import "OPTLYErrorHandlerMessages.h"
#import "OPTLYHTTPRequestManager.h"
#import "OPTLYLog.h"
#import "OPTLYLoggerMessages.h"

static NSString * const kHTTPRequestMethodGet = @"GET";
static NSString * const kHTTPRequestMethodPost = @"POST";
static NSString * const kHTTPHeaderFieldContentType = @"Content-Type";
static NSString * const kHTTPHeaderFieldValueApplicationJSON = @"application/json";

@interface OPTLYHTTPRequestManager()

- (NSURLSession *)session;

// Use this flag to deterine if we are running a unit test
// The flag is needed to track some values for unit test
@property (nonatomic, assign) BOOL isRunningTest;
@property (nonatomic, assign) NSInteger retryAttemptTest;
@property (nonatomic, strong) NSMutableArray *delaysTest;
@end

@implementation OPTLYHTTPRequestManager

- (NSURLSession *)session {
    NSURLSession *ephemeralSession = nil;
    
    @try {
        ephemeralSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
        ephemeralSession.configuration.TLSMinimumSupportedProtocol = kTLSProtocol12;

    }
    @catch (NSException *e) {
        OPTLYLogError(e.description);
        //return self.backgroundSession;
    }
    
    return ephemeralSession;
}

- (NSURLSession *)backgroundSession {
    NSURLSession *backgroundSession = nil;
    
    @try {
        backgroundSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"backgroundFlushEvent"]];
        backgroundSession.configuration.TLSMinimumSupportedProtocol = kTLSProtocol12;
    }
    @catch (NSException *e) {
        OPTLYLogError(e.description);
    }
    return backgroundSession;
}

# pragma mark - Object Initializers

- (id)init
{
    NSAssert(YES, @"Use initWithURL initialization method.");
    _isRunningTest = [self runningUnitTests];
    self = [super init];
    return self;
}

// Create global serial GCD queue for NSURL tasks
dispatch_queue_t networkTasksQueue()
{
    static dispatch_queue_t _networkTasksQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _networkTasksQueue = dispatch_queue_create("com.Optimizely.networkTasksQueue", DISPATCH_QUEUE_CONCURRENT);
    });
    return _networkTasksQueue;
}

# pragma mark - GET
- (void)GETWithURL:(NSURL *)url
        completion:(OPTLYHTTPRequestManagerResponse)completion {
    [self GETWithParameters:nil url:url completionHandler:completion];
}

- (void)GETWithBackoffRetryInterval:(NSInteger)backoffRetryInterval
                                url:(NSURL *)url
                            retries:(NSInteger)retries
                  completionHandler:(OPTLYHTTPRequestManagerResponse)completion
{
    if (self.isRunningTest == YES) {
        self.delaysTest = [NSMutableArray new];
    }
    
    [self GETWithParameters:nil
                        url:url
       backoffRetryInterval:backoffRetryInterval
                    retries:retries
          completionHandler:completion];
}

# pragma mark - GET (with parameters)
- (void)GETWithParameters:(NSDictionary *)parameters
                      url:(NSURL *)url
        completionHandler:(OPTLYHTTPRequestManagerResponse)completion
{
    
    NSURL *urlWithParameterQuery = [self buildQueryURL:url withParameters:parameters];
    NSURLSessionDataTask *downloadTask = [self.session dataTaskWithURL:urlWithParameterQuery
                                                         completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                             if (completion) {
                                                                 completion(data, response, error);
                                                             }
                                                         }];
    
    [downloadTask resume];
}

- (void)GETWithParameters:(NSDictionary *)parameters
                      url:(NSURL *)url
     backoffRetryInterval:(NSInteger)backoffRetryInterval
                  retries:(NSInteger)retries
        completionHandler:(OPTLYHTTPRequestManagerResponse)completion
{
    if (self.isRunningTest == YES) {
        self.delaysTest = [NSMutableArray new];
    }
    
    [self GETWithParameters:parameters
                        url:url
       backoffRetryInterval:backoffRetryInterval
                    retries:retries
          completionHandler:completion
        backoffRetryAttempt:0
                      error:nil];
}

- (void)GETWithParameters:(NSDictionary *)parameters
                      url:(NSURL *)url
     backoffRetryInterval:(NSInteger)backoffRetryInterval
                  retries:(NSInteger)retries
        completionHandler:(OPTLYHTTPRequestManagerResponse)completion
      backoffRetryAttempt:(NSInteger)backoffRetryAttempt
                    error:(NSError *)error
{
    
    OPTLYLogDebug(OPTLYHTTPRequestManagerGETWithParametersAttempt, backoffRetryAttempt);
    
    if (self.isRunningTest == YES) {
        self.retryAttemptTest = backoffRetryAttempt;
    }
    
    if (backoffRetryAttempt > retries) {
        if (completion) {
            NSString *errorMessage = [NSString stringWithFormat:OPTLYErrorHandlerMessagesHTTPRequestManagerGETRetryFailure, error];
            NSError *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                                 code:OPTLYErrorTypesHTTPRequestManager
                                             userInfo:@{ NSLocalizedDescriptionKey : errorMessage }];
            OPTLYLogDebug(errorMessage);
            completion(nil, nil, error);
        }
        
        if (self.isRunningTest == YES) {
            self.delaysTest = nil;
        }
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self GETWithParameters:parameters
                        url:url
          completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
              if (error) {
                  dispatch_time_t delayTime = [weakSelf backoffDelay:backoffRetryAttempt
                                                backoffRetryInterval:backoffRetryInterval];
                  dispatch_after(delayTime, networkTasksQueue(), ^(void){
                      
                      [weakSelf GETWithParameters:parameters
                                              url:url
                             backoffRetryInterval:backoffRetryInterval
                                          retries:retries
                                completionHandler:completion
                              backoffRetryAttempt:backoffRetryAttempt+1
                                            error:error];
                  });
              } else {
                  if (completion) {
                      completion(data, response, error);
                  }
              }
          }];
}

# pragma mark - GET (if modified)
- (void)GETIfModifiedSince:(NSString *)lastModifiedDate
                       url:(NSURL *)url
         completionHandler:(OPTLYHTTPRequestManagerResponse)completion
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:lastModifiedDate forHTTPHeaderField:@"If-Modified-Since"];
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (completion) {
            completion(data, response, error);
        }
    }];
    
    [dataTask resume];
}

- (void)GETIfModifiedSince:(NSString *)lastModifiedDate
                       url:(NSURL *)url
      backoffRetryInterval:(NSInteger)backoffRetryInterval
                   retries:(NSInteger)retries
         completionHandler:(OPTLYHTTPRequestManagerResponse)completion
{
    if (self.isRunningTest == YES) {
        self.delaysTest = [NSMutableArray new];
    }
    
    [self GETIfModifiedSince:lastModifiedDate
                         url:url
        backoffRetryInterval:backoffRetryInterval
                     retries:retries
           completionHandler:completion
         backoffRetryAttempt:0
                       error:nil];
}

- (void)GETIfModifiedSince:(NSString *)lastModifiedDate
                       url:(NSURL *)url
      backoffRetryInterval:(NSInteger)backoffRetryInterval
                   retries:(NSInteger)retries
         completionHandler:(OPTLYHTTPRequestManagerResponse)completion
       backoffRetryAttempt:(NSInteger)backoffRetryAttempt
                     error:(NSError *)error
{
    OPTLYLogDebug(OPTLYHTTPRequestManagerGETIfModifiedSince, backoffRetryAttempt);
    
    if (self.isRunningTest == YES) {
        self.retryAttemptTest = backoffRetryAttempt;
    }
    
    if (backoffRetryAttempt > retries) {
        if (completion) {
            NSString *errorMessage = [NSString stringWithFormat:OPTLYErrorHandlerMessagesHTTPRequestManagerGETIfModifiedFailure, error];
            NSError *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                                 code:OPTLYErrorTypesHTTPRequestManager
                                             userInfo:@{ NSLocalizedDescriptionKey : errorMessage }];
            OPTLYLogDebug(errorMessage);
            completion(nil, nil, error);
        }
        
        if (self.isRunningTest == YES) {
            self.delaysTest = nil;
        }
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self GETIfModifiedSince:lastModifiedDate
                         url:url
           completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
               NSInteger statusCode = 503;
               if (response != nil && error == nil) {
                   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                   statusCode = (long)[httpResponse statusCode];
               }
               if (error != nil || statusCode >= 400) {
                   dispatch_time_t delayTime = [weakSelf backoffDelay:backoffRetryAttempt
                                                 backoffRetryInterval:backoffRetryInterval];
                   dispatch_after(delayTime, networkTasksQueue(), ^(void){
                       [weakSelf GETIfModifiedSince:lastModifiedDate
                                                url:url
                               backoffRetryInterval:backoffRetryInterval
                                            retries:retries
                                  completionHandler:completion
                                backoffRetryAttempt:backoffRetryAttempt+1
                                              error:error];
                   });
               } else {
                   if (completion) {
                       completion(data, response, error);
                   }
               }
           }];
}


# pragma mark - POST
- (void)POSTWithParameters:(NSDictionary *)parameters
                       url:(NSURL *)url
         completionHandler:(OPTLYHTTPRequestManagerResponse)completion
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:kHTTPRequestMethodPost];
    
    NSError *JSONSerializationError = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:parameters
                                                   options:kNilOptions error:&JSONSerializationError];
    if (JSONSerializationError) {
        if (completion) {
            completion(nil, nil, JSONSerializationError);
        }
        return;
    }
    
    [request addValue:kHTTPHeaderFieldValueApplicationJSON forHTTPHeaderField:kHTTPHeaderFieldContentType];
    
    NSURLSessionUploadTask *uploadTask = [self.session uploadTaskWithRequest:request
                                                                        fromData:data
                                                               completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                                   if (completion) {
                                                                       completion(data, response, error);
                                                                   }
                                                               }];
    
    [uploadTask resume];
}

- (void)POSTWithParameters:(nonnull NSDictionary *)parameters
                       url:(NSURL *)url
      backoffRetryInterval:(NSInteger)backoffRetryInterval
                   retries:(NSInteger)retries
         completionHandler:(nullable OPTLYHTTPRequestManagerResponse)completion
{
    if (self.isRunningTest == YES) {
        self.delaysTest = [NSMutableArray new];
    }
    
    [self POSTWithParameters:parameters
                         url:url
        backoffRetryInterval:backoffRetryInterval
                     retries:retries
           completionHandler:completion
         backoffRetryAttempt:0
                       error:nil];
}

- (void)POSTWithParameters:(NSDictionary *)parameters
                       url:(NSURL *)url
      backoffRetryInterval:(NSInteger)backoffRetryInterval
                   retries:(NSInteger)retries
         completionHandler:(OPTLYHTTPRequestManagerResponse)completion
       backoffRetryAttempt:(NSInteger)backoffRetryAttempt
                     error:(NSError *)error
{
    OPTLYLogDebug(OPTLYHTTPRequestManagerPOSTWithParameters, backoffRetryAttempt);
    
    if (self.isRunningTest == YES) {
        self.retryAttemptTest = backoffRetryAttempt;
    }
    
    if (backoffRetryAttempt > retries) {
        if (completion) {
            NSString *errorMessage = [NSString stringWithFormat:OPTLYErrorHandlerMessagesHTTPRequestManagerPOSTRetryFailure, error];
            NSError *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                                 code:OPTLYErrorTypesHTTPRequestManager
                                             userInfo:@{ NSLocalizedDescriptionKey : errorMessage }];
            OPTLYLogDebug(errorMessage);
            completion(nil, nil, error);
        }
        
        if (self.isRunningTest == YES) {
            self.delaysTest = nil;
        }
        
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self POSTWithParameters:parameters
                         url:url
           completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
               if (error) {
                   dispatch_time_t delayTime = [weakSelf backoffDelay:backoffRetryAttempt
                                                 backoffRetryInterval:backoffRetryInterval];
                   dispatch_after(delayTime, networkTasksQueue(), ^(void){
                       [weakSelf POSTWithParameters:parameters
                                                url:url
                               backoffRetryInterval:backoffRetryInterval
                                            retries:retries
                                  completionHandler:completion
                                backoffRetryAttempt:backoffRetryAttempt+1
                                              error:error];
                   });
               } else {
                   if (completion) {
                       completion(data, response, error);
                   }
               }
           }];
}

# pragma mark - Helper Methods

- (BOOL)runningUnitTests {
    BOOL isRunningTest = NSClassFromString(@"XCTestCase") != nil;
    return isRunningTest;
}

// calculates the exponential backoff time based on the retry attempt number
- (dispatch_time_t)backoffDelay:(NSInteger)backoffRetryAttempt
           backoffRetryInterval:(NSInteger)backoffRetryInterval
{
    uint32_t exponentialMultiplier = pow(2.0, backoffRetryAttempt);
    uint64_t delay_ns = backoffRetryInterval * exponentialMultiplier * NSEC_PER_MSEC;
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, delay_ns);
    
    OPTLYLogDebug(OPTLYHTTPRequestManagerBackoffRetryStates, backoffRetryAttempt, exponentialMultiplier, delay_ns, delayTime);
    
    if (self.isRunningTest == YES) {
        if ([self.delaysTest count] >= backoffRetryAttempt) {
            self.delaysTest[backoffRetryAttempt] = [NSNumber numberWithLongLong:delay_ns];
        }
    }
    
    return delayTime;
}

- (NSURL *)buildQueryURL:(NSURL *)url
          withParameters:(NSDictionary *)parameters
{
    if (parameters == nil || [parameters count] == 0) {
        return url;
    }
    
    NSURLComponents *components = [[NSURLComponents alloc] init];
    
    components.scheme = url.scheme;
    components.host = url.host;
    components.path = url.path;
    
    NSMutableArray *queryItems = [NSMutableArray new];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop)
     {
         NSURLQueryItem *queryItem = [NSURLQueryItem queryItemWithName:key value:object];
         [queryItems addObject:queryItem];
     }];
    components.queryItems = queryItems;
    
    return components.URL;
}

@end
