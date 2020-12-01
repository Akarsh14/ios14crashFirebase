//
//  LogInAPIClass.m
//  Woo_v2
//
//  Created by Suparno Bose on 4/26/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.


#import "LogInAPIClass.h"
#import "AppLaunchApiClass.h"

@implementation LogInAPIClass

+(BOOL)isUserFake:(NSString *)userID withGender:(NSString *)genderVal
           andDob:(NSString *)dobVal AndCompletionBlock:(LogInCallCompletionBlock)block{
    NSString *checkFakeIdURL = [NSString stringWithFormat:@"%@%@?wooId=%@",kLoginURLV5,kCheckWooFakeUser,userID];
    if ([genderVal length]>0) {
        checkFakeIdURL = [NSString stringWithFormat:@"%@&gender=%@",checkFakeIdURL,genderVal];
    }
    if ([dobVal length]>0) {
        checkFakeIdURL = [NSString stringWithFormat:@"%@&dob=%@",checkFakeIdURL,dobVal];
    }
    
    checkFakeIdURL = [NSString stringWithFormat:@"%@&requiredYouAreInScreen=true",checkFakeIdURL];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =checkFakeIdURL;
    wooRequestObj.time =900;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =getRequest;
    wooRequestObj.numberOfRetries =10;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = checkWooFakeUser;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        if (requestType == checkWooFakeUser) {
            if (statusCode==401 || statusCode==402 || statusCode==500) {
                [self handleErrorForResponseCode:statusCode];
                return ;
            }
            block(success,response,408, NO);
        }
    }shouldReachServerThroughQueue:TRUE];
    return TRUE;
}

+(void)handleErrorForResponseCode:(int)responseCode{
    
    switch (responseCode) {
            
        case 203:
        {
            //            Method Not Allowed
            SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"Woo is experiencing heavy traffic.", nil));
        }
            break;
            
        case 400:
        {
            //            Method Not Allowed
            SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"Woo is experiencing heavy traffic.", nil));
        }
            break;
        case 401:
        {
            U2AlertView *alert = [[U2AlertView alloc] init];
            
            [alert setU2AlertActionBlockForButton:^(int tagValue , id data){
                [APP_DELEGATE performSelector:@selector(showLoginScreen)];
            }];
            
            [alert alertWithHeaderText:@"Authentication error" description:@"Something unexpected has happened. Please login again" leftButtonText:NSLocalizedString(@"CMP00356", nil) andRightButtonText:nil];
            [alert show];
            
        }
            break;
            
        case 402:
        {
            //            Not Found
            //            [ALToastView toastInView:APP_DELEGATE.window withText:@"402:Payment required."];
            //$$$$$$$$$$$$
            //            [self showPayWall];
            
        }
            break;
            
        case 404:
        {
            //            Not Found
            SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"Woo is experiencing heavy traffic.", nil));
            
        }
            break;
            
        case 408:
        {
            //            Request Timeout
            
            SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"Woo is experiencing heavy traffic.", nil));
        }
            break;
            
        case 405:
        {
            //            Method Not Allowed
            SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"Woo is experiencing heavy traffic.", nil));
        }
            break;
        case 500:
        {
            //            Internal Server Error
         //   SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"Woo is experiencing heavy traffic.", nil));
        }
            break;
            
        default:
        {
            
        }
            break;
    }
}

#pragma mark - Login Call To Server
+(void)makeLoginCallToServerWithUserId:(NSString *)fbId
                       withAccessToken:(NSString *)accessToken
                          withLocation:(CLLocation *)location
                              withAge : (NSString *)age
                           withGender : (NSString *)gender
                            viaLogin :(NSString *)type
                              AnyTRUECALLERdata:(id )truecallerParameter
                    withCompletionBlock:(LogInCallCompletionBlock)block {
    
    NSString *mcc = [[NSUserDefaults standardUserDefaults] valueForKey:kMcc];
    NSString *mnc = [[NSUserDefaults standardUserDefaults] valueForKey:kMnc];
    
//    mcc = @"404";
//    mnc = @"10";
    
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];      //getting time zone
    
    NSInteger gmtTime = [timeZone secondsFromGMT];  //getting the difference between user time zone and GMT
    
    NSString *language = [APP_Utilities getDeviceLanguageString];   //User default language
    
    //added this value if device is unable to fetch the language. If language is nil the param dict was getting corrupted and hence failing the login call. 
    if (language == nil) {
        language = @"English";
    }
    
    NSString *locale = [APP_Utilities getDeviceLocaleCode];
    if (locale == nil) {
        locale = @"";
    }

    NSString *udid = [NSString stringWithFormat:@"%@",[[UIDevice currentDevice] identifierForVendor].UUIDString];   //getting user vendor ID, (device UDID is no longer used)
    if (udid == nil) {
        udid = @"";
    }
    
    
    NSString *lat = [NSString stringWithFormat:@"%f",location.coordinate.latitude];
    NSString *log = [NSString stringWithFormat:@"%f",location.coordinate.longitude];
    
    if (lat == nil || (int)location.coordinate.latitude == 0) {
        lat = @"";
    }
    if (log == nil || (int)location.coordinate.longitude == 0) {
        log = @"";
    }
    
    if ([age length] == 0)
        age = nil;
    
    
    NSMutableDictionary *params = nil;
    NSString *authType;
    NSString *authDTo;
    
    if([type isEqualToString:LoginViaFacebook]) {
        authType = LoginViaFacebook;
        authDTo = @"facebookDto";
    } else if ([type isEqualToString:LoginViaFacebookAccountKit]) {
        authType = LoginViaFacebookAccountKit;
        authDTo = @"facebookAccountKitDto";
    } else if([type isEqualToString:LoginViaTrueCaller]) {
        authType = LoginViaTrueCaller;
    }else if([type isEqualToString:LoginViaNativeOTP]) {
        authDTo = @"nativeOtpDto";
        authType = LoginViaNativeOTP;
    }else if([type isEqualToString:LoginViaFirebase]){
        authDTo = @"firebaseLoginDto";
        authType = LoginViaFirebase;
    }else if([type isEqualToString:LoginViaAppple]){
        authDTo = @"appleLoginDto";
        authType = LoginViaAppple;
    }

    NSMutableDictionary *authDictionary = [[NSMutableDictionary alloc] init];
    if ([accessToken length] > 0){
        
        if([type isEqualToString:LoginViaFirebase]){

                   NSDictionary *idTokenDTO = [NSDictionary dictionaryWithObject:accessToken forKey:@"idToken"];
                   [authDictionary setObject:idTokenDTO forKey:authDTo];
            
        }else if([type isEqualToString:LoginViaAppple]){
            
            NSDictionary *idTokenDTO = [NSDictionary dictionaryWithObject:accessToken forKey:@"idToken"];
            [authDictionary setObject:idTokenDTO forKey:authDTo];
            
            if([[NSUserDefaults standardUserDefaults] valueForKey:@"firstNameAppleLogin"] != nil){
                [authDictionary setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"firstNameAppleLogin"] forKey:@"firstName"];
            }
            
            if([[NSUserDefaults standardUserDefaults] valueForKey:@"lastNameAppleLogin"]!= nil){
                 [authDictionary setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"lastNameAppleLogin"] forKey:@"lastName"];
            }
        }else{
            NSDictionary *accessTokenDto = [NSDictionary dictionaryWithObject:accessToken forKey:@"accessToken"];
            
                [authDictionary setObject:accessTokenDto forKey:authDTo];
        }
            
        
        
        }
        [authDictionary setObject:authType forKey:@"authType"];
    
    ([type isEqualToString:LoginViaTrueCaller]) ? [authDictionary setObject:(NSDictionary *)truecallerParameter forKey:@"trueCallerDto"] : nil ;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserLastLocationKey] != nil){ // IF there is a location
        NSDictionary *locationValue = [[NSUserDefaults standardUserDefaults] objectForKey:kUserLastLocationKey];
        NSNumber *latValue = [locationValue objectForKey:kLastLocationLatitudeKey];
        NSNumber *longValue = [locationValue objectForKey:kLastLocationLongitudeKey];
    
         params = [NSMutableDictionary dictionaryWithObjectsAndKeys:authDictionary ,                                                @"authDto",
                   
                            [NSString stringWithFormat:@"%ld",(long)gmtTime] ,      @"gmtTime",
                            language ,                                              @"language",
                            locale,                                                 @"locale",
                            udid ,                                                  @"deviceId",
                            [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ,        @"appVersion",
                            latValue,                                                     @"latitude",
                            longValue,                                                     @"longitude",
                            mcc,                                                     @"mcc",
                            mnc,                                                     @"mnc",
                  nil];
    }
    
    else if (age && gender) // If both age & gender changes
         params = [NSMutableDictionary dictionaryWithObjectsAndKeys:authDictionary ,                                                @"authDto",
                 
                  [NSString stringWithFormat:@"%ld",(long)gmtTime] ,      @"gmtTime",
                  language ,                                              @"language",
                  locale,                                                 @"locale",
                  udid ,                                                  @"deviceId",
                  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ,        @"appVersion",
                  gender,                                                  @"gender",
                  age,                                                     @"ageInYear",nil];
    else if (age) // If only age changes
        params = [NSMutableDictionary dictionaryWithObjectsAndKeys:authDictionary ,                                                @"authDto",
                 
                  [NSString stringWithFormat:@"%ld",(long)gmtTime] ,      @"gmtTime",
                  language ,                                              @"language",
                  locale,                                                 @"locale",
                  udid ,                                                  @"deviceId",
                  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ,        @"appVersion",
                  age,                                                     @"ageInYear",nil];

    else if (gender) // If only gender changes
         params = [NSMutableDictionary dictionaryWithObjectsAndKeys:authDictionary ,                                                @"authDto",
                  
                  [NSString stringWithFormat:@"%ld",(long)gmtTime] ,      @"gmtTime",
                  locale,                                                 @"locale",
                  language ,                                              @"language",
                  udid ,                                                  @"deviceId",
                  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ,        @"appVersion",
                 gender,                                                  @"gender",
                  nil];
    
    else // IF there is no location
        
        if ([type isEqualToString:LoginViaTrueCaller]){
         params = [NSMutableDictionary dictionaryWithObjectsAndKeys:authDictionary ,                                                @"authDto",
                 
                  [NSString stringWithFormat:@"%ld",(long)gmtTime] ,      @"gmtTime",
                  language ,                                              @"language",
                  locale,                                                 @"locale",
                  udid ,                                                  @"deviceId",
                  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ,        @"appVersion",
                  mcc,                                                     @"mcc",
                  mnc,                                                     @"mnc",
                  nil];
        }else if ([type isEqualToString:LoginViaFirebase]){
         params = [NSMutableDictionary dictionaryWithObjectsAndKeys:authDictionary ,                                                @"authDto",
                 
                  [NSString stringWithFormat:@"%ld",(long)gmtTime] ,      @"gmtTime",
                  language ,                                              @"language",
                  locale,                                                 @"locale",
                  udid ,                                                  @"deviceId",
                  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ,        @"appVersion",
                  mcc,                                                     @"mcc",
                  mnc,                                                     @"mnc",
                  nil];
        }else if ([type isEqualToString:LoginViaAppple]){
         params = [NSMutableDictionary dictionaryWithObjectsAndKeys:authDictionary ,                                                @"authDto",
                 
                  [NSString stringWithFormat:@"%ld",(long)gmtTime] ,      @"gmtTime",
                  language ,                                              @"language",
                  locale,                                                 @"locale",
                  udid ,                                                  @"deviceId",
                  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ,        @"appVersion",
                  mcc,                                                     @"mcc",
                  mnc,                                                     @"mnc",
                  nil];
        }else{
      
                   params = [NSMutableDictionary dictionaryWithObjectsAndKeys:authDictionary ,                                                @"authDto",
                 
                  [NSString stringWithFormat:@"%ld",(long)gmtTime] ,      @"gmtTime",
                  language ,                                              @"language",
                  locale,                                                 @"locale",
                  udid ,                                                  @"deviceId",
                  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ,        @"appVersion",
                  mcc,                                                     @"mcc",
                  mnc,                                                     @"mnc",
                             nil];
            
        }
    
   
    ([[NSUserDefaults standardUserDefaults]valueForKey:@"wooIdsToInclude"] != nil) ? [params setObject:[[NSUserDefaults standardUserDefaults]valueForKey:@"wooIdsToInclude"] forKey:@"utmCampaign"] : [params setObject:@"UNKNOWN" forKey:@"utmCampaign"];
    
    ([[NSUserDefaults standardUserDefaults]valueForKey:@"utm_medium"] != nil) ? [params setObject:[[NSUserDefaults standardUserDefaults]valueForKey:@"utm_medium"] forKey:@"utmMedium"] : [params setObject:@"UNKNOWN" forKey:@"utmMedium"];
    
    ([[NSUserDefaults standardUserDefaults]valueForKey:@"utm_content"] != nil) ? [params setObject:[[NSUserDefaults standardUserDefaults]valueForKey:@"utm_content"] forKey:@"utmContent"] : [params setObject:@"UNKNOWN" forKey:@"utmContent"];
    
    ([[NSUserDefaults standardUserDefaults]valueForKey:@"utm_source"] != nil) ? [params setObject:[[NSUserDefaults standardUserDefaults]valueForKey:@"utm_source"] forKey:@"utmSource"] : [params setObject:@"UNKNOWN" forKey:@"utmSource"];
  
    [params setObject:kDeviceType forKey:@"deviceType"];
    
  if ([[NSUserDefaults standardUserDefaults] objectForKey:@"referralCookie"]) {
        NSDictionary *referralDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"referralCookie"];
        [params addEntriesFromDictionary:referralDict];
    }
    
    __block BOOL userChanged = NO;
    
    NSString *loginURL = [NSString stringWithFormat:@"%@%@",kLoginURLV4_HTTPS,kLoginCall];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =loginURL;
    wooRequestObj.time =0;
    wooRequestObj.requestParams =params;
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries =0;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = registerUserToServer;
    wooRequestObj.isJsonContentType = true;
    
    NSLog(@"params : %@",params);
    NSLog(@"login url : %@",loginURL);
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        if (requestType == registerUserToServer) {
            if (statusCode==401 || statusCode==402 || statusCode==500) {
                //     [self handleErrorForResponseCode:statusCode];
            }
            //            NSLog(@"response in make login call:%@",response);
            
            if (success) {
                if (response)
                    
                    
                    if ([response objectForKey:@"region"]) {
                        [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:@"region"] forKey:@"userRegion"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                [[LoginModel sharedInstance] updateModelWithData:response andLoginType:type];
                if([type isEqualToString:LoginViaFacebook]) {
                    [[LoginModel sharedInstance]setIsAlternateLogin:NO];
                } else {
                    [[LoginModel sharedInstance]setIsAlternateLogin:YES];
                    if ([type isEqualToString:LoginViaTrueCaller]){
                        [[LoginModel sharedInstance] setIsAlertnativeLoginTypeTrueCaller:YES];
                    }
                    else{
                        [[LoginModel sharedInstance] setIsAlertnativeLoginTypeTrueCaller:NO];
                    }
                }
                    
                
                // Update Login Model
                
                //                NSLog(@"%@",[LoginModel sharedInstance]);
                
                if ([[LoginModel sharedInstance] locationFound]) {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kLocationFound];
                }
                
                
                
                
                // Saving User Lat/Long
                
                if ([[response objectForKey:@"locationFound"] boolValue]) {
                    
                    NSNumber *lat = [NSNumber numberWithDouble:[[response objectForKey:@"latitude"] doubleValue]];
                    NSNumber *lon = [NSNumber numberWithDouble:[[response objectForKey:@"longitude"] doubleValue]];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:[[NSDictionary alloc] initWithObjectsAndKeys:lat,kLastLocationLatitudeKey,lon,kLastLocationLongitudeKey,nil] forKey:kUserLastLocationKey];
                    //  @{kLastLocationLatitudeKey:lat,kLastLocationLongitudeKey:lon} forKey:kUserLastLocationKey];
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kLocationNeedsToBeUpdatedOnServer];
                    
                }
        
                
                // Saving user confirmed if YES
                
                BOOL alreadyRegistered = [[response objectForKey:@"confirmed"] boolValue];
                [[NSUserDefaults standardUserDefaults] setBool:alreadyRegistered forKey:kUserAlreadyRegistered];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                
                if (![[response objectForKey:kOnBoardingPassed] boolValue]) {
                    
                    [[NSUserDefaults standardUserDefaults] setBool:[[response objectForKey:kOnBoardingPassed] boolValue] forKey:kUserAlreadyRegistered];
                    
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
                
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kProfileHidingPreference];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kIsUpdateVersion2_1];
                
                if ([response objectForKey:kWooEncryptionTokenFromServer]) {
                    [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:kWooEncryptionTokenFromServer]
                        forKey:kWooEncryptionTokenFromServer];
                }
                
                
                
                // Check if last user loggedIn & current user are same or different
                
                if ([[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]) // If saved userid exist
                    if (![[NSString stringWithFormat:@"%@",[response objectForKey:@"id"]] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]]) {
                        [APP_DELEGATE reinitialiseUserDefaultAndDatabase];
                        userChanged = YES;
                    }
                
                
                NSUserDefaults *userDefaultObj = [NSUserDefaults standardUserDefaults];
                //                NSLog(@"[userDefaultObj objectForKey:kWooUserId] :%@",[userDefaultObj objectForKey:kWooUserId]);
                [userDefaultObj setObject:[NSString stringWithFormat:@"%@",[response objectForKey:@"id"]] forKey:kWooUserId];
                [APP_Utilities myprofile].wooId = [NSString stringWithFormat:@"%@",[response objectForKey:@"id"]];
                //Make my profile call
                
                
                if (!([[APP_Utilities validString:[NSString stringWithFormat:@"%@",[response objectForKey:@"id"]]] length]>0) ||
                    [NSString stringWithFormat:@"%@",[response objectForKey:@"id"]] == NULL) {
                    return ;
                }
                [userDefaultObj setObject:[APP_Utilities validString:[NSString stringWithFormat:@"%@",[response objectForKey:@"firstName"]]] forKey:kWooUserName];
                [userDefaultObj setObject:[APP_Utilities validString:[NSString stringWithFormat:@"%@",fbId]] forKey:kFacebookNumbericUserID];
                [userDefaultObj setObject:[APP_Utilities validString:[NSString stringWithFormat:@"%@",[response objectForKey:@"profilePicUrl"]]] forKey:kWooProfilePicURL];
                [APP_Utilities precacheDiscoverImagesWithData:[NSArray arrayWithObject:[APP_Utilities validString:[NSString stringWithFormat:@"%@",[response objectForKey:@"profilePicUrl"]]]]];
                [userDefaultObj setObject:[response objectForKey:kProfileCompletenessScoreKey] forKey:kProfileCompletenessScoreKey];
                
                [userDefaultObj setObject:[response objectForKey:kGenderKey] forKey:kWooUserGender];
                [userDefaultObj setObject:[NSDate date] forKey:kWooLoggedInTime];
                
                
                [userDefaultObj synchronize];
                
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInSuccessfullyNotification object:nil];
                [APP_DELEGATE sendSwrveEventWithEvent:@"FBLogin.Success" andScreen:@"FBLogin"];
                [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"Success" forScreenName:@"Login"];
                [APP_DELEGATE sendFCMPushTokenToServer];
                // [APP_DELEGATE connectToLayer];
                [APP_DELEGATE trackVoIPInvites];
                if (![[response objectForKey:@"gender"] isEqualToString:@"UNKNOWN"]){
                    [[AppLaunchApiClass sharedManager] getNotificationConfigOptionsWithCompletionBlock:nil];
                }
                
                [APP_DELEGATE connectToApplozic];
                /*
                 
                 NSString *url = [[NSUserDefaults standardUserDefaults]objectForKey:kWooProfilePicURL];
                 
                 NSString *imageURL = nil;
                 
                 if([[APP_Utilities validString:url] length]>0){
                 imageURL = [NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(100),IMAGE_SIZE_FOR_POINTS(100), [APP_Utilities encodeFromPercentEscapeString:url]];
                 }
                 
                 */
                
            }
            else{
                //Error handling
                
            }
            
            block(success , response , statusCode , userChanged);
            
        }
        
    }  shouldReachServerThroughQueue:TRUE];
}



+(void)makeRegistrationCallwithCompletionBlock:(RegistrationCallCompletionBlock)regBlock {
    
    NSString *mnc = [[NSUserDefaults standardUserDefaults] valueForKey:kMnc];
    NSString *mcc = [[NSUserDefaults standardUserDefaults] valueForKey:kMcc];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSDate *birthDate = [dateFormatter dateFromString:LoginModel.sharedInstance.birthday];
    NSTimeInterval epochBirthday = [birthDate timeIntervalSince1970];
    double dob = round(epochBirthday*1000);
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]initWithObjectsAndKeys:LoginModel.sharedInstance.firstName, @"firstName" , LoginModel.sharedInstance.lastName, @"lastName",nil];
    
    [params setValue:LoginModel.sharedInstance.gender forKey:@"gender"];
    [params setValue:[NSNumber numberWithDouble:dob] forKey:@"dob"];
    [params setValue:nil forKey:@"placeId"];
    (mnc != nil) ? [params setValue:mnc forKey:@"mnc"] : nil;
    (mcc != nil) ? [params setObject:mcc forKey:@"mcc"] : nil;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserLastLocationKey] != nil){
        NSDictionary *locationValue = [[NSUserDefaults standardUserDefaults] objectForKey:kUserLastLocationKey];
        NSNumber *latValue = [locationValue objectForKey:kLastLocationLatitudeKey];
        NSNumber *longValue = [locationValue objectForKey:kLastLocationLongitudeKey];
        [params setValue:latValue forKey:@"latitude"];
        [params setValue:longValue forKey:@"longitude"];
        
    }
    
    NSString *registrationURl = [NSString stringWithFormat:@"%@%@?wooId=%@",kBaseURLV2_HTTPS,kRegistrationCall,[[NSUserDefaults standardUserDefaults] valueForKey:kWooUserId]];
   __block BOOL userChanged = NO;
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =registrationURl;
    wooRequestObj.time =0;
    wooRequestObj.requestParams = params;
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries =0;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = registerUserToServer;
    wooRequestObj.isJsonContentType = true;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        if (requestType == registerUserToServer) {
            if (statusCode==401 || statusCode==402 || statusCode==500) {
                //     [self handleErrorForResponseCode:statusCode];
            }
            //            NSLog(@"response in make login call:%@",response);
            
            if (success) {
                
                
                if (response)
                    
                    if ([response objectForKey:@"region"]) {
                        [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:@"region"] forKey:@"userRegion"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                
                
                [[LoginModel sharedInstance] updateModelWithData:response andLoginType:@""]; // Update Login Model
                
                //                NSLog(@"%@",[LoginModel sharedInstance]);
                
                if ([[LoginModel sharedInstance] locationFound]) {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kLocationFound];
                }
                
                
                
                
                // Saving User Lat/Long
                
                if ([[response objectForKey:@"locationFound"] boolValue]) {
                    
                    NSNumber *lat = [NSNumber numberWithDouble:[[response objectForKey:@"latitude"] doubleValue]];
                    NSNumber *lon = [NSNumber numberWithDouble:[[response objectForKey:@"longitude"] doubleValue]];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:[[NSDictionary alloc] initWithObjectsAndKeys:lat,kLastLocationLatitudeKey,lon,kLastLocationLongitudeKey,nil] forKey:kUserLastLocationKey];
                    //  @{kLastLocationLatitudeKey:lat,kLastLocationLongitudeKey:lon} forKey:kUserLastLocationKey];
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kLocationNeedsToBeUpdatedOnServer];
                    
                }
                
                
                // Saving user confirmed if YES
                
                BOOL alreadyRegistered = [[response objectForKey:@"confirmed"] boolValue];
                [[NSUserDefaults standardUserDefaults] setBool:alreadyRegistered forKey:kUserAlreadyRegistered];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                
                if (![[response objectForKey:kOnBoardingPassed] boolValue]) {
                    
                    [[NSUserDefaults standardUserDefaults] setBool:[[response objectForKey:kOnBoardingPassed] boolValue] forKey:kUserAlreadyRegistered];
                    
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
                
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kProfileHidingPreference];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kIsUpdateVersion2_1];
                
                if ([response objectForKey:kWooEncryptionTokenFromServer]) {
                    [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:kWooEncryptionTokenFromServer]
                                                              forKey:kWooEncryptionTokenFromServer];
                }
                
                
                
                // Check if last user loggedIn & current user are same or different
                
                if ([[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]) // If saved userid exist
                    if (![[NSString stringWithFormat:@"%@",[response objectForKey:@"id"]] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]]) {
                        [APP_DELEGATE reinitialiseUserDefaultAndDatabase];
                        userChanged = YES;
                    }
                
                
                
                
                NSUserDefaults *userDefaultObj = [NSUserDefaults standardUserDefaults];
                //                NSLog(@"[userDefaultObj objectForKey:kWooUserId] :%@",[userDefaultObj objectForKey:kWooUserId]);
                [userDefaultObj setObject:[NSString stringWithFormat:@"%@",[response objectForKey:@"id"]] forKey:kWooUserId];
                [APP_Utilities myprofile].wooId = [NSString stringWithFormat:@"%@",[response objectForKey:@"id"]];
                //Make my profile call
                
                
                if (!([[APP_Utilities validString:[NSString stringWithFormat:@"%@",[response objectForKey:@"id"]]] length]>0) ||
                    [NSString stringWithFormat:@"%@",[response objectForKey:@"id"]] == NULL) {
                    return ;
                }
                
                
                [userDefaultObj setObject:[APP_Utilities validString:[NSString stringWithFormat:@"%@",[response objectForKey:@"firstName"]]] forKey:kWooUserName];
                //[userDefaultObj setObject:[APP_Utilities validString:[NSString stringWithFormat:@"%@",fbId]] forKey:kFacebookNumbericUserID];
                [userDefaultObj setObject:[APP_Utilities validString:[NSString stringWithFormat:@"%@",[response objectForKey:@"profilePicUrl"]]] forKey:kWooProfilePicURL];
                [APP_Utilities precacheDiscoverImagesWithData:[NSArray arrayWithObject:[APP_Utilities validString:[NSString stringWithFormat:@"%@",[response objectForKey:@"profilePicUrl"]]]]];
                [userDefaultObj setObject:[response objectForKey:kProfileCompletenessScoreKey] forKey:kProfileCompletenessScoreKey];
                
                [userDefaultObj setObject:[response objectForKey:kGenderKey] forKey:kWooUserGender];
                [userDefaultObj setObject:[NSDate date] forKey:kWooLoggedInTime];
                
                
                [userDefaultObj synchronize];
                
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInSuccessfullyNotification object:nil];
                [APP_DELEGATE sendSwrveEventWithEvent:@"FBLogin.Success" andScreen:@"FBLogin"];
                [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"Success" forScreenName:@"Login"];
                [APP_DELEGATE sendFCMPushTokenToServer];
                // [APP_DELEGATE connectToLayer];
                [APP_DELEGATE trackVoIPInvites];
                if (![[response objectForKey:@"gender"] isEqualToString:@"UNKNOWN"]){
                    [[AppLaunchApiClass sharedManager] getNotificationConfigOptionsWithCompletionBlock:nil];
                }
                NSString *url = [[NSUserDefaults standardUserDefaults]objectForKey:kWooProfilePicURL];
                 
                 NSString *imageURL = nil;
                 
                 if([[APP_Utilities validString:url] length]>0){
                 imageURL = [NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(100),IMAGE_SIZE_FOR_POINTS(100), [APP_Utilities encodeFromPercentEscapeString:url]];
                 }
           }
            else{
                //Error handling
                
            }
            
            regBlock(success , response , statusCode , userChanged);
            
        }
        
        }  shouldReachServerThroughQueue:TRUE];
}



@end
