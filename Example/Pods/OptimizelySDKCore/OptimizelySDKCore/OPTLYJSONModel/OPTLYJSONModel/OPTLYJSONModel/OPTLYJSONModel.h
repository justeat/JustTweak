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
//  OPTLYJSONModel.h
//  OPTLYJSONModel
//

#import <Foundation/Foundation.h>

#import "OPTLYJSONModelError.h"
#import "OPTLYJSONValueTransformer.h"
#import "OPTLYJSONKeyMapper.h"

/////////////////////////////////////////////////////////////////////////////////////////////
#if TARGET_IPHONE_SIMULATOR
#define OPTLYJMLog( s, ... ) NSLog( @"[%@:%d] %@", [[NSString stringWithUTF8String:__FILE__] \
lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define OPTLYJMLog( s, ... )
#endif
/////////////////////////////////////////////////////////////////////////////////////////////

DEPRECATED_ATTRIBUTE
@protocol ConvertOnDemand
@end

DEPRECATED_ATTRIBUTE
@protocol Index
@end

#pragma mark - Property Protocols
/**
 * Protocol for defining properties in a JSON Model class that should not be considered at all
 * neither while importing nor when exporting JSON.
 *
 * @property (strong, nonatomic) NSString&lt;Ignore&gt; *propertyName;
 *
 */
@protocol Ignore
@end

/**
 * Protocol for defining optional properties in a JSON Model class. Use like below to define
 * model properties that are not required to have values in the JSON input:
 *
 * @property (strong, nonatomic) NSString&lt;OPTLYOptional&gt; *propertyName;
 *
 */
@protocol OPTLYOptional
@end

/**
 * Make all objects compatible to avoid compiler warnings
 */
@interface NSObject (OPTLYJSONModelPropertyCompatibility) <OPTLYOptional, Ignore>
@end

/////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - OPTLYJSONModel protocol
/**
 * A protocol describing an abstract OPTLYJSONModel class
 * OPTLYJSONModel conforms to this protocol, so it can use itself abstractly
 */
@protocol AbstractOPTLYJSONModelProtocol <NSCopying, NSCoding>

@required
/**
 * All OPTLYJSONModel classes should implement initWithDictionary:
 *
 * For most classes the default initWithDictionary: inherited from OPTLYJSONModel itself
 * should suffice, but developers have the option to also overwrite it if needed.
 *
 * @param dict a dictionary holding JSON objects, to be imported in the model.
 * @param err an error or NULL
 */
- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError * __autoreleasing *)err;


/**
 * All OPTLYJSONModel classes should implement initWithData:error:
 *
 * For most classes the default initWithData: inherited from OPTLYJSONModel itself
 * should suffice, but developers have the option to also overwrite it if needed.
 *
 * @param data representing a JSON response (usually fetched from web), to be imported in the model.
 * @param error an error or NULL
 */
- (instancetype)initWithData:(NSData *)data error:(NSError * __autoreleasing *)error;

/**
 * All OPTLYJSONModel classes should be able to export themselves as a dictionary of
 * JSON compliant objects.
 *
 * For most classes the inherited from OPTLYJSONModel default toDictionary implementation
 * should suffice.
 *
 * @return NSDictionary dictionary of JSON compliant objects
 * @exception OPTLYJSONModelTypeNotAllowedException thrown when one of your model's custom class properties
 * does not have matching transformer method in an OPTLYJSONValueTransformer.
 */
- (NSDictionary *)toDictionary;

/**
 * Export a model class to a dictionary, including only given properties
 *
 * @param propertyNames the properties to export; if nil, all properties exported
 * @return NSDictionary dictionary of JSON compliant objects
 * @exception OPTLYJSONModelTypeNotAllowedException thrown when one of your model's custom class properties
 * does not have matching transformer method in an OPTLYJSONValueTransformer.
 */
- (NSDictionary *)toDictionaryWithKeys:(NSArray *)propertyNames;
@end

/////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - OPTLYJSONModel interface
/**
 * The OPTLYJSONModel is an abstract model class, you should not instantiate it directly,
 * as it does not have any properties, and therefore cannot serve as a data model.
 * Instead you should subclass it, and define the properties you want your data model
 * to have as properties of your own class.
 */
@interface OPTLYJSONModel : NSObject <AbstractOPTLYJSONModelProtocol, NSSecureCoding>

// deprecated
+ (NSMutableArray *)arrayOfModelsFromDictionaries:(NSArray *)array DEPRECATED_MSG_ATTRIBUTE("use arrayOfModelsFromDictionaries:error:");
+ (void)setGlobalKeyMapper:(OPTLYJSONKeyMapper *)globalKeyMapper DEPRECATED_MSG_ATTRIBUTE("override +keyMapper in a base model class instead");
+ (NSString *)protocolForArrayProperty:(NSString *)propertyName DEPRECATED_MSG_ATTRIBUTE("use classForCollectionProperty:");
- (void)mergeFromDictionary:(NSDictionary *)dict useKeyMapping:(BOOL)useKeyMapping DEPRECATED_MSG_ATTRIBUTE("use mergeFromDictionary:useKeyMapping:error:");
- (NSString *)indexPropertyName DEPRECATED_ATTRIBUTE;
- (NSComparisonResult)compare:(id)object DEPRECATED_ATTRIBUTE;

/** @name Creating and initializing models */

/**
 * Create a new model instance and initialize it with the JSON from a text parameter. The method assumes UTF8 encoded input text.
 * @param string JSON text data
 * @param err an initialization error or nil
 * @exception OPTLYJSONModelTypeNotAllowedException thrown when unsupported type is found in the incoming JSON,
 * or a property type in your model is not supported by OPTLYJSONValueTransformer and its categories
 * @see initWithString:usingEncoding:error: for use of custom text encodings
 */
- (instancetype)initWithString:(NSString *)string error:(OPTLYJSONModelError **)err;

/**
 * Create a new model instance and initialize it with the JSON from a text parameter using the given encoding.
 * @param string JSON text data
 * @param encoding the text encoding to use when parsing the string (see NSStringEncoding)
 * @param err an initialization error or nil
 * @exception OPTLYJSONModelTypeNotAllowedException thrown when unsupported type is found in the incoming JSON,
 * or a property type in your model is not supported by OPTLYJSONValueTransformer and its categories
 */
- (instancetype)initWithString:(NSString *)string usingEncoding:(NSStringEncoding)encoding error:(OPTLYJSONModelError **)err;

/** @name Exporting model contents */

/**
 * Export the whole object to a JSON data text string
 * @return JSON text describing the data model
 */
- (NSString *)toJSONString;

/**
 * Export the whole object to a JSON data text string
 * @return JSON text data describing the data model
 */
- (NSData *)toJSONData;

/**
 * Export the specified properties of the object to a JSON data text string
 * @param propertyNames the properties to export; if nil, all properties exported
 * @return JSON text describing the data model
 */
- (NSString *)toJSONStringWithKeys:(NSArray *)propertyNames;

/**
 * Export the specified properties of the object to a JSON data text string
 * @param propertyNames the properties to export; if nil, all properties exported
 * @return JSON text data describing the data model
 */
- (NSData *)toJSONDataWithKeys:(NSArray *)propertyNames;

/** @name Batch methods */

/**
 * If you have a list of dictionaries in a JSON feed, you can use this method to create an NSArray
 * of model objects. Handy when importing JSON data lists.
 * This method will loop over the input list and initialize a data model for every dictionary in the list.
 *
 * @param array list of dictionaries to be imported as models
 * @return list of initialized data model objects
 * @exception OPTLYJSONModelTypeNotAllowedException thrown when unsupported type is found in the incoming JSON,
 * or a property type in your model is not supported by OPTLYJSONValueTransformer and its categories
 * @exception OPTLYJSONModelInvalidDataException thrown when the input data does not include all required keys
 * @see arrayOfDictionariesFromModels:
 */
+ (NSMutableArray *)arrayOfModelsFromDictionaries:(NSArray *)array error:(NSError * __autoreleasing *)err;
+ (NSMutableArray *)arrayOfModelsFromData:(NSData *)data error:(NSError * __autoreleasing *)err;
+ (NSMutableArray *)arrayOfModelsFromString:(NSString *)string error:(NSError * __autoreleasing *)err;
+ (NSMutableDictionary *)dictionaryOfModelsFromDictionary:(NSDictionary *)dictionary error:(NSError * __autoreleasing *)err;
+ (NSMutableDictionary *)dictionaryOfModelsFromData:(NSData *)data error:(NSError * __autoreleasing *)err;
+ (NSMutableDictionary *)dictionaryOfModelsFromString:(NSString *)string error:(NSError * __autoreleasing *)err;

/**
 * If you have an NSArray of data model objects, this method takes it in and outputs a list of the
 * matching dictionaries. This method does the opposite of arrayOfObjectsFromDictionaries:
 * @param array list of OPTLYJSONModel objects
 * @return a list of NSDictionary objects
 * @exception OPTLYJSONModelTypeNotAllowedException thrown when unsupported type is found in the incoming JSON,
 * or a property type in your model is not supported by OPTLYJSONValueTransformer and its categories
 * @see arrayOfModelsFromDictionaries:
 */
+ (NSMutableArray *)arrayOfDictionariesFromModels:(NSArray *)array;
+ (NSMutableDictionary *)dictionaryOfDictionariesFromModels:(NSDictionary *)dictionary;

/** @name Validation */

/**
 * Overwrite the validate method in your own models if you need to perform some custom validation over the model data.
 * This method gets called at the very end of the OPTLYJSONModel initializer, thus the model is in the state that you would
 * get it back when initialized. Check the values of any property that needs to be validated and if any invalid values
 * are encountered return NO and set the error parameter to an NSError object. If the model is valid return YES.
 *
 * NB: Only setting the error parameter is not enough to fail the validation, you also need to return a NO value.
 *
 * @param error a pointer to an NSError object, to pass back an error if needed
 * @return a BOOL result, showing whether the model data validates or not. You can use the convenience method
 * [OPTLYJSONModelError errorModelIsInvalid] to set the NSError param if the data fails your custom validation
 */
- (BOOL)validate:(NSError * __autoreleasing *)error;

/** @name Key mapping */
/**
 * Overwrite in your models if your property names don't match your JSON key names.
 * Lookup OPTLYJSONKeyMapper docs for more details.
 */
+ (OPTLYJSONKeyMapper *)keyMapper;

/**
 * Indicates whether the property with the given name is OPTLYOptional.
 * To have a model with all of its properties being OPTLYOptional just return YES.
 * This method returns by default NO, since the default behaviour is to have all properties required.
 * @param propertyName the name of the property
 * @return a BOOL result indicating whether the property is OPTLYOptional
 */
+ (BOOL)propertyIsOptional:(NSString *)propertyName;

/**
 * Indicates whether the property with the given name is Ignored.
 * To have a model with all of its properties being Ignored just return YES.
 * This method returns by default NO, since the default behaviour is to have all properties required.
 * @param propertyName the name of the property
 * @return a BOOL result indicating whether the property is ignored
 */
+ (BOOL)propertyIsIgnored:(NSString *)propertyName;

/**
 * Indicates the class used for the elements of a collection property.
 * Rather than using:
 *     @property (strong) NSArray <MyType> *things;
 * You can implement classForCollectionProperty: and keep your property
 * defined like:
 *     @property (strong) NSArray *things;
 * @param propertyName the name of the property
 * @return Class the class used to deserialize the elements of the collection
 *
 * Example in Swift 3.0:
 * override static func classForCollectionProperty(propertyName: String) -> AnyClass? {
 *   switch propertyName {
 *     case "childModel":
 *       return ChildModel.self
 *     default:
 *       return nil
 *   }
 * }
 */
+ (Class)classForCollectionProperty:(NSString *)propertyName NS_SWIFT_NAME(classForCollectionProperty(propertyName:));

/**
 * Merges values from the given dictionary into the model instance.
 * @param dict dictionary with values
 * @param useKeyMapping if YES the method will use the model's key mapper and the global key mapper, if NO
 * it'll just try to match the dictionary keys to the model's properties
 */
- (BOOL)mergeFromDictionary:(NSDictionary *)dict useKeyMapping:(BOOL)useKeyMapping error:(NSError * __autoreleasing *)error;

@end
