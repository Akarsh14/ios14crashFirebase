//
//  LoginViewController.m
//  Woo
//
//  Created by Umesh Mishra on 11/02/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "LoginViewController.h"
#import "U2opiaFBLoginView.h"
#import "PermissionView.h"
#import "VerificationViewController.h"
#import "DiscoverEmptyView.h"
#import "WooAPIClass.h"
#import "Woo_v2-Swift.h"
#import "PermissionScreenViewController.h"
#import "VPImageCropperViewController.h"
#import "ImageAPIClass.h"
#import "FacebookAlbumViewController.h"
#import "SearchLocationViewController.h"
#import "LoginErrorFeedbackViewController.h"
#import "LogInAPIClass.h"
#import "LoginLoadingViewController.h"
#import "ConfirmUserViewController.h"
#import "ApplozicChatManager.h"
#import <Crashlytics/Crashlytics.h>

//firebase ui import by akarsh
@import FirebaseUI;
@import Firebase;
@import FirebaseAuth;
@import AuthenticationServices;
@import CommonCrypto;

@interface LoginViewController ()<LoginLoadingDelegate , LoginErroFeedbackDelegate , VPImageCropperDelegate,ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding>
{
    
    
    __weak IBOutlet UIButton *iButton;
    __weak IBOutlet UIView *viewMask;
    __weak IBOutlet UIButton *fbLoginButton;
    __weak IBOutlet UIView *viewTop;
    __weak IBOutlet UIView *viewBottom;
    __weak IBOutlet UIImageView *imageViewIntro;
    // BOOL boatScreenHasBeenPushed;
    __weak IBOutlet UIView *firstView;
    __weak IBOutlet UIView *secondView;
    __weak IBOutlet NSLayoutConstraint *bottomToSecondViewConstraint;
    
    
    __weak IBOutlet UIButton *btnSignInPhoneNumber;
    __weak IBOutlet UIButton *appleSignInBtn;
    __weak IBOutlet NSLayoutConstraint *topToFirstViewConstraint;
    __weak IBOutlet UILabel *firstLabel;
    __weak IBOutlet UILabel *secondLabel;
    __weak IBOutlet UIButton *privacyPolicyButton;
    __weak IBOutlet UIImageView *introScreenImageView;
    __weak IBOutlet UIView *topView;
    __weak IBOutlet UIView *gestureView;
    BOOL shouldStop;
    _Bool isAninmating;
    
    NSString *currentNonce;
}

@end

@implementation LoginViewController


int feedbackTimeInterval = 900;
int imageAnimationIndex = 0;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

//Fb Kit
//-(void)initFbAccKit{
//    if (_accountKit == nil){
//        _accountKit = [[AKFAccountKit alloc]
//                       initWithResponseType:AKFResponseTypeAccessToken];
//    }
//}

- (IBAction)btnCloseFbPopUp:(id)sender {
    [self displayLoginUI];
    [self changeViewPosition];
    [viewMask setHidden:YES];
}

- (void)_prepareLoginViewController:(UIViewController<AKFViewController> *)loginViewController
{
    loginViewController.delegate = self;
    // Optionally, you may set up backup verification methods.
    loginViewController.enableSendToFacebook = YES;
    loginViewController.enableGetACall = YES;
}

- (IBAction)showGuideLines:(id)sender {
    
    UIStoryboard *homeStoryboard = [UIStoryboard storyboardWithName:@"Home" bundle:nil];
    WkWebViewController *myWebviewController = [homeStoryboard instantiateViewControllerWithIdentifier:@"wkWebViewStoryBoardID"];
    myWebviewController.navTitle = @"Guidelines/EULA";
    myWebviewController.webViewUrl = [NSURL URLWithString:@"http://www.getwooapp.com/contentguidelines.html"];
    [self.navigationController pushViewController:myWebviewController animated:true];
}

- (IBAction)btnWhyFb:(id)sender {
    //[subViewFBWhyFbLogin.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    [facebookBtn setFrame:CGRectMake(0, 0, subViewFBWhyFbLogin.frame.size.width, 41)];
    
    if (![subViewFBWhyFbLogin.subviews containsObject:facebookBtn]){
        [subViewFBWhyFbLogin addSubview:facebookBtn];
    }
    [self.view bringSubviewToFront:viewMask];
    [viewMask setHidden:NO];
    
}




- (IBAction)loginViaNumberTapped:(UIButton *)sender
{
    if([APP_Utilities isIndianUser]){
        
        NSString *loginViewFlow = [[NSUserDefaults standardUserDefaults]                                            objectForKey:@"INDIA_LOGIN_METHOD_NEW_iOS"];
        
        if(loginViewFlow != nil){
            
            if([loginViewFlow isEqual: @"FIREBASE_LOGIN"]){
              [self loginViaFireBase];
            }else{
              [self loginViaNumber];
            }
            
        }else{
             [self loginViaNumber];
        }
         
    }else{
        [self loginViaFireBase];
    }
    //[self loginViaNumber];
}


//this method helps to authenticate user's phone number via OTP through firebase
- (void) loginViaFireBase {
    NSLog(@"initiate firebase login");
   
    // Objective-C
    FUIPhoneAuth *phoneProvider = [FUIAuth defaultAuthUI].providers.firstObject;
    
    [phoneProvider signInWithPresentingViewController:self phoneNumber:nil];
}


// This method receives the results when firebase phoneAuth completes after otp
- (void)authUI:(FUIAuth *)authUI
    didSignInWithAuthDataResult:(nullable FIRAuthDataResult *)authDataResult
         error:(nullable NSError *)error {
  // Implement this method to handle signed in user (`authDataResult.user`) or error if any.
    
    if(error == nil){
        NSLog(@"user login successfully");
        NSLog(@"%@",authDataResult.user.refreshToken);
        
        FIRUser *user = authDataResult.user;
        
        [user getIDTokenWithCompletion:^(NSString * _Nullable token, NSError * _Nullable error) {
            NSLog(@"%@",token);
            [[Utilities sharedUtility] sendMixPanelEventWithName:@"Firebase_OTP_Verify_Success"];
            [[LoginModel sharedInstance] setIsAlternateLogin:YES];
            [[LoginModel sharedInstance] setIsAlertnativeLoginTypeTrueCaller:NO];
            [self makeLoginCallToServerWithUserId:nil withAccessToken:token withDictionary:nil andLoginThrough:LoginViaFirebase];
        }];
        
    }else{
        NSLog(error.localizedDescription);
    }
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (@available(iOS 13.0, *)) {
        appleSignInBtn.hidden = false;
        [appleSignInBtn setHidden:NO];
    }else{
        appleSignInBtn.hidden = true;
        [appleSignInBtn setHidden:YES];
    }
    
    // Do any additional setup after loading the view.
    //    Hiding navigation bar
    self.navigationController.navigationBarHidden = YES;
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [gestureView addGestureRecognizer:singleFingerTap];
    
//    [self initFbAccKit];
    
    
    
    //Firebase UI Auth declared by akarsh
    [FUIAuth defaultAuthUI].delegate = self; // delegate should be retained by you!
    FUIPhoneAuth *phoneProvider = [[FUIPhoneAuth alloc] initWithAuthUI:[FUIAuth defaultAuthUI]];
    [FUIAuth defaultAuthUI].providers = @[phoneProvider];
    
    [APP_DELEGATE sendSwrveEventWithEvent:@"3-Onboarding.Start1.OB_Start_Landing" andScreen:@"Start1"];
    // boatScreenHasBeenPushed = NO;
    
    //[[NSUserDefaults standardUserDefaults] setBool:false forKey:kBoatScreenPushed];
    
    [descriptionButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    if (_isAuthenticationFailed) { // If authentication has been failed
        
        [self displayLoginUI];
        
        // [self configureViews];
        
        return;
         
    }
    
    if ([self checkForFeedbackError]){
        return;
    }
    
//    if ([LoginModel sharedInstance].isAlternateLogin){
        if ([[NSUserDefaults standardUserDefaults] valueForKey:kWooUserId] != nil){
            if ([LoginModel sharedInstance].confirmed){
                [APP_Utilities sendToDiscover];
            }
            else{
                if ([LoginModel sharedInstance].isUserRegistered == false){
                    [self moveToOnBoardingScreensBasedOnData];
                }
                else{
                    
                    if ([LoginModel sharedInstance].isAlternateLogin){
                        
                        if ([LoginModel sharedInstance].isAlertnativeLoginTypeTrueCaller){
                            [self makeLoginCallToServerWithUserId:nil withAccessToken:nil withDictionary:nil andLoginThrough:LoginViaTrueCaller];
                        }
                        else{
                            [self makeLoginCallToServerWithUserId:nil withAccessToken:nil withDictionary:nil andLoginThrough:LoginViaNativeOTP];
                        }
                        
                    }else{
                        
                        [self makeLoginCallToServerWithUserId:[[NSUserDefaults standardUserDefaults] objectForKey:kStoredfbId]
                        withAccessToken:[[NSUserDefaults standardUserDefaults] objectForKey:kStoredAccessToken] withDictionary:nil andLoginThrough:LoginViaFacebook];
                    }
                    
                }
            }
        }
//    }
//    else{
//        if ([[NSUserDefaults standardUserDefaults] objectForKey:kStoredfbId] == nil) {
//            if ([[NSUserDefaults standardUserDefaults] objectForKey:kFacebookNumbericUserID] != nil) {
//
//                [[NSUserDefaults standardUserDefaults] setValue:[[NSUserDefaults standardUserDefaults] objectForKey:kFacebookNumbericUserID] forKey:kStoredfbId];
//                [[NSUserDefaults standardUserDefaults] synchronize];
//
//                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserAlreadyRegistered];
//            }
//
//        }
//
//        if ([[NSUserDefaults standardUserDefaults] objectForKey:kStoredAccessToken] && [[NSUserDefaults standardUserDefaults] objectForKey:kStoredfbId] && ![[NSUserDefaults standardUserDefaults] boolForKey:kUserAlreadyRegistered] ) { // not confirmed
//
////                [self makeLoginCallToServerWithUserId:[[NSUserDefaults standardUserDefaults] objectForKey:kStoredfbId]
////                                          withAccessToken:[FBSDKAccessToken currentAccessToken].tokenString];
//
//            delayFlag = true;
////            [self moveToOnBoardingScreensBasedOnData];
//
//            [self makeLoginCallToServerWithUserId:[[NSUserDefaults standardUserDefaults] objectForKey:kStoredfbId]
//                                  withAccessToken:[[NSUserDefaults standardUserDefaults] objectForKey:kStoredAccessToken] withDictionary:nil andLoginThrough:LoginViaFacebook];
////
//
//        }else if ([[NSUserDefaults standardUserDefaults] objectForKey:kStoredAccessToken] &&
//                 [[NSUserDefaults standardUserDefaults] objectForKey:kStoredfbId] &&
//                 [[NSUserDefaults standardUserDefaults] boolForKey:kUserAlreadyRegistered] &&
//                 [[NSUserDefaults standardUserDefaults] objectForKey:kUserLastLocationKey] &&
//                 ![[NSUserDefaults standardUserDefaults] boolForKey:kLocationNeedsToBeUpdatedOnServer] && [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]){
//
//            // User confirmed & location is saved.
//
//            [APP_Utilities sendToDiscover];
//
//        }else if ([[NSUserDefaults standardUserDefaults] objectForKey:kStoredAccessToken] &&
//                  [[NSUserDefaults standardUserDefaults] objectForKey:kStoredfbId] &&
//                  [[NSUserDefaults standardUserDefaults] boolForKey:kUserAlreadyRegistered] &&
//                  [[NSUserDefaults standardUserDefaults] boolForKey:kLocationFound] && [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]){
//
//            // User confirmed & location found from server is true.
//            NSLog(@"third condition of facebook");
//            [APP_Utilities sendToDiscover];
//
//        }else if ([[NSUserDefaults standardUserDefaults] objectForKey:kStoredAccessToken] &&
//                  [[NSUserDefaults standardUserDefaults] objectForKey:kStoredfbId] &&
//                  [[NSUserDefaults standardUserDefaults] boolForKey:kUserAlreadyRegistered] &&
//                  ![[NSUserDefaults standardUserDefaults] objectForKey:kUserLastLocationKey] && [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]){
//            // If user does't have location but user is confirmed
//
//            NSLog(@"fourth condition of facebook");
//            [APP_Utilities sendToDiscover];
//        }
//    }
    
    [self displayLoginUI];
    
    //initializing Fb Account kit
    
}



- (BOOL)checkForFeedbackError{
    // Check whether error feedback send is less than 15 min
    NSDate *lastTime = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:kLoginErrorFeedbackTimeStamp];
    NSLog(@"LAST TIME = %@",lastTime);
    self.introImages = (NSMutableArray *)[NSArray arrayWithObjects:
                                          [UIImage imageNamed:@"loginImageset1"],
                                          [UIImage imageNamed:@"loginImageset2"],
                                          [UIImage imageNamed:@"loginImageset3"],
                                          [UIImage imageNamed:@"loginImageset4"],
                                          [UIImage imageNamed:@"loginImageset5"],
                                          nil];
    if (lastTime) {
        [self calculateErrorFeedbackTime:lastTime];
        return true;
    }
    else{
        return false;
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    [self displayLoginUI];
    [self changeViewPosition];
    [viewMask setHidden:YES];
}

-(void)initUIElementsAndConstraints{
    //Adding Images for animation
    
    NSLog(@"yha tk aaya");
    //Adding  Borders
    //TODO- Add in .XIB
    btnSignInPhoneNumber.layer.borderWidth = 2;
    btnSignInPhoneNumber.layer.borderColor = [[UIColorHelper colorWithRGBA:@"#d7d6d4"] CGColor];
    btnSignInPhoneNumber.layer.cornerRadius = 4;
    
    
    if (IS_IPHONE_5){
        //bring the views upside only for phones Ex: iphone SE, 5S
        NSLog(@"yha pe  bhi aaya");
        constraintwooLogo.constant = -13;
        constraintWooWidth.constant = 130;
        constraintWooHeight.constant = 40;
        constraintWePutWomen.constant = 10;
        fbLoginButton.titleLabel.font = [UIFont fontWithName:kLatoRegular size:12];
        btnSignInPhoneNumber.titleLabel.font = [UIFont fontWithName:kLatoRegular size:12];
        appleSignInBtn.titleLabel.font = [UIFont fontWithName:kLatoRegular size:12];
        constraintAnimateImageBottom.constant = -4;
    }
    
    else if (IS_IPHONE_EqualToIphone_6){
        //Iphone 6, 7, 8
        
        NSLog(@"Iphone 6");
        constraintWooWidth.constant = 135;
        //constraintWooHeight.constant = 48;
        constraintwooLogo.constant = -12;
        constraintWePutWomen.constant = 15;
        constraintWhyFacebookBottom.constant = 22;
        constraintAnimateImageBottom.constant = -25;
    }
    else if (IS_IPHONE_HigherThanIphone_6){
        //Iphone 6+ 8+, 7+ and Iphone x
        constraintWooWidth.constant = 135;
        constraintwooLogo.constant = 9;
        constraintWePutWomen.constant = 22;
        constraintWhyFacebookBottom.constant = 25;
        constraintAnimateImageBottom.constant = -45;
        NSLog(@"Iphone 6+");
        
    }else{
        //Nothing falls in this condition, as we coverted everthing in upper conditions. Modify later if somedevice falls here
    }
    [viewMask setHidden:true];
}


-(void)animateImages
{
    //return the animation after it is moved
    
    if (!shouldStop){
        imageAnimationIndex = 0;
        
        return;
    }
    
    imageAnimationIndex++;
    __block LoginViewController *loginObject = self;
    [UIView transitionWithView:imageViewIntro
                      duration:4.0f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        loginObject->imageViewIntro.image = [self.introImages objectAtIndex:imageAnimationIndex % [self.introImages count]];
                    } completion:^(BOOL finished) {
                        if (self->shouldStop){
                            [self animateImages];
                        }
                    }];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if ([loginInfoView superview]) {
        [loginInfoView dismissLoginInfoView];
    }
}


#pragma mark - Calculate Login Error Feedback timestamp
- (void)calculateErrorFeedbackTime:(NSDate *)lastTime{
    
    NSDate *currentTime = [NSDate date];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitSecond
                                               fromDate:lastTime
                                                 toDate:currentTime
                                                options:0];
    
    
    int diffInSecond = (int)components.second;
    
    int resetTime = feedbackTimeInterval - diffInSecond;
    
    if (diffInSecond < feedbackTimeInterval) {
        
        [self resetTimer:resetTime];
        [facebookBtn setAlpha:0.5];
        [facebookBtn setUserInteractionEnabled:NO];
        [self displayLoginUI];
        //  [self changeViewPosition];
        
    }else{
        
        [facebookBtn setAlpha:1.0];
        [facebookBtn setUserInteractionEnabled:YES];
        [self displayLoginUI];
        // [self changeViewPosition];
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    int page = scrollView.contentOffset.x / scrollView.frame.size.width;
    //    pageControlObj.currentPage = page;
    [pageControlObj setCurrentPage:page];
    [self.view bringSubviewToFront:pageControlObj];

    if (page == 2) {
        descriptionButton.titleLabel.textColor = kIntroCyanColor;
    }else{
        descriptionButton.titleLabel.textColor = [UIColor colorWithRed:(240.0f/255.0f) green:(240.0f/255.0f) blue:(240.0f/255.0f) alpha:1.0f];
    }
    // UIImage *newImage;
    switch (page) {
        case 0:
        {
            if ([APP_Utilities isIndianUser]) {
                //       newImage = [UIImage imageNamed:@"tutorialIndiaFirst"];
            }else{
                //       newImage = [UIImage imageNamed:@"tutorialInternationalFirst"];
            }
        }
            break;
        case 1:
        {
            if ([APP_Utilities isIndianUser]) {
                //       newImage = [UIImage imageNamed:@"tutorialIndiaSecond"];
            }else{
                //       newImage = [UIImage imageNamed:@"tutorialInternationalSecond"];
            }
        }
            break;
        case 2:
        {
            if ([APP_Utilities isIndianUser]) {
                //          newImage = [UIImage imageNamed:@"tutorialIndiaThird"];
            }else{
                //         newImage = [UIImage imageNamed:@"tutorialInternationalThird"];
            }
        }
            break;
            
        default:
            break;
    }
    
}

-(void)addAllObservers{
    [self removeAllObserver];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeLoginCall:) name:kUserLoggedInSuccessfully object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeFBSyncCall) name:kDismissLoginViewAndMakeToFBSync object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushToPostLoginViewController:) name:kPushToVerificationScreen object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showIndicatorView) name:kShowIndicatorViewOnLoginScreen object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideIndcatorView) name:kHideIndicatorViewOnLoginScreen object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeToSecondViewForiOS8andBelow) name:kNotificationForCancelledFromFacebook object:nil];
    
}
-(void)makeFBSyncCall{
    if (_isViewPresentedFromSync) {
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kMakeFbSyncCall object:nil];
            if (dismissBlock) {
                dismissBlock(TRUE,[FBSession activeSession].accessTokenData.accessToken);
            }
        }];
    }
}

-(void)showIndicatorView{
    [self showActivityIndicatorViewInCenter:FALSE];
}

-(void)hideIndcatorView{
    [self hideActivityIndcatorView];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:YES];
    if (loginViewObj.doesLoginFailed) {
        _isFirstViewVisible = YES;
    }else{
        _isFirstViewVisible = NO;
    }
    NSLog(@"scroll view content size :%@",NSStringFromCGSize(self.scrollView.contentSize));
    NSLog(@"view content size :%@",NSStringFromCGRect(self.view.frame));
    NSLog(@"content view size :%@",NSStringFromCGRect(self.contentView.frame));
    
    NSDictionary *attrDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [UIFont fontWithName:@"Lato-Regular" size:10.0],NSFontAttributeName,
                              [UIColor whiteColor],NSForegroundColorAttributeName,
                              @(NSUnderlineStyleSingle),NSUnderlineStyleAttributeName,
                              [UIColor clearColor],NSBackgroundColorAttributeName,
                              nil];
    //                            @{
    //                               NSFontAttributeName : [UIFont fontWithName:@"Lato-Regular" size:10.0],
    //                               NSForegroundColorAttributeName : [UIColor whiteColor],
    //                               NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
    //                                 NSBackgroundColorAttributeName: [UIColor clearColor]
    //                               };
    
    [privacyPolicyButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Privacy Policy", @"") attributes:attrDict] forState:UIControlStateNormal];
    
    if (SCREEN_HEIGHT <= 480) {
        topToFirstViewConstraint.constant = -firstView.frame.size.height;
        bottomToSecondViewConstraint.constant = - secondView.frame.size.height;
        [self.view layoutIfNeeded];
        firstView.hidden = TRUE;
        secondView.hidden = TRUE;
    }
    
    
    
    [self.view bringSubviewToFront:pageControlObj];
    
    int introPosition = 2;
    [self performSelector:@selector(startTheIntroAnimationWithPosition:) withObject:[NSNumber numberWithInt:introPosition] afterDelay:2.0];
    
}

-(void)colorStatusBar{
    [[Utilities sharedUtility]colorStatusBar:[UIColor whiteColor]];
}

-(void)viewWillAppear:(BOOL)animated{
    
    
    [super viewWillAppear:YES];
    [self colorStatusBar];
    
    [APP_Utilities isIndianUser];
    //TODO why are we removing before adding the observers
    [self addAllObservers];
    
    isLoginCallMade = FALSE;
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    if (loginViewObj.doesLoginFailed) {
        _isFirstViewVisible = YES;
    }else{
        _isFirstViewVisible = NO;
    }
    
    if (delayFlag == true) {
        
        delayFlag = false;
        [self performSelector:@selector(changeViewPosition)];
        
    }else{
        
        [self performSelector:@selector(changeViewPosition) withObject:nil afterDelay:0.3];
    }
    
    
    [self displayLoginUI];
    [self changeViewPosition];
    
    if(!shouldStop){
        shouldStop = true;
        [self animateImages];
    }
    [viewMask setHidden:YES];
    [self initUIElementsAndConstraints];
    
    
}

- (void)startTheIntroAnimationWithPosition:(NSNumber *)position{
    int positionOfIntro = position.intValue;
    if (positionOfIntro > 5 || positionOfIntro < 1) {
        positionOfIntro = 1;
    }
    
    NSString *firstText;
    NSString *secondText;
    __block NSString *imageName;
    
    // CGFloat alphaPropertyForBottomView = 1.0;
    switch (positionOfIntro) {
        case 1:{
            firstText = @"";
            secondText = @"";
            // alphaPropertyForBottomView = 0.0;
        }
            break;
        case 2:{
            firstText = @"Connect Across the Globe";
            secondText = @"Global yet indvidual, with smart filters";
        }
            break;
        case 3:{
            firstText = @"Search with Tags";
            secondText = @"Discover and be discovered";
        }
            break;
        case 4:{
            firstText = @"Send a Crush";
            secondText = @"Make the first move";
        }
            break;
        case 5:{
            firstText = @"Ask Questions";
            secondText = @"Connect if you like the answer";
        }
            break;
            
        default:{
            firstText = @"";
            secondText = @"";
            // alphaPropertyForBottomView = 0.0;
        }
            break;
    }
    
    //        [UIView animateWithDuration:1.0 animations:^{
    //        [topView setAlpha:0.0];
    //        [introScreenImageView setAlpha:0.0];
    //    } completion:^(BOOL finished) {
    //        [UIView animateWithDuration:2.0 animations:^{
    //            [firstLabel setText:firstText];
    //            [secondLabel setText:secondText];
    //
    //            imageName = [NSString stringWithFormat:@"intro_screen_%d",positionOfIntro];
    //            introScreenImageView.image = [UIImage imageNamed:imageName];
    //
    //            [topView setAlpha:1.0];
    //            [introScreenImageView setAlpha:1.0];
    //            [bottomFacebookWarningArea setAlpha:alphaPropertyForBottomView];
    //
    //        }];
    //    }];
    
    [firstLabel setText:NSLocalizedString(firstText, @"")];
    [secondLabel setText:NSLocalizedString(secondText, @"")];
    
    imageName = [NSString stringWithFormat:@"intro_screen_%d",positionOfIntro];
    introScreenImageView.image = [UIImage imageNamed:imageName];
    
    [topView setAlpha:1.0];
    [introScreenImageView setAlpha:1.0];
    //[bottomFacebookWarningArea setAlpha:alphaPropertyForBottomView];
    
    positionOfIntro++;
    [self performSelector:@selector(startTheIntroAnimationWithPosition:) withObject:[NSNumber numberWithInt:positionOfIntro] afterDelay:4.5];
    
}

-(void)changeViewPosition{
    [self.view bringSubviewToFront:bottomContainerView];
    [bottomContainerView bringSubviewToFront:bottomFacebookWarningArea];
    [bottomFacebookWarningArea bringSubviewToFront:iButton];
    [bottomContainerView bringSubviewToFront:loginInfoView];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    shouldStop = false;
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:YES];
    [self hideActivityIndcatorView];
    
}

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer
{
    [self.animator animate:[recognizer locationOfTouch:0 inView:self.view].x];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark FacebookCancelledObserverForiOS8AndBelow

- (void)changeToSecondViewForiOS8andBelow
{
    if (loginViewObj.doesLoginFailed) {
        _isFirstViewVisible = YES;
    }else{
        _isFirstViewVisible = NO;
    }
    
}

#pragma mark
#pragma mark instance methods

-(void)performManualLogout{
    //need to perform login again
    //clear session to get login button again
    //    [[FBSession activeSession] closeAndClearTokenInformation];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kStoredAccessToken];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastVerificationState];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kIsLoginProcessCompleted];
    
    //Added by Umesh
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kWooUserId];
}




-(void)displayLoginUI{
    
    __weak typeof(self) weakSelf = self;
    
    NSDate *now = [NSDate date];
    long long nowAsLong = [now timeIntervalSince1970];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kTimeForNextShowLoginButton] && [[[NSUserDefaults standardUserDefaults] objectForKey:kTimeForNextShowLoginButton] longLongValue] > nowAsLong) {
        [facebookBtn setHidden:YES];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kStoredAccessToken];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self logoutUser];
    }else{
        
        if (facebookBtn) {
            [facebookBtn removeAllObserver];
            facebookBtn = nil;
        }
        
        if (!facebookBtn) {
            facebookBtn = [FBSDKLogin sharedManagerFBSDKLogin];
        }
        
        
        if (_isViewPresentedFromSync) {
            [loginViewObj setIsPresentedForFBSync:TRUE];
        }
        [facebookBtn showLoginButtonWithTitle:@"SIGN-IN WITH FACEBOOK" ];
        facebookBtn.backgroundColor = [UIColor clearColor];
        
        [facebookBtn fbLoginButtonClicked:^(bool isButtonTapped) {
            if (isButtonTapped){
//                [[Utilities sharedUtility] sendMixPanelEventWithName:@"Fblogin"];
                [self->btnSignInPhoneNumber setHidden:YES];
                [self->btnWhyFacebook setHidden:YES];
            }else{
                NSLog(@"set hidden false");
                [self->btnSignInPhoneNumber setHidden:NO];
                [self->btnWhyFacebook setHidden:NO];
            }
            
        }];
        
        __weak FBSDKLogin *weakFacebookBtn = facebookBtn;
        [weakFacebookBtn setCompletionBlock:^(NSString *accessToken, NSError *err , BOOL missingPermission) {
            [weakFacebookBtn hideLoader];
            if (!err && accessToken && !missingPermission) {
                
                NSLog(@"FB Access Token = %@",accessToken);
                
                NSLog(@"FBID = %@",[[FBSDKAccessToken currentAccessToken] userID]);
                
                if (![APP_Utilities reachable]){
                    
                    [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];
                    
                    return;
                }
                
                [APP_DELEGATE sendFirebaseEvent:@"FB_KIT_LOGIN" andScreen:@""];
                [[Utilities sharedUtility] sendMixPanelEventWithName:@"FB_KIT_LOGIN"];
                
                [[LoginModel sharedInstance] setIsAlternateLogin:NO];
                [weakSelf makeLoginCallToServerWithUserId:[[FBSDKAccessToken currentAccessToken] userID] withAccessToken:accessToken withDictionary:nil andLoginThrough:LoginViaFacebook];
                
            }else if (!accessToken){ // FbSDK issue while login
                
                if([err code]==306){
                    [self showFBSettingsErrorAlert];
                }else{
                    
                    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"Error") message:NSLocalizedString(@"There seems to an error coming from Facebook. Please try to login after sometime.", @"Try after some time.") preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CMP00356", @"Ok Button") style:UIAlertActionStyleCancel handler:nil];
                    [errorAlert addAction:okAction];
                    
                    [self presentViewController:errorAlert animated:true completion:nil];
                }
                
                
            }
            else{
                if (missingPermission) {
                    [weakSelf showReloginPopup];
                }
            }
            
        }];
        
        
        //CGRect screenRect = [[UIScreen mainScreen] bounds];
        // CGFloat screenHeight = screenRect.size.height;
        
        
        //[bottomContainerView setFrame:CGRectMake(0, screenHeight-120, 320, 120)];
        
        [facebookBtn setHidden:NO];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kIsFakeDtoInLoginKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if (![viewFB.subviews containsObject:facebookBtn]){
        [viewFB addSubview:facebookBtn];
    }
    
    if (facebookBtn.alpha == 0.5){
        [facebookBtn setHidden:YES];
        btnSignInPhonNumberBottom.constant = 20;
        [btnWhyFacebook setHidden:YES];
        
    }
}

- (IBAction) handleAuthrizationFromApple:(id) sender {
    NSLog(@"adsfasdf");
//    [self signoutfromFirebase];
    [self startSignInWithAppleFlow];
}

- (NSString *)randomNonce:(NSInteger)length {
  NSAssert(length > 0, @"Expected nonce to have positive length");
  NSString *characterSet = @"0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._";
  NSMutableString *result = [NSMutableString string];
  NSInteger remainingLength = length;

  while (remainingLength > 0) {
    NSMutableArray *randoms = [NSMutableArray arrayWithCapacity:16];
    for (NSInteger i = 0; i < 16; i++) {
      uint8_t random = 0;
      int errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random);
      NSAssert(errorCode == errSecSuccess, @"Unable to generate nonce: OSStatus %i", errorCode);

      [randoms addObject:@(random)];
    }

    for (NSNumber *random in randoms) {
      if (remainingLength == 0) {
        break;
      }

      if (random.unsignedIntValue < characterSet.length) {
        unichar character = [characterSet characterAtIndex:random.unsignedIntValue];
        [result appendFormat:@"%C", character];
        remainingLength--;
      }
    }
  }

  return result;
}



- (void)signoutfromFirebase {
    
    NSError *signOutError;
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    if (!status) {
      NSLog(@"Error signing out: %@", signOutError);
      return;
    }
}


- (void)startSignInWithAppleFlow {
    
  NSString *nonce = [self randomNonce:32];
  currentNonce = nonce;
  ASAuthorizationAppleIDProvider *appleIDProvider = [[ASAuthorizationAppleIDProvider alloc] init];
  ASAuthorizationAppleIDRequest *request = [appleIDProvider createRequest];
  request.requestedScopes = @[ASAuthorizationScopeFullName, ASAuthorizationScopeEmail];
  request.nonce = [self stringBySha256HashingString:nonce];

  ASAuthorizationController *authorizationController =
      [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[request]];
  authorizationController.delegate = self;
  authorizationController.presentationContextProvider = self;
  [authorizationController performRequests];
    
}

- (NSString *)stringBySha256HashingString:(NSString *)input {
  const char *string = [input UTF8String];
  unsigned char result[CC_SHA256_DIGEST_LENGTH];
  CC_SHA256(string, (CC_LONG)strlen(string), result);

  NSMutableString *hashed = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
  for (NSInteger i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
    [hashed appendFormat:@"%02x", result[i]];
  }
  return hashed;
}


- (void)authorizationController:(ASAuthorizationController *)controller
   didCompleteWithAuthorization:(ASAuthorization *)authorization API_AVAILABLE(ios(13.0)) {
    
  if ([authorization.credential isKindOfClass:[ASAuthorizationAppleIDCredential class]]) {
    ASAuthorizationAppleIDCredential *appleIDCredential = authorization.credential;
    NSString *rawNonce = currentNonce;
    NSAssert(rawNonce != nil, @"Invalid state: A login callback was received, but no login request was sent.");

    if (appleIDCredential.identityToken == nil) {
      NSLog(@"Unable to fetch identity token.");
      return;
    }

      
    NSString *idToken = [[NSString alloc] initWithData:appleIDCredential.identityToken
                                              encoding:NSUTF8StringEncoding];
     
    if(appleIDCredential.fullName.givenName != nil){
          
      [[NSUserDefaults standardUserDefaults] setObject:appleIDCredential.fullName.givenName forKey:@"firstNameAppleLogin"];
      [[NSUserDefaults standardUserDefaults] setObject:appleIDCredential.fullName.familyName forKey:@"lastNameAppleLogin"];
          
    }
      
    if (idToken == nil) {
      NSLog(@"Unable to serialize id token from data: %@", appleIDCredential.identityToken);
    }

    // Initialize a Firebase credential.
    FIROAuthCredential *credential = [FIROAuthProvider credentialWithProviderID:@"apple.com" IDToken:idToken rawNonce:rawNonce];

    // Sign in with Firebase.
    [[FIRAuth auth] signInWithCredential:credential
                              completion:^(FIRAuthDataResult * _Nullable authResult,
                                           NSError * _Nullable error) {
      if (error != nil) {
        // Error. If error.code == FIRAuthErrorCodeMissingOrInvalidNonce,
        // make sure you're sending the SHA256-hashed nonce as a hex string
        // with your request to Apple.
          
          UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"Error") message:NSLocalizedString(@"There seems to an error coming from Firebase. Please try to login after sometime.", @"Try after some time.") preferredStyle:UIAlertControllerStyleAlert];
                             
                             UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CMP00356", @"Ok Button") style:UIAlertActionStyleCancel handler:nil];
                             [errorAlert addAction:okAction];
                             
                             [self presentViewController:errorAlert animated:true completion:nil];
        return;
          
      }else{
            NSLog(@"user Apple login successfully");
            
            FIRUser *user = authResult.user;
            
            NSLog(@"fullName for sign in apple for real device is %@", appleIDCredential.fullName);
               
            [user getIDTokenWithCompletion:^(NSString * _Nullable token, NSError * _Nullable error) {
                NSLog(@"token for apple sign in %@",token);
                [[LoginModel sharedInstance] setIsAlternateLogin:YES];
                [[LoginModel sharedInstance] setIsAlertnativeLoginTypeTrueCaller:NO];
                [self makeLoginCallToServerWithUserId:nil withAccessToken:token withDictionary:nil andLoginThrough:LoginViaAppple];
            }];
            
        }
        
      // Sign-in succeeded!
    }];
  }
}

- (void)authorizationController:(ASAuthorizationController *)controller
           didCompleteWithError:(NSError *)error API_AVAILABLE(ios(13.0)) {
    NSLog(@"Sign in with Apple errored: %ld", (long)[error code]);
    
    NSInteger errorCode = (long)[error code];
    if(errorCode != 1001){
        UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"Error") message:NSLocalizedString(@"There seems to an error coming from Firebase. Please try to login after sometime.", @"Try after some time.") preferredStyle:UIAlertControllerStyleAlert];
                              
                              UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CMP00356", @"Ok Button") style:UIAlertActionStyleCancel handler:nil];
                              [errorAlert addAction:okAction];
                              
                              [self presentViewController:errorAlert animated:true completion:nil];
           
    }
}




-(void)showFBSettingsErrorAlert{
    
    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"Error") message:NSLocalizedString(@"Access has not been granted to the Facebook account. Verify device settings.", @"Check Device Settings") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", @"Ok Button") style:UIAlertActionStyleCancel handler:nil];
    [errorAlert addAction:okAction];
    
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Open Settings", @"Open Settings") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    [errorAlert addAction:settingsAction];
    
    [self presentViewController:errorAlert animated:true completion:nil];
    
}

-(void)showReloginPopup{
    UIAlertController *permissionMissingAlert = [UIAlertController alertControllerWithTitle:@"Need more details!" message:@"We need some more details to build \nan accurate Woo profile for you. \nPlease allow Woo to access \nFacebook for this information. \n\nWoo never posts on your wall." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Authorize Facebook", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (!facebookBtn) {
            facebookBtn = [FBSDKLogin sharedManagerFBSDKLogin];
        }
        [facebookBtn getLoginPermissionFromFacebook];
    }];
    [permissionMissingAlert addAction:defaultAction];
    [self presentViewController:permissionMissingAlert animated:YES completion:nil];
}


#pragma mark - Login Call To Server
-(void)makeLoginCallToServerWithUserId:(NSString *)fbId withAccessToken:(NSString *)accessToken withDictionary:(id)Parameters andLoginThrough:(NSString *)viaMedium {
    
    [APP_DELEGATE sendSwrveEventWithEvent:@"3-Onboarding.Start1.FB_Login" andScreen:@"Start1"];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:(fbId == nil)? @"" : fbId  forKey:@"fbID"];
    [dict setObject:(accessToken == nil)? @"" : accessToken forKey: @"accessToken"];
    [dict setObject:[[CLLocation alloc] init] forKey:@"location"];
    [dict setObject:(Parameters == nil)? @"" : Parameters forKey:@"TruecallerParameters"];
    [dict setObject:viaMedium forKey:@"loginVia"];
    
    if([viaMedium isEqualToString:LoginViaFacebook]){
        [[Utilities sharedUtility] sendMixPanelEventWithName:@"Fblogin"];
    }else if([viaMedium isEqualToString:LoginViaFirebase]){
        [[Utilities sharedUtility] sendMixPanelEventWithName:@"Firebase_Login_iOS"];
    }
    
    //   NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:fbId, , accessToken,, nil , , viaMedium , @"loginVia", nil];
    
    //    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
    //                                                    fbId , @"fbId",
    //                                                    accessToken, @"accessToken",
    //                          nil,          @"location",nil];
    //
    //
    //
    //
    //                          Parameters, @"TruecallerParameters", viaMedium , @"loginVia",
    //                                                    nil
    //
    [self performSegueWithIdentifier:kPushToLoginLoadingController sender:dict];
}


- (void) selectedPhotoData:(id)photoData{
    
    NSLog(@"%@",photoData);
}

- (void) goToNextScreenwithResponse:(NSString *)response withAccessToken:(NSString *)accessToken withUserChangedStatus:(BOOL)userChanged{
    
    if (_isAuthenticationFailed && !userChanged) { // If authentication failed , re-login & also check whether last user fbid & current user fbid  are same of different
        
        if ([_authenticationController respondsToSelector:@selector(authenticationFailedCallBack)]) {
            
            [_authenticationController performSelector:@selector(authenticationFailedCallBack) withObject:nil afterDelay:0.3];
            
        }
        [self dismissViewControllerAnimated:YES completion:^{
            if (dismissBlock) {
                dismissBlock(TRUE,[FBSession activeSession].accessTokenData.accessToken);
            }
        }];
        
        return;
    }
    [self goToNextScreenBasedOnLoginDataWithAccessToken:accessToken andNewUserNoPicShown:false];
    
}

- (void) moveToOnBoardingScreensBasedOnData{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.navigationController popToRootViewControllerAnimated:false];
        
        UIStoryboard *onBoardingStoryboard = [UIStoryboard storyboardWithName:@"onboarding" bundle:nil];
        OnBoardingNameViewController *onBoardingName = [onBoardingStoryboard instantiateViewControllerWithIdentifier:@"OnBoardingNameViewController"];
        [self.navigationController pushViewController:onBoardingName animated:true];
        
    });
}

- (void)goToNextScreenBasedOnLoginDataWithAccessToken:(NSString *)accessToken andNewUserNoPicShown:(BOOL)newUserNoPicShown{
    [[ApplozicChatManager sharedApplozicChatManager] connectUserToApplozicWithClientObject:APP_DELEGATE.applozic withAppLozicAuthBlock:^(BOOL authenticationSuccess, ApplozicClient * _Nonnull applozicClient) {
        if (!authenticationSuccess){
            return;
        }
        else{
            if ([ApplozicChatManager sharedApplozicChatManager].connectionEstablishedBlock){
                [ApplozicChatManager sharedApplozicChatManager].connectionEstablishedBlock(TRUE);
                [ApplozicChatManager sharedApplozicChatManager].connectionEstablishedBlock = nil;
            }
        }
    }];
    
    
    if ([[LoginModel sharedInstance] confirmed] && [[LoginModel sharedInstance] locationFound]) {
        NSLog(@"first condition me ghusa");
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"isOnboardingMyProfileShown"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [APP_Utilities sendToDiscover];
        
    }else if ([[LoginModel sharedInstance] confirmed] && ![[LoginModel sharedInstance] locationFound]) { // User confirmed but location not found
        NSLog(@"second condition me ghusa");
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"isOnboardingMyProfileShown"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [APP_Utilities sendToDiscover];
        
    }else if (![[LoginModel sharedInstance] confirmed] && [[LoginModel sharedInstance] locationFound]){
        
        NSLog(@"third condition me ghusa");
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"isOnboardingMyProfileShown"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"tutorialNotShown"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        if ([LoginModel sharedInstance].isAlternateLogin){
            BOOL showNewUserNoPic =[LoginModel sharedInstance].isNewUserNoPicScreenOn;
            
            if (newUserNoPicShown){
                showNewUserNoPic = false;
            }
            else if ([LoginModel sharedInstance].profilePicUrl != nil){
                showNewUserNoPic = false;
            }
            
            if(showNewUserNoPic){ // new user no pic
                
                if ([LoginModel sharedInstance].isUserRegistered){
                    int width = SCREEN_WIDTH * .7361;
                    
                    VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:[UIImage imageNamed:@"crop_default"] cropFrame:CGRectMake((SCREEN_WIDTH - width)/2,0.122*SCREEN_HEIGHT, width, 0.655*SCREEN_HEIGHT) limitScaleRatio:3.0];
                    
                    imgCropperVC.isImageAdded = YES;
                    imgCropperVC.delegate = self;
                    
                    [self.navigationController pushViewController:imgCropperVC animated:YES];
                }
                else{
                    [self moveToOnBoardingScreensBasedOnData];
                }
            }
            else if ([LoginModel sharedInstance].isPhotoScreenGridOn){
                if ([LoginModel sharedInstance].isUserRegistered){
                    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId];
                    
                    [ProfileAPIClass fetchDataForUserWithUserID:userID.longLongValue withCompletionBlock:^(id response, BOOL success, int statusCode) {
                        if (success){
                            APP_DELEGATE.onBaordingPageNumber++;
                            WizardPhotoViewController *photoViewController = [[WizardPhotoViewController alloc] initWithNibName:@"WizardPhotoViewController" bundle:[NSBundle mainBundle]];
                            [self.navigationController pushViewController:photoViewController animated:true];
                        }
                    }];
                }
                else{
                    [self moveToOnBoardingScreensBasedOnData];
                }
            }
            else if ([LoginModel sharedInstance].age == 0 || [[LoginModel sharedInstance].gender isEqualToString:@"UNKNOWN"]){ // Showing Age Gender Screen
                
                if ([LoginModel sharedInstance].isUserRegistered){
                    APP_DELEGATE.onBaordingPageNumber++;
                    [self performSegueWithIdentifier:kAgeGenderControllerID sender:nil];
                }
                else{
                    [self moveToOnBoardingScreensBasedOnData];
                }
            }
            else if (LoginModel.sharedInstance.userLifestyleTagsAvailable == false || LoginModel.sharedInstance.userRelationshipTagsAvailable == false) {
                APP_DELEGATE.onBaordingPageNumber++;
                RelationshipViewController *relationshipController = [RelationshipViewController loadNib:@"Relationship and Lifestyle"];
                [relationshipController setViewsfor:1 tagData:0 closeBtn:false title:@"Relationship and Lifestyle"];
                [self.navigationController pushViewController:relationshipController animated:true];
            }
            else if(![[LoginModel sharedInstance] userOtherTagsAvailable]){           //changed condition as if the value is true user should not see the tag screen
                if ([LoginModel sharedInstance].isUserRegistered){
                    APP_DELEGATE.onBaordingPageNumber++;
                    //[self performSegueWithIdentifier:kTagScreenControllerID sender:nil];
                    
                    WizardTagsViewController *wizardTagsVC = [[WizardTagsViewController alloc] initWithNibName:@"WizardTagsViewController" bundle:nil];
                    [wizardTagsVC setIsUsedOutOfWizard:true];
                    [wizardTagsVC setIsPartOfOnboarding:true];
                    [self.navigationController pushViewController:wizardTagsVC animated:true];
                }
                else{
                    [self moveToOnBoardingScreensBasedOnData];
                }
            }
            else if([[LoginModel sharedInstance] personalQuoteText]){
                // Showing About Me Screen.
                
                if ([LoginModel sharedInstance].isUserRegistered){
                    APP_DELEGATE.onBaordingPageNumber++;
                    [self performSegueWithIdentifier:kAboutMeScreenControllerID sender:nil];
                }
                else{
                    [self moveToOnBoardingScreensBasedOnData];
                }
            }
            else{
                [APP_Utilities sendToDiscover];
            }
        }
        else{
            
            if(![LoginModel sharedInstance].isUserRegistered){
                NSLog(@"isuserRegister false");
                [self moveToOnBoardingScreensBasedOnData];
            }else{
                NSLog(@"isuserRegister true");
                if ([[LoginModel sharedInstance] startScreenTitle]){
                    
                    [self performSegueWithIdentifier:kBoatScreenControllerID sender:nil];
                    
                }else if ([LoginModel sharedInstance].age == 0 || [[LoginModel sharedInstance].gender isEqualToString:@"UNKNOWN"]){ // Showing Age Gender Screen
                    
                    if ([LoginModel sharedInstance].isAlternateLogin){
                        if ([LoginModel sharedInstance].isUserRegistered){
                            APP_DELEGATE.onBaordingPageNumber++;
                            [self performSegueWithIdentifier:kAgeGenderControllerID sender:nil];
                        }
                        else{
                            [self moveToOnBoardingScreensBasedOnData];
                        }
                    }
                    else{
                        
                        if ([LoginModel sharedInstance].isUserRegistered){
                            APP_DELEGATE.onBaordingPageNumber++;
                            [self performSegueWithIdentifier:kAgeGenderControllerID sender:nil];
                        }else{
                          [self moveToOnBoardingScreensBasedOnData];
                        }
                    }
                }else if ([LoginModel sharedInstance].isPhotoScreenGridOn){
                    if ([LoginModel sharedInstance].isUserRegistered){
                        NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId];
                        
                        [ProfileAPIClass fetchDataForUserWithUserID:userID.longLongValue withCompletionBlock:^(id response, BOOL success, int statusCode) {
                            if (success){
                                APP_DELEGATE.onBaordingPageNumber++;
                                WizardPhotoViewController *photoViewController = [[WizardPhotoViewController alloc] initWithNibName:@"WizardPhotoViewController" bundle:[NSBundle mainBundle]];
                                [self.navigationController pushViewController:photoViewController animated:true];
                            }
                        }];
                    }
                    else{
                        [self moveToOnBoardingScreensBasedOnData];
                    }
                }else if ([[LoginModel sharedInstance] favIntent] != INTENT_TYPE_NONE){ // Showing Intent Screen
                    
                    APP_DELEGATE.onBaordingPageNumber++;
                    [self performSegueWithIdentifier:kIntentScreenControllerID sender:nil];
                }
                else if (LoginModel.sharedInstance.userLifestyleTagsAvailable == false || LoginModel.sharedInstance.userRelationshipTagsAvailable == false) {
                    
                    NSLog(@"Relationship vaali screen open hai");
                    
                    APP_DELEGATE.onBaordingPageNumber++;
                    RelationshipViewController *relationshipController = [RelationshipViewController loadNib:@"Relationship and Lifestyle"];
                    [relationshipController setViewsfor:1 tagData:0 closeBtn:false title:@"Relationship and Lifestyle"];
                    
                    [self.navigationController pushViewController:relationshipController animated:true];
                }
                else if(![[LoginModel sharedInstance] userOtherTagsAvailable]){           //changed condition as if the value is true user should not see the tag screen
                    if ([LoginModel sharedInstance].isAlternateLogin){
                        if ([LoginModel sharedInstance].isUserRegistered){
                            APP_DELEGATE.onBaordingPageNumber++;
                            //[self performSegueWithIdentifier:kTagScreenControllerID sender:nil];
                            
                            WizardTagsViewController *wizardTagsVC = [[WizardTagsViewController alloc] initWithNibName:@"WizardTagsViewController" bundle:nil];
                            [wizardTagsVC setIsUsedOutOfWizard:true];
                            [wizardTagsVC setIsPartOfOnboarding:true];
                            [self.navigationController pushViewController:wizardTagsVC animated:true];
                        }
                        else{
                            [self moveToOnBoardingScreensBasedOnData];
                        }
                    }
                    else{
                        APP_DELEGATE.onBaordingPageNumber++;
                        // [self performSegueWithIdentifier:kTagScreenControllerID sender:nil];
                        
                        WizardTagsViewController *wizardTagsVC = [[WizardTagsViewController alloc] initWithNibName:@"WizardTagsViewController" bundle:nil];
                        [wizardTagsVC setIsUsedOutOfWizard:true];
                        [wizardTagsVC setIsPartOfOnboarding:true];
                        [self.navigationController pushViewController:wizardTagsVC animated:true];
                    }
                }
                else if([[LoginModel sharedInstance] personalQuoteText]){ // Showing About Me Screen.
                    
                    if ([LoginModel sharedInstance].isAlternateLogin){
                        if ([LoginModel sharedInstance].isUserRegistered){
                            APP_DELEGATE.onBaordingPageNumber++;
                            [self performSegueWithIdentifier:kAboutMeScreenControllerID sender:nil];
                        }
                        else{
                            [self moveToOnBoardingScreensBasedOnData];
                        }
                    }
                    else{
                        APP_DELEGATE.onBaordingPageNumber++;
                        [self performSegueWithIdentifier:kAboutMeScreenControllerID sender:nil];
                    }
                }
                else if([[LoginModel sharedInstance] profilePicUrl] == nil){ // new user no pic
                    
                    if ([LoginModel sharedInstance].isAlternateLogin){
                        [self moveToOnBoardingScreensBasedOnData];
                    }
                    else{
                        int width = SCREEN_WIDTH * .7361;
                        
                        VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:[UIImage imageNamed:@"crop_default"] cropFrame:CGRectMake((SCREEN_WIDTH - width)/2,0.122*SCREEN_HEIGHT, width, 0.655*SCREEN_HEIGHT) limitScaleRatio:3.0];
                        
                        imgCropperVC.isImageAdded = YES;
                        imgCropperVC.delegate = self;
                        
                        [self.navigationController pushViewController:imgCropperVC animated:YES];
                    }
                    
                }else{
                    
                    [self moveToOnBoardingScreensBasedOnData];
                    
//                    if ([LoginModel sharedInstance].isAlternateLogin){
//                        [self moveToOnBoardingScreensBasedOnData];
//                    }
//                    else{
//                        if ([[LoginModel sharedInstance].gender isEqualToString:@"FEMALE"]){
//                            NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId];
//
//                            [ProfileAPIClass fetchDataForUserWithUserID:userID.longLongValue withCompletionBlock:^(id response, BOOL success, int statusCode) {
//                                if (success){
//                                    APP_DELEGATE.onBaordingPageNumber++;
//                                    WizardPhotoViewController *photoViewController = [[WizardPhotoViewController alloc] initWithNibName:@"WizardPhotoViewController" bundle:[NSBundle mainBundle]];
//                                    [self.navigationController pushViewController:photoViewController animated:true];
//                                }
//                            }];
//                        }
//                        else{
//                            [APP_Utilities sendToDiscover];
//                        }
//                    }
                }
            }
            
        }
    }
    
    else if (![[LoginModel sharedInstance] locationFound]) { // Push to Permission Screen
        
        NSLog(@"fourth condition me ghusa");
        
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"isOnboardingMyProfileShown"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"tutorialNotShown"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self performSegueWithIdentifier:kPermissionScreenControllerID sender:accessToken];
    }
}


#pragma mark - VPIImage Cropper Delegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(NSDictionary *)editedImageData {
    
    if ([LoginModel sharedInstance].isAlternateLogin){
        [self goToNextScreenBasedOnLoginDataWithAccessToken:@"" andNewUserNoPicShown:true];
    }
    else{
//        [cropperViewController.navigationController popViewControllerAnimated:NO];
//        [APP_Utilities sendToDiscover];
        [self goToNextScreenBasedOnLoginDataWithAccessToken:@"" andNewUserNoPicShown:true];
    }
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    
    if ([LoginModel sharedInstance].isAlternateLogin){
        [self goToNextScreenBasedOnLoginDataWithAccessToken:@"" andNewUserNoPicShown:true];
    }
    else{
//        [cropperViewController.navigationController popViewControllerAnimated:NO];
//        [APP_Utilities sendToDiscover];
        
        [self goToNextScreenBasedOnLoginDataWithAccessToken:@"" andNewUserNoPicShown:true];
    }
}




/*
 Method to show Discover screen
 */
-(void)pushToPostDiscoverViewController{
    //    return;
    //    [APP_Utilities hideActivityIndicator];  //hide activity indicator
    
    NSUserDefaults *userDefaultObj = [NSUserDefaults standardUserDefaults];
    [userDefaultObj setBool:TRUE forKey:kIsLoginProcessCompleted];
    [userDefaultObj synchronize];
    
    double delayInSeconds = 0.5f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        //        DiscoverViewController *discoverViewControllerObj = [self.storyboard instantiateViewControllerWithIdentifier:@"DiscoverViewController"];
        //        UINavigationController *navObj = [[UINavigationController alloc] initWithRootViewController:discoverViewControllerObj];
        //        [[APP_DELEGATE returnDrawerController] setCenterViewController:navObj];
        
        NSLog(@"self navigation controller :%@",self.navigationController);
        NSLog(@"self presened :%d",self.isBeingDismissed);
        NSLog(@"self %d",self.isMovingFromParentViewController);
        NSLog(@"self :%d",self.isModalInPopover);
        NSLog(@"");
        if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInSuccessfullyLoadDiscover object:nil];
            [self dismissViewControllerAnimated:YES completion:^{
                if (dismissBlock) {
                    dismissBlock(TRUE,[FBSession activeSession].accessTokenData.accessToken);
                }
            }];
            
        }
        [self removeTutorialAndFbView];
        //        [self dismissViewControllerAnimated:NO completion:^{
        //            [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification object:nil];
        //
        //            [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInSuccessfullyNotification object:nil];
        //            [self removeTutorialAndFbView];
        //        }];
    });
}

/*
 Method to push to Verification screen
 */
-(void)pushToPostLoginViewController:(id)responseObject{
    
    NSUserDefaults *userDefaultObj = [NSUserDefaults standardUserDefaults];
    [userDefaultObj setBool:FALSE forKey:kIsLoginProcessCompleted];
    [userDefaultObj synchronize];
    if (![responseObject isKindOfClass:[NSDictionary class]]) {
        responseObject = [responseObject userInfo];
        NSLog(@"fake DTo from user default :%@",[[NSUserDefaults standardUserDefaults] objectForKey:kIsFakeDtoInLoginKey]);
        NSLog(@"fakeDTo class from user default :%@",[[NSUserDefaults standardUserDefaults] objectForKey:kIsFakeDtoInLoginKey]);
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kIsFakeDtoInLoginKey] && [[[NSUserDefaults standardUserDefaults] objectForKey:kIsFakeDtoInLoginKey] isKindOfClass:[NSDictionary class]]) {
            responseObject = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [[NSUserDefaults standardUserDefaults] objectForKey:kIsFakeDtoInLoginKey],kIsFakeDtoInLoginKey,
                              [responseObject objectForKey:@"id"],@"id",
                              nil];
            //  @{kIsFakeDtoInLoginKey:[[NSUserDefaults standardUserDefaults] objectForKey:kIsFakeDtoInLoginKey],@"id":[responseObject objectForKey:@"id"]};
        }
    }
    
    NSString *keyText = @"";
    //    [APP_Utilities hideActivityIndicator];
    if ([[APP_Utilities validString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]] length]>0) {
        keyText = [NSString stringWithFormat:@"WooID_%@",[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
    }
    
    VerificationState currentState = [[[NSUserDefaults standardUserDefaults] valueForKey:kLastVerificationState] intValue];
    //UserVerificationState currentUserVerificatonState = UnverifiedUser;
    if ([keyText length]>0) {
        // currentUserVerificatonState = [[[NSUserDefaults standardUserDefaults] valueForKey:keyText] intValue];
    }
    BOOL wasPushedToInvite = [[NSUserDefaults standardUserDefaults] boolForKey:kIsPushedToInviteScreen];
    
    if ((currentState == VerificationComplete) || wasPushedToInvite){
        //        [self pushToConfirmProfileScreen];
    }
    else{
        [self performSegueWithIdentifier:kPushToVerificationViewControllerSegue sender:responseObject];
    }
    
    [self removeTutorialAndFbView];
}

- (NSString*) convertDictionaryToString:(NSMutableDictionary*) dict
{
    NSError* error;
    NSDictionary* tempDict = [dict copy]; // get Dictionary from mutable Dictionary
    //giving error as it takes dic, array,etc only. not custom object.
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:tempDict
                                                       options:NSJSONReadingMutableLeaves error:&error];
    NSString* nsJson=  [[NSString alloc] initWithData:jsonData
                                             encoding:NSUTF8StringEncoding];
    return nsJson;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:kPushToVerificationViewControllerSegue]) {
        VerificationViewController *verificationViewControllerObj = [segue destinationViewController];
        verificationViewControllerObj.responseObj = sender; // set your properties here
    }else     if ([segue.identifier isEqualToString:kPermissionScreenControllerID]) {
        
        if ([segue.destinationViewController isKindOfClass:[PermissionScreenViewController class]]) {
            PermissionScreenViewController *Obj = (PermissionScreenViewController *)segue.destinationViewController;
            Obj.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kStoredAccessToken];
            Obj.userFBId = [[NSUserDefaults standardUserDefaults] objectForKey:kStoredfbId];
        }
        else{
            UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
            if ([[navController.childViewControllers firstObject] isKindOfClass:[PermissionScreenViewController class]]) {
                
                PermissionScreenViewController *Obj = (PermissionScreenViewController *)[navController.childViewControllers firstObject];
                Obj.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kStoredAccessToken];
                Obj.userFBId = [[NSUserDefaults standardUserDefaults] objectForKey:kStoredfbId];
                
                
            }
        }
        
        
    }else if ([segue.identifier isEqualToString:kPushToLoginLoadingController]){
        
        LoginLoadingViewController *controller = (LoginLoadingViewController *)segue.destinationViewController;
        if ([controller isKindOfClass:[LoginLoadingViewController class]]) {
            controller.accessToken = [sender objectForKey:@"accessToken"];
            controller.fbId = [sender objectForKey:@"fbId"];
            controller.location = [sender objectForKey:@"location"];
            controller.TruecallerParameters = [sender objectForKey:@"TruecallerParameters"];
            controller.loginVia =  [sender objectForKey:@"loginVia"];
            if (@available(iOS 13, *)) {
            controller.modalPresentationStyle = UIModalPresentationFullScreen;
            }
            controller.delegate = self;
        }
    }
    
}


#pragma mark - LoginLoading Delegate
- (void)gettingResponseFromLoginAPI : (BOOL)success withResponse:(id)response withStatusCode:(int) statusCode withAccessToken:(NSString *)accessToken withLoginLoadingReference:(LoginLoadingViewController *)loginLoading withUserChangedStatus:(BOOL)userChanged{
    if (statusCode == 501 || statusCode == 416) {
        
        [loginLoading dismissViewControllerAnimated:NO completion:^{
            
        }];
        
        LoginErrorFeedbackViewController *errorLogin = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginErrorFeedbackViewController"];
        errorLogin.delegate = self;
        if (statusCode == 416){
            errorLogin.isShownForAgeLimit = YES;
        }
      
        [self presentViewController:errorLogin animated:YES completion:^{
            
        }];
    }
    else if (statusCode == 401){
        
        [loginLoading dismissViewControllerAnimated:NO completion:^{
            [self showReloginPopup];
        }];
    }else{
        
        [loginLoading dismissViewControllerAnimated:NO completion:^{
            
        }];
        
        [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"fbSessionToken"];
          [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self goToNextScreenwithResponse:response withAccessToken:accessToken withUserChangedStatus:userChanged];
    }
}


#pragma mark - Login Error Feedback Delegate
- (void)gettingResponseFromLoginErrorFeebackWithLoginErrorReference:(LoginErrorFeedbackViewController *)errorFeedback{
    
    [errorFeedback dismissViewControllerAnimated:YES completion:^{
        [self displayLoginUI];
        if (!errorFeedback.isShownForAgeLimit){
            [self->facebookBtn setAlpha:0.5];
            [self->facebookBtn setUserInteractionEnabled:NO];
            [self changeViewPosition];
            [self resetTimer:feedbackTimeInterval];
            
            if (self->facebookBtn.alpha == 0.5){
                [self->facebookBtn setHidden:YES];
                self->btnSignInPhonNumberBottom.constant = 20;
                [self->btnWhyFacebook setHidden:YES];
            }
            
        }else{
            [self->facebookBtn setAlpha:1];
            [self->facebookBtn setUserInteractionEnabled:YES];
            [self changeViewPosition];
            [self resetTimer:feedbackTimeInterval];
        }
    }];
}


#pragma mark - Reset Timer
- (void) resetTimer : (int)timer{
    [myTimer invalidate];
    myTimer = nil;
    myTimer =  [NSTimer scheduledTimerWithTimeInterval:timer
                                                target:self
                                              selector:@selector(handleLoginErrorFeedbackResponse)
                                              userInfo:nil
                                               repeats:NO];
}


#pragma mark - Handle Login Error Feedback Response
- (void)handleLoginErrorFeedbackResponse{
    //[self displayLoginUI];
    [facebookBtn setAlpha:1.0];
    [facebookBtn setUserInteractionEnabled:YES];
    
    //    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLoginErrorFeedbackTimeStamp];
}




/*
 Method to send facebookUserId to server and check if user is valid or not
 */
-(void)makeLoginCall:(NSNotification *)notificationObj{
    
    
    
    if (_isFirstViewVisible == YES) {
        [APP_DELEGATE sendSwrveEventWithEvent:@"TapScreen2" andScreen:@"FBLogin"];
    }
    //    [APP_Utilities showActivityIndicator];
    if (isLoginCallMade) {
        return;
    }
    isLoginCallMade = TRUE;
    
    NSDictionary *parmaValues = [notificationObj userInfo];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];      //getting time zone
    
    NSInteger gmtTime = [timeZone secondsFromGMT];  //getting the difference between user time zone and GMT
    
    NSString *language = [APP_Utilities getDeviceLanguageString];   //User default language
    NSString *locale = [APP_Utilities getDeviceLocaleCode];
    
    NSString *udid = [NSString stringWithFormat:@"%@",[[UIDevice currentDevice] identifierForVendor].UUIDString];   //getting user vendor ID, (device UDID is no longer used)
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                            [parmaValues valueForKey:@"userId"],@"userId",
                            [parmaValues valueForKey:@"access_token"],@"access_token",
                            [NSString stringWithFormat:@"%ld",(long)gmtTime],@"gmtTime",
                            language,@"language",
                            locale,@"locale",
                            udid,@"deviceId",
                            [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],@"appVersion",
                            kDeviceType,@"deviceType",
                            nil];
    
    //                            @{@"userId":[parmaValues valueForKey:@"userId"],
    //                             @"access_token":[parmaValues valueForKey:@"access_token"],
    //                             @"gmtTime":[NSString stringWithFormat:@"%ld",(long)gmtTime],
    //                             @"language":language,
    //                             @"locale":locale,
    //                             @"deviceId":udid,
    //                             @"appVersion":[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
    //                             @"deviceType":kDeviceType
    //                             };
    NSString *loginURL = [NSString stringWithFormat:@"%@%@",kLoginURLV4_HTTPS,kLoginCall];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =loginURL;
    wooRequestObj.time =0;
    wooRequestObj.requestParams =params;
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = registerUserToServer;
    NSLog(@"params : %@",params);
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        if (requestType == registerUserToServer) {
            if (statusCode==401 || statusCode==402 || statusCode==500) {
                if ([self.view superview]) {
                    isLoginCallMade = FALSE;
                    [self handleErrorForResponseCode:statusCode];
                }
            }
            NSLog(@"response in make login call:%@",response);
            if (success) {
                
                [APP_DELEGATE.oMyProfileModel updateModel:response];
                
                // UserProfileModel *model = APP_DELEGATE.oMyProfileModel;
                
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kProfileHidingPreference];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kIsUpdateVersion2_1];
                
                if ([response objectForKey:kWooEncryptionTokenFromServer]) {
                    [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:kWooEncryptionTokenFromServer]
                                                              forKey:kWooEncryptionTokenFromServer];
                }
                
                NSUserDefaults *userDefaultObj = [NSUserDefaults standardUserDefaults];
                NSLog(@"[userDefaultObj objectForKey:kWooUserId] :%@",[userDefaultObj objectForKey:kWooUserId]);
                [userDefaultObj setObject:[NSString stringWithFormat:@"%@",[response objectForKey:@"id"]] forKey:kWooUserId];
                //Make my profile call
                if (![[NSString stringWithFormat:@"%@",[response objectForKey:@"id"]] isEqualToString:[userDefaultObj objectForKey:kWooUserId]]) {
                    [APP_DELEGATE reinitialiseUserDefaultAndDatabase];
                }
                
                if ([response objectForKey:kMaxDistance]) {
                    [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:kMaxDistance] forKey:kMaxDistance];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                if ([response objectForKey:kWooToken]) {
                    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",[response objectForKey:kWooToken]] forKey:kWooToken];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                }
                
                if (!([[APP_Utilities validString:[NSString stringWithFormat:@"%@",[response objectForKey:@"id"]]] length]>0) ||
                    [NSString stringWithFormat:@"%@",[response objectForKey:@"id"]] == NULL) {
                    isLoginCallMade = FALSE;
                    [self displayLoginUI];
                    return ;
                }
                
                //                NSString *currentSwrveUserId = [[NSUserDefaults standardUserDefaults] objectForKey:kSwrveUserId];
                //                if (![currentSwrveUserId isEqualToString:[Swrve sharedInstance].userID]) {
                //                    [APP_DELEGATE sendSwrveUserIDToServer:[Swrve sharedInstance].userID];
                //                }
                
                [userDefaultObj setObject:[APP_Utilities validString:[NSString stringWithFormat:@"%@",[response objectForKey:@"firstName"]]] forKey:kWooUserName];
                [userDefaultObj setObject:[APP_Utilities validString:[NSString stringWithFormat:@"%@",[parmaValues valueForKey:@"userId"]]] forKey:kFacebookNumbericUserID];
                [userDefaultObj setObject:[APP_Utilities validString:[NSString stringWithFormat:@"%@",[response objectForKey:@"profilePicUrl"]]] forKey:kWooProfilePicURL];
                [userDefaultObj setObject:[response objectForKey:kProfileCompletenessScoreKey] forKey:kProfileCompletenessScoreKey];
                
                [userDefaultObj setObject:[response objectForKey:@"age"] forKey:kAgeFromServer];
                [userDefaultObj setObject:[response objectForKey:kMinAgePreference] forKey:kMinAgePreference];
                [userDefaultObj setObject:[response objectForKey:kMaxAgePreference] forKey:kMaxAgePreference];
                [userDefaultObj setObject:[response objectForKey:kGenderPreference] forKey:kGenderPreference];
                [userDefaultObj setObject:[response objectForKey:kGenderKey] forKey:kWooUserGender];
                
                //Added by Umesh : to save sound preference : on 19 Sept, 2104
                //$$$LUV***
                //Uncomment below two user default when
                
                [userDefaultObj setBool:([[response objectForKey:@"chatSoundOn"] boolValue]?TRUE:FALSE) forKey:kMessagesSoundPreference];
                [userDefaultObj setBool:([[response objectForKey:@"otherSoundOn"] boolValue]?TRUE:FALSE) forKey:kMatchesSoundPreferences];
                
                //End here
                
                [userDefaultObj synchronize];
                
                [APP_DELEGATE sendFCMPushTokenToServer];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInSuccessfullyNotification object:nil];
                [APP_DELEGATE sendSwrveEventWithEvent:@"FBLogin.Success" andScreen:@"FBLogin"];
                [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"Success" forScreenName:@"Login"];
                NSString *url = [[NSUserDefaults standardUserDefaults]objectForKey:kWooProfilePicURL];
                //NSString *imageURL = nil;
                
                if([[APP_Utilities validString:url] length]>0){
                    // imageURL = [NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(100),IMAGE_SIZE_FOR_POINTS(100), [APP_Utilities encodeFromPercentEscapeString:url]];
                }
                
                BOOL alreadyRegistered = [[response objectForKey:@"confirmed"] boolValue];
                
                [[NSUserDefaults standardUserDefaults] setBool:alreadyRegistered forKey:kUserAlreadyRegistered];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                if(alreadyRegistered){
                    [self pushToPostDiscoverViewController];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kPrefetchImagesForFBAlbum object:nil];
                    });
                }else{
                    
                    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"isOnboardingMyProfileShown"];
                    [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"tutorialNotShown"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    if ([response objectForKey:kIsFakeDtoInLoginKey]) {
                        [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:kIsFakeDtoInLoginKey] forKey:kIsFakeDtoInLoginKey];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                    [self pushToPostLoginViewController:response];
                }
            }
            else{
                //Error handling
            }
        }
        
    }  shouldReachServerThroughQueue:TRUE];
}
/*
 This will show permission on a screen when user taps on the permission button
 
 */
-(void)displayPermissionUI{
    PermissionView *permissionViewObj = [[PermissionView alloc] initWithFrame:self.view.bounds];
    permissionViewObj.alpha = 0;
    [permissionViewObj fadeInView];
    [self.view addSubview:permissionViewObj];
}
/*
 This method will send device ID to server.
 not in use right now
 */
-(void)makeDeviceDataCall{
    
}
- (IBAction)permissionButtonclicked:(id)sender {
    [APP_DELEGATE sendSwrveEventWithEvent:@"TapWhyFB" andScreen:@"FBLogin"];
    _isFirstViewVisible = YES;
}

//Method to get new read and publish permission, not in user only for testing purpose

//- (IBAction)getNewReadPermissionButtonclicked:(id)sender{
//    [loginViewObj getReadPermissions:@[@"read_friendlists",@"user_location",@"user_likes",@"user_interests"]];
//}
//
//- (IBAction)getPublishPermissionButtonclicked:(id)sender{
//    [loginViewObj getPublishPermissions:@[@"publish_actions"]];
//}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

-(void)removeTutorialAndFbView{
    return;
    if (loginViewObj && [loginViewObj superview]) {
        [loginViewObj removeAllObserver];
        loginViewObj = nil;
    }
}

- (IBAction)infoButtonTapped:(id)sender {
    //    [bottomContainerView addSubview:[UIView ]];
    
    [APP_DELEGATE sendSwrveEventWithEvent:@"3-Onboarding.Start1.WhyFBTapped" andScreen:@"Start1"];
    
    // WooScreenManager.sharedInstance.oHomeViewController?.presentViewController(DeepLinkingOptions.MyWebViewTC)
    //    let storyboard = UIStoryboard(name: "Woo_3", bundle: nil)
    
    //    myWebViewViewController?.navTitle = NSLocalizedString("FAQs", comment: "FAQ web view title")
    //    myWebViewViewController?.webViewUrl = AppLaunchModel.sharedInstance().faqUrl
    //    let navController = UINavigationController(rootViewController: myWebViewViewController!)
    //    self.present(navController, animated: true, completion: nil)
    UIStoryboard *wooStoryBoard = [UIStoryboard storyboardWithName:@"Home" bundle:nil];
    WkWebViewController *myWebViewViewController = [wooStoryBoard instantiateViewControllerWithIdentifier:@"wkWebViewStoryBoardID"];
    myWebViewViewController.navTitle = NSLocalizedString(@"Privacy Policy", @"");
    NSURL *termsUrl = [NSURL URLWithString:@"http://www.getwooapp.com/privacy-policy.html"];
    if ([[AppLaunchModel sharedInstance] TermsUrl].absoluteString.length > 0) {
        termsUrl = [[AppLaunchModel sharedInstance] TermsUrl];
    }
    myWebViewViewController.webViewUrl = termsUrl;
    // UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:myWebViewViewController];
    [self presentViewController:myWebViewViewController animated:true completion:nil];
    return;
    
    if (!loginInfoView) {
        loginInfoView = [[[NSBundle mainBundle] loadNibNamed:@"LoginScreenInfoView" owner:nil options:nil] objectAtIndex:0];
    }
    //    loginInfoView.alpha = 1.0f;
    if (![loginInfoView superview]) {
        heightContraintOfBottomView.constant = 240;
        [loginInfoView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
        [loginInfoView presentViewOnView:bottomContainerView];
    }
    
    [loginInfoView viewDismissed:^(BOOL isViewDismissed , BOOL isPrivacyOpened , BOOL isTermsOpened) {
        
        if (isViewDismissed)
            heightContraintOfBottomView.constant = 70;
        else if (isPrivacyOpened){ // Privacy Clicked
            
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Home" bundle:nil];
            
            WkWebViewController *controller = [storyBoard instantiateViewControllerWithIdentifier:@"wkWebViewStoryBoardID"];
            controller.navTitle = @"Privacy Policy";
            controller.webViewUrl = [NSURL URLWithString:@"http://www.getwooapp.com/privacy-policy.html"];
            [self presentViewController:controller animated:YES completion:nil];
            
        }else if (isTermsOpened){ // Terms Clicked
            
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Home" bundle:nil];
            
            WkWebViewController *controller = [storyBoard instantiateViewControllerWithIdentifier:@"wkWebViewStoryBoardID"];
            controller.navTitle = NSLocalizedString(@"Terms Of Use", @"Terms Of Use") ;
            controller.webViewUrl = [NSURL URLWithString:@"http://www.getwooapp.com/privacy-policy.html"];
            [self presentViewController:controller animated:YES completion:nil];
            
        }
    }];
    //    PopularUserView *popularUserViewObj = nil;
    //    popularUserViewObj = [[[NSBundle mainBundle] loadNibNamed:@"PopularUserView" owner:nil options:nil] objectAtIndex:0];
    //    popularUserViewObj.frame = self.view.bounds;
    
}

-(void)removeAllObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUserLoggedInSuccessfully object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPushToVerificationScreen object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShowIndicatorViewOnLoginScreen object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHideIndicatorViewOnLoginScreen object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationForCancelledFromFacebook object:nil];
}

-(void)showAuthenticationAlert{
    loginViewObj.hidden = TRUE;
    [loginViewObj setIsPresentedForFBSync:TRUE];
    [loginViewObj facebookPermissionALertTapped];
    
}

- (IBAction)neverPostDescriptionButton:(id)sender {
    
    [self displayPermissionUI];
}


-(void)dealloc{
    [self removeAllObserver];
}

#pragma mark - keyframe animation methods



- (NSUInteger)numberOfPages
{
    // Tell the scroll view how many pages it should have
    return 5;
}

- (UIImage *)grabImageFromViewToGrab:(UIView *)viewToGrab {
    // Create a "canvas" (image context) to draw in.
    UIGraphicsBeginImageContextWithOptions(viewToGrab.bounds.size, NO, 0.0);  // high res
    
    // Make the CALayer to draw in our "canvas".
    [[viewToGrab layer] renderInContext: UIGraphicsGetCurrentContext()];
    
    // Fetch an UIImage of our "canvas".
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    // Stop the "canvas" from accepting any input.
    UIGraphicsEndImageContext();
    
    // Return the image.
    return image;
}

-(UILabel *)createIntroLabelWithText:(NSString *)textToDisplay{
    
    UILabel *textLabel = [[UILabel alloc]init];
    [textLabel setText:textToDisplay];
    [textLabel setBackgroundColor:[UIColor clearColor]];
    [textLabel setTextColor:[UIColor whiteColor]];
    [textLabel setFont:kBotTextFont];
    [textLabel setTextAlignment:NSTextAlignmentCenter];
    [textLabel sizeToFit];
    
    return textLabel;
}


-(UILabel *)createTagForIntroTutorialWithText:(NSString *)tagText{
    
    UILabel *tagLabel = [[UILabel alloc] init];
    [tagLabel setText:tagText];
    [tagLabel setBackgroundColor:kHeaderTextRedColor];
    [tagLabel setTextColor:[UIColor whiteColor]];
    [tagLabel setFont:[UIFont systemFontOfSize:12]];
    [tagLabel.layer setCornerRadius:2.0f];
    tagLabel.layer.masksToBounds= YES;
    tagLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    tagLabel.layer.borderWidth=0.5f;
    [tagLabel setTextAlignment:NSTextAlignmentCenter];
    [tagLabel sizeToFit];
    return tagLabel;
}



-(void)configureViews{
    
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    
    //first view
    firstImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"firstImage"]];
    secondImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"secondImage"]];
    thirdImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"thirdImage"]];
    //    fourthImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fourthImage"]];
    fifthImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fifthImage"]];
    sixthImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sixthImage"]];
    
    
    [self.contentView addSubview:firstImage];
    [self.contentView addSubview:secondImage];
    [self.contentView addSubview:thirdImage];
    //    [self.contentView addSubview:fourthImage];
    [self.contentView addSubview:fifthImage];
    [self.contentView addSubview:sixthImage];
    
    //    logoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:LOCALISED_IMAGE_NAME(@"IntroWooLogoV3")]];
    //    [self.contentView addSubview:logoImage];
    //    [logoImage setAlpha:1.0f];
    //    lastPanelWooLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:LOCALISED_IMAGE_NAME(@"IntroWooLogoV3")]];
    //
    //    discoverText =[self createIntroLabelWithText:NSLocalizedString(@"Let's Talk!", @"first screen text")];
    //    [self.contentView addSubview:discoverText];
    //    [discoverText setAlpha:1.0f];
    //    [discoverText setFont:[UIFont fontWithName:@"ThrowMyHandsUpintheAir" size:25.0f]];
    //
    //    lastPanelText =[self createIntroLabelWithText:NSLocalizedString(@"Let's Talk!", @"last screen text")];
    //    [lastPanelText setFont:[UIFont fontWithName:@"ThrowMyHandsUpintheAir" size:25.0f]];
    
    
    
    //second view
    
    //    UIView *cyanExpandingCircle = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 400, 400)];
    //    [cyanExpandingCircle setBackgroundColor:kIntroCyanColor];
    //    cyanExpandingCircle.layer.cornerRadius = 200.0f;
    //    cyanExpandingCircle.clipsToBounds = YES;
    //
    //
    //    whiteView = [[UIView alloc]init];
    //    [whiteView setBackgroundColor:[UIColor whiteColor]];
    //    [self.contentView addSubview:whiteView];
    //
    //
    //    cyanCircle = [[UIImageView alloc]initWithImage:[self grabImageFromViewToGrab:cyanExpandingCircle]];
    //    [self.contentView addSubview:cyanCircle];
    //
    //
    //    introTagsView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 160)];
    //    [introTagsView setBackgroundColor:[UIColor clearColor]];
    //    [self.contentView addSubview:introTagsView];
    //    [introTagsView setAlpha:0.0f];
    //
    //    firstTag = [self createTagForIntroTutorialWithText:NSLocalizedString(@"#Lovemusic", @"text for last tag")];
    //
    //    secondTag = [self createTagForIntroTutorialWithText:NSLocalizedString(@"#Interfaces", @"text for second tag of second line")];
    //
    //    thirdTag = [self createTagForIntroTutorialWithText:NSLocalizedString(@"#Designer", @"text for first tag of second line")];
    //
    //    fourthTag = [self createTagForIntroTutorialWithText:NSLocalizedString(@"#hiphop", @"text for third tag of second line")];
    //
    //    fifthTag = [self createTagForIntroTutorialWithText:NSLocalizedString(@"#coffeeovertea", @"text for first line second tag")];
    //    sixthTag = [self createTagForIntroTutorialWithText:NSLocalizedString(@"#instagrammer", @"text for first tag of first line")];
    //
    //    [introTagsView addSubview:firstTag];
    //    [introTagsView addSubview:secondTag];
    //    [introTagsView addSubview:thirdTag];
    //    [introTagsView addSubview:fourthTag];
    //    [introTagsView addSubview:fifthTag];
    //    [introTagsView addSubview:sixthTag];
    //
    //    thirdScreenFirstText = [self createIntroLabelWithText:NSLocalizedString(@"Use tags to discover\ncommon interests, passion, and traits", @"first text on third screen")];
    //
    //
    //
    //
    //    [thirdScreenFirstText setNumberOfLines:2];
    //    [thirdScreenFirstText setAlpha:1];
    //    [self.contentView addSubview:thirdScreenFirstText];
    //
    //    thirdScreenSecondText = [self createIntroLabelWithText:NSLocalizedString(@"Tags to help you\nfind better", @"second line on third screen")];
    //    [thirdScreenSecondText setNumberOfLines:2];
    //    [thirdScreenSecondText setAlpha:1];
    //    [self.contentView addSubview:thirdScreenSecondText];
    //
    //
    //    //third view
    //    animatableCyanArea = [[UIView alloc] init];
    //    [animatableCyanArea setBackgroundColor:kIntroCyanColor];
    //    [animatableCyanArea setAlpha:1.0f];
    //    [self.contentView addSubview:animatableCyanArea];
    //
    //
    //
    //    cyanAreaForText = [[UIView alloc]init];
    //    [cyanAreaForText setBackgroundColor:kIntroCyanColor];
    //    [self.contentView addSubview:cyanAreaForText];
    //
    //
    //    cyanAreaCrushText = [[UILabel alloc] init];
    //    [cyanAreaCrushText setBackgroundColor:[UIColor clearColor]];
    //    [cyanAreaCrushText setFont:[UIFont systemFontOfSize:14]];
    //    [cyanAreaCrushText setText:NSLocalizedString(@"I really liked your profile. Check mine.\n It will be great to connect with you.", @"this is the message for crush text on 4th screen")];
    //    [cyanAreaCrushText setNumberOfLines:2];
    //    [cyanAreaCrushText setTextAlignment:NSTextAlignmentCenter];
    //    [cyanAreaCrushText setTextColor:[UIColor whiteColor]];
    //    [cyanAreaCrushText sizeToFit];
    //
    //
    //
    //    cyanAreaCrushHeading = [[UILabel alloc] init];
    //    [cyanAreaCrushHeading setBackgroundColor:[UIColor clearColor]];
    //    [cyanAreaCrushHeading setFont:[UIFont systemFontOfSize:14]];
    //    [cyanAreaCrushHeading setText:NSLocalizedString(@"Sam sent you a Crush", @"this is the message for crush header on 4th screen")];
    //    [cyanAreaCrushHeading setNumberOfLines:2];
    //    [cyanAreaCrushHeading setTextAlignment:NSTextAlignmentCenter];
    //    [cyanAreaCrushHeading setTextColor:[UIColor whiteColor]];
    //    [cyanAreaCrushHeading sizeToFit];
    //
    //
    //    fourthScreenFirstText = [self createIntroLabelWithText:NSLocalizedString(@"Let that special ONE know", @"first text on fourth screen")];
    //    [fourthScreenFirstText setNumberOfLines:1];
    //    [fourthScreenFirstText setTextColor:[UIColor blackColor]];
    //    [self.contentView addSubview:fourthScreenFirstText];
    //
    //    fourthScreenSecondText = [self createIntroLabelWithText:NSLocalizedString(@"Send a Crush\nand steal their heart", @"second text on fourth screen")];
    //    [fourthScreenSecondText setNumberOfLines:2];
    //    [fourthScreenSecondText setTextColor:[UIColor blackColor]];
    //    [self.contentView addSubview:fourthScreenSecondText];
    //
    //
    //    [cyanAreaForText addSubview:cyanAreaCrushText];
    //    [cyanAreaForText addSubview:cyanAreaCrushHeading];
    //
    //    smallHeart = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"introCrushIcon"]];
    //    [self.contentView addSubview:smallHeart];
    //
    //
    //    //fourth view
    //    UIView *purpleExpandingCircle = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 400, 400)];
    //    [purpleExpandingCircle setBackgroundColor:kIntroPurpleColor];
    //    purpleExpandingCircle.layer.cornerRadius = 200.0f;
    //    purpleExpandingCircle.clipsToBounds = YES;
    //
    //    purpleCircle = [[UIImageView alloc]initWithImage:[self grabImageFromViewToGrab:purpleExpandingCircle]];
    //    [self.contentView addSubview:purpleCircle];
    //
    //    secondScreenFirstText = [self createIntroLabelWithText:NSLocalizedString(@"Ask a question and\nget to know them better", @"first text on second screen")];
    //    [secondScreenFirstText setNumberOfLines:2];
    //    [secondScreenFirstText setAlpha:1];
    //    [self.contentView addSubview:secondScreenFirstText];
    //
    //
    //    secondScreenSecondText  = [self createIntroLabelWithText:NSLocalizedString(@"Answer with confidence\nand privately", @"second screen text under answer area")];
    //    [secondScreenSecondText setNumberOfLines:2];
    //    [self.contentView addSubview:secondScreenSecondText];
    //
    //    questionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 220, 80)];
    //    [questionView setBackgroundColor:[UIColor whiteColor]];
    //    [questionView.layer setCornerRadius:2.0f];
    //
    //
    //    UILabel *questionText = [[UILabel alloc]init];
    //    [questionText setText:NSLocalizedString(@"What is the craziest thing you have ever done?", @"text to be displayed for question")];
    //    [questionText setBackgroundColor:[UIColor clearColor]];
    //    [questionText setTextColor:[UIColor grayColor]];
    //    [questionText setFont:[UIFont systemFontOfSize:14]];
    //    [questionText setTextAlignment:NSTextAlignmentLeft];
    //    [questionText setNumberOfLines:2];
    //    [questionText sizeToFit];
    //
    //    [questionView addSubview:questionText];
    //    [questionText mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.left.mas_equalTo(15);
    //        make.top.mas_equalTo(15);
    //        make.width.equalTo(questionView.mas_width).with.offset(-30);
    //
    //    }];
    //
    //    UILabel *answerButtonLabel= [[UILabel alloc]init];
    //    [answerButtonLabel setText:NSLocalizedString(@"Answer", @"Answer button to be displayed on the bottom right of question of tutorial")];
    //    [answerButtonLabel setBackgroundColor:[UIColor clearColor]];
    //    [answerButtonLabel setTextColor:kHeaderTextRedColor];
    //    [answerButtonLabel setFont:[UIFont systemFontOfSize:14]];
    //    [answerButtonLabel setTextAlignment:NSTextAlignmentLeft];
    //    [answerButtonLabel sizeToFit];
    //
    //    [questionView addSubview:answerButtonLabel];
    //    [answerButtonLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.bottom.mas_equalTo(-15);
    //        make.right.mas_equalTo(-15);
    //    }];
    //
    //    [self.contentView addSubview:questionView];
    //
    //    //fifth view
    //    lastImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"introLastImage"]];
    //    [self.contentView addSubview:lastImage];
    //    [self.contentView addSubview:lastPanelText];
    //    [self.contentView addSubview:lastPanelWooLogo];
    //
    [self configurePositionsForViews];
    //
}




-(void)configurePositionsForViews{
    
    [firstImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(SCREEN_HEIGHT);
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    [secondImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(SCREEN_HEIGHT);
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    [thirdImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(SCREEN_HEIGHT);
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    //    [fourthImage mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.width.mas_equalTo(SCREEN_WIDTH);
    //        make.height.mas_equalTo(SCREEN_HEIGHT);
    //        make.centerX.equalTo(self.contentView.mas_centerX);
    //        make.centerY.equalTo(self.contentView.mas_centerY);
    //    }];
    
    [fifthImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(SCREEN_HEIGHT);
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    [sixthImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(SCREEN_HEIGHT);
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    //
    //
    //
    //    [logoImage mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.centerX.equalTo(self.contentView.mas_centerX);
    //        make.centerY.equalTo(self.contentView.mas_centerY).with.offset(-(SCREEN_WIDTH*0.1796875));
    //        make.width.mas_equalTo(SCREEN_WIDTH*0.1875);
    //        make.height.mas_equalTo(SCREEN_WIDTH*0.1875);
    //    }];
    //
    //
    //    [discoverText mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.centerX.equalTo(self.contentView.mas_centerX);
    //        make.centerY.equalTo(self.contentView.mas_centerY).with.offset(SCREEN_WIDTH*0.0625);
    //    }];
    //
    //    [lastPanelWooLogo mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.centerX.equalTo(self.contentView.mas_centerX);
    //        make.centerY.equalTo(self.contentView.mas_centerY).with.offset(-(SCREEN_WIDTH*0.1796875));
    //        make.width.mas_equalTo(SCREEN_WIDTH*0.1875);
    //        make.height.mas_equalTo(SCREEN_WIDTH*0.1875);
    //    }];
    //
    //
    //    [lastPanelText mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.centerX.equalTo(self.contentView.mas_centerX);
    //        make.centerY.equalTo(self.contentView.mas_centerY).with.offset(SCREEN_WIDTH*0.0625);
    //    }];
    //
    //
    //    [purpleCircle mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.equalTo(self.contentView.mas_bottom);
    //    }];
    //
    //
    //    [questionView mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.centerX.equalTo(self.contentView.mas_centerX);
    //        make.centerY.equalTo(self.contentView.mas_centerY).with.offset(-SCREEN_WIDTH*0.1875);
    //        make.width.mas_equalTo(SCREEN_WIDTH*0.6875);
    //        make.height.mas_equalTo(SCREEN_WIDTH*0.25);
    //    }];
    //
    //
    //    [secondScreenSecondText mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.centerX.equalTo(self.contentView.mas_centerX);
    //        make.top.equalTo(questionView.mas_bottom).with.offset(SCREEN_WIDTH*0.0625);
    //    }];
    //
    //    [secondScreenFirstText mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.centerX.equalTo(self.contentView.mas_centerX);
    //        make.bottom.equalTo(questionView.mas_top).with.offset(-SCREEN_WIDTH*0.0625);
    //    }];
    //
    //
    //    [whiteView mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.width.equalTo(self.contentView.mas_width);
    //        make.height.equalTo(self.contentView.mas_height);
    //        make.centerX.equalTo(self.contentView.mas_centerX);
    //        make.centerY.equalTo(self.contentView.mas_centerY);
    //    }];
    //
    //
    //    [cyanCircle mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.equalTo(self.contentView.mas_bottom);
    //    }];
    //
    //    [introTagsView mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.centerX.equalTo(self.contentView.mas_centerX);
    //        make.centerY.equalTo(self.contentView.mas_centerY).with.offset(-SCREEN_WIDTH*0.1875);
    //        make.width.mas_equalTo(SCREEN_WIDTH);
    //        make.height.mas_equalTo(160);
    //    }];
    //
    //    [thirdScreenFirstText mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.centerX.equalTo(self.contentView.mas_centerX);
    //        make.bottom.equalTo(introTagsView.mas_top);
    //    }];
    //
    //
    //    [thirdScreenSecondText mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.centerX.equalTo(self.contentView.mas_centerX);
    //        make.top.equalTo(introTagsView.mas_bottom).with.offset(SCREEN_WIDTH*0.0625);
    //    }];
    //
    //    [firstTag mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.centerX.equalTo(introTagsView.mas_centerX);
    //        make.bottom.equalTo(introTagsView.mas_bottom);
    //        make.width.mas_equalTo(firstTag.frame.size.width+20);
    //        make.height.mas_equalTo(firstTag.frame.size.height+20);
    //    }];
    //
    //    [secondTag mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.bottom.equalTo(firstTag.mas_top).with.offset(-10);
    //        make.width.mas_equalTo(secondTag.frame.size.width+20);
    //        make.height.mas_equalTo(secondTag.frame.size.height+20);
    //        make.centerX.equalTo(introTagsView.mas_centerX);
    //    }];
    //
    //    [thirdTag mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.bottom.equalTo(firstTag.mas_top).with.offset(-10);
    //        make.width.mas_equalTo(thirdTag.frame.size.width+20);
    //        make.height.mas_equalTo(thirdTag.frame.size.height+20);
    //        make.right.equalTo(secondTag.mas_left).with.offset(-10);
    //    }];
    //
    //
    //    [fourthTag mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.bottom.equalTo(firstTag.mas_top).with.offset(-10);
    //        make.width.mas_equalTo(fourthTag.frame.size.width+20);
    //        make.height.mas_equalTo(fourthTag.frame.size.height+20);
    //        make.left.equalTo(secondTag.mas_right).with.offset(10);
    //
    //    }];
    //
    //    [fifthTag mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.width.mas_equalTo(fifthTag.frame.size.width+20);
    //        make.height.mas_equalTo(fifthTag.frame.size.height+20);
    //        make.bottom.equalTo(secondTag.mas_top).with.offset(-10);
    //        make.centerX.equalTo(introTagsView.mas_centerX).with.offset(50);
    //    }];
    //
    //    [sixthTag mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.width.mas_equalTo(sixthTag.frame.size.width+20);
    //        make.height.mas_equalTo(sixthTag.frame.size.height+20);
    //        make.bottom.equalTo(secondTag.mas_top).with.offset(-10);
    //        make.right.equalTo(fifthTag.mas_left).with.offset(-10);
    //    }];
    //
    //
    //    [animatableCyanArea mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.centerX.equalTo(self.contentView.mas_centerX);
    //        make.centerY.equalTo(self.contentView.mas_centerY).with.offset(-50);
    //        make.width.mas_equalTo(SCREEN_HEIGHT);
    //        make.height.mas_equalTo(SCREEN_HEIGHT);
    //    }];
    //
    //
    //
    //    [cyanAreaForText mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.centerX.equalTo(animatableCyanArea.mas_centerX);
    //        make.centerY.equalTo(animatableCyanArea.mas_centerY);
    //        make.width.mas_equalTo(SCREEN_WIDTH*0.859375);
    //        make.height.mas_equalTo(SCREEN_WIDTH*0.375);
    //
    //    }];
    //
    //    [fourthScreenFirstText mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.centerX.equalTo(self.contentView.mas_centerX);
    //        make.bottom.equalTo(cyanAreaForText.mas_top).with.offset(-SCREEN_WIDTH*0.0625);
    //    }];
    //
    //    [fourthScreenSecondText mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.centerX.equalTo(self.contentView.mas_centerX);
    //        make.top.equalTo(cyanAreaForText.mas_bottom).with.offset(SCREEN_WIDTH*0.0625);
    //    }];
    //
    //
    //    [cyanAreaCrushText mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.centerX.equalTo(cyanAreaForText.mas_centerX);
    //        make.centerY.equalTo(cyanAreaForText.mas_centerY);
    //    }];
    //
    //    [cyanAreaCrushHeading mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.centerX.equalTo(cyanAreaForText.mas_centerX);
    //        make.bottom.equalTo(cyanAreaCrushText.mas_top).with.offset(-15);
    //    }];
    //
    //    [smallHeart mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.centerY.equalTo(animatableCyanArea.mas_centerY);
    //        make.centerX.equalTo(animatableCyanArea.mas_centerX);
    //    }];
    //
    //    [lastImage mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.width.mas_equalTo(SCREEN_WIDTH);
    //        make.height.mas_equalTo(SCREEN_HEIGHT);
    //        make.centerX.equalTo(self.contentView.mas_centerX);
    //        make.centerY.equalTo(self.contentView.mas_centerY);
    //    }];
    //
    [self configurePagesForViews];
}

-(void)configurePagesForViews{
    
    [self keepView:firstImage onPages:@[@(-1), @(0)] atTimes:@[@(-1), @(0)]];
    [self keepView:secondImage onPages:@[@(1)] atTimes:@[@(1)]];
    [self keepView:thirdImage onPages:@[@(2)] atTimes:@[@(2)]];
    [self keepView:fifthImage onPages:@[@(3)] atTimes:@[@(3)]];
    [self keepView:sixthImage onPages:@[@(4), @(5)] atTimes:@[@(4), @(5)]];
    //    [self keepView:sixthImage onPages:@[@(5), @(6)] atTimes:@[@(5), @(6)]];
    
    
    //    //first view
    //    [self keepView:logoImage onPages:@[@(-1), @(0), @(1)] atTimes:@[@(-1), @(0), @(1)]];
    //    [self keepView:discoverText onPages:@[@(-1), @(0), @(1)] atTimes:@[@(-1), @(0), @(1)]];
    //
    //
    //    //second view
    //    [self keepView:cyanCircle onPages:@[@(0), @(1)] atTimes:@[@(0), @(1)] withAttribute:IFTTTHorizontalPositionAttributeRight offset:400];
    //    [self animateCyanCircle];
    //
    //
    //
    //    [self keepView:introTagsView onPages:@[@(0), @(1), @(2)] atTimes:@[@(0), @(1), @(2)]];
    //    [self animateTagsView];
    //    [self keepView:thirdScreenFirstText onPages:@[@(0), @(1), @(2)] atTimes:@[@(0), @(1), @(2)]];
    //    [self keepView:thirdScreenSecondText onPages:@[@(0), @(1), @(2)] atTimes:@[@(0), @(1), @(2)]];
    //    [self animateThirdSCreenTexts];
    //
    //
    //    //third view
    //    [self keepView:animatableCyanArea onPages:@[@(1), @(2), @(3), @(4)] atTimes:@[@(1), @(2), @(3), @(4)]];
    //    [self animateAnimatableCyanArea];
    //
    //
    //    [self keepView:fourthScreenFirstText onPages:@[@(1), @(2), @(3), @(4)] atTimes:@[@(1), @(2), @(3), @(4)]];
    //    [self keepView:fourthScreenSecondText onPages:@[@(1), @(2), @(3), @(4)] atTimes:@[@(1), @(2), @(3), @(4)]];
    //    [self keepView:smallHeart onPages:@[@(1), @(2), @(3), @(4)] atTimes:@[@(1), @(2), @(3), @(4)]];
    //
    //    // change of fourth
    //    [self keepView:cyanAreaForText onPages:@[@(2), @(3), @(4), @(5)] atTimes:@[@(2), @(3), @(4), @(5)]];
    //    [self keepView:cyanAreaCrushText onPages:@[@(2), @(3), @(4), @(5)] atTimes:@[@(2), @(3), @(4), @(5)]];
    //    [self keepView:cyanAreaCrushHeading onPages:@[@(2), @(3), @(4), @(5)] atTimes:@[@(2), @(3), @(4), @(5)]];
    //    [self animateElementsOnFourthScreen];
    //
    //    //fourth view
    //    [self keepView:purpleCircle onPages:@[@(4), @(5)] atTimes:@[@(4), @(5)] withAttribute:IFTTTHorizontalPositionAttributeRight offset:400];
    //
    //    [self animatePurpleCircle];
    //
    //
    //    [self keepView:questionView onPages:@[@(3), @(4), @(5)] atTimes:@[@(3), @(4), @(5)]];
    //    [self keepView:secondScreenSecondText onPages:@[@(3), @(4), @(5)] atTimes:@[@(3), @(4), @(5)]];
    //    [self keepView:secondScreenFirstText onPages:@[@(3), @(4), @(5)] atTimes:@[@(3), @(4), @(5)]];
    //    [self animateSecondScreenElements];
    //
    //
    //    //animations for first view
    //
    //
    //    [self keepView:whiteView onPages:@[@(3), @(4), @(5)] atTimes:@[@(3), @(4), @(5)]];
    //
    //
    //
    //
    //
    //    [self keepView:lastImage onPages:@[@(4), @(5), @(6)] atTimes:@[@(4), @(5), @(6)]];
    //    [self keepView:lastPanelWooLogo onPages:@[@(4), @(5), @(6)] atTimes:@[@(4), @(5), @(6)]];
    //    [self keepView:lastPanelText onPages:@[@(4), @(5), @(6)] atTimes:@[@(4), @(5), @(6)]];
    //
    //    [self animateImagesOnLastPanel];
    //
}


//-(void)animateImagesOnLastPanel{
//    IFTTTAlphaAnimation *lastImageAlpha = [IFTTTAlphaAnimation animationWithView:lastImage];
//    [lastImageAlpha addKeyframeForTime:4.0f alpha:0.0f];
//    [lastImageAlpha addKeyframeForTime:4.4f alpha:1.0f];
//    [self.animator addAnimation:lastImageAlpha];
//
//    IFTTTAlphaAnimation *lastPanelLogoAnimation = [IFTTTAlphaAnimation animationWithView:lastPanelWooLogo];
//    [lastPanelLogoAnimation addKeyframeForTime:4.4f alpha:0.0f];
//    [lastPanelLogoAnimation addKeyframeForTime:4.8f alpha:1.0f];
//    [self.animator addAnimation:lastPanelLogoAnimation];
//
//    IFTTTAlphaAnimation *lastPanelTextAnimation = [IFTTTAlphaAnimation animationWithView:lastPanelText];
//    [lastPanelTextAnimation addKeyframeForTime:4.4f alpha:0.0f];
//    [lastPanelTextAnimation addKeyframeForTime:4.8f alpha:1.0f];
//    [self.animator addAnimation:lastPanelTextAnimation];
//
//
//}


//-(void)animateElementsOnFourthScreen{
//
//    IFTTTAlphaAnimation *fourthScreenfirstTextAlpha = [IFTTTAlphaAnimation animationWithView:fourthScreenFirstText];
//    [fourthScreenfirstTextAlpha addKeyframeForTime:1.50f alpha:0.0f];
//    [fourthScreenfirstTextAlpha addKeyframeForTime:1.80f alpha:1.0f];
//    [self.animator addAnimation:fourthScreenfirstTextAlpha];
//
//    IFTTTAlphaAnimation *fourthScreenSecondTextAlpha = [IFTTTAlphaAnimation animationWithView:fourthScreenSecondText];
//    [fourthScreenSecondTextAlpha addKeyframeForTime:1.50f alpha:0.0f];
//    [fourthScreenSecondTextAlpha addKeyframeForTime:1.80f alpha:1.0f];
//    [self.animator addAnimation:fourthScreenSecondTextAlpha];
//
//    IFTTTAlphaAnimation *heartAlphaAnimations = [IFTTTAlphaAnimation animationWithView:smallHeart];
//    [heartAlphaAnimations addKeyframeForTime:1.50f alpha:0.0f];
//    [heartAlphaAnimations addKeyframeForTime:2.0f alpha:1.0f];
//    [self.animator addAnimation:heartAlphaAnimations];
//
//    IFTTTScaleAnimation *heartScaleAnimation = [IFTTTScaleAnimation animationWithView:smallHeart];
//    [heartScaleAnimation addKeyframeForTime:1.50f scale:0.01f];
//    [heartScaleAnimation addKeyframeForTime:2.0f scale:1.3f];
//    [self.animator addAnimation:heartScaleAnimation];
//
//    IFTTTScaleAnimation *cyanTextAreaScaleAnimation = [IFTTTScaleAnimation animationWithView:cyanAreaForText];
//    [cyanTextAreaScaleAnimation addKeyframeForTime:2.0f scale:0.001f];
//    [cyanTextAreaScaleAnimation addKeyframeForTime:2.30f scale:1.0f];
//    [self.animator addAnimation:cyanTextAreaScaleAnimation];
//
//    IFTTTTranslationAnimation *heartTranslateAnimation = [IFTTTTranslationAnimation animationWithView:smallHeart];
//    [heartTranslateAnimation addKeyframeForTime:2.80f translation:CGPointMake(smallHeart.frame.origin.x, smallHeart.frame.origin.y)];
//    [heartTranslateAnimation addKeyframeForTime:2.90f translation:CGPointMake(smallHeart.frame.origin.x, (smallHeart.frame.origin.y+((SCREEN_WIDTH*0.375)/2)-(SCREEN_WIDTH*0.046875)-smallHeart.frame.size.height))];
//    [self.animator addAnimation:heartTranslateAnimation];
//
//    IFTTTCornerRadiusAnimation *cyanTextAreaCornerAnimation = [IFTTTCornerRadiusAnimation animationWithView:cyanAreaForText];
//    [cyanTextAreaCornerAnimation addKeyframeForTime:2.00f cornerRadius:((SCREEN_WIDTH*0.375)/2)];
//    [cyanTextAreaCornerAnimation addKeyframeForTime:2.30f cornerRadius:5.0f];
//    [self.animator addAnimation:cyanTextAreaCornerAnimation];
//
//    IFTTTAlphaAnimation *crushHeadingAlphaAnimation = [IFTTTAlphaAnimation animationWithView:cyanAreaCrushHeading];
//    [crushHeadingAlphaAnimation addKeyframeForTime:2.90f alpha:0.0f];
//    [crushHeadingAlphaAnimation addKeyframeForTime:3.00f alpha:1.0f];
//    [self.animator addAnimation:crushHeadingAlphaAnimation];
//
//
//    IFTTTAlphaAnimation *crushTextAlphaAnimation = [IFTTTAlphaAnimation animationWithView:cyanAreaCrushText];
//    [crushTextAlphaAnimation addKeyframeForTime:2.90f alpha:0.0f];
//    [crushTextAlphaAnimation addKeyframeForTime:3.0f alpha:1.0f];
//    [self.animator addAnimation:crushTextAlphaAnimation];
//
//
//}

//-(void)animateAnimatableCyanArea{
//
//    IFTTTAlphaAnimation *cyanAlphaAnimation = [IFTTTAlphaAnimation animationWithView:animatableCyanArea];
//    [cyanAlphaAnimation addKeyframeForTime:1.0f alpha:0.0f];
//    [cyanAlphaAnimation addKeyframeForTime:1.1f alpha:1.0f];
//
//    [self.animator addAnimation:cyanAlphaAnimation];
//
//
//    IFTTTScaleAnimation *cyanScaleAnimation = [IFTTTScaleAnimation animationWithView:animatableCyanArea];
//    [cyanScaleAnimation addKeyframeForTime:1.0f scale:1.0f];
//    [cyanScaleAnimation addKeyframeForTime:1.4f scale:0.1f];
//
//    [self.animator addAnimation:cyanScaleAnimation];
//
//    IFTTTCornerRadiusAnimation *cornerRadiusAnimation = [IFTTTCornerRadiusAnimation animationWithView:animatableCyanArea];
//    [cornerRadiusAnimation addKeyframeForTime:1.3f cornerRadius:(SCREEN_HEIGHT/2)];
//    [self.animator addAnimation:cornerRadiusAnimation];
//
//
//    IFTTTAlphaAnimation *whiteAreaAnimation = [IFTTTAlphaAnimation animationWithView:whiteView];
//    [whiteAreaAnimation addKeyframeForTime:1.0f alpha:0.0f];
//    [whiteAreaAnimation addKeyframeForTime:1.1f alpha:1.0f];
//
//    [self.animator addAnimation:whiteAreaAnimation];
//
//}
//
//-(void)animateThirdSCreenTexts{
//    [thirdScreenSecondText setAlpha:0.0f];
//    [thirdScreenFirstText setAlpha:0.0f];
//
//    IFTTTAlphaAnimation *firstTextAlphaAnimation = [IFTTTAlphaAnimation animationWithView:thirdScreenFirstText];
//
//    [firstTextAlphaAnimation addKeyframeForTime:0.15f alpha:0.0f];
//    [firstTextAlphaAnimation addKeyframeForTime:0.30f alpha:1.0f];
//    [firstTextAlphaAnimation addKeyframeForTime:1.0f alpha:1.0f];
//    [firstTextAlphaAnimation addKeyframeForTime:1.1f alpha:0.0f];
//    [self.animator addAnimation:firstTextAlphaAnimation];
//
//    IFTTTAlphaAnimation *secondTextAlphaAnimation = [IFTTTAlphaAnimation animationWithView:thirdScreenSecondText];
//
//    [secondTextAlphaAnimation addKeyframeForTime:0.15f alpha:0.0f];
//    [secondTextAlphaAnimation addKeyframeForTime:0.30f alpha:1.0f];
//    [secondTextAlphaAnimation addKeyframeForTime:1.0f alpha:1.0f];
//    [secondTextAlphaAnimation addKeyframeForTime:1.1f alpha:0.0f];
//    [self.animator addAnimation:secondTextAlphaAnimation];
//
//}
//
//-(void)animateTagsView{
//
//    IFTTTAlphaAnimation *showViewAnimation = [IFTTTAlphaAnimation animationWithView:introTagsView];
//    [showViewAnimation addKeyframeForTime:0.3f alpha:0.0f];
//    [showViewAnimation addKeyframeForTime:0.31f alpha:1.0f];
//    [showViewAnimation addKeyframeForTime:1.0f alpha:1.0f];
//    [showViewAnimation addKeyframeForTime:1.11f alpha:0.0f];
//
//    [self.animator addAnimation:showViewAnimation];
//
//
//    [sixthTag setAlpha:1.0f];
//    IFTTTScaleAnimation *sixthTagScaleAnimation = [IFTTTScaleAnimation animationWithView:sixthTag];
//    [sixthTagScaleAnimation addKeyframeForTime:0.0f scale:0.01f];
//    [sixthTagScaleAnimation addKeyframeForTime:0.42f scale:0.01f];
//    [sixthTagScaleAnimation addKeyframeForTime:0.53f scale:1.0f];
//    [self.animator addAnimation:sixthTagScaleAnimation];
//
//    [fifthTag setAlpha:1.0f];
//    IFTTTScaleAnimation *fifthTagScaleAnimation = [IFTTTScaleAnimation animationWithView:fifthTag];
//    [fifthTagScaleAnimation addKeyframeForTime:0.0f scale:0.01f];
//    [fifthTagScaleAnimation addKeyframeForTime:0.51f scale:0.01f];
//    [fifthTagScaleAnimation addKeyframeForTime:0.63f scale:1.0f];
//    [self.animator addAnimation:fifthTagScaleAnimation];
//
//
//    [thirdTag setAlpha:1.0f];
//    IFTTTScaleAnimation *thirdTagScaleAnimation = [IFTTTScaleAnimation animationWithView:thirdTag];
//    [thirdTagScaleAnimation addKeyframeForTime:0.0f scale:0.01f];
//    [thirdTagScaleAnimation addKeyframeForTime:0.61f scale:0.01f];
//    [thirdTagScaleAnimation addKeyframeForTime:0.72f scale:1.0f];
//    [self.animator addAnimation:thirdTagScaleAnimation];
//
//    [secondTag setAlpha:1.0f];
//    IFTTTScaleAnimation *secondTagScaleAnimation = [IFTTTScaleAnimation animationWithView:secondTag];
//    [secondTagScaleAnimation addKeyframeForTime:0.0f scale:0.01f];
//    [secondTagScaleAnimation addKeyframeForTime:0.70f scale:0.01f];
//    [secondTagScaleAnimation addKeyframeForTime:0.82f scale:1.0f];
//    [self.animator addAnimation:secondTagScaleAnimation];
//
//
//    [fourthTag setAlpha:1.0f];
//    IFTTTScaleAnimation *fourthTagScaleAnimation = [IFTTTScaleAnimation animationWithView:fourthTag];
//    [fourthTagScaleAnimation addKeyframeForTime:0.0f scale:0.01f];
//    [fourthTagScaleAnimation addKeyframeForTime:0.80f scale:0.01f];
//    [fourthTagScaleAnimation addKeyframeForTime:0.91f scale:1.0f];
//    [self.animator addAnimation:fourthTagScaleAnimation];
//
//    [firstTag setAlpha:1.0f];
//    IFTTTScaleAnimation *firstTagScaleAnimation = [IFTTTScaleAnimation animationWithView:firstTag];
//    [firstTagScaleAnimation addKeyframeForTime:0.0f scale:0.01f];
//    [firstTagScaleAnimation addKeyframeForTime:0.89f scale:0.01f];
//    [firstTagScaleAnimation addKeyframeForTime:1.0f scale:1.0f];
//    [self.animator addAnimation:firstTagScaleAnimation];
//
//
//}
//
//-(void)animatePurpleCircle{
//
//    IFTTTScaleAnimation *purpleScaleAnimation = [IFTTTScaleAnimation animationWithView:purpleCircle];
//    [purpleScaleAnimation addKeyframeForTime:3.0 scale:1.0f];
//    [purpleScaleAnimation addKeyframeForTime:4.0f scale:25.0f];
//    [self.animator addAnimation:purpleScaleAnimation];
//
//}
//
//
//-(void)animateSecondScreenElements{
//    IFTTTAlphaAnimation *secondScreenSecondTextAlphaAnimation = [IFTTTAlphaAnimation animationWithView:secondScreenSecondText];
//    [secondScreenSecondTextAlphaAnimation addKeyframeForTime:3.3f alpha:0.0f];
//    [secondScreenSecondTextAlphaAnimation addKeyframeForTime:3.85f alpha:1.0f];
//    [secondScreenSecondTextAlphaAnimation addKeyframeForTime:5.0f alpha:1.0f];
//    [secondScreenSecondTextAlphaAnimation addKeyframeForTime:5.01f alpha:0.0f];
//    [self.animator addAnimation:secondScreenSecondTextAlphaAnimation];
//
//    IFTTTAlphaAnimation *questionAlphaAnimation = [IFTTTAlphaAnimation animationWithView:questionView];
//    [questionAlphaAnimation addKeyframeForTime:3.3f alpha:0.0f];
//    [questionAlphaAnimation addKeyframeForTime:3.85f alpha:1.0f];
//    [questionAlphaAnimation addKeyframeForTime:5.0f alpha:1.0f];
//    [questionAlphaAnimation addKeyframeForTime:5.01f alpha:0.0f];
//    [self.animator addAnimation:questionAlphaAnimation];
//
//    IFTTTAlphaAnimation *secondScreenFirstTextAlphaAnimation = [IFTTTAlphaAnimation animationWithView:secondScreenFirstText];
//    [secondScreenFirstTextAlphaAnimation addKeyframeForTime:3.3f alpha:0.0f];
//    [secondScreenFirstTextAlphaAnimation addKeyframeForTime:3.85f alpha:1.0f];
//    [secondScreenFirstTextAlphaAnimation addKeyframeForTime:5.0f alpha:1.0f];
//    [secondScreenFirstTextAlphaAnimation addKeyframeForTime:5.01f alpha:0.0f];
//    [self.animator addAnimation:secondScreenFirstTextAlphaAnimation];
//
//
//    IFTTTScaleAnimation *questionAreaScaleAnimation = [IFTTTScaleAnimation animationWithView:questionView];
//    [questionAreaScaleAnimation addKeyframeForTime:3.5f scale:0.01f];
//    [questionAreaScaleAnimation addKeyframeForTime:3.9f scale:1.0f];
//    [self.animator addAnimation:questionAreaScaleAnimation];
//
//}
//
//-(void)animateCyanCircle{
//    IFTTTScaleAnimation *cyanScaleAnimation = [IFTTTScaleAnimation animationWithView:cyanCircle];
//    [cyanScaleAnimation addKeyframeForTime:0.0 scale:1.0f];
//    [cyanScaleAnimation addKeyframeForTime:1.0f scale:25.0f];
//    [self.animator addAnimation:cyanScaleAnimation];
//
//
//    IFTTTAlphaAnimation *cyanAlphaAnimation = [IFTTTAlphaAnimation animationWithView:cyanCircle];
//    [cyanAlphaAnimation addKeyframeForTime:1.0f alpha:1.0f];
//    [cyanAlphaAnimation addKeyframeForTime:1.15f alpha:0.0f];
//
//    [self.animator addAnimation:cyanAlphaAnimation];
//}

-(void)loginViewDimissed:(void(^)(BOOL success, NSString *tokenString))block{
    dismissBlock = block;
}
- (IBAction)move:(id)sender {
    UIStoryboard *onBoardingStoryboard = [UIStoryboard storyboardWithName:@"onboarding" bundle:nil];
    OnBoardingNameViewController *onboarding = [onBoardingStoryboard instantiateViewControllerWithIdentifier:@"OnBoardingNameViewController"];
    [self.navigationController pushViewController:onboarding animated:true];
}

@end

