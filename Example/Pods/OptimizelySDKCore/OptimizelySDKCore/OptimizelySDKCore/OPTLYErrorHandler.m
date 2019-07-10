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

#import "OPTLYErrorHandler.h"

@implementation OPTLYErrorHandler

+ (BOOL)conformsToOPTLYErrorHandlerProtocol:(Class)instanceClass
{
    // compile-time check
    BOOL isValidProtocolDeclaration = [instanceClass conformsToProtocol:@protocol(OPTLYErrorHandler)];
    
    // runtime checks
    BOOL implementsHandleErrorMethod = [instanceClass instancesRespondToSelector:@selector(handleError:)];
    BOOL implementsHandleExceptionMethod = [instanceClass instancesRespondToSelector:@selector(handleException:)];
    
    return isValidProtocolDeclaration && implementsHandleErrorMethod && implementsHandleExceptionMethod;
    
}

+ (void)handleError:(id<OPTLYErrorHandler>) errorHandler
               code:(NSInteger)code
        description:(NSString *)localizedDescription
{
    NSError *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                         code:code
                                     userInfo:@{NSLocalizedDescriptionKey : localizedDescription}];
    [errorHandler handleError:error];
}

@end

@implementation OPTLYErrorHandlerDefault

- (void)handleError:(NSError *)error
{
    NSLog(@"[OPTIMIZELY SDK][error]:%@", error);
}

- (void)handleException:(NSException *)exception
{
    NSLog(@"[OPTIMIZELY SDK][exception]:%@", exception);
}

@end


@implementation OPTLYErrorHandlerNoOp

- (void)handleError:(NSError *)error
{
    return;
}

- (void)handleException:(NSException *)exception
{
    return;
}

@end

