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

#import "OPTLYLog.h"

@implementation OPTLYLog

void optlyLog(NSString* level, const char* file, int lineNumber, const char* functionName, NSString* format, ...)
{
    // add new line if needed
    if (![format hasSuffix:@"\n"]) {
        format = [format stringByAppendingString:@"\n"];
    }
    
    va_list ap;             // variable arguments
    va_start(ap, format);   // initialize variable argument list
    NSString *body = [[NSMutableString alloc] initWithFormat:format arguments:ap];
    va_end(ap);             // End using variable argument list.
    
    NSLog(@"%s (%s) %s", level.UTF8String, functionName, [body UTF8String]);
}

@end
