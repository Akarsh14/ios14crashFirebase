//
//  BaseViewController.m
//  Woo
//
//  Created by Umesh Mishra on 13/03/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "BaseViewController.h"
#import "U2AlertView.h"
#import "LoginViewController.h"
#import "AppDelegate.h"

//#import "PurchaseViewController.h"
//#import "DiscoverViewController.h"

@implementation BaseViewController


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
    //
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
        centerPoint.y +=30;
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
            UIAlertController *authenticationAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Authentication error", @"") message:NSLocalizedString(@"Something unexpected has happened. Please login again", @"") preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CMP00356", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self performSelector:@selector(showLoginScreen)];
            }];
            [authenticationAlert addAction:okAction];
            
            [self presentViewController:authenticationAlert animated:true completion:nil];
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
    
    // New implementation
    [[FBSDKLogin sharedManagerFBSDKLogin] logOutUserFromFacebook];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                @"onboarding" bundle:[NSBundle mainBundle]];
    
    
    
    LoginViewController *loginViewControllerObj = [storyboard instantiateViewControllerWithIdentifier:kLoginViewControllerID];
    [loginViewControllerObj setIsAuthenticationFailed:YES];
    [self presentViewController:loginViewControllerObj animated:YES completion:^{
        
        
    }];
    
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
