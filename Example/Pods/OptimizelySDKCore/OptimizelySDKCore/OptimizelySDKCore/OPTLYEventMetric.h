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

// Model object representing a metric that can be applied to an event

#import <Foundation/Foundation.h>
#ifdef UNIVERSAL
    #import "OPTLYJSONModelLib.h"
#else
    #import <OptimizelySDKCore/OPTLYJSONModelLib.h>
#endif

NS_ASSUME_NONNULL_BEGIN
extern NSString * const OPTLYEventMetricNameRevenue;
extern NSString * const OPTLYEventMetricNameValue;
NS_ASSUME_NONNULL_END

@protocol OPTLYEventMetric
@end

@interface OPTLYEventMetric : OPTLYJSONModel

// The name of the metric, e.g. 'revenue' or 'value'
@property (nonatomic, strong, nonnull) NSString *name;
// The value of the metric
@property (nonatomic, strong, nonnull) NSNumber *value;

@end
