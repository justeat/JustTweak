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
//  OPTLYJSONModelClassProperty.m
//  OPTLYJSONModel
//

#import "OPTLYJSONModelClassProperty.h"

@implementation OPTLYJSONModelClassProperty

-(NSString*)description
{
    //build the properties string for the current class property
    NSMutableArray* properties = [NSMutableArray arrayWithCapacity:8];

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    if (self.isIndex) [properties addObject:@"Index"];
#pragma GCC diagnostic pop

    if (self.isOptional) [properties addObject:@"Optional"];
    if (self.isMutable) [properties addObject:@"Mutable"];
    if (self.isStandardJSONType) [properties addObject:@"Standard JSON type"];
    if (self.customGetter) [properties addObject:[NSString stringWithFormat: @"Getter = %@", NSStringFromSelector(self.customGetter)]];

    if (self.customSetters)
    {
        NSMutableArray *setters = [NSMutableArray array];

        for (id obj in self.customSetters.allValues)
        {
            SEL selector;
            [obj getValue:&selector];
            [setters addObject:NSStringFromSelector(selector)];
        }

        [properties addObject:[NSString stringWithFormat: @"Setters = [%@]", [setters componentsJoinedByString:@", "]]];
    }

    NSString* propertiesString = @"";
    if (properties.count>0) {
        propertiesString = [NSString stringWithFormat:@"(%@)", [properties componentsJoinedByString:@", "]];
    }

    //return the name, type and additional properties
    return [NSString stringWithFormat:@"@property %@%@ %@ %@",
            self.type?[NSString stringWithFormat:@"%@*",self.type]:(self.structName?self.structName:@"primitive"),
            self.protocol?[NSString stringWithFormat:@"<%@>", self.protocol]:@"",
            self.name,
            propertiesString
            ];
}

@end
