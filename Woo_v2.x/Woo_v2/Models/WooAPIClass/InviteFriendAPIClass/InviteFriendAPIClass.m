//
//  InviteFriendAPIClass.m
//  Woo_v2
//
//  Created by Deepak Gupta on 5/5/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "InviteFriendAPIClass.h"

@implementation InviteFriendAPIClass


+(void)getInviteFriendDataWithCompletionBlock:(InviteFriendCallCompletionBlock)block{

    NSString *sendEventUrl = [NSString stringWithFormat:@"%@%@?wooId=%@",kBaseURLV2,kGetInvitation,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];

    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =sendEventUrl;
    wooRequestObj.time =9000;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =getRequest;
    wooRequestObj.numberOfRetries =-10;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = getInviteFriend;

    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
    
    
    /********************************************* Response Structure **************************************
     
     {
     compaign =     {
     active = 1;
     id = 4;
     incentiveText = "They can get you 3 FREE Crushes";
     logoUrl = "https://u2-woostore.s3.amazonaws.com/campaignLogo/crush_referal.png";
     term = "Promotion is valid on only new installs and sign ups.You will only get the crushes if the referred profiles are genuine. It\U2019s a treat for your friends too, they will get a free crush on sign up.Offer is applicable single time only.\n\n Limited time offer. Woo reserves the right to terminate and/or modify the offer at any time without prior notice.";
     title = Invite;
     };
     iMailUrl = "http://goo.gl/INriWm";
     iMessageUrl = "http://goo.gl/INriWm";
     iWhatsAppUrl = "http://goo.gl/INriWm";
     mailUrl = "http://goo.gl/7If49T";
     messageUrl = "http://goo.gl/hSoC5H";
     whatsAppUrl = "http://goo.gl/SiJbbm";
     }
     
     
     ************************************************************/
    
    
    
    if (requestType == getInviteFriend) {
        block(success,response);
        
    }
} shouldReachServerThroughQueue:FALSE];

}


+ (void)sendInviteFriendEventOnServer:(NSString *)inviteName withCompletionBlock:(InviteFriendCallCompletionBlock)block{
    
    //    http://52.74.129.186:8080/woo/api/v2/invited?wooId=4026665&inviteSource=FACEBOOK
    
    
    NSString *sendEventUrl = [NSString stringWithFormat:@"%@%@?wooId=%@&inviteSource=%@",kBaseURLV2,kSendInvitation,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId], inviteName];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =sendEventUrl;
    wooRequestObj.time =9000;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries =-10;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = sendInviteFriend;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        if (requestType == sendInviteFriend) {
            block(success,response);
        }
    } shouldReachServerThroughQueue:FALSE];
}

+(void)getCachedInviteCampaignDataFromServerWithCompletionBlock:(InviteFriendCallCompletionBlock)block
{
    NSString *sendEventUrl = [NSString stringWithFormat:@"%@%@?wooId=%@",kBaseURLV2,kGetInviteCampaign,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =sendEventUrl;
    wooRequestObj.time = 604800;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =getRequest;
    wooRequestObj.numberOfRetries =1;
    wooRequestObj.cachePolicy=GET_DATA_FROM_CACHE_ONLY;
    wooRequestObj.requestType = getInviteCampaign;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        
        /********************************************* Response Structure **************************************
         
         {
         compaign =     {
         active = 1;
         id = 4;
         incentiveText = "They can get you 3 FREE Crushes";
         logoUrl = "https://u2-woostore.s3.amazonaws.com/campaignLogo/crush_referal.png";
         term = "Promotion is valid on only new installs and sign ups.You will only get the crushes if the referred profiles are genuine. It\U2019s a treat for your friends too, they will get a free crush on sign up.Offer is applicable single time only.\n\n Limited time offer. Woo reserves the right to terminate and/or modify the offer at any time without prior notice.";
         title = Invite;
         };
         iMailUrl = "http://goo.gl/INriWm";
         iMessageUrl = "http://goo.gl/INriWm";
         iWhatsAppUrl = "http://goo.gl/INriWm";
         mailUrl = "http://goo.gl/7If49T";
         messageUrl = "http://goo.gl/hSoC5H";
         whatsAppUrl = "http://goo.gl/SiJbbm";
         }
         
         
         ************************************************************/
        
        
        
        if (requestType == getInviteCampaign) {
            block(success,response);
            
        }
    } shouldReachServerThroughQueue:FALSE];
}

+(void)getInviteCampaignDataFromServerWithCompletionBlock:(InviteFriendCallCompletionBlock)block{
    
    NSString *sendEventUrl = [NSString stringWithFormat:@"%@%@?wooId=%@",kBaseURLV2,kGetInviteCampaign,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =sendEventUrl;
    wooRequestObj.time = 604800;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =getRequest;
    wooRequestObj.numberOfRetries =-10;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_AND_UPDATE_CACHE;
    wooRequestObj.requestType = getInviteCampaign;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        
        /********************************************* Response Structure **************************************
         
         {
         compaign =     {
         active = 1;
         id = 4;
         incentiveText = "They can get you 3 FREE Crushes";
         logoUrl = "https://u2-woostore.s3.amazonaws.com/campaignLogo/crush_referal.png";
         term = "Promotion is valid on only new installs and sign ups.You will only get the crushes if the referred profiles are genuine. It\U2019s a treat for your friends too, they will get a free crush on sign up.Offer is applicable single time only.\n\n Limited time offer. Woo reserves the right to terminate and/or modify the offer at any time without prior notice.";
         title = Invite;
         };
         iMailUrl = "http://goo.gl/INriWm";
         iMessageUrl = "http://goo.gl/INriWm";
         iWhatsAppUrl = "http://goo.gl/INriWm";
         mailUrl = "http://goo.gl/7If49T";
         messageUrl = "http://goo.gl/hSoC5H";
         whatsAppUrl = "http://goo.gl/SiJbbm";
         }
         
         
         ************************************************************/
        
        
        if (requestType == getInviteCampaign) {
            block(success,response);
            
        }
    } shouldReachServerThroughQueue:FALSE];
}



@end
