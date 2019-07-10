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
//  OPTLYJSONModelClassProperty.h
//  OPTLYJSONModel
//

#import <Foundation/Foundation.h>

/**
 * **You do not need to instantiate this class yourself.** This class is used internally by OPTLYJSONModel
 * to inspect the declared properties of your model class.
 *
 * Class to contain the information, representing a class property
 * It features the property's name, type, whether it's a required property,
 * and (optionally) the class protocol
 */
@interface OPTLYJSONModelClassProperty : NSObject

// deprecated
@property (assign, nonatomic) BOOL isIndex DEPRECATED_ATTRIBUTE;

/** The name of the declared property (not the ivar name) */
@property (copy, nonatomic) NSString *name;

/** A property class type  */
@property (assign, nonatomic) Class type;

/** Struct name if a struct */
@property (strong, nonatomic) NSString *structName;

/** The name of the protocol the property conforms to (or nil) */
@property (copy, nonatomic) NSString *protocol;

/** If YES, it can be missing in the input data, and the input would be still valid */
@property (assign, nonatomic) BOOL isOptional;

/** If YES - don't call any transformers on this property's value */
@property (assign, nonatomic) BOOL isStandardJSONType;

/** If YES - create a mutable object for the value of the property */
@property (assign, nonatomic) BOOL isMutable;

/** a custom getter for this property, found in the owning model */
@property (assign, nonatomic) SEL customGetter;

/** custom setters for this property, found in the owning model */
@property (strong, nonatomic) NSMutableDictionary *customSetters;

@end
