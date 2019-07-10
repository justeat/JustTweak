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

#import <Foundation/Foundation.h>

// An optional bucketing ID may be provided in attributes via a
// key-value pair
//     OptimizelyBucketId : bucketId
// to accomplish decoupling bucketing from user identification so
// that a group of users that have the same bucketing ID are put
// into the same variation.
// A Bucketing ID allows equivalence relation on user IDs. A group
// of users with the same bucketing ID defines an equivalence class
// of user IDs that all map to the same experiment variation.
extern NSString * _Nonnull const OptimizelyBucketId;
extern NSString * _Nonnull const OptimizelyBotFiltering;
extern NSString * _Nonnull const OptimizelyUserAgent;
