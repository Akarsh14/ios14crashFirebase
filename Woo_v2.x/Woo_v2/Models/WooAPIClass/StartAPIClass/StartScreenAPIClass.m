//
//  StartAPIClass.m
//  Woo_v2
//
//  Created by Deepak Gupta on 6/30/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "StartScreenAPIClass.h"

@implementation StartScreenAPIClass


+(void)makeStartScreenCallWithCompletionBlock:(StartScreenCompletionBlock)block{
    
    NSString *url = nil;
    url = [NSString stringWithFormat:@"%@%@?wooId=%lld",kBaseURLV1,kStartScreenDone,[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue]];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =url;
    wooRequestObj.time =900;
    wooRequestObj.requestParams = nil;
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries =10;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = startScreenDoneCallToServer;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        if (requestType == startScreenDoneCallToServer) {
             block(response , success , statusCode);
        }
    } shouldReachServerThroughQueue:TRUE];
  
    
}


@end
