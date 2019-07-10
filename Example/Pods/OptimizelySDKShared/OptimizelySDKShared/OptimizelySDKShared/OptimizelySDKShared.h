/****************************************************************************
 * Copyright 2016-2017, Optimizely, Inc. and contributors                   *
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

#ifndef UNIVERSAL
    #import <OptimizelySDKCore/OptimizelySDKCore.h>
#endif
#import "OPTLYClient.h"
#import "OPTLYClientBuilder.h"
#if TARGET_OS_IOS
    #import "OPTLYDatabase.h"
    #import "OPTLYDatabaseEntity.h"
#endif
#import "OPTLYDataStore.h"
#import "OPTLYDatafileManagerBasic.h"
#import "OPTLYFileManager.h"
#import "OPTLYManagerBase.h"
#import "OPTLYManagerBasic.h"
#import "OPTLYManagerBuilder.h"

#if TARGET_OS_IOS
#import "OPTLYFMDBDatabase.h"
#import "OPTLYFMDBDatabaseQueue.h"
#import "OPTLYFMDB.h"
#import "OPTLYFMDBResultSet.h"
#endif

//! Project version number for OptimizelySDKShared.
FOUNDATION_EXPORT double OptimizelySDKSharedVersionNumber;

//! Project version string for OptimizelySDKShared.
FOUNDATION_EXPORT const unsigned char OptimizelySDKSharedVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <OptimizelySDKShared/PublicHeader.h>


