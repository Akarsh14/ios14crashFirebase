//
//  FBSDKLogin.m
//  Woo_v2
//
//  Created by Deepak Gupta on 5/16/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "FBSDKLogin.h"
FBSDKLogin *fbSDKobj = nil;
FBSDKLoginManager *loginManagerObj;

@interface FBSDKLogin (){
   FbLoginButtonClicked _isButtonTappedBlock;
}

@property(nonatomic, retain)UIButton *myLoginButton;
@property(nonatomic, retain)UIActivityIndicatorView *loginActivityIndicator;

@end

@implementation FBSDKLogin

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+(FBSDKLogin *) sharedManagerFBSDKLogin
{
    if(fbSDKobj == nil){
        fbSDKobj = [[FBSDKLogin alloc] initWithFrame:CGRectMake(0, 5, SCREEN_WIDTH, 40)];
        loginManagerObj = [[FBSDKLoginManager alloc] init];
    }
    return fbSDKobj;
}



- (void)showLoginButtonWithTitle : (NSString *)title{
    
//    loginManagerObj = [[FBSDKLoginManager alloc] init];
    if (_myLoginButton != nil){
        _myLoginButton = nil;
    }
    _myLoginButton=[UIButton buttonWithType:UIButtonTypeCustom];
    _myLoginButton.backgroundColor=[UIColor colorWithRed:45.0/255.0 green:69.0/255.0 blue:135.0/255.0 alpha:1.0];

    _myLoginButton.frame=CGRectMake(0,0,SCREEN_WIDTH-80,45);
    _myLoginButton.layer.masksToBounds =TRUE;
    _myLoginButton.layer.cornerRadius = 4.0;
    if (IS_IPHONE_5){
        //bring the views upside only for phones lesser than Iphone 6 Ex: iphone SE, 5S
      [[_myLoginButton titleLabel] setFont:[UIFont fontWithName:kLatoRegular size:12.0f]];
    }else{
        [[_myLoginButton titleLabel] setFont:[UIFont fontWithName:kLatoRegular size:15.0f]];
    }
    
    [_myLoginButton setTitle:title forState: UIControlStateNormal];
    [_myLoginButton setImage:[UIImage imageNamed:@"ic_onbording_facebook"] forState:UIControlStateNormal];
     if (IS_IPHONE_SmallerThanIphone_6){
    [_myLoginButton setImageEdgeInsets: UIEdgeInsetsMake(0, 0, 0, 45)];
     }else if (IS_IPHONE_HigherThanIphone_6){
          [_myLoginButton setImageEdgeInsets: UIEdgeInsetsMake(0, 0, 0, 43)];
     }else if(IS_IPHONE_EqualToIphone_6){
         [_myLoginButton setImageEdgeInsets: UIEdgeInsetsMake(0, 0, 0, 43)];
     }
    [_myLoginButton addTarget:self action:@selector(loginButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    for (id view in self.subviews){
        if ([view isKindOfClass:[UIButton class]]){
            [view removeFromSuperview];
        }
    }
    [self addSubview:_myLoginButton];
}



- (void)fbLoginButtonClicked:(FbLoginButtonClicked)block{
    _isButtonTappedBlock = block;
}
- (void)showLoader{
    _isButtonTappedBlock(YES);
    [_myLoginButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    if (!_loginActivityIndicator) {
        _loginActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    [_myLoginButton addSubview:_loginActivityIndicator];
    [_loginActivityIndicator startAnimating];
    NSLog(@"%f", SCREEN_HEIGHT);
    if ((IS_IPHONE_SmallerThanIphone_6) || (IS_IPHONE_X)){
        _loginActivityIndicator.center = CGPointMake(30, 23);
    }else if (IS_IPHONE_HigherThanIphone_6){ _loginActivityIndicator.center = CGPointMake(50, 23);
    }else{
        _loginActivityIndicator.center = CGPointMake(30, 23);
    }
}

- (void)hideLoader{
    _isButtonTappedBlock(NO);
    
    if (_loginActivityIndicator.isAnimating) {
        [_loginActivityIndicator stopAnimating];
    }
    [_myLoginButton setImage:[UIImage imageNamed:@"ic_onbording_facebook"] forState:UIControlStateNormal];
}

- (void)setCompletionBlock : (FBSDKLoginBlock) block{
    _block = block;
}

#pragma mark - Login Button Clicked
-(void)loginButtonClicked
{
    
    if (![APP_Utilities reachable]){
        
        [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];
         return;
    }
   [self showLoader];
//
//    self.accountStore = [[ACAccountStore alloc] init];
//    
//    ACAccountType *facebookAccountType = [self.accountStore
//                                          accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
//    
//    // Specify App ID and permissions
//    NSDictionary *options = @{
//                              ACFacebookAppIdKey: @"1439999919568107",
//                              ACFacebookPermissionsKey: [[U2opiaFBLoginView sharedU2opiaFBLoginView] fetchReadPermissions],
//                              ACFacebookAudienceKey: ACFacebookAudienceEveryone
//                              };
//    [self addActivityIndicator];
//    [_accountStore requestAccessToAccountsWithType:facebookAccountType
//                                           options:options completion:^(BOOL granted, NSError *e) {
//                                               if (granted) {
//                                                   NSArray *accounts = [self.accountStore
//                                                                        accountsWithAccountType:facebookAccountType];
//                                                   self.facebookAccount = [accounts lastObject];
//                                               }
//                                               else
//                                               {
//                                                   [self hideActivityIndicator];
//                                                   // Handle Failure
//                                                   NSLog(@"ERROR %@",[e localizedDescription]);
//                                               }
//                                           }];

    
    if ([FBSDKAccessToken currentAccessToken]) {
        if (![self checkIfPermissionMissing]){
            
        _block([NSString stringWithFormat:@"%@",[FBSDKAccessToken currentAccessToken].tokenString] , nil , NO);
        
        }else
            _block([NSString stringWithFormat:@"%@",[FBSDKAccessToken currentAccessToken].tokenString] , nil , YES);
    }else{
        [self getLoginPermissionFromFacebook];
    }
}



-(void)getLoginPermissionFromFacebook{
    loginManagerObj.loginBehavior = FBSDKLoginBehaviorBrowser;
    
    [loginManagerObj logInWithPermissions:[self fetchReadPermissions] fromViewController:nil handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        
        
        if (error || ![FBSDKAccessToken currentAccessToken]) // Error
            _block(nil , error , NO);
        else {// Data
            
            if (![self checkIfPermissionMissing]){
                
                NSUserDefaults *userDefaultObj = [NSUserDefaults standardUserDefaults];
                [userDefaultObj setObject:result.token.tokenString forKey:kStoredAccessToken];
                
                [userDefaultObj setObject:[[FBSDKAccessToken currentAccessToken] userID] forKey:kStoredfbId];
                [userDefaultObj synchronize];
                
                
                _block (result.token.tokenString , nil , NO);
                
            }else
                _block (result.token.tokenString , nil , YES);
            
            
            
            NSLog(@"FBID = %@",[[FBSDKAccessToken currentAccessToken] userID]);
            
        }
    }];
}

#pragma mark - Facebook Logout
- (void)logOutUserFromFacebook{
    
    [loginManagerObj logOut];
    
    [FBSDKAccessToken setCurrentAccessToken:nil];
    
}


#pragma mark - Fetch Read Permission for Facebook
-(NSArray*)fetchReadPermissions{
   
   // user_education_history,user_relationships,user_work_history
    return [@"user_birthday,user_friends,user_likes,user_photos,email,user_link,user_gender"  componentsSeparatedByString:@","];
    //return [@"user_birthday,user_friends,user_education_history,user_likes,user_photos,user_relationships,email,user_work_history" componentsSeparatedByString:@","];
}


#pragma mark - Check any of the permission is missing.
-(BOOL)checkIfPermissionMissing{
    BOOL isIncompletePermission = FALSE;
    
    for (NSString *permission in [self fetchReadPermissions]) {
        if (![[FBSDKAccessToken currentAccessToken].permissions containsObject:permission]) {
            isIncompletePermission = TRUE;
            break;
        }
    }
    
    return false;
}


-(void)removeAllObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)getReadPermissions:(NSArray *)readPermissions onParentViewController:(UIViewController *)parentViewController withBlock:(void (^)(bool isValid))block{
    
    NSMutableArray *newPermissions = [[NSMutableArray alloc] init];
    //    Checking if we have requested read permission, if we have ignore else add new permisison in newPermissions array
    
    for (NSString *permission in readPermissions) {
        if (![[FBSession activeSession].permissions containsObject:permission ]) {
            [newPermissions addObject:permission];
        }
    }
    [newPermissions removeAllObjects];
    [newPermissions addObjectsFromArray:readPermissions];
    
    if ([newPermissions count] > 0) {
        if ([FBSession activeSession].isOpen) {
            [[FBSession activeSession] requestNewReadPermissions:newPermissions completionHandler:^(FBSession *session, NSError *error) {
                if (error) {
                    //show alert here
                    block(FALSE);
                    return;
                }
                if (session) {
                    block(TRUE);
                }
            }];
        }
        else{
            NSLog(@"%u",[FBSession openActiveSessionWithAllowLoginUI:FALSE fromViewController:parentViewController]);
            if ([FBSession openActiveSessionWithAllowLoginUI:FALSE fromViewController:parentViewController]) {
                if([FBSession activeSession].isOpen){
                    [[FBSession activeSession] requestNewReadPermissions:newPermissions completionHandler:^(FBSession *session, NSError *error) {
                        if (error) {
                            //show alert here
                            block(FALSE);
                            return;
                        }
                        if (session) {
                            block(TRUE);
                        }
                    }];
                }
            }
            else{
                block(FALSE);
            }
        }
    }
    
}


@end
