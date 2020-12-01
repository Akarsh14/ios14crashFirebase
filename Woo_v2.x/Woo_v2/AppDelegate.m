//
//
//  AppDelegate.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 18/05/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "AppDelegate.h"
#import "UNetworkReachability.h"
#import "MyAnswers.h"
#import "TemplateQuestions.h"
#import "TopNotificationView.h"
#import "AppSessionManager.h"
#import "ACTReporter.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <GooglePlaces/GooglePlaces.h>
#import "TopChatView.h"
#import "LayerManager.h"
#import "MMDrawerController.h"
#import "Woo_v2-Swift.h"
#import "TagsModel.h"
#import "InAppPurchaseManager.h"
#import "WooPlusModel.h"
#import "CrushesDashboard.h"
#import "MeDashboard.h"

@import FirebaseUI;
@import FirebaseAuth;
@import GooglePlaces;
@import Firebase;
@import FirebaseDynamicLinks;
#import "AgoraConnectionManager.h"
#import <AVFoundation/AVFoundation.h>
#import "Mixpanel/Mixpanel.h"
#import <TrueSDK/TrueSDK.h>
#import "ApplozicChatManager.h"
#import "ALReachability.h"

#define DISCOVER_TEST 1
static bool hasAddObserver=NO;
@interface AppDelegate ()<ApplozicUpdatesDelegate, AppsFlyerTrackerDelegate>

@end

@implementation AppDelegate

#pragma mark - Refresh Receipt Delegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"app launched with state %ld",(long)application.applicationState);
    [AppSessionManager sharedManager];
    isFetchingMatchDataFromServer = FALSE;
   
    
    [NSNotificationCenter.defaultCenter addObserverForName:@"showAlertOnDiscover"
                                                    object:nil
                                                     queue:nil
                                                usingBlock:^(NSNotification *note)
    {
        
        NSDictionary* userInfo = note.userInfo;
        NSLog(@"hello %@",userInfo[@"imageURL"]);
        
        TopChatView *chatView = [TopChatView sharedInstanceWithNotificationType:unknown];
                [chatView setNotificationTypeForView:unknown];
        
        if([userInfo[@"status"] isEqualToString:@"APPROVED"]){
            [chatView showNewChatMessageFromTop:@"Photo has been Uploaded Successfully." withHeader:@"Success!" andUserImage:userInfo[@"imageURL"]];
        }else if([userInfo[@"status"] isEqualToString:@"ALLREJECTED"]){
            [chatView showNewChatMessageFromTop:@"To encourage connections between real people, we ask that at least one of your photos has you clearly visible in it." withHeader:@"Violate our Guidelines!" andUserImage:userInfo[@"imageURL"]];
        }else if([userInfo[@"status"] isEqualToString:@"REJECTED"]){
            [chatView showNewChatMessageFromTop:@"Photo has failed to upload." withHeader:@"Unsuccessfull!" andUserImage:userInfo[@"imageURL"]];
        }
        
    }];
    
    
    //Added by Umesh to caught a crash or exception try to save data in the exception method
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    //
    _onBaordingPageNumber = ON_BOARDING_PAGE_NUMBER_NONE;
    self.onBaordingPageNumber = 0;
    
   //Pass your applicationKey
    NSLog(@"%@", kAppId_Applozic);
    _applozic = [[ApplozicClient alloc]initWithApplicationKey:kAppId_Applozic withDelegate:self];

    [self connectToApplozic];
    
    [self listenToNetworkReachability];

//    _registerUserClientService = [[ALRegisterUserClientService alloc] init];
//
//    [_registerUserClientService connect];
    
    if([ALUserDefaultsHandler isLoggedIn])
    {
        [self getLatestSyncingMessagesFromAppLozicForLaunchOptions:launchOptions forApplication:application];
    }
    
//    else{
//        [[ApplozicChatManager sharedApplozicChatManager] connectUserToApplozicWithClientObject:_applozic withAppLozicAuthBlock:^(BOOL authenticationSuccess, ApplozicClient * _Nonnull applozicClient) {
//            [self getLatestSyncingMessagesFromAppLozicForLaunchOptions:launchOptions forApplication:application];
//        }];
//    }

   // NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://a3hjs.app.goo.gl/w5Eb"]];
   // NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
//    [[AppSessionManager sharedManager] getCookieFromRefferalUrl];
    
    
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    NSData *decodedObject = [userDefault objectForKey: @"MyProfileModel"];
    if (decodedObject) {
        _oMyProfileModel = [NSKeyedUnarchiver unarchiveObjectWithData: decodedObject];
    }
    else{
        _oMyProfileModel = [[UserProfileModel alloc] init];
    }
    
#ifdef TESTURL
    NSLog(@">>>>>>>>>>>>>>>>>YES");
#else
    NSLog(@">>>>>>>>>>>>>>>>>NO");
#endif
    
//    [GMSServices provideAPIKey:kGoogleAPIKey];
    [GMSPlacesClient provideAPIKey:kGoogleAPIKey];
    if ([[NSUserDefaults standardUserDefaults] doubleForKey:kfirstTimeAppLaunchesOnDevice] == 0) {
        [[NSUserDefaults standardUserDefaults] setDouble:[[NSDate date] timeIntervalSince1970] forKey:kfirstTimeAppLaunchesOnDevice];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init]
                                      forBarPosition:UIBarPositionAny
                                          barMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    
    if (!self.store) {
        self.store = [Store sharedInstance];//[[Store alloc]init];
    }
    
    [self migrateDataOnUpdate];
    
    
    [self createAudioFolderIfNotExists];
    [self createImageFolderIfNotExists];
    
//    [self fetchNewNotifications];

    [self addNotificationObservers];
    
    [self fetchTemplateQuestions];
    [UIApplication sharedApplication].applicationIconBadgeNumber=0;

    
//----------------- Appsflyer starts here
    
    [AppsFlyerTracker sharedTracker].appsFlyerDevKey = @"XQVMQypA38hBCAHfHUzfZY";
    [AppsFlyerTracker sharedTracker].appleAppID = @"885397079";
     [AppsFlyerTracker sharedTracker].delegate = self;
    
//----------------- Appsflyer ends here
    
  //  [APP_Utilities getPushNotificationPermission];
    
////----------------- Swrve starts here
//    [self initializeSwrveWithLaunchOption:launchOptions];
////----------------- Swrve ends here
    
    
//--------------------GA Starts here
    
    // Enabling Firebase for woo
    [FIRApp configure];

    [self initializeGoogleAnalytics];
    [self initializeConversionTrackingSDK];
    
    [self setupRemoteConfig];
    [self fetchRemoteConfig];
    
//--------------------GA Ends here
    
//--------------------------------- Initialising crashalytics ------------------
    [Fabric with:@[[Crashlytics class]]];
    [[Crashlytics sharedInstance]setUserIdentifier:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];

    [Mixpanel sharedInstanceWithToken:@"29b0f02f3fc0e36e430a5e510ac1bea0"];

//------------------------------------------------------------------------------
    [self makeAppsflyerAppLaunchCall];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    [self sendEventToGoogleAnalyticsForEvent:@"AppLaunch" forScreenName:@""];
    [self sendSwrveEventWithEvent:@"AppLaunch.AppLaunchScreen.UserAppOpen" andScreen:@"AppLaunchScreen"];
    
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationUserDidTakeScreenshotNotification
                                                      object:nil
                                                       queue:mainQueue
                                                  usingBlock:^(NSNotification *note) {
                                                      // executes after screenshot
                                                      [self notifyGAIfUserHasTakenAScreenshot];
                                                  }];
    /**
     *  Added this method to clear any temporary changes in settings
     */
    [self clearTemporarySettingsDefault];
    
    [self detectNetworkTypeAndUpdateImageDownloaderNotification];
    
    WooScreenManager *screenManager = [WooScreenManager sharedInstance];
    if (screenManager.drawerController) {
        [screenManager configureDrawerController];
    }
        
    
    /**
     *  REMOVE THIS CODE THIS IS FOR TESTING ONLY
     */
   // [[TagsModel sharedInstance] addTemporaryTagsDetails];
    [[TagsModel sharedInstance] addAllTags];
    [self inAppPurchaseRestore];
    
    
    /*************************** FIREBASE SECTION ******************************/
    
    [FIROptions defaultOptions].deepLinkURLScheme = @"com.u2opiamobile.wooapp";

    // Add observer for InstanceID token refresh callback.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenRefreshNotification:) name:kFIRInstanceIDTokenRefreshNotification object:nil];
    
    /****************************************************************************/
    
    if(launchOptions){
        NSDictionary *userActivityDictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsUserActivityDictionaryKey];
        
        if (userActivityDictionary) {
            [userActivityDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[NSUserActivity class]]) {
                    NSUserActivity *userActivity = obj;
                    // This is the case when in deep link we are getting a URL from server
                    if(userActivity && userActivity.webpageURL){
                        NSString *url = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)[NSString stringWithFormat:@"%@",userActivity.webpageURL], CFSTR(""), kCFStringEncodingUTF8);
                        if(url){
                            NSArray *urlComponents = [url componentsSeparatedByString:@"&"];
                            NSLog(@"urlcomponents == %@",urlComponents);
                            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                            for (NSString *keyValuePair in urlComponents)
                            {
                                NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
                                NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
                                NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
                                NSLog(@" keyValuePair ==== %@",keyValuePair);
                                NSLog(@"1 key for Deeplink ==== %@",key);
                               
                                
                                if(key && [key isEqualToString:@"af_dp"]){
                                   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                       if ([keyValuePair containsString:@"www.wooapp.com"]) {
                                           //purchase string hai
                                           [self handleDeepLinkWithURL:url withSourceApplication:application];
                                       }
                                       else{
                                           //me scetion screen hai
                                           [self handleDeepLinkWithURL:value withSourceApplication:application];
                                       }
                                       
                                    });
                                    break;
                                }
                                else if([key isEqualToString:@"utm_campaign"] || [key isEqualToString:@"utm_source"] || [key isEqualToString:@"utm_medium"] || [key isEqualToString:@"utm_term"] || [key isEqualToString:@"utm_content"] || [key isEqualToString:@"ius"])
                                    {
                                        [params setObject:value forKey:key];
                                    }
    
                            }
                            //Rdirect acc to utmparams
                            [self redirectAccordingToUTMParms:params];
                        }
                    }
                    
                }
            }];
        }else{
            NSURL *url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
            NSString *sourceApplication = [launchOptions objectForKey:UIApplicationLaunchOptionsSourceApplicationKey];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self application:application openURL:url sourceApplication:sourceApplication annotation:[NSNull null]];
            });
        }
        
    }
     [[Crashlytics sharedInstance]setUserIdentifier:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
    NSLog(@"The user ID is %@", [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]);
    __weak AppDelegate *weakSelf = self;
    self.callCenter.callEventHandler = ^(CTCall* call) {
        // anounce that we've had a state change in our call center
        //NSLog(@"self.callcenter.curentcalls %lu",weakSelf.callCenter.currentCalls.count);
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:call.callState,@"callState",weakSelf.callCenter.currentCalls,@"currentCallsSet",nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CTCallStateDidChange" object:nil userInfo:dict];
    };
    
    //    [self testCode:application];
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
        if([[TCTrueSDK sharedManager] isSupported])
        {
            [[TCTrueSDK sharedManager] setupWithAppKey:@"TfJzGb7c09a9f61714659b9686ea7c1647025" appLink:@"https://siafca45adb2514a6f85674c12009ea30c.truecallerdevs.com"];
        }
    
    [self listenToNetworkReachability];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:)
                                                 name:AL_kReachabilityChangedNotification object:nil];
    
    
    
    return YES;
    
    
}



-(void) setupRemoteConfig {
    
    NSDictionary *defaultValues = @{
        @"API_SERVER_LIVE_LOGIN_iOS":   [[[NSBundle mainBundle] infoDictionary]                                             objectForKey:@"API_BASE_URL"],
        @"API_SERVER_LIVE_iOS":         [[[NSBundle mainBundle] infoDictionary]                                             objectForKey:@"API_BASE_URL"],
        @"INDIA_LOGIN_METHOD_NEW_iOS" :     @"FIREBASE_LOGIN"
    };
    
    [[FIRRemoteConfig remoteConfig] setDefaults:defaultValues];
    
    [self indianLoginMethodFlow];
    
    if([APP_Utilities isIndianUser]){
        
        #ifdef DEBUG
              [[NSUserDefaults standardUserDefaults] setObject:[defaultValues objectForKey:@"API_SERVER_LIVE_LOGIN_iOS"] forKey:@"API_SERVER_LIVE_LOGIN_iOS"];
        #else
              [[NSUserDefaults standardUserDefaults] setObject:kIndianProdLoginUrl forKey:@"API_SERVER_LIVE_LOGIN_iOS"];
        
//        [[NSUserDefaults standardUserDefaults] setObject:[defaultValues objectForKey:@"API_SERVER_LIVE_LOGIN_iOS"] forKey:@"API_SERVER_LIVE_LOGIN_iOS"];
        #endif
        
        [[NSUserDefaults standardUserDefaults] setObject:[defaultValues objectForKey:@"API_SERVER_LIVE_iOS"] forKey:@"API_SERVER_LIVE_iOS"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }else{
        [self updateBaseURLs];
    }
}

-(void) indianLoginMethodFlow {
    
    FIRRemoteConfig *rc = [FIRRemoteConfig remoteConfig];
    
    NSString *indianLoginMethod = [[rc configValueForKey:@"INDIA_LOGIN_METHOD_NEW_iOS"] stringValue];
    
    [[NSUserDefaults standardUserDefaults] setObject:indianLoginMethod forKey:@"INDIA_LOGIN_METHOD_NEW_iOS"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(void) enableDeveloperMode {
    FIRRemoteConfigSettings *devModeSettings = [[FIRRemoteConfigSettings alloc] initWithDeveloperModeEnabled:YES];
    [FIRRemoteConfig remoteConfig].configSettings = devModeSettings;
}


-(void) updateBaseURLs {
    
    #ifdef DEBUG
        [[NSUserDefaults standardUserDefaults] setObject:[[[NSBundle mainBundle] infoDictionary]                                             objectForKey:@"API_BASE_URL"] forKey:@"API_SERVER_LIVE_LOGIN_iOS"];
        [[NSUserDefaults standardUserDefaults] setObject:[[[NSBundle mainBundle] infoDictionary]                                             objectForKey:@"API_BASE_URL"] forKey:@"API_SERVER_LIVE_iOS"];
    
        [[NSUserDefaults standardUserDefaults] synchronize];
    #else
    
            FIRRemoteConfig *rc = [FIRRemoteConfig remoteConfig];
            if([APP_Utilities isIndianUser]){
                
                [[NSUserDefaults standardUserDefaults] setObject:kIndianProdLoginUrl forKey:@"API_SERVER_LIVE_LOGIN_iOS"];
                [[NSUserDefaults standardUserDefaults] setObject:[[[NSBundle mainBundle] infoDictionary]                                             objectForKey:@"API_BASE_URL"] forKey:@"API_SERVER_LIVE_iOS"];
                
                
//                [[NSUserDefaults standardUserDefaults] setObject:[[[NSBundle mainBundle] infoDictionary]                                             objectForKey:@"API_BASE_URL"] forKey:@"API_SERVER_LIVE_LOGIN_iOS"];
//                [[NSUserDefaults standardUserDefaults] setObject:[[[NSBundle mainBundle] infoDictionary]                                             objectForKey:@"API_BASE_URL"] forKey:@"API_SERVER_LIVE_iOS"];
                
                    [[NSUserDefaults standardUserDefaults] synchronize];
                
            }else{
                    
                    NSString *apiServerLiveLoginIos = [[rc configValueForKey:@"API_SERVER_LIVE_LOGIN_iOS"] stringValue];

                    [[NSUserDefaults standardUserDefaults] setObject:apiServerLiveLoginIos forKey:@"API_SERVER_LIVE_LOGIN_iOS"];

                    NSString *apiServerLiveIos = [[rc configValueForKey:@"API_SERVER_LIVE_iOS"] stringValue];

                    [[NSUserDefaults standardUserDefaults] setObject:apiServerLiveIos forKey:@"API_SERVER_LIVE_iOS"];
                
                
//                [[NSUserDefaults standardUserDefaults] setObject:[[[NSBundle mainBundle] infoDictionary]                                             objectForKey:@"API_BASE_URL"] forKey:@"API_SERVER_LIVE_LOGIN_iOS"];
//                [[NSUserDefaults standardUserDefaults] setObject:[[[NSBundle mainBundle] infoDictionary]                                             objectForKey:@"API_BASE_URL"] forKey:@"API_SERVER_LIVE_iOS"];
                
                    [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[Utilities sharedUtility] sendMixPanelEventWithName:@"DynamicUrls_Retrieved_firebase_RemoteConfig_iOS"];
                
            }
        
    #endif
    
}

-(void) fetchRemoteConfig {
    
    NSTimeInterval expirationTime;
    
#ifdef DEBUG
    expirationTime = 0.0;
    [self enableDeveloperMode];
#else
    expirationTime = 43200;
#endif
    
    [[FIRRemoteConfig remoteConfig] fetchWithExpirationDuration:expirationTime completionHandler:^(FIRRemoteConfigFetchStatus status, NSError * _Nullable error) {
        if(error == nil){
            
            NSLog(@"Horray%ld",(long)status);
            
            [[FIRRemoteConfig remoteConfig] activateFetched];
            [self updateBaseURLs];
            [self indianLoginMethodFlow];
            
        }else{
            NSLog(@"%@", error.localizedDescription);

        }
    }];
}


-(void)alertShowing:(NSString *)Title messageString: (NSString *)MessageString{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:Title message:MessageString preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    [topController presentViewController:alertController animated:YES completion:nil];

}


-(void)firebaseInitiation:(NSNotification *)notificationInstance{
    
    NSLog(@"%@",notificationInstance);
    
    NSDictionary* userInfo = notificationInstance.userInfo;
    firebasePhoneAuthenticationfromWhichScreen = (NSString*)userInfo[@"screen"];
    
    NSLog (@"Successfully received test notification! %@", firebasePhoneAuthenticationfromWhichScreen);
    
    
    //Firebase UI Auth declared by akarsh
       [FUIAuth defaultAuthUI].delegate = self;
       FUIPhoneAuth *phoneProvider = [[FUIPhoneAuth alloc] initWithAuthUI:[FUIAuth defaultAuthUI]];
       [FUIAuth defaultAuthUI].providers = @[phoneProvider];
    
    UINavigationController *currentNavigationController = [[[[WooScreenManager sharedInstance] oHomeViewController] childViewControllers] objectAtIndex:2];
    
//    currentNavigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [phoneProvider signInWithPresentingViewController:currentNavigationController phoneNumber:nil];
}

- (void)authUI:(FUIAuth *)authUI
    didSignInWithAuthDataResult:(nullable FIRAuthDataResult *)authDataResult
         error:(nullable NSError *)error {
    
    if(error == nil){
        
        NSLog(@"user login successfully");
        NSLog(@"%@",authDataResult.user.refreshToken);
        
        FIRUser *user = authDataResult.user;
        
        [user getIDTokenWithCompletion:^(NSString * _Nullable token, NSError * _Nullable error) {
            NSLog(@"%@",token);
            [self makeServerCallForFirebaseAuthentication:token];
        }];
        
    }else{
        NSLog(@"%@", error.localizedDescription);
    }
    
}


-(void)makeServerCallForFirebaseAuthentication:(NSString *)accessToken{
    NSLog(@"%@", accessToken);
    
    NSString *userWooID = [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId];
    NSString *countryCode = [[NSUserDefaults standardUserDefaults]
                             stringForKey:@"kCountyCodeForFIrebasePhoneAuthentication"];
    
    
    NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:userWooID,@"wooId",countryCode,@"countryCode",accessToken,@"access_token",@"FIREBASE",@"verificationMode",nil];
    
    NSMutableDictionary *mutableParams = [[NSMutableDictionary alloc] initWithDictionary:params];

            NSLog(@"params>>>>>>>:%@",params);

    NSString *deviceDataCall = [NSString stringWithFormat:@"%@%@?wooId=%@&verificationMode=FIREBASE&countryCode=%@&access_token=%@",kBaseURLV4,kVerifyPhoneNumber,userWooID,countryCode,accessToken];
            NSLog(@"URL FOR POSTING DATA %@",deviceDataCall);
            WooRequest *wooRequestObj = [[WooRequest alloc]init];
            wooRequestObj.url =deviceDataCall;
            wooRequestObj.time =0;
            wooRequestObj.methodType =postRequest;
            wooRequestObj.numberOfRetries =0;
            wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
            wooRequestObj.requestType = sendUserDeviceIdToSever;
            wooRequestObj.isJsonContentType = true;
            [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType){
                
                    if (success)
                    {
                        NSDictionary* userInfo = @{@"statusCode":[NSNumber numberWithInt:statusCode]};
                        [[DiscoverProfileCollection sharedInstance] updateMyProfileData:response];
                        
                        if([self->firebasePhoneAuthenticationfromWhichScreen isEqualToString:@"WizardPhoneVerifyController"]){
                            
                            
                            [[Utilities sharedUtility] sendMixPanelEventWithName:@"Firebase_Login_through_WizardScreen_iOS"];
                            
                            [[NSNotificationCenter defaultCenter]postNotificationName:@"kGetResultFromFirebaseAuthenticationForWizardScreen" object:nil userInfo:userInfo];
                            
                        }else{
                            
                            [[Utilities sharedUtility] sendMixPanelEventWithName:@"Firebase_Login_through_EditProfileScreen_iOS"];
                            
                            [[NSNotificationCenter defaultCenter]postNotificationName:kGetResultFromFirebaseAuthenticationObserver object:nil userInfo:userInfo];
                        }
                        
                    }
                    else
                    {
                        NSLog(@"Edit Profile ERROR %@",error);
                        // Display you error NSError object
                    }
            } shouldReachServerThroughQueue:TRUE];
}


-(void)getLatestSyncingMessagesFromAppLozicForLaunchOptions:(NSDictionary *)launchOptions forApplication:(UIApplication *)application{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ALMessageService getLatestMessageForUser:[ALUserDefaultsHandler getDeviceKeyString] withCompletion:^(NSMutableArray *messageArray, NSError *error) {
            
            if(error)
            {
                ALSLog(ALLoggerSeverityError, @"ERROR IN LATEST MSG APNs CLASS : %@",error);
            }else{
                NSLog(@"New Messages received %@", messageArray);
                if(messageArray && [messageArray count]>0){
                    for(ALMessage *message in messageArray){
                        [[ApplozicChatManager sharedApplozicChatManager] onMessageReceived:message];
                    }
                }
            }
        }];
    });
    
    if (launchOptions != nil)
    {
        NSDictionary *dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (dictionary != nil)
        {
            NSLog(@"Launched from push notification: %@", dictionary);
            [_applozic notificationArrivedToApplication:application withDictionary:dictionary];
            
        }
    }
}

-(void)redirectAccordingToUTMParms:(NSDictionary *)params
{
    //
    if([params.allKeys count] >0)
    {
        NSLog(@"UTM Params : %@",params);
        if([params objectForKey:@"utm_campaign"])
        {
            if([[params objectForKey:@"utm_campaign"] isEqualToString:@"Visitor_mail"])
            {
                [self sendFirebaseEvent:@"Email_visitor" andScreen:@""];
            }
            else if([[params objectForKey:@"utm_campaign"] isEqualToString:@"Liked_mail"])
            {
                [self sendFirebaseEvent:@"Email_liked" andScreen:@""];
            }
            else if ([[params objectForKey:@"utm_campaign"] isEqualToString:@"Welcome_mail"])
            {
                [self sendFirebaseEvent:@"Email_welcome" andScreen:@""];
            }
            
            if([params objectForKey:@"ius"] && [[APP_Utilities validString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]] length]>0)
            {
                NSLog(@"redirecting to  : %@",[params objectForKey:@"ius"]);
                [[NSUserDefaults standardUserDefaults] setObject:[params objectForKey:@"ius"] forKey:@"redirectFromUTMParams"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"redirectToUTMScreen" object:nil];
            }
            
            if([params objectForKey:@"utm_campaign"] && [[params objectForKey:@"utm_source"] isEqualToString:@"POPXO"]){
                [[NSUserDefaults standardUserDefaults] setObject:[params objectForKey:@"utm_campaign"] forKey:@"wooIdsToInclude"];
                [[NSUserDefaults standardUserDefaults] setObject:[params objectForKey:@"utm_source"] forKey:@"utm_source"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"addWooIdToDiscover" object:nil];
            }
        }
    }
}
//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
//{
//    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
//    NSDictionary *fields = [HTTPResponse allHeaderFields];
//    NSString *cookie = [fields valueForKey:@"X-True-Cache-Key"]; // It is your cookie
//}

void uncaughtExceptionHandler(NSException *exception) {
    // You code here, you app will already be unload so you can only see what went wrong.
    [APP_DELEGATE savePrivateAndMainContext];
}

#pragma mark Firebase Methods

- (void)initialiseFireBaseNotifications{
    
}

-(void)sendEventOnFirebaseWithEventDetails:(NSString*)eventName withUserProperties:(NSDictionary *)userProperties{
    [FIRAnalytics logEventWithName:eventName parameters:userProperties];
}

-(void)sendUserPropertyDetailsOnFirebasewithKeyName:(NSString*)keyName withKeyValue:(NSString*)keyValue{
    [FIRAnalytics setUserPropertyString:keyName forName:keyValue];
}


/**
 *  Taking the event of user taking a screenshot
 */

- (void)notifyGAIfUserHasTakenAScreenshot
{
    NSString *wooIdForUser = [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId];
    if (wooIdForUser) {
        [self sendEventToGoogleAnalyticsForEvent:[NSString stringWithFormat:@"%@ took Screenshot",wooIdForUser] forScreenName:@""];
    }
}

/**
 *  This method will clear temporary settings value in NSUserDefaults
 */
-(void)clearTemporarySettingsDefault{
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kGenderPreferenceEdited];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMaxDistanceEdited];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMaxAgePreferenceEdited];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMinAgePreferenceEdited];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)clearProfileVisibiltyDefault
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kProfileHidingPreferenceEdited];
    [[NSUserDefaults standardUserDefaults] synchronize];
 
}

#pragma mark SwrveMethods

-(void)initializeSwrveWithLaunchOption:(NSDictionary *)launchOptions {
/*
    
    _swreConfigObj = [[SwrveConfig alloc] init];
    _swreConfigObj.pushEnabled = YES;
    _swreConfigObj.pushNotificationEvents = nil;
    
    
    [Swrve sharedInstanceWithAppID:2819 apiKey:@"Jzf3pMkAjqVs7nbd3bAB" config:_swreConfigObj launchOptions:launchOptions];
    NSLog(@"%@",[Swrve sharedInstance].userID);
    NSString *currentSwrveUserId = [[NSUserDefaults standardUserDefaults] objectForKey:kSwrveUserId];
    if (![currentSwrveUserId isEqualToString:[Swrve sharedInstance].userID]) {
        [self sendSwrveUserIDToServer:[Swrve sharedInstance].userID];
    }

    // Tell the Swrve SDK your app was launched from a push notification
    NSDictionary * remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if (remoteNotification) {
        [[Swrve sharedInstance].talk pushNotificationReceived:remoteNotification];
    }
*/
}

- (void)sendSwrveUserIDToServer:(NSString *)swrveUserId
{/*
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]) {
        NSString *userWooID = [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId];
        
        swrveUserId = [swrveUserId stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSLog(@"swrveUserId>>>>>>> :%@",swrveUserId);
        
        NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:userWooID,@"wooId",swrveUserId,@"swrveId", nil];
//                                @{@"wooId":userWooID,
//                                 @"swrveId":swrveUserId
//                                 };
//        NSDictionary *params = @{@"wooId":userWooID
//                                 };
        
        
        NSLog(@"params>>>>>>>:%@",params);
        
        NSString *swrveUpdateURL = [NSString stringWithFormat:@"%@%@",kBaseURLV1,kSwrveUpdateCall];
        NSLog(@"URL FOR POSTING DATA %@",swrveUpdateURL);
        WooRequest *wooRequestObj = [[WooRequest alloc]init];
        wooRequestObj.url =swrveUpdateURL;
        wooRequestObj.time =900;
        wooRequestObj.requestParams =params;
        wooRequestObj.methodType =postRequest;
        wooRequestObj.numberOfRetries =3;
        wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
        wooRequestObj.requestType = sendSwrveUserIDToServer;
        
        [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType){
            
            if (requestType == sendSwrveUserIDToServer) {
                if (success)
                {
                    // Use your response NSDictionary object
                    NSLog(@"Swrve POSTED ON SERVER");
                    if (![[NSUserDefaults standardUserDefaults] objectForKey:kSwrveUserId]) {
                        [[NSUserDefaults standardUserDefaults]setObject:swrveUserId forKey:kSwrveUserId];
                        [[NSUserDefaults standardUserDefaults]synchronize];
                    }
                }
                else
                {
                    NSLog(@"Swrve ERROR %@",error);
                    // Display you error NSError object
                }
            }
        } shouldReachServerThroughQueue:TRUE];
    }
 */
}

#pragma mark GoogleAnalyticsMethods
-(void)initializeGoogleAnalytics{
    
    [[GAI sharedInstance] setTrackUncaughtExceptions:YES];
    [[GAI sharedInstance] setDispatchInterval:30];
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelNone];
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-51372217-1"];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kWooUserGender]) {
        NSString *genderDimensionValue = [[NSUserDefaults standardUserDefaults]  objectForKey:kWooUserGender];
        [tracker set:[GAIFields customDimensionForIndex:2] value:genderDimensionValue];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kAgeFromServer]) {
        NSString *ageDimensionValue = [[NSUserDefaults standardUserDefaults] objectForKey:kAgeFromServer];
        [tracker set:[GAIFields customDimensionForIndex:1] value:ageDimensionValue];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]) {
        NSString *wooIdDimensionValue = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
        [tracker set:[GAIFields customDimensionForIndex:4] value:wooIdDimensionValue];
    }
}

-(void)initializeConversionTrackingSDK{
    // Woo-App-Install-IOS
    // Google iOS Download tracking snippet
    // To track downloads of your app, add this snippet to your
    // application delegate's application:didFinishLaunchingWithOptions: method.
    [ACTConversionReporter reportWithConversionID:@"973174064" label:@"070wCLWj41YQsOqF0AM" value:@"0.00" isRepeatable:NO];

//    [ACTConversionReporter reportWithConversionID:@"973174064" label:@"l5YICP79x1YQsOqF0AM" value:@"0.00" isRepeatable:NO];
}

-(void)sendEventToGoogleAnalyticsForEvent:(NSString *)event forScreenName:(NSString *)screenCode{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    //NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId];
    //userID = [APP_Utilities validString:userID];
    
    NSString *trackPageName;
    
    trackPageName = [NSString stringWithFormat:@"\%@",event];
    
    [tracker set:kGAIScreenName value:screenCode];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:trackPageName     // Event category (required)
                                                          action:event            // Event action (required)
                                                           label:nil          // Event label
                                                           value:nil] build]];    // Event value
}




- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    int messageCharLimit = 250;
    if ((([textView.text length] + text.length) > messageCharLimit) && [text length]>0) {
        return FALSE;
    }
    
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView{
    
    int messageCharLimit = 250;
    NSString *finalString = @"";
    
    if (textView.text.length> 0) {
        [placeholderLabel setHidden:YES];
        [feedbackAlertViewObj enableRightButton];
        
    }else{
        [placeholderLabel setHidden:NO];
        [feedbackAlertViewObj DisableRightButton];
    }
    
    [charaterLimitLbl setText:[NSString stringWithFormat:@"%lu",messageCharLimit-[textView.text length]]];
    
    NSLog(@"length = %lu",(unsigned long)[[APP_Utilities validString:finalString] length]);
    
    
}


-(void)feedBackAlertButtonTapped:(NSString *)buttonTappedIndex{
    
    if ([buttonTappedIndex intValue] == 1) {
        
        if ([[feedbackTextviewObj.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] < 1) {
            
            SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"Please enter some text.", @"expty feedback toast text"));
            return;
        }
        
        SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"CMP00320",nil));
        
        if ([feedbackTextviewObj.text length]>0) {
            
            AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
            BOOL isNetworkReachable = (reachability.isReachable || reachability.isReachableViaWiFi || reachability.isReachableViaWWAN);
            if (!isNetworkReachable) {
                //        [APP_Utilities displayAlertWithTitle:NSLocalizedString(@"Oops!", nil) message:NSLocalizedString(@"No internet connection! Please try again.", nil) withDelegate:self];
                
                SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"Please check your internet connection",nil));
                return;
            }

            
            
            
            
            NSString *urlString = [NSString stringWithFormat:@"%@%@?wooId=%@&feedBackText=%@",kBaseURLV2, kUserFeedback, [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],[feedbackTextviewObj.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            WooRequest *wooRequestObj = [[WooRequest alloc]init];
            wooRequestObj.url =urlString;
            wooRequestObj.time =900;
            wooRequestObj.requestParams =nil;
            wooRequestObj.methodType =postRequest;
            wooRequestObj.numberOfRetries =3;
            wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
            wooRequestObj.requestType = userFeedback;
            
            [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
                
                if (statusCode==401 || statusCode==402 || statusCode==500) {
                    //                    [self handleErrorForResponseCode:statusCode];
                }
                if (error) {
                    //                    [ALToastView toastInView:APP_DELEGATE.window withText:@"Unable to sent feedback."];
                }
                if (requestType == userFeedback && statusCode==200) {
                    
                    //                    [ALToastView toastInView:APP_DELEGATE.window withText:@"Feedback sent successfully."];
                }
            }   shouldReachServerThroughQueue:TRUE];
            [feedbackAlertViewObj removeFromSuperview];
        }
    }else{
        [feedbackAlertViewObj removeFromSuperview];
    }
}


-(void)addNotificationObservers{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchTemplateQuestions)
                                                 name:kUserLoggedInSuccessfullyNotification object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchNewNotifications)
//                                                 name:kUserLoggedInSuccessfullyNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeAppsflyerUserLoginCall)
                                                 name:kUserLoggedInSuccessfullyNotification object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:[AppSessionManager sharedManager]
//                                             selector:@selector(makeAppLaunchCallToServer)
//                                                 name:kUserLoggedInSuccessfullyNotification object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:[AppSessionManager sharedManager]
//                                             selector:@selector(getVisitorFromServer)
//                                                 name:kUserLoggedInSuccessfullyNotification object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
    selector:@selector(firebaseInitiation:) name:kFirebasePhoneAuthenticationObserver object:nil];
    
////    [[NSNotificationCenter defaultCenter] addObserver:self
//       selector:@selector(firebaseInitiation:) name:kFirebasePhoneAuthenticationObserver object:nil];
}

-(void)handleDeepLinkWithURL:(NSString *)url withSourceApplication:(UIApplication *)application{
    NSLog(@"url === :%@",url);
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    NSString *resultingStr = [url stringByReplacingOccurrencesOfString:@"wooapp://" withString:@""];
    NSArray *notificationTypeStringArray = [resultingStr componentsSeparatedByString:@"?"];
    NSString *firstObject = [notificationTypeStringArray firstObject];
    NotificationType notificationTypeObj = [APP_Utilities getNotificationTypeFor:firstObject];
    if ((notificationTypeObj != unknown) && ([APP_Utilities getNotificationTypeFor:resultingStr] == unknown)) {
        resultingStr = firstObject;
    }
    
    // check here for purchase and if available over write everything
    
    if ([url length] > 0) {
        NSString *purchaseURL = [url stringByReplacingOccurrencesOfString:@"wooapp://" withString:@""];

        NSArray *urlComponents = [purchaseURL componentsSeparatedByString:@"&"];
        NSLog(@"urlComponents ===  :%@",urlComponents);
        
//        NSString *resultingStr = [url stringByReplacingOccurrencesOfString:@"wooapp://" withString:@""];
        
        if ([urlComponents count] > 1) {
            // it will contain af_dp value that will give payment option
            
            for (NSString *keyValuePair in urlComponents)
            {
                NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
                NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
                NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
                if(key && [key isEqualToString:@"af_dp"]){
                    [dict setObject:value forKey:@"purchasePlanId"];
                    NSString *purchaseTypeStr = [keyValuePair stringByReplacingOccurrencesOfString:@"af_dp=http://www.wooapp.com/" withString:@""];
                    NSArray *midArray = [purchaseTypeStr componentsSeparatedByString:@"/"];
                    if ([midArray count] > 0) {
                        resultingStr = [midArray firstObject];
                    }
                    break;
                }
            }
        }
    }
    
    
    
        if (!([resultingStr length] == 0)) {
        [dict setObject:resultingStr forKey:@"TYPE"];
        
        if (!notifManager)
            notifManager = [[NotificationManager alloc]init];
        if(![resultingStr.lowercaseString containsString:@"is_weak_match"])
        {
            [notifManager openScreenForNotificationName:kDeepLiking WithApplication:application withNotificationData:dict];
        }
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    [[AppsFlyerTracker sharedTracker] handleOpenURL:url sourceApplication:sourceApplication withAnnotation:annotation];
    return YES;
    BOOL wasHandled = NO;
    NSLog(@"url == :%@",url);
    NSLog(@"sourceApplication === %@",sourceApplication);
    // if ([url.scheme isEqualToString:@"myapp"])
    if ([[url absoluteString] containsString:@"wooapp://"]){ // For DeepLinking
        [self handleDeepLinkWithURL:[url absoluteString] withSourceApplication:application];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self handleDeepLinkWithURL:[url absoluteString] withSourceApplication:application];
//        });
//        [self handleDeepLinkWithURL:[url absoluteString] withSourceApplication:application];
    }else{ // For Facebook
      //  wasHandled  = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
        
        wasHandled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                      openURL:url
                                                            sourceApplication:sourceApplication
                                                                 annotation:annotation];

    }

    NSLog(@"DYNAMIC LINK for open url:%@",url.absoluteString);
    NSLog(@"DYNAMIC LINK url:%@",url);
    
    FIRDynamicLink *dynamicLink =
    [[FIRDynamicLinks dynamicLinks] dynamicLinkFromCustomSchemeURL:url];
    if (dynamicLink) {
        NSLog(@"============DYNAMIC LINK================");
        NSLog(@"DYNAMIC LINK: %@",dynamicLink.url);
        return YES;
    }
    
    return wasHandled;
}

//- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options NS_AVAILABLE_IOS(9_0);

-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    [[AppsFlyerTracker sharedTracker] handleOpenUrl:url options:options];
    
    BOOL wasHandled = NO;
    NSLog(@"1url == :%@",url);
    
    NSString *decodedString = [url.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *resultingStr = [decodedString stringByReplacingOccurrencesOfString:@"com.u2opiamobile.wooapp://google/link/?" withString:@""];
    NSArray *urlComponents = [resultingStr componentsSeparatedByString:@"&"];
    NSLog(@"urlComponents ===  :%@",urlComponents);
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *keyValuePair in urlComponents)
    {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
        NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
        
        if([key isEqualToString:@"utm_campaign"] || [key isEqualToString:@"utm_source"] || [key isEqualToString:@"utm_medium"] || [key isEqualToString:@"utm_term"] || [key isEqualToString:@"utm_content"])
        {
            [params setObject:value forKey:key];
            
        }
        
    }
    
    
    if([params.allKeys count] >0)
    {
        if([params objectForKey:@"utm_campaign"])
        {
            if([[params objectForKey:@"utm_campaign"] isEqualToString:@"Visitor_mail"])
            {
                [self sendFirebaseEvent:@"Email_visitor" andScreen:@""];
            }
            else if([[params objectForKey:@"utm_campaign"] isEqualToString:@"Liked_mail"])
            {
                [self sendFirebaseEvent:@"Email_liked" andScreen:@""];
            }
            else if ([[params objectForKey:@"utm_campaign"] isEqualToString:@"Welcome_mail"])
            {
                [self sendFirebaseEvent:@"Email_welcome" andScreen:@""];
            }
        }
        
        if([params objectForKey:@"utm_medium"]){
         [[NSUserDefaults standardUserDefaults] setObject:[params objectForKey:@"utm_medium"]  forKey:@"utmMedium"];
        }
        
        if([params objectForKey:@"utmContent"]){
            [[NSUserDefaults standardUserDefaults] setObject:[params objectForKey:@"utm_content"]  forKey:@"utmContent"];
        }
        [[NSUserDefaults standardUserDefaults] setObject:params forKey:kVoIPInviteParams];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
/////////////////////////////////////////////////////////////////////////////////////////////
    // if ([url.scheme isEqualToString:@"myapp"])
    if ([[url absoluteString] containsString:@"wooapp://"]){ // For DeepLinking
        [self handleDeepLinkWithURL:[url absoluteString] withSourceApplication:app];
        //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //            [self handleDeepLinkWithURL:[url absoluteString] withSourceApplication:application];
        //        });
        //        [self handleDeepLinkWithURL:[url absoluteString] withSourceApplication:application];
    }else{ // For Facebook
        //  wasHandled  = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
        NSString *sourceApplication = [options objectForKey:UIApplicationOpenURLOptionsSourceApplicationKey];
//        NSLog(@"1sourceApplication === %@",sourceApplication);
        wasHandled = [[FBSDKApplicationDelegate sharedInstance] application:app
                                                                    openURL:url
                                                          sourceApplication:sourceApplication
                                                                 annotation:[options objectForKey:UIApplicationOpenURLOptionsAnnotationKey]];
        
    }
    
    FIRDynamicLink *dynamicLink =
    [[FIRDynamicLinks dynamicLinks] dynamicLinkFromCustomSchemeURL:url];
    
    if (dynamicLink) {
        NSLog(@"============DYNAMIC LINK================");
        NSLog(@"DYNAMIC LINK: %@",dynamicLink.url);
        return YES;
    }
    
    return wasHandled;
}


-(void)trackVoIPInvites
{
    NSString *getIdentifyTokenForNonce = [NSString stringWithFormat:@"%@%@?wooId=%@",kBaseURLV1,kTrackVoIPInvite,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
    
    NSDictionary *paramsDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:kVoIPInviteParams];
    for (NSString *key in  [paramsDictionary allKeys])
    {
        getIdentifyTokenForNonce = [getIdentifyTokenForNonce stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",key,[paramsDictionary objectForKey:key]]];
    }

    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =getIdentifyTokenForNonce;
    wooRequestObj.time =0;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = trackVoIPInvite;
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        if (statusCode == 200)
        {
            
        }
    }
    shouldReachServerThroughQueue:YES];
}
-(void)savePrivateAndMainContext{
    NSError *error = nil;
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    if(privateManagedObjectContext!=nil){
        if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
    else{
        // Saving data on parent context and then informing back
        [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
            
            }];
        }
    }
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"applicationDidEnterBackground");
    [_applozic unsubscribeToConversation];
    [_applozic unSubscribeToTypingStatusForOneToOne];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"APP_ENTER_IN_BACKGROUND" object:nil];

    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^{
        [[AgoraConnectionManager sharedManager] pingInst];

    }];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:_oMyProfileModel];
    [userDefault setObject:encodedObject forKey:@"MyProfileModel"];
    [userDefault synchronize];
   [self savePrivateAndMainContext];
    
    [self connectToFCM];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [_applozic subscribeToConversation];
    [_applozic subscribeToTypingStatusForOneToOne];
    [ALPushNotificationService applicationEntersForeground];
    
    if([ALUserDefaultsHandler isLoggedIn])
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ALMessageService getLatestMessageForUser:[ALUserDefaultsHandler getDeviceKeyString] withCompletion:^(NSMutableArray *messageArray, NSError *error) {
            
            if(error)
            {
                ALSLog(ALLoggerSeverityError, @"ERROR IN LATEST MSG APNs CLASS : %@",error);
            }else{
                NSLog(@"New Messages received %@", messageArray);
                if(messageArray && [messageArray count]>0){
                    for(ALMessage *message in messageArray){
                        [[ApplozicChatManager sharedApplozicChatManager] onMessageReceived:message];
                    }
                }
            }
        }];
      });
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"APP_ENTER_IN_FOREGROUND" object:nil];
    
    NSLog(@"check countOfApprovedPhotos %ld", (long)[DiscoverProfileCollection sharedInstance].myProfileData.wooAlbum.countOfApprovedPhotos);
    
//    NSLog(@"wooUserId hai %ld", (long)LoginModel.sharedInstance.WooUserId);
//    if(LoginModel.sharedInstance.WooUserId != 0){
//
//        if([DiscoverProfileCollection sharedInstance].myProfileData.wooAlbum.countOfApprovedPhotos < 1){
//               [self alertShowing:@"Violate our Guidelines!" messageString:@"To encourage connections between real people, we ask that at least one of your photos has you clearly visible in it"];
//           }
//
//    }
   
    
    [[AppSessionManager sharedManager] makeAppLaunchCallToServer];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAppCameToForeground object:nil];
    [self detectNetworkTypeAndUpdateImageDownloaderNotification];
    
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    NSData *decodedObject = [userDefault objectForKey: @"MyProfileModel"];
    if (decodedObject) {
        _oMyProfileModel = [NSKeyedUnarchiver unarchiveObjectWithData: decodedObject];
    }
    else{
        _oMyProfileModel = [[UserProfileModel alloc] init];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    //facebook activate code
    [FBSDKAppEvents activateApp];

    [[InAppPurchaseManager sharedIAPManager] completeInAppForFailedTransaction];
    [UNetworkReachability sharedNetworkReachability];
    
//----------------- Appsflyer starts here
    
// Track Installs, updates & sessions(app opens) (You must include this API to enable tracking)
    
    [[AppsFlyerTracker sharedTracker] trackAppLaunch];
    
//----------------- Appsflyer ends here
    [self performSelector:@selector(fetchingMatchesAfterDelay) withObject:nil afterDelay:1.0];
    
     [self connectToFCM];
}

-(void)logEventOnFacebook:(NSString*)logEvent {
    [FBSDKAppEvents logEvent:logEvent];
}

- (void)fetchingMatchesAfterDelay{
    totalMatches = (int)[[MyMatches getAllMatches] count];
    totalUnreadAnswers = (int)[[MyMatches getAllUnreadMessage] count];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self savePrivateAndMainContext];
    
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:[InAppPurchaseManager sharedIAPManager]];
        
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:_oMyProfileModel];
    [userDefault setObject:encodedObject forKey:@"MyProfileModel"];
    [userDefault synchronize];
    
    [[ALDBHandler sharedInstance] saveContext];

}



#pragma mark - Remote notification methods
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    
    NSLog(@"\n\n\n\n\n\n TOKEN => %@  <= Token \n\n\n",devToken);
    
    /*
     if ([Swrve sharedInstance].talk != nil) {
     
     //        [Swrve sharedInstanceWithAppID:2819 apiKey:@"Jzf3pMkAjqVs7nbd3bAB" config:_swreConfigObj];
     NSLog(@"\n\n\n\n\n\n\n\n\n THIS IS WORKING\n\n\n\n\n\nn\\nn\n");
     [[Swrve sharedInstance].talk setDeviceToken:devToken];
     }
     */
    
    [[NSUserDefaults standardUserDefaults] setObject:devToken forKey:kDeviceToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kIsRegisteredForPush]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kIsRegisteredForPush];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:KAPNS_PERMISSION_ASKED]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    }
    [self registerForVOIPPush];
    [self updateDeviceTokenOnApplozicServer:_applozic];
    [self connectToFCM];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    
    NSLog(@"notificationSettings.types :%lu",(unsigned long)notificationSettings.types);
    
    [application registerForRemoteNotifications];
 //   [self registerForVOIPPush];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    
    NSLog(@"\n\n\n\n\n\n TOKEN REG FAILED WITH ERROR => %@  <= ERROR \n\n\n",err);
    
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kNotificationTapped];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
    [_applozic notificationArrivedToApplication:application withDictionary:userInfo];
    

    NSLog(@"------------------------------------------");
    NSLog(@"|       IN DID RECEIVE NOTIFICATION-------       ");
    NSLog(@"------------------------------------------");

    NSLog(@"1userinfo >>>>>>➡️➡️➡️➡️➡️➡️➡️➡️➡️➡️➡️ %@",userInfo);
    
    @try {
        if (!notifManager)
            notifManager = [[NotificationManager alloc]init];
        
            [notifManager openScreenForNotificationName:kAPNS WithApplication:application withNotificationData:userInfo];

    }
    @catch (NSException *exception) {
        NSLog(@"PUSH EXCEPTION %@ ",exception);
    }
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    [_applozic notificationArrivedToApplication:application withDictionary:userInfo];
    
//    ALPushNotificationService *pushNotificationService = [[ALPushNotificationService alloc] init];
//    [pushNotificationService notificationArrivedToApplication:application withDictionary:userInfo];
//    completionHandler(UIBackgroundFetchResultNewData);

    NSLog(@"------------------------------------------");
    NSLog(@"|       IN DID RECEIVE NOTIFICATION       ");
    NSLog(@"------------------------------------------");
    /*
     {
     "aps": {
     "alert": "this is the text for displaying"
     },
     "_p": 123456,
     "LANDING_SCREEN": "SCREEN_NAME"
     }
     */
    
    NSLog(@"2userinfo ⏩⏩⏩⏩⏩⏩⏩⏩ %@",userInfo);
    
    
    @try {
        if (!notifManager)
            NSLog(@"👉🏼👉🏼👉🏼👉🏼👉🏼👉🏼 IN IF CONDITION");
            NSLog(@"Current Stack : %@", [self.window rootViewController]);

            notifManager = [[NotificationManager alloc]init];
            [notifManager openScreenForNotificationName:kAPNS WithApplication:application withNotificationData:userInfo];

            completionHandler(UIBackgroundFetchResultNewData);
    }
    @catch (NSException *exception) {
        NSLog(@"PUSH EXCEPTION %@ ",exception);
    }
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"Local Notification aayi hai background me");
    NSLog(@"Received Local Notification %@",[[AgoraConnectionManager sharedManager] getIncomingCallerAccount]);
    NSLog(@"Log State %ld",(long)[[UIApplication sharedApplication] applicationState]);
    if (SYSTEM_VERSION_LESS_THAN(@"10.0"))
        {
            NSLog(@"local notification %@",notification.alertBody);
           dispatch_async(dispatch_get_main_queue(), ^{
               [[WooScreenManager sharedInstance] openIncomingCallScreenForCallFromUserWithId:[[AgoraConnectionManager sharedManager] getIncomingCallUid] withMatchDetail:[MyMatches getMatchDetailForMatchedUSerID:[[AgoraConnectionManager sharedManager] getIncomingCallerAccount] isApplozic:false] andChannelId:[[AgoraConnectionManager sharedManager] incomingCallChannelId]  withPresentationCompletion:^(BOOL completed)
                {
                    [[AgoraConnectionManager sharedManager] acceptCallFromBackground];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"outGoingCallInviteAccepted" object:nil];
                    
                }];
           });
           
        }
}


- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    NSLog(@"Local Notification aayi hai background me");
    NSLog(@"Received Local Notification %@",[[AgoraConnectionManager sharedManager] getIncomingCallerAccount]);
    NSLog(@"Log State %ld",(long)[[UIApplication sharedApplication] applicationState]);
    if (SYSTEM_VERSION_LESS_THAN(@"10.0"))
    {
//        NSLog(@"local notification %@",notification.alertBody);
        dispatch_async(dispatch_get_main_queue(), ^{
            [[WooScreenManager sharedInstance] openIncomingCallScreenForCallFromUserWithId:[[AgoraConnectionManager sharedManager] getIncomingCallUid] withMatchDetail:[MyMatches getMatchDetailForMatchedUSerID:[[AgoraConnectionManager sharedManager] getIncomingCallerAccount] isApplozic:false] andChannelId:[[AgoraConnectionManager sharedManager] incomingCallChannelId]  withPresentationCompletion:^(BOOL completed)
             {
                 [[AgoraConnectionManager sharedManager] acceptCallFromBackground];
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"outGoingCallInviteAccepted" object:nil];
                 
             }];
        });
        
    }
    
}

-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
{
    if ([identifier isEqualToString:@"Accept"])
    {
        
        NSLog(@"background se call aati hui ko accept kiya %@",[[AgoraConnectionManager sharedManager] getIncomingCallerAccount]);
        
        [[WooScreenManager sharedInstance] openIncomingCallScreenForCallFromUserWithId:[[AgoraConnectionManager sharedManager] getIncomingCallUid] withMatchDetail:[MyMatches getMatchDetailForMatchedUSerID:[[AgoraConnectionManager sharedManager] getIncomingCallerAccount] isApplozic:false] andChannelId:[[AgoraConnectionManager sharedManager] incomingCallChannelId]  withPresentationCompletion:^(BOOL completed)
        {
            [[AgoraConnectionManager sharedManager] acceptCallFromBackground];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"outGoingCallInviteAccepted" object:nil]; 

        }];
    }
    else if ([identifier isEqualToString:@"Decline"])
    {
        [[AgoraConnectionManager sharedManager] declineInviteWithChannelId:[[AgoraConnectionManager sharedManager] incomingCallChannelId] asUserWithAccount:[[AgoraConnectionManager sharedManager] getIncomingCallerAccount]];
    }
    else
    {
        NSLog(@"Received Local Notification None");

    }
    completionHandler();
}


#pragma mark - Restoration Methods

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return true;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    return true;
}

#pragma mark - FCM Token Refresh

- (void)tokenRefreshNotification:(NSNotification *)notification {
    // Note that this callback will be fired everytime a new token is generated, including the first
    // time. So if you need to retrieve the token as soon as it is available this is where that
    // should be done.
    

    [[FIRInstanceID instanceID] instanceIDWithHandler:^(FIRInstanceIDResult * _Nullable result,
                                                                           NSError * _Nullable error) {
                         if (error != nil) {
                           NSLog(@"Error fetching remote instance ID: %@", error);
                         } else {
                           NSLog(@"Remote instance ID token: %@", result.token);
                             NSString* message =
                             [NSString stringWithFormat:@"%@", result.token];
                             refreshedToken = message;
                         }
                       }];
    
    NSLog(@"token is refreshed = %@",refreshedToken);

    fcmPushToken = refreshedToken;
    
    [self sendFCMPushTokenToServer];
    
    // Connect to FCM since connection may have failed when attempted before having a token.
    [self connectToFCM];
    
}

- (void)connectToFCM {
    // Won't connect since there is no token
     [[FIRInstanceID instanceID] instanceIDWithHandler:^(FIRInstanceIDResult * _Nullable result,
                                                                           NSError * _Nullable error) {
                         if (error != nil) {
                           NSLog(@"Error fetching remote instance ID: %@", error);
                         } else {
                           NSLog(@"Remote instance ID token: %@", result.token);
                             NSString* message =
                             [NSString stringWithFormat:@"%@", result.token];
                             refreshedToken = message;
                         }
                       }];
    
    // Disconnect previous FCM connection if it exists.
    if(![FIRMessaging messaging].isDirectChannelEstablished){
        [FIRMessaging messaging].shouldEstablishDirectChannel = TRUE;
    }
}


-(void)disconnectFromFCM{
    [FIRMessaging messaging].shouldEstablishDirectChannel = FALSE;
}

/*
 * Added by Lokesh
 * This is the method to send FCM token to server in case the token is refreshed or post login
 */
-(void)sendFCMPushTokenToServer{
    
    NSLog(@"fcmPushToken %@",fcmPushToken);
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] && [[APP_Utilities validString:fcmPushToken] length]>0) {
        NSString *userWooID = [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId];
        
        NSString *fcmURL = [NSString stringWithFormat:@"%@%@?wooId=%@&token=%@",kBaseURLV1,kFCMAPICall,userWooID,fcmPushToken];
        NSLog(@"URL FOR POSTING DATA %@",fcmURL);
        WooRequest *wooRequestObj = [[WooRequest alloc]init];
        wooRequestObj.url =fcmURL;
        wooRequestObj.time =900;
        wooRequestObj.methodType =postRequest;
        wooRequestObj.numberOfRetries =3;
        wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
        wooRequestObj.requestType = sendFCMTokenToServer;
        
        [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType){
            
            if (requestType == sendFCMTokenToServer) {
                if (success)
                {
                    NSLog(@"TOKEN POSTED ON SERVER");
                }
                else
                {
                    // Display you error NSError here and handle it accordingly
                }
            }
        } shouldReachServerThroughQueue:TRUE];
    }
}




-(void)sendDeviceTokedToServer:(NSData *)devTokenData andPushKitToken:(NSData *)voipTokenData{
    
    
    NSLog(@"devTokenData is %@",devTokenData);
    NSLog(@"voipTokenData is %@",voipTokenData);
    
    NSString *deviceTokenToServer;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]) {
        NSString *userWooID = [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId];
        NSString *udid = [NSString stringWithFormat:@"%@",[[UIDevice currentDevice] identifierForVendor].UUIDString];
        
        
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13.0")){
            
            // if we are working with xcode 11
            // if not, then please comment this code
                NSUInteger length = devTokenData.length;
                const unsigned char *buffer = devTokenData.bytes;
                NSMutableString *devTokenForIos13  = [NSMutableString stringWithCapacity:(length * 2)];
                for (int i = 0; i < length; ++i) {
                    [devTokenForIos13 appendFormat:@"%02x", buffer[i]];
                }
                NSLog(@" devtoken in hexString%@",devTokenForIos13);
            deviceTokenToServer = devTokenForIos13;
        }else{
            

            
            NSString *deviceToken = [[devTokenData description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
            
            deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSLog(@"deviceToken>>>>LUV>>> :%@",deviceToken);
            deviceTokenToServer = deviceToken;
            
        }
     
        NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:userWooID,@"wooUserId",deviceTokenToServer,@"deviceToken",udid,@"deviceId",[UIDevice modelName] ,@"deviceModel", @"Apple", @"deviceBrand", @"Apple", @"deviceManufacturer", kDeviceType,@"deviceType",nil];
        
        NSMutableDictionary *mutableParams = [[NSMutableDictionary alloc] initWithDictionary:params];
        
        if (voipTokenData != nil){
            
            // This method is used when we work on xcode 11
            // comment this method if we work on xcode 10
            
            if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13.0")){
             
                NSUInteger length = voipTokenData.length;
                const unsigned char *buffer = voipTokenData.bytes;
                NSMutableString *voipTokenForIos13  = [NSMutableString stringWithCapacity:(length * 2)];
                for (int i = 0; i < length; ++i) {
                    [voipTokenForIos13 appendFormat:@"%02x", buffer[i]];
                }
                NSLog(@"%@",voipTokenForIos13);
                
                [mutableParams setObject:voipTokenForIos13 forKey:@"voipToken"];
                
            }else{
                
                NSString *voipToken = [[voipTokenData description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
                    
                voipToken = [voipToken stringByReplacingOccurrencesOfString:@" " withString:@""];
                NSLog(@"voipToken>>>>LUV>>> :%@",voipToken);
                [mutableParams setObject:voipToken forKey:@"voipToken"];
            }
              
        }

        
        //iPhone10,1
//                                @{@"wooUserId":userWooID,
//                                 @"deviceToken":deviceToken,
//                                 @"deviceId":udid,
//                                 @"deviceType":kDeviceType
//                                 };
        
        NSLog(@"params>>>>>>>:%@",params);
        
        NSString *deviceDataCall = [NSString stringWithFormat:@"%@%@",kBaseURLV1,kDeviceDataCall];
        NSLog(@"URL FOR POSTING DATA %@",deviceDataCall);
        WooRequest *wooRequestObj = [[WooRequest alloc]init];
        wooRequestObj.url =deviceDataCall;
        wooRequestObj.time =900;
        wooRequestObj.requestParams =mutableParams;
        wooRequestObj.methodType =postRequest;
        wooRequestObj.numberOfRetries =3;
        wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
        wooRequestObj.requestType = sendUserDeviceIdToSever;
        [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType){
            
            if (requestType == sendUserDeviceIdToSever) {
                if (success)
                {
                    // Use your response NSDictionary object
                    NSLog(@"TOKEN POSTED ON SERVER");
                    
                }
                else
                {
                    NSLog(@"TOKEN ERROR %@",error);
                    // Display you error NSError object
                }
            }
        } shouldReachServerThroughQueue:TRUE];
    }
}



+(AppDelegate *)appDelegate
{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

-(NSString *)getAudioPathForFileName:(NSString *)fileName{
    //    document directory path
    NSString* documentsPath = [APP_Utilities applicationCacheDirectory];
    NSString *finalDocumentsPath = [NSString stringWithFormat:@"%@/audio",documentsPath];
    NSString *audioFile = nil;
    NSString *fileNameStr = [NSString stringWithFormat:@"%@",fileName];
    if([fileNameStr hasSuffix:@".m4a"] || [fileNameStr hasSuffix:@".mp4"]){
        audioFile =   [NSString stringWithFormat:@"%@",fileName];
    }else{
        audioFile =  [NSString stringWithFormat:@"%@.%@",fileName,kAudioFileExtension];
    }
    
    //    Full path of audio file
    NSString* outputFileURL = [finalDocumentsPath stringByAppendingPathComponent:audioFile];
    //    returning audio file path
    return outputFileURL;
}

-(void)createAudioFolderIfNotExists{
    NSString *audioFolderPath = [NSString stringWithFormat:@"%@/%@",[APP_Utilities applicationCacheDirectory],@"audio"];
    //    NSURL *url = [[NSURL alloc] initWithString:audioFolderPath];
    BOOL isDir = TRUE;
    if (![[NSFileManager defaultManager] fileExistsAtPath:audioFolderPath isDirectory:&isDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:audioFolderPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}


-(void)showLoginScreen{
    
    [[FBSession activeSession] clearJSONCache];
    [[FBSession activeSession] close];
    [[FBSession activeSession] closeAndClearTokenInformation];
    
    [FBSession setActiveSession:nil];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"FBAccessTokenInformationKey"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kIsLoginProcessCompleted];
    
    NSArray *baseViews = [self.window.rootViewController.navigationController.topViewController.view subviews];
    for (UIView *view in baseViews) {
        if (![view isKindOfClass:[LoaderView class]]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kLoaderViewNil];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedOutSuccessfullyLoadDiscover object:nil];
    /*commented by Umesh
     [APP_DELEGATE reInitialiseUserDefault];
     */
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)clearUserDefaultsObjects{
    
    
    [self clearTemporarySettingsDefault];
    if (_notificationsDataArray && [_notificationsDataArray count] > 0) {
        [_notificationsDataArray removeAllObjects];
        _notificationsDataArray = nil;
    }
    
    //clear user defaults for dropoff
    //
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"4-seenTodayCount"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"1-seenTodayCount"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"2-seenTodayCount"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"3-seenTodayCount"];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"4-seenLifetimeCount"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"1-seenLifetimeCount"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"2-seenLifetimeCount"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"3-seenLifetimeCount"];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"4-lastSeenDate"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"1-lastSeenDate"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"2-lastSeenDate"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"3-lastSeenDate"];
    
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"4-cancellationCount"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"1-cancellationCount"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"2-cancellationCount"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"3-cancellationCount"];

//    NSArray *dropOffPlanIDArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"DropOffPlanIDArray"];
//    for(NSString *planId in dropOffPlanIDArray)
//        
//    {
//        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:[NSString stringWithFormat:@"%@-cancellationCount",planId]];
//    }
//    
    
    //[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"(planProductId)-lastSeenDate")
    

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kStoredAccessToken];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastVerificationState];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kIsLoginProcessCompleted];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kMatchesTimestampKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMatchesTimestampKey];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"paginationToken"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"paginationIndex"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"indexForNextDiscoverCall"];

    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *keyText = [NSString stringWithFormat:@"WooID_%@",[[NSUserDefaults standardUserDefaults] valueForKey:kWooUserId]];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:keyText];
    //Added by Umesh
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kWooUserId];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kWooUserName];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kWooUserGender];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kWooProfilePicURL];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kGenderPreference];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kProfileHidingPreference];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLocalTemplatesQuestionTimeKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAnswersRestored];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAnswersUpdatedTimestamp];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kOpenPredictionLeastAtleastOnce];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserSubmittedV3Feedback];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kRemindMePopupTimestampV3];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kFirstMAtchOnV3Key];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kQuestionsRestored];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMinAgePreference];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMaxAgePreference];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kNextMatchTimer];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLocalMyProfileUserKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kChatMessageSentFirstTime];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kIsFirstMatchNotified];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kFirstTimeProfileOptionsFetched];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kWooEncryptionTokenFromServer];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMaxDistance];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastLocationLatitudeKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastLocationLongitudeKey];
    
    
    
    //    NSLog(@"\n\n\n\n1>?>>LOGOUT HUA HAI");
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kIsRegisteredForPush];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kIsRegisteredForLocation];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDiscoverLaunchedForFirstTime];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kGenderPrefrenceChangedForFirstTime];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAgeFromServer];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPendingFavListKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPendingUnFavListKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kFirstDiscoverOverlayKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kfirstNiceKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kFirstNahKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastNotificationID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLikedFromProfile];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDislikedFromProfile];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastErrorValue];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kNumberOfDiscoverLaunches];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kNumberOfTimesProfileCompletenessScreenAppeared];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kNumberOfTimesInviteFriendsScreenAppeared];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kNumberOfTimesPhoneNumberVerifiedScreenAppeared];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kNumberOfTimesTimerScreenAppeared];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserLastLocationTimeStampKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMatchesSoundPreferences];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMessagesSoundPreference];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kNumberOfTimesCropButtonBlinked];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kHasFetchedMatchesAlready];
    //phone verify
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDisableResendSMSButtonTime];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kNumberOfTimeResendButtonTappedForDay];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kIsUserBlacklisted];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kWooToken];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kFacebookNumbericUserID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserFBName];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kNeedToShowUserFirstDayExperience];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kFirstTimeANewUserWithoutImagesLaunchesApp];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"qwedsa"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kIsUserDetailsFetchOnce];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kQuestionsLimit];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kIsUserOnLayerChatOnly];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAnswerCharacterLimit];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kQuestionCharacterLimit];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAnswersLimit];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kQuestionsAskedToday];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kNumberOfDirectMessageSent];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLinkedInEnabled];
     [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLinkedInEnabled];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kProfileOptionUpdateTimestamp];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kServerTimestampKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kIsfirstTimeAutoScrollDone];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastFilerScreenShowed];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kIsProfileCompletenessShown];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kIsFirstTimeLikeANswerButtonAlertShown];
    //    [[NSUserDefaults standardUserDefaults] setObject:@"40" forKey:kProfileCompletenessScoreKey]; // Setting the profile completeness score to 40
    
    //New user defaults added
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTimeUserWasFirstLandedOnDiscoverAfterLogginIn];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTotalNumberOfProfileForADay];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kIsTagSelected];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kIsPreferencesChanged];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kIsFirstAutomaticTagSelectionDone];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kEnableInvite];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kInviteBlockerEnableDisable];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kIsPushedToInviteScreen];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kInviteShareUrl];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPlacementPosition];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSwrveUserId];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kNeedtoShowYayScreen];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAutoReadPushNotificationKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kYayYouAreInScreenType];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kIsLikedNoneFilerCardShown];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTimeOfLikedNoneShown];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPendingInAppPurchaseURL];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCrushDashboardTimestampKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kBoostDashboardTimestampKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSkippedProfileDashboardTimeStampKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLikedMeDashboardTimestampKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"productsFetched"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userRegion"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"isWooGlobePopUpShownToUser"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserLastLocationKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastLocationUpdatedTime];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kWooLoggedInTime];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [defs dictionaryRepresentation];
    for (id key in dict) {
        if([key isEqualToString:kIsProfileCompletenessShown])
            [defs removeObjectForKey:key];
            break;
    }
    [defs synchronize];
}

-(void)reinitialiseUserDefaultAndDatabase{
    
    [self clearUserDefaultsObjects];
    [self clearProfileVisibiltyDefault];
    
    [self.store deleteDatabase];
    
    [self.store deleteManagedObject];
}


-(void)reInitialiseUserDefault{
    
    [self clearUserDefaultsObjects];
    
}

-(void)connectToAgora{
    [[AgoraConnectionManager sharedManager]loginToAgora:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] withCompletionHandler:^(BOOL completed) {
        
        if (completed){
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           [[NSNotificationCenter defaultCenter] postNotificationName:KLoggedInToAgora object:nil];
                           
                           if([[Utilities sharedUtility] checkMicrophonePermission] == -1)
                           {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   //Show introductory Popup and then show permission
                                   if([[NSUserDefaults standardUserDefaults] boolForKey:@"isOnboardingMyProfileShown"])
                                   {
                                       [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"showVoiceCallingIntroductionPopupWhenVisitsMatchbox"];
                                       [[NSUserDefaults standardUserDefaults] synchronize];
                                       //[self showVoiceCallIntroductionPopup];
                                   }
                               });
                           }
                           
                       });
        }
        
    }];
}


-(void)inAppPurchaseRestore{
    if (!hasAddObserver) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:[InAppPurchaseManager sharedIAPManager]];
        hasAddObserver=YES;
    }
}

#pragma mark - Layer
-(void)connectToLayer{
    NSLog(@"Connect karne aaya hai");
    if([AppLaunchModel sharedInstance].isVoiceCallingOnForIOS)
    {
        if(![[AgoraConnectionManager sharedManager] isLogin]){
            [self connectToAgora];
        }

    }
//    [[LayerManager sharedLayerManager] connectUserToLayer:^(BOOL authenticationSuccess, LYRClient *layerClient) {
//        NSLog(@"Connect karke aaya hai");
//        NSLog(@"authenticationSuccess :%d",authenticationSuccess);
//        NSLog(@"layerClient :%@",layerClient);
//        NSLog(@"layerClient is connected :%d",layerClient.isConnected);
//        NSLog(@"authenticated user :%@",layerClient.authenticatedUser);
//        NSLog(@"authenticated user id :%@",layerClient.authenticatedUser.userID);
//        _layerClient = layerClient;
//        if ([LayerManager sharedLayerManager].connectionEstablishedBlock) {
//            NSLog(@"Tuesday 12 :%@",[LayerManager sharedLayerManager].connectionEstablishedBlock);
//            [LayerManager sharedLayerManager].connectionEstablishedBlock(TRUE);
//            [LayerManager sharedLayerManager].connectionEstablishedBlock = nil;
//        }
//    }];
}

#pragma mark Applozic connection
-(void)connectToApplozic{
    NSLog(@"Applozic connect karne aaya hai");

    if (_applozic == nil){
        _applozic = [[ApplozicClient alloc]initWithApplicationKey:kAppId_Applozic withDelegate:self];
    }
    if([AppLaunchModel sharedInstance].isVoiceCallingOnForIOS)
    {
        if(![[AgoraConnectionManager sharedManager] isLogin]){
            [self connectToAgora];
        }
        
    }
    
    [[ApplozicChatManager sharedApplozicChatManager] connectUserToApplozicWithClientObject:_applozic withAppLozicAuthBlock:^(BOOL authenticationSuccess, ApplozicClient * _Nonnull applozicClient) {
        
        if (!authenticationSuccess){
            return;
        }
        else{
        
        if ([ApplozicChatManager sharedApplozicChatManager].connectionEstablishedBlock){
            [ApplozicChatManager sharedApplozicChatManager].connectionEstablishedBlock(TRUE);
            [ApplozicChatManager sharedApplozicChatManager].connectionEstablishedBlock = nil;
        }
        
        [self getMessagesFromApplozic];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self.applozic subscribeToConversation];
            [self.applozic subscribeToTypingStatusForOneToOne];
            });
            
        }
    }];
}

-(void)updateDeviceTokenOnApplozicServer:(ApplozicClient *)clientObj{
    if (clientObj) {
        NSData *devTokenData= [[NSUserDefaults standardUserDefaults] objectForKey:kDeviceToken];
        NSString * deviceTokenString;
        
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13.0")){
            
            // if we are working with xcode 11
            // if not, then please comment this code
                NSUInteger length = devTokenData.length;
                const unsigned char *buffer = devTokenData.bytes;
                NSMutableString *devTokenForIos13  = [NSMutableString stringWithCapacity:(length * 2)];
                for (int i = 0; i < length; ++i) {
                    [devTokenForIos13 appendFormat:@"%02x", buffer[i]];
                }
                NSLog(@" devtoken in hexString%@",devTokenForIos13);
                deviceTokenString = devTokenForIos13;
            
        }else{
            
           deviceTokenString  = [[[[devTokenData description]
                                stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                stringByReplacingOccurrencesOfString: @">" withString: @""]
                                stringByReplacingOccurrencesOfString: @" " withString: @""];
        }
        
         
        if (![[ALUserDefaultsHandler getApnDeviceToken] isEqualToString:deviceTokenString]) {
            ALRegisterUserClientService *registerUserClientService = [[ALRegisterUserClientService alloc] init];
            [registerUserClientService updateApnDeviceTokenWithCompletion
             :deviceTokenString withCompletion:^(ALRegistrationResponse
                                                 *rResponse, NSError *error) {
                 
                 NSLog(@"Registration response%@", rResponse);
                 
                 if (error) {
                     NSLog(@"%@",error);
                 }
                 else{
                     NSLog(@"Push device token success");
                 }
             }];
        }
    }
}

-(void)showVoiceCallIntroductionPopup
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [window endEditing:YES];
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
//    NSLog(@"Window subviews %@",window.subviews);
    VoiceCallIntroductionPopup *voiceCallIntroPopup =  [[[NSBundle mainBundle] loadNibNamed:@"VoiceCallIntroductionPopup" owner:window.rootViewController options:nil] firstObject];
    voiceCallIntroPopup.frame = CGRectMake(0, 0,[[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    
    
    NSString *leftUserImageURL = DiscoverProfileCollection.sharedInstance.myProfileData.wooAlbum.profilePicUrl;
    if (leftUserImageURL != nil){
    [voiceCallIntroPopup.leftImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(kCircularImageSize),IMAGE_SIZE_FOR_POINTS(kCircularImageSize), leftUserImageURL]] placeholderImage:[UIImage imageNamed:@"ic_me_avatar_small"] completed:nil];
    }
    
    if([[[[DiscoverProfileCollection sharedInstance] myProfileData ]gender] isEqualToString:@"FEMALE"])
    {
        [voiceCallIntroPopup.rightImage setImage:[UIImage imageNamed:@"ic_calling_male"]];
    }
    else
    {
        [voiceCallIntroPopup.rightImage setImage:[UIImage imageNamed:@"ic_calling_female"]];
    }

    
    voiceCallIntroPopup.closeTappedOnOverlayHandler = ^{
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            // CALL YOUR METHOD HERE - as this assumes being called only once from user interacting with permission alert!
            if (granted) {
                // Microphone enabled code
            }
            else {
                // Microphone disabled code
            }
        }];
    };
    [window addSubview:voiceCallIntroPopup];
}

-(void)createImageFolderIfNotExists{
    NSString *selfieimageFolderPath = [NSString stringWithFormat:@"%@/%@",[APP_Utilities applicationCacheDirectory],kSelfieImagesFolderName];
    //    NSURL *url = [[NSURL alloc] initWithString:audioFolderPath];
    BOOL isDir = TRUE;
    if (![[NSFileManager defaultManager] fileExistsAtPath:selfieimageFolderPath isDirectory:&isDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:selfieimageFolderPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}

-(void)getMyMatchesForTimestamp:(unsigned int long long)timestamp withCompletion:(void (^)(BOOL matchFetched))completionBlock
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] || [[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue] <=0) {
        return;
    }
    long long int localSavedTimestamp = 0;
    
    NSString *storedTimestamp = [[NSUserDefaults standardUserDefaults] objectForKey:kServerTimestampKey];
 
    unsigned long long serverTimeStamp = [storedTimestamp longLongValue];
    
    NSLog(@"timestamp %llu \n storedTimestamp : %@ \n serverTimeStamp: %llu\n",timestamp,storedTimestamp,serverTimeStamp);
    if([AppLaunchModel sharedInstance].lastMatchUpdateTime > serverTimeStamp){

        
        localSavedTimestamp = [AppLaunchModel sharedInstance].lastMatchUpdateTime;

        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%lld",localSavedTimestamp] forKey:kServerTimestampKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/matches",kBaseURLV3,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];

    localSavedTimestamp = timestamp;
    
    urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"?time=%lld",localSavedTimestamp]];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =urlString;
    wooRequestObj.time =900;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =getRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = fetchAllMatches;
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        if (success && (requestType == fetchAllMatches) && (statusCode == 200)) {
            //long long matchTimestamp = 0;

            NSMutableArray *responseDataArray = (NSMutableArray *)response;
            if ([responseDataArray count] > 0) {
              
//                if (localSavedTimestamp>=0) {
                 //   matchTimestamp = [[[responseDataArray lastObject] objectForKey:kMatchTime] longLongValue];
//                }

                
                [self makeAppsflyerFirstMatchCall];
                [MyMatches insertDataInMyMatchesFromArray:responseDataArray withChatInsertionSuccess:^(BOOL insertionSuccess) {
                   if(insertionSuccess)
                   {
                        [self connectToLayer];
                        [self connectToApplozic];
                       
                        if ([responseDataArray count] == 1) {
                            if (notifManager && notifManager.shouldShowTopNotification == TRUE) {
                                if (notifManager && notifManager.showTopNotioficationForMatchId && [notifManager.showTopNotioficationForMatchId length] > 0) {
                                    [self showTopNotificationForMatchID:notifManager.showTopNotioficationForMatchId];
                                    completionBlock(success);
                                }
                            }
                        }
                   }
                }];
                
            }
            if (![[NSUserDefaults standardUserDefaults] boolForKey:kHasFetchedMatchesAlready]) {
                [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kHasFetchedMatchesAlready];
            }
            completionBlock(success);

        }
        completionBlock(success);
    } shouldReachServerThroughQueue:TRUE];
    }
}


-(void)getMyMatchesForRefreshMatchesTimestamp:(unsigned int long long)timestamp withCompletion:(void (^)(BOOL matchFetched))completionBlock
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] || [[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue] <=0) {
        return;
    }
    long long int localSavedTimestamp = 0;
    
    NSString *storedTimestamp = [[NSUserDefaults standardUserDefaults] objectForKey:kServerTimestampKey];
    
    unsigned long long serverTimeStamp = [storedTimestamp longLongValue];
    
//    if([AppLaunchModel sharedInstance].lastMatchUpdateTime > serverTimeStamp){
//        localSavedTimestamp = [AppLaunchModel sharedInstance].lastMatchUpdateTime;
//        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%lld",localSavedTimestamp] forKey:kServerTimestampKey];
//        [[NSUserDefaults standardUserDefaults] synchronize];
    
        NSString *urlString = [NSString stringWithFormat:@"%@/%@/matches",kBaseURLV3,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
        
        localSavedTimestamp = serverTimeStamp;
        
        urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"?time=%lld",localSavedTimestamp]];
        
        WooRequest *wooRequestObj = [[WooRequest alloc]init];
        wooRequestObj.url =urlString;
        wooRequestObj.time =900;
        wooRequestObj.requestParams =nil;
        wooRequestObj.methodType =getRequest;
        wooRequestObj.numberOfRetries =3;
        wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
        wooRequestObj.requestType = fetchAllMatches;
        [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
            if (success && (requestType == fetchAllMatches) && (statusCode == 200)) {
              //  long long matchTimestamp = 0;
                
                NSMutableArray *responseDataArray = (NSMutableArray *)response;
                if ([responseDataArray count] > 0) {
                    
//                    if (localSavedTimestamp>=0) {
//                        matchTimestamp = [[[responseDataArray lastObject] objectForKey:kMatchTime] longLongValue];
//                    }
                    
                    
                    [self makeAppsflyerFirstMatchCall];
                    [MyMatches insertDataInMyMatchesFromArray:responseDataArray withChatInsertionSuccess:^(BOOL insertionSuccess) {
                        if(insertionSuccess)
                        {
                        [self connectToLayer];
                        [self connectToApplozic];
                        
                        if ([responseDataArray count] == 1) {
                            if (notifManager && notifManager.shouldShowTopNotification == TRUE) {
                                if (notifManager && notifManager.showTopNotioficationForMatchId && [notifManager.showTopNotioficationForMatchId length] > 0) {
                                    [self showTopNotificationForMatchID:notifManager.showTopNotioficationForMatchId];
//                                    completionBlock(success);
                                }
                            }
                        }
                        }
                        
                    }];
                    
                }
                if (![[NSUserDefaults standardUserDefaults] boolForKey:kHasFetchedMatchesAlready]) {
                    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kHasFetchedMatchesAlready];
                }
//                completionBlock(success);
                
            }
//            completionBlock(success);
        } shouldReachServerThroughQueue:TRUE];
        
//    }
    
}

-(void)getMyMatchesForTimestamp:(long long int)timestampInitial andUpdateTimeAfterDataInsertionWith:(long long int)newTimeStamp{
    
    if([AppLaunchModel sharedInstance].lastMatchUpdateTime > timestampInitial){
        
        
    NSLog(@"------------------------------------------");
    NSLog(@"|       IN getmatchesfortimestamp       ");
    NSLog(@"------------------------------------------");
    

    long long int lastUpdateTimestamp = timestampInitial;
    long long int localSavedTimestamp = 0;
    
    NSLog(@"------------------------------------------");
    NSLog(@"|       IN TIMESTAMP 1 = %lld       ",lastUpdateTimestamp);
    NSLog(@"------------------------------------------");
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/matches",kBaseURLV3,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
    
    
//    this is the condition to check that user is logged in and user ID is saved on disk
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] || [[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue] <=0) {
        
        return;
        
    }

//    this will check that is the last updated timestamp which we have to send to server for matches
    if ( timestampInitial > 0) {
        
        localSavedTimestamp = timestampInitial;
        
        NSLog(@"------------------------------------------");
        NSLog(@"|       IN TIMESTAMP 2 = %lld       ",localSavedTimestamp);
        NSLog(@"------------------------------------------");
        
    }
    
    if (localSavedTimestamp < 0) {
        localSavedTimestamp = 0;
    }
    
    if (localSavedTimestamp == 0) {
        isFetchingMatchDataFromServer = TRUE;
    }
 
    urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"?time=%lld",localSavedTimestamp]];
    
    NSLog(@"------------------------------------------ %@ ------------------------------------------",urlString);
    
    NSLog(@"------------------------------------------");
    NSLog(@"|       IN makingCallForFetchingData       ");
    NSLog(@"|       IN GET DATA URL                 %@",urlString);
    NSLog(@"------------------------------------------");
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =urlString;
    wooRequestObj.time =900;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =getRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = fetchAllMatches;
    //making a request to server to get all matches after the savedTimeStamp
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        //We have recieved some response
        if (success && (requestType == fetchAllMatches) && (statusCode == 200)) {
            
            NSMutableArray *responseDataArray = (NSMutableArray *)response;
            
            NSLog(@"------------------------------------------");
            NSLog(@"|       Response %@       ",response);
            NSLog(@"------------------------------------------");
            
            
            if ([responseDataArray count] > 0) {
                [self makeAppsflyerFirstMatchCall];
                [MyMatches insertDataInMyMatchesFromArray:responseDataArray withChatInsertionSuccess:^(BOOL insertionSuccess) {
                    if(insertionSuccess)
                    {
                        [self connectToLayer];
                        [self connectToApplozic];
                        if ([responseDataArray count] == 1) {
                            if (notifManager && notifManager.shouldShowTopNotification == TRUE) {
                                if (notifManager && notifManager.showTopNotioficationForMatchId && [notifManager.showTopNotioficationForMatchId length] > 0) {
                                    [self showTopNotificationForMatchID:notifManager.showTopNotioficationForMatchId];                                
                                }
                            }
                        }
                    }
                }];
                
            }
            else{
                [[NSNotificationCenter defaultCenter] postNotificationName:kMatchDataSavedInLocalDatabase object:nil];
            }


            if (![[NSUserDefaults standardUserDefaults] boolForKey:kHasFetchedMatchesAlready]) {
                [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kHasFetchedMatchesAlready];
            }
            long long unsigned int newTimestamp = [AppLaunchModel sharedInstance].lastMatchUpdateTime;
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%lld",newTimestamp] forKey:kServerTimestampKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[WooScreenManager sharedInstance].oHomeViewController checkAndShowUnreadBadgeOnMatchIcon];
            isFetchingMatchDataFromServer = FALSE;
        }
    } shouldReachServerThroughQueue:TRUE];
    
    }
}




-(void)showTopNotificationForMatchID:(NSString *)matchID{
    
    NSLog(@"------------------------------------------");
    NSLog(@"|       showtopnotificaionforlatestmatch  ");
    NSLog(@"------------------------------------------");
    if (notifManager)
        notifManager.shouldShowTopNotification = false;
    
    MyMatches *latestMatch= [MyMatches getMatchDetailForMatchID:matchID];
  notifManager.showTopNotioficationForMatchId = nil;
    TopNotificationView *notificationView = [[TopNotificationView alloc]init];
    
    [notificationView presentMatchNotificationWithText:[NSString stringWithFormat:@"%@ %@",latestMatch.matchUserName,NSLocalizedString(@"likes you back!", nil)] andImageURL:[NSURL URLWithString:latestMatch.matchUserPic] forMatchID:latestMatch.matchId];
}




-(void)updateQuestionAnswersOnUI{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] || ([[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue] <= 0)) {
        return;
    }
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kQuestionsRestored]) {
        
        NSString *restoreQuestionsURL = [NSString stringWithFormat:@"%@%@?wooId=%lld&lastUpdate=0",kBaseURLV1,kQuestion,[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue]];
        
        WooRequest *wooRequestObj = [[WooRequest alloc]init];
        wooRequestObj.url =restoreQuestionsURL;
        wooRequestObj.time =0;
        wooRequestObj.requestParams =nil;
        wooRequestObj.methodType =getRequest;
        wooRequestObj.numberOfRetries =3;
        wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
        wooRequestObj.requestType = restoreQuestions;
        
        [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
            
            if (success && requestType == restoreQuestions) {
                
                [MyQuestions insertUpdateMyQuestionsFromArray:[response objectForKey:@"dto"] withInsertionCompletionHandler:^(BOOL isCompleted) {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kQuestionsRestored];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMeSection" object:nil];                    
                    [self getUpdatedAnswers];                    
                }];
                
            }
        } shouldReachServerThroughQueue:TRUE];
    }else{
        [self getUpdatedAnswers];
    }
}

-(void)getUpdatedAnswers{
    
    AppLaunchModel *appLaunchModelObj =[AppLaunchModel sharedInstance];
    
    long long int lastUpdatedTimestamp = 0;
    
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kLatestAnswerTimestampKey]) {
    
        lastUpdatedTimestamp = [[[NSUserDefaults standardUserDefaults] objectForKey:kLatestAnswerTimestampKey] longLongValue];
        
    }
    
    if (lastUpdatedTimestamp == 0 && [[NSUserDefaults standardUserDefaults] objectForKey:kAnswersRestored] && [[[NSUserDefaults standardUserDefaults] objectForKey:kAnswersRestored] boolValue] == true) {
        
        return;
        
    }
    
    if (lastUpdatedTimestamp >= appLaunchModelObj.answersUpdateTime && [[NSUserDefaults standardUserDefaults] objectForKey:kAnswersRestored] && [[[NSUserDefaults standardUserDefaults] objectForKey:kAnswersRestored] boolValue] == true) {
        return;
    }
    
    
    NSString *updateAnswerURL = [NSString stringWithFormat:@"%@%@?wooId=%lld&lastUpdate=%lld",kBaseURLV1,kAnswers,[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue], lastUpdatedTimestamp];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =updateAnswerURL;
    wooRequestObj.time =0;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =getRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = updateAnswers;

    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        if (requestType == updateAnswers && success) {
            
            //need to check this again
            BOOL needTouUpdateCounter = NO;
            if(lastUpdatedTimestamp != 0)
            {
                needTouUpdateCounter = ![[NSUserDefaults standardUserDefaults] boolForKey:kAnswersRestored];
            }
            if ([response objectForKey:@"listAnswerDto"] && [(NSArray *)[response objectForKey:@"listAnswerDto"] count] > 0) {
                
                [MyAnswers insertOrUpdateAnswersFromAnswerArray:(NSArray *)[response objectForKey:@"listAnswerDto"] isFetchingNewAnswers:needTouUpdateCounter withCompletionHandler:^(BOOL isInsertionCompleted) {
                    
                    if(isInsertionCompleted)
                    {
                        [MyAnswers setIsFetchingAnswers:false];
                    }
                    [appLaunchModelObj setAnswersUpdateTime:[[[response objectForKey:kGenericAttributeKey] objectForKey:kAnswersLastUpdateAPIKey] longLongValue]];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:[AppLaunchModel sharedInstance].answersUpdateTime] forKey:kLatestAnswerTimestampKey];
                    
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAnswersRestored];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kAnswersFetched object:nil];
                    
                }];
            }else{
                
                [MyAnswers setIsFetchingAnswers:false];

                [appLaunchModelObj setAnswersUpdateTime:[[[response objectForKey:kGenericAttributeKey] objectForKey:kAnswersLastUpdateAPIKey] longLongValue]];
                
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:[AppLaunchModel sharedInstance].answersUpdateTime] forKey:kLatestAnswerTimestampKey];
                
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAnswersRestored];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kAnswersFetched object:nil];
            }

            
        }
        else
        {
            [MyAnswers setIsFetchingAnswers:false];
        }
    } shouldReachServerThroughQueue:TRUE];
}



-(void)fetchTemplateQuestions{
    
    //    this is the condition to check that user is logged in and user ID is saved on disk
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] ||
        [[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue] <=0) {
        return;
    }
    
    NSString *templateQuestionsURL = [NSString stringWithFormat:@"%@%@?wooId=%lld",kBaseURLV1,kGetTemplateQuestions,[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue]];

    if ([[NSUserDefaults standardUserDefaults] objectForKey:kLocalTemplatesQuestionTimeKey] && [[[NSUserDefaults standardUserDefaults] objectForKey:kLocalTemplatesQuestionTimeKey] longLongValue] > 0) {
        
        templateQuestionsURL = [templateQuestionsURL stringByAppendingString:[NSString stringWithFormat:@"&lastUpdate=%lld",[[[NSUserDefaults standardUserDefaults] objectForKey:kLocalTemplatesQuestionTimeKey] longLongValue]]];
    }
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =templateQuestionsURL;
    wooRequestObj.time =0;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =getRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = getTemplateQuestions;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        [APP_Utilities hideActivityIndicator];
        if (success && requestType == getTemplateQuestions) {
            
            [[NSUserDefaults standardUserDefaults] setObject:[[response objectForKey:kGenericAttributeKey] objectForKey:kTemplateUpdateTimestampKey] forKey:kLocalTemplatesQuestionTimeKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if ([response objectForKey:kQuestionsArrayKey] && [(NSArray *)[response objectForKey:kQuestionsArrayKey] count] > 0) {
                
                [TemplateQuestions insertUpdateTemplateQuestionsFromArray:[response objectForKey:kQuestionsArrayKey]];
                
            }
        }
    } shouldReachServerThroughQueue:TRUE];
    
}


-(void)makeAppsflyerAppLaunchCall{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] || [[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue] <=0) {
        return;
    }
    
    [[AppsFlyerTracker sharedTracker] trackEvent:@"LAUNCH"
                                      withValues:[[NSDictionary alloc]initWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],@"User_id",[NSString stringWithFormat:@"%f",[AppLaunchModel sharedInstance].qualityScore],@"qualityScore",nil]];
//                                                @{@"User_id":[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],
//                                                   @"qualityScore":[NSString stringWithFormat:@"%f",[AppLaunchModel sharedInstance].qualityScore]
//                                                   }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"QualityScoreUploaded"] == false){
    
    [self sendFirebaseEvent:[NSString stringWithFormat:@"Quality_Score_%f",[AppLaunchModel sharedInstance].qualityScore] andScreen:@""];
    
    if ([AppLaunchModel sharedInstance].qualityScore >= 4){
        [self sendFirebaseEvent:@"Quality_Score_4_Plus" andScreen:@""];
    }
    if ([AppLaunchModel sharedInstance].qualityScore >= 3){
        [self sendFirebaseEvent:@"Quality_Score_3_Plus" andScreen:@""];
    }
    if ([AppLaunchModel sharedInstance].qualityScore >= 2){
        [self sendFirebaseEvent:@"Quality_Score_2_Plus" andScreen:@""];
    }
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"QualityScoreUploaded"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [ApplicationDelegate sendFirebaseEvent:@"Launch" andScreen:@""];
    [ApplicationDelegate sendUserPropertyDetailsOnFirebasewithKeyName:@"WooUserId" withKeyValue:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
    [ApplicationDelegate sendUserPropertyDetailsOnFirebasewithKeyName:@"QualityScore" withKeyValue:[NSString stringWithFormat:@"%f",[AppLaunchModel sharedInstance].qualityScore]];
}


-(void)makeAppsflyerUserLoginCall{
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] || [[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue] <=0) {
        return;
    }

    
    [[AppsFlyerTracker sharedTracker] trackEvent:@"LOGIN"
                                      withValues:[[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)[[LoginModel sharedInstance] WooUserId]],@"User_id",[NSString stringWithFormat:@"%d",[[LoginModel sharedInstance] age]],@"Age",[NSString stringWithFormat:@"%@",[[LoginModel sharedInstance] gender]],@"Gender",nil]];
//
//                                                @{@"User_id":[NSString stringWithFormat:@"%ld",(long)[[LoginModel sharedInstance] WooUserId]],
//                                                   @"Age":[NSString stringWithFormat:@"%d",[[LoginModel sharedInstance] age]],
//                                                   @"Gender":[NSString stringWithFormat:@"%@",[[LoginModel sharedInstance] gender]],
//                                                   }];

    [ApplicationDelegate sendFirebaseEvent:@"Login" andScreen:@""];
    [ApplicationDelegate sendUserPropertyDetailsOnFirebasewithKeyName:@"WooUserId" withKeyValue:[NSString stringWithFormat:@"%ld",(long)[[LoginModel sharedInstance] WooUserId]]];
    [ApplicationDelegate sendUserPropertyDetailsOnFirebasewithKeyName:@"WooUserAge" withKeyValue:[NSString stringWithFormat:@"%d",[[LoginModel sharedInstance] age]]];
    [ApplicationDelegate sendUserPropertyDetailsOnFirebasewithKeyName:@"WooUserGender" withKeyValue:[NSString stringWithFormat:@"%@",[[LoginModel sharedInstance] gender]]];
    
}

-(void)makeAppsflyerFirstMatchCall{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] || [[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue] <=0) {
        return;
    }
    
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsFirstMatchNotified] && [[NSUserDefaults standardUserDefaults] boolForKey:kIsFirstMatchNotified] == YES) {
        return;
    }else{
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsFirstMatchNotified];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSLog(@"gender : %@",[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserGender]);
    NSLog(@"user id :%@",[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]);
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kWooUserGender]) {
        [[AppsFlyerTracker sharedTracker] trackEvent:@"MATCH"
                                          withValues:[[NSDictionary alloc]initWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],@"User_id",[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserGender],@"Gender",nil]];
//  @{@"User_id":[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],
//                                                       @"Gender":[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserGender],
//                                                       }];
        
        [ApplicationDelegate sendFirebaseEvent:@"Match" andScreen:@""];
    }
    
    
}

-(void)makeAppsflyerFakeUserCall{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] || [[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue] <=0) {
        return;
    }
    
    [[AppsFlyerTracker sharedTracker] trackEvent:@"FAKE"
                                      withValues:[[NSDictionary alloc]initWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],@"User_id",nil]];
//                                                @{@"User_id":[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],
//                                                   }];
    [ApplicationDelegate sendFirebaseEvent:@"FAKE" andScreen:@""];
    
}

-(void)sendFirebaseEvent:(NSString *)event andScreen:(NSString *)screen{
    NSMutableDictionary *fieldsDictionary = [[NSMutableDictionary alloc]init];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] && [[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue] > 0) {
        [fieldsDictionary setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] forKey:@"WooID"];
        [fieldsDictionary setObject:[NSString stringWithFormat:@"W%@",[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]] forKey:@"WID"];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kWooUserGender] && [[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserGender] length] > 0) {
        
        [fieldsDictionary setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserGender] forKey:@"gender"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kAgeFromServer] && [[[NSUserDefaults standardUserDefaults] objectForKey:kAgeFromServer] intValue] > 0) {
        NSString *ageDimensionValue = [[NSUserDefaults standardUserDefaults] objectForKey:kAgeFromServer];
        [fieldsDictionary setObject:ageDimensionValue forKey:@"age"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userRegion"]) {
        [fieldsDictionary setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userRegion"] forKey:@"location"];
    }
    
    [fieldsDictionary setObject:[NSString stringWithFormat:@"%d",totalMatches] forKey:@"MatchesCount"];
    
    [fieldsDictionary setObject:[NSString stringWithFormat:@"%d",totalUnreadAnswers] forKey:@"UnreadMessagesCount"];
    
    if ([[fieldsDictionary allKeys] count] > 0) {
        [self sendEventOnFirebaseWithEventDetails:event withUserProperties:fieldsDictionary];
//        for (NSString *fieldsKey in fieldsDictionary) {
//            [self sendUserPropertyDetailsOnFirebasewithKeyName:fieldsKey withKeyValue:[fieldsDictionary objectForKey:fieldsKey]];
//        }
        
    }else{
        [self sendEventOnFirebaseWithEventDetails:event withUserProperties:nil];
    }
}

-(void)sendPurchasedFirebaseEvent:(NSString *)event ForPurchaseData:(NSDictionary *)purchaseDict{
    
    if ([[purchaseDict allKeys] count] > 0) {
        [self sendEventOnFirebaseWithEventDetails:event withUserProperties:purchaseDict];
    }else{
        [self sendEventOnFirebaseWithEventDetails:event withUserProperties:nil];
    }
}

-(void)sendFirebaseEvent:(NSString *)event andScreen:(NSString *)screen andAdditionalFields:(NSMutableDictionary*)fieldsDictionary{
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] && [[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue] > 0) {
        [fieldsDictionary setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] forKey:@"WooID"];
        [fieldsDictionary setObject:[NSString stringWithFormat:@"W%@",[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]] forKey:@"WID"];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kWooUserGender] && [[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserGender] length] > 0) {
        
        [fieldsDictionary setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserGender] forKey:@"gender"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kAgeFromServer] && [[[NSUserDefaults standardUserDefaults] objectForKey:kAgeFromServer] intValue] > 0) {
        NSString *ageDimensionValue = [[NSUserDefaults standardUserDefaults] objectForKey:kAgeFromServer];
        [fieldsDictionary setObject:ageDimensionValue forKey:@"age"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userRegion"]) {
        [fieldsDictionary setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userRegion"] forKey:@"location"];
    }
    
    [fieldsDictionary setObject:[NSString stringWithFormat:@"%d",totalMatches] forKey:@"MatchesCount"];
    
    [fieldsDictionary setObject:[NSString stringWithFormat:@"%d",totalUnreadAnswers] forKey:@"UnreadMessagesCount"];
    
    if ([[fieldsDictionary allKeys] count] > 0) {
        [self sendEventOnFirebaseWithEventDetails:event withUserProperties:fieldsDictionary];
        //        for (NSString *fieldsKey in fieldsDictionary) {
        //            [self sendUserPropertyDetailsOnFirebasewithKeyName:fieldsKey withKeyValue:[fieldsDictionary objectForKey:fieldsKey]];
        //        }
        
    }else{
        [self sendEventOnFirebaseWithEventDetails:event withUserProperties:nil];
    }
}


-(void)sendSwrveEventWithEvent:(NSString *)event andScreen:(NSString *)screen{
    
    NSMutableDictionary *fieldsDictionary = [[NSMutableDictionary alloc]init];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] && [[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue] > 0) {
        [fieldsDictionary setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] forKey:@"WooID"];
        [fieldsDictionary setObject:[NSString stringWithFormat:@"W%@",[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]] forKey:@"WID"];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kWooUserGender] && [[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserGender] length] > 0) {
        
        [fieldsDictionary setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserGender] forKey:@"gender"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kAgeFromServer] && [[[NSUserDefaults standardUserDefaults] objectForKey:kAgeFromServer] intValue] > 0) {
        NSString *ageDimensionValue = [[NSUserDefaults standardUserDefaults] objectForKey:kAgeFromServer];
        [fieldsDictionary setObject:ageDimensionValue forKey:@"age"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userRegion"]) {
        [fieldsDictionary setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userRegion"] forKey:@"location"];
    }
    
//    int totalMatches = (int)[[MyMatches getAllMatches] count];
//    int totalUnreadAnswers = (int)[[MyMatches getAllUnreadMessage] count];
    
    [fieldsDictionary setObject:[NSString stringWithFormat:@"%d",totalMatches] forKey:@"MatchesCount"];
    
    [fieldsDictionary setObject:[NSString stringWithFormat:@"%d",totalUnreadAnswers] forKey:@"UnreadMessagesCount"];
    
    NSString *finalEventName= @"";
    
    if ([event length] > 0) {
    NSArray *dotSeparatedArray = [event componentsSeparatedByString:@"."];
    if ([dotSeparatedArray count] > 1) {
    NSString *eventFirstName = [dotSeparatedArray objectAtIndex:1];
    NSString *eventLastName = [dotSeparatedArray lastObject];
    
    if ([eventFirstName length] > 0 && [eventLastName length] > 0) {
    NSArray *underScoreSeparatedArray1 = [eventFirstName componentsSeparatedByString:@"_"];
    NSArray *underScoreSeparatedArray2 = [eventLastName componentsSeparatedByString:@"_"];
    
    if (underScoreSeparatedArray1.count > 1 && underScoreSeparatedArray2.count > 1) {
    NSString *eventPart1 = [underScoreSeparatedArray1 firstObject];
    NSString *eventPart2 = [underScoreSeparatedArray2 lastObject];
    NSString *shortEventName = [underScoreSeparatedArray2 firstObject];
    
    finalEventName = [NSString stringWithFormat:@"%@_%@",eventFirstName,eventPart2];
    if (finalEventName.length > 40) {
        finalEventName = [NSString stringWithFormat:@"%@_%@_%@",eventPart1,shortEventName,eventPart2];
        if (finalEventName.length > 40) {
            finalEventName = eventLastName;
            }
            }
       }
    else{
        finalEventName = [NSString stringWithFormat:@"%@_%@",eventFirstName,eventLastName];
        }
    }
    else{
        finalEventName = event;
    }
        }
        else{
            finalEventName = event;
        }
    }
    else{
        finalEventName = event;
    }

    if ([[fieldsDictionary allKeys] count] > 0 && [screen length] > 0) {
//        [[Swrve sharedInstance] userUpdate:fieldsDictionary];
//        [[Swrve sharedInstance] event:event payload:fieldsDictionary];
        [self sendEventOnFirebaseWithEventDetails:finalEventName withUserProperties:fieldsDictionary];
//        for (NSString *fieldsKey in fieldsDictionary) {
//            [self sendUserPropertyDetailsOnFirebasewithKeyName:fieldsKey withKeyValue:[fieldsDictionary objectForKey:fieldsKey]];
//        }

    }else{
//        [[Swrve sharedInstance] event:event];
        [self sendEventOnFirebaseWithEventDetails:finalEventName withUserProperties:nil];
    }
}


-(void)checkIfMaxDistanceExists{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kMaxDistance]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"2147483647" forKey:kMaxDistance];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}







- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSLog(@"Product recieve huya hai :%@",response);
    NSLog(@"agar huya hai to fir count:%lu",(unsigned long)[response.products count]);
    NSLog(@"agar huya hai to fir product list :%@", response.products);
}



- (void)showNewChatMessageFromTop : (NSString *)message headerText:(NSString *)headerTxt withImageURL:(NSString *)imageUrl withMatchId:(NSString *)matchId{
    TopChatView *chatView = [TopChatView sharedInstanceWithNotificationType:chatBoxLanding];
//    TopChatView *chatView = [[TopChatView alloc] initWithViewType:chatBoxLanding];
    [chatView setNotificationTypeForView:chatBoxLanding];
    [chatView showNewChatMessageFromTop:message withHeader:headerTxt andUserImage:imageUrl];
    [chatView setButtonTapHandler:^(BOOL btnTapped) {
        // code to be written
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //Check currentTab
            
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            if([[[[[window subviews] lastObject] subviews] lastObject] isKindOfClass:[PurchasePopup class]] || [[[[[window subviews] lastObject] subviews] lastObject] isKindOfClass:[DropOffPurchasePopup class]] || [[[[[window subviews] lastObject] subviews] lastObject] isKindOfClass:[PostFeedbackContactView class]])
            {
                [[[[[window subviews] lastObject] subviews] lastObject] removeFromSuperview];
            }
        
            if([[WooScreenManager sharedInstance] isDrawerOpen])
            {
                [[[WooScreenManager sharedInstance] oHomeViewController] closeDrawer:[UIButton new]];
            }
            
            int currentTab = [[[[WooScreenManager sharedInstance] oHomeViewController] currentTabBarIndexObjc] intValue];
            if(currentTab != 2 && currentTab != 3)
            {
                //pop current navigation
                UINavigationController *currentNavigationController = [[[[WooScreenManager sharedInstance] oHomeViewController] childViewControllers] objectAtIndex:currentTab];
                [currentNavigationController popToRootViewControllerAnimated:NO];
                
                if(currentTab == 1)
                {
                    DiscoverViewController *discoverVc = [[currentNavigationController viewControllers] firstObject];
                    [[DiscoverProfileCollection sharedInstance] switchCollectionMode:CollectionModeDiscover];
                    [discoverVc makeProfileDeckSmall];
                    if([[DiscoverProfileCollection sharedInstance] collectionMode] == CollectionModeMy_PROFILE)
                    {
                    
                        [discoverVc myProfileBackButtonPressed:[UIButton new]];

                    }
                    
                }
               
            }
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            
            if ([[[DiscoverProfileCollection sharedInstance] discoverModelCollection] count] > 0) {
                [[DiscoverProfileCollection sharedInstance] setCollectionMode:CollectionModeDiscover];
            }
            else{
                [[DiscoverProfileCollection sharedInstance] setCollectionMode:CollectionModeDiscover_EMPTY];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"moveToChatRoom" object:matchId userInfo:nil];
        });
    }];
}

- (void)showNewChatMessageFromTop: (NSString *)message{
    TopChatView *chatView = [TopChatView sharedInstance];
    [chatView setNotificationTypeForView:chatBoxLanding];
    [chatView showNewChatMessageFromTop:message];
//    [chatView showNewChatMessageFromTop:message withHeader:@"" andUserImage:@""];
}



- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray * __nullable restorableObjects))restorationHandler{
    
    [[AppsFlyerTracker sharedTracker] continueUserActivity:userActivity restorationHandler:restorationHandler];

    NSLog(@"URL» %@",userActivity.webpageURL);
    if([userActivity.webpageURL.absoluteString containsString:@"https://siafca45adb2514a6f85674c12009ea30c.truecallerdevs.com"])
    {
        return [[TCTrueSDK sharedManager] application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
    }
    NSURL *activityLinkUrl = nil;
    NSLog(@"Activity link url %@", activityLinkUrl);
    if ([userActivity.webpageURL.absoluteString containsString:@"ios_url"]){
        NSArray *activityComponents = [userActivity.webpageURL.absoluteString componentsSeparatedByString:@"&"];
        NSString *iOSLink = nil;
        for (NSString *keyValuePair in activityComponents)
        {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
            NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
            if([key isEqualToString:@"af_ios_url"]){
                iOSLink = value;
                activityLinkUrl = [NSURL URLWithString:iOSLink];
            }
        }
    }
    if (activityLinkUrl == nil){
        activityLinkUrl = userActivity.webpageURL;
    }
    
    BOOL handled = [[FIRDynamicLinks dynamicLinks]
                    handleUniversalLink:activityLinkUrl
                    completion:^(FIRDynamicLink * _Nullable dynamicLink,
                                 NSError * _Nullable error) {
                        FIRDynamicLinkComponents *params = [FIRDynamicLinkComponents componentsWithLink:userActivity.webpageURL domainURIPrefix:@"itunes.apple.com"];
                        NSLog(@">>>>>FIR DYNAMIC params :%@",params);
                        NSLog(@">>>>>FIR DYNAMIC Actual link =========  %@",params.link);
                        NSLog(@"====FIR DYNAMIC Our provided Link========= %@",dynamicLink.url);
                        
                        if(dynamicLink.url){
                            NSString *urlString = nil;
                            if ([dynamicLink.url.absoluteString containsString:@"utm_campaign"]){
                                NSArray *urlStartComponents = [dynamicLink.url.absoluteString componentsSeparatedByString:@"?"];
                                urlString = [urlStartComponents lastObject];
                            }
                            NSString *urlAbsoluteString = nil;
                            if (urlString != nil){
                                urlAbsoluteString = urlString;
                            }
                            else{
                                urlAbsoluteString = params.link.absoluteString;
                            }
                            NSArray *urlComponents = [urlAbsoluteString componentsSeparatedByString:@"&"];

                            
                            NSLog(@"urlcomponents == %@",urlComponents);
                            NSMutableDictionary *dictParams = [[NSMutableDictionary alloc] init];
                            for (NSString *keyValuePair in urlComponents)
                            {
                                NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
                                NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
                                NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
                                
                                if([key isEqualToString:@"utm_campaign"] || [key isEqualToString:@"utm_source"] || [key isEqualToString:@"utm_medium"] || [key isEqualToString:@"utm_term"] || [key isEqualToString:@"utm_content"] || [key isEqualToString:@"ius"])
                                {
                                    [dictParams setObject:value forKey:key];
                                }
                                
                            }
                            
                            if (![dictParams objectForKey:@"ius"]){
                                if([params.link.absoluteString containsString:@"ius"]){
                                    NSArray *urlStartComponents = [params.link.absoluteString componentsSeparatedByString:@"?"];
                                    urlString = [urlStartComponents lastObject];
                                    NSArray *iusDataArray= [urlString componentsSeparatedByString:@"&"];
                                    for (NSString *keyValuePair in iusDataArray){
                                        if ([keyValuePair containsString:@"ius"]){
                                            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
                                            NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
                                            NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
                                            [dictParams setValue:value forKey:key];
                                        }
                                    }
                                }
                            }
                            //Rdirect acc to utmparams
                            [self redirectAccordingToUTMParms:dictParams];
                        }
                    }];

    
    return handled;
}



-(void)detectNetworkTypeAndUpdateImageDownloaderNotification{
    
    CTTelephonyNetworkInfo *telephonyInfo = [CTTelephonyNetworkInfo new];
    
    NSLog(@"Current Radio Access Technology: %@", telephonyInfo.currentRadioAccessTechnology);
    
    if ([self getSimpleNameForNetworkType:telephonyInfo.currentRadioAccessTechnology] == nil ){
        self.networkInUse = @"";
    }else{
        self.networkInUse = [self getSimpleNameForNetworkType:telephonyInfo.currentRadioAccessTechnology];
    }
    [NSNotificationCenter.defaultCenter addObserverForName:CTRadioAccessTechnologyDidChangeNotification
                                                    object:nil
                                                     queue:nil
                                                usingBlock:^(NSNotification *note)
    {
        if ([self getSimpleNameForNetworkType:telephonyInfo.currentRadioAccessTechnology] == nil ){
            self.networkInUse = @"";
        }else{
        self.networkInUse = [self getSimpleNameForNetworkType:telephonyInfo.currentRadioAccessTechnology];
        }}];
}

-(NSString *)getCurrentConnectednetwork{
    
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    
    if (reachability.isReachable) {
        if (reachability.isReachableViaWiFi) {
            return @"WiFi";
        }else if (reachability.isReachableViaWWAN){
            return _networkInUse;
        }
    }
    return @"";
}

-(NSString *)getSimpleNameForNetworkType:(NSString *)radioAccessTechnology{
    
    
    if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS]) {
        return @"GPRS";
    } else if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge]) {
        return @"2G";
    } else if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyWCDMA]) {
        return @"3G";
    } else if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSDPA]) {
        return @"3G";
    } else if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSUPA]) {
        return @"3G";
    } else if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMA1x]) {
        return @"2G";
    } else if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]) {
        return @"3G";
    } else if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]) {
        return @"3G";
    } else if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]) {
        return @"3G";
    } else if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyeHRPD]) {
        return @"3G";
    } else if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {
        return @"4G";
    }
    return @"";
}

-(void)migrateDataOnUpdate{
    //Mymathces, Crush, boost/Visitor
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kCheckUpgradeForAll]) { // Check for Boost & Crush Upgdare for Group Id
        
        
        NSArray *arrCrush = [CrushesDashboard getAllCrushesFromDB];
        if ([arrCrush count] > 0) {
            
            for (int index = 0 ; index < [arrCrush count]; index ++) {
                
                if (([[arrCrush objectAtIndex:index] groupId] == 0) | ![[arrCrush objectAtIndex:index] groupId]) {
                    
                    [[arrCrush objectAtIndex:index] setGroupId:[NSNumber numberWithInt:0]];
                    
                    
                    NSString *crushExpiryTime = [[arrCrush objectAtIndex:index] crushTimestamp];
                    long long int serverTimeInMilliSecs = [crushExpiryTime longLongValue];
                    NSDate *dateToBeStoredInDb = [NSDate dateWithTimeIntervalSince1970:serverTimeInMilliSecs/1000];
                    
                    [[arrCrush objectAtIndex:index] setCrushTimestampCurrent:dateToBeStoredInDb];
                    
                    
                    [STORE saveContext];
                    
                }
                
            }
        }
        
        NSArray *arrBoost = [MeDashboard getAllBoostProfiles];
        if ([arrBoost count] > 0) {
            for (int index = 0 ; index < [arrCrush count]; index ++) {
                if (([[arrBoost objectAtIndex:index] groupId] == 0) | ![[arrBoost objectAtIndex:index] groupId]) {
                    
                    [[arrBoost objectAtIndex:index] setGroupId:[NSNumber numberWithInt:0]];
                    
                    [STORE saveContext];
                    
                }
            }
        }
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kCheckUpgradeForAll];
        
    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kCheckUpgradeFor3_0_2]) {
        
        NSArray *myMatchesArray = [MyMatches getAllMatches];
        
        if (myMatchesArray && [myMatchesArray count] > 0) {
            for (MyMatches *matchedUseData in myMatchesArray) {
                if (matchedUseData.layerChatID && ([[APP_Utilities validString:matchedUseData.layerChatID] length] > 0) && !([matchedUseData.layerChatID containsString:@"dummyChatId"])) {
                    [matchedUseData setMatchedUserStatus:[NSNumber numberWithInt:MATCHED_USER_STATUS_CONNECTED_TO_LAYER]];
                }
            }
            [STORE saveContext];
        }
        
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kCheckUpgradeFor3_0_2];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}
-(BOOL)getIsFetchingMatchDataFromServerValue{
    return isFetchingMatchDataFromServer;
}



#pragma mark - Pushkit Delegates

-(void)registerForVOIPPush
{
    //Adding pushkit code for voipRegistration
    PKPushRegistry *pushRegistry = [[PKPushRegistry alloc]initWithQueue:dispatch_get_main_queue()];
    pushRegistry.delegate = self;
    pushRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
    
}
-(void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(PKPushType)type
{
    if(type == PKPushTypeVoIP)
    {
        NSData *tokenData = credentials.token;
//        NSString *tokenString = [[NSString alloc] initWithData:tokenData encoding:NSUTF8StringEncoding];
        //send token to server
        NSLog(@"PUSHKIT tokenString %@",tokenData);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self sendDeviceTokedToServer:[[NSUserDefaults standardUserDefaults] objectForKey:kDeviceToken] andPushKitToken:tokenData];
        });
    }
    
}

-(void) pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type
{
    
    NSLog(@"push aa rhe hai voip k didReceiveIncomingPushWithPayload");
    NSLog(@"didReceiveIncomingPushWithPayload %@",payload);
    NSDictionary *payloadDict = [payload.dictionaryPayload objectForKey:@"aps"];
    NSString  *message = [payloadDict objectForKey:@"alert"];
    NSLog(@"Payload Dictionary and Message %@ %@",payload.dictionaryPayload,message);
    NSLog(@"Log State %ld",(long)[[UIApplication sharedApplication] applicationState]);
    if(type == PKPushTypeVoIP)
    {
        
        NSLog(@"PKPushTypeVoIP");
//        if( [[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground)
//           {
               NSString *handle = [payload.dictionaryPayload objectForKey:@"handle"];
               //            NSString * uuidString = [payload.dictionaryPayload objectForKey:@"uuid"];
                BOOL isVideo = [payload.dictionaryPayload objectForKey:@"isVideo"];
                NSUUID *uuid = [[NSUUID alloc]init];
        
//        [[AgoraConnectionManager sharedManager] recieveIncomingCallFRomUuid:uuid withHandle:handle withVideo:isVideo];
        
        NSLog(@"isme uuid kya aa rhi hai %@",uuid);
                if (uuid)
                {
                    NSLog(@"UUID %@ %d",uuid,isVideo);
                    [[AgoraConnectionManager sharedManager] recieveIncomingCallFRomUuid:uuid withHandle:handle withVideo:isVideo];
                }
//           }

    }
 
    
}
- (void)pushRegistry:(PKPushRegistry *)registry didInvalidatePushTokenForType:(PKPushType)type
{
    NSLog(@"PUSHKIT TOKEN INVALIDATED");
    
}


- (void)conversationReadByCurrentUser:(NSString *)userId withGroupId:(NSNumber *)groupId {
    NSLog(@"Appdelegate onAllMessagesRead %@", userId);
}

- (void)onAllMessagesRead:(NSString *)userId {
    NSLog(@"Appdelegate onAllMessagesRead %@", userId);
}

- (void)onChannelUpdated:(ALChannel *)channel {
    
}

- (void)onConversationDelete:(NSString *)userId withGroupId:(NSNumber *)groupId {
    
}

- (void)onMessageDeleted:(NSString *)messageKey {
    
}

- (void)onMessageDelivered:(ALMessage *)message {
    NSLog(@"AppDelegate onMessageDelivered %@", message);
    [[ApplozicChatManager sharedApplozicChatManager] onMessageDelivered:message];

}

- (void)onMessageDeliveredAndRead:(ALMessage *)message withUserId:(NSString *)userId {
    NSLog(@"AppDelegate onMessageDeliveredAndRead %@", message);
}

- (void)onMessageReceived:(ALMessage *)alMessage {
    NSLog(@"%@ onMessageReceived has sent you %@", alMessage.to, alMessage.message);
    
   [[ApplozicChatManager sharedApplozicChatManager] onMessageReceived:alMessage];
}

- (void)onMessageSent:(ALMessage *)alMessage {
    NSLog(@"%@",alMessage.status);
    NSLog(@"onMessageSent you sent to this %@ to %@", alMessage.to, alMessage.message);
    [[ApplozicChatManager sharedApplozicChatManager] onMessageSent:alMessage];

}

- (void)onMqttConnected {
    
   
}

- (void)onMqttConnectionClosed {
    // [_applozic unSubscribeToTypingStatusForOneToOne];
    //[_applozic unsubscribeToConversation];
    NSLog(@"AppDelegate onMqttConnectionClosed");
}

- (void)onUpdateLastSeenAtStatus:(ALUserDetail *)alUserDetail {
    NSLog(@"AppDelegate onUpdateLastSeenAtStatus");
}

- (void)onUpdateTypingStatus:(NSString *)userId status:(BOOL)status {
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
     if (state == UIApplicationStateActive)
    {
        [[ApplozicChatManager sharedApplozicChatManager] onUpdateTypingStatus:userId status:status];
    }
}

- (void)onUserBlockedOrUnBlocked:(NSString *)userId andBlockFlag:(BOOL)flag {
    NSLog(@"AppDelegate onUserBlockedOrUnBlocked");
    
}

- (void)onUserDetailsUpdate:(ALUserDetail *)userDetail {
    NSLog(@"AppDelegate onUserDetailsUpdate");
}

- (void)onUserMuteStatus:(ALUserDetail *)userDetail {
    NSLog(@"AppDelegate onUserMuteStatus");
}

-(void)listenToNetworkReachability{
    self.internetConnectionReach = [ALReachability reachabilityForInternetConnection];
    
    self.internetConnectionReach.reachableBlock = ^(ALReachability * reachability)
    {
                NSString * temp = [NSString stringWithFormat:@" InternetConnection Says Reachable(%@)", reachability.currentReachabilityString];
         NSLog(@"%@", temp);
    };
    
    self.internetConnectionReach.unreachableBlock = ^(ALReachability * reachability)
    {
                NSString * temp = [NSString stringWithFormat:@"InternetConnection Block Says Unreachable(%@)", reachability.currentReachabilityString];
          NSLog(@"%@", temp);
    };
    
    [self.internetConnectionReach startNotifier];

}

-(void)reachabilityChanged:(NSNotification*)note
{
    ALReachability * reach = (ALReachability*)[note object];
    
    if (reach == self.internetConnectionReach)
    {
        if([reach isReachable])
        {
            ALSLog(ALLoggerSeverityInfo, @"========== IF internetConnectionReach ============");
            [_applozic subscribeToConversation];
            [_applozic subscribeToTypingStatusForOneToOne];
            [self getMessagesFromApplozic];
            
            ALUserService *userService = [ALUserService new];
            [userService blockUserSync: [ALUserDefaultsHandler getUserBlockLastTimeStamp]];
            
        }
        else
        {
            ALSLog(ALLoggerSeverityInfo, @"========== ELSE internetConnectionReach ============");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NETWORK_DISCONNECTED" object:nil];
        }
    }
    
}

- (void)getMessagesFromApplozic{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [ALMessageService getLatestMessageForUser:[ALUserDefaultsHandler getDeviceKeyString] withCompletion:^(NSMutableArray *messageArray, NSError *error) {
            
            if(error)
            {
                ALSLog(ALLoggerSeverityError, @"ERROR IN LATEST MSG APNs CLASS : %@",error);
            }else{
                NSLog(@"New Messages received %@", messageArray);
                if(messageArray && [messageArray count]>0){
                    for(ALMessage *message in messageArray){
                        [[ApplozicChatManager sharedApplozicChatManager] onMessageReceived:message];
                    }
                }
            }
        }];
    });
}

-(ApplozicClient*)getAppLozicClient{
    return _applozic;
}

-(void)onConversionDataReceived:(NSDictionary*) installData {
    
    
    //Handle Conversion Data (Deferred Deep Link)
    
}

-(void)onConversionDataRequestFailure:(NSError *) error {
    
    NSLog(@"%@",error);
}


- (void) onAppOpenAttribution:(NSDictionary*) attributionData {
    [self handleDeepLinkWithURL:[attributionData objectForKey:@"af_dp"] withSourceApplication:nil];
    
    //Handle Deep Link
}

- (void) onAppOpenAttributionFailure:(NSError *)error {
    NSLog(@"%@",error);
}



// event handler for uploading the images to server on background
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler{
    
    NSString *Identifier =  [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
    
}

@end
