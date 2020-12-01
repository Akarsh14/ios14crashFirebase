//
//  FBLinkedInAPIClass.h
//  Woo_v2
//
//  Created by Suparno Bose on 27/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^FBLinkedInSyncCompletionBlock)(BOOL success, id responseObj, int errorNumber);

@interface FBLinkedInAPIClass : NSObject

+(void) updateLinkInSyncDataWithAccessToken:(NSString*)accessToken andCompletionBlock:(FBLinkedInSyncCompletionBlock)resultBlock;

+(void) logOutLinkInWithCompletionBlock:(FBLinkedInSyncCompletionBlock)resultBlock;

+(void) updateFBSyncDataWithAccessToken:(NSString*)fbSessionToken andCompletionBlock:(FBLinkedInSyncCompletionBlock)resultBlock;

@end
