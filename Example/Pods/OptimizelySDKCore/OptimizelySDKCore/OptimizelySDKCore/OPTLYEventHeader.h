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

// Object containing event information scraped from http request instead of sent by the client

#import <Foundation/Foundation.h>
#ifdef UNIVERSAL
    #import "OPTLYJSONModelLib.h"
#else
    #import <OptimizelySDKCore/OPTLYJSONModelLib.h>
#endif

@protocol OPTLYEventHeader
@end

@interface OPTLYEventHeader : OPTLYJSONModel

// The IP address of the client
@property (nonatomic, strong, nonnull) NSString *clientIp;
// The user agent of the client. Null on mobile.
@property (nonatomic, strong, nullable) NSString<OPTLYOptional> *userAgent;
// The referrer of the client. Null on mobile.
@property (nonatomic, strong, nullable) NSString<OPTLYOptional> *referer;

@end
