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

#import "OPTLYEventTagUtil.h"
#import "OPTLYEventMetric.h"
#import "OPTLYLogger.h"
#import "OPTLYNSObject+Validation.h"

@implementation OPTLYEventTagUtil

+ (NSNumber *)getRevenueValue:(NSDictionary *)eventTags logger:(id<OPTLYLogger>)logger {
    NSObject *value = eventTags[OPTLYEventMetricNameRevenue];
    if (!value) {
        return nil;
    }
    // Convert value to NSNumber of type "long long" or nil (failure) if impossible.
    NSNumber *answer = nil;
    // If the object is an in range NSNumber, then char, floats, and boolean values will be cast to a "long long".
    if ([value isKindOfClass:[NSNumber class]]) {
        answer = (NSNumber*)value;
        const char *objCType = [answer objCType];
        
        if ([self isNSNumberBoolean:answer]) {
            answer = nil;
            [logger logMessage:OPTLYLoggerMessagesRevenueValueInvalidBoolean withLevel:OptimizelyLogLevelWarning];
        } else if ((strcmp(objCType, @encode(char)) == 0)
                   || (strcmp(objCType, @encode(unsigned char)) == 0)
                   || (strcmp(objCType, @encode(short)) == 0)
                   || (strcmp(objCType, @encode(unsigned short)) == 0)
                   || (strcmp(objCType, @encode(int)) == 0)
                   || (strcmp(objCType, @encode(unsigned int)) == 0)
                   || (strcmp(objCType, @encode(long)) == 0)
                   || (strcmp(objCType, @encode(long long)) == 0)) {
            // These objCType's all fit inside "long long"
        } else if (((strcmp(objCType, @encode(unsigned long)) == 0)
                    || (strcmp(objCType, @encode(unsigned long long)) == 0))) {
            // Cast in range "unsigned long" and "unsigned long long" to "long long".
            // NOTE: Above uses all 64 bits of precision available and that "unsigned long"
            // and "unsigned long long" are same size on 64 bit Apple platforms.
            // https://developer.apple.com/library/content/documentation/General/Conceptual/CocoaTouch64BitGuide/Major64-BitChanges/Major64-BitChanges.html
            if ([answer unsignedLongLongValue]<=((unsigned long long)LLONG_MAX)) {
                long long longLongValue = [answer longLongValue];
                answer = [NSNumber numberWithLongLong:longLongValue];
            } else {
                // The unsignedLongLongValue is outside of [LLONG_MIN,LLONG_MAX], so
                // can't be properly cast to "long long" nor will be sent.
                answer = nil;
                [logger logMessage:OPTLYLoggerMessagesRevenueValueIntegerOverflow withLevel:OptimizelyLogLevelWarning];
            }
        } else if ((LLONG_MIN<=[answer doubleValue])&&([answer doubleValue]<=LLONG_MAX)) {
            // Cast in range floats etc. to long long, rounding or trunctating fraction parts.
            // NOTE: Mantissas of Objective-C doubles have 53 bits of precision which is
            // less than the 64 bits of precision of a "long long" or "unsigned long".
            // OTOH, floats have expts which can put the value of float outside the range
            // of a "long long" or "unsigned long".  Therefore, we test doubleValue
            // -- the highest precision floating format made available by NSNumber --
            // against [LLONG_MIN,LLONG_MAX] only after we're guaranteed we've already
            // considered all possible NSNumber integer formats (the previous two "if"
            // conditions).
            // https://en.wikipedia.org/wiki/IEEE_754
            // Intel "Floating-point Formats"
            // https://software.intel.com/en-us/node/523338
            // ARM "IEEE 754 arithmetic"
            // https://developer.arm.com/docs/dui0808/g/floating-point-support/ieee-754-arithmetic
            answer = @([answer longLongValue]);
            // Appropriate warning since conversion to integer generally will lose
            // some non-zero fraction after the decimal point.  Even if the fraction is zero,
            // the warning could alert user of SDK to a coding issue that should be remedied.
            [logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesRevenueValueFloatOverflow, value, answer] withLevel:OptimizelyLogLevelWarning];
        } else {
            // all other NSNumber's can't be reasonably cast to long long
            answer = nil;
            [logger logMessage:OPTLYLoggerMessagesRevenueValueInvalid withLevel:OptimizelyLogLevelWarning];
        }
    } else if ([value isValidStringType]) {
        // cast strings to long long
        answer = @([(NSString*)value longLongValue]);
        [logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesRevenueValueString, value] withLevel:OptimizelyLogLevelWarning];
    } else {
        // all other objects can't be cast to long long
        [logger logMessage:OPTLYLoggerMessagesRevenueValueInvalid withLevel:OptimizelyLogLevelWarning];
    };
    return answer;
}

+ (NSNumber *)getNumericValue:(NSDictionary *)eventTags logger:(id<OPTLYLogger>)logger {
    NSObject *value = eventTags[OPTLYEventMetricNameValue];
    if (!value) {
        return nil;
    }
    // Convert value to NSNumber of type "double" or nil (failure) if impossible.
    NSNumber *answer = nil;
    // if the object is an NSNumber, then char, floats, and boolean values will be cast to a double int
    if ([value isKindOfClass:[NSNumber class]]) {
        answer = (NSNumber*)value;
        
        if ([self isNSNumberBoolean:answer]) {
            answer = nil;
            [logger logMessage:OPTLYLoggerMessagesNumericValueInvalidBoolean withLevel:OptimizelyLogLevelWarning];
        } else {
            // Require real numbers (not infinite or NaN).
            double doubleValue = [(NSNumber*)value doubleValue];
            if (isfinite(doubleValue)) {
                answer = (NSNumber*)value;
            } else {
                answer = nil;
                [logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesNumericValueInvalidFloat, value] withLevel:OptimizelyLogLevelWarning];
            }
        }
    } else if ([value isValidStringType]) {
        // cast strings to double
        double doubleValue = [(NSString*)value doubleValue];
        if (isfinite(doubleValue)) {
            [logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesNumericValueString, value] withLevel:OptimizelyLogLevelWarning];
            answer = [NSNumber numberWithDouble:doubleValue];
        } else {
            [logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesNumericValueInvalidString, value] withLevel:OptimizelyLogLevelWarning];
        }
    } else {
        // all other objects can't be cast to double
        [logger logMessage:OPTLYLoggerMessagesNumericValueInvalid withLevel:OptimizelyLogLevelWarning];
    };
    return answer;
}

+ (BOOL)isNSNumberBoolean:(NSNumber*)value {
    const char *objCType = [value objCType];
    // Dispatch objCType according to one of "Type Encodings" listed here:
    // https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
    
    // NSNumber's generated by "+ (NSNumber *)numberWithBool:(BOOL)value;"
    // serialize to JSON booleans "true" and "false" via NSJSONSerialization .
    // The @YES and @NO compile to __NSCFBoolean's which (strangely enough)
    // are ((strcmp(objCType, @encode(char)) == 0) but these serialize as
    // JSON booleans "true" and "false" instead of JSON numbers.
    // These aren't integers, so shouldn't be sent.
    
    //
    // [Jira #4041] integers {1 and 0} are filtered out accidentally since @YES and @NO interpreted as @1 and @0
    //              we need compare with @YES and @NO only for boolean NSNumber (objCType == @encode(char))
    
    return  (strcmp(objCType, @encode(bool)) == 0) ||
            ((strcmp(objCType, @encode(char)) == 0) && [value isEqual:@YES]) ||
            ((strcmp(objCType, @encode(char)) == 0) && [value isEqual:@NO]);
}

@end
