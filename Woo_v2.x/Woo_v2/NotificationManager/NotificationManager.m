//
//  NotificationManager.m
//  Woo_v2
//
//  Created by Deepak Gupta on 4/13/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "NotificationManager.h"
#import "ChatMessage.h"
#import "Woo_v2-Swift.h"
#import "MeDashboard.h"
#import "LikedMe.h"
#import "TopChatView.h"
#import "ApplozicChatHelperClass.h"
#import "ApplozicChatManager.h"
#import "Applozic.h"

@implementation NotificationManager


- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}


#pragma mark - Open Screen For Notification Screen
- (void) openScreenForNotificationName : (NSString *)notifName  WithApplication : (UIApplication *)application withNotificationData : (NSDictionary *)userInfo{
    NSLog(@"openScreenForNotificationName === userInfo :%@",userInfo);
    
    //FIXREQUIRED: Can you seperate this deep linking flow and push flow.
    if ([notifName isEqualToString:kDeepLiking]) { // Handling Notification For DeepLinking

        //FIXREQUIRED: I believe you also need to do it in case of voip push while opening up of a screen
      //  [[NSNotificationCenter defaultCenter] postNotificationName:kRemoveViewWithKeyboard object:nil];
        [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];

        NotificationType notificationTypeObj = [APP_Utilities getNotificationTypeFor:[userInfo objectForKey:@"TYPE"]];
        [self openScreenWithNotifType:notificationTypeObj withData:userInfo];
        
        return;
    }
    else if([notifName isEqualToString:kAPNS])
    {
        //kapns
    //FIXREQUIRED: Why we have just handled voip landing not everything? Or why can’t we move this where everything is handled?
    // FIXREQUIRED: Where is the (null) check?
        NSString *type = [userInfo objectForKey:@"TYPE"];
        if (type == nil){
            if ([userInfo objectForKey:@"AL_KEY"]){
                if ([[userInfo objectForKey:@"AL_KEY"] isEqualToString:@"APPLOZIC_01"]){
                type = @"CHAT_BOX_LANDING";
                }
            }
        }
            
       NotificationType notificationTypeObj = [APP_Utilities getNotificationTypeFor:type];
        if(notificationTypeObj == voipInviteLanding)
        {
            [AppLaunchModel sharedInstance].isCallingEnabled = YES;
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"hasSeenTutorialForVoiceCall"];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
    }
    
    
    BOOL isApplicationActive = NO;
    if (application.applicationState == UIApplicationStateActive) {
        isApplicationActive = YES;
    }
    
    //This code is added handle the D0 push notification. if JSON key is present that means our server is sending the push notification
    NSDictionary *userInfoDict = userInfo;
    if ([[userInfo allKeys] containsObject:@"JSON"] || [[userInfo allKeys] containsObject:@"AL_VALUE"]) {
        NSData *data;
        if ([[userInfo allKeys] containsObject:@"JSON"]){
        data = [[userInfo objectForKey:@"JSON"] dataUsingEncoding:NSUTF8StringEncoding];
        }
        else{
            data = [[userInfo objectForKey:@"AL_VALUE"] dataUsingEncoding:NSUTF8StringEncoding];
        }
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:kNilOptions
                                                                       error:nil];
        userInfoDict = jsonResponse;
    }
    
    
    //    ----------------------- SWRVE NOTIFICATION METHOD STARTS ------------------
//    UIApplicationState swrveState = [application applicationState];
//    if (swrveState == UIApplicationStateInactive || swrveState == UIApplicationStateBackground) {
//        [[Swrve sharedInstance].talk pushNotificationReceived:userInfo];
//    }
    NSLog(@"\n\n userInfo ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ :%@",userInfo);
    
    
    NSString *landingScreen = @"";
    
    if (userInfoDict && [userInfoDict valueForKey:kSwrveLandingScreenKey]) {
        landingScreen = [userInfoDict valueForKey:kSwrveLandingScreenKey];
    }
    
    NotificationType notificationTypeObj = [APP_Utilities getNotificationTypeFor:[userInfoDict objectForKey:kSwrveLandingScreenKey]];

    if (!isApplicationActive && ![landingScreen isEqualToString:@"(null)"] && [[APP_Utilities validString:landingScreen] length] > 0) {
      //  [[NSNotificationCenter defaultCenter] postNotificationName:kRemoveViewWithKeyboard object:nil];
        [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];

        NSLog(@"👉🏼👉🏼👉🏼👉🏼👉🏼👉🏼👉🏼👉🏼👉🏼 JUST BEFORE REAISE NOTIFICATION");
        if ((notificationTypeObj == incomingVisitorLanding) || (notificationTypeObj == likedMeSection))
        {
            [self performSelector:@selector(raiseNotification:) withObject:userInfoDict afterDelay:0.0f];
        }
        else
        {
            [self performSelector:@selector(raiseNotification:) withObject:userInfoDict afterDelay:1.5f];
        }
        return;
    }
    else
    {
        NSLog(@"Silent notification for matchremoved aaya");
        [self parseMatchRemovedAndUpdateMatchDataForNotificationData:userInfoDict];
    }
    
    if (!isApplicationActive)
    {
        if ([[userInfo allKeys] containsObject:@"layer"] || [[userInfoDict objectForKey:@"type"] isEqualToString:@"APPLOZIC_01"]) {
            if ([[userInfo allKeys] containsObject:@"layer"]){
                [self performSelector:@selector(OpenChatRoomForConversationId:) withObject:userInfo afterDelay:1.5];
            }
            else{
                [self OpenChatRoomForConversationId:userInfo];
            }
        }
    }
    
    // this is the case for Auto visitor >> incoming visitor landing
    // FIXREQUIRED: Again why just these two cases are handled here rest somewhere else? Can we do the cleanup?
    if (isApplicationActive &&  ((notificationTypeObj == incomingVisitorLanding) || (notificationTypeObj == likedMeSection))) {
        
        NSLog(@"\n\n userInfoDict ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ :%@",userInfoDict);
        if(notificationTypeObj == incomingVisitorLanding)
        {
            [self insertSilentlyIntoLikedMeDB:userInfoDict isLikedMe:NO];
        }
        else
        {
            //for liked me
            [self insertSilentlyIntoLikedMeDB:userInfoDict isLikedMe:YES];
        }
    }
}




#pragma mark - Open Alert For Custom Notification
-(void)openAlertForCustomNotification:(NSDictionary *)userInfoDict withTextData:(NSDictionary *)apsData{
    U2AlertView *customNotificationAlert = [[U2AlertView alloc]init];
    
    if ([[APP_Utilities validString:[userInfoDict objectForKey:@"URL"]] length] < 1) {
        
        [customNotificationAlert alertWithHeaderText:NSLocalizedString(@"Woo",nil) description:[apsData objectForKey:@"alert"] leftButtonText:NSLocalizedString(@"CMP00356",nil) andRightButtonText:nil];
    }else{
        [customNotificationAlert alertWithHeaderText:NSLocalizedString(@"Woo",nil) description:[apsData objectForKey:@"alert"] leftButtonText:NSLocalizedString(@"Cancel",nil) andRightButtonText:NSLocalizedString(@"Open",nil)];
    }
    
    [customNotificationAlert setContainerData:userInfoDict];
   
    
    [customNotificationAlert setU2AlertActionBlockForButton:^(int tagValue , id data){
        NSLog(@"%d",tagValue);
        
        if (tagValue == 1){
            if (data && [data isKindOfClass:[NSDictionary class]])
                [APP_Utilities openURLForURLString:[data objectForKey:@"URL"]];
        }
    }];
    
    [customNotificationAlert show];
}

#pragma mark - Push To Answer View
//FIXREQUIRED: It is not used/called?
-(void)pushToAnswerView:(NSString *)qID{
    [[NSNotificationCenter defaultCenter] postNotificationName:kPushToAnswerViewOnNotificationTap object:qID];
}


-(void)checkForInviteCodeInPushNotification:(NSDictionary *)launchOptionsDict andIsApplicationInForeground:(BOOL)isAppInForeground{
    NSLog(@"didFinishLaunchingWithOptions notification startup userinfo: %@", launchOptionsDict);
    NSLog(@"userInfo aps :%@",launchOptionsDict);
    NSLog(@"alert text :%@",[launchOptionsDict objectForKey:@"aps"]);
    NSLog(@"alert text :%@",[[launchOptionsDict objectForKey:@"aps"] objectForKey:@"alert"]);
    
    NSString *alertStr = [[launchOptionsDict objectForKey:@"aps"] objectForKey:@"alert"];
    
    if (([alertStr rangeOfString:@"["].location != NSNotFound) && ([alertStr rangeOfString:@"]"].location != NSNotFound)){
        NSRange startIndex = [alertStr rangeOfString:@"["];
        NSRange endIndex = [alertStr rangeOfString:@"]"];
        NSUInteger lenghtOfCode = endIndex.location - startIndex.location;
        
        NSRange codeRange = NSMakeRange(startIndex.location+1, lenghtOfCode-1);
        
        NSString *codeStr = [alertStr substringWithRange:codeRange ];
        NSLog(@"code string :%@",codeStr);
        [[NSUserDefaults standardUserDefaults] setObject:codeStr forKey:kAutoReadPushNotificationKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if (isAppInForeground) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kAutoReadCodeAndFillCode object:nil];
        }
        else{
            [[NSNotificationCenter defaultCenter] postNotificationName:kAutoReadCodeAndMakeServerCall object:nil];
        }
    }
}


#pragma mark - Show AlertView For Notification
//-(void)showAlertForNotificationOrNavigateToScreenForApplicationState:(BOOL)isActive andNotifcationType:(NotificationType )notificationTypeObj andOptionalTextToDisplay:(NSString *)textToDisplay{
//    if (!pushAlertView) {
//        pushAlertView = [[U2AlertView alloc]init];
//    }else{
//        [pushAlertView removeFromSuperview];
//        pushAlertView = nil;
//        pushAlertView = [[U2AlertView alloc]init];
//    }
//  
//    
//    [pushAlertView setU2AlertActionBlockForButton:^(int tagValue , id data){
//        NSLog(@"%d",tagValue);
//        
//        if (tagValue == 1)
//            [self buttonTappedOnNotificationAlertWithNotificationData:(NSString *)data];
//        
//        
//    }];
//    
//    [pushAlertView setContainerData:[NSString stringWithFormat:@"%li",(long)notificationTypeObj]];
//    [pushAlertView alertWithHeaderText:nil description:textToDisplay leftButtonText:NSLocalizedString(@"Cancel",nil) andRightButtonText:NSLocalizedString(@"CMP00356", nil)];
//    
//    if (isActive) {
//        [pushAlertView show];
//    }else{
////        [APP_DELEGATE fetchNewNotifications];
//    }
//}


#pragma mark - Button Tapped On Notification Alert
//-(void)buttonTappedOnNotificationAlertWithNotificationData:(NSString *)notificationTapped{
//    
//    NotificationType notification = [notificationTapped intValue];
//    
//        [[NSNotificationCenter defaultCenter] postNotificationName:kDismissTheScreenNotification object:nil];
//        
//        switch (notification) {
//            case myProfile: {
//                [[NSNotificationCenter defaultCenter]postNotificationName:kProfileTappedOnLeftPanel object:nil];
//                break;
//            }
//            case discover: {
//                [[NSNotificationCenter defaultCenter] postNotificationName:kTakeUserToDiscoverScreen object:nil];
//                break;
//            }
//            case matches: {
//                [[NSNotificationCenter defaultCenter] postNotificationName:kMessagesTappedOnLeftPanel object:nil];
//                break;
//            }
//            case questions: {
//                [[NSNotificationCenter defaultCenter] postNotificationName:kMessagesTappedOnLeftPanel object:nil];
//                [[NSNotificationCenter defaultCenter] postNotificationName:kQuestionsTapped object:nil];
//                break;
//            }
//            case notifications: {
//                [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationsTappedOnLeftPanel object:nil];
//                break;
//            }
//            case inviteFriends: {
//                //                <#statement#>
//                break;
//            }
//            case settings: {
//                [[NSNotificationCenter defaultCenter]postNotificationName:kSettingsTappedOnLeftPanel object:nil];
//                break;
//            }
//            case purchases: {
//                [[NSNotificationCenter defaultCenter]postNotificationName:kPurchasesTappedOnLeftPanel object:nil];
//                break;
//            }
//            case powerUps:{
//                
//                [[NSNotificationCenter defaultCenter]postNotificationName:kPowerUpsTappedOnLeftPanel object:nil];
//                
//            }
//                break;
//            case crushPanel:{ //
//                [[NSNotificationCenter defaultCenter]postNotificationName:kCrushTappedOnLeftPanel object:nil];
//                
//            }
//                break;
//            case visitorPanel:{
//                [[NSNotificationCenter defaultCenter]postNotificationName:kVisitorTappedOnLeftPanel object:nil];
//                
//            }
//                break;
//            case boostPaymentScreen:{
//                
//                [[NSNotificationCenter defaultCenter]postNotificationName:kPurchaseOptionBoost object:nil];
//                
//            }
//                break;
//            case crushPaymentScreen:{
//                
//                [[NSNotificationCenter defaultCenter]postNotificationName:kPurchaseOptionCrush object:nil];
//                
//            }
//
//            case custom: {
//                //                nothing here
//                break;
//            }
//            case  demo:{
//                [[NSNotificationCenter defaultCenter] postNotificationName:kTutorialTappedOnLeftPanel object:nil];
//            }
//                break;
//                
//            case  my_photos:{
//                [[NSNotificationCenter defaultCenter] postNotificationName:kImageSelectionNotification object:nil];
//                
//            }
//                break;
//                
//            case  faq:{
//                [[NSNotificationCenter defaultCenter] postNotificationName:kFAQTappedOnLeftPanel object:nil];
//                
//            }
//                break;
//                
//            case unknown: {
//                //                nothing here
//                break;
//            }
//            default: {
//                break;
//            }
//        }
//    }




-(void)raiseNotification:(NSDictionary *)notificationData{
    NotificationType notificationTypeObj = [APP_Utilities getNotificationTypeFor:[notificationData objectForKey:kSwrveLandingScreenKey]];
    
    NSLog(@"👉🏼👉🏼👉🏼👉🏼👉🏼👉🏼👉🏼👉🏼 IN RAISE NOTIFICATION");
    
    [self openScreenWithNotifType:notificationTypeObj withData:notificationData];
}


-(void)openScreenWithNotifType : (NotificationType)notifType withData : (NSDictionary *)notificationData{
    
    NSLog(@"openScreenWithNotifType === notificationData:%@ === %ld",notificationData,notifType);
    switch (notifType) {
        case unknown: {
            //DONE
            [[NSNotificationCenter defaultCenter] postNotificationName:kDiscoverLandingNotification object:nil];
            break;
        }
        case referFriend: {
            //DONE
            [[NSNotificationCenter defaultCenter] postNotificationName:kInviteScreenLandingNotification object:nil];
            break;
        }
        case voipInviteLanding: {
             [[NSNotificationCenter defaultCenter] postNotificationName:kVoIPInviteKey object:nil];
        }
        case discoverScreen: {
            //DONE
            [[NSNotificationCenter defaultCenter] postNotificationName:kDiscoverLandingNotification object:nil];
            break;
        }
        case meSectionLanding: {
            [[NSNotificationCenter defaultCenter] postNotificationName:kMeLandingNotification object:nil];
            break;
        }
        case visitorSection: {
            [[NSNotificationCenter defaultCenter] postNotificationName:kVisitorLandingNotification object:nil];
            break;
        }
        case likedMeSection: {
            
            [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"isNewLikedMeToBeAddedFromNotification"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:kLikedMeLandingNotification object:nil];
            [self prepareIncomingMeDataAndInsertInDb:notificationData withLikedMe:TRUE];

            break;
        }
        case crushReceivedSection: {
            [[NSNotificationCenter defaultCenter] postNotificationName:kCrushLandingNotification object:nil];
            break;
        }
        case skippedProfileSection: {
            [[NSNotificationCenter defaultCenter] postNotificationName:kSkippedProfileLandingNotification object:nil];
            break;
        }
        case myQuestionsSection: {
            NSLog(@"myQuestionsSection");
            [[NSNotificationCenter defaultCenter] postNotificationName:kQuestionsLandingNotification object:nil];
            break;
        }
        case matchBoxSection: {
            [APP_DELEGATE getMyMatchesForTimestamp:[AppLaunchModel sharedInstance].lastMatchUpdateTime andUpdateTimeAfterDataInsertionWith:0];
            [[NSNotificationCenter defaultCenter] postNotificationName:kMatchboxLandingNotification object:nil];
            break;
        }
        case myPurchasesSection: {
            [[NSNotificationCenter defaultCenter] postNotificationName:kPurchaseLandingNotification object:nil];
            break;
        }
        case boostPurchaseSection: {
            [[NSNotificationCenter defaultCenter] postNotificationName:kBoostPurchaseLandingNotification object:notificationData];
            break;
        }
        case crushPurchaseSection: {
            [[NSNotificationCenter defaultCenter] postNotificationName:kCrushPurchaseLandingNotification object:notificationData];
            break;
        }
        case wooplusPurchaseSection: {
            [[NSNotificationCenter defaultCenter] postNotificationName:kWooPlusPurchaseLandingNotification object:notificationData];
            break;
        }
        case wooGlobePurchaseSection: {
            [[NSNotificationCenter defaultCenter] postNotificationName:kWooGlobePurchaseLandingNotification object:notificationData];
            break;
        }
        case inviteScreenLandingSection: {
            [[NSNotificationCenter defaultCenter] postNotificationName:kInviteScreenLandingNotification object:nil];
            break;
        }
        case editProfilePurchaseSection: {
            [[NSNotificationCenter defaultCenter] postNotificationName:kEditProfileLandingNotification object:nil];
            break;
        }
        case chatBoxLanding: {
            [[NSNotificationCenter defaultCenter] postNotificationName:kChatBoxLandingNotification object:nil];
            break;
        }
        case discoverSettingsSection: {
            [[NSNotificationCenter defaultCenter] postNotificationName:kDiscoverSettingsLandingNotification object:nil];
            break;
        }
        case appSettingsSection: {
            [[NSNotificationCenter defaultCenter] postNotificationName:kAppSettingsLandingNotification object:nil];
            break;
        }
        case appStoreLandingSection: {
            [[NSNotificationCenter defaultCenter] postNotificationName:kAppStoreLandingNotification object:nil];
            break;
        }
        case tagBubbleLanding: {
            [[NSNotificationCenter defaultCenter] postNotificationName:kTagBubbleScreenLandingNotification object:nil];
            break;
        }
        case incomingVisitorLanding: {
            [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"isNewVisitorToBeAddedFromNotification"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:kVisitorLandingNotification object:nil];
            [self prepareIncomingMeDataAndInsertInDb:notificationData withLikedMe:FALSE];

            break;
        }
        case inAppBrowserSection: {
            
            
            break;
        }
        case matchRemoved:
        {
            //
            
            break;
        }
        case contentguidelines:
        {
            //
            [[NSNotificationCenter defaultCenter] postNotificationName:kVisitorContentGuidelinesLandingNotification object:nil];
            break;
        }
        case feedback:
        {
            //
            [[NSNotificationCenter defaultCenter] postNotificationName:kFeedBackScreenLandingNotification object:nil];
            break;
        }
    }
}


-(void)insertSilentlyIntoLikedMeDB:(NSDictionary *)userInfo isLikedMe:(BOOL)isLikedMe
{
    NSMutableDictionary *visitorData = nil;
    
    if ([[userInfo allKeys] containsObject:@"JSON"]) {
        
        NSData *data = [[userInfo objectForKey:@"JSON"] dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:kNilOptions
                                                                       error:nil];
        
        visitorData = [[NSMutableDictionary alloc] init];
        [visitorData setValue:[jsonResponse objectForKey:@"wooId"] forKey:@"wooUserId"];
        [visitorData setValue:[jsonResponse objectForKey:@"firstName"] forKey:@"firstName"];
        [visitorData setValue:[jsonResponse objectForKey:@"age"] forKey:@"age"];
        [visitorData setValue:[jsonResponse objectForKey:@"imgUrl"] forKey:@"profilePicUrl"];
        if([jsonResponse objectForKey:@"like"]!=nil){
            [visitorData setValue:[jsonResponse objectForKey:@"like"] forKey:@"like"];
        }else{
            [visitorData setValue:[NSNumber numberWithBool:true] forKey:@"like"];
        }
        
        [visitorData setValue:[jsonResponse objectForKey:@"gender"] forKey:@"gender"];
        NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
        if([jsonResponse objectForKey:@"time"]!=nil){
            [visitorData setValue:[jsonResponse objectForKey:@"time"] forKey:@"time"];
        }else{
            [visitorData setValue:[NSString stringWithFormat:@"%f",timeInSeconds*1000] forKey:@"time"];
        }
        [visitorData setValue:[jsonResponse objectForKey:@"isActorBoosted"]?[jsonResponse objectForKey:@"isActorBoosted"]:[NSNumber numberWithBool:FALSE] forKey:@"isActorBoosted"];
    }
    else{
        visitorData = [[NSMutableDictionary alloc] init];
        [visitorData setValue:[userInfo objectForKey:@"wooId"] forKey:@"wooUserId"];
        [visitorData setValue:[userInfo objectForKey:@"firstName"] forKey:@"firstName"];
        [visitorData setValue:[userInfo objectForKey:@"age"] forKey:@"age"];
        [visitorData setValue:[userInfo objectForKey:@"imgUrl"] forKey:@"profilePicUrl"];
        if([userInfo objectForKey:@"like"]!=nil){
            [visitorData setValue:[userInfo objectForKey:@"like"] forKey:@"like"];
        }else{
            [visitorData setValue:[NSNumber numberWithBool:true] forKey:@"like"];
        }
        [visitorData setValue:[userInfo objectForKey:@"gender"] forKey:@"gender"];
        NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
        if([userInfo objectForKey:@"time"]!=nil){
            [visitorData setValue:[userInfo objectForKey:@"time"] forKey:@"time"];
        }else{
            [visitorData setValue:[NSString stringWithFormat:@"%f",timeInSeconds*1000] forKey:@"time"];
        }
        //        [visitorData setValue:[userInfo objectForKey:@"time"] forKey:@"time"];
        [visitorData setValue:[userInfo objectForKey:@"isActorBoosted"]?[userInfo objectForKey:@"isActorBoosted"]:[NSNumber numberWithBool:FALSE] forKey:@"isActorBoosted"];
    }
    if(isLikedMe)
    {
        [MeDashboard insertOrUpdateBoostDashboardData:[NSArray arrayWithObject:visitorData] forType:likedMe withInsertionCompletionHandler:^(BOOL isInsertionCompleted) {
     
            [AppLaunchModel sharedInstance].isNewDataPresentInLikedMESection = true;

            [[WooScreenManager sharedInstance].oHomeViewController checkAndshowUnreadBadgeOnAboutMeIcon];
        }];
    }
    else{
        NotificationType notificationTypeObj = [APP_Utilities getNotificationTypeFor:[userInfo objectForKey:kSwrveLandingScreenKey]];
        __weak NotificationManager *notifManager = self;
    
        [MeDashboard insertOrUpdateBoostDashboardData:[NSArray arrayWithObject:visitorData] forType:(notificationTypeObj == likedMeSection ? likedMe : VisitorMe) withInsertionCompletionHandler:^(BOOL isInsertionCompleted) {
           
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                NSString* input = [userInfo objectForKey:@"message"];

                // will cause trouble if you have "abc\\\\uvw"
                NSString* esc1 = [input stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
                NSString* esc2 = [esc1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
                
                NSLog(@"esc is %@",esc2);
                
                NSString* quoted = [[@"\"" stringByAppendingString:esc2] stringByAppendingString:@"\""];
                
                NSLog(@"quoted is %@",quoted);
                
                NSData* data = [quoted dataUsingEncoding:NSUTF8StringEncoding];
                NSString* unesc = [NSPropertyListSerialization propertyListFromData:data
                                   mutabilityOption:NSPropertyListImmutable format:NULL
                                   errorDescription:NULL];
                assert([unesc isKindOfClass:[NSString class]]);
                NSLog(@"Output = %@", unesc);
                
                
                [[WooScreenManager sharedInstance].oHomeViewController checkAndshowUnreadBadgeOnAboutMeIcon];
                TopChatView *chatView = [TopChatView sharedInstanceWithNotificationType:notificationTypeObj];
                [chatView setNotificationTypeForView:notificationTypeObj];
                [chatView showNewChatMessageFromTop:unesc withHeader:[userInfo objectForKey:@"title"] andUserImage:[userInfo objectForKey:@"imgUrl"]];

                [chatView setButtonTapHandler:^(BOOL btnTapped) {

                    [notifManager openScreenWithNotifType:notificationTypeObj == likedMeSection ? likedMeSection : incomingVisitorLanding withData:userInfo];
                }];
            });
        }];
    }

}

-(void)parseMatchRemovedAndUpdateMatchDataForNotificationData:(NSDictionary *)dictionary
{
    if ([[dictionary allKeys] containsObject:@"MATCH_ID"]) {
        NSString *matchID = [dictionary objectForKey:@"MATCH_ID"];
        NSLog(@"MatchId for deleted match %@",matchID);
        MyMatches *matchObj = [MyMatches getMatchDetailForMatchID:matchID];
        if([matchObj.isTargetFlagged boolValue] == YES)
        {
            NSLog(@"MatchId for deleted match when target is flagged %@",matchID);
            //2. You need to test this piece ankit for target flagged case.
            ///remove from Mymatches
            [MyMatches deleteMatchForMatchID:matchID];
        }
        else
        {
            //MyMatches update for isDeleted
            [MyMatches updateMatchedUserForIsDeletedWithMatchId:matchID];
        }
        
    }
}
-(void)prepareIncomingMeDataAndInsertInDb:(NSDictionary *)userInfo withLikedMe:(BOOL)isLikedMe{
    
    /*
    {
        "to" : "dal1NqbnFSU:APA91bGmsNR_Jlz6PjdQ0VIoSsQuwF4ZZl3iyYz_gXbxBubWRlwoaVZHOEVq-zBBkHV5jgPJaIj66nxTdztxwz0tAoGZWskRomkSdGsCtyNRZ4D5CAFaKDmMJ3Q1MUKw9IGwkOVRFsTU",
        "priority" : "high",
        "notification" : {
            "body" : "This is Woo.",
            "text" : "Woo",
            "icon" : "wowooowww"
        },
        "data" : {
            "JSON" : "{\"LANDING_SCREEN\":\"LIKED_ME_LANDING\",\"TYPE\":\"RECIEVED_LIKE\", \"HEADS_UP_NOTIFICATION\":\"true\",\"USER_NAME\":\"RA\",\"IMAGE_URL\":\"http://u2-woostore.s3.amazonaws.com/wooPictures/10154170458031529.jpg\", \"age\":\"38\", \"gender\":\"FEMALE\", \"title\":\" \", \"message\":\"Congratulations Srini, someone has liked your profile. Get matched if you like her as well.\", \"imgUrl\":\"http://u2-woostore.s3.amazonaws.com/wooPictures/656123417876654.jpg\", \"firstName\":\"RA\", \"wooId\":\"4027293\", \"like\":\"true\" }",
            "sound" : "default",
            "message":"Test Message visitor"
        }
    }
     
     {
     "wooUserId": 3421682,
     "firstName": "Manik",
     "age": 29,
     "like": true,
     "profilePicUrl": "http://u2-woostore.s3.amazonaws.com/wooPictures/10152425015575426.jpg",
     "gender": "MALE",
     "isActorBoosted": false,
     "time": 1495179351000
     }
    */
    

    NSMutableDictionary *visitorData = nil;
    
    if ([[userInfo allKeys] containsObject:@"JSON"]) {
        
        NSData *data = [[userInfo objectForKey:@"JSON"] dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:kNilOptions
                                                                       error:nil];
        
        visitorData = [[NSMutableDictionary alloc] init];
        [visitorData setValue:[jsonResponse objectForKey:@"wooId"] forKey:@"wooUserId"];
        [visitorData setValue:[jsonResponse objectForKey:@"firstName"] forKey:@"firstName"];
        [visitorData setValue:[jsonResponse objectForKey:@"age"] forKey:@"age"];
        [visitorData setValue:[jsonResponse objectForKey:@"imgUrl"] forKey:@"profilePicUrl"];
        if([jsonResponse objectForKey:@"like"]!=nil){
            [visitorData setValue:[jsonResponse objectForKey:@"like"] forKey:@"like"];
        }else{
            [visitorData setValue:[NSNumber numberWithBool:false] forKey:@"like"];
        }
        
        [visitorData setValue:[jsonResponse objectForKey:@"gender"] forKey:@"gender"];
        NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
        if([jsonResponse objectForKey:@"time"]!=nil){
            [visitorData setValue:[jsonResponse objectForKey:@"time"] forKey:@"time"];
        }else{
            [visitorData setValue:[NSString stringWithFormat:@"%f",timeInSeconds*1000] forKey:@"time"];
        }
        [visitorData setValue:[jsonResponse objectForKey:@"isActorBoosted"]?[jsonResponse objectForKey:@"isActorBoosted"]:[NSNumber numberWithBool:FALSE] forKey:@"isActorBoosted"];
    }
    else{
        visitorData = [[NSMutableDictionary alloc] init];
        [visitorData setValue:[userInfo objectForKey:@"wooId"] forKey:@"wooUserId"];
        [visitorData setValue:[userInfo objectForKey:@"firstName"] forKey:@"firstName"];
        [visitorData setValue:[userInfo objectForKey:@"age"] forKey:@"age"];
        [visitorData setValue:[userInfo objectForKey:@"imgUrl"] forKey:@"profilePicUrl"];
        if([userInfo objectForKey:@"like"]!=nil){
            [visitorData setValue:[userInfo objectForKey:@"like"] forKey:@"like"];
        }else{
            [visitorData setValue:[NSNumber numberWithBool:false] forKey:@"like"];
        }
        [visitorData setValue:[userInfo objectForKey:@"gender"] forKey:@"gender"];
        NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
        if([userInfo objectForKey:@"time"]!=nil){
            [visitorData setValue:[userInfo objectForKey:@"time"] forKey:@"time"];
        }else{
            [visitorData setValue:[NSString stringWithFormat:@"%f",timeInSeconds*1000] forKey:@"time"];
        }
//        [visitorData setValue:[userInfo objectForKey:@"time"] forKey:@"time"];
        [visitorData setValue:[userInfo objectForKey:@"isActorBoosted"]?[userInfo objectForKey:@"isActorBoosted"]:[NSNumber numberWithBool:FALSE] forKey:@"isActorBoosted"];
    }
    
    NSLog(@"New visitor/likedme notification after dictionary : %@",visitorData);


    if(isLikedMe){
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateLikedMeView_NewLikedMeAdded object:visitorData];
        [[WooScreenManager sharedInstance].oHomeViewController checkAndshowUnreadBadgeOnAboutMeIcon];

//        [LikedMe insertOrUpdateLikedMeData:[NSArray arrayWithObject:visitorData] withCompletionHandler:^(BOOL isInsertionCompleted) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateLikedMeView_NewLikedMeAdded object:nil];
//            [[WooScreenManager sharedInstance].oHomeViewController checkAndshowUnreadBadgeOnAboutMeIcon];
//        }];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateVisitorView_NewVisitorAdded object:visitorData];
        [[WooScreenManager sharedInstance].oHomeViewController checkAndshowUnreadBadgeOnAboutMeIcon];

//        [BoostDashboard insertOrUpdateBoostDashboardData:[NSArray arrayWithObject:visitorData] withInsertionCompletionHandler:^(BOOL isInsertionCompleted) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateVisitorView_NewVisitorAdded object:nil];
//            [[WooScreenManager sharedInstance].oHomeViewController checkAndshowUnreadBadgeOnAboutMeIcon];
//        }];
    }
}


#pragma mark - Called for IAmMatched
- (void)raiseEventForIAmMatched : (NSDictionary *)userInfo{
    
    NSData *data = [[userInfo objectForKey:@"JSON"] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:nil];
    self.shouldShowTopNotification = YES;
    self.showTopNotioficationForMatchId = [jsonResponse objectForKey:@"MATCH_ID"];
//    [APP_DELEGATE fetchNewNotifications];
    
}

#pragma mark - Open Chat Room
-(void)OpenChatRoom{
    [[NSNotificationCenter defaultCenter] postNotificationName:kChatsTapped object:nil];
}

-(void)OpenChatRoomForConversationId:(NSDictionary *)chatDetail{
    NSLog(@"UK chatDetail :%@",chatDetail);
    NSString *conversationID = [[chatDetail objectForKey:@"layer"] objectForKey:@"conversation_identifier"];
    NSLog(@"UK conversation ID :%@",conversationID);
    
    MyMatches *layerIDMatch = nil;
    NSString *layerMessageID = nil;
    
    NSDictionary *jsonDict;
    if (conversationID == nil){
        //applozic chat
        NSData *data;
        if ([[chatDetail allKeys] containsObject:@"AL_VALUE"]){
            data = [[chatDetail objectForKey:@"AL_VALUE"] dataUsingEncoding:NSUTF8StringEncoding];
        }
        jsonDict = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:kNilOptions
                                                                       error:nil];
        conversationID = [jsonDict objectForKey:@"message"];
        layerMessageID = [[jsonDict objectForKey:@"messageMetaData"] objectForKey:@"CreatedTime"];
    }
    
    if ([conversationID length]>0){
        if ([[chatDetail allKeys] containsObject:@"AL_VALUE"]){
            layerIDMatch = [MyMatches getMatchObjectForApplozicId:conversationID];
        }
        else{
            layerIDMatch = [MyMatches getMatchObjectForLayerConversationId:conversationID];
        }
        [APP_DELEGATE connectToLayer];
        [APP_DELEGATE connectToApplozic];
        NSLog(@"layerIDMatch ==== %@",layerIDMatch);
        NSLog(@"WooScreenManager sharedInstance].oHomeViewController :%@",[WooScreenManager sharedInstance].oHomeViewController);
       
        ///////////Notfication
//        NSArray *childVcs = [[[WooScreenManager sharedInstance] oHomeViewController] childViewControllers];
//        int currentTabSelected = [[[[WooScreenManager sharedInstance] oHomeViewController]  currentTabBarIndexObjc] intValue];
//        UINavigationController *currentNavigation = [childVcs objectAtIndex:currentTabSelected];
//        [currentNavigation popToRootViewControllerAnimated:NO];
        
        if (layerIDMatch) {
            NSLog(@"call hona chahiye openchatroom");
            NSString *msgStringWithName = [[chatDetail objectForKey:@"aps"] objectForKey:@"alert"];
            NSString *msgString = [msgStringWithName stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@: ",layerIDMatch.matchUserName] withString:@""];
            NSLog(@"\n===\nmessage string %@",msgString);
//            LYRMessage *messageObj = [[LayerManager sharedLayerManager] getMessageObjectForLayerConversationId:[[chatDetail objectForKey:@"layer"] objectForKey:@"message_identifier"]];
//            NSLog(@"messageObj :%@\n===\n",messageObj);
//            [[NSNotificationCenter defaultCenter] postNotificationName:kDismissPresentedViewController object:layerIDMatch.matchedUserId userInfo:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                //Check currentTab
                if([[WooScreenManager sharedInstance] isDrawerOpen])
                {
                    [[[WooScreenManager sharedInstance] oHomeViewController] closeDrawer:[UIButton new]];
                }
                
                UIWindow *window = [UIApplication sharedApplication].keyWindow;
                if([[[[[window subviews] lastObject] subviews] lastObject] isKindOfClass:[PurchasePopup class]] || [[[[[window subviews] lastObject] subviews] lastObject] isKindOfClass:[DropOffPurchasePopup class]] || [[[[[window subviews] lastObject] subviews] lastObject] isKindOfClass:[PostFeedbackContactView class]])
                {
                    [[[[[window subviews] lastObject] subviews] lastObject] removeFromSuperview];
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
                if(layerIDMatch.isTargetFlagged.boolValue == false)
                {
                    ALMessage *alMessage;
                    if ([[jsonDict objectForKey:@"messageMetaData"] objectForKey:@"imageurl"] != nil){
                        alMessage = [[ApplozicChatManager sharedApplozicChatManager] createMessageObjectForId:conversationID forMessage:msgString isImage:true andImageData:[jsonDict objectForKey:@"messageMetaData"]];
                    }
                    else{
                     alMessage = [[ApplozicChatManager sharedApplozicChatManager] createMessageObjectForId:conversationID forMessage:msgString isImage:false andImageData:nil];
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"moveToChatRoom" object:layerIDMatch.matchId userInfo:nil];

                    /*
                    ChatMessage *message = [ChatMessage getChatMessageForLayerMessageId:layerMessageID];
                    if (!message){
                    [APPLOZIC_HELPER insertApplozicChatFromToLocalDB:alMessage ifSenderIsMe:false withCompletionHandler:^(ChatMessage *chatMessageObj) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"moveToChatRoom" object:layerIDMatch.matchId userInfo:nil];
                    }];
                    }
                    else{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"moveToChatRoom" object:layerIDMatch.matchId userInfo:nil];
                    }
                     */
                }
            });
            
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //Check currentTab
                if([[WooScreenManager sharedInstance] isDrawerOpen])
                {
                    [[[WooScreenManager sharedInstance] oHomeViewController] closeDrawer:[UIButton new]];
                }
                
                UIWindow *window = [UIApplication sharedApplication].keyWindow;
                if([[[[[window subviews] lastObject] subviews] lastObject] isKindOfClass:[PurchasePopup class]] || [[[[[window subviews] lastObject] subviews] lastObject] isKindOfClass:[DropOffPurchasePopup class]] || [[[[[window subviews] lastObject] subviews] lastObject] isKindOfClass:[PostFeedbackContactView class]])
                {
                    [[[[[window subviews] lastObject] subviews] lastObject] removeFromSuperview];
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
            
//            [[NSNotificationCenter defaultCenter] postNotificationName:kDismissPresentedViewController object:layerIDMatch.matchedUserId userInfo:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"moveToChatRoom" object:layerIDMatch.matchId userInfo:nil];

            });
//            [[WooScreenManager sharedInstance].oHomeViewController moveToTab:2];
        }
    }
    else{
        
    }
    
    
    
    NSLog(@"UK match object for layer id :%@",layerIDMatch);
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:kPushToChatScreen object:layerIDMatch];
    
}

//-(void)openChatRoomForChatRoomId:(NSDictionary *)notificationInfo{
//    NSLog(@"notificationInfo===== :%@",notificationInfo);
//    
//    NSArray *lastPathObjectOfMsgId = [[[notificationInfo objectForKey:@"layer"] objectForKey:@"conversation_identifier"] componentsSeparatedByString:@"/"];
//    
//    NSString *msgId = [lastPathObjectOfMsgId lastObject];
//    
//    ChatMessage *msgObj = [ChatMessage getChatMessageForLayerMessageId:msgId];
//    NSLog(@"msgObj :%@",msgObj);
//    if (msgObj) {
//        [[WooScreenManager sharedInstance].oHomeViewController openChatRoomForChatRoomId:msgObj.chatRoomID];
//    }
//    else{
//        [[WooScreenManager sharedInstance].oHomeViewController moveToTab:2];
//    }
//}
/*
 UNUSED METHOD
-(void)callMeInCaseOfMatchDetailsReceivedInPush:(NSDictionary *)userInfo withApplicationState:(UIApplication *)application{
    //Now checking if we have match from the sender of the message.
    MyMatches *myMatchesObjNew = [MyMatches getIntroMessageForWooUserID:[userInfo objectForKey:@"SENDER_ID"]];
    if (!myMatchesObjNew) {
        //If we haven't recieved any match that means either the match does not exists or it has been deleted from the server so we need not do any thing.
    }
    else{
        //Else we have to create chat room for the matched user.
        NSLog(@"====my matches k baad chat room create hua hai");
        if (application.applicationState == UIApplicationStateActive) {
            return;
        }
        
        //checking if the any chat room was open and if the same room was open no need to push
        if (APP_DELEGATE.currentActiveChatRoomId && ![[userInfo objectForKey:@"SENDER_ID"] isEqualToString:APP_DELEGATE.currentActiveChatRoomId]) {
            return;
        }
        if (APP_DELEGATE.currentActiveChatRoomId && ![[userInfo objectForKey:@"SENDER_ID"] isEqualToString:@""]) {
            //raise a notification if current chat room is not the chat room of the sender pop and go to chat room again
            [[NSNotificationCenter defaultCenter] postNotificationName:kPopFromChatView object:nil userInfo:nil];
            NSLog(@"====-pop huya hai");
        }
        //raise a notification to push into the chat room.
        [self performSelector:@selector(raiseEventToPushToChatView:) withObject:myMatchesObjNew afterDelay:0.53];
        //                        [[NSNotificationCenter defaultCenter] postNotificationName:kPushToChatScreen object:chatRoomObj];
    }
}
*/

// UNUSED METHOD
//-(void)callChatMessageView:(NSDictionary *)userInfo withApplicationState:(UIApplication *)application{
//    
//    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
//    BOOL isNetworkReachable = (reachability.isReachable || reachability.isReachableViaWiFi || reachability.isReachableViaWWAN);
//    if (!isNetworkReachable) {
//        //        [APP_Utilities displayAlertWithTitle:NSLocalizedString(@"Oops!", nil) message:NSLocalizedString(@"No internet connection! Please try again.", nil) withDelegate:self];
//        
//        SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"Please check your internet connection",nil));
//        return;
//    }
//    
//    //checking if chat room is available for the chat messge that needs to be instered
//    NSLog(@"=====|| call chat message view");
//    __block MyMatches *matchedUserObj = [MyMatches getMatchDetailForMatchedUSerID:[userInfo objectForKey:@"SENDER_ID"]];
//    if (!matchedUserObj) {
//        //we are inside this chat room that means chat room is not available
//        //Cheking if my matches for the other person exists in database or not
//        NSLog(@"===== }chat room nahi hai..:)");
//
//        if (!matchedUserObj) {
//            //We are inside this method that means we dont have any match for that person in database.
//            //Fetching matches from server.
//            NSLog(@"===== ^^ myMatches nahi hai");
//            long long int savedTimestamp = [[[NSUserDefaults standardUserDefaults] objectForKey:kMatchesTimestampKey] longLongValue];
//            
//            if([[APP_Utilities validString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]] length]>0){
//                NSString *urlString = [NSString stringWithFormat:@"%@/%@/matches?time=%lld",kBaseURLV1,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],savedTimestamp];
//                WooRequest *wooRequestObj = [[WooRequest alloc]init];
//                wooRequestObj.url =urlString;
//                wooRequestObj.time =900;
//                wooRequestObj.requestParams =nil;
//                wooRequestObj.methodType =getRequest;
//                wooRequestObj.numberOfRetries = 3;
//                wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
//                wooRequestObj.requestType = getHiddenNotificationData;
//                //making a request to server to get all matches after the savedTimeStamp
//                [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
//                    
//                    BOOL isItInsideOfThisMethod = FALSE;
//                    //We have recieved some response
//                    if (success && requestType == getHiddenNotificationData) {
//                        
//                        NSMutableArray *responseDataArray = (NSMutableArray *)response;
//                        
//                        for (NSMutableDictionary *matchDictionary in responseDataArray) {
//                            //checking if any match has deleted from the sever.
//                            /* Show all matches wheteher deleted is true or false
//                             
//                             if ([matchDictionary objectForKey:@"deleted"] && [[matchDictionary objectForKey:@"deleted"] boolValue]) {
//                             [MyMatches deleteMatchForMatchID:[matchDictionary objectForKey:@"matchId"]];
//                             
//                             }else{ */
//                            //if a match is not deleted that means it is added. So add my match data in database
//                            isItInsideOfThisMethod = TRUE;
//                            [MyMatches insertDataInMyMatchesFromArray:[NSArray arrayWithObject:matchDictionary] withChatInsertionSuccess:^(BOOL insertionSuccess) {
//                                [self callMeInCaseOfMatchDetailsReceivedInPush:userInfo withApplicationState:application];
//                                
//                            }];
//                        }
//                        
//                    }
//                    
//                    if(!isItInsideOfThisMethod){
//                        [self callMeInCaseOfMatchDetailsReceivedInPush:userInfo withApplicationState:application];
//                    }
//                  
//                } shouldReachServerThroughQueue:TRUE];
//                
//            }
//        }
//        else{
//            //We are here that means chatroom for the sender does not exists but match exists
//            //creating chat room for the sender.
//            NSLog(@"====--my matches hai ");
//            NSLog(@"====00 ab chat room create hua hai");
//            if (application.applicationState == UIApplicationStateActive) {
//                return;
//            }
//            
//            //checking if the any chat room was open and if the same room was open no need to push
//            if (APP_DELEGATE.currentActiveChatRoomId && [[userInfo objectForKey:@"SENDER_ID"] isEqualToString:APP_DELEGATE.currentActiveChatRoomId]) {
//                return;
//            }
//            if (APP_DELEGATE.currentActiveChatRoomId && ![[userInfo objectForKey:@"SENDER_ID"] isEqualToString:@""]) {
//                //raise a notification if current chat room is not the chat room of the sender pop and go to chat room again
//                [[NSNotificationCenter defaultCenter] postNotificationName:kPopFromChatView object:nil userInfo:nil];
//                NSLog(@"====>pop huya hai>> matches hai");
//            }
//            
//            [self performSelector:@selector(raiseEventToPushToChatView:) withObject:matchedUserObj afterDelay:0.53];
//        }
//    }
//    else{
//        if (application.applicationState == UIApplicationStateActive) {
//            return;
//        }
//        //We are here that means chat room for the sender is availabe.
//        if (APP_DELEGATE.currentActiveChatRoomId && [[userInfo objectForKey:@"SENDER_ID"] isEqualToString:APP_DELEGATE.currentActiveChatRoomId]) {
//            return;
//        }
//        if (APP_DELEGATE.currentActiveChatRoomId && ![[userInfo objectForKey:@"SENDER_ID"] isEqualToString:@""]) {
//            //raise a notification if current chat room is not the chat room of the sender pop and go to chat room again
//            [[NSNotificationCenter defaultCenter] postNotificationName:kPopFromChatView object:nil userInfo:nil];
//        }
//        
//        [self performSelector:@selector(raiseEventToPushToChatView:) withObject:matchedUserObj afterDelay:0.53];
//    }
//    
//}

#pragma mark - Push to ChatView
-(void)raiseEventToPushToChatView:(MyMatches *)matchedUserObj{

    [[NSNotificationCenter defaultCenter] postNotificationName:kPushToChatScreen object:matchedUserObj];
}





@end
