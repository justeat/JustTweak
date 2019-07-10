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
#import "OPTLYErrorHandlerMessages.h"

/**
 * This class determines how the Optimizely SDK will handle exceptions and errors.
 */
@protocol OPTLYErrorHandler <NSObject>

/**
 * Handle an error thrown by the SDK.
 * @param error The error object to be handled.
 */
- (void)handleError:(NSError *)error;

/**
 * Handle an exception thrown by the SDK.
 * @param exception The exception object to be handled.
 */
- (void)handleException:(NSException *)exception;

@end

@interface OPTLYErrorHandler : NSObject
/**
 * Utility method to check if a class conforms to the OPTLYErrorHandler protocol
 * This method uses compile and run time checks
 */
+ (BOOL)conformsToOPTLYErrorHandlerProtocol:(Class)instanceClass;

/**
 * Utility method to package Apple-specific errors which then calls the error handler.
 */
+ (void)handleError:(id<OPTLYErrorHandler>) errorHandler
               code:(NSInteger)code
        description:(NSString *)localizedDescription;
@end

@interface OPTLYErrorHandlerDefault : NSObject <OPTLYErrorHandler>
@end

/**
 * OPTLYErrorHandlerNoOp comforms to the OPTLYErrorHandler protocol,
 * but all methods perform a no op.
 */
@interface OPTLYErrorHandlerNoOp : NSObject <OPTLYErrorHandler>
@end
