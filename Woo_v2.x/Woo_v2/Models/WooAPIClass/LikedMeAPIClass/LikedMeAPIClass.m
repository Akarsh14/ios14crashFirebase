//
//  LikedMeAPIClass.m
//  Woo_v2
//
//  Created by Suparno Bose on 25/01/16.
//  Copyright © 2016 Woo. All rights reserved.
//

#import "LikedMeAPIClass.h"

#import "LikedMe.h"

@implementation LikedMeAPIClass

+(void)getLikedMeProfilesFromServerWithLimit:(NSInteger)apiPageLength withTime:(NSString *)timeString withPaginationToken:(NSString *)paginationTokenStr withIndexValue:(int)indexValue AndCompletionBlock:(LikedMeCompletionBlock)block
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] && [APP_Utilities validString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]]>0)
    {
        isfetchingLikedMeDataFromServer = TRUE;
        NSString *timestamp = @"0";
        
        if (timeString && [timeString length] > 0) {
            timestamp = timeString;
        }
        else{
            if ([[NSUserDefaults standardUserDefaults] objectForKey:kLikedMeDashboardTimestampKey]) {
                timestamp = [[NSUserDefaults standardUserDefaults] objectForKey:kLikedMeDashboardTimestampKey];
            }
        }
        
        
        NSString *crushesID = [[LikedMe getIDsOfAllTheLikedMeProfileInDB] componentsJoinedByString:@","];
        
        NSMutableDictionary *bodyParamDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:crushesID,@"targetIds", nil];
        if ([crushesID length]<1) {
            bodyParamDict = nil;
        }
        
        NSString *urlString = [NSString stringWithFormat:@"%@%@?wooId=%@&time=%@&pageSize=%ld",kBaseURLV8,kLikedMeDashboardAPI, [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],timestamp,apiPageLength];
        if (paginationTokenStr && [paginationTokenStr length] > 0)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kPaginationCallStartedLikedMe object:nil];
            urlString = [NSString stringWithFormat:@"%@&paginationToken=%@",urlString, paginationTokenStr];
        }
        if (indexValue > -1) {
            urlString = [NSString stringWithFormat:@"%@&index=%d",urlString, indexValue];
        }
        
        WooRequest *wooRequestObj = [[WooRequest alloc]init];
        wooRequestObj.url =urlString;
        wooRequestObj.time =900;
        wooRequestObj.requestParams =bodyParamDict;
        wooRequestObj.methodType =getRequest;
        wooRequestObj.numberOfRetries = 0;
        wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
        wooRequestObj.requestType = getLikedMeDashboardData;
        [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
            if (requestType == getLikedMeDashboardData) {
                if (success)
                {
                    [self handleLikedMeResponse:response];
                    
                    if (response && [(NSArray *)[response objectForKey:@"profiles"] count]>0 && indexValue == 0)
                    {
                        [LikedMe setExpiryIndexForInsertionForLikedMe:(int)[[LikedMe getAllExpiringLikedMeProfiles]count]];
                    }
                    
                    
                    if (block) {
                        block(response,success);
                    }
                    

                    if ([[response allKeys] containsObject:@"paginationToken"] && [[response objectForKey:@"paginationToken"] length] > 0){
                        //make call again
                        [self getLikedMeProfilesFromServerWithLimit:kPaginationCallPageSize withTime:[NSString stringWithFormat:@"%lld",[[response objectForKey:@"time"] longLongValue]] withPaginationToken:[response objectForKey:@"paginationToken"] withIndexValue:[[response objectForKey:@"index"] intValue] AndCompletionBlock:nil];
                    }
                    else
                    {
                        isfetchingLikedMeDataFromServer = FALSE;
                        [[WooScreenManager sharedInstance].oHomeViewController checkAndshowUnreadBadgeOnAboutMeIcon];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMeSection" object:nil];

                        if ([(NSArray *)[response objectForKey:@"profiles"] count]>0)
                        {
                            [[NSNotificationCenter defaultCenter] postNotificationName:kPaginationCallStoppedLikedMe object:nil];
                        }
                    }
                }
                else{
                    isfetchingLikedMeDataFromServer = FALSE;
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMeSection" object:nil];
                    if(block)
                    {
                        block(nil,FALSE);
                    }
                    
                }
                
            }
        } shouldReachServerThroughQueue:YES];
    }
    else
    {
        isfetchingLikedMeDataFromServer = FALSE;
    }
}

+(void)handleLikedMeResponse:(id)response{
    if (!response) {
        return;
    }
    
    
    //&& (![[response allKeys] containsObject:@"paginationToken"])
    if ([[response allKeys] containsObject:@"time"]) {
        [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:@"time"] forKey:kLikedMeDashboardTimestampKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    if (response && [(NSArray *)[response objectForKey:@"profiles"] count]>0) {
        [MeDashboard insertOrUpdateBoostDashboardData:[response objectForKey:@"profiles"] forType:likedMe  withInsertionCompletionHandler:^(BOOL isInsertionCompleted) {
             [AppLaunchModel sharedInstance].isNewDataPresentInLikedMESection = TRUE;
            //            [LikedMe setInsertionCompleted:true];
                        [[WooScreenManager sharedInstance].oHomeViewController checkAndshowUnreadBadgeOnAboutMeIcon];
        }];
       
    }
    else{
        [MeDashboard setInsertionCompleted:true];
        [[WooScreenManager sharedInstance].oHomeViewController checkAndshowUnreadBadgeOnAboutMeIcon];
    }
    if ((response && [(NSArray *)[response objectForKey:@"disableTargetIds"] count]>0)) {
        [MeDashboard deleteBoostDataFromDBWithUserIDs:[response objectForKey:@"disableTargetIds"] withCompletionHandler:^(BOOL isDeletionCompleted) {
            
        }];
    }
    
    
}

+(BOOL)getIsfetchingLikedMeDataFromServerValue{
    return isfetchingLikedMeDataFromServer;
}
+(void)setIsfetchingLikedMeDataFromServerValue:(BOOL)value
{
    isfetchingLikedMeDataFromServer = value;
}
@end
