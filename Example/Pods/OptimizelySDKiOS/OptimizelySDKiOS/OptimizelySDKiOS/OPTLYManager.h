/****************************************************************************
 * Copyright 2016-2018, Optimizely, Inc. and contributors                   *
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
#ifdef UNIVERSAL
    #import "OPTLYManagerBase.h"
#else
    #import <OptimizelySDKShared/OPTLYManagerBase.h>
#endif

@protocol OPTLYManager;

@interface OPTLYManager : OPTLYManagerBase<OPTLYManager>
/**
 * Init with builder block
 * @param builderBlock The Optimizely Manager Builder Block where datafile manager, event dispatcher, and other configurations will be set.
 * @return OptimizelyManager instance
 */
+ (nullable instancetype)init:(nonnull OPTLYManagerBuilderBlock)builderBlock
__attribute((deprecated("Use OPTLYManager initWithBuilder method instead.")));

/**
 * Init with OPTLYManagerBuilder object
 * @param builder The OPTLYManagerBuilder object which has datafile manager, event dispatcher, and other configurations to be set.
 * @return OPTLYManager instance
 */
- (nullable instancetype)initWithBuilder:(nullable OPTLYManagerBuilder *)builder;
@end
