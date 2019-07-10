/****************************************************************************
 * Modifications to JSONModel by Optimizely, Inc.                           *
 * Copyright 2017, Optimizely, Inc. and contributors                        *
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
//
//  OPTLYJSONModelError.m
//  OPTLYJSONModel
//

#import "OPTLYJSONModelError.h"

NSString* const OPTLYJSONModelErrorDomain = @"OPTLYJSONModelErrorDomain";
NSString* const kOPTLYJSONModelMissingKeys = @"kOPTLYJSONModelMissingKeys";
NSString* const kOPTLYJSONModelTypeMismatch = @"kOPTLYJSONModelTypeMismatch";
NSString* const kOPTLYJSONModelKeyPath = @"kOPTLYJSONModelKeyPath";

@implementation OPTLYJSONModelError

+(id)errorInvalidDataWithMessage:(NSString*)message
{
    message = [NSString stringWithFormat:@"Invalid JSON data: %@", message];
    return [OPTLYJSONModelError errorWithDomain:OPTLYJSONModelErrorDomain
                                      code:kOPTLYJSONModelErrorInvalidData
                                  userInfo:@{NSLocalizedDescriptionKey:message}];
}

+(id)errorInvalidDataWithMissingKeys:(NSSet *)keys
{
    return [OPTLYJSONModelError errorWithDomain:OPTLYJSONModelErrorDomain
                                      code:kOPTLYJSONModelErrorInvalidData
                                  userInfo:@{NSLocalizedDescriptionKey:@"Invalid JSON data. Required JSON keys are missing from the input. Check the error user information.",kOPTLYJSONModelMissingKeys:[keys allObjects]}];
}

+(id)errorInvalidDataWithTypeMismatch:(NSString*)mismatchDescription
{
    return [OPTLYJSONModelError errorWithDomain:OPTLYJSONModelErrorDomain
                                      code:kOPTLYJSONModelErrorInvalidData
                                  userInfo:@{NSLocalizedDescriptionKey:@"Invalid JSON data. The JSON type mismatches the expected type. Check the error user information.",kOPTLYJSONModelTypeMismatch:mismatchDescription}];
}

+(id)errorBadResponse
{
    return [OPTLYJSONModelError errorWithDomain:OPTLYJSONModelErrorDomain
                                      code:kOPTLYJSONModelErrorBadResponse
                                  userInfo:@{NSLocalizedDescriptionKey:@"Bad network response. Probably the JSON URL is unreachable."}];
}

+(id)errorBadJSON
{
    return [OPTLYJSONModelError errorWithDomain:OPTLYJSONModelErrorDomain
                                      code:kOPTLYJSONModelErrorBadJSON
                                  userInfo:@{NSLocalizedDescriptionKey:@"Malformed JSON. Check the OPTLYJSONModel data input."}];
}

+(id)errorModelIsInvalid
{
    return [OPTLYJSONModelError errorWithDomain:OPTLYJSONModelErrorDomain
                                      code:kOPTLYJSONModelErrorModelIsInvalid
                                  userInfo:@{NSLocalizedDescriptionKey:@"Model does not validate. The custom validation for the input data failed."}];
}

+(id)errorInputIsNil
{
    return [OPTLYJSONModelError errorWithDomain:OPTLYJSONModelErrorDomain
                                      code:kOPTLYJSONModelErrorNilInput
                                  userInfo:@{NSLocalizedDescriptionKey:@"Initializing model with nil input object."}];
}

- (instancetype)errorByPrependingKeyPathComponent:(NSString*)component
{
    // Create a mutable  copy of the user info so that we can add to it and update it
    NSMutableDictionary* userInfo = [self.userInfo mutableCopy];

    // Create or update the key-path
    NSString* existingPath = userInfo[kOPTLYJSONModelKeyPath];
    NSString* separator = [existingPath hasPrefix:@"["] ? @"" : @".";
    NSString* updatedPath = (existingPath == nil) ? component : [component stringByAppendingFormat:@"%@%@", separator, existingPath];
    userInfo[kOPTLYJSONModelKeyPath] = updatedPath;

    // Create the new error
    return [OPTLYJSONModelError errorWithDomain:self.domain
                                      code:self.code
                                  userInfo:[NSDictionary dictionaryWithDictionary:userInfo]];
}

@end
