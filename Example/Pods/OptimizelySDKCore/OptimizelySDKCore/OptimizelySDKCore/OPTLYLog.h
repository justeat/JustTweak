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
#import <SystemConfiguration/SystemConfiguration.h>

#ifdef LOG_FLAG_ERROR
    #define OPTLYLogError(args...) optlyLog(@"OPTLYLogError",__FILE__,__LINE__,__PRETTY_FUNCTION__,args);
#else
    #define OPTLYLogError(args...)
#endif

#ifdef LOG_FLAG_DEBUG
    #define OPTLYLogDebug(args...) optlyLog(@"OPTLYLogDebug",__FILE__,__LINE__,__PRETTY_FUNCTION__,args);
#else
    #define OPTLYLogDebug(args...)
#endif

#ifdef LOG_FLAG_INFO
    #define OPTLYLogInfo(args...) optlyLog(@"OPTLYLogInfo",__FILE__,__LINE__,__PRETTY_FUNCTION__,args);
#else
    #define OPTLYLogInfo(args...)
#endif

void optlyLog(NSString* level, const char* file, int lineNumber, const char* functionName, NSString* format, ...);

@interface OPTLYLog : NSObject

@end
