//
//  PostAnswerApiClass.m
//  Woo_v2
//
//  Created by Akhil Singh on 21/06/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "PostAnswerApiClass.h"

@implementation PostAnswerApiClass


+(void)postAnswerForQuestionID:(NSInteger)questionID andAnswer:(NSString *)answerText withCompletionBlock:(PostAnswerApiCompletionBlock)block{
    
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    if (!reachability.reachable) {
        
        [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];
        return;
    }
    
    NSDictionary *params;
    
    params = @{@"wooId":[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],
               @"answer":[[APP_Utilities validString:answerText] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
               @"questionId":[NSString stringWithFormat:@"%ld",(long)questionID],
               @"guid":[NSString stringWithFormat:@"%lld",CURRENT_TIMESTAMP_IN_LONG]
               };
    
    NSString *postAnswerURL = [NSString stringWithFormat:@"%@%@",kBaseURLV2,kAnswers];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [manager setRequestSerializer:requestSerializer];
    
    [manager  POST:postAnswerURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        block(YES,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(NO,nil);
        NSLog(@"error=%@",error);
        
    } caching:GET_DATA_FROM_URL_ONLY andNumberOfRetries:3];

}

@end
