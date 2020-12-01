//
//  LoginErrorFeedbackAPIClass.m
//  Woo_v2
//
//  Created by Deepak Gupta on 6/15/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "LoginErrorFeedbackAPIClass.h"

@implementation LoginErrorFeedbackAPIClass


+(void)submitFeedbackForLoginError:(NSString *)strFeedback  withCompletionBlock:(LoginErrorFeedbackCompletionBlock)block{
    
    
    NSString *feedbackUrl = nil;
    feedbackUrl = [NSString stringWithFormat:@"%@%@?feedBackText=%@",kBaseURLV1,kLoginErrorFeedback, [APP_Utilities encodeFromPercentEscapeString:strFeedback]];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =feedbackUrl;
    wooRequestObj.time =900;
    wooRequestObj.requestParams = nil;
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries =10;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = sendLoginErrorFeedbackToServer;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        if (requestType == sendLoginErrorFeedbackToServer) {
            if (statusCode==401 || statusCode==402 || statusCode==500) {
                // [self handleErrorForResponseCode:statusCode];
            }
                block(response , success);
        }
    } shouldReachServerThroughQueue:TRUE];

}
@end
