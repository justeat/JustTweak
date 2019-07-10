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

#import "OptimizelySDKEventDispatcher.h"
#import "OPTLYEventDispatcher.h"
#import "OPTLYEventDispatcherBuilder.h"

FOUNDATION_EXPORT double OptimizelySDKEventDispatcherVersionNumber;
FOUNDATION_EXPORT const unsigned char OptimizelySDKEventDispatcherVersionString[];

