//
//  BoostProductsAPICalss.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 01/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "BoostProductsAPICalss.h"

@implementation BoostProductsAPICalss


+(void)makePopupEventAPIwithType:(NSString *)productType{
    
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    
    if (!reachability.reachable)
        return;
    
    
    NSString *productEventAPI = [NSString stringWithFormat:@"%@%@%lld/%@",kBaseURLV1,kPurchaseEventAPI,[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue],productType];
    
    NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:@"text",@"json",nil];
    
//    params = @{@"json":@"text"};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [manager setRequestSerializer:requestSerializer];
    
    [manager  POST:productEventAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    } caching:GET_DATA_FROM_URL_ONLY andNumberOfRetries:3];

    
}

+(void)makeMatchFailureEventCallToServerWithTargetId:(NSString *)tagetId{
    
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    
    if (!reachability.reachable)
        return;
    
    
    NSString *productEventAPI = [NSString stringWithFormat:@"%@%@%lld/%@",kBaseURLV1,kPurchaseEventAPI,[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue],@"MATCH_FAILURE"];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],@"actorId",tagetId,@"targetId", nil];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [manager setRequestSerializer:requestSerializer];
    
    [manager  POST:productEventAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    } caching:GET_DATA_FROM_URL_ONLY andNumberOfRetries:3];
    
    
}


+(void)getProductsFromServerForWooID:(NSString *)wooID withCompletionBlock:(BoostAPICompletionBlock)block withType:(NSString *)productType{
    
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    
    if (!reachability.reachable) {
        [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];
        
        return;
    }
    
    NSString *getBoostProductsAPI = [NSString stringWithFormat:@"%@%@%@/%@",kBaseURLV3,kGetProductsFromServer,productType,wooID];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =getBoostProductsAPI;
    wooRequestObj.time =9000;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =getRequest;
    wooRequestObj.numberOfRetries =-10;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = getPrductsFromServer;
    
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
//        NSLog(@"Response >>>. %@",response);
        block((success?YES:NO), response, statusCode);
        
    } shouldReachServerThroughQueue:YES];
    
}



+(void)activateBoostForWooID:(NSString *)wooID withCompletionBlock:(ActivateBoostCompletionBlock) block{
    
    
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    
    BOOL isNetworkReachable = (reachability.isReachable || reachability.isReachableViaWiFi || reachability.isReachableViaWWAN);
    
    if (!isNetworkReachable) {
        [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];
        
        return;
    }

    NSString *activateBoostString = [NSString stringWithFormat:@"%@%@/%@",kBaseURLV3,kActivateBoost,wooID];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =activateBoostString;
    wooRequestObj.time =0;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = activatingBoost;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        if (requestType == activatingBoost) {
            if (!success) {
                block(NO, response, statusCode);
            }else{
                
                if ([BoostModel sharedInstance].availableBoost >= 1) {
                    [BoostModel sharedInstance].availableBoost = [BoostModel sharedInstance].availableBoost - 1;
                    [BoostModel sharedInstance].currentlyActive = YES;
                    [BoostModel sharedInstance].percentageCompleted = 0.0f;
                }
                block(YES, response, statusCode);
            }
        }
        
    } shouldReachServerThroughQueue:TRUE];

    
    
}
@end
