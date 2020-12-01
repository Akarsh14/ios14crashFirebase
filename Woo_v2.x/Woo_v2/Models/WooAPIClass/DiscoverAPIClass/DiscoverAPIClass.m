//
//  DiscoverAPIClass.m
//  Woo_v2
//
//  Created by Suparno Bose on 26/05/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "DiscoverAPIClass.h"
#import "Woo_v2-Swift.h"
#import "AppSessionManager.h"
#import "WooGlobeModel.h"


@implementation DiscoverAPIClass

+(void)fetchDiscoverDataFromServer:(BOOL)paginationEnabled
                     AndPrefrence: (BOOL)isExtended
                     isTagSelected:(BOOL)tagSelected
                    AndCompletionBlock:(DiscoverAPICompletionBlock) block{
    
    if (paginationEnabled && ![[DiscoverProfileCollection sharedInstance] isPaginationAllowed]) {
        return;
    }
    
    NSString *latitude,*longitude ;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserLastLocationKey]) {
        latitude = [NSString stringWithFormat:@"%f",[[[[NSUserDefaults standardUserDefaults] objectForKey:kUserLastLocationKey] objectForKey:kLastLocationLatitudeKey] floatValue]];//latitude
        longitude = [NSString stringWithFormat:@"%f",[[[[NSUserDefaults standardUserDefaults] objectForKey:kUserLastLocationKey] objectForKey:kLastLocationLongitudeKey] floatValue]];//longitude
    }
    else{
        latitude = @"28.628278";
        longitude = @"77.206065";
    }
    //Woo user id of a user.
    
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId];
    
    //user's Time zone
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    
    //getting the difference between user time zone and GMT
    NSString *gmtTime = [NSString stringWithFormat:@"%ld",(long)[timeZone secondsFromGMT]];
    
    //getting user vendor ID, (device UDID is no longer used)
    NSString *udid = [NSString stringWithFormat:@"%@",[[UIDevice currentDevice] identifierForVendor].UUIDString];
    
    //Getting minimum prefered age from the settings.
    NSString *minAgeString = [NSString stringWithFormat:@"%d",[DiscoverProfileCollection sharedInstance].intentModelObject.minAge.intValue];
    
    //Getting maximum prefered age from the settings.
    NSString *maxAgeString = [NSString stringWithFormat:@"%d",[DiscoverProfileCollection sharedInstance].intentModelObject.maxAge.intValue];
    
    //App version
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    //Getting if user will get incentive or not
   // NSString *willUserGetIncentiveProfile = [[NSUserDefaults standardUserDefaults] boolForKey:kUserShouldGetNewProfilesAsIncentive]?@"TRUE":@"FALSE";
    
    //Creating Discover URL with base URl, discover API and woo ID
    NSMutableString *getDiscoverDataURL = [NSMutableString stringWithFormat:@"%@%@wooId=%@",kBaseURLV20,kGetDiscoverData,userID];
    
    // Adding Google Reference Id
    if ([[NSUserDefaults standardUserDefaults] valueForKey:kGoogleReferenceId]) {
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&placeId=%@",[[NSUserDefaults standardUserDefaults] valueForKey:kGoogleReferenceId]]];
    }
    
    if([DiscoverProfileCollection sharedInstance].intentModelObject.showGoGlobal != nil){
        if([DiscoverProfileCollection sharedInstance].intentModelObject.showGoGlobal.boolValue == true){
            [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&goGlobal=true"]];
        }else{
            [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&goGlobal=false"]];
        }
        
        
    }else{
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&goGlobal=true"]];
    }
    
    if (gmtTime) {
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&gmtTime=%@",gmtTime]];
    }
    
    //Appending udid in the discover URL
    if (udid) {
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&deviceId=%@",udid]];
    }
    
    //Appending min prefered age in the discover URL, if nothing is prefered it will be 18
    if (minAgeString && ![minAgeString isEqualToString:@"(null)"]) {
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&minAge=%@",minAgeString]];
    }
    else{
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&minAge=%@",@"18"]];
    }
    
    //Appending max prefered age in the discover URL, if nothing is prefered it will be 30
    if (maxAgeString  && ![maxAgeString isEqualToString:@"(null)"]) {
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&maxAge=%@",maxAgeString]];
    }
    else{
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&maxAge=%@",@"30"]];
    }
    
    //Appending app version in discover URL, if nothing than it will 1.3
    if (appVersion && ![appVersion isEqualToString:@"(null)"]) {
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&appVersion=%@",appVersion]];
    }
    else{
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&appVersion=%@",@"3.0"]];
    }
    
    //Appending latitude in discover URL, if nothing than it will null
    if (latitude) {
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&latitude=%@",latitude]];
    }
    
    //Appending longitude in discover URL, if nothing than it will null
    if (longitude) {
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&longitude=%@",longitude]];
    }
    
    //[getDiscoverDataURL appendString:[NSString stringWithFormat:@"&isIncentive=%@",willUserGetIncentiveProfile]];
    
    //Appending prefered gender in discover URL
    if([DiscoverProfileCollection sharedInstance].intentModelObject.interestedGender){
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&interestedGender=%@",[DiscoverProfileCollection sharedInstance].intentModelObject.interestedGender]];
    }
    else{
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&interestedGender=FEMALE"]];
    }
    
    //Appending TRUE if user had made its profile hidden, else Appeding FALSE
    if (([[NSUserDefaults standardUserDefaults] boolForKey:kProfileHidingPreferenceEdited] == YES) || ([[NSUserDefaults standardUserDefaults] boolForKey:kProfileHidingPreferenceEdited] == NO)) {
        
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&isHidden=%@",([[NSUserDefaults standardUserDefaults] boolForKey:kProfileHidingPreferenceEdited]?@"TRUE":@"FALSE")]];
        
    }else{
        if (([[NSUserDefaults standardUserDefaults] boolForKey:kProfileHidingPreference] == YES) || ([[NSUserDefaults standardUserDefaults] boolForKey:kProfileHidingPreference] == NO)) {
            
            [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&isHidden=%@",([[NSUserDefaults standardUserDefaults] boolForKey:kProfileHidingPreference]?@"TRUE":@"FALSE")]];
            
        }else{
            [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&isHidden=%@",@"FALSE"]];
        }
    }
    
    // maxDistance
    NSInteger maxDistance = [DiscoverProfileCollection sharedInstance].intentModelObject.maxDistance.integerValue;
    if ([DiscoverProfileCollection sharedInstance].intentModelObject.isKms.boolValue == true) {
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&maxDistance=%ld",(long)maxDistance]];
    }
    else{
        NSInteger maxDistanceInMiles = 0;
        
        if (maxDistance < 200) {
        if (maxDistance == 10) {
            maxDistanceInMiles = 16;
        }
        else if (maxDistance == 20){
            maxDistanceInMiles = 32;
        }
        else if (maxDistance == 50){
            maxDistanceInMiles = 80;
        }
        else if (maxDistance == 100){
            maxDistanceInMiles = 160;
        }
        }
        else{
            maxDistanceInMiles = maxDistance;
        }
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&maxDistance=%ld",(long)maxDistanceInMiles]];
    }
    [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&isKms=%@",[DiscoverProfileCollection sharedInstance].intentModelObject.isKms.boolValue ? @"TRUE":@"FALSE"]];
    [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&favIntent=%@",[DiscoverProfileCollection sharedInstance].intentModelObject.favIntent]];
    
    
    BOOL needToUpdateAppLaunch = NO;
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kLocationNeedsToBeUpdatedOnServer]) {
        
        needToUpdateAppLaunch = YES;
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setBool:NO forKey:kLocationNeedsToBeUpdatedOnServer];
        [userDefault synchronize];
        if ([[userDefault objectForKey:KSourceOfLocation] isEqualToString:@"Manual"] ||
            [[userDefault objectForKey:KSourceOfLocation] isEqualToString:@"Manual_settings"]) {
            
            [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&locationChanged=%@&locationSource=%@&locationSubSource=%@",@"TRUE",[userDefault objectForKey:KSourceOfLocation],[userDefault objectForKey:kSubSourceOfLocation]]];
        }
        else{
            [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&locationChanged=%@&locationSource=%@",@"TRUE",[userDefault objectForKey:KSourceOfLocation]]];
        }
        
    }
    else{
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&locationChanged=%@",@"FALSE"]];
    }
    
    if (paginationEnabled) {
        if (tagSelected) {
            [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&paginationToken=%@&index=%@",
                                              [DiscoverProfileCollection sharedInstance].tagSearchPaginationToken,
                                              [DiscoverProfileCollection sharedInstance].tagSearchPaginationIndex]];
        }
        else{
            [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&paginationToken=%@&index=%@",
                                          [DiscoverProfileCollection sharedInstance].paginationToken,
                                          [DiscoverProfileCollection sharedInstance].paginationIndex]];
        }
    }
    
    if (isExtended) {
        [getDiscoverDataURL appendString:@"&forDiscoverEmpty=true"];
    }
    
    if (tagSelected == true) {
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&tagId=%@&tagType=%@&tagWooIdsToRemove=%@&tagName=%@",[DiscoverProfileCollection sharedInstance].selectedTagData.tagId,[DiscoverProfileCollection sharedInstance].selectedTagData.tagsDtoType,[DiscoverProfileCollection sharedInstance].selectedUserTagWooID,
            [DiscoverProfileCollection sharedInstance].selectedTagData.name]];
    }
    
    /// create param dictionary for Woo Globe
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =getDiscoverDataURL;
    wooRequestObj.time =9000;
    wooRequestObj.requestParams = [NSDictionary dictionaryWithObjectsAndKeys:[APP_Utilities convertDictionaryToString:[self getWooGlobeDetail]],@"payload", nil] ;
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries =-10;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = getDiscoverScreenData;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
       // NSLog(@"response :%@",response);
        if (![response isKindOfClass:[NSDictionary class]])
        {
            return;
        }
        
        if (success) {
            
            if (([response objectForKey:@"hasMovedAcrossRegion"] && [[response objectForKey:@"hasMovedAcrossRegion"] boolValue]) || ![[NSUserDefaults standardUserDefaults] boolForKey:@"productsFetched"]) {
                [[AppSessionManager sharedManager] getPurchaseProductDetailFromServer];
                
                [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"productsFetched"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            if (needToUpdateAppLaunch) {
                
                [[AppSessionManager sharedManager] makeAppLaunchCallToServer];
            }
            
            if( [[NSUserDefaults standardUserDefaults] valueForKey:kGoogleReferenceId]){
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kGoogleReferenceId];
            }
            
            if (tagSelected) {
                if ([response objectForKey:@"paginationToken"]) {
                    [DiscoverProfileCollection sharedInstance].tagSearchPaginationToken = [response objectForKey:@"paginationToken"];
                }
                else{
                    [DiscoverProfileCollection sharedInstance].tagSearchPaginationToken = @"";
                }
            }
            else{
                if ([response objectForKey:@"paginationToken"]) {
                    [DiscoverProfileCollection sharedInstance].paginationToken = [response objectForKey:@"paginationToken"];
                }
                else{
                    [DiscoverProfileCollection sharedInstance].paginationToken = @"";
                }
            }
            
            if (tagSelected) {
                if ([response objectForKey:@"index"]) {
                    [DiscoverProfileCollection sharedInstance].tagSearchPaginationIndex = [NSString stringWithFormat:@"%@",[response objectForKey:@"index"]];
                }
                else{
                    [DiscoverProfileCollection sharedInstance].tagSearchPaginationIndex = @"";
                }
            }
            else{
                if ([response objectForKey:@"index"]) {
                    [DiscoverProfileCollection sharedInstance].paginationIndex = [NSString stringWithFormat:@"%@",[response objectForKey:@"index"]];
                }
                else{
                    [DiscoverProfileCollection sharedInstance].paginationIndex = @"";
                }
            }
            
            if (tagSelected) {
                if ([response objectForKey:@"paginationTokenExpired"]) {
                    [[DiscoverProfileCollection sharedInstance] setIstagSearchPaginationTokenExpired:true];
                }
                else{
                    [[DiscoverProfileCollection sharedInstance] setIstagSearchPaginationTokenExpired:false];
                }
            }
            else{
                if ([response objectForKey:@"paginationTokenExpired"]) {
                    [[DiscoverProfileCollection sharedInstance] setIsPaginationTokenExpired:true];
                }
                else{
                    [[DiscoverProfileCollection sharedInstance] setIsPaginationTokenExpired:false];
                }
            }
        
            if ([response objectForKey:@"discoverCardDtos"] &&
                ((NSArray*)[response objectForKey:@"discoverCardDtos"]).count > 0)
            {
                if (tagSelected == true) {
                    [[DiscoverProfileCollection sharedInstance] updateSearchCardCollection:[response objectForKey:@"discoverCardDtos"]];
                }
                else{
                [[DiscoverProfileCollection sharedInstance] updateCardCollection:[response objectForKey:@"discoverCardDtos"]];
                }
            }
        }
        else{
            if (statusCode == 401) {
                [APP_Utilities deleteAccount_Temp:nil];
            }
        }
        
        if (block) {
            block(success,response,statusCode);
        }
        
    } shouldReachServerThroughQueue:FALSE];
}

+(void)fetchDiscoverDataFromServerWithRequestBody:(BOOL)paginationEnabled AndPrefrence: (BOOL)isExtended isTagSelected:(BOOL)tagSelected AndCompletionBlock:(DiscoverAPICompletionBlock) block{

    if (paginationEnabled && ![[DiscoverProfileCollection sharedInstance] isPaginationAllowed]) {
        return;
    }
    
    NSString *latitude,*longitude ;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserLastLocationKey]) {
        latitude = [NSString stringWithFormat:@"%f",[[[[NSUserDefaults standardUserDefaults] objectForKey:kUserLastLocationKey] objectForKey:kLastLocationLatitudeKey] floatValue]];//latitude
        longitude = [NSString stringWithFormat:@"%f",[[[[NSUserDefaults standardUserDefaults] objectForKey:kUserLastLocationKey] objectForKey:kLastLocationLongitudeKey] floatValue]];//longitude
    }
    else{
        latitude = @"28.628278";
        longitude = @"77.206065";
    }
    //Woo user id of a user.
    
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId];
    
    if (([[APP_Utilities validString:userID] length] == 0) || ![[NSUserDefaults standardUserDefaults] boolForKey:@"isOnboardingMyProfileShown"]) {
        return;
    }
    
    //user's Time zone
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    
    //getting the difference between user time zone and GMT
    NSString *gmtTime = [NSString stringWithFormat:@"%ld",(long)[timeZone secondsFromGMT]];
    
    //getting user vendor ID, (device UDID is no longer used)
    NSString *udid = [NSString stringWithFormat:@"%@",[[UIDevice currentDevice] identifierForVendor].UUIDString];
    
    //Getting minimum prefered age from the settings.
    NSString *minAgeString = [NSString stringWithFormat:@"%d",[DiscoverProfileCollection sharedInstance].intentModelObject.minAge.intValue];
    
    //Getting maximum prefered age from the settings.
    NSString *maxAgeString = [NSString stringWithFormat:@"%d",[DiscoverProfileCollection sharedInstance].intentModelObject.maxAge.intValue];
    
    //App version
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    //Getting if user will get incentive or not
    // NSString *willUserGetIncentiveProfile = [[NSUserDefaults standardUserDefaults] boolForKey:kUserShouldGetNewProfilesAsIncentive]?@"TRUE":@"FALSE";
    
    //Creating Discover URL with base URl, discover API and woo ID
    NSMutableString *getDiscoverDataURL = [NSMutableString stringWithFormat:@"%@%@?wooId=%@",kBaseURLV20,kGetDiscoverData,userID];
    
    // Adding Google Reference Id
    if ([[NSUserDefaults standardUserDefaults] valueForKey:kGoogleReferenceId]) {
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&placeId=%@",[[NSUserDefaults standardUserDefaults] valueForKey:kGoogleReferenceId]]];
    }
    
    if([DiscoverProfileCollection sharedInstance].intentModelObject.showGoGlobal != nil){
        if([DiscoverProfileCollection sharedInstance].intentModelObject.showGoGlobal.boolValue == true){
            [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&goGlobal=true"]];
        }else{
            [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&goGlobal=false"]];
        }
        
        
    }else{
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&goGlobal=true"]];
    }
    
    if (gmtTime) {
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&gmtTime=%@",gmtTime]];
    }
    
    //Appending udid in the discover URL
    if (udid) {
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&deviceId=%@",udid]];
    }
    
    //Appending min prefered age in the discover URL, if nothing is prefered it will be 18
    if (minAgeString && ![minAgeString isEqualToString:@"(null)"]) {
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&minAge=%@",minAgeString]];
    }
    else{
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&minAge=%@",@"18"]];
    }
    
    //Appending max prefered age in the discover URL, if nothing is prefered it will be 30
    if (maxAgeString  && ![maxAgeString isEqualToString:@"(null)"]) {
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&maxAge=%@",maxAgeString]];
    }
    else{
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&maxAge=%@",@"30"]];
    }
    
    //Appending app version in discover URL, if nothing than it will 1.3
    if (appVersion && ![appVersion isEqualToString:@"(null)"]) {
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&appVersion=%@",appVersion]];
    }
    else{
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&appVersion=%@",@"3.0"]];
    }
    
    //Appending latitude in discover URL, if nothing than it will null
    if (latitude) {
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&latitude=%@",latitude]];
    }
    
    //Appending longitude in discover URL, if nothing than it will null
    if (longitude) {
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&longitude=%@",longitude]];
    }
    
    //[getDiscoverDataURL appendString:[NSString stringWithFormat:@"&isIncentive=%@",willUserGetIncentiveProfile]];
    
    //Appending prefered gender in discover URL
    if([DiscoverProfileCollection sharedInstance].intentModelObject.interestedGender){
        if ([[DiscoverProfileCollection sharedInstance].intentModelObject.interestedGender isEqualToString:@"UNKNOWN"]){
            if ([[DiscoverProfileCollection sharedInstance].myProfileData.gender isEqualToString:@"MALE"]){
                [DiscoverProfileCollection sharedInstance].intentModelObject.interestedGender = @"FEMALE";
            }
            else{
                [DiscoverProfileCollection sharedInstance].intentModelObject.interestedGender = @"MALE";
            }
        }
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&interestedGender=%@",[DiscoverProfileCollection sharedInstance].intentModelObject.interestedGender]];
    }
    else{
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&interestedGender=FEMALE"]];
    }
    
    //Appending TRUE if user had made its profile hidden, else Appeding FALSE
    if (([[NSUserDefaults standardUserDefaults] boolForKey:kProfileHidingPreferenceEdited] == YES) || ([[NSUserDefaults standardUserDefaults] boolForKey:kProfileHidingPreferenceEdited] == NO)) {
        
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&isHidden=%@",([[NSUserDefaults standardUserDefaults] boolForKey:kProfileHidingPreferenceEdited]?@"TRUE":@"FALSE")]];
        
    }else{
        if (([[NSUserDefaults standardUserDefaults] boolForKey:kProfileHidingPreference] == YES) || ([[NSUserDefaults standardUserDefaults] boolForKey:kProfileHidingPreference] == NO)) {
            
            [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&isHidden=%@",([[NSUserDefaults standardUserDefaults] boolForKey:kProfileHidingPreference]?@"TRUE":@"FALSE")]];
            
        }else{
            [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&isHidden=%@",@"FALSE"]];
        }
    }
    
    // maxDistance
    NSInteger maxDistance = [DiscoverProfileCollection sharedInstance].intentModelObject.maxDistance.integerValue;
    if ([DiscoverProfileCollection sharedInstance].intentModelObject.isKms.boolValue == true) {
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&maxDistance=%ld",(long)maxDistance]];
    }
    else{
        NSInteger maxDistanceInMiles = 0;
        
        if (maxDistance < 200) {
            if (maxDistance == 10) {
                maxDistanceInMiles = 16;
            }
            else if (maxDistance == 20){
                maxDistanceInMiles = 32;
            }
            else if (maxDistance == 50){
                maxDistanceInMiles = 80;
            }
            else if (maxDistance == 100){
                maxDistanceInMiles = 160;
            }
        }
        else{
            maxDistanceInMiles = maxDistance;
        }
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&maxDistance=%ld",(long)maxDistanceInMiles]];
    }
    [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&isKms=%@",[DiscoverProfileCollection sharedInstance].intentModelObject.isKms.boolValue ? @"TRUE":@"FALSE"]];
    [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&favIntent=%@",[DiscoverProfileCollection sharedInstance].intentModelObject.favIntent]];
    
    
    BOOL needToUpdateAppLaunch = NO;
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kLocationNeedsToBeUpdatedOnServer]) {
        
        needToUpdateAppLaunch = YES;
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setBool:NO forKey:kLocationNeedsToBeUpdatedOnServer];
        [userDefault synchronize];
        if ([[userDefault objectForKey:KSourceOfLocation] isEqualToString:@"Manual"] ||
            [[userDefault objectForKey:KSourceOfLocation] isEqualToString:@"Manual_settings"]) {
            
            [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&locationChanged=%@&locationSource=%@&locationSubSource=%@",@"TRUE",[userDefault objectForKey:KSourceOfLocation],[userDefault objectForKey:kSubSourceOfLocation]]];
        }
        else{
            [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&locationChanged=%@&locationSource=%@",@"TRUE",[userDefault objectForKey:KSourceOfLocation]]];
        }
        
    }
    else{
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&locationChanged=%@",@"FALSE"]];
    }
    
//    if ([[AppLaunchModel sharedInstance] showLocationToggle] == true) {
//        if ([[[[DiscoverProfileCollection sharedInstance] intentModelObject] showLocation] boolValue] == true) {
//            [getDiscoverDataURL appendString:@"&showLocation=true"];
//        }
//        else{
//            [getDiscoverDataURL appendString:@"&showLocation=false"];
//        }
////    }

    [getDiscoverDataURL appendString:@"&showLocation=true"];

    
//    NSLog(@"[DiscoverProfileCollection sharedInstance].paginationToken === %@",[DiscoverProfileCollection sharedInstance].paginationToken);
//    NSLog(@"[DiscoverProfileCollection sharedInstance].paginationIndex === %@",[DiscoverProfileCollection sharedInstance].paginationIndex);
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"wooIdsToInclude"]){
        [DiscoverProfileCollection sharedInstance].callInProgress = true;
        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&wooIdsToInclude=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"wooIdsToInclude"]]];
        if (paginationEnabled == true){
            paginationEnabled = false;
        }
    }
    
    if (paginationEnabled) {
        if (tagSelected) {
            [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&paginationToken=%@&index=%@",
                                              [DiscoverProfileCollection sharedInstance].tagSearchPaginationToken,
                                              [DiscoverProfileCollection sharedInstance].tagSearchPaginationIndex]];
        }
        else{
            [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&paginationToken=%@&index=%@",
                                              [DiscoverProfileCollection sharedInstance].paginationToken,
                                              [DiscoverProfileCollection sharedInstance].paginationIndex]];
        }
    }
    
    if (isExtended) {
        [getDiscoverDataURL appendString:@"&forDiscoverEmpty=true"];
    }
    
    if (tagSelected == true) {

        if ([DiscoverProfileCollection sharedInstance].selectedTagData != nil){
            NSString *nameString = [[DiscoverProfileCollection sharedInstance].selectedTagData.name stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];

        [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&tagId=%@&tagType=%@&tagWooIdsToRemove=%@&tagName=%@",[DiscoverProfileCollection sharedInstance].selectedTagData.tagId,[DiscoverProfileCollection sharedInstance].selectedTagData.tagsDtoType,[DiscoverProfileCollection sharedInstance].selectedUserTagWooID,
            nameString]];
        }
    }
    else{
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"needToSendCurrentWooIDToServer"] && [DiscoverProfileCollection sharedInstance].currentProfileWooID.length > 0) {
            [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&tagWooIdsToRemove=%@",[DiscoverProfileCollection sharedInstance].currentProfileWooID]];
            [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"needToSendCurrentWooIDToServer"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }

    }
    
    if ([DiscoverProfileCollection sharedInstance].needToSendWooIDsForFLP == true) {
        NSString *flpIDs = @"";
        if ([DiscoverProfileCollection sharedInstance].flpWooIDs.count > 0) {
            if ([DiscoverProfileCollection sharedInstance].flpWooIDs.count == 1) {
                flpIDs = [DiscoverProfileCollection sharedInstance].flpWooIDs.lastObject;
            }
            else{
                flpIDs = [NSString stringWithFormat:@"%@,%@",[DiscoverProfileCollection sharedInstance].flpWooIDs.firstObject,[[[DiscoverProfileCollection sharedInstance] flpWooIDs] objectAtIndex:[DiscoverProfileCollection sharedInstance].flpWooIDs.count - 2]];
            }
            [getDiscoverDataURL appendString:[NSString stringWithFormat:@"&tagWooIdsToRemove=%@",flpIDs]];
        }
    }
    

    NSDictionary *paramDict = [self getWooGlobeDetail];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    
//    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [manager setRequestSerializer:requestSerializer];
    
    
//    NSLog(@"Discover API call :%@",getDiscoverDataURL);
//    NSLog(@"discover param :%@",paramDict);
    [manager POST:getDiscoverDataURL parameters:paramDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DiscoverProfileCollection sharedInstance].callInProgress = false;

        if (![responseObject isKindOfClass:[NSDictionary class]])
        {
            return;
        }
        
//        NSLog(@"responseObject Discover :%@",resvponseObject);
        
        NSDictionary *response = (NSDictionary *)responseObject;
        
        if (operation.response.statusCode == 200) {
            
            if (![LoginModel sharedInstance].appLozicToken ||![LoginModel sharedInstance].appLozicUserId){
                
                [[AppSessionManager sharedManager] makeAppLaunchCallToServer];
            }
            
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"wooIdsToInclude"]){
                if (![getDiscoverDataURL containsString:@"wooIdsToInclude"]){
                    //[self fetchDiscoverDataFromServerWithRequestBody:paginationEnabled AndPrefrence:isExtended isTagSelected:tagSelected AndCompletionBlock:nil];
                    return;
                }
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"wooIdsToInclude"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            if ([DiscoverProfileCollection sharedInstance].needToSendWooIDsForFLP == true) {
                [DiscoverProfileCollection sharedInstance].needToSendWooIDsForFLP = false;
                [[DiscoverProfileCollection sharedInstance].flpWooIDs removeAllObjects];
            }
            
            if (([response objectForKey:@"hasMovedAcrossRegion"] && [[response objectForKey:@"hasMovedAcrossRegion"] boolValue]) || ![[NSUserDefaults standardUserDefaults] boolForKey:@"productsFetched"]) {
                [[AppSessionManager sharedManager] getPurchaseProductDetailFromServer];
                
                [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"productsFetched"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            if (needToUpdateAppLaunch || ([response objectForKey:@"reCallAppLaunch"] == true)) {
                
                [[AppSessionManager sharedManager] makeAppLaunchCallToServer];
            }
            
            if ([response objectForKey:@"hasDeviceChanged"]){
                if ((BOOL)[response objectForKey:@"hasDeviceChanged"] == true){
                    [APP_DELEGATE sendDeviceTokedToServer:[[NSUserDefaults standardUserDefaults] objectForKey:kDeviceToken] andPushKitToken:nil];

                }
                
            }
            
            if( [[NSUserDefaults standardUserDefaults] valueForKey:kGoogleReferenceId]){
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kGoogleReferenceId];
            }
            
            if ([response objectForKey:@"maxDistance"]) {
                [DiscoverProfileCollection sharedInstance].intentModelObject.maxDistance = [response objectForKey:@"maxDistance"];

            }
            
            if (tagSelected) {
                if ([response objectForKey:@"paginationToken"]) {
                    [DiscoverProfileCollection sharedInstance].tagSearchPaginationToken = [response objectForKey:@"paginationToken"];
                }
                else{
                    [DiscoverProfileCollection sharedInstance].tagSearchPaginationToken = @"";
                }
            }
            else{
                if ([response objectForKey:@"paginationToken"]) {
                    [DiscoverProfileCollection sharedInstance].paginationToken = [response objectForKey:@"paginationToken"];
                }
                else{
                    [DiscoverProfileCollection sharedInstance].paginationToken = @"";
                }
            }
            
            if (tagSelected) {
                if ([response objectForKey:@"index"]) {
                    [DiscoverProfileCollection sharedInstance].tagSearchPaginationIndex = [NSString stringWithFormat:@"%@",[response objectForKey:@"index"]];
                }
                else{
                    [DiscoverProfileCollection sharedInstance].tagSearchPaginationIndex = @"";
                }
            }
            else{
                if ([response objectForKey:@"index"]) {
                    [DiscoverProfileCollection sharedInstance].paginationIndex = [NSString stringWithFormat:@"%@",[response objectForKey:@"index"]];
                }
                else{
                    [DiscoverProfileCollection sharedInstance].paginationIndex = @"";
                }
            }
            
            if (tagSelected) {
                if ([response objectForKey:@"paginationTokenExpired"]) {
                    [[DiscoverProfileCollection sharedInstance] setIstagSearchPaginationTokenExpired:true];
                }
                else{
                    [[DiscoverProfileCollection sharedInstance] setIstagSearchPaginationTokenExpired:false];
                }
            }
            else{
                if ([response objectForKey:@"paginationTokenExpired"]) {
                    [[DiscoverProfileCollection sharedInstance] setIsPaginationTokenExpired:true];
                }
                else{
                    [[DiscoverProfileCollection sharedInstance] setIsPaginationTokenExpired:false];
                }
            }
            
            if ([response objectForKey:@"discoverCardDtos"] &&
                ((NSArray*)[response objectForKey:@"discoverCardDtos"]).count > 0)
            {
                if (tagSelected == true) {
                    [[DiscoverProfileCollection sharedInstance] updateSearchCardCollection:[response objectForKey:@"discoverCardDtos"]];
                }
                else{
                    [[DiscoverProfileCollection sharedInstance] updateCardCollection:[response objectForKey:@"discoverCardDtos"]];
                }
            }
            //Added on 22 June 2017 for the purpose of fetching matches on discover call
            if ([response objectForKey:@"refreshMatches"])
            {
                [APP_DELEGATE getMyMatchesForRefreshMatchesTimestamp:0 withCompletion:nil];
            }
            if (block) {
                block(TRUE,response,(int)operation.response.statusCode);
            }
        }
        else{
            if (operation.response.statusCode == 401) {
                [APP_Utilities deleteAccount_Temp:nil];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (operation.response.statusCode == 401) {
            [APP_Utilities deleteAccount_Temp:nil];
        }
        if (block) {
            block(FALSE,nil,(int)operation.response.statusCode);
        }
    } caching:GET_DATA_FROM_URL_ONLY andNumberOfRetries:0];
    

}

+ (void)makeLikeCallWithParams:(NSString *)otherPersonWooId andSelectedTag:(NSDictionary *)selectedTag withTagId:( NSString* _Nullable )tagId andTagDTOType:(NSString* _Nullable)tagType AndCompletionBlock:(DiscoverAPICompletionBlock _Nullable ) block
{
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId];
    
    if ([[APP_Utilities validString:userID] length] == 0){
        return;
    }
    if( ![APP_Utilities validString:otherPersonWooId] || [otherPersonWooId isEqualToString:@"0"] )
    {
        block(NO, nil, nil);
    }
    NSString *likeAProfileURL = [NSString stringWithFormat:@"%@%@?actorId=%@&targetId=%@",kBaseURLV4,kLikeAProfile,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],otherPersonWooId];
    
    if(tagId != nil && tagType != nil)
    {
        likeAProfileURL = [likeAProfileURL stringByAppendingString:[NSString stringWithFormat:@"&tagId=%@&tagType=%@",tagId,tagType]];
    }
//    NSLog(@"likeAProfileURL :%@",likeAProfileURL);
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =likeAProfileURL;
    wooRequestObj.time =0;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = likeOrDislikeAProfile;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        if (statusCode == 200){
            //Match Flow
   
        }
        block(success, response, statusCode);
        
    }shouldReachServerThroughQueue:FALSE];
    
}

+ (void)makePassCallWithParams:(NSString *)otherPersonWooId AndCompletionBlock:(DiscoverAPICompletionBlock) block{
    
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId];
    
    if ([[APP_Utilities validString:userID] length] == 0){
        return;
    }
    
    if ([userID isEqualToString:otherPersonWooId]){
        return;
    }
    
    NSString *sendDirectMessageURL = [NSString stringWithFormat:@"%@%@?actorId=%@&targetId=%@&message=%@&%@=%@&%@=%@",kBaseURLV3,kDisLikeAProfile,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],otherPersonWooId,@"",kDislikeSourceKey,kDislikeSourceDiscoverValue,kDislikeSubSourceKey,kDislikeSubSourcePassValue];
    
    
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url = sendDirectMessageURL;
    wooRequestObj.time =0;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = likeOrDislikeAProfile;
    //
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        block(success,response,statusCode);
        
    } shouldReachServerThroughQueue:TRUE];
}

+ (void)makePassCallWithParams:(NSString *)otherPersonWooId withSubsource:(NSString *)subsourceString withTagId:( NSString* _Nullable )tagId andTagDTOType:(NSString* _Nullable)tagType  AndCompletionBlock:(DiscoverAPICompletionBlock) block
{
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId];
    
    if ([[APP_Utilities validString:userID] length] == 0){
        return;
    }
    
    if ([userID isEqualToString:otherPersonWooId]){
        return;
    }
    
    NSString *sendDirectMessageURL = [NSString stringWithFormat:@"%@%@?actorId=%@&targetId=%@&message=%@&%@=%@",kBaseURLV3,kDisLikeAProfile,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],otherPersonWooId,@"",kDislikeSourceKey,kDislikeSourceDiscoverValue];
    if(tagId != nil && tagType != nil)
    {
       sendDirectMessageURL = [sendDirectMessageURL stringByAppendingString:[NSString stringWithFormat:@"&tagId=%@&tagType=%@",tagId,tagType]];
    }
    
    if (subsourceString && [subsourceString length] > 0) {
        sendDirectMessageURL = [NSString stringWithFormat:@"%@&%@=%@", sendDirectMessageURL, kDislikeSubSourceKey, subsourceString];
    }
    else{
        sendDirectMessageURL = [NSString stringWithFormat:@"%@&%@=%@", sendDirectMessageURL, kDislikeSubSourceKey, kDislikeSubSourcePassValue];
    }
    
    
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url = sendDirectMessageURL;
    wooRequestObj.time =0;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = likeOrDislikeAProfile;
    //
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        block(success,response,statusCode);
        
    } shouldReachServerThroughQueue:TRUE];
    
    
}

+ (void)makeSendCrushCallWithParams:(NSString *)otherPersonWooId andCrushText:(NSString *)crushText AndCompletionBlock:(DiscoverAPICompletionBlock) block{
    
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId];
    
    if ([[APP_Utilities validString:userID] length] == 0){
        return;
    }
    if( ![APP_Utilities validString:otherPersonWooId] || [otherPersonWooId isEqualToString:@"0"] )
    {
        block(NO, nil, nil);
    }
    
    NSString *sendDirectMessageURL = [NSString stringWithFormat:@"%@%@?actorId=%@&targetId=%@&text=%@&crush=%@&actorPurchasedCrush=%@",kBaseURLV4,kLikeAProfile,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],otherPersonWooId,[APP_Utilities encodeFromPercentEscapeString:crushText],@"TRUE",![[CrushModel sharedInstance] checkIfUserNeedsToPurchase]?@"TRUE":@"FALSE"];

    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url = sendDirectMessageURL;
    wooRequestObj.time =0;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = likeOrDislikeAProfile;
    //
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        block(success,response,statusCode);
        
    } shouldReachServerThroughQueue:TRUE];

}

+(NSMutableDictionary *)getWooGlobeDetail{
//    return nil;
//    if ([WooGlobeModel sharedInstance].isExpired) {
//        return nil;
//    }
    
    NSMutableDictionary *wooGlobeParamDict = [[NSMutableDictionary alloc] init];

    [wooGlobeParamDict setValue:[WooGlobeModel sharedInstance].ethnicityOption?@"true":@"false" forKey:@"ethnicityOn"];
    [wooGlobeParamDict setValue:[WooGlobeModel sharedInstance].religionOption?@"true":@"false" forKey:@"religionsOn"];
    
    [wooGlobeParamDict setValue:[WooGlobeModel sharedInstance].wooGlobleOption?@"true":@"false" forKey:@"wooGlobeOn"];
    
    NSMutableArray *religionIdArray = [[NSMutableArray alloc] init];
    for (NSDictionary *religionDetail in [WooGlobeModel sharedInstance].religionArray) {
        if ([religionDetail objectForKey:@"tagId"]) {
            [religionIdArray addObject:[religionDetail objectForKey:@"tagId"]];
        }
    }
    
    NSMutableArray *ethnicityIdArray = [[NSMutableArray alloc] init];
    for (NSDictionary *ethnicityDetail in [WooGlobeModel sharedInstance].ethnicityArray) {
        if ([ethnicityDetail objectForKey:@"tagId"]) {
            [ethnicityIdArray addObject:[ethnicityDetail objectForKey:@"tagId"]];
        }
    }
//    if ([religionIdArray count] > 0) {
        [wooGlobeParamDict setObject:religionIdArray forKey:@"religions"];
//    }
    
//    if ([ethnicityIdArray count] > 0) {
        [wooGlobeParamDict setObject:ethnicityIdArray forKey:@"ethnicity"];
//    }
    
    if ([WooGlobeModel sharedInstance].wooGlobeLocationDictionary && [[WooGlobeModel sharedInstance].wooGlobeLocationDictionary.allKeys count] > 0) {
        NSDictionary *diasporaLocationDict = [NSDictionary dictionaryWithObjectsAndKeys:
          [[WooGlobeModel sharedInstance].wooGlobeLocationDictionary objectForKey:@"latitude"],@"latitude",
          [[WooGlobeModel sharedInstance].wooGlobeLocationDictionary objectForKey:@"longitude"],@"longitude",
          [[WooGlobeModel sharedInstance].wooGlobeLocationDictionary objectForKey:@"placeId"],@"placeId",
          nil];
        [wooGlobeParamDict setObject:diasporaLocationDict forKey:@"diasporaLocation"];
    }
    else{
        if ([WooGlobeModel sharedInstance].locationOption) {
            
            NSString *latitude,*longitude ;
            latitude = [NSString stringWithFormat:@"%f",[[[[NSUserDefaults standardUserDefaults] objectForKey:kUserLastLocationKey] objectForKey:kLastLocationLatitudeKey] floatValue]];//latitude
            longitude = [NSString stringWithFormat:@"%f",[[[[NSUserDefaults standardUserDefaults] objectForKey:kUserLastLocationKey] objectForKey:kLastLocationLongitudeKey] floatValue]];//longitude
            
            NSDictionary *diasporaLocationDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  latitude,@"latitude",
                                                  longitude,@"longitude",
                                                  nil];
            [wooGlobeParamDict setObject:diasporaLocationDict forKey:@"diasporaLocation"];
        }
        else{
            NSDictionary *diasporaLocationDict = [[NSDictionary alloc] init];
            [wooGlobeParamDict setObject:diasporaLocationDict forKey:@"diasporaLocation"];
        }
        
    }
    [wooGlobeParamDict setValue:[WooGlobeModel sharedInstance].locationOption?@"true":@"false" forKey:@"locationOn"];
//    NSLog(@"[APP_Utilities convertDictionaryToString:wooGlobeParamDict] :%@",[APP_Utilities convertDictionaryToString:wooGlobeParamDict]);
    return wooGlobeParamDict;
}

@end
