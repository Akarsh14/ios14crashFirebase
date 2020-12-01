//
//  BoostAPIClass.m
//  Woo_v2
//
//  Created by Suparno Bose on 25/01/16.
//  Copyright © 2016 Woo. All rights reserved.
//

#import "BoostAPIClass.h"
#import "MeDashboard.h"
#import "BoostModel.h"

@implementation BoostAPIClass

+(void)getVisitorsFromServerWithLimit:(NSInteger)apiPageLength withTime:(NSString *)timeString  withPaginationToken:(NSString *)paginationTokenStr withIndexValue:(int)indexValue AndCompletionBlock:(BoostCompletionBlock)block{

    if ([[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] && [APP_Utilities validString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]]>0) {
            NSString *timestamp = @"0";
        
            isfetchingVisitorDataFromServer = TRUE;
            if (timeString && [timeString length] > 0) {
                //ues this time else use other time
                timestamp = timeString;
            }
            else{
                if ([[NSUserDefaults standardUserDefaults] objectForKey:kBoostDashboardTimestampKey]) {
                    timestamp = [[NSUserDefaults standardUserDefaults] objectForKey:kBoostDashboardTimestampKey];
                }
            }
            NSString *crushesID = [[MeDashboard getIDsOfAllTheBoostInDB] componentsJoinedByString:@","];
            
            NSMutableDictionary *bodyParamDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:crushesID,@"targetIds", nil];
            if ([crushesID length]<1) {
                bodyParamDict = nil;
            }
        
            NSString *urlString = [NSString stringWithFormat:@"%@%@?wooId=%@&time=%@",kBaseURLV8, kVisitorDashboardAPI_New, [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],timestamp];
            if (paginationTokenStr && [paginationTokenStr length] > 0)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kPaginationCallStarted object:nil];                
                urlString = [NSString stringWithFormat:@"%@&paginationToken=%@",urlString, paginationTokenStr];
            }
            if (indexValue > -1) {
                urlString = [NSString stringWithFormat:@"%@&index=%d",urlString, indexValue];
            }
            
            WooRequest *wooRequestObj = [[WooRequest alloc]init];
            wooRequestObj.url =urlString;
            NSLog(@"Visitor urlString :%@",urlString);
            wooRequestObj.time =900;
            wooRequestObj.requestParams =bodyParamDict;
            wooRequestObj.methodType =getRequest;
            wooRequestObj.numberOfRetries = 0;
            wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
            wooRequestObj.requestType = getBoostDashboardData;
            [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
                if (requestType == getBoostDashboardData) {
                    if (success)
                    {
                        [self handleBoostResponse:response];
                     
                        
                        if (response && [(NSArray *)[response objectForKey:@"profiles"] count]>0 && indexValue == 0)
                        {
                            [MeDashboard setExpiryIndexForInsertion:(int)[[MeDashboard getAllExpiringVisitors]count]];
                        }
                        
                        if (block != nil) {
                            block(response,success);
                        }
                        NSLog(@"visitor response :%@",response);
                        
//                        if ([[response objectForKey:@"total"] intValue] == 100) {
//                            [self getVisitorsFromServerWithLimit:50 AndCompletionBlock:block];
//                        }
                        if ([[response allKeys] containsObject:@"paginationToken"] && [[response objectForKey:@"paginationToken"] length] > 0) {
                            
                            //make call again
                            [self getVisitorsFromServerWithLimit:kPaginationCallPageSize withTime:[NSString stringWithFormat:@"%lld",[[response objectForKey:@"time"] longLongValue]] withPaginationToken:[response objectForKey:@"paginationToken"] withIndexValue:[[response objectForKey:@"index"] intValue] AndCompletionBlock:nil];
                        }
                        else
                        {
                            isfetchingVisitorDataFromServer = FALSE;
                           [[WooScreenManager sharedInstance].oHomeViewController checkAndshowUnreadBadgeOnAboutMeIcon];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMeSection" object:nil];
                            if ([(NSArray *)[response objectForKey:@"profiles"] count]>0)
                            {
                                [[NSNotificationCenter defaultCenter] postNotificationName:kPaginationCallStopped object:nil];
                            }
                            
                        }
                    }
                    else{
                        isfetchingVisitorDataFromServer = FALSE;
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMeSection" object:nil];
                        block(nil,FALSE);
                    }
                    
                }
            } shouldReachServerThroughQueue:YES];
        }
    else
    {
        isfetchingVisitorDataFromServer = false;
    }
}

+(void)handleBoostResponse:(id)response{
    if (!response) {
        return;
    }
    if ([[response allKeys] containsObject:@"time"]) {
        [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:@"time"] forKey:kBoostDashboardTimestampKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
//    [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:@"time"] forKey:kBoostDashboardTimestampKey];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (response && [(NSArray *)[response objectForKey:@"profiles"] count]>0) {
        [MeDashboard insertOrUpdateBoostDashboardData:[response objectForKey:@"profiles"] forType:VisitorMe withInsertionCompletionHandler:^(BOOL isInsertionCompleted) {
            [AppLaunchModel sharedInstance].isNewDataPresentInVisitorSection = TRUE;
//            [BoostDashboard setInsertionCompleted:true];
            [[WooScreenManager sharedInstance].oHomeViewController checkAndshowUnreadBadgeOnAboutMeIcon];
        }];
    }
    else
    {
        [MeDashboard setInsertionCompleted:true];
        [[WooScreenManager sharedInstance].oHomeViewController checkAndshowUnreadBadgeOnAboutMeIcon];
    }
    if ((response && [(NSArray *)[response objectForKey:@"disableTargetIds"] count]>0)) {
        [MeDashboard deleteBoostDataFromDBWithUserIDs:[response objectForKey:@"disableTargetIds"] withCompletionHandler:^(BOOL isDeletionCompleted) {
            [[WooScreenManager sharedInstance].oHomeViewController checkAndshowUnreadBadgeOnAboutMeIcon];
        }];
    }
    
    
    
}

+(BOOL)getIsfetchingVisitorDataFromServerValue{
    return isfetchingVisitorDataFromServer;
}

+(void)setIsfetchingVisitorDataFromServerValue:(BOOL)value{
    isfetchingVisitorDataFromServer = value;
}
@end
