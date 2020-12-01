//
//  LoginViewController.h
//  Woo
//
//  Created by Umesh Mishra on 11/02/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginScreenInfoView.h"
#import "IFTTTBaseController.h"
#import "FBSDKLogin.h"
/**
 @author : Umesh Mishra
 
 LoginViewController will be visible when user need to login using facebook.
 
 It will be called in following scenarios:
 
 * When user is launching the app for the first time
 * If session expires and we have to renew the session
 
 It will contain two views:
 
 * Loginv view and
 * Tutorial view
 * Also permission view will appear when user tap on permission button placed in the bottom the view.
 */

@class U2opiaFBLoginView;

@interface LoginViewController : IFTTTBaseController<UIScrollViewDelegate>{
    
    IBOutlet UIView *bottomContainerView;
    U2opiaFBLoginView *loginViewObj;
    
    FBSDKLogin          *facebookBtn;
    BOOL isLoginCallMade;
    
    int currentPage;
    
    __weak IBOutlet UIButton *descriptionButton;
    __weak IBOutlet UIPageControl *pageControlObj;
    __weak IBOutlet FBSDKButton *btnFBSDKLogin;
    
    __weak IBOutlet UIView *viewFB;
    __weak IBOutlet UIView *bottomFacebookWarningArea;
    
    __weak IBOutlet UIButton *btnWhyFacebook;
    void (^dismissBlock)(BOOL success, NSString *tokenString);
    
    //Constanint
    
    __weak IBOutlet NSLayoutConstraint *constraintWooWidth;
    __weak IBOutlet NSLayoutConstraint *btnSignInPhonNumberBottom;
    
    __weak IBOutlet NSLayoutConstraint *constraintAnimateImageBottom;
    __weak IBOutlet NSLayoutConstraint *constraintWooHeight;
    __weak IBOutlet NSLayoutConstraint *constraintwooLogo;
    __weak IBOutlet NSLayoutConstraint *constraintWePutWomen;
    __weak IBOutlet NSLayoutConstraint *constraintWhyFacebookBottom;
    
     // Objects
     __weak IBOutlet UILabel *lblBelowLogo;
     __weak IBOutlet UILabel *lblWePutWomen;
     __weak IBOutlet UILabel *lblWeNeverPost;
    //When clicked on WhyFB button a new btnFBWhyFbLogin will appear
     __weak IBOutlet UIView *subViewFBWhyFbLogin;
    

/**
 *  Animation images starts from here
 */
    UIImageView *firstImage;
    UIImageView *secondImage;
    UIImageView *thirdImage;
//    UIImageView *fourthImage;
    UIImageView *fifthImage;
    UIImageView *sixthImage;
    
//    UIImageView *logoImage;
//    UILabel *discoverText;
//    
//    UIImageView *purpleCircle;
//    UILabel *secondScreenFirstText;
//    UIView *questionView;
//    UILabel *secondScreenSecondText;
//    
//    UIView *introTagsView;
//    UILabel *firstTag;
//    UILabel *secondTag;
//    UILabel *thirdTag;
//    UILabel *fourthTag;
//    UILabel *fifthTag;
//    UILabel *sixthTag;
//    UILabel *thirdScreenFirstText;
//    UILabel *thirdScreenSecondText;
//    
//    
//    UIImageView *cyanCircle;
//    UIView *animatableCyanArea;
//    UIView *whiteView;
//    UIImageView *smallHeart;
//    UIView *cyanAreaForText;
//    UILabel *cyanAreaCrushHeading;
//    UILabel *cyanAreaCrushText;
//    UILabel *fourthScreenFirstText;
//    UILabel *fourthScreenSecondText;
//    
//    UIImageView *lastImage;
//    UIImageView *lastPanelWooLogo;
//    UILabel *lastPanelText;
/**
 *  Animation images ENDS from here
 */
    
    
    /** Intro Animation V3.0
    
    UIImageView     *imgViewFirstScreenBg;
    UILabel         *lblFirstScreenIntroText;
    
    UIView          *viewSecondScreenBg;
    UIView          *viewSecondScreenMiddle;
    UILabel         *lblSecondScreenMiddleText;
    UILabel         *lblSecondScreenTopText;

    UILabel         *lblThirdScreenMiddleText;
    UILabel         *lblThirdScreenTopText;
    
    
    UIView          *viewFourthScreenBg;



    
      *  Intro Animation V3.0
      */
    

    LoginScreenInfoView *loginInfoView;
    
    IBOutlet NSLayoutConstraint *heightContraintOfBottomView;
    IBOutlet UIView *transparentBottomView;

    BOOL    delayFlag;
    
    NSTimer     *myTimer;
}

@property(nonatomic, assign) BOOL isFirstViewVisible;
@property(nonatomic, assign) BOOL isViewPresentedFromSync;
//@property(nonatomic, strong) AKFAccountKit *accountKit;
@property (nonatomic , assign) BOOL isAuthenticationFailed;
@property (assign)id    authenticationController;
@property(nonatomic, strong) NSMutableArray *introImages;

/**
 @author : Lokesh Sehgal
 This method will push user to discover screen
 */
-(void)pushToPostDiscoverViewController;

// ADded by Lokesh
-(void)performManualLogout;

/**
 @author : Umesh Mishra
 This method will add tutorials view above the login view
 */

/**
 @author : Umesh Mishra
 This method will add the facebook login button view below tutorial view
 */
-(void)displayLoginUI;

/**
 @author : Umesh Mishra
 This method will make login call if user is verified and launching the app again
 @param : notification object of NSNotification type. It contains userId,userName and access token that is used to make login call.
 */
-(void)makeLoginCall:(NSNotification *)notificationObj;
/**
 @author : Umesh Mishra
 This will show permission on a screen when user taps on the permission button
 */
-(void)displayPermissionUI;
/**
 @author : Umesh Mishra
 This method will send device ID to server.
 */
-(void)makeDeviceDataCall;

/**
 @author : Lokesh Sehgal
 This method will push the user to login view or to discover view
 */
-(void)pushToPostLoginViewController:(id)responseObject;
/**
 @author : Lokesh Sehgal
 This method will push the user to Profile Confirmation Screen
 */
-(void)pushToConfirmProfileScreen;
/**
 @author : Umesh Mishra
 method to show permission view. It will contain why we need permission from user.
 @param buttonObj that is clicked
 */
- (IBAction)permissionButtonclicked:(id)sender;

///**
//  @author : Umesh Mishra
//method to get new read permission from the user
//
// This is just a test method and will be removed
//
// */
//- (IBAction)getNewReadPermissionButtonclicked:(id)sender;
//
///**
//  @author : Umesh Mishra
// method to get new publish permission from the user
//
// This is just a test method and will be removed
//
// */
//- (IBAction)getPublishPermissionButtonclicked:(id)sender;

-(void)removeTutorialAndFbView;

- (IBAction)infoButtonTapped:(id)sender;

-(void)addAllObservers;

-(void)showAuthenticationAlert;

- (IBAction)neverPostDescriptionButton:(id)sender;

-(void)makeLoginCallToServerWithUserId:(NSString *)fbId withAccessToken:(NSString *)accessToken withDictionary:(id )Parameters andLoginThrough:(NSString *)viaMedium;

-(void)showReloginPopup;

-(void)loginViewDimissed:(void(^)(BOOL success, NSString *tokenString))dismissBlock;

- (BOOL)checkForFeedbackError;


@end


