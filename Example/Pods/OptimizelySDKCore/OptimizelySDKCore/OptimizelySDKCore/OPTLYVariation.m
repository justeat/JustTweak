/****************************************************************************
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

#import "OPTLYVariation.h"
#import "OPTLYDatafileKeys.h"
#import "OPTLYVariableUsage.h"

@interface OPTLYVariation()
/// A mapping of Feature Variable IDs to Variable Usages constructed during the initialization of Variation objects from the list of Variable Usages.
@property (nonatomic, strong) NSDictionary<NSString *, OPTLYVariableUsage *><Ignore> *variableIdToVariableUsageMap;
@end

@implementation OPTLYVariation

+ (OPTLYJSONKeyMapper*)keyMapper
{
    return [[OPTLYJSONKeyMapper alloc] initWithDictionary:@{ OPTLYDatafileKeysVariationId   : @"variationId",
                                                             OPTLYDatafileKeysVariationKey  : @"variationKey",
                                                             OPTLYDatafileKeysVariationVariables  : @"variableUsageInstances",
                                                             OPTLYDatafileKeysVariationFeatureEnabled : @"featureEnabled"
                                                       }];
}

# pragma mark - Feature Variable Mappings and Getters

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return [propertyName isEqualToString:@"featureEnabled"];
}

- (nullable OPTLYVariableUsage *)getVariableUsageForVariableId:(nullable NSString *)variableId {
    OPTLYVariableUsage *variableUsage = nil;
    if (variableId) {
        variableUsage = self.variableIdToVariableUsageMap[variableId];
    }
    return variableUsage;
}

- (NSDictionary<NSString *, OPTLYVariableUsage *> *)variableIdToVariableUsageMap {
    if (!_variableIdToVariableUsageMap) {
        _variableIdToVariableUsageMap = [self generateVariableIdToVariableUsageMap];
    }
    return _variableIdToVariableUsageMap;
}

- (NSDictionary<NSString *, OPTLYVariableUsage *> *)generateVariableIdToVariableUsageMap {
    NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
    for (OPTLYVariableUsage *variableUsage in self.variableUsageInstances) {
        map[variableUsage.variableId] = variableUsage;
    }
    
    return [NSDictionary dictionaryWithDictionary:map];
}

@end
