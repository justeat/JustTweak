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
//  OPTLYJSONModelError.h
//  OPTLYJSONModel
//

#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////////////////////////////////////////////
typedef NS_ENUM(int, kOPTLYJSONModelErrorTypes)
{
    kOPTLYJSONModelErrorInvalidData = 1,
    kOPTLYJSONModelErrorBadResponse = 2,
    kOPTLYJSONModelErrorBadJSON = 3,
    kOPTLYJSONModelErrorModelIsInvalid = 4,
    kOPTLYJSONModelErrorNilInput = 5
};

/////////////////////////////////////////////////////////////////////////////////////////////
/** The domain name used for the OPTLYJSONModelError instances */
extern NSString *const OPTLYJSONModelErrorDomain;

/**
 * If the model JSON input misses keys that are required, check the
 * userInfo dictionary of the OPTLYJSONModelError instance you get back -
 * under the kOPTLYJSONModelMissingKeys key you will find a list of the
 * names of the missing keys.
 */
extern NSString *const kOPTLYJSONModelMissingKeys;

/**
 * If JSON input has a different type than expected by the model, check the
 * userInfo dictionary of the OPTLYJSONModelError instance you get back -
 * under the kOPTLYJSONModelTypeMismatch key you will find a description
 * of the mismatched types.
 */
extern NSString *const kOPTLYJSONModelTypeMismatch;

/**
 * If an error occurs in a nested model, check the userInfo dictionary of
 * the OPTLYJSONModelError instance you get back - under the kOPTLYJSONModelKeyPath
 * key you will find key-path at which the error occurred.
 */
extern NSString *const kOPTLYJSONModelKeyPath;

/////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Custom NSError subclass with shortcut methods for creating
 * the common OPTLYJSONModel errors
 */
@interface OPTLYJSONModelError : NSError

@property (strong, nonatomic) NSHTTPURLResponse *httpResponse;

@property (strong, nonatomic) NSData *responseData;

/**
 * Creates a OPTLYJSONModelError instance with code kOPTLYJSONModelErrorInvalidData = 1
 */
+ (id)errorInvalidDataWithMessage:(NSString *)message;

/**
 * Creates a OPTLYJSONModelError instance with code kOPTLYJSONModelErrorInvalidData = 1
 * @param keys a set of field names that were required, but not found in the input
 */
+ (id)errorInvalidDataWithMissingKeys:(NSSet *)keys;

/**
 * Creates a OPTLYJSONModelError instance with code kOPTLYJSONModelErrorInvalidData = 1
 * @param mismatchDescription description of the type mismatch that was encountered.
 */
+ (id)errorInvalidDataWithTypeMismatch:(NSString *)mismatchDescription;

/**
 * Creates a OPTLYJSONModelError instance with code kOPTLYJSONModelErrorBadResponse = 2
 */
+ (id)errorBadResponse;

/**
 * Creates a OPTLYJSONModelError instance with code kOPTLYJSONModelErrorBadJSON = 3
 */
+ (id)errorBadJSON;

/**
 * Creates a OPTLYJSONModelError instance with code kOPTLYJSONModelErrorModelIsInvalid = 4
 */
+ (id)errorModelIsInvalid;

/**
 * Creates a OPTLYJSONModelError instance with code kOPTLYJSONModelErrorNilInput = 5
 */
+ (id)errorInputIsNil;

/**
 * Creates a new OPTLYJSONModelError with the same values plus information about the key-path of the error.
 * Properties in the new error object are the same as those from the receiver,
 * except that a new key kOPTLYJSONModelKeyPath is added to the userInfo dictionary.
 * This key contains the component string parameter. If the key is already present
 * then the new error object has the component string prepended to the existing value.
 */
- (instancetype)errorByPrependingKeyPathComponent:(NSString *)component;

/////////////////////////////////////////////////////////////////////////////////////////////
@end
