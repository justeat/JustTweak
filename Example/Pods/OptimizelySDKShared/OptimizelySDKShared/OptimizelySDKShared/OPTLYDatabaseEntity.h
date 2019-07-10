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

#import <Foundation/Foundation.h>

/*
 *   This class contains the column values in a database row.
 *   Each row entry contains three columns:
 *       1. id [int]
 *       2. json [text]
 *       3. timestamp [int]
 */

@interface OPTLYDatabaseEntity : NSObject

@property (nonatomic, strong) NSNumber *entityId;
@property (nonatomic, strong) NSString *entityValue;
@property (nonatomic, assign) NSNumber *timestamp;

- (instancetype)initWithEntityId:(NSNumber *)entityId
                     entityValue:(NSString *)entityValue
                       timeStamp:(NSNumber *)timestamp;

@end
