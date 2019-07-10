#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "OptimizelySDKShared.h"
#import "OPTLYClient.h"
#import "OPTLYClientBuilder.h"
#import "OPTLYDatabase.h"
#import "OPTLYDatabaseEntity.h"
#import "OPTLYDatafileConfig.h"
#import "OPTLYDatafileManagerBasic.h"
#import "OPTLYDataStore.h"
#import "OPTLYEventDataStore.h"
#import "OPTLYFileManager.h"
#import "OPTLYManagerBase.h"
#import "OPTLYManagerBasic.h"
#import "OPTLYManagerBuilder.h"
#import "OPTLYFMDB.h"
#import "OPTLYFMDBDatabase.h"
#import "OPTLYFMDBDatabaseQueue.h"
#import "OPTLYFMDBResultSet.h"

FOUNDATION_EXPORT double OptimizelySDKSharedVersionNumber;
FOUNDATION_EXPORT const unsigned char OptimizelySDKSharedVersionString[];

