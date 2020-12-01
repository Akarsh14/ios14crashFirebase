//
//  ProfileAPIClass.m
//  Woo_v2
//
//  Created by Suparno Bose on 04/02/16.
//  Copyright © 2016 Woo. All rights reserved.
//

#import "ProfileAPIClass.h"
#import "Woo_v2-Swift.h"
#import "ApplozicChatManager.h"


@implementation ProfileAPIClass

+(void)updateMyProfileDataForUserWithPayload:(NSString*)payloadString AndProfilePicID:(NSString*)profilePicID AndCompletionBlock:(FetchUserDataCompletionBlock)block{
    
    NSString *urlString = nil;
    
    if (profilePicID != nil) {
        urlString = [NSString stringWithFormat:@"%@%@?wooUserId=%llu&profilePicId=%@",kBaseURLV15,kUpdateUserProile,[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue],profilePicID];
    }
    else{
        urlString = [NSString stringWithFormat:@"%@%@?wooUserId=%llu",kBaseURLV15,kUpdateUserProile,[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue]];
    }
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =urlString;
    wooRequestObj.time =0;
    wooRequestObj.requestParams =
        [NSDictionary dictionaryWithObject:payloadString
                                                             forKey:@"payload"];
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = updateUserProfileData;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        if (requestType == updateUserProfileData) {
            if (block)
                if ([response objectForKey:@"displayName"] != nil){
                [[LoginModel sharedInstance] setFirstName:[response objectForKey:@"displayName"]];
                    [[ApplozicChatManager sharedApplozicChatManager] updateUserName];
                }
            
            if(![[NSUserDefaults standardUserDefaults] boolForKey:@"validFemaleEventSent"] && ([[NSUserDefaults standardUserDefaults] boolForKey:@"isVisible"])){
                
                [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"validFemaleEventSent"];
                [APP_DELEGATE sendFirebaseEvent:@"VALID_FEMALE" andScreen:@""];
                [APP_DELEGATE sendFirebaseEvent:@"ACTUAL_VALID_FEMALE" andScreen:@""];
                [APP_DELEGATE logEventOnFacebook:@"Achievements Unlocked"];
                [APP_DELEGATE logEventOnFacebook:@"Contact"];
                [BoostProductsAPICalss makePopupEventAPIwithType:@"FIREBASE_EVENT_FOR_FEMALE_VISIBLE"];
            }

                block(response , success, statusCode);
            }
    } shouldReachServerThroughQueue:TRUE];
}

+(void)fetchDataForUserWithUserID:(long long int)targetID withCompletionBlock:(FetchUserDataCompletionBlock)block{
    NSString *profileDataString = [NSString stringWithFormat:@"%@%@?wooUserId=%lld&targetId=%lld",kBaseURLV15,kGetUserProfile,[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue],targetID];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =profileDataString;
    wooRequestObj.time =0;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =getRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.requestType = getUserProfileData;
//    
//    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue] == targetID){
//        wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
//    }
//    else{
//        wooRequestObj.cachePolicy=GET_DATA_FROM_URL_IF_FAIL_GET_DATA_FROM_CACHE;
//    }
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;

    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        if (requestType != getUserProfileData) {
            return;
        }
        NSLog(@"response=%@",response);
        
        if (success) {
            if (targetID == [[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue]){
                [[DiscoverProfileCollection sharedInstance] updateMyProfileData: response];
                
                [[LoginModel sharedInstance] setFirstName:[DiscoverProfileCollection sharedInstance].myProfileData.displayName];
                
                if ([response objectForKey:kuserRelationshipTagsAvailable])
                    [LoginModel sharedInstance].userRelationshipTagsAvailable = [[response objectForKey:kuserRelationshipTagsAvailable] boolValue];
                
                if ([response objectForKey:kuserZodiacTagsAvailable])
                    [LoginModel sharedInstance].userZodiacTagsAvailable = [[response objectForKey:kuserZodiacTagsAvailable] boolValue];
                
                if ([response objectForKey:kuserLifestyleTagsAvailable])
                    [LoginModel sharedInstance].userLifestyleTagsAvailable = [[response objectForKey:kuserLifestyleTagsAvailable] boolValue];
                
                if([response objectForKey:@"isVisible"]){
                    [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"isVisible"];
                }else{
                    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"isVisible"];
                }
                
                
                [[NSUserDefaults standardUserDefaults] setObject:[APP_Utilities validString:[NSString stringWithFormat:@"%@",[response objectForKey:@"displayName"]]] forKey:kWooUserName];
                
                
                if(![[NSUserDefaults standardUserDefaults] boolForKey:@"validFemaleEventSent"] && ([response objectForKey:@"isVisible"] != nil)){
                    
                    [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"validFemaleEventSent"];
                    [APP_DELEGATE sendFirebaseEvent:@"VALID_FEMALE" andScreen:@""];
                    [APP_DELEGATE sendFirebaseEvent:@"ACTUAL_VALID_FEMALE" andScreen:@""];
                    [APP_DELEGATE logEventOnFacebook:@"Achievements Unlocked"];
                    [APP_DELEGATE logEventOnFacebook:@"Contact"];
                    [BoostProductsAPICalss makePopupEventAPIwithType:@"FIREBASE_EVENT_FOR_FEMALE_VISIBLE"];
                }
                
                [[NSUserDefaults standardUserDefaults] synchronize];

                [[DiscoverProfileCollection sharedInstance] myProfileData].wooId = [NSString stringWithFormat:@"%lld",targetID];
                if (([[NSUserDefaults standardUserDefaults] boolForKey:@"isOnboardingMyProfileShown"] == false) && [[LoginModel sharedInstance] showMyProfileScreen]) {
                    [[DiscoverProfileCollection sharedInstance] switchCollectionMode:1];
                }
            }
        }
        else{
            if (statusCode == 401) {
                [[Utilities sharedUtility] deleteAccount_Temp:nil];
                [[WooScreenManager sharedInstance] loadLoginView];
            }
        }

        if (block)
            block(response , success, statusCode);
        
    } shouldReachServerThroughQueue:TRUE];
}


+(void)prepareDataForScreenWithResponse:(NSMutableDictionary *)response WithUserID:(long long int)targetID{
    
    if ([response objectForKey:kWooAlbumKey] && [(NSArray *)[response objectForKey:kWooAlbumKey] count] > 0)
    {
        if ([(NSArray *)[response objectForKey:kWooAlbumKey] count] >2) {
            [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kHideAddMorePicCard];
        }
        else{
            [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:kHideAddMorePicCard];
        }
    }
    else{
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:kHideAddMorePicCard];
    }
    
    if ([[[response objectForKey:kVoiceIntro] objectForKey:kVoiceIntroUrl] length] > 0 ) {
        
        NSDictionary *voiceIntroDictionary = [response objectForKey:kVoiceIntro];
        
        if ([voiceIntroDictionary objectForKey:@"voiceIntroUrl"]) {
            
            NSString *path = [APP_DELEGATE getAudioPathForFileName:[[[voiceIntroDictionary objectForKey:@"voiceIntroUrl"] componentsSeparatedByString:@"/"] lastObject]];
            
            if (![APP_Utilities checkIfFileExistsAtPath:path]) {
                
                NSString *audioFileName = [NSString stringWithFormat:@"%@",[[[voiceIntroDictionary objectForKey:@"voiceIntroUrl"] componentsSeparatedByString:@"/"] lastObject]];
                ;
                if (![APP_Utilities checkIfFileExistsAtPath:[APP_Utilities getAudioPathForFileName:audioFileName]]) {
                    [[APIQueue sharedAPIQueue] downloadFileFromURL:[voiceIntroDictionary objectForKey:@"voiceIntroUrl"] forClass:self];
                }
            }
        }
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kVoiceIntroAvailableKey];
    }
    else{
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:kVoiceIntroAvailableKey];
        
    }
    //        Adding profile comppleteness details
    
    [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:kProfileCompletenessScoreKey]
                                              forKey:kProfileCompletenessScoreKey];
    //Adding powerUp Data
    if (targetID == [[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue]) {
        
        if ([BoostModel sharedInstance].availableInRegion == YES && [CrushModel sharedInstance].availableInRegion == YES) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:kHasPurchasedCrushCurrently] == YES) {
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kHasPurchasedCrushCurrently];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        else if ([BoostModel sharedInstance].availableInRegion == YES && [CrushModel sharedInstance].availableInRegion == NO){
            if ([[NSUserDefaults standardUserDefaults]boolForKey:kHasPurchasedCrushCurrently] == YES) {
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kHasPurchasedCrushCurrently];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    }

    //        adding user Lifestyle data
    if ([[[response objectForKey:kUserLifestyleKey] allKeys] count] > 0) {
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kAboutMeTagKey];
    }
    //        adding user Passion data
    if ([[[response objectForKey:kUserPassiionsKey] allKeys] count] > 0) {
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kAboutMeTagKey];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
