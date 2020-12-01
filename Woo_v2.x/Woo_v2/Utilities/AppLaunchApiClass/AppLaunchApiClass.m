//
//  AppLaunchApiClass.m
//  Woo_v2
//
//  Created by Akhil Singh on 27/04/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "AppLaunchApiClass.h"
#import "LoginModel.h"
#import "AppSessionManager.h"
#import "WooGlobeModel.h"

@implementation AppLaunchApiClass

+ (id)sharedManager {
    static AppLaunchApiClass *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[super allocWithZone:NULL] init];
    });
    [self initialiseSellingMessage];
    return sharedManager;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}
- (instancetype)init
{
    self = [super init];
    
    return self;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedManager];
}

+(void)initialiseSellingMessage{
    if ([[AppLaunchModel sharedInstance].boostText length] <  1) {
        [AppLaunchModel sharedInstance].boostText = NSLocalizedString(@"Boost your profile now to increase your visibility on Woo and see all your visitors.", @"Boost your profile text");
    }
    if ([[AppLaunchModel sharedInstance].profileCompletnessText length] <  1) {
        [AppLaunchModel sharedInstance].profileCompletnessText = NSLocalizedString(@"Our research tells us profiles with more details, gets more visibility. Complete your profile and tell them why you’re so awesome.", @"Complete your profile text.");
    }
    if ([[AppLaunchModel sharedInstance].activateBoostText length] <  1) {
        [AppLaunchModel sharedInstance].activateBoostText = NSLocalizedString(@"Boost your profile now to increase your visibility.", @"Boost your profile now to increase your visibility.");
    }
    if ([[AppLaunchModel sharedInstance].crushPurchaseText length] <  1) {
        [AppLaunchModel sharedInstance].crushPurchaseText = NSLocalizedString(@"Now you can send a personalised message to the profiles you really like even before getting matched. Sending a crush increases your chances of getting a match.", @"Now you can send a personalised message to the profiles you really like even before getting matched. Sending a crush increases your chances of getting a match.");
    }
    if ([[AppLaunchModel sharedInstance].discoverMoreProfileText length] <  1) {
        [AppLaunchModel sharedInstance].discoverMoreProfileText = NSLocalizedString(@"Get started by reviewing more profiles.", @"Get started by reviewing more profiles.");
    }
    if ([[AppLaunchModel sharedInstance].sendCrushText length] <  1) {
        [AppLaunchModel sharedInstance].sendCrushText = NSLocalizedString(@"Don’t miss out , make the the first move.", @"Don’t miss out , make the the first move.");
    }
    if ([[AppLaunchModel sharedInstance].subscriptionLikedMeText length] <  1) {
        [AppLaunchModel sharedInstance].subscriptionLikedMeText = @"Send a Crush to increase your chance of \n being liked back";
    }
    if ([[AppLaunchModel sharedInstance].subscriptionSkippedProfileText length] <  1) {
        [AppLaunchModel sharedInstance].subscriptionSkippedProfileText = NSLocalizedString(@"Swiped left and missed out on a person you want to meet?", @"Swiped left and missed out on a person you want to meet?");
    }
    if ([[AppLaunchModel sharedInstance].subscriptionVisitorText length] <  1) {
        [AppLaunchModel sharedInstance].subscriptionVisitorText = NSLocalizedString(@"See who came across your profile.", @"See who came across your profile.");
    }
    if ([[AppLaunchModel sharedInstance].boostVisitorText length] <  1) {
        [AppLaunchModel sharedInstance].boostVisitorText = NSLocalizedString(@"In the meantime....\n Get discovered by more people", @"In the meantime....\n Get discovered by more people");
    }
    if ([[AppLaunchModel sharedInstance].boostLikedMeText length] <  1) {
        [AppLaunchModel sharedInstance].boostLikedMeText = NSLocalizedString(@"In the meantime....\n Get discovered by more people", @"In the meantime....\n Get discovered by more people");
    }
    if ([[AppLaunchModel sharedInstance].boostCrushReceivedText length] <  1) {
        [AppLaunchModel sharedInstance].boostCrushReceivedText = NSLocalizedString(@"In the meantime....\n Get discovered by more people", @"In the meantime....\n Get discovered by more people");
    }
    if ([[AppLaunchModel sharedInstance].boostMatchboxText length] <  1) {
        [AppLaunchModel sharedInstance].boostMatchboxText = NSLocalizedString(@"Conversations start with Crushes, Likes and Answers. \nIn the meantime, you can get seen by more people to start conversations.", @"Conversations start with Crushes, Likes and Answers. In the meantime, you can get seen by more people to start conversations.");
    }
//    if ([[AppLaunchModel sharedInstance].subscriptionText length] <  1) {
//        [AppLaunchModel sharedInstance].subscriptionText = NSLocalizedString(@"Get access to all profiles who liked you , see all your visitors , unlimited likes everyday, access to your skipped profiles and much more. Become a WooPlus member now.", @"Subsciption text.");
//    }
}

/**
 *  AppSyncCall for getting app sync options like ProfileOptions,Tips and Crush templates
 *
 *  @param appConfigDict response of AppLaunch call
 *  @param block         to update the view when data arrives
 */
- (void)makeAppSyncCallForAppConfigOptions:(NSDictionary *)appConfigDict
{
    if (![APP_Utilities reachable]) {
        [[AppSessionManager sharedManager] makeAppLaunchCallToWhenConnectionResumes];
        return;
    }
    NSString *appSyncUrlString;
    NSString *appConfigType = @"";
    
    long long int serverTipsTime = [[appConfigDict objectForKey:kTipsUpdateTimestamp] longLongValue];
    
    long long int tipsUpdatedTime = [AppLaunchModel sharedInstance].tipsUpdatedTime;
    
    if ((serverTipsTime > tipsUpdatedTime) && (tipsUpdatedTime > 0)) {
        appConfigType = AppConfigTypeTips;
    }
    
    long long int serverProfileOptionsTime = [[appConfigDict objectForKey:kProfileOptionUpdateTimestamp] longLongValue];
    
    long long int profileOptionsUpdatedTime = [AppLaunchModel sharedInstance].profileOptionsUpdatedTime;
    
    if ((serverProfileOptionsTime > profileOptionsUpdatedTime) && (profileOptionsUpdatedTime > 0)) {
        if ([appConfigType length]>0) {
            appConfigType = [NSString stringWithFormat:@"%@,%@",appConfigType,AppConfigTypeProfileOptions];
        }
        else{
            appConfigType = AppConfigTypeProfileOptions;
        }
    }
    
//    long long int serverCountryDtoTime = [[appConfigDict objectForKey:kCountryDtoLastUpdatedTimestamp] longLongValue];
//    
//    long long int countryDtoUpdatedTime = [AppLaunchModel sharedInstance].countryDtoLastUpdatedTime;
//    
//    if ((serverCountryDtoTime > countryDtoUpdatedTime) && (countryDtoUpdatedTime > 0)) {
//        if ([appConfigType length]>0) {
//            appConfigType = [NSString stringWithFormat:@"%@,%@",appConfigType,APPConfigCountryDto];
//        }
//        else{
//            appConfigType = APPConfigCountryDto;
//        }
//    }

    
    long long int serverCrushesTemplateTime =[[appConfigDict objectForKey:@"crushMessagesUpdatedTime"] longLongValue];
    
    long long int crushesTemplateUpdatedTime = [CrushModel sharedInstance].crushMessagesUpdatedTime;
    
    if ((serverCrushesTemplateTime > crushesTemplateUpdatedTime) && (crushesTemplateUpdatedTime > 0)) {
        if ([appConfigType length]>0) {
            appConfigType = [NSString stringWithFormat:@"%@,%@",appConfigType,AppConfigTypeCrushTemplates];
        }
        else{
            appConfigType = AppConfigTypeCrushTemplates;
        }
    }
    
//    kSellingMessageUpdateTime, sellingMessageUpdatedTime
    
    long long int serverSellingMessageTime =[[appConfigDict objectForKey:@"sellingUpdatedTime"] longLongValue];
    
    long long int sellingMessageUpdatedTime = [AppLaunchModel sharedInstance].sellingMessageUpdatedTime;
    
    if ((serverSellingMessageTime > sellingMessageUpdatedTime) && (sellingMessageUpdatedTime > 0)) {
        if ([appConfigType length]>0) {
            appConfigType = [NSString stringWithFormat:@"%@,%@",appConfigType,APPConfigTypeSelling];
        }
        else{
            appConfigType = APPConfigTypeSelling;
        }
    }
    
    long long int serverProfileWidgetsTime =[[appConfigDict objectForKey:@"profileWidgetsLastUpdatedTime"] longLongValue];
    
    long long int profileWidgetsUpdatedTime = [AppLaunchModel sharedInstance].profileWidgetsUpdatedTime;
    
    if (serverProfileWidgetsTime > profileWidgetsUpdatedTime && (profileWidgetsUpdatedTime > 0)) {
        if ([appConfigType length]>0) {
            appConfigType = [NSString stringWithFormat:@"%@,%@",appConfigType,AppConfigTypeProfileWidgets];
        }
        else{
            appConfigType = AppConfigTypeProfileWidgets;
        }
    }
    
    if ([appConfigType length]>0) {
        appSyncUrlString = [NSString stringWithFormat:@"%@%@?wooId=%@&syncType=%@",kBaseURLV8,kAppConfigSyncCall,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],appConfigType];
    }
    else{
        //& countryDtoUpdatedTime == 0
        if (tipsUpdatedTime == 0 || profileOptionsUpdatedTime  == 0 || crushesTemplateUpdatedTime == 0 || sellingMessageUpdatedTime == 0 || profileWidgetsUpdatedTime == 0) {
            appSyncUrlString = [NSString stringWithFormat:@"%@%@?wooId=%@",kBaseURLV8,kAppConfigSyncCall,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
        }
        else{
            return;
        }
    }
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =appSyncUrlString;
    wooRequestObj.time =0;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =getRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = getAppConfigFromServer;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        if (requestType == getAppConfigFromServer) {
            
            if (success){
                [[AppSessionManager sharedManager] removeObserverForInternetChange];
                
                if ([response objectForKey:@"analyzeProfileDto"]){
                    [AppLaunchModel sharedInstance].analyzeProfileDto = [response objectForKey:@"analyzeProfileDto"];
                }
                
                if ([response objectForKey:@"profileWidgets"]){
                    [AppLaunchModel sharedInstance].profileWidgetsArray = [response objectForKey:@"profileWidgets"];
                }
                
                if ([response objectForKey:@"profileCompletenessScoreThreshold"]){
                    [AppLaunchModel sharedInstance].profileCompletenessScoreThreshold = [[response objectForKey:@"profileCompletenessScoreThreshold"] integerValue];
                }
                
                if ([response objectForKey:@"profileCompletenessFallbackThreshold"]){
                    [AppLaunchModel sharedInstance].profileCompletenessFallbackThreshold = [[response objectForKey:@"profileCompletenessFallbackThreshold"] integerValue];
                }
                
                if ([response objectForKey:@"profileWidgetsLastUpdatedTime"]){
                    [AppLaunchModel sharedInstance].profileWidgetsUpdatedTime = [[response objectForKey:@"profileWidgetsLastUpdatedTime"] longLongValue];
                }
                
                if ([response objectForKey:@"wooCreditsScreenText"]){
                    [AppLaunchModel sharedInstance].wooCreditsScreenText = [response objectForKey:@"wooCreditsScreenText"];
                }
                
                if ([response objectForKey:@"tipsDto"]) {
                    [AppLaunchModel sharedInstance].tipsUpdatedTime = [[response objectForKey:kTipsUpdateTimestamp] longLongValue];
                }
                
                // Handling MyPurchaseTemplate
                if ([response objectForKey:@"myPurchaseTemplates"]) {
                    [[MyPurchaseTemplate sharedInstance] updateDataWithMyPurchaseTemplate:[response objectForKey:@"myPurchaseTemplates"]];
                }
                
                if ([response objectForKey:@"countryDto"]) {
                    [[AppLaunchModel sharedInstance] setCountryDtoLastUpdatedTime:[[response objectForKey:kCountryDtoLastUpdatedTimestamp] longLongValue]];
                    [[AppLaunchModel sharedInstance] updateCountryDtoArrayWithData:[response objectForKey:@"countryDto"]];
                }
                
                
                if ([response objectForKey:@"profileOptionsDto"]) {
                    [AppLaunchModel sharedInstance].profileOptionsUpdatedTime = [[response objectForKey:kProfileOptionUpdateTimestamp] longLongValue];
                    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
                    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",timestamp] forKey:kProfileUpdatedOn];
                    
                    NSMutableDictionary *profileData = [response mutableCopy];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:[profileData objectForKey:@"profileOptionsDto"] forKey:kUserProfileDataKey];
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFirstTimeProfileOptionsFetched];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
                if ([response objectForKey:@"crushTemplates"]) {
                    if ([response objectForKey:@"crushMessagesUpdatedTime"]) {
                        [CrushModel sharedInstance].crushMessagesUpdatedTime =[[response objectForKey:@"crushMessagesUpdatedTime"] longLongValue];
                    }
                    [CrushModel sharedInstance].templateQuestionArray = [NSArray arrayWithArray:[response objectForKey:@"crushTemplates"]];
                }
                
                if ([response objectForKey:@"leftPanelSuggestions"] &&
                    [[response objectForKey:@"leftPanelSuggestions"] objectForKey:@"leftPanelDataDto"]) {
                    [AppLaunchModel sharedInstance].leftPanelSuggestions = [[[response objectForKey:@"leftPanelSuggestions"] objectForKey:@"leftPanelDataDto"] mutableCopy];
                }
                
                if ([response objectForKey:@"leftPanelAdsText"]) {
                    [AppLaunchModel sharedInstance].leftPanelAdsText = [response objectForKey:@"leftPanelAdsText"];
                }
//                sellingUpdatedTime
                
                if ([response objectForKey:@"sellingScreenDto"]) {
                    
                    //add selling msgs
                    if ([[response objectForKey:@"sellingScreenDto"] objectForKey:@"boostText"] && [[[response objectForKey:@"sellingScreenDto"] objectForKey:@"boostText"] length] > 0) {
                    
                        [AppLaunchModel sharedInstance].boostText = [[response objectForKey:@"sellingScreenDto"] objectForKey:@"boostText"]; //new done

                    }
                    
                    if ([[response objectForKey:@"sellingScreenDto"] objectForKey:@"profileCompletnessText"] && [[[response objectForKey:@"sellingScreenDto"] objectForKey:@"profileCompletnessText"] length] > 0) {
                        
                        [AppLaunchModel sharedInstance].profileCompletnessText = [[response objectForKey:@"sellingScreenDto"] objectForKey:@"profileCompletnessText"]; //new done
                    }
                   
                    
//                    if ([[response objectForKey:@"sellingScreenDto"] objectForKey:@"subscriptionText"] && [[[response objectForKey:@"sellingScreenDto"] objectForKey:@"subscriptionText"] length] > 0) {
//                        
//                        [AppLaunchModel sharedInstance].subscriptionText = [[response objectForKey:@"sellingScreenDto"] objectForKey:@"subscriptionText"];
//                    }
                    if ([[response objectForKey:@"sellingScreenDto"] objectForKey:@"subsLikedMeText"] && [[[response objectForKey:@"sellingScreenDto"] objectForKey:@"subsLikedMeText"] length] > 0) {
                        
                        [AppLaunchModel sharedInstance].subscriptionLikedMeText = [[response objectForKey:@"sellingScreenDto"] objectForKey:@"subsLikedMeText"];// new done
                    }
                    
                    if ([[response objectForKey:@"sellingScreenDto"] objectForKey:@"subsSkippedText"] && [[[response objectForKey:@"sellingScreenDto"] objectForKey:@"subsSkippedText"] length] > 0) {
                        
                        [AppLaunchModel sharedInstance].subscriptionSkippedProfileText = [[response objectForKey:@"sellingScreenDto"] objectForKey:@"subsSkippedText"];// new done
                    }
                    
                    if ([[response objectForKey:@"sellingScreenDto"] objectForKey:@"subsVisitorsText"] && [[[response objectForKey:@"sellingScreenDto"] objectForKey:@"subsVisitorsText"] length] > 0) {
                        
                        [AppLaunchModel sharedInstance].subscriptionVisitorText = [[response objectForKey:@"sellingScreenDto"] objectForKey:@"subsVisitorsText"]; //new done
                    }
                    
                    if ([[response objectForKey:@"sellingScreenDto"] objectForKey:@"activateBoost"] && [[[response objectForKey:@"sellingScreenDto"] objectForKey:@"activateBoost"] length] > 0) {
                        
                        [AppLaunchModel sharedInstance].activateBoostText = [[response objectForKey:@"sellingScreenDto"] objectForKey:@"activateBoost"]; // new done
                        
                    }
                    
                    if ([[response objectForKey:@"sellingScreenDto"] objectForKey:@"crushPurchaseText"] && [[[response objectForKey:@"sellingScreenDto"] objectForKey:@"crushPurchaseText"] length] > 0) {
                        
                        [AppLaunchModel sharedInstance].crushPurchaseText = [[response objectForKey:@"sellingScreenDto"] objectForKey:@"crushPurchaseText"]; // new done
                        
                    }
                    
                    if ([[response objectForKey:@"sellingScreenDto"] objectForKey:@"discoverSkippedText"] && [[[response objectForKey:@"sellingScreenDto"] objectForKey:@"discoverSkippedText"] length] > 0) {
                        
                        [AppLaunchModel sharedInstance].discoverMoreProfileText = [[response objectForKey:@"sellingScreenDto"] objectForKey:@"discoverSkippedText"]; // new Done
                        
                    }
                    
                    if ([[response objectForKey:@"sellingScreenDto"] objectForKey:@"sendCrushText"] && [[[response objectForKey:@"sellingScreenDto"] objectForKey:@"sendCrushText"] length] > 0) {
                        
                        [AppLaunchModel sharedInstance].sendCrushText = [[response objectForKey:@"sellingScreenDto"] objectForKey:@"sendCrushText"];    // new done
                        
                    }
                    
                    if ([[response objectForKey:@"sellingScreenDto"] objectForKey:@"boostVisitorsText"] && [[[response objectForKey:@"sellingScreenDto"] objectForKey:@"boostVisitorsText"] length] > 0) {
                        
                        [AppLaunchModel sharedInstance].boostVisitorText = [[response objectForKey:@"sellingScreenDto"] objectForKey:@"boostVisitorsText"];    // new done
                        
                    }
                    if ([[response objectForKey:@"sellingScreenDto"] objectForKey:@"boostLikedMeText"] && [[[response objectForKey:@"sellingScreenDto"] objectForKey:@"boostLikedMeText"] length] > 0) {
                        
                        [AppLaunchModel sharedInstance].boostLikedMeText = [[response objectForKey:@"sellingScreenDto"] objectForKey:@"boostLikedMeText"];    // new done
                        
                    }
                    if ([[response objectForKey:@"sellingScreenDto"] objectForKey:@"boostCrushReceivedText"] && [[[response objectForKey:@"sellingScreenDto"] objectForKey:@"boostCrushReceivedText"] length] > 0) {
                        
                        [AppLaunchModel sharedInstance].boostCrushReceivedText = [[response objectForKey:@"sellingScreenDto"] objectForKey:@"boostCrushReceivedText"];    // new done
                        
                    }
                    if ([[response objectForKey:@"sellingScreenDto"] objectForKey:@"boostMatchboxText"] && [[[response objectForKey:@"sellingScreenDto"] objectForKey:@"boostMatchboxText"] length] > 0) {
                        
                        [AppLaunchModel sharedInstance].boostMatchboxText = [[response objectForKey:@"sellingScreenDto"] objectForKey:@"boostMatchboxText"];    // new done
                        
                    }
                    
                    
                }
                
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"freeTrailPopUP" object:nil];
                
            }
            else{
                [[AppSessionManager sharedManager] makeAppLaunchCallToWhenConnectionResumes];
            }
        }
        
    }  shouldReachServerThroughQueue:TRUE];
    
    if ([appConfigDict objectForKey:@"sellingUpdatedTime"]) {
        [AppLaunchModel sharedInstance].sellingMessageUpdatedTime =[[appConfigDict objectForKey:@"sellingUpdatedTime"] longLongValue];
    }
    
}

/**
 *  AppSyncCall for getting app sync options like ProfileOptions,Tips and Crush templates
 */
- (void)makeAppSyncCallForSidePanelTips
{
    NSString *appSyncUrlString = [NSString stringWithFormat:@"%@%@?wooId=%@&syncType=LEFT_PANEL_TOP",kBaseURLV5,
                                                                kAppConfigSyncCall,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =appSyncUrlString;
    wooRequestObj.time =0;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =getRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = getAppConfigFromServer;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        if (requestType == getAppConfigFromServer) {
            
            if (success){
                if ([response objectForKey:@"leftPanelSuggestions"] &&
                    [[response objectForKey:@"leftPanelSuggestions"] objectForKey:@"leftPanelDataDto"]) {
                    [AppLaunchModel sharedInstance].leftPanelSuggestions = [[[response objectForKey:@"leftPanelSuggestions"] objectForKey:@"leftPanelDataDto"] mutableCopy];
                }
                
                if ([response objectForKey:@"leftPanelAdsText"]) {
                    [AppLaunchModel sharedInstance].leftPanelAdsText = [response objectForKey:@"leftPanelAdsText"];
                }
                
            }
        }
        
    }  shouldReachServerThroughQueue:TRUE];
}

- (void)getNotificationConfigOptionsWithCompletionBlock:(getNotificationConfigurationAPICompletionBlock) block
{
    NSString *appSyncUrlString = [NSString stringWithFormat:@"%@%@?wooId=%@",kBaseURLV3,kNotificationPreferences,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];

    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =appSyncUrlString;
    wooRequestObj.time =0;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =getRequest;
    wooRequestObj.numberOfRetries = 0;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = getNotificationPreferences;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        if (requestType == getNotificationPreferences) {
            
            if (success){
                
                if ([response objectForKey:@"diasporaDto"]) {
                    [[WooGlobeModel sharedInstance] updateDataWithWooGlobeDictionary:[response objectForKey:@"diasporaDto"]];
                }
                [DiscoverProfileCollection sharedInstance].intentModelObject.maxAge = [NSNumber numberWithInteger:[[response objectForKey:@"maxAge"] integerValue]];
                [DiscoverProfileCollection sharedInstance].intentModelObject.showLocation = [NSNumber numberWithBool:[[response objectForKey:@"showLocation"] boolValue]];
                [DiscoverProfileCollection sharedInstance].intentModelObject.minAge = [NSNumber numberWithInteger:[[response objectForKey:@"minAge"] integerValue]];
                int maxDistanceInMiles = [[response objectForKey:@"maxDistance"] intValue];
                int maxDistance = 0;
                    if (maxDistanceInMiles == 16) {
                        maxDistance = 10;
                    }
                    else if (maxDistanceInMiles == 32){
                        maxDistance = 20;
                    }
                    else if (maxDistanceInMiles == 80){
                        maxDistance = 50;
                    }
                    else if (maxDistanceInMiles == 160){
                        maxDistance = 100;
                    }
                    else{
                        maxDistance = maxDistanceInMiles;
                    }

                [DiscoverProfileCollection sharedInstance].intentModelObject.maxDistance = [NSNumber numberWithInt:maxDistance];
                [DiscoverProfileCollection sharedInstance].intentModelObject.interestedGender = [response objectForKey:@"interestedGender"];
                [DiscoverProfileCollection sharedInstance].intentModelObject.isKms = [NSNumber numberWithBool:[[response objectForKey:@"kms"] boolValue]];
                [DiscoverProfileCollection sharedInstance].intentModelObject.maxAllowedAge = [NSNumber numberWithInteger:[[response objectForKey:@"maxAllowedWoo"] integerValue]];
                [DiscoverProfileCollection sharedInstance].intentModelObject.minAllowedAge =[NSNumber numberWithInteger:[[response objectForKey:@"minAllowedWoo"] integerValue]];
                [DiscoverProfileCollection sharedInstance].intentModelObject.intentAgeDifferenceThreshold = [NSNumber numberWithInteger:[[response objectForKey:@"ageDifferenceThreshold"] integerValue]];
                
                if([response objectForKey:@"goGlobalOn"]){
                    [DiscoverProfileCollection sharedInstance].intentModelObject.showGoGlobal = [NSNumber numberWithBool:[[response objectForKey:@"goGlobalOn"] boolValue]];
                }
                
                if([response objectForKey:@"showGoGlobalButton"]){
                    [DiscoverProfileCollection sharedInstance].intentModelObject.showGoGlobalButton = [NSNumber numberWithBool:[[response objectForKey:@"showGoGlobalButton"] boolValue]];
                }
                
                if ([response objectForKey:kFavIntent]) {
                    [DiscoverProfileCollection sharedInstance].intentModelObject.favIntent = [response objectForKey:kFavIntent];
                }
                else{
                    NSString *favIntentText = @"";
                    if ([LoginModel sharedInstance].favIntent == INTENT_TYPE_NONE) {
                        favIntentText = @"NONE";
                    }
                    else if ([LoginModel sharedInstance].favIntent == INTENT_TYPE_FRIEND){
                        favIntentText = @"FRIEND";
                    }
                    else if ([LoginModel sharedInstance].favIntent == INTENT_TYPE_CASUAL){
                        favIntentText = @"CASUAL";
                    }
                    else if ([LoginModel sharedInstance].favIntent == INTENT_TYPE_LOVE_OF_MY_LIFE){
                        favIntentText = @"LOVE";
                    }
                    
                    [DiscoverProfileCollection sharedInstance].intentModelObject.favIntent = favIntentText;
                }
                
                NSLog(@"[DiscoverProfileCollection sharedInstance].intentModelObject :%@",[DiscoverProfileCollection sharedInstance].intentModelObject);
                NSLog(@"[DiscoverProfileCollection sharedInstance].intentModelObject.modelHasBeenUpdatedByServer :%@",[DiscoverProfileCollection sharedInstance].intentModelObject.modelHasBeenUpdatedByServer);
                if (([DiscoverProfileCollection sharedInstance].intentModelObject == nil ) ||  ([DiscoverProfileCollection sharedInstance].intentModelObject.modelHasBeenUpdatedByServer == nil) || [DiscoverProfileCollection sharedInstance].intentModelObject.modelHasBeenUpdatedByServer.boolValue == false) {
                    [DiscoverProfileCollection sharedInstance].intentModelObject.modelHasBeenUpdatedByServer = [NSNumber numberWithBool:true];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kAppSettingsHasBeenFetchedFromServer object:nil];
                }
                [[DiscoverProfileCollection sharedInstance] appTerminationHandler];
                
                [AppLaunchModel sharedInstance].matchNotification = [[response objectForKey:@"chatNotification"] boolValue];
                [AppLaunchModel sharedInstance].crushNotification = [[response objectForKey:@"crushNotification"] boolValue];
                [AppLaunchModel sharedInstance].questionNotification = [[response objectForKey:@"qaNotification"] boolValue];
                [AppLaunchModel sharedInstance].soundNotification = [[response objectForKey:@"alertSound"] boolValue];
            }
        }
        
        if (block != nil){
            block(true);
        }
        
    }  shouldReachServerThroughQueue:TRUE];
    
}

- (void)getWooQuestions:(long long int) wooQuestionUpdatedTime
{
    if (![APP_Utilities reachable]) {
        [[AppSessionManager sharedManager] makeAppLaunchCallToWhenConnectionResumes];
        return;
    }
    
    NSString *wooQuestionsUrlString = [NSString stringWithFormat:@"%@%@?wooId=%@&updatedTime=%lld",kBaseURLV1,kGetWooQuestions,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],wooQuestionUpdatedTime];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =wooQuestionsUrlString;
    wooRequestObj.time =0;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =getRequest;
    wooRequestObj.numberOfRetries = 0;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = getWooQuestions;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        if (requestType == getWooQuestions) {
            
            if (success){
                [[AppLaunchModel sharedInstance] updateTemplateQuestionsArrayFromData:[response objectForKey:@"wooQuestionDto"]];
            }
        }
        
    }  shouldReachServerThroughQueue:TRUE];
    
}

- (void)updateNotificationConfigOptions
{
    NSString *appSyncUrlString = [NSString stringWithFormat:@"%@%@?wooId=%@&matchNotification=%@&crushNotification=%@&questionNotification=%@&soundAlerts=%@",kBaseURLV2,kUpdateNotificationPreferences,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],[NSString stringWithFormat:@"%@",[AppLaunchModel sharedInstance].matchNotification?@"TRUE":@"FALSE"],[NSString stringWithFormat:@"%@",[AppLaunchModel sharedInstance].crushNotification?@"TRUE":@"FALSE"],[NSString stringWithFormat:@"%@",[AppLaunchModel sharedInstance].questionNotification?@"TRUE":@"FALSE"],[NSString stringWithFormat:@"%@",[AppLaunchModel sharedInstance].soundNotification?@"TRUE":@"FALSE"]];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =appSyncUrlString;
    wooRequestObj.time =0;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = updateNotificationPreferences;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
    }  shouldReachServerThroughQueue:TRUE];
    
}



@end
