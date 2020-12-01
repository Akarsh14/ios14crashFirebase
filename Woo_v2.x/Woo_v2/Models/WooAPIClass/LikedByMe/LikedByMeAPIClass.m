//
//  LikedByMeAPIClass.m
//  Woo_v2
//
//  Created by Harish Kuramsetty on 11/18/19.
//  Copyright © 2019 Woo. All rights reserved.
//


#import "LikedByMeAPIClass.h"
#import "LikedByMe.h"

@implementation LikedByMeAPIClass

+(void)getLikedByMeProfilesFromServerWithLimit:(NSInteger)apiPageLength withTime:(NSString *)timeString  withPaginationToken:(NSString *)paginationTokenStr withIndexValue:(int)indexValue /*AndCompletionBlock:(LikedByMeProfileCompletionBlock)block*/{
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] && [APP_Utilities validString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]]>0)
    {
            NSString *timestamp = @"0";
            isfetchingLikedByMeDataFromServer = TRUE;
            
            if (timeString && [timeString length] > 0) {
                //ues this time else use other time
                timestamp = timeString;
            }
            else{
                if ([[NSUserDefaults standardUserDefaults] objectForKey:kLikedByMeProfileDashboardTimeStampKey]) {
                    timestamp = [[NSUserDefaults standardUserDefaults] objectForKey:kLikedByMeProfileDashboardTimeStampKey];
                }
            }
            
            NSString *crushesID = [[LikedByMe getIDsOfAllSkippedProfileInDB] componentsJoinedByString:@","];
            
            NSMutableDictionary *bodyParamDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:crushesID,@"targetIds", nil];
            if ([crushesID length]<1) {
                bodyParamDict = nil;
            }
            
        
            NSString *urlString = [NSString stringWithFormat:@"%@%@?wooId=%@&time=%@",kBaseURLV8, kLikedByMeDashboardAPI, [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],timestamp];
            
            if (paginationTokenStr && [paginationTokenStr length] > 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kPaginationCallStartedLikedByMeProfiles object:nil];

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
            wooRequestObj.requestType = getLikedByMeDashboardData;
            [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
                if (requestType == getLikedByMeDashboardData) {
                    if (success) {
                        [self handleLikedMeResponse:response];
                        if (response && [(NSArray *)[response objectForKey:@"profiles"] count]>0 && indexValue == 0)
                        {
                            [LikedByMe setExpiryIndexForInsertionForSkipped:(int)[[SkippedProfiles getAllSkippedProfiles]count]];
                        }

                        /*
                        if (block) {
                            block(response,success);
                        }
                         */
                        
//                        if ([[response objectForKey:@"total"] intValue] == 100) {
//                            [self getLikedByMeProfilesFromServerWithLimit:50 AndCompletionBlock:block];
//                        }
                        if ([[response allKeys] containsObject:@"paginationToken"] && [[response objectForKey:@"paginationToken"] length] > 0) {
                            //make call again
                            [self getLikedByMeProfilesFromServerWithLimit:kPaginationCallPageSize withTime:[NSString stringWithFormat:@"%lld",[[response objectForKey:@"time"] longLongValue]] withPaginationToken:[response objectForKey:@"paginationToken"] withIndexValue:[[response objectForKey:@"index"] intValue]/* AndCompletionBlock:nil*/];
                        }
                        else
                        {
                            isfetchingLikedByMeDataFromServer = FALSE;
                            [[WooScreenManager sharedInstance].oHomeViewController checkAndshowUnreadBadgeOnAboutMeIcon];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMeSection" object:nil];

                            if ([(NSArray *)[response objectForKey:@"profiles"] count]>0)
                            {
                                [[NSNotificationCenter defaultCenter] postNotificationName:kPaginationCallStoppedLikedByMeProfiles object:nil];
                            }
                        }
                    }
                    else{
                        isfetchingLikedByMeDataFromServer = FALSE;
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMeSection" object:nil];
                        /*block(nil,FALSE);*/
                    }
                    
                }
            } shouldReachServerThroughQueue:YES];
        }
    else
    {
        isfetchingLikedByMeDataFromServer = FALSE;
    }
}

+(void)handleLikedMeResponse:(id)response{
    if (!response) {
        return;
    }
    
    
    //&& ![[response allKeys] containsObject:@"paginationToken"]
    if ([[response allKeys] containsObject:@"time"] ) {
        [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:@"time"] forKey:kLikedByMeProfileDashboardTimeStampKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    if (response && [(NSArray *)[response objectForKey:@"profiles"] count]>0) {
        [LikedByMe insertOrUpdateSkippedProfileData:[response objectForKey:@"profiles"] withCompletionHandler:^(BOOL isInsertionCompleted) {
            [AppLaunchModel sharedInstance].isNewDataPresentInLikedByMeSection = true;
//            [LikedByMeProfiles setInsertionCompleted:true];
            [[WooScreenManager sharedInstance].oHomeViewController checkAndshowUnreadBadgeOnAboutMeIcon];
        }];
    }
    else
    {
        [LikedByMe setInsertionCompleted:true];
        [[WooScreenManager sharedInstance].oHomeViewController checkAndshowUnreadBadgeOnAboutMeIcon];

    }
    if ((response && [(NSArray *)[response objectForKey:@"disableTargetIds"] count]>0)) {
        [LikedByMe deleteSkippedProfileDataFromDBWithUserIDs:[response objectForKey:@"disableTargetIds"] withCompletionHandler:^(BOOL isDeletionCompleted) {
            
        }];
    }
    
    
}

+(BOOL)getIsfetchingLikedByMeDataFromServerValue{
    return isfetchingLikedByMeDataFromServer;
}
+(void)setIsfetchingLikedByMeDataFromServerValue:(BOOL)value{
     isfetchingLikedByMeDataFromServer = value;
}


@end
