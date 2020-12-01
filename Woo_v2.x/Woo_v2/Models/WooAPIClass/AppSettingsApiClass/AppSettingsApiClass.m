//
//  AppSettingsApiClass.m
//  Woo_v2
//
//  Created by Akhil Singh on 23/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "AppSettingsApiClass.h"

@implementation AppSettingsApiClass

+(void)sendFeedbackToServer:(NSString *)feedBackString andNumberOfStars:(int)stars
                   andEmail:(NSString*)mail
             andPhoneNumber:(NSString*)phoneNumber
        WithCompletionBlock:(AppSettingsApiCompletionBlock)block{
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@?wooId=%@&feedBackText=%@&numberOfStars=%d",kBaseURLV2, kUserFeedback, [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],[feedBackString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], stars];
    
    if (mail && [mail length] > 0) {
        urlString = [NSString stringWithFormat:@"%@&email=%@",urlString,mail];
    }
    
    if (mail && [mail length] > 0) {
        urlString = [NSString stringWithFormat:@"%@&phoneNumer=%@",urlString,phoneNumber];
    }
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =urlString;
    wooRequestObj.time =900;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries = 3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = userFeedback;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        if (statusCode==401 || statusCode==402 || statusCode==500) {
            //                    [self handleErrorForResponseCode:statusCode];
        }
        if (error) {
            //                    [ALToastView toastInView:APP_DELEGATE.window withText:@"Unable to sent feedback."];
        }
        if (requestType == userFeedback && statusCode==200) {
            if (block) {
                block(success, response, statusCode);
            }
        }
    }   shouldReachServerThroughQueue:TRUE];
    
}

+ (void)logoutUserWithCompletionBlock:(AppSettingsApiCompletionBlock)block{
    NSString *urlString = [NSString stringWithFormat:@"%@%@?wooId=%@",kBaseURLV2, kLogoutUser, [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
    
    NSLog(@"urlString kya hai %@", urlString);
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =urlString;
    wooRequestObj.time =900;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries = 3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = logoutUser;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        NSLog(@"response kya hai %@", response);
        NSLog(@"responseType kya hai %u", requestType);
        NSLog(@"statusCode kya hai %u", statusCode);
        
        if (statusCode==401 || statusCode==402 || statusCode==500) {
            //            [self handleErrorForResponseCode:statusCode];
        }
        if (error) {
            block(success, error, 0);
        }
        if (requestType == logoutUser && statusCode==200) {
            block(success, response, statusCode);
        }
    }   shouldReachServerThroughQueue:TRUE];

}

+ (void)disableUserWithCompletionBlock:(AppSettingsApiCompletionBlock)block{
    NSString *urlString = [NSString stringWithFormat:@"%@%@?wooId=%@",kBaseURLV2_HTTPS, kDisableUser, [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =urlString;
    wooRequestObj.time =900;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries = 3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = logoutUser;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        if (statusCode==401 || statusCode==402 || statusCode==500) {
            //            [self handleErrorForResponseCode:statusCode];
        }
        if (error) {
        }
        if (requestType == logoutUser && statusCode==200) {
            block(success, response, statusCode);
        }
    }   shouldReachServerThroughQueue:TRUE];    
}

+ (void)deleteUserWithUserComment:(NSString *)comment withEmail:(NSString *)email andPhoneNumber:(NSString *)phoneNumber andDeleteFeedback:(BOOL)feedback WithCompletionBlock:(AppSettingsApiCompletionBlock)block{
    NSString *urlString = [NSString stringWithFormat:@"%@%@?wooId=%@&wooToken=%@&deleteFeedback=%@",kBaseURLV3_HTTPS, kDeleteUser, [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],[[NSUserDefaults standardUserDefaults] objectForKey:kWooToken],(feedback ? @"POSITIVE":@"NEGATIVE")];
    
    if (![email isEqualToString:@""]){
        urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"&email=%@",[email stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]];
    }
    
    if (![phoneNumber isEqualToString:@""]){
        urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"&phoneNumber=%@",[phoneNumber stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]];
    }
    
    if(![comment isEqualToString:@""])
    {
        urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"&comments=%@",[comment stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]];
    }
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =urlString;
    wooRequestObj.time =900;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =deleteRequest;
    wooRequestObj.numberOfRetries = 3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = deleteUser;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        if (statusCode==401 || statusCode==402 || statusCode==500) {
            //            [self handleErrorForResponseCode:statusCode];
        }
        if (error) {
        }
        if (requestType == deleteUser && statusCode==200) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserLastLocationKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            block(success, response, statusCode);
        }
    }   shouldReachServerThroughQueue:TRUE];
    
}


@end
