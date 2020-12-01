//
//  GetProductAPIClass.m
//  Woo_v2
//
//  Created by Deepak Gupta on 10/7/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "GetProductAPIClass.h"
#import "PurchaseProductDetailModel.h"
@implementation GetProductAPIClass

+(void)getPurchaseProductsDetailFromServerWithCompletionBlock:(PurchaseProductDetailAPICompletionBlock)block{
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] && [APP_Utilities validString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]]>0) {

    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    
    if (!reachability.reachable) {
        [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];
        
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@/%@",kBaseURLV10,kGetPurchaseProductsDetailFromServer,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =urlString;
    wooRequestObj.time =9000;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =getRequest;
    wooRequestObj.numberOfRetries =0;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = getPurchaseProductDetailFromServer;
    
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        if (requestType == getPurchaseProductDetailFromServer) {
            
            if (success) {
                
                [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"productsFetched"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[PurchaseProductDetailModel sharedInstance] updatePurchaseProductDetailModel:response];
            }
            
        }
        
        
    } shouldReachServerThroughQueue:YES];

    }
}

@end
