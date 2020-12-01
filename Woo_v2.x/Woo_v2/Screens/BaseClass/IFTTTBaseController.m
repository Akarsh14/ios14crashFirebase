//
//  IFTTTBaseController.m
//  Woo
//
//  Created by Umesh Mishra on 13/03/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "IFTTTBaseController.h"
#import "U2AlertView.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
//#import "PurchaseViewController.h"
//#import "DiscoverViewController.h"

@implementation IFTTTBaseController


-(void)viewDidLoad{
    
    [super viewDidLoad];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPushToChatScreen object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushToChatScreen:) name:kPushToChatScreen object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPushToChatScreen object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushToChatScreenForMatchId:) name:kOpenChatRoomFromTopNotification object:nil];
}

-(void)pushToChatScreenForMatchId:(NSNotification *)notificationObj{
//    NSString *matchId = notificationObj.object;
//    MyMatches *matchObj = [MyMatches getMatchDetailForMatchID:matchId];
//    ChatRoom *chatRoomObj = [ChatRoom getChatRoomForChatRoomID:matchObj.matchedUserId];
    
}

-(void)pushToChatScreen:(NSNotification *)notificationObj{
//    NSLog(@"pushing to chat screen silently");
//    chatRoomObj = notificationObj.object;
//    [[NSNotificationCenter defaultCenter] postNotificationName:kChatCellTapped object:nil];

}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}




-(void)baseClassMethod{

}

/*
 
 -(void)showActivityIndicatorView{
 
 
 if (!activityIndicatorBackgroundView) {
 activityIndicatorBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
 [self.view addSubview:activityIndicatorBackgroundView];
 }
 
 if (!activityIndicatorObj) {
 activityIndicatorObj = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
 activityIndicatorObj.tintColor = kHeaderBackgroundColor;
 [activityIndicatorBackgroundView addSubview:activityIndicatorObj];
 activityIndicatorObj.center = activityIndicatorBackgroundView.center;
 }
 activityIndicatorObj.hidden = FALSE;
 activityIndicatorBackgroundView.layer.cornerRadius = 3;
 activityIndicatorBackgroundView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
 
 
 
 activityIndicatorBackgroundView.center = self.view.center;
 if (!activityIndicatorObj.isAnimating) {
 [activityIndicatorObj startAnimating];
 }
 //    [APP_Utilities showActivityIndicator];
 }
 -(void)hideActivityIndcatorView{
 if (activityIndicatorBackgroundView) {
 [activityIndicatorBackgroundView removeFromSuperview];
 activityIndicatorBackgroundView = nil;
 }
 if (activityIndicatorObj) {
 if (activityIndicatorObj.isAnimating) {
 [activityIndicatorObj stopAnimating];
 
 }
 [activityIndicatorObj removeFromSuperview];
 activityIndicatorObj = nil;
 }
 
 [APP_Utilities hideActivityIndicator];
 }
 
 */
-(void)showActivityIndicatorViewInCenter:(BOOL)showInCenter{
    if (!activityIndicatorObj) {
        activityIndicatorObj = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
//    activityIndicatorObj.color  = kHeaderBackgroundColor;
//    activityIndicatorObj.color = kHeaderBackgroundColor;
    [self.view addSubview:activityIndicatorObj];
    if (showInCenter) {
        activityIndicatorObj.center = self.view.center;
    }
    else{
        CGPoint centerPoint = self.view.center;
        centerPoint.y +=((SCREEN_HEIGHT/2)-60);
        activityIndicatorObj.center = centerPoint;
    }
    
    if (!activityIndicatorObj.isAnimating) {
        [activityIndicatorObj startAnimating];
    }
//    [APP_Utilities showActivityIndicator];
}
-(void)hideActivityIndcatorView{
    if (activityIndicatorObj) {
        if (activityIndicatorObj.isAnimating) {
            [activityIndicatorObj stopAnimating];
            
        }
        [activityIndicatorObj removeFromSuperview];
        activityIndicatorObj = nil;
    }
    [APP_Utilities hideActivityIndicator];
}

-(void)disableRightPanel{
//    [[APP_DELEGATE returnDrawerController] setRightDrawerViewController:nil];
}
-(void)enableRightPanel{
//    [[APP_DELEGATE returnDrawerController] setRightDrawerViewController:[self.storyboard instantiateViewControllerWithIdentifier:kRightPanelViewControllerID]];
//    [self.storyboard instantiateViewControllerWithIdentifier:kRightPanelViewControllerID];
}
-(void)handleErrorForResponseCode:(int)responseCode{
    
    //LUV_V2 --uncomment
//    if (![APP_Utilities reachable]) {
//        [ALToastView toastInView:APP_DELEGATE.window withText:@"No internet connection."];
//        return;
//    }
    
    NSArray *viewController = [self.navigationController viewControllers];
    
    NSLog(@"viewController : %@",viewController);
    NSLog(@"last Object in navigation heirarchy : %@",[viewController lastObject]);
    
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
                [self showLoginScreen];
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
            SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"Woo is experiencing heavy traffic.", nil));
        }
            break;
        
        default:
        {
            
        }
            break;
    }
}


-(void)showLoginScreen{
    [self logoutUser];
    
    
//    LoginViewController *loginViewControllerObj = [self.storyboard instantiateViewControllerWithIdentifier:kLoginViewControllerID];
//    UINavigationController *navObj = [[UINavigationController alloc] initWithRootViewController:loginViewControllerObj];
//    [[APP_DELEGATE returnDrawerController] setCenterViewController:navObj];
    
//    [self.navigationController popToRootViewControllerAnimated:NO];
//    if ([[[self.navigationController viewControllers] lastObject] isKindOfClass:[DiscoverViewController class]]) {
//        [[[self.navigationController viewControllers] lastObject] viewWillAppear:NO];
//    }
    return;
    
//    LoginViewController *loginViewControllerObj = [self.storyboard instantiateViewControllerWithIdentifier:kLoginViewControllerID];
//    UINavigationController *navObj = [[UINavigationController alloc] initWithRootViewController:loginViewControllerObj];
//    [self presentViewController:navObj animated:NO completion:nil];
    
    
}

//-(void)showPayWall{
//    
//    if ([[self.navigationController.viewControllers  lastObject]isKindOfClass:[PurchaseViewController class]]) {
//        return;
//    }
//    
//    PurchaseViewController *purchaseViewControllerObj = [self.storyboard instantiateViewControllerWithIdentifier:kPurchaseViewControllerID];
//    [purchaseViewControllerObj setShowNavBar:FALSE];
//    UINavigationController *navObj = [[UINavigationController alloc] initWithRootViewController:purchaseViewControllerObj];
//    [self presentViewController:navObj animated:NO completion:nil];
//    
//    
//}

-(void)logoutUser{

    [[FBSession activeSession] clearJSONCache];
    [[FBSession activeSession] close];
    [[FBSession activeSession] closeAndClearTokenInformation];

    [FBSession setActiveSession:nil];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"FBAccessTokenInformationKey"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kIsLoginProcessCompleted];
    
    NSArray *baseViews = [self.view subviews];
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

-(void)logoutWithoutRaisingAnyNotificaiton{
    [[FBSession activeSession] clearJSONCache];
    [[FBSession activeSession] close];
    [[FBSession activeSession] closeAndClearTokenInformation];
    
    [FBSession setActiveSession:nil];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"FBAccessTokenInformationKey"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kIsLoginProcessCompleted];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//-(void)reinitialiseUserDefaultAndDatabase{
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kStoredAccessToken];
//    
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastVerificationState];
//    
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kIsLoginProcessCompleted];
//    
//    
//    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kMatchesTimestampKey];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMatchesTimestampKey];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    
//    NSString *keyText = [NSString stringWithFormat:@"WooID_%@",[[NSUserDefaults standardUserDefaults] valueForKey:kWooUserId]];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:keyText];
//    //Added by Umesh
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kWooUserId];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kWooUserName];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kWooUserGender];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kWooProfilePicURL];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kGenderPreference];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMinAgePreference];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMaxAgePreference];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kNextMatchTimer];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLocalMyProfileUserKey];
//    
//    //    NSLog(@"\n\n\n\n1>?>>LOGOUT HUA HAI");
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kIsRegisteredForPush];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kIsRegisteredForLocation];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDiscoverLaunchedForFirstTime];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kGenderPrefrenceChangedForFirstTime];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAgeFromServer];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kFirstDiscoverOverlayKey];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kfirstNiceKey];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kFirstNahKey];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastNotificationID];
//    
//    
//    
//    [[NSUserDefaults standardUserDefaults] setObject:@"40" forKey:kProfileCompletenessScoreKey]; // Setting the profile completeness score to 40
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    
//    [APP_DELEGATE.store deleteDatabase];
//    
//    [APP_DELEGATE.store deleteManagedObject];
//}

@end
