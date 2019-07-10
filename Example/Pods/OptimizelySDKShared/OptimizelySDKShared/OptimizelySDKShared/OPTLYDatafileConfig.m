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

#import "OPTLYDatafileConfig.h"
#import "OPTLYManagerBase.h"

NSString * const DEFAULT_HOST = @"https://cdn.optimizely.com";
NSString * const OPTLY_PROJECTID_SUFFIX = @"/json/%@.json";
NSString * const OPTLY_ENVIRONMENTS_SUFFIX = @"/datafiles/%@.json";

@interface OPTLYDatafileConfig()
- (nullable id)initWithProjectId:(NSString *)projectId withSDKKey:(NSString *)sdkKey withHost:(NSString *)host;
@property(nonatomic, strong, nullable) NSString* projectId;
@property(nonatomic, strong, nullable) NSString* sdkKey;
@property(nonatomic, strong) NSString* host;
@property(nonatomic, strong) NSURL* datafileUrl;
@end

@implementation OPTLYDatafileConfig(OPTLYHelpers)
+ (NSString *)defaultProjectIdCdnPath:(NSString *)projectId {
    NSString *datafileFormat = [DEFAULT_HOST stringByAppendingString:OPTLY_PROJECTID_SUFFIX];
    return [NSString stringWithFormat:datafileFormat, projectId];
}
+ (NSString *)defaultSdkKeyCdnPath:(NSString *)sdkKey {
    NSString *datafileFormat = [DEFAULT_HOST stringByAppendingString:OPTLY_ENVIRONMENTS_SUFFIX];
    return [NSString stringWithFormat:datafileFormat, sdkKey];
}
+ (BOOL)isValidKeyString:(NSString*)s {
    return ((s != nil) && ![s isEqualToString:@""] && ![s containsString:@" "]);
}
@end

@implementation OPTLYDatafileConfig

- (instancetype)initWithProjectId:(NSString *)projectId withSDKKey:(NSString *)sdkKey withHost:(NSString *)host {
    self.host = host;
    
    if (![OPTLYDatafileConfig isValidKeyString:projectId] && ![OPTLYDatafileConfig isValidKeyString:sdkKey]) {
        // One of projectId and sdkKey needs to be a valid key string.
        return nil;
    }
    if (self = [super init]) {
        self.projectId = projectId;
        self.sdkKey = sdkKey;
        if (self.sdkKey != nil) {
            NSString *datafileFormat = [self.host stringByAppendingString:OPTLY_ENVIRONMENTS_SUFFIX];
            NSString *datafile = [NSString stringWithFormat:datafileFormat, self.sdkKey];
            self.datafileUrl = [NSURL URLWithString:datafile];
        }
        else {
            NSString *datafileFormat = [self.host stringByAppendingString:OPTLY_PROJECTID_SUFFIX];
            NSString *datafile = [NSString stringWithFormat:datafileFormat, self.projectId];
            self.datafileUrl = [NSURL URLWithString:datafile];
        }
    }
    return self;
}

- (instancetype)initWithProjectId:(NSString *)projectId withSDKKey:(NSString *)sdkKey {
    return [self initWithProjectId:projectId withSDKKey:sdkKey withHost:DEFAULT_HOST];
}
- (NSString*)key {
    return (_sdkKey != nil) ? _sdkKey : _projectId;
}

- (NSURL *)URLForKey {
    return _datafileUrl;
}

+ (BOOL)areNilOrEqual:(NSString*)x y:(NSString*)y {
    // Equivalence relation which allows nil inputs and implies isEqual: for non-nil inputs.
    if (x==nil) {
        return (y==nil);
    } else {
        return [x isEqual:y];
    }
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass: [OPTLYDatafileConfig class]]) {
        return NO;
    }
    OPTLYDatafileConfig* p = (OPTLYDatafileConfig *)object;
    return ([OPTLYDatafileConfig areNilOrEqual:self.projectId y:p.projectId]
            &&[OPTLYDatafileConfig areNilOrEqual:self.sdkKey y:p.sdkKey]);
}

- (NSUInteger)hash {
    NSUInteger a = 40229;
    NSUInteger result = 524758627;
    result = a*result + (self.projectId == nil ? 0 : [self.projectId hash]);
    result = a*result + (self.sdkKey == nil ? 0 : [self.sdkKey hash]);
    return result;
}
@end
