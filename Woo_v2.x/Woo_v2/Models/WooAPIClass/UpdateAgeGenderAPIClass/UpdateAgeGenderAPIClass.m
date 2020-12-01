//
//  UpdateAgeGenderAPIClass.m
//  Woo_v2
//
//  Created by Deepak Gupta on 6/7/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "UpdateAgeGenderAPIClass.h"

@implementation UpdateAgeGenderAPIClass


+(void)updateAgeGenderWithUserId:(NSString *)userId withAge:(NSString *)age withGender:(NSString *)gender withCompletionBlock:(UpdateAgeGenderCompletionBlock)block{
    
    
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    if (!reachability.reachable) {
        
        [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];

        return;
    }
    
    
    NSString *apiPath = [NSString stringWithFormat:@"%@%@?wooId=%@&gender=%@&dob=%@",kBaseURLV1,kUpdateUserAgeGender,userId , gender , age];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =apiPath;
    wooRequestObj.time =900;
    //    wooRequestObj.requestParams =[NSDictionary dictionaryWithObjectsAndKeys:payloadString,@"payload", nil];
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = updateAgeGenderToServer;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        if (updateAgeGenderToServer) {
            if (statusCode==401 || statusCode==402 || statusCode==500) {
                block(nil,NO);
            }
            block(response,success);
        }
    }  shouldReachServerThroughQueue:TRUE];
    
    
}
@end
