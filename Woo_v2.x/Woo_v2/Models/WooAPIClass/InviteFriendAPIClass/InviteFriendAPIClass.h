//
//  InviteFriendAPIClass.h
//  Woo_v2
//
//  Created by Deepak Gupta on 5/5/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^InviteFriendCallCompletionBlock)(BOOL,id);

@interface InviteFriendAPIClass : NSObject

// Get Invite Friend Data API Call
+(void)getInviteFriendDataWithCompletionBlock:(InviteFriendCallCompletionBlock)block;

// Send Invite Friend Event API Call
+ (void)sendInviteFriendEventOnServer:(NSString *)inviteName withCompletionBlock:(InviteFriendCallCompletionBlock)block;

//Get Invite Campaign data from server
+(void)getInviteCampaignDataFromServerWithCompletionBlock:(InviteFriendCallCompletionBlock)block;
//Get Invite Campaign data from server
+(void)getCachedInviteCampaignDataFromServerWithCompletionBlock:(InviteFriendCallCompletionBlock)block;
@end
