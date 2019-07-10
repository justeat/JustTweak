/****************************************************************************
 * Copyright 2018-2019, Optimizely, Inc. and contributors                   *
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

#import "OPTLYNSObject+Validation.h"
#import "OPTLYDatafileKeys.h"

@implementation NSObject (Validation)

- (BOOL)isValidStringType {
    if (self) {
        // check value is NSString
        return [self isKindOfClass:[NSString class]];
    }
    return false;
}

- (nullable NSString *)getValidString {
    if (self) {
        if ([self isValidStringType] && ![(NSString *)self isEqualToString:@""]) {
            return (NSString *)self;
        }
    }
    return nil;
}

- (nullable NSArray *)getValidArray {
    if (self) {
        if ([self isKindOfClass:[NSArray class]] && (((NSArray *)self).count > 0)) {
            return (NSArray *)self;
        }
    }
    return nil;
}

- (nullable NSDictionary *)getValidDictionary {
    if (self) {
        if ([self isKindOfClass:[NSDictionary class]] && (((NSDictionary *)self).count > 0)) {
            return (NSDictionary *)self;
        }
    }
    return nil;
}

- (NSString *)getStringOrEmpty {
    NSString *string = @"";
    if (self) {
        if ([self isValidStringType]) {
            string = [string stringByAppendingString:((NSString *)self)];
        }
    }
    return string;
}

- (NSString *)getJSONArrayStringOrEmpty {
    NSString *string = @"";
    if (self) {
        if ([self isKindOfClass:[NSArray class]]) {
            NSError *error = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:(NSArray *)self options:NSJSONWritingPrettyPrinted error:&error];
            if (error == nil) {
                string = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            }
        }
    }
    return string;
}

- (BOOL)isValidExactMatchTypeValue {
    //Check if given object is acceptable exact match type value
    if (self) {
        return ([self isKindOfClass:[NSString class]] || ([self isNumericAttributeValue] && [self isFiniteNumber]) || [self isKindOfClass:[NSNull class]] || [self isValidBooleanAttributeValue]);
    }
    return false;
}

- (BOOL)isValidGTLTMatchTypeValue {
    //Check if given object is acceptable GT or LT match type value
    if (self) {
        return (self != nil && ![self isKindOfClass:[NSNull class]] && [self isNumericAttributeValue] && [self isFiniteNumber]);
    }
    return false;
}

- (nullable NSArray *)getValidAudienceConditionsArray {
    if(self) {
        if ([self isValidStringType]) {
            //Check if string is a valid json
            NSError *error = nil;
            NSData *data = [(NSString *)self dataUsingEncoding:NSUTF8StringEncoding];
            id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if (error) {
                //check if string is not a valid json but is a non-empty string and can be casted as a number
                if ([(NSString *)self getValidString]) {
                    NSString *audienceString = [(NSString *)self getValidString];
                    if ([audienceString intValue]) {
                        return @[OPTLYDatafileKeysOrCondition,audienceString];
                    }
                }
                return nil;
            }
            
            return (NSArray *)json;
        }
    }
    return nil;
}

- (nullable NSArray *)getValidConditionsArray {
    if(self) {
        if ([self isValidStringType]) {
            NSError *error = nil;
            NSData *data = [(NSString *)self dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *conditionsArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if (!error) {
                return conditionsArray;
            }
        }
    }
    return nil;
}

- (BOOL)isValidAttributeValue {
    if (self) {
        if ([self isEqual:[NSNull null]]) {
            return false;
        }
        // check value is NSString
        if ([self isValidStringType]) {
            return true;
        }
        // check value is Boolean
        if ([self isValidBooleanAttributeValue]) {
            return true;
        }
        //check value is valid numeric attribute
        if ([self isNumericAttributeValue] && [self isFiniteNumber]) {
            return true;
        }
    }
    return false;
}

- (BOOL)isValidBooleanAttributeValue {
    if (self) {
        // check value is NSNumber
        NSNumber *number = (NSNumber *)self;
        CFTypeID boolID = CFBooleanGetTypeID(); // the type ID of CFBoolean
        CFTypeID numID = CFGetTypeID((__bridge CFTypeRef)(number)); // the type ID of num
        return numID == boolID;
    }
    return false;
}

- (BOOL)isNumericAttributeValue {
    if (self) {
        NSNumber *number = (NSNumber *)self;
        // check value is NSNumber
        if (number && [number isKindOfClass:[NSNumber class]]) {
            const char *objCType = [number objCType];
    
            // check NSNumber is bool
            CFTypeID boolID = CFBooleanGetTypeID(); // the type ID of CFBoolean
            CFTypeID numID = CFGetTypeID((__bridge CFTypeRef)(number)); // the type ID of num
            if (boolID == numID) {
                return false;
            }
            // check NSNumber is of type int, double
            Boolean isNumeric = (strcmp(objCType, @encode(short)) == 0)
            || (strcmp(objCType, @encode(unsigned short)) == 0)
            || (strcmp(objCType, @encode(int)) == 0)
            || (strcmp(objCType, @encode(unsigned int)) == 0)
            || (strcmp(objCType, @encode(long)) == 0)
            || (strcmp(objCType, @encode(unsigned long)) == 0)
            || (strcmp(objCType, @encode(long long)) == 0)
            || (strcmp(objCType, @encode(unsigned long long)) == 0)
            || (strcmp(objCType, @encode(float)) == 0)
            || (strcmp(objCType, @encode(double)) == 0)
            || (strcmp(objCType, @encode(char)) == 0)
            || (strcmp(objCType, @encode(unsigned char)) == 0);
            
            return isNumeric;
        }
    }
    return false;
}

- (BOOL)isFiniteNumber {
    if (self) {
        NSNumber *number = (NSNumber *)self;
        // check value is NSNumber
        if (number && [number isKindOfClass:[NSNumber class]]) {
            // check for Nan and infinity
            if (!isnan([number doubleValue]) && !isinf([number doubleValue])) {
                NSNumber *maxValue = [NSNumber numberWithDouble:pow(2,53)];
                return (fabs([number doubleValue]) <= [maxValue doubleValue]);
            }
        }
    }
    return false;
}

@end
