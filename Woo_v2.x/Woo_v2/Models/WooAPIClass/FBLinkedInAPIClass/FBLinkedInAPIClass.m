//
//  FBLinkedInAPIClass.m
//  Woo_v2
//
//  Created by Suparno Bose on 27/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "FBLinkedInAPIClass.h"

@implementation FBLinkedInAPIClass

+(void) updateLinkInSyncDataWithAccessToken:(NSString*)accessToken andCompletionBlock:(FBLinkedInSyncCompletionBlock)resultBlock{
    
    NSString *linkedInUrl = [NSString stringWithFormat:@"%@/sync/linkedin?wooId=%@&accessToken=%@",kBaseURLV5,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],accessToken];
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =linkedInUrl;
    wooRequestObj.time =9000;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries =-10;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = sendLinkedInAccessTokenToServer;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
            resultBlock(success, response, statusCode);

        } shouldReachServerThroughQueue:FALSE];
    });
}

+(void) logOutLinkInWithCompletionBlock:(FBLinkedInSyncCompletionBlock)resultBlock{
    
    NSString *linkedInUrl = [NSString stringWithFormat:@"%@/linkedIn/delinked?wooId=%@&delinked=false",kBaseURLV4,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =linkedInUrl;
    wooRequestObj.time =9000;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries =-10;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = sendLinkedInAccessTokenToServer;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
            resultBlock(success, response, statusCode);
            
        } shouldReachServerThroughQueue:FALSE];
    });
}

+(void) updateFBSyncDataWithAccessToken:(NSString*)fbSessionToken andCompletionBlock:(FBLinkedInSyncCompletionBlock)resultBlock{
    
    NSString *wooUserId = [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId];
    NSString *syncWorkKey = @"false";
    NSString *syncAgeKey = @"false";
    NSString *syncEducationKey = @"false";
    NSString *syncGender     =  @"false";
    
    NSString *fbSyncURLString = [NSString stringWithFormat:@"%@%@?syncWork=%@&syncEducation=%@&syncAge=%@&syncGender=%@&wooId=%@&accessToken=%@",kBaseURLV4,kFacebookSyncAPIv2,syncWorkKey,syncEducationKey,syncAgeKey,syncGender,wooUserId,fbSessionToken];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =fbSyncURLString;
    wooRequestObj.time =0;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries =0;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = makeFbSyncCallToServer;
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj
                              withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
                                  
                                  resultBlock(success, response, statusCode);
                                  
                              } shouldReachServerThroughQueue:YES];
}

@end
