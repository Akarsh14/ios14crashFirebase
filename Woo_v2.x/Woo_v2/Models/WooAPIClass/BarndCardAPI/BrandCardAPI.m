//
//  BrandCardAPI.m
//  Woo_v2
//
//  Created by Suparno Bose on 30/06/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "BrandCardAPI.h"
#import "ProfileAPIClass.h"
@implementation BrandCardAPI

+ (void) updateBrandCardPassStatusOnServer : (NSString *)clickPass And: (NSString *) cardId{
    
    /*
     http://api-testing-1816224593.ap-southeast-1.elb.amazonaws.com/woo/api/v1/brandCard/?wooId=3421456&cardId=1&eventType=CLICK/PASS
     
     */
    NSString *updateBrandCardPassStatusURL = [NSString stringWithFormat:@"%@%@?wooId=%@&cardId=%@&eventType=%@",kBaseURLV1,kBrandCardSeenAPI,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],cardId,clickPass];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =updateBrandCardPassStatusURL;
    wooRequestObj.time =0;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = brandCardPass;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        if (success) {
            
            NSLog(@"EITHER BRAND CARD OR INVITE FRIEND HAS BEEN SEEN");
            
        }
        
    } shouldReachServerThroughQueue:TRUE];
}

+ (void) updateSelectionCardPassStatusOnServer : (NSString *)subCardType And: (NSString *) cardId AndSelectedValues : (NSArray*) selectedValues{
    
    NSString *updateSelectionCardURL = [NSString stringWithFormat:@"%@%@?wooId=%@&cardId=%@&subCardType=%@",kBaseURLV1,kSelectionCardSeenAPI,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],cardId,subCardType];
    
    for (ProfessionModel *items in selectedValues) {
        updateSelectionCardURL = [NSString stringWithFormat:@"%@&selectedValues=%@",updateSelectionCardURL,items.tagId];
    }
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =updateSelectionCardURL;
    wooRequestObj.time =0;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = brandCardPass;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        if (success) {
            
            //Woo user id of a user.
            NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId];
            
            [ProfileAPIClass fetchDataForUserWithUserID:userID.longLongValue withCompletionBlock:nil];
        }
        
    } shouldReachServerThroughQueue:TRUE];
}

+ (void) updateSelectionCardPassStatusOnServer : (NSString *)subCardType And: (NSString *) cardId AndSelectedValues : (NSArray*) selectedValues withCompletionHandler:(void(^)(BOOL success, NSArray *ethnicityResponse))block{
    
    NSString *updateSelectionCardURL = [NSString stringWithFormat:@"%@%@?wooId=%@&cardId=%@&subCardType=%@",kBaseURLV1,kSelectionCardSeenAPI,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],cardId,subCardType];
    
    for (ProfessionModel *items in selectedValues) {
        updateSelectionCardURL = [NSString stringWithFormat:@"%@&selectedValues=%@",updateSelectionCardURL,items.tagId];
    }
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =updateSelectionCardURL;
    wooRequestObj.time =0;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = brandCardPass;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        if (success) {
            
            //Woo user id of a user.
            NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId];
            
            [ProfileAPIClass fetchDataForUserWithUserID:userID.longLongValue withCompletionBlock:nil];
            block(TRUE,[response objectForKey:@"ethnicities"]);
            
            [AppLaunchModel sharedInstance].leftPanelSuggestions = [[[response objectForKey:@"leftPanelSuggestions"] objectForKey:@"leftPanelDataDto"] mutableCopy];
        }
        
    } shouldReachServerThroughQueue:TRUE];
}

@end
