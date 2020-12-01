//
//  U2opiaFBLoginView.m
//  Woo
//
//  Created by Umesh Mishra on 13/02/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "U2opiaFBLoginView.h"

U2opiaFBLoginView *u2opiaFBLoginViewObj = nil;

#pragma mark shared instance of U2opia FB Login View

@implementation U2opiaFBLoginView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+(U2opiaFBLoginView *) sharedU2opiaFBLoginView
{
    if(nil == u2opiaFBLoginViewObj)
    {
        u2opiaFBLoginViewObj = [[U2opiaFBLoginView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 80)];
        
    }
    
    return u2opiaFBLoginViewObj;
}
-(void)addLoginButton{
    
    if (![FBSession activeSession].accessTokenData) {
        //        [[NSNotificationCenter defaultCenter] postNotificationName:kPlayVideo object:nil userInfo:nil];
    }
    [self printFbsession:[FBSession activeSession]];
    //Adding fb login button with read permissions
    //Adding fb login button with read permissions
    for (UIView *oldLoginViewObj in [self subviews]) {
        if ([oldLoginViewObj isKindOfClass:[FBLoginView class]]) {
            [oldLoginViewObj removeFromSuperview];
        }
    }
    FBLoginView *loginView = [[FBLoginView alloc] initWithReadPermissions:[[U2opiaFBLoginView sharedU2opiaFBLoginView] fetchReadPermissions]];
    //loginView.loginBehavior = FBSessionLoginTypeFacebookApplication;
    
    for (id viewObj in [loginView subviews]) {
        
        if ([viewObj isKindOfClass:[UIButton class]]) {
            UIButton *loginButton = (UIButton *)viewObj;
            loginButtonObj = loginButton;
            [loginButton addTarget:self action:@selector(loginButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    loginView.delegate = self;
    //VG_UM
    // Align the button in the center horizontally
    loginView.frame = CGRectMake((self.center.x - (loginView.frame.size.width / 2)), 0, loginView.frame.size.width, loginView.frame.size.height);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(internetConnectionStatusChanged:) name:kInternetConnectionStatusChanged object:nil];
    
    
    
    // Add the button to the view
    [self addSubview:loginView];
    sendNotification = TRUE;
    loginView.hidden = TRUE;
    [self printFbsession:[FBSession activeSession]];
    
}


-(UIButton *)getLoginButtonReference{
    return self->loginButtonObj;
}

-(void)loginButtonTapped:(id)sender{
    if (!_isPresentedForFBSync) {
        //        [APP_DELEGATE reinitialiseUserDefaultAndDatabase];
    }
    
    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"TapFBLogin" forScreenName:@"Login"];
    loginButtonObj.enabled = FALSE;
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowIndicatorViewOnLoginScreen object:nil];
    //    [self addActivityIndicator];
}
-(void)addActivityIndicator{
    if (!activityIndicatorViewObj) {
        activityIndicatorViewObj = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    [self addSubview:activityIndicatorViewObj];
    [activityIndicatorViewObj startAnimating];
    //    activityIndicatorViewObj.center = self.center;
    activityIndicatorViewObj.center = CGPointMake(self.frame.size.width/2, 15);
}
-(void)hideActivityIndicator{
    if (activityIndicatorViewObj.isAnimating) {
        [activityIndicatorViewObj stopAnimating];
    }
}
/*
 Method to get extra read permission from the user/facebook.
 It will check if session already have the asked permission, if not than it will get the new permission otherwise will not do anything.
 */
-(void)getReadPermissions:(NSArray *)readPermissions withBlock:(void (^)(bool isValid))block{
    //    [self printFbsession:[FBSession activeSession]];
    NSMutableArray *newPermissions = [[NSMutableArray alloc] init];
    //    Checking if we have requested read permission, if we have ignore else add new permisison in newPermissions array
    
    for (NSString *permission in readPermissions) {
        if (![[FBSession activeSession].permissions containsObject:permission ]) {
            [newPermissions addObject:permission];
        }
    }
    [newPermissions removeAllObjects];
    [newPermissions addObjectsFromArray:readPermissions];
    
    NSLog(@"sesseion : %@",[FBSession activeSession]);
    NSLog(@"is open : %d",[FBSession activeSession].isOpen);
    //Asking for new read permissions
    if ([newPermissions count]>0) {
        if([FBSession activeSession].isOpen){
            [[FBSession activeSession] requestNewReadPermissions:newPermissions completionHandler:^(FBSession *session, NSError *error) {
                
                NSLog(@"error value:%@",error);
                NSLog(@"session value :%@",session);
                if (error) {
                    [self handleAuthError:error];
                    block(FALSE);
                    return;
                }
                if (session) {
                    if (_isPresentedForFBSync) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kDismissLoginViewAndMakeToFBSync object:nil];
                    }
                    else{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kUserProvidedNewFbPermission object:session];
                    }
                    
                    [self printFbsession:session];
                    block(TRUE);
                }
                
            }];
        }else{
            if([FBSession openActiveSessionWithAllowLoginUI:FALSE])
                
                if([FBSession activeSession].isOpen){
                    [[FBSession activeSession] requestNewReadPermissions:newPermissions completionHandler:^(FBSession *session, NSError *error) {
                        
                        if (error) {
                            [self handleAuthError:error];
                            block(FALSE);
                            return;
                        }
                        if (session) {
                            [self printFbsession:session];
                            block(TRUE);
                        }
                    }];
                }
            
        }
    }else{
        block(TRUE);
    }
    
    
}

/*
 Method to get publish permission from the user/facebook.
 It will check if session already have the asked permission, if not than it will get the new permission otherwise will not do anything.
 */
-(void)getPublishPermissions:(NSArray *)publishPermissions withBlock:(void (^)(bool isValid))block{
    
    [self printFbsession:[FBSession activeSession]];
    NSMutableArray *newPermissions = [[NSMutableArray alloc] init];
    //    Checking if we have requested publish permission, if we have ignore else add new permisison in newPermissions array
    for (NSString *permission in publishPermissions) {
        if (![[FBSession activeSession].permissions containsObject:permission ]) {
            [newPermissions addObject:permission];
        }
    }
    //Asking for new publish permissions
    if ([newPermissions count]>0) {
        //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Ask_FB_Recommender_Inbox_Permission];
        if([FBSession activeSession].isOpen){
            isAskingForExtendedPermissions = TRUE;
            [[FBSession activeSession] requestNewPublishPermissions:newPermissions defaultAudience:FBSessionDefaultAudienceFriends completionHandler:^(FBSession *session, NSError *error) {
                if (error) {
                    [self handleAuthError:error];
                    //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Ask_FB_Recommender_Cancel_Inbox_Permission];
                    block(FALSE);
                    isAskingForExtendedPermissions = FALSE;
                    return;
                }
                if (session) {
                    //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Ask_FB_Recommender_Confirm_Inbox_Permission];
                    [self printFbsession:session];
                    block(TRUE);
                }
                isAskingForExtendedPermissions = FALSE;
            }];
        }else{
            
            if([FBSession openActiveSessionWithAllowLoginUI:FALSE])
                
                if([FBSession activeSession].isOpen){
                    isAskingForExtendedPermissions = TRUE;
                    [[FBSession activeSession] requestNewPublishPermissions:newPermissions defaultAudience:FBSessionDefaultAudienceFriends completionHandler:^(FBSession *session, NSError *error) {
                        if (error) {
                            [self handleAuthError:error];
                            //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Ask_FB_Recommender_Cancel_Inbox_Permission];
                            block(FALSE);
                            isAskingForExtendedPermissions = FALSE;
                            return;
                        }
                        if (session) {
                            [self printFbsession:session];
                            //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Ask_FB_Recommender_Confirm_Inbox_Permission];
                            block(TRUE);
                        }
                        isAskingForExtendedPermissions = FALSE;
                    }];
                }
            
        }
    }else{
        block(TRUE);
    }
}

// This method will be called when the user information has been fetched
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowIndicatorViewOnLoginScreen object:nil];
    _doesLoginFailed = NO;

    if (sendNotification) {
        
        if ([APP_Utilities isFacebookPermissionMissing]) {
            if ([user.objectID length]>0) {
                userFacebookId = user.objectID;
            }
            if ([[user name] length]>0) {
                userFacebookName = [user name];
            }
            [self showAuthorizeFacebookPermissionAlert];
            return;
        }
        
        sendNotification = FALSE;
        //checking if previous session is valid or not


        [self fetchMeForCheckingWhetherTokenIsExpired:^(bool isValid) {
            if(!isValid){
                NSString *validToken = [APP_Utilities validString:[[[FBSession activeSession] accessTokenData] accessToken]];       //current access token
                
                NSString *storedToken = [APP_Utilities validString:[[NSUserDefaults standardUserDefaults] objectForKey:kStoredAccessToken]];    //previous access token
                
                if ([[NSUserDefaults standardUserDefaults] objectForKey:kFacebookNumbericUserID] != nil) {
                    if (![[[NSUserDefaults standardUserDefaults] objectForKey:kFacebookNumbericUserID] isEqualToString:user.objectID]) {
                        NSLog(@"different user are login ");
                        [APP_DELEGATE reinitialiseUserDefaultAndDatabase];
                        _isPresentedForFBSync = FALSE;
                    }
                }
                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@", user.objectID] forKey:kFacebookNumbericUserID];
                [[NSUserDefaults standardUserDefaults] setObject:user.name forKey:kUserFBName];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                //if both token are equal and last verification state is less than LocationCallDoneState raise notification make login call or raise notification to show discover screen
                if([validToken isEqualToString:storedToken] && !_isPresentedForFBSync){
                    
                    if ([[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]) {
                        //                            VerificationState currentState = [[[NSUserDefaults standardUserDefaults] valueForKey:kLastVerificationState] intValue];
                        NSString *keyText = @"";
                        //    [APP_Utilities hideActivityIndicator];
                        if ([[APP_Utilities validString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]] length]>0) {
                            keyText = [NSString stringWithFormat:@"WooID_%@",[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
                        }
//                        VerificationState currentState = [[[NSUserDefaults standardUserDefaults] valueForKey:kLastVerificationState] intValue];
                       // UserVerificationState currentUserVerificatonState = UnverifiedUser;
                        if ([keyText length]>0) {
                           // currentUserVerificatonState = [[[NSUserDefaults standardUserDefaults] valueForKey:keyText] intValue];
                        }
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:kPushToVerificationScreen object:nil userInfo:[NSDictionary dictionaryWithObject:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] forKey:@"id"]];
//                        }
                        
                    }
                    else{
                        NSUserDefaults *userDefaultObj = [NSUserDefaults standardUserDefaults];
                        [userDefaultObj setObject:validToken forKey:kStoredAccessToken];
                        [userDefaultObj synchronize];
                        
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInSuccessfully object:nil userInfo:@{@"userId": user.objectID,@"access_token":[FBSession activeSession].accessTokenData, @"userName":user.name}];
                    }
                    
                }else{
                    // Else Make call and update cached token
                    NSUserDefaults *userDefaultObj = [NSUserDefaults standardUserDefaults];
                    [userDefaultObj setObject:validToken forKey:kStoredAccessToken];
                    [userDefaultObj synchronize];
                    
                    if (_isPresentedForFBSync) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kDismissLoginViewAndMakeToFBSync object:nil];
                    }
                    else{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInSuccessfully object:nil userInfo:@{@"userId": user.objectID,@"access_token":[FBSession activeSession].accessTokenData, @"userName":user.name}];
                    }
                    
                    
                }
            }
            //                else{
            //                    //Added by Umesh on 15 April 2014, logout or open new session if token expires with current session
            //                    [[FBSession activeSession] openFromAccessTokenData:[[FBSession activeSession] accessTokenData] completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            //                        if (error) {
            //                            [self doLogoutOperation];
            //                        }
            //                        else{
            //                            NSString *validToken = [APP_Utilities validString:[[[FBSession activeSession] accessTokenData] accessToken]];       //current access token
            //                            NSUserDefaults *userDefaultObj = [NSUserDefaults standardUserDefaults];
            //                            [userDefaultObj setObject:validToken forKey:kStoredAccessToken];
            //                            [userDefaultObj synchronize];
            //
            //                            [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInSuccessfully object:nil userInfo:@{@"userId": user.id,@"access_token":[FBSession activeSession].accessTokenData, @"userName":user.name}];
            //                        }
            //                    }];
            //                }
            //                [[NSNotificationCenter defaultCenter] postNotificationName:kHideIndicatorViewOnLoginScreen object:nil];
            //                [self hideActivityIndicator];
        }];
    }
    
}


-(void)showAuthorizeFacebookPermissionAlert{
    if (showLoginALert) {
        [showLoginALert removeFromSuperview];
        showLoginALert = nil;
    }
    showLoginALert = [[U2AlertView alloc] init];
    [showLoginALert alertWithHeaderText:NSLocalizedString(@"Need more details!", nil) description:NSLocalizedString(@"We need some more details to build \nan accurate Woo profile for you. \nPlease allow Woo to access \nFacebook for this information. \n\nWoo never posts on your wall.", nil) leftButtonText:NSLocalizedString(@"Authorize Facebook", nil) andRightButtonText:nil];
    __weak U2opiaFBLoginView *weakSelf = self;
    [showLoginALert setU2AlertActionBlockForButton:^(int tagValue , id data){
        [weakSelf facebookPermissionALertTapped];
    }];
    
    
    [showLoginALert show];
}


-(void)facebookPermissionALertTapped{
    NSLog(@"authrize button tapped");
    [self getReadPermissions:[self fetchReadPermissions] withBlock:^(bool isValid) {
        //        if ([APP_Utilities isFacebookPermissionMissing]) {
        //            [self showAuthorizeFacebookPermissionAlert];
        //            return;
        //        }
        //        else{
        //
        //            NSString *validToken = [APP_Utilities validString:[[[FBSession activeSession] accessTokenData] accessToken]];       //current access token
        //            NSUserDefaults *userDefaultObj = [NSUserDefaults standardUserDefaults];
        //            [userDefaultObj setObject:validToken forKey:kStoredAccessToken];
        //            [userDefaultObj synchronize];
        //
        //            if (userFacebookId && [userFacebookId length]>0) {
        //                [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInSuccessfully object:nil userInfo:@{@"userId": userFacebookId,@"access_token":[FBSession activeSession].accessTokenData, @"userName":@""}];
        //            }
        //        }
    }];
}

// Implement the loginViewShowingLoggedInUser: delegate method to modify your app's UI for a logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    
    loginView.frame = CGRectMake(loginView.frame.origin.x, -1000, loginView.frame.size.width, loginView.frame.size.height);
    hasErrorOccuredAlready = FALSE;
}

// Implement the loginViewShowingLoggedOutUser: delegate method to modify your app's UI for a logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    //VG_UM
    loginView.frame = CGRectMake(loginView.frame.origin.x, 0, loginView.frame.size.width, loginView.frame.size.height);
    loginView.frame = CGRectMake((self.center.x - (loginView.frame.size.width / 2)), 0, loginView.frame.size.width, loginView.frame.size.height);
    
    hasErrorOccuredAlready = FALSE;
    loginButtonObj.enabled = TRUE;
    sendNotification = TRUE;
    loginView.hidden = FALSE;
    [[NSNotificationCenter defaultCenter] postNotificationName:kHideIndicatorViewOnLoginScreen object:nil];
    //    [[NSNotificationCenter defaultCenter] postNotificationName:kPlayVideo object:nil userInfo:nil];
}

// You need to override loginView:handleError in order to handle possible errors that can occur during login

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    _doesLoginFailed = YES;

    [APP_DELEGATE sendSwrveEventWithEvent:@"FBLogin.Fail" andScreen:@"FBLogin"];
    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"Fail" forScreenName:@"Login"];
    [self printFbsession:[FBSession activeSession]];
    [self handleAuthError:error];
    loginView.hidden = FALSE;
    loginButtonObj.enabled = TRUE;
    hasErrorOccuredAlready = TRUE;
    [[NSNotificationCenter defaultCenter] postNotificationName:kHideIndicatorViewOnLoginScreen object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForCancelledFromFacebook  object:nil userInfo:nil];//for iOS8 and below
    //    [[NSNotificationCenter defaultCenter] postNotificationName:kPlayVideo object:nil userInfo:nil];
    //    [self hideActivityIndicator];
}

- (void)handleAuthError:(NSError *)error
{
    NSString *alertText;
    NSString *alertTitle;
    BOOL hasPermissions = FALSE;
    
    if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
        // Error requires people using you app to make an action outside your app to recover
        alertTitle = @"Facebook error";
        alertText = [FBErrorUtility userMessageForError:error];
        [APP_Utilities displayAlertWithTitle:alertTitle message:alertText withDelegate:nil];
        
    } else {
        //Indicates that the error category is invalid and likely represents an error that
        //is unrelated to Facebook or the Facebook SDK
        if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryInvalid) {
            NSLog(@"FBErrorCategoryInvalid");
        }
        else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryRetry){
            //Indicates that the error may be authentication related but the application should retry the operation
            NSLog(@"FBErrorCategoryRetry");
            if ([FBErrorUtility shouldNotifyUserForError:error] == YES) {
                alertTitle = @"Something went wrong";
                alertText = [FBErrorUtility userMessageForError:error];
                [APP_Utilities displayAlertWithTitle:alertTitle message:alertText withDelegate:nil];
                [self doLogoutOperation];
            }
            else{
                [self doLogoutOperation];
            }
        }
        else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
            // We need to handle session closures that happen outside of the app
            alertTitle = @"Session Error";
            alertText = @"Oops, something went wrong! Please log in to Facebook and try again.";
            [APP_Utilities displayAlertWithTitle:alertTitle message:alertText withDelegate:nil];
            [self doLogoutOperation];
        }
        else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryPermissions){
            //permission related error
            alertText = @"you do not have permission to perform this action. Please provide permission.";
            alertTitle = @"Permission Error";
            [APP_Utilities displayAlertWithTitle:alertTitle message:alertText withDelegate:nil];
        }
        else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryServer){
            //permission related error
            alertText = @"Seems facebook is busy right now.";
            alertTitle = @"Sever Error";
            [APP_Utilities displayAlertWithTitle:alertTitle message:alertText withDelegate:nil];
        }
        else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryThrottling){
            //permission related error
            alertText = @"You have exceeded your limit :P. Please try after sometime";
            alertTitle = @"Facebook Error";
            [APP_Utilities displayAlertWithTitle:alertTitle message:alertText withDelegate:nil];
        }
        else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled){
            //The user refused to log in into your app, either ignore or...
            alertTitle = NSLocalizedString(@"Woo Login", nil);
            alertText = NSLocalizedString(@"Did you complete your Facebook login? Please follow all steps to log in successfully.",nil);
            
            //Added accessTokenData condition and also changed to fetchExtendedPermissions from fetchReadPermissions on August 06, 2014
            if ([FBSession activeSession].accessTokenData) {
                for (NSString *permission in [[U2opiaFBLoginView sharedU2opiaFBLoginView] fetchExtendedPermissions]) {
                    if ([[FBSession activeSession].permissions containsObject:permission ]) {
                        hasPermissions = TRUE;
                        break;
                    }
                }
            }
            
            if(hasPermissions || isAskingForExtendedPermissions){
                [APP_Utilities displayAlertWithTitle:@"Woo" message:@"Permissions Issue - Please provide the required extended permissions" withDelegate:nil];
            }
            else{
                [APP_Utilities displayAlertWithTitle:alertTitle message:alertText withDelegate:nil];
            }
            
        }
        else {
            
            if (![APP_Utilities reachable]) {
                alertTitle = @"No Internet";
                alertText = @"Internert is not reachable.";
                [APP_Utilities displayAlertWithTitle:alertTitle message:alertText withDelegate:nil];
            }
            else{
                alertTitle = @"Something went wrong";
                alertText = NSLocalizedString(@"Please retry",nil);
                [APP_Utilities displayAlertWithTitle:alertTitle message:alertText withDelegate:nil];
                
            }
            
            // All other errors that can happen need retries
            // Show the user a generic error message
            
        }
        
        if(!hasPermissions && !isAskingForExtendedPermissions)
            [self doLogoutOperation];
    }
}
/*
 Method to check if current session is valid or not, by making a me call to fb
 */

-(void)fetchMeForCheckingWhetherTokenIsExpired:(void (^)(bool isValid))block {
    
    __block BOOL hasErrorOccured = TRUE;
    
    @try {
        //        [APP_Utilities showActivityIndicator];
        hasErrorOccured = FALSE;
        block(hasErrorOccured);
        return;
        FBRequest *fqlRequest =  [FBRequest requestForGraphPath:@"fql"];
        
        [fqlRequest setSession:FBSession.activeSession];
        
        NSString *fqlQuery = [NSString stringWithFormat:@"select uid from user where uid=me()"];
        
        [fqlRequest.parameters setObject:fqlQuery forKey:@"q"];
        
        [fqlRequest startWithCompletionHandler:^(FBRequestConnection *connection,
                                                 id result,
                                                 NSError *error) {
            
            
            if(error){
                if(!hasErrorOccuredAlready)
                    [self handleAuthError:error];
                
                hasErrorOccured = TRUE;
            }else{
                hasErrorOccured = FALSE;
            }
            
            block(hasErrorOccured); //call block here
            
            //            [APP_Utilities hideActivityIndicator];
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"excp %@",exception.debugDescription);
    }
    
    
}

-(void)doLogoutOperation{
    //need to perform login again
    //clear session to get login button again
    [[FBSession activeSession] closeAndClearTokenInformation];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kStoredAccessToken];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastVerificationState];
    
    
    
    //Added by Umesh
    if (!_isPresentedForFBSync) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kIsLoginProcessCompleted];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kWooUserId];
    }
    
}


//This method is just to check the current session state


-(void)printFbsession:(FBSession *)sessionObj{
    switch (sessionObj.state) {
        case FBSessionStateCreated:
            NSLog(@"FBSessionStateCreated");
            break;
        case FBSessionStateCreatedTokenLoaded:
            NSLog(@"FBSessionStateCreatedTokenLoaded");
            break;
        case FBSessionStateCreatedOpening:
            NSLog(@"FBSessionStateCreatedOpening");
            break;
        case FBSessionStateOpen:
            NSLog(@"FBSessionStateOpen");
            break;
        case FBSessionStateOpenTokenExtended:
            NSLog(@"FBSessionStateOpenTokenExtended");
            break;
        case FBSessionStateClosedLoginFailed:
            NSLog(@"FBSessionStateClosedLoginFailed");
            break;
        case FBSessionStateClosed:
            NSLog(@"FBSessionStateClosed");
            break;
        default:
            break;
    }
    NSLog(@"token value>>>>> : %@",sessionObj.accessTokenData.accessToken);
}


-(void)internetConnectionStatusChanged:(NSNotification*)notif{
    
    int internetStatus = 0;
    
    internetStatus = [notif.object intValue];
    
    [self startMoniteringNetworkingFluctuations:internetStatus];
    
}

-(void)startMoniteringNetworkingFluctuations:(AFNetworkReachabilityStatus)status{
    
    switch (status) {
        case AFNetworkReachabilityStatusNotReachable:{
            
            NSLog(@"No Internet Connection9876");
            
            // Handle low network issues here
            //                loginButtonObj.hidden = FALSE;
            //                loginButtonObj.enabled = FALSE;
            NSLog(@">>>>loginButtonObj>>>hidde:%d    enable:%d",loginButtonObj.isHidden,loginButtonObj.isEnabled);
            NSLog(@"\n\n\n\nLogin button set : %@\n\n\n",loginButtonObj);
            
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kHideIndicatorViewOnLoginScreen object:nil];
            [APP_Utilities displayAlertWithTitle:@"No Internet" message:NSLocalizedString(@"Please check your internet connection",nil) withDelegate:nil];
            [loginButtonObj setEnabled:FALSE];
            [loginButtonObj setHidden:FALSE];
            NSLog(@"<<<<<loginButtonObj>>>hidde:%d    enable:%d",loginButtonObj.isHidden,loginButtonObj.isEnabled);
        }
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi:{
            NSLog(@"Reachable via WIFI");
            loginButtonObj.enabled = TRUE;
        }
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:{
            
            NSLog(@"Reachable via 3G");
            loginButtonObj.enabled = TRUE;
        }
            break;
        default:
        {
            NSLog(@"Unknown status here");
        }
            break;
    }
}

-(NSArray*)fetchReadPermissions{
    
    
    return [@"user_birthday,user_friends,user_likes,user_photos,email,user_link,user_gender" componentsSeparatedByString:@","];
}


-(NSArray*)fetchExtendedPermissions{
    return [@"xmpp_login" componentsSeparatedByString:@","];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

-(void)loginWithoutShowingUI{
    
    NSLog(@"fnsession : %@",[FBSession activeSession]);
    NSLog(@"token :%@",[FBSession activeSession].accessTokenData);
    NSLog(@"session state : %lu",(unsigned long)[FBSession activeSession].state);
    [FBSession openActiveSessionWithReadPermissions:[self fetchReadPermissions] allowLoginUI:NO completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        [self addLoginButton];
        NSLog(@"button obj :%@",loginButtonObj);
        NSLog(@"session : %@",session);
        NSLog(@"status :%lu",(unsigned long)status);
        NSLog(@"make sync call again : %@",session.accessTokenData);
        [self performSelector:@selector(makeFBSyncCall) withObject:nil afterDelay:0.3];
        
    }];
    
}
-(void)makeFBSyncCall{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMakeFbSyncCall object:nil];
}
-(void)removeAllObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

