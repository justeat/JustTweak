/****************************************************************************
 * Copyright 2018, Optimizely, Inc. and contributors                        *
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

extern NSString * __nonnull const DEFAULT_HOST;
extern NSString * __nonnull const OPTLY_PROJECTID_SUFFIX;
extern NSString * __nonnull const OPTLY_ENVIRONMENTS_SUFFIX;

@interface OPTLYDatafileConfig : NSObject
- (nullable id)initWithProjectId:(nullable NSString *)projectId withSDKKey:(nullable NSString *)sdkKey withHost:(nonnull NSString *)host;
- (nullable id)initWithProjectId:(nullable NSString *)projectId withSDKKey:(nullable NSString *)sdkKey;
- (nonnull NSURL *) URLForKey;
- (nonnull NSString *) key;
@end

@interface OPTLYDatafileConfig(OPTLYHelpers)
+ (nonnull NSString *)defaultProjectIdCdnPath:(nonnull NSString *)projectId;
+ (nonnull NSString *)defaultSdkKeyCdnPath:(nonnull NSString *)sdkKey;
/*
 * Test if string s can be an Optimizely SDK key string.
 */
+ (BOOL)isValidKeyString:(nullable NSString*)s;

@end
