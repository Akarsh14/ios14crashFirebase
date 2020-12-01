//
//  UpdateUserLocationAPIClass.m
//  Woo_v2
//
//  Created by Deepak Gupta on 6/8/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "UpdateUserLocationAPIClass.h"

@implementation UpdateUserLocationAPIClass


// Method to send user current location to server
+(void)makeLocationCallToServerWithLatitudeWithCompletionBlock:(UpdateUserLocationCompletionBlock)block{
    //    updating current verification state
    
    NSString *locationOptionsUrl;
    
    //Woo user id of a user.
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId];
    
    NSString *latitude,*longitude ;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserLastLocationKey]) {
        latitude = [NSString stringWithFormat:@"%f",[[[[NSUserDefaults standardUserDefaults] objectForKey:kUserLastLocationKey] objectForKey:kLastLocationLatitudeKey] floatValue]];//latitude
        longitude = [NSString stringWithFormat:@"%f",[[[[NSUserDefaults standardUserDefaults] objectForKey:kUserLastLocationKey] objectForKey:kLastLocationLongitudeKey] floatValue]];//longitude
    }
    
    locationOptionsUrl = [NSString stringWithFormat:@"%@%@?wooId=%@&latitude=%@&longitude=%@",kBaseURLV2,kUserLocationCall,userID,latitude,longitude];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =locationOptionsUrl;
    wooRequestObj.time =900;
    wooRequestObj.requestParams = nil;
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries =10;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = sendUserLocationToServer;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        
        
        if (requestType == sendUserLocationToServer) {
            if (statusCode==401 || statusCode==402 || statusCode==500) {
                // [self handleErrorForResponseCode:statusCode];
            }
            
            if (success) {
                
                block(response , success);
                
            }
            else{
                //not send
                block(nil , NO);
            }
        }
    } shouldReachServerThroughQueue:TRUE];
    
}

@end
