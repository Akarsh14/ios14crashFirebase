//
//  SMSCodeVerificationController.h
//  Woo
//
//  Created by Umesh Mishra on 30/10/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WooLoader.h"

@interface SMSCodeVerificationController : UIViewController<UITextFieldDelegate>{
    __weak IBOutlet UILabel *viewHeaderMessageLabelObj;
    __weak IBOutlet UITextField *smsCodeTextFieldObj;
    __weak IBOutlet UIButton *submitButtonObj;
    
    __weak IBOutlet UIView *recheckHeaderView;
    __weak IBOutlet UIView *enterCodeHeaderView;
    
    
    __weak IBOutlet UIView *timerBackgroundViewObj;
    __weak IBOutlet UILabel *codeSentAgainLbl;
    __weak IBOutlet UILabel *countDownLabelObj;
//    __weak IBOutlet UIActivityIndicatorView *activityIndicatorObj;
    
    __weak IBOutlet UIView *codeNotRecievedViewObj;
    __weak IBOutlet UILabel *codeNotRecievedLabel;
    __weak IBOutlet DY_UnderLineButton *resendCodeButtonObj;
    __weak IBOutlet UIButton *callUsFreeButtonObj;
    
    
    
    
    __weak IBOutlet UIImageView *exclamaitonImageView;
    
    NSTimer *timerObj;
    
    int currMinuteVal;
    int currSecondsVal;
    
    NSString *verificationID;
    
    BOOL amIVisibleToUser;
    BOOL isSentOTPCallMade;
    AFNetworkReachabilityStatus internetStatus;
    BOOL showFallBackOption;
    
    
    BOOL isTimerExpired;
    BOOL isFallbackOptionShownToUser;
    
    BOOL sendUserToSubmitNumberView;
    IBOutlet UILabel *weHaveSendYouCodeLbl;
    BOOL showWeHaveSendYouCode;
    
    __weak IBOutlet UIView *codeContainerView;
    __weak IBOutlet UILabel *titleLbl;
    NSString *OTPString;
    
    __weak IBOutlet UIView *wooLoaderContainerViewObj;
    WooLoader *customLoader;
    void (^PhoneVerificatonBlock)(BOOL isSuccess, NSString *phoneNumberVerified);
}

@property (nonatomic, assign)BOOL isPushedFromCallVerficationScreen;
@property (nonatomic, retain)NSString *mobileNumber;
@property (nonatomic, retain)NSString *countryCode;
@property (nonatomic, retain)NSString *countryCodeString;
@property (nonatomic, assign)int lengthOfOtpCode;

-(IBAction)resendCodeButtonTapped:(id)sender;
-(IBAction)callUsFreeButtonTapped:(id)sender;
-(IBAction)submitCodeButtonTapped:(id)sender;
-(IBAction)backButtonTapped:(id)sender;

-(void)enableSubmitbutton:(BOOL)isSubmitButtonEnabled;

-(void)makeSendSMSToPhoneApiCall;
-(void)setHeaderMessageAndAllignItAccordingToText:(BOOL)showExclamationImage;

-(void)startCountDown:(int)timeOutTime;

-(void)showCustomLoader;
-(void)hideCustomLoader;

-(void)isPhoneVerifySuccess:(void(^)(BOOL isSuccess, NSString *phoneNumberVerified))verificationBlock;

@end
