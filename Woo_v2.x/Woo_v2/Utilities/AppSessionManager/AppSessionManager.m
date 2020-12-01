//
//  AppSessionManager.m
//  Woo_v2
//
//  Created by Suparno Bose on 03/12/15.
//  Copyright © 2015 Woo. All rights reserved.
//

#import "AppSessionManager.h"
#import <Crashlytics/Crashlytics.h>
#import "BoostModel.h"
#import "CrushModel.h"
#import "WooPlusModel.h"
#import "BoostAPIClass.h"
#import "CrushAPIClass.h"
#import "BoostDashboard.h"
#import "MeDashboard.h"
#import "CrushesDashboard.h"
#import "AppLaunchApiClass.h"
#import "LikedMeAPIClass.h"
#import "LoginModel.h"
#import "LikedMeAPIClass.h"
#import "SkippedProfileAPIClass.h"
#import "ChatRoom.h"
#import "BoostDashboard.h"
#import "CrushesDashboard.h"
#import "LikedMe.h"
#import "SkippedProfiles.h"
#import "FreeTrailModel.h"
#import "GetProductAPIClass.h"

#import "Woo_v2-Swift.h"
#import "PurchaseProductDetailModel.h"
#import "DiscoverAPIClass.h"
#import "InviteFriendAPIClass.h"
#import "AgoraConnectionManager.h"
#import <AVFoundation/AVFoundation.h>

@import FirebaseInstanceID;
@import FirebaseInstallations;

#define UserDefaults [NSUserDefaults standardUserDefaults]

#define kAppLaunchTime  @"AppLaunchTime"
#define kAppFGTime      @"AppForeGroundTime"

@interface AppSessionManager()
@property (nonatomic) NSInteger currentTime;
@property (nonatomic) NSTimer * outOfLikeTimer;
@end

@implementation AppSessionManager


+ (id)sharedManager {
    static AppSessionManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[super allocWithZone:NULL] init];
    });
    return sharedManager;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appComesFG)
//                                                     name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appGoesBG)
                                                     name:UIApplicationDidEnterBackgroundNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(makeAppLaunchCallToServer)
//                                                     name:kUserLoggedInSuccessfullyNotification
//                                                   object:nil];
    }
    return self;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedManager];
}

- (void)launchedFreshApp{
    NSDate *firstLaunchDate = [NSDate date];
    [UserDefaults setObject:firstLaunchDate forKey:kAppLaunchTime];
    [UserDefaults setObject:[NSNumber numberWithInt:0] forKey:kAppFGTime];
    [UserDefaults synchronize];
}

//- (void)appComesFG{
//    [self makeAppLaunchCallToServer];
//}

- (void)appGoesBG{
    NSUserDefaults *ud      = UserDefaults;
    NSDate *lastLaunchDate  = [ud objectForKey:kAppLaunchTime];
    double appFGTime        = [[ud objectForKey:kAppFGTime] doubleValue];
    
    NSDate *nowDate = [NSDate date];
    NSTimeInterval executionTime = [nowDate timeIntervalSinceDate:lastLaunchDate];
    appFGTime = appFGTime + executionTime ;
    NSLog(@"executionTime = %f", appFGTime);
    
    [ud setObject:[NSNumber numberWithInt:appFGTime] forKey:kAppFGTime];
    [ud synchronize];
}

-(void)makeAppLaunchCallToServer{
    [self moveprofilesToMeDashboard];
   //[self checkForOutOfLike];
    
    NSString *wooUserId = [UserDefaults objectForKey:kWooUserId];
    if (![APP_Utilities reachable]) {
        [self makeAppLaunchCallToWhenConnectionResumes];
        return;
    }
    
    [APP_DELEGATE logEventOnFacebook:@"App_Launch"];

    if ([[APP_Utilities validString:wooUserId] length]>0) {
        
        NSString * language = [APP_Utilities getDeviceLocaleCode];
        
        @try {
            [CrashlyticsKit setUserIdentifier:wooUserId];
        }
        @catch (NSException *exception) {
            //            do nothing here
        }
        
        NSString *appLaunchURL = [NSString stringWithFormat:@"%@%@?wooId=%@&locale=%@",kBaseURLV8,kAppLaunchAPI,wooUserId,language];
        if ([UserDefaults objectForKey:kProfileCompletenessScoreKey]) {
            appLaunchURL = [NSString stringWithFormat:@"%@&profileCompletenessScore=%@",appLaunchURL,
                                                                                       [UserDefaults objectForKey:kProfileCompletenessScoreKey]];
        }
        if ([UserDefaults objectForKey:kAppFGTime]) {
            double appLastFGTime        = [[UserDefaults objectForKey:kAppFGTime] doubleValue];
            appLaunchURL = [NSString stringWithFormat:@"%@&wooAppSession=%d",appLaunchURL,(int)(appLastFGTime*100)];
        }
//        NSLog(@"appLaunchURL >>> :%@",appLaunchURL);
        [[AppLaunchApiClass sharedManager] getNotificationConfigOptionsWithCompletionBlock:nil];
        
        WooRequest *wooRequestObj = [[WooRequest alloc]init];
        wooRequestObj.url =appLaunchURL;
        wooRequestObj.time =0;
        wooRequestObj.requestParams =nil;
        wooRequestObj.methodType =postRequest;
        wooRequestObj.numberOfRetries =3;
        wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
        wooRequestObj.requestType = makeAppLaunchCallToServer;
        [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
            if (requestType == makeAppLaunchCallToServer) {
                statusCode = 0;
                [self launchedFreshApp];
//                NSLog(@"response : %@",response);
                if (statusCode == 401) {
                    
                    if (![UserDefaults boolForKey:kIsUpdateVersion2_1] && [UserDefaults boolForKey:kIsLoginProcessCompleted]) {
                        if (![UserDefaults objectForKey:kWooEncryptionTokenFromServer] && ([[UserDefaults objectForKey:kWooEncryptionTokenFromServer] length]<1)) {
                            //Make login call to get token from the server
                            [APP_Utilities makeSilentLoginCallToFetchWooSecurityToken];
                        }
                    }
                    else{
                        U2AlertView *alert = [[U2AlertView alloc] init];
                        
                        [alert setU2AlertActionBlockForButton:^(int tagValue , id data){
                            [self performSelector:@selector(showLoginScreen)];
                            
                        }];
                        
                        [alert alertWithHeaderText:NSLocalizedString(@"Authentication error",nil) description:NSLocalizedString(@"Something unexpected has happened. Please login again",nil) leftButtonText:NSLocalizedString(@"CMP00356", nil) andRightButtonText:nil];
                        [alert show];
                    }
                    
                }
                
                if (response){
                    //upgrade Testing
                    
                    [[LoginModel sharedInstance] setAppLozicUserId:[response objectForKey:@"appLozicUserId"]];
                    [[LoginModel sharedInstance] setAppLozicToken:[response objectForKey:@"appLozicToken"]];
                    
                    if([response valueForKey:@"upgradeApp"] != nil){
                        if([[response valueForKey:@"upgradeApp"] boolValue] == true){
                        
                            NSLog(@"%d",[[response valueForKey:@"forceUpgrade"] boolValue]);
                            if([[response valueForKey:@"forceUpgrade"] boolValue] == true){
                                
                                UIAlertController *forceUpgradeAlert = [UIAlertController alertControllerWithTitle:kUpgradepopupHeader message:kUpgradepopupcontent preferredStyle:UIAlertControllerStyleAlert];
                                
                                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Update", nil) style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action) {
                                         NSLog(@"Upgrade action is here");
                                         NSString *iTunesLink = kAppleStoreUrl;
                                         
                                         UIApplication *application = [UIApplication sharedApplication];
                                         NSURL *URL = [NSURL URLWithString:iTunesLink];
                                         [application openURL:URL options:@{} completionHandler:^(BOOL success) {
                                             if (success) {
                                                 NSLog(@"Going to app store for update");
                                             }
                                         }];
                                         
                                     }];
                                
                                [forceUpgradeAlert addAction:okAction];
                                [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:forceUpgradeAlert animated:YES completion:nil];
                            }else{
                                 UIAlertController *normalUpgradeAlert = [UIAlertController alertControllerWithTitle:kUpgradepopupHeader message:kNormalUpgradepopupcontent preferredStyle:UIAlertControllerStyleAlert];
                                
                                
                                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Update", nil) style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction *action) {
                                             NSLog(@"Upgrade action is here");
                                             NSString *iTunesLink = @"https://apps.apple.com/in/app/woo-the-dating-app-women-love/id885397079";
                                             
                                             UIApplication *application = [UIApplication sharedApplication];
                                             NSURL *URL = [NSURL URLWithString:iTunesLink];
                                             [application openURL:URL options:@{} completionHandler:^(BOOL success) {
                                                 if (success) {
                                                     NSLog(@"Going to app store for update");
                                                 }
                                             }];
                                             
                                         }];
                                
                                UIAlertAction *laterAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Later",nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                                    NSLog(@"Later action is here");
                                }];
                                
                                [normalUpgradeAlert addAction:okAction];
                                [normalUpgradeAlert addAction:laterAction];
                                
                                [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:normalUpgradeAlert animated:YES completion:nil];
                            }
                            
                        }
                    }
                    
                    if(([response objectForKey:@"isVisible"] != nil) && [[[[DiscoverProfileCollection sharedInstance] myProfileData ]gender] isEqualToString:@"FEMALE"]){
                        
                        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"validFemaleEventSent"];
                        [APP_DELEGATE sendFirebaseEvent:@"VALID_FEMALE" andScreen:@""];
                        [APP_DELEGATE sendFirebaseEvent:@"ACTUAL_VALID_FEMALE" andScreen:@""];
                        [APP_DELEGATE logEventOnFacebook:@"Achievements Unlocked"];
                        [APP_DELEGATE logEventOnFacebook:@"Contact"];
                        
                        [APP_DELEGATE sendFirebaseEvent:@"FIREBASE_EVENT_FOR_FEMALE_VISIBLE" andScreen:@""];
                        [BoostProductsAPICalss makePopupEventAPIwithType:@"FIREBASE_EVENT_FOR_FEMALE_VISIBLE"];
                    }
                    
                    if(([response objectForKey:@"isVisible"] != nil) && [[[[DiscoverProfileCollection sharedInstance] myProfileData ]gender] isEqualToString:@"MALE"]){
                        
                        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"validMaleEventSent"];
                        [APP_DELEGATE sendFirebaseEvent:@"FIREBASE_EVENT_FOR_MALE_VISIBLE" andScreen:@""];
                        [BoostProductsAPICalss makePopupEventAPIwithType:@"FIREBASE_EVENT_FOR_MALE_VISIBLE"];
                        
                    }
                    
                    if(([response objectForKey:@"isXMen"] != nil)){
                        
                        [APP_DELEGATE sendFirebaseEvent:@"FIREBASE_EVENT_FOR_XMEN" andScreen:@""];
                        [BoostProductsAPICalss makePopupEventAPIwithType:@"FIREBASE_EVENT_FOR_XMEN"];
                        
                    }
                    
                    
                    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"expiringForMeSectionShown"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    NSString *actualVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];

                        if ([[APP_Utilities validString:[response objectForKey:@"appVersion"]] length] > 0){
                            
                            NSString *requiredVersion = [APP_Utilities validString:[response objectForKey:@"appVersion"]];
                            if ([requiredVersion compare:actualVersion options:NSNumericSearch] == NSOrderedSame && ((![[NSUserDefaults standardUserDefaults] valueForKey:@"olderAppVersion"]) ||
                                ([[[NSUserDefaults standardUserDefaults] valueForKey:@"olderAppVersion"] compare:actualVersion options:NSNumericSearch] == NSOrderedAscending))) {
                                
                                //remove me data
                                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCrushDashboardTimestampKey];
                                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kBoostDashboardTimestampKey];
                                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSkippedProfileDashboardTimeStampKey];
                                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLikedMeDashboardTimestampKey];
                                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAnswersRestored];
                                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAnswersUpdatedTimestamp];
                                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kQuestionsRestored];
                                [[NSUserDefaults standardUserDefaults] setValue:actualVersion forKey:@"olderAppVersion"];

//                                [[NSUserDefaults standardUserDefaults] setBool:true forKey:kUpgradeIsCompleteToClearUpMeSectionData];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                                if([AppLaunchModel sharedInstance].isVoiceCallingOnForIOS)
                                {
                                    [[AgoraConnectionManager sharedManager]loginToAgora:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] withCompletionHandler:^(BOOL completed) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            
                                            [[NSNotificationCenter defaultCenter] postNotificationName:KLoggedInToAgora object:nil];

                                            if([[Utilities sharedUtility] checkMicrophonePermission] == 0)
                                            {
                                                UIAlertController *microphoneAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Woo", @"Woo") message:NSLocalizedString(@"To enable calls , Woo needs access to your iPhone's microphone. Tap settings and turn on Microphone.",@"To enable calls , Woo needs access to your iPhone's microphone. Tap settings and turn on Microphone.") preferredStyle:UIAlertControllerStyleAlert];
                                                
                                                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                                                    
                                                }];
                                                [microphoneAlert addAction:cancelAction];
                                                
                                                UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                }];
                                                [microphoneAlert addAction:settingsAction];
                                                
                                                [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:microphoneAlert animated:YES completion:nil];

                                            }
                                        });
                                        
                                        
                                    }];
                                
                                }
                                
                                [APP_DELEGATE.store deleteAllDataInMeSection:@[@"MeDashboard",@"LikedMe",@"SkippedProfiles",@"CrushesDashboard",@"MyQuestions",@"Answers"]];
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                    //Also migrate chat messages for upgrade case
                                    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isChatRoomMigrationDone"] == NO)
                                    {
                                        //migrate chat room
                                        [self migrateChatRoomData];
                                    }
                                });
                            }
                            
                        }

                    if ([response objectForKey:kLatestAnswerTimestampKey]) {
                        
                        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:[AppLaunchModel sharedInstance].answersUpdateTime] forKey:kLatestAnswerTimestampKey];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        if([[response objectForKey:kLatestAnswerTimestampKey] longLongValue] > [AppLaunchModel sharedInstance].answersUpdateTime)
                        {
                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAnswersRestored];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        }

                        NSLog(@"AppLaunch  answersUpdateTime %lld",[AppLaunchModel sharedInstance].answersUpdateTime);
                        NSLog(@"answerLastUpdatedTime userdefaults %lld",[[[NSUserDefaults standardUserDefaults] objectForKey:kLatestAnswerTimestampKey] longLongValue]);
                    }
                    
                    /**
                     *  Code for updating answers on the basis of timestamp
                     */
                    NSLog(@"AppLaunch answersUpdateTime %lld",[AppLaunchModel sharedInstance].answersUpdateTime);
                    
                    
                    

                    
                    [[FIRInstanceID instanceID] instanceIDWithHandler:^(FIRInstanceIDResult * _Nullable result,
                                                                        NSError * _Nullable error) {
                      if (error != nil) {
                        NSLog(@"Error fetching remote instance ID: %@", error);
                      } else {
                        NSLog(@"Remote instance ID token: %@", result.token);
                          NSString* message =
                          [NSString stringWithFormat:@"%@", result.token];
                          self->_refreshedToken = message;
                      }
                    }];
                    
                    if ([response objectForKey:@"fcmToken"] && self->_refreshedToken){
                        NSString *serverFcmToken = [response objectForKey:@"fcmToken"];
                        if (![serverFcmToken isEqualToString:self->_refreshedToken]){
                            [APP_DELEGATE sendFCMPushTokenToServer];
                            [APP_DELEGATE sendFirebaseEvent:@"FCM_TOKEN_MISMATCH" andScreen:@""];
                        }
                    }
                    [APP_DELEGATE updateQuestionAnswersOnUI];
                    
                    [self handleSuccessLaunchCallToServer:response];

                }
                else{
                    [self makeAppLaunchCallToWhenConnectionResumes];
                }
                
                if ([UserDefaults boolForKey:kIsUserOnLayerChatOnly]) {
                    if ([[MyMatches getAllMatches] count]>0 && [UserDefaults objectForKey:kWooUserId]) {
                        [(AppDelegate*)([UIApplication sharedApplication].delegate) connectToLayer];
                        [APP_DELEGATE connectToApplozic];

                    }
                }
                else{
                    if ([[MyMatches getAllMatches] count]>0 && [UserDefaults objectForKey:kWooUserId]) {
                        //                        [self fetchChatMessagesOnPush];
                        [(AppDelegate*)([UIApplication sharedApplication].delegate) connectToLayer];
                        [APP_DELEGATE connectToApplozic];
                        
                    }
                }
                [[NSNotificationCenter defaultCenter]postNotificationName:@"AppLaunchReceived"
                                                                   object:nil];
            }
        } shouldReachServerThroughQueue:YES];
        
        [self makeLikeCallFromMatchboxIfAnyCallIsPending];
    }
}

-(void)moveprofilesToMeDashboard{
    
    if([[NSUserDefaults standardUserDefaults]
        boolForKey:kBoostDashBoardMigration] == NO){
    NSArray *vistors = [BoostDashboard getAllBoostProfiles];
    if ([vistors count] > 0){
    [MeDashboard migrateThingsFromVisit:vistors forType:VisitorMe withInsertionCompletionHandler:^(BOOL isInsertionCompleted) {
         if(isInsertionCompleted){
         [APP_DELEGATE.store deleteAllDataInMeSection:@[@"BoostDashboard"]];
              [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kBoostDashBoardMigration];
         }
    }];
    }else{
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kBoostDashBoardMigration];
    }
    }
    if([[NSUserDefaults standardUserDefaults]
        boolForKey:kLikedMeMigration] == NO){
    NSArray *likedMeData = [LikedMe getAllLikedMeProfiles];
          if ([likedMeData count] > 0){
           [MeDashboard migrateThingsFromVisit:likedMeData forType:likedMe withInsertionCompletionHandler:^(BOOL isInsertionCompleted) {
               if(isInsertionCompleted){
               [APP_DELEGATE.store deleteAllDataInMeSection:@[@"LikedMe"]];
                   [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kLikedMeMigration];
                   
               }
           }];
          }else{
              [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kLikedMeMigration];
          }
    }
}

-(void)migrateChatRoomData
{
    NSArray *matches = [MyMatches getAllMatches];
    if ([matches count]>0 && [[ChatMessage getAllMessage] count] > 0)
    {
        for(int matchIndex =0; matchIndex<[matches count]; matchIndex++)
        {
            MyMatches *match = [matches objectAtIndex:matchIndex];
            [ChatMessage updateChatMessagesForChatRoomId:match.matchedUserId withNewChatRoomId:match.matchId withUpdationHandler:^(BOOL success) {
                if(matchIndex == [matches count])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isChatRoomMigrationDone"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kChatRoomMigrationDone object:nil];
                    });
                }
            }];
           
        }
    }
}

-(void)makeLikeCallFromMatchboxIfAnyCallIsPending{
    NSArray *allPendingCallInMatchBox = [MyMatches getAllPendingMatched];
    
    for (MyMatches *matchDetail in allPendingCallInMatchBox) {
        [MyMatches updateMatchedUserStatus:MATCHED_USER_STATUS_ESTABLISHING_CONNECTION forChatRoomId:matchDetail.matchId withUpdationCompletionHandler:^(BOOL isUpdationCompleted) {
            [DiscoverAPIClass makeLikeCallWithParams:matchDetail.matchedUserId andSelectedTag:nil withTagId:nil andTagDTOType:nil  AndCompletionBlock:^(BOOL success, id reponse, int statusCode) {
                if (success) {
                    if (statusCode == 202) {
                        //user liked match not made
                        [MyMatches updateMatchedUserStatus:MATCHED_USER_STATUS_RETRY forChatRoomId:matchDetail.matchId withUpdationCompletionHandler:nil];
                    }
                    else if(statusCode == 200){
                        // user liked and matched
                        NSMutableDictionary *matchedUserDetail = [[NSMutableDictionary alloc] initWithDictionary:(NSDictionary *)[reponse objectForKey:@"matchEventDto"]];
                       // matchedUserDetail = [matchedUserDetail objectForKey:@"matchEventDto"];
                        //Adding chatID if there is no value
                        if (![matchedUserDetail objectForKey:@"chatId"] || [[APP_Utilities validString:[matchedUserDetail objectForKey:@"chatId"]] length] <= 0) {
                            [matchedUserDetail setObject:@"ApplozicChatId" forKey:@"chatId"];
                        }
                        if ([matchedUserDetail objectForKey:@"chatId"] && ([[APP_Utilities validString:[matchedUserDetail objectForKey:@"chatId"]] length] > 0) ) {
                            [MyMatches insertDataInMyMatchesFromArray:[NSArray arrayWithObject:matchedUserDetail] withChatInsertionSuccess:^(BOOL insertionSuccess) {
                                [MyMatches updateMatchedUserStatus:MATCHED_USER_STATUS_CONNECTED_TO_LAYER forChatRoomId:matchDetail.matchId withUpdationCompletionHandler:nil];
                            }];
                        }
                        else{
                            [MyMatches updateMatchedUserStatus:MATCHED_USER_STATUS_RETRY forChatRoomId:matchDetail.matchId withUpdationCompletionHandler:nil];
                        }
                    }
                }
                else{
                    [MyMatches updateMatchedUserStatus:MATCHED_USER_STATUS_RETRY forChatRoomId:matchDetail.matchId withUpdationCompletionHandler:nil];
                }
            }];
            
        }];
    }
}

#pragma mark Reading from refrerral url and taking its cookie

- (void)getCookieFromRefferalUrl{
    
    /* COMMENTED AND REMOVED BY LOKESH _ NOT IN USE _ GARBAGE CODE
    
    
    
    return;
//    NSHTTPURLResponse * response;
    NSURLResponse *response;
    NSError * error;
    NSMutableURLRequest *request;
    
    
    
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://172.30.33.105:8080/nvite/"]
                                           cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                       timeoutInterval:120];
//    [request setValue:@"12345" forHTTPHeaderField:@"fngrp"];
    NSLog(@"request header filed %@",[request allHTTPHeaderFields]);
    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        NSLog(@"response :%@",response);
        NSLog(@"response all header :%@",[response description]);
        NSLog(@">>>%@", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
        NSLog(@"connectionError :%@",connectionError);
    }];
    NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
    NSDictionary *headerDict = [(NSHTTPURLResponse *)response allHeaderFields];
    NSHTTPURLResponse * responseNew = (NSHTTPURLResponse *)response;
    NSLog(@"headerDict :%@",headerDict);
    NSLog(@"status code %ld",(long)responseNew.statusCode);
    NSLog(@"headerDict description :%@",headerDict.description);
    NSLog(@"headerDict : %@", [headerDict objectForKey:@"fngrp"]);
    NSArray * all = [NSHTTPCookie cookiesWithResponseHeaderFields:[responseNew allHeaderFields] forURL:[NSURL URLWithString:@"http://172.30.33.105:8080/nvite/"]];
    // test-nvite.getwooapp.com
    
    
    for (NSHTTPCookie *cookie in all) {
        NSLog(@"Name: %@ : Value: %@", cookie.name, cookie.value);
        NSLog(@"Comment: %@ : CommentURL: %@", cookie.comment, cookie.commentURL);
        NSLog(@"Domain: %@ : ExpiresDate: %@", cookie.domain, cookie.expiresDate);
        NSLog(@"isHTTPOnly: %@ : isSecure: %@", cookie.isHTTPOnly?@"yes":@"no", cookie.isSecure?@"yes":@"no");
        NSLog(@"isSessionOnly: %@ : path: %@", cookie.isSessionOnly?@"yes":@"no", cookie.path);
        NSLog(@"portList: %@ : properties: %@", cookie.portList, cookie.properties);
        
       // NSString *alipaySetCookieString = @"CAKEPHP=""; path=/nvite/; domain=test-nvite.getwooapp.com; expires=""";
      //  NSHTTPCookie * clok  = [alipaySetCookieString cookie];
       // NSLog(@"cookie.cid=%@",[cookie valueForKey:@"trm"]);
    }
    
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSHTTPCookie *cookie;
    for(cookie in [storage cookies]) {
        if([[cookie domain] rangeOfString:@"172.30.33.105:8080"].location != NSNotFound) {
            NSLog(@"cookie to be deleted:%@", cookie);
            [storage deleteCookie:cookie];
            NSMutableDictionary *cookieDict = [[NSMutableDictionary alloc] init];
            [[NSUserDefaults standardUserDefaults] setObject:cookieDict forKey:@"referralCookie"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
     
     */
}

-(void)handleSuccessLaunchCallToServer:(id)response{
    
    NSLog(@"every thing is allright");

    long long int matchUpdateTime = [[response objectForKey:@"lastMatchUpdateTime"] unsignedLongLongValue];

    NSDictionary *meSectionDto = [response objectForKey:@"meSectionDto"];

        if ([meSectionDto objectForKey:@"showExpirySectionLikedMe"]) {
            [[WooPlusModel sharedInstance] setShowExpiryEnabledForLikedMe:[[meSectionDto valueForKey:@"showExpirySectionLikedMe"] boolValue]];
        }
        
        if ([[response objectForKey:@"meSectionDto"] objectForKey:@"showExpirySectionSkipped"]) {
            [[WooPlusModel sharedInstance] setShowExpiryEnabledForSkippedProfiles:[[meSectionDto valueForKey:@"showExpirySectionSkipped"] boolValue]];
        }
        
        if ([[response objectForKey:@"meSectionDto"] objectForKey:@"showExpirySectionVisitors"]) {
            [[WooPlusModel sharedInstance] setShowExpiryEnabledForVisitors:[[meSectionDto valueForKey:@"showExpirySectionVisitors"] boolValue]];
        }
        
        if ([[response objectForKey:@"meSectionDto"] objectForKey:@"showMaskedProfilesLikedMe"]) {
            [[WooPlusModel sharedInstance] setMaskingEnabledForLikedMe:[[meSectionDto valueForKey:@"showMaskedProfilesLikedMe"] boolValue]];
        }
        
        if ([[response objectForKey:@"meSectionDto"] objectForKey:@"showMaskedProfilesSkipped"]) {
            [[WooPlusModel sharedInstance] setMaskingEnabledForSkippedProfiles:[[meSectionDto valueForKey:@"showMaskedProfilesSkipped"] boolValue]];
        }
        
        if ([[response objectForKey:@"meSectionDto"] objectForKey:@"showMaskedProfilesVisitors"]) {
            [[WooPlusModel sharedInstance] setMaskingEnabledForVisitors:[[meSectionDto valueForKey:@"showMaskedProfilesVisitors"] boolValue]];
        }

    NSString *storedTimestamp = [[NSUserDefaults standardUserDefaults] objectForKey:kServerTimestampKey];
    
    unsigned long long serverTimeStamp = [storedTimestamp longLongValue];

    [AppLaunchModel sharedInstance].lastMatchUpdateTime = matchUpdateTime;
    
    [APP_DELEGATE getMyMatchesForTimestamp:serverTimeStamp andUpdateTimeAfterDataInsertionWith:matchUpdateTime];
    
    [MyMatches deleteAllFailedMatchedAfter2HoursWithDeletionCompletionHandler:^(BOOL isDeletionCompleted) {
        
    }];
    
    long long int serverwooQuestionsTime = [[response objectForKey:@"wooQuestionLastUpdatedTime"] longLongValue];
    
    long long int storedWooQuestionsTime = [AppLaunchModel sharedInstance].wooQuestionLastUpdatedTime;
    
    if (serverwooQuestionsTime > storedWooQuestionsTime){
        [[AppLaunchApiClass sharedManager] getWooQuestions:storedWooQuestionsTime];
    }
    
    [[AppLaunchApiClass sharedManager] makeAppSyncCallForAppConfigOptions:response];
    [[AppLaunchModel sharedInstance] updateModelWithData:response];
    
//    if (([DiscoverProfileCollection sharedInstance].intentModelObject == nil ) ||  ([DiscoverProfileCollection sharedInstance].intentModelObject.modelHasBeenUpdatedByServer == nil) || [DiscoverProfileCollection sharedInstance].intentModelObject.modelHasBeenUpdatedByServer.boolValue == false)
//    {
//    }
    
//    [[AppLaunchApiClass sharedManager] getNotificationConfigOptions];
//
    [self deleteVisitor_LikedMe_CrushAnd_SkippedProfilesThatAreExpiredFromSystem];
    

    if ([[APP_Utilities validString:[response objectForKey:@"appVersion"]] length] > 0 && [[APP_Utilities validString:[response objectForKey:@"upgradeText"]] length] > 0) {    }
    
    if ([[AppLaunchModel sharedInstance].messaging_SERVER isEqualToString:@"LAYER"]) {
        [UserDefaults setBool:TRUE forKey:kIsUserOnLayerChatOnly];
    }
    else{
        [UserDefaults setBool:FALSE forKey:kIsUserOnLayerChatOnly];
    }
    
    
 //offerDto    Handling
    
    NSArray *offer = [response objectForKey:@"offerDto"];
    if(offer.count > 0){
        NSDictionary *offerDTO = [offer objectAtIndex:0];
       [[FreeTrailModel sharedInstance]updateDataWithOfferDtoDictionary:offerDTO];
    }else{
        NSDictionary *offerDTO = [[NSDictionary alloc]init];
        [[FreeTrailModel sharedInstance] updateDataWithOfferDtoDictionary:offerDTO];
    }
// Boost Data Handling
    NSDictionary *BoostDic = [[response objectForKey:@"productDto"] objectForKey:@"boostDto"];
    if (BoostDic) {
        [[BoostModel sharedInstance] updateDataWithBoostDictionary:BoostDic];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kBoostValueUpdated object:nil];
    }
    
    // Handling WooPlus
    
    if ([[response objectForKey:@"productDto"] objectForKey:@"wooPlusDto"]) {
        
        [[WooPlusModel sharedInstance] updateDataWithWooPlusDictionary:[[response objectForKey:@"productDto"] objectForKey:@"wooPlusDto"]];
        
        if([[[response objectForKey:@"productDto"] objectForKey:@"wooPlusDto"] objectForKey:@"sendNewECommerceEvent"]){
            [APP_DELEGATE sendFirebaseEvent:@"WOOPLUS_PURCHASE_EVENT_NEW" andScreen:@""];
            [BoostProductsAPICalss makePopupEventAPIwithType:@"WOOPLUS_PURCHASE_EVENT_NEW"];
            
        }
    }
    
    if ([[response objectForKey:@"productDto"] objectForKey:@"wooGlobeDto"]) {
        NSDictionary * wooGlobeDto  = [[response objectForKey:@"productDto"] objectForKey:@"wooGlobeDto"];
        if ([[wooGlobeDto allKeys] containsObject:@"expired"]) {
            [WooGlobeModel sharedInstance].isExpired = [[wooGlobeDto valueForKey:@"expired"] boolValue];
        }
    }
    
    //Woo globe data Handling
    if ([[response objectForKey:@"productDto"] objectForKey:@"wooGlobeDto"]) {
        [[WooGlobeModel sharedInstance] updateWooGlobeAvailibilityData:[[response objectForKey:@"productDto"] objectForKey:@"wooGlobeDto"]];
    }
    
    // Crush Data Handling
    if ([[response objectForKey:@"productDto"] objectForKey:@"crushDto"]) {
        [[CrushModel sharedInstance] updateDataWithCrushDictionary:[[response objectForKey:@"productDto"] objectForKey:@"crushDto"]];
    }

    
    
    //Calling invite based on timestamp
    
    long long int lastUpdatedTimestampInviteCampaign = 0;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kinviteCampaignUpdatedTime])
    {
        lastUpdatedTimestampInviteCampaign =  [[[NSUserDefaults standardUserDefaults] objectForKey:kinviteCampaignUpdatedTime] longLongValue];
        
    }
    __block id applaunchResponse = response;
    if(lastUpdatedTimestampInviteCampaign == 0 || [[response objectForKey:@"inviteCampaignUpdatedTime"] longLongValue] > lastUpdatedTimestampInviteCampaign)
    {
        NSLog(@"inviteCampaignUpdatedTime call gayi");
        [InviteFriendAPIClass getInviteCampaignDataFromServerWithCompletionBlock:^(BOOL completed, id response)
        {
            if (response != nil)
            {

                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%lld",[[applaunchResponse objectForKey:@"inviteCampaignUpdatedTime"] longLongValue]]  forKey:kinviteCampaignUpdatedTime];
                [[NSUserDefaults standardUserDefaults]synchronize];
                

                NSDictionary *responseDict = (NSDictionary *) response;
                
                NSArray *responseDictKeys = responseDict.allKeys;
                
                if ([responseDictKeys containsObject:@"campaignDesc"])
                {
                    [AppLaunchModel sharedInstance].invitationCampaignDesc  = [responseDict objectForKey:@"campaignDesc"];
                }
            }
        }];
    }

    // Calling Visitor Based upon timestamp

    long long int lastUpdatedTimestampBoost = 0;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kBoostDashboardTimestampKey]) {
        lastUpdatedTimestampBoost = [[[NSUserDefaults standardUserDefaults] objectForKey:kBoostDashboardTimestampKey] longLongValue];
    }
    
    if ([BoostModel sharedInstance].availableInRegion && [[NSUserDefaults standardUserDefaults] valueForKey:kLocationFound] && ( [[response objectForKey:@"visitorLastUpdatedTime"] longLongValue] > lastUpdatedTimestampBoost  || [[response objectForKey:@"visitorLastUpdatedTime"] longLongValue] == 0 )) {
        [self getVisitorFromServer];
    }

    
    // Calling LikedMe Based upon timestamp

    long long int lastUpdatedTimestampLikedMe = 0;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kLikedMeDashboardTimestampKey]) {
        lastUpdatedTimestampLikedMe = [[[NSUserDefaults standardUserDefaults] objectForKey:kLikedMeDashboardTimestampKey] longLongValue];
    }

    
    if ([WooPlusModel sharedInstance].availableInRegion && [[NSUserDefaults standardUserDefaults] valueForKey:kLocationFound] && ( [[response objectForKey:@"likedMeLastUpdatedTime"] longLongValue] > lastUpdatedTimestampLikedMe  || [[response objectForKey:@"likedMeLastUpdatedTime"] longLongValue] == 0 )) {
//        [LikedMeAPIClass getLikedMeProfilesFromServerWithLimit:50 AndCompletionBlock:^(id response, BOOL success) {
//            //dp nothing
//        }];
        if ([LikedMeAPIClass getIsfetchingLikedMeDataFromServerValue] == false) {
            [LikedMeAPIClass setIsfetchingLikedMeDataFromServerValue:true];
            [LikedMeAPIClass getLikedMeProfilesFromServerWithLimit:kPaginationCallPageSize withTime:nil withPaginationToken:nil withIndexValue:0 AndCompletionBlock:nil];
        }
    }
    
    // Calling Skipped Profiles Based upon timestamps
    long long int lastUpdatedTimestampSkippedProfiled = 0;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kSkippedProfileDashboardTimeStampKey]) {
        lastUpdatedTimestampSkippedProfiled = [[[NSUserDefaults standardUserDefaults] objectForKey:kSkippedProfileDashboardTimeStampKey] longLongValue];
    }
    
    
    if ([WooPlusModel sharedInstance].availableInRegion && [[NSUserDefaults standardUserDefaults] valueForKey:kLocationFound] && ( [[response objectForKey:@"skippedProfilesLastUpdatedTime"] longLongValue] > lastUpdatedTimestampSkippedProfiled  || [[response objectForKey:@"skippedProfilesLastUpdatedTime"] longLongValue] == 0 )) {
        if ([SkippedProfileAPIClass getIsfetchingSkippedDataFromServerValue] == false){
        
            [SkippedProfileAPIClass setIsfetchingSkippedDataFromServerValue:true];
            [SkippedProfileAPIClass getSkippedProfilesFromServerWithLimit:kPaginationCallPageSize withTime:nil withPaginationToken:nil withIndexValue:0/* AndCompletionBlock:nil*/];
        }
    }
    
   
    if ([WooPlusModel sharedInstance].availableInRegion && [[NSUserDefaults standardUserDefaults] valueForKey:kLocationFound] && ( [[response objectForKey:@"skippedProfilesLastUpdatedTime"] longLongValue] > lastUpdatedTimestampSkippedProfiled  || [[response objectForKey:@"skippedProfilesLastUpdatedTime"] longLongValue] == 0 )) {
        if ([LikedByMeAPIClass getIsfetchingLikedByMeDataFromServerValue] == false){
        
            [LikedByMeAPIClass setIsfetchingLikedByMeDataFromServerValue:true];
            [LikedByMeAPIClass getLikedByMeProfilesFromServerWithLimit:kPaginationCallPageSize withTime:nil withPaginationToken:nil withIndexValue:0];
        }
    }

    if ([WooScreenManager sharedInstance].oHomeViewController) {
        [[WooScreenManager sharedInstance].oHomeViewController checkIfBoostActive];
        [[WooScreenManager sharedInstance].oHomeViewController checkAndShowUnreadBadgeOnMatchIcon];
        [[WooScreenManager sharedInstance].oHomeViewController checkAndshowUnreadBadgeOnAboutMeIcon];
    }

    if  (  [[response objectForKey:@"productsLastUpdatedTime"] longLongValue] > [PurchaseProductDetailModel sharedInstance].productsLastUpdatedTime.longLongValue || [[response objectForKey:@"productsLastUpdatedTime"] longLongValue] == 0 ){
        
            [self getPurchaseProductDetailFromServer];
    }
    else if  (  [[response objectForKey:@"userProductPriceUpdatedTime"] longLongValue] > [PurchaseProductDetailModel sharedInstance].userProductPriceUpdatedTime.longLongValue || [[response objectForKey:@"userProductPriceUpdatedTime"] longLongValue] == 0 ){
        
        [self getPurchaseProductDetailFromServer];
    }
    else{
    if ([PurchaseProductDetailModel sharedInstance].wooGlobalModel == nil || [MyPurchaseTemplate sharedInstance].wooGlobeContent == nil) {
        [self getPurchaseProductDetailFromServer];
        [AppLaunchModel sharedInstance].sellingMessageUpdatedTime = 0;
        [AppLaunchModel sharedInstance].profileOptionsUpdatedTime = 0;
        [AppLaunchModel sharedInstance].tipsUpdatedTime = 0;
        [AppLaunchModel sharedInstance].countryDtoLastUpdatedTime = 0;
        [CrushModel sharedInstance].crushMessagesUpdatedTime = 0;
        [[AppLaunchApiClass sharedManager] makeAppSyncCallForAppConfigOptions:response];
    }
    }

    if ([response objectForKey:@"crushMsgCharsLimit"]) {
        [CrushModel sharedInstance].crushMsgCharsLimit = [[response objectForKey:@"crushMsgCharsLimit"] integerValue];
    }
    
    
    // Calling Crush API based on TimeStamp
    
    long long int lastUpdatedTimestampCrush = 0;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kCrushDashboardTimestampKey]) {
        lastUpdatedTimestampCrush = [[[NSUserDefaults standardUserDefaults] objectForKey:kCrushDashboardTimestampKey] longLongValue];
    }
    
    if ([CrushModel sharedInstance].availableInRegion && [[NSUserDefaults standardUserDefaults] valueForKey:kLocationFound] && (  [[response objectForKey:@"crushLastUpdatedTime"] longLongValue] > lastUpdatedTimestampCrush || [[response objectForKey:@"crushLastUpdatedTime"] longLongValue] == 0 )) {
     
            [self getCrushFromServer];
    
    }
    
//    if (![AppLaunchModel sharedInstance].swrveStatus) {
//        APP_DELEGATE.swreConfigObj = nil;
//        APP_DELEGATE.swreConfigObj = [[SwrveConfig alloc]init];
//        [Swrve sharedInstanceWithAppID:2819 apiKey:@"Jzf3pMkAjqVs7nbd3bAB" config:APP_DELEGATE.swreConfigObj];
//        NSLog(@"%@",[Swrve sharedInstance].userID);
//        [self sendNewSwrveUserIDToServer:[Swrve sharedInstance].userID];
//    }
    
    long long int serverLocationUpdatedTimestamp = [[response objectForKey:kLocationUpdatedTimestamp] longLongValue];
    long long int locationUpdatedTimeStamp = [[UserDefaults objectForKey:kLocationUpdatedTimestamp] longLongValue];
    if (serverLocationUpdatedTimestamp != locationUpdatedTimeStamp) {
        [UserDefaults setObject:[NSString stringWithFormat:@"%lld",serverLocationUpdatedTimestamp] forKey:kLocationUpdatedTimestamp];
        [UserDefaults synchronize];
    }
}

- (void)sendNewSwrveUserIDToServer:(NSString *)swrveUserId
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]) {
        NSString *userWooID = [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId];
        
        swrveUserId = [swrveUserId stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSLog(@"swrveUserId>>>>>>> :%@",swrveUserId);
        
        NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:userWooID,@"wooId",swrveUserId,@"swrveId",nil];
//                                @{@"wooId":userWooID,
//                                 @"swrveId":swrveUserId
//                                 };
        
        NSLog(@"params>>>>>>>:%@",params);
        if ([swrveUserId length] < 1) {
            return;
        }
        
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
    
}


#pragma mark - Get Purchase Product Detail From Server
- (void)getPurchaseProductDetailFromServer{
    
    [GetProductAPIClass getPurchaseProductsDetailFromServerWithCompletionBlock:^(BOOL success, id responseObj, int errorNumber) {
        
        
    }];
}

-(void)getVisitorFromServer{
    if ([APP_Utilities reachable]) {
        self.isVisitorCallMade = NO;
        //index will be 0 as discussed, Still need to confirm from Gaurav and changes should be made accordingally
        if ([BoostAPIClass getIsfetchingVisitorDataFromServerValue] == false)
        {
            [BoostAPIClass setIsfetchingVisitorDataFromServerValue:true];
            [BoostAPIClass getVisitorsFromServerWithLimit:kPaginationCallPageSize withTime:nil withPaginationToken:nil withIndexValue:0 AndCompletionBlock:^(id response, BOOL isSuccess) {
                //            if (response && [[response objectForKey:@"totalBoost"] intValue]>=kPageLengthForBoost) {
                //                [self getVisitorFromServer];
                //            }
                
                NSArray *arrayOfProfiles = [response objectForKey:@"boostInfoDtos"];
                NSMutableArray *profilePicsArray = [[NSMutableArray alloc] init];
                
                for (NSDictionary *dataDict in arrayOfProfiles) {
                    if ([[dataDict objectForKey:@"profilePicUrl"] length] > 0) {
                        CGFloat imageWidth = SCREEN_WIDTH;
                        CGFloat imageHeight = (SCREEN_WIDTH *0.8);
                        
                        NSURL *ImageCroppedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(imageWidth),IMAGE_SIZE_FOR_POINTS(imageHeight),[APP_Utilities encodeFromPercentEscapeString:[APP_Utilities validString:[dataDict objectForKey:@"profilePicUrl"]]]]];
                        [profilePicsArray addObject:ImageCroppedUrl];
                    }
                }
                SDWebImagePrefetcher *prefetchedReference = [SDWebImagePrefetcher sharedImagePrefetcher];
                [prefetchedReference setMaxConcurrentDownloads:5];
                [prefetchedReference setOptions:SDWebImageLowPriority|SDWebImageContinueInBackground];
                [prefetchedReference prefetchURLs:profilePicsArray];
                
                self.isVisitorCallMade = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationsFetchedSuccessfully object:nil];
            }];
        }

    }
}

-(void)getCrushFromServer{
    
    if ([APP_Utilities reachable]) {
        self.isCrushCallMade = NO;
        if ([CrushAPIClass getIsfetchingCrushDataFromServerValue] == false)
        {
            [CrushAPIClass setIsfetchingCrushDataFromServerValue:true];
            [CrushAPIClass getCrushesFromServerWithLimit:kPaginationCallPageSize withTime:nil withPaginationToken:nil withIndexValue:0 AndCompletionBlock:^(id response) {
            
//            if ([response objectForKey:@"crushInfoDtos"] && [(NSArray *)[response objectForKey:@"crushInfoDtos"] count] > 0 && [(NSArray *)[response objectForKey:@"crushInfoDtos"] count] == kPageLengthForCrushes) {

//            if ([response objectForKey:@"profiles"] && [(NSArray *)[response objectForKey:@"profiles"] count] > 0 && [(NSArray *)[response objectForKey:@"profiles"] count] == kPageLengthForCrushes) {
//
//
//            [self getCrushFromServer];
//            }
            self.isCrushCallMade = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationsFetchedSuccessfully object:nil];
        }];
        }
    }
    
}

- (void)makeLocationOptionsCall
{
    NSString *mcc = [[NSUserDefaults standardUserDefaults] valueForKey:kMcc];
    NSString *mnc = [[NSUserDefaults standardUserDefaults] valueForKey:kMnc];
    
    NSString *locationOptionsUrl;
    if (!mnc && !mcc) {
        locationOptionsUrl = [NSString stringWithFormat:@"%@%@?wooId=%@&latitude=0.0&longitude=0.0",kBaseURLV3,kUserLocationCall,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
    }
    else{
       locationOptionsUrl = [NSString stringWithFormat:@"%@%@?wooId=%@&latitude=0.0&longitude=0.0&mcc=%@&mnc=%@",kBaseURLV3,kUserLocationCall,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],mcc,mnc];
    }
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =locationOptionsUrl;
    wooRequestObj.time =0;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = getLocationOptionsFromServer;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        if (requestType == getLocationOptionsFromServer) {
            
            if (success){
//                [[NSUserDefaults standardUserDefaults] setObject:response forKey:kLocationOptions];
//                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        
    }  shouldReachServerThroughQueue:TRUE];
}

-(void)deleteVisitor_LikedMe_CrushAnd_SkippedProfilesThatAreExpiredFromSystem{
    if (([AppLaunchModel sharedInstance].meSectionProfileExpiryDays + [AppLaunchModel sharedInstance].meSectionExpiredProfilesDaysThreshold) > -1) {
        [MeDashboard deleteAllVisotorsPresentInSystemForMoreThanDays:(int)([AppLaunchModel sharedInstance].meSectionProfileExpiryDays + [AppLaunchModel sharedInstance].meSectionExpiredProfilesDaysThreshold)];
        [LikedMe deleteAllLikedMeProfilesPresentInSystemForMoreThanDays:(int)([AppLaunchModel sharedInstance].meSectionProfileExpiryDays + [AppLaunchModel sharedInstance].meSectionExpiredProfilesDaysThreshold)];
        [SkippedProfiles deleteAllSkippedProfilesPresentInSystemForMoreThanDays:(int)([AppLaunchModel sharedInstance].meSectionProfileExpiryDays + [AppLaunchModel sharedInstance].meSectionExpiredProfilesDaysThreshold)];
    }
}

-(void)makeAppLaunchCallToWhenConnectionResumes{
    [self removeObserverForInternetChange];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(internetConnectionStatusChanged:) name:kInternetConnectionStatusChanged object:nil];
}

-(void) internetConnectionStatusChanged:(NSNotification*)notif{
    int internetStatus = [notif.object intValue];
    if (internetStatus == AFNetworkReachabilityStatusReachableViaWWAN || internetStatus == AFNetworkReachabilityStatusReachableViaWiFi) {
        [self makeAppLaunchCallToServer];
    }
}

-(void)removeObserverForInternetChange{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kInternetConnectionStatusChanged object:nil];
}

-(void)checkForOutOfLike{
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *componants = [calendar components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:date];

    NSInteger hour = componants.hour;
    NSInteger minute = componants.minute;
    NSInteger second = componants.second;
    
    NSInteger currentTime = 24*60*60 - ((((hour * 60) + minute ) * 60 ) + second);
    
    if (currentTime < 60*60) {
        _currentTime = currentTime;
        _outOfLikeTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timerHandler) userInfo:nil repeats:YES];
    }
}

-(void) timerHandler{
    _currentTime = _currentTime - 5;
    if (_currentTime <= 0) {
        [_outOfLikeTimer invalidate];
        _outOfLikeTimer = nil;
        
       // [self makeAppLaunchCallToServer];
    }
}

@end


