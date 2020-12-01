//
//  SkippedProfileAPIClass.m
//  Woo_v2
//
//  Created by Umesh Mishraji on 30/08/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "SkippedProfileAPIClass.h"
#import "SkippedProfiles.h"

@implementation SkippedProfileAPIClass

+(void)getSkippedProfilesFromServerWithLimit:(NSInteger)apiPageLength withTime:(NSString *)timeString  withPaginationToken:(NSString *)paginationTokenStr withIndexValue:(int)indexValue /*AndCompletionBlock:(SkippedProfileCompletionBlock)block*/{
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] && [APP_Utilities validString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]]>0)
    {
            NSString *timestamp = @"0";
            isfetchingSkippedDataFromServer = TRUE;
            
            if (timeString && [timeString length] > 0) {
                //ues this time else use other time
                timestamp = timeString;
            }
            else{
                if ([[NSUserDefaults standardUserDefaults] objectForKey:kSkippedProfileDashboardTimeStampKey]) {
                    timestamp = [[NSUserDefaults standardUserDefaults] objectForKey:kSkippedProfileDashboardTimeStampKey];
                }
            }
            
            NSString *crushesID = [[SkippedProfiles getIDsOfAllSkippedProfileInDB] componentsJoinedByString:@","];
            
            NSMutableDictionary *bodyParamDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:crushesID,@"targetIds", nil];
            if ([crushesID length]<1) {
                bodyParamDict = nil;
            }
            
            NSString *urlString = [NSString stringWithFormat:@"%@%@?wooId=%@&time=%@&pageSize=%ld",kBaseURLV8, kSkippedProfileDashboardAPI, [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],timestamp,apiPageLength];
            
            if (paginationTokenStr && [paginationTokenStr length] > 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kPaginationCallStartedSkippedProfiles object:nil];

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
            wooRequestObj.requestType = getSkippedProfileDashboardData;
            [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
                if (requestType == getSkippedProfileDashboardData) {
                    if (success) {
                        [self handleLikedMeResponse:response];
                        if (response && [(NSArray *)[response objectForKey:@"profiles"] count]>0 && indexValue == 0)
                        {
                            [SkippedProfiles setExpiryIndexForInsertionForSkipped:(int)[[SkippedProfiles getAllSkippedProfiles]count]];
                        }

                        /*
                        if (block) {
                            block(response,success);
                        }
                         */
                        
//                        if ([[response objectForKey:@"total"] intValue] == 100) {
//                            [self getSkippedProfilesFromServerWithLimit:50 AndCompletionBlock:block];
//                        }
                        if ([[response allKeys] containsObject:@"paginationToken"] && [[response objectForKey:@"paginationToken"] length] > 0) {
                            //make call again
                            [self getSkippedProfilesFromServerWithLimit:kPaginationCallPageSize withTime:[NSString stringWithFormat:@"%lld",[[response objectForKey:@"time"] longLongValue]] withPaginationToken:[response objectForKey:@"paginationToken"] withIndexValue:[[response objectForKey:@"index"] intValue]/* AndCompletionBlock:nil*/];
                        }
                        else
                        {
                            isfetchingSkippedDataFromServer = FALSE;
                            [[WooScreenManager sharedInstance].oHomeViewController checkAndshowUnreadBadgeOnAboutMeIcon];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMeSection" object:nil];

                            if ([(NSArray *)[response objectForKey:@"profiles"] count]>0)
                            {
                                [[NSNotificationCenter defaultCenter] postNotificationName:kPaginationCallStoppedSkippedProfiles object:nil];
                            }
                        }
                    }
                    else{
                        isfetchingSkippedDataFromServer = FALSE;
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMeSection" object:nil];
                        /*block(nil,FALSE);*/
                    }
                    
                }
            } shouldReachServerThroughQueue:YES];
        }
    else
    {
        isfetchingSkippedDataFromServer = FALSE;
    }
}

+(void)handleLikedMeResponse:(id)response{
    if (!response) {
        return;
    }
    
    
    //&& ![[response allKeys] containsObject:@"paginationToken"]
    if ([[response allKeys] containsObject:@"time"] ) {
        [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:@"time"] forKey:kSkippedProfileDashboardTimeStampKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    if (response && [(NSArray *)[response objectForKey:@"profiles"] count]>0) {
        [SkippedProfiles insertOrUpdateSkippedProfileData:[response objectForKey:@"profiles"] withCompletionHandler:^(BOOL isInsertionCompleted) {
            [AppLaunchModel sharedInstance].isNewDataPresentInSkippedSection = true;
//            [SkippedProfiles setInsertionCompleted:true];
            [[WooScreenManager sharedInstance].oHomeViewController checkAndshowUnreadBadgeOnAboutMeIcon];
        }];
    }
    else
    {
        [SkippedProfiles setInsertionCompleted:true];
        [[WooScreenManager sharedInstance].oHomeViewController checkAndshowUnreadBadgeOnAboutMeIcon];

    }
    if ((response && [(NSArray *)[response objectForKey:@"disableTargetIds"] count]>0)) {
        [SkippedProfiles deleteSkippedProfileDataFromDBWithUserIDs:[response objectForKey:@"disableTargetIds"] withCompletionHandler:^(BOOL isDeletionCompleted) {
            
        }];
    }
    
    
}

+(BOOL)getIsfetchingSkippedDataFromServerValue{
    return isfetchingSkippedDataFromServer;
}
+(void)setIsfetchingSkippedDataFromServerValue:(BOOL)value{
     isfetchingSkippedDataFromServer = value;
}


@end
