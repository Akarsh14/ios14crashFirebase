//
//  MeApiClass.m
//  Woo_v2
//
//  Created by Ankit Batra on 05/04/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

#import "MeApiClass.h"

@implementation MeApiClass


+(void)syncProfileViews:(NSArray *)selectedViewers withCompletionBlock:(SyncViewsApiCompletionBlock)block
{
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    if (!reachability.reachable) {
        
        [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];
        return;
    }
    
    NSDictionary *params;
    
    params = [[NSDictionary alloc] initWithObjectsAndKeys:selectedViewers,@"selectedViewers",nil];
  //@{@"selectedViewers":selectedViewers};
    
    NSString *postAnswerURL = [NSString stringWithFormat:@"%@%@?actorId=%@",kBaseURLV3,kSyncProfileViews,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [manager setRequestSerializer:requestSerializer];
    
    [manager  POST:postAnswerURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        block(YES,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(NO,nil);
        NSLog(@"error=%@",error);
        
    } caching:GET_DATA_FROM_URL_ONLY andNumberOfRetries:0];
    
}


@end
