//
//  BoostCrushAPI.m
//  Woo_v2
//
//  Created by Suparno Bose on 25/01/16.
//  Copyright © 2016 Woo. All rights reserved.
//

#import "CrushAPIClass.h"
#import "CrushesDashboard.h"
#import "Woo_v2-Swift.h"

@implementation CrushAPIClass

+(void)getCrushesFromServerWithLimit:(NSInteger)apiPageLength withTime:(NSString *)timeString  withPaginationToken:(NSString *)paginationTokenStr withIndexValue:(int)indexValue AndCompletionBlock:(CrushCompletionBlock)block{
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] && [APP_Utilities validString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]]>0) {
        NSString *timestamp = @"0";
        isfetchingCrushDataFromServer = TRUE;
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kCrushDashboardTimestampKey]) {
            timestamp = [[NSUserDefaults standardUserDefaults] objectForKey:kCrushDashboardTimestampKey];
        }

        NSString *getCrushesString = [NSString stringWithFormat:@"%@%@?wooId=%@&time=%@&pageSize=%ld",kBaseURLV7,kCrushDashboardAPI,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],timestamp,(long)apiPageLength];
        
        if (paginationTokenStr && [paginationTokenStr length] > 0) {
            getCrushesString = [NSString stringWithFormat:@"%@&paginationToken=%@",getCrushesString, paginationTokenStr];
        }
        if (indexValue > -1) {
            getCrushesString = [NSString stringWithFormat:@"%@&index=%d",getCrushesString, indexValue];
        }

        
        NSString *crushesID = [[CrushesDashboard getIDsOfAllTheCrushesInDB] componentsJoinedByString:@","];;
        
        NSMutableDictionary *bodyParamDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:crushesID,@"targetIds", nil];
        
        WooRequest *wooRequestObj = [[WooRequest alloc]init];
        wooRequestObj.url =getCrushesString;
        wooRequestObj.time =0;
        wooRequestObj.requestParams =bodyParamDict;
        wooRequestObj.methodType =getRequest;
        wooRequestObj.numberOfRetries =3;
        wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
        wooRequestObj.requestType = getCrushDashboardData;
        
        [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
            
            if (requestType == getCrushDashboardData && success) {
                [CrushAPIClass handleCrushResponseAndUpdateItLocally:response];
                if (block) {
                    block(response);
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMeSection" object:nil];

                if ([[response allKeys] containsObject:@"paginationToken"] && [[response objectForKey:@"paginationToken"] length] > 0) {
                    //make call again
//                    [self getVisitorsFromServerWithLimit:kPaginationCallPageSize withTime:[NSString stringWithFormat:@"%lld",[timeString longLongValue]] withPaginationToken:[response objectForKey:@"paginationToken"] withIndexValue:[[response objectForKey:@"index"] intValue] AndCompletionBlock:nil];
                   // [self getCrushesFromServerWithLimit:kPaginationCallPageSize withTime:[NSString stringWithFormat:@"%lld",[timeString longLongValue]] withPaginationToken:[response objectForKey:@"paginationToken"] withIndexValue:[[response objectForKey:@"index"] intValue] AndCompletionBlock:nil];
                }
                
                [[WooScreenManager sharedInstance].oHomeViewController checkAndshowUnreadBadgeOnAboutMeIcon];

            }
            else
            {
                isfetchingCrushDataFromServer = FALSE;
                block(nil);
            }
        } shouldReachServerThroughQueue:TRUE];
    }
    else{
        isfetchingCrushDataFromServer = FALSE;
        block(nil);
    }
}

+(void)likeAnAnswer:(TargetQuestionModel *)question successBlock:(CrushCompletionBlock)block{
    
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    BOOL isNetworkReachable = (reachability.isReachable || reachability.isReachableViaWiFi || reachability.isReachableViaWWAN);
    if (!isNetworkReachable) {
        //        [APP_Utilities displayAlertWithTitle:NSLocalizedString(@"Oops!", nil) message:NSLocalizedString(@"No internet connection! Please try again.", nil) withDelegate:self];
        
        SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"Please check your internet connection",nil));
        return;
    }
    
    [APP_DELEGATE sendSwrveEventWithEvent:@"Answers.LikeAnswer" andScreen:@"Answers"];
    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"LikeAnswer" forScreenName:@"Answer"];
    NSString *likeAnswerURL = [NSString stringWithFormat:@"%@/answers/%ld/activity?wooId=%@&readActivity=%@&status=%@",kBaseURLV3,(long)question.answerId,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],@"1",@"1"];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =likeAnswerURL;
    wooRequestObj.time =0;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries = 0;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = likeOrDislikeAProfile;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        if (statusCode==200) {
            block(response);
        }
    } shouldReachServerThroughQueue:TRUE];
}


+(void)handleCrushResponseAndUpdateItLocally:(id)responseData{
    
    if (!responseData) {
        return;
    }
    
    if ([responseData objectForKey:@"time"]){
        [[NSUserDefaults standardUserDefaults] setObject:[responseData objectForKey:@"time"] forKey:kCrushDashboardTimestampKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    if ([responseData objectForKey:@"disableTargetIds"] && [(NSArray *)[responseData objectForKey:@"disableTargetIds"] count] >0) {
        
        [CrushesDashboard deleteCrushDataFromDBWithUserIDs:[responseData objectForKey:@"disableTargetIds"] withCompletionHandler:nil];
    }
    
    if ([responseData objectForKey:@"profiles"] && [(NSArray *)[responseData objectForKey:@"profiles"] count] >0) {

        [CrushesDashboard insertOrUpdateCrushWithData:[responseData objectForKey:@"profiles"] withCompletionHandler:^(BOOL isInsertionCompleted) {
            [self setIsfetchingCrushDataFromServerValue:false];
            [AppLaunchModel sharedInstance].isNewDataPresentInCrushSection = TRUE;
            [[WooScreenManager sharedInstance].oHomeViewController checkAndshowUnreadBadgeOnAboutMeIcon];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMeSection" object:nil];
        }];
    }
    else
    {
        isfetchingCrushDataFromServer = false;
        //[AppLaunchModel sharedInstance].isNewDataPresentInCrushSection = TRUE;
        [[WooScreenManager sharedInstance].oHomeViewController checkAndshowUnreadBadgeOnAboutMeIcon];
    }
    
}

//+(void)getTemplateCrushFromServer{
//    if ([APP_Utilities reachable]) {
//        NSString *getTemplateCrushFromSeverApi =[NSString stringWithFormat:@"%@%@?wooId=%@",kBaseURLV1,kGetTemplateCrush,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
//        WooRequest *wooRequestObj = [[WooRequest alloc]init];
//        wooRequestObj.url =getTemplateCrushFromSeverApi;
//        wooRequestObj.time =0;
//        wooRequestObj.requestParams =nil;
//        wooRequestObj.methodType =getRequest;
//        wooRequestObj.numberOfRetries =3;
//        wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
//        wooRequestObj.requestType = getTemplateCrush;
//        [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
//            if ((wooRequestObj.requestType == getTemplateCrush) && (statusCode == 200)) {
//                [CrushModel sharedInstance].templateQuestionArray = [NSArray arrayWithArray:response];
//            }
//        } shouldReachServerThroughQueue:TRUE];
//    }
//}

+(void)deleteMatchWithMatchID:(MyMatches *)matchObj withCommentForUnmatch:(NSString *)comment successBlock:(DeletionCompletionHandler)block{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] || [[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue] <= 0) {
        block(NO);
        return;
    }
    
    NSString *deletionURL = [NSString stringWithFormat:@"%@/%@/matches/%@",kBaseURLV1,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],matchObj.matchId];
    
    if(![comment isEqualToString:@""])
    {
        deletionURL = [deletionURL stringByAppendingString:[NSString stringWithFormat:@"?comments=%@",[comment stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]];
    }
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =deletionURL;
    wooRequestObj.time =900;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =deleteRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = deleteAMatch;
    //TODO
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        if (requestType == deleteAMatch) {
            if (success)
            {
                // Use your response NSDictionary object
                block(YES);
            }
            else
            {
                // Display you error NSError object
                block(NO);
            }
        }
    }  shouldReachServerThroughQueue:TRUE];
    
}

+(BOOL)getIsfetchingCrushDataFromServerValue{
    return isfetchingCrushDataFromServer;
}
+(void)setIsfetchingCrushDataFromServerValue:(BOOL)value{
     isfetchingCrushDataFromServer = value;
}


@end
