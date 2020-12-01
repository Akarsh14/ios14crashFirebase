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

#import "TrueSDK.h"
#import "NSURL+TrueSDK.h"
#import "TCError.h"
#import "TCTrueProfile.h"
#import "TCTrueProfileRequest.h"
#import "TCTrueProfileResponse.h"
#import "TCTrueSDKLogger.h"
#import "TCUtils.h"
#import "TCVersion.h"
#import "TCProfileRequestButton.h"
#import "TCTrueSDK.h"

FOUNDATION_EXPORT double TrueSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char TrueSDKVersionString[];

