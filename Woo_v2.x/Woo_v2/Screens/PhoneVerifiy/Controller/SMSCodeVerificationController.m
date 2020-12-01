//
//  SMSCodeVerificationController.m
//  Woo
//
//  Created by Umesh Mishra on 30/10/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "SMSCodeVerificationController.h"

@interface SMSCodeVerificationController ()

@end

@implementation SMSCodeVerificationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];

    internetStatus = -2;
    amIVisibleToUser = TRUE;
    isSentOTPCallMade = FALSE;
    [self initializeView];
    if (_lengthOfOtpCode < 1) {
        _lengthOfOtpCode = 4;
    }
    OTPString = @"";
    [self createOTPView];
    titleLbl.text = NSLocalizedString(@"Verify with code",nil);
    
    
//    [self setCustomBackButton];
    [self makeSendSMSToPhoneApiCall];
    [self addObserversForManagingTimerInBackground];
    smsCodeTextFieldObj.layer.borderColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0].CGColor;
    //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Enter_code_screen_without_timer forScreenName:@"FV"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kInternetConnectionStatusChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(internetConnectionStatusChanged:) name:kInternetConnectionStatusChanged object:nil];
    recheckHeaderView.hidden = TRUE;
    enterCodeHeaderView.hidden = FALSE;
    showWeHaveSendYouCode = FALSE;
    codeSentAgainLbl.hidden = TRUE;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [self showCustomLoader];
}

-(void)createOTPView{
    //width of the text field is 45
    //space between the two text field is 10
    int widthOfTheTextField = 45;
    int gapBetweenTextFields = 10;
    
    int totalWidth = (_lengthOfOtpCode * widthOfTheTextField) +((_lengthOfOtpCode-1)*gapBetweenTextFields);

    if (totalWidth > (SCREEN_WIDTH -28)) {
        NSLog(@"width is greater than as it should be");
        int totalAvailableWidth = (SCREEN_WIDTH -28);
        int maximumWidthWithSpace = totalAvailableWidth/_lengthOfOtpCode;
        widthOfTheTextField = maximumWidthWithSpace* 0.82;
        gapBetweenTextFields = maximumWidthWithSpace* 0.18;
        
        totalWidth = (_lengthOfOtpCode * widthOfTheTextField) +((_lengthOfOtpCode-1)*gapBetweenTextFields);
        
    }
    codeContainerView.backgroundColor = [UIColor clearColor];
    int startX = ((SCREEN_WIDTH - 28) - totalWidth)/2;
    for (int index = 0; index < _lengthOfOtpCode; index++) {
        UITextField *otpTextField = [[UITextField alloc] initWithFrame:CGRectMake(startX, 4, widthOfTheTextField, 32)];
        otpTextField.placeholder = [NSString stringWithFormat:@"%d",(index+1)%10];
        otpTextField.font = [UIFont fontWithName:@"Lato-Medium" size:16];
        otpTextField.textAlignment = NSTextAlignmentCenter;
        otpTextField.tag = index+1;
        otpTextField.textColor = [UIColor whiteColor];
        otpTextField.delegate = self;
//        otpTextField.backgroundColor = [UIColor whiteColor];
        
        UILabel *bottomBoundaryView = [[UILabel alloc] initWithFrame:CGRectMake(startX, 40, widthOfTheTextField, 2)];
        bottomBoundaryView.text = @"";
        bottomBoundaryView.backgroundColor = [UIColor whiteColor];
        
        [codeContainerView addSubview:otpTextField];
        [codeContainerView addSubview:bottomBoundaryView];
        
        startX += (widthOfTheTextField + gapBetweenTextFields);
    }
}
-(IBAction)backButtonTapped:(id)sender{
    if(_isPushedFromCallVerficationScreen){
        NSArray *viewControllerArray = [self.navigationController viewControllers];
        [self.navigationController popToViewController:[viewControllerArray objectAtIndex:[viewControllerArray count]-3] animated:YES];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
}

-(void)internetConnectionStatusChanged:(NSNotification*)notif{
    if (internetStatus == [notif.object intValue]) {
        internetStatus = [notif.object intValue];
        return;
    }
//    if (!isSentOTPCallMade) {
//        [self makeSendSMSToPhoneApiCall];
//    }
//    ;

    //    [self startMoniteringNetworkingFluctuations:internetStatus];
}
-(void)setCustomBackButton{
    
    //    [self.navigationItem setHidesBackButton:YES];
    [self.navigationController setNavigationBarHidden:FALSE];
    
    UIImage* backImage = [UIImage imageNamed:@"redBackButton.png"];
    CGRect backButtonImageRect = CGRectMake(0, 0, 17, 22);
    UIButton *backButtn = [[UIButton alloc] initWithFrame:backButtonImageRect];
    [backButtn setBackgroundImage:backImage forState:UIControlStateNormal];
    [backButtn addTarget:self action:@selector(backButtonTapped)
        forControlEvents:UIControlEventTouchUpInside];
    [backButtn setShowsTouchWhenHighlighted:NO];
    [backButtn setTitle:@"" forState:UIControlStateNormal];
    [backButtn setBackgroundColor:[UIColor clearColor]];
    UIBarButtonItem *backButtonItem =[[UIBarButtonItem alloc] initWithCustomView:backButtn];
    self.navigationItem.leftBarButtonItem = nil;
    [self.navigationItem setLeftBarButtonItem:backButtonItem];
    
    
}
-(void)setHeaderMessageAndAllignItAccordingToText:(BOOL)showExclamationImage{
//    [self hideCustomLoader];
    if ([smsCodeTextFieldObj.text length]>0) {
        [self enableSubmitbutton:TRUE];
    }
    
    recheckHeaderView.hidden = !showExclamationImage;
    enterCodeHeaderView.hidden = showExclamationImage;
    NSString *last4DigitsOfMobile = [_mobileNumber substringFromIndex:[_mobileNumber length]-4];
    NSString *headerMsg = [NSString stringWithFormat:NSLocalizedString(@"Please We have sent a code to your mobile number ending with %@. Please enter the verification code in the text box below.",nil), last4DigitsOfMobile];
    NSRange rangeOfLast4Digits = [headerMsg rangeOfString:last4DigitsOfMobile];
    NSMutableAttributedString *attributedHeaderStr = [[NSMutableAttributedString alloc] initWithString:headerMsg];
    [attributedHeaderStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Lato-Medium" size:14] range:NSMakeRange(0, [headerMsg length])];
    [attributedHeaderStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Lato-Bold" size:14] range:rangeOfLast4Digits];
    viewHeaderMessageLabelObj.text = showExclamationImage?NSLocalizedString(@"Please re-check the code",nil):headerMsg;
    viewHeaderMessageLabelObj.attributedText = attributedHeaderStr;
    if (showExclamationImage) {
        //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Enter_code_screen_with_timer_and_alert forScreenName:@"FV"];
    }
    
//    [viewHeaderMessageLabelObj sizeToFit];
    int width = viewHeaderMessageLabelObj.frame.size.width;
    int xPos = 0;
    
    if (showExclamationImage) {
        width = width + 15 + 12;
    }
    
    xPos = (self.view.frame.size.width - width)/2;
    
    if (showExclamationImage) {
        exclamaitonImageView.hidden = FALSE;
        CGRect imageFrame = exclamaitonImageView.frame;
        imageFrame.origin.x = xPos;
        xPos += imageFrame.size.width + 12;
        exclamaitonImageView.frame = imageFrame;
        
        CGRect labelFrame = viewHeaderMessageLabelObj.frame;
        labelFrame.origin.x = xPos;
        viewHeaderMessageLabelObj.frame = labelFrame;
        
    }
    else{
        exclamaitonImageView.hidden = TRUE;
        CGRect labelFrame = viewHeaderMessageLabelObj.frame;
        labelFrame.origin.x = xPos;
        viewHeaderMessageLabelObj.frame = labelFrame;
    }
}

-(void)backButtonTapped{
    if(_isPushedFromCallVerficationScreen){
        NSArray *viewControllerArray = [self.navigationController viewControllers];
        [self.navigationController popToViewController:[viewControllerArray objectAtIndex:[viewControllerArray count]-3] animated:YES];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

-(void)initializeView{
    
//    viewHeaderMessageLabelObj.font = kVerifyingMessageTextFont;
//    viewHeaderMessageLabelObj.textColor = kVerifyingMessageTextColor;
    
    smsCodeTextFieldObj.font = kVerifyingMessageTextFont;
    smsCodeTextFieldObj.layer.cornerRadius = 3.0;
    smsCodeTextFieldObj.layer.masksToBounds = YES;
    
    submitButtonObj.backgroundColor = kHeaderBackgroundColor;
    submitButtonObj.titleLabel.font = kVerifyingMessageTextFont;
    [submitButtonObj setTitleColor:kVerifyingMessageTextColor forState:UIControlStateNormal];
    submitButtonObj.layer.cornerRadius = 3.0;
    
    timerBackgroundViewObj.backgroundColor = [UIColor clearColor];
//    warningMessageLabelObj.font = kVerifyingMessageTextFont;
//    warningMessageLabelObj.textColor = kVerifyingMessageTextColor;
    countDownLabelObj.font = kVerifyingMessageTextFont;
//    countDownLabelObj.textColor = kVerifyingMessageTextColor;
    
    
    
    
//    codeNotRecievedViewObj.backgroundColor = [UIColor clearColor];
    
    codeNotRecievedLabel.font = kVerifyingMessageTextFont;
//    codeNotRecievedLabel.textColor = kVerifyingMessageTextColor;
    
//    resendCodeButtonObj.backgroundColor = kHeaderBackgroundColor;
//    resendCodeButtonObj.titleLabel.font = kVerifyingMessageTextFont;
//    [resendCodeButtonObj setTitleColor:kVerifyingMessageTextColor forState:UIControlStateNormal];
//    resendCodeButtonObj.layer.cornerRadius = 3.0;
    
    callUsFreeButtonObj.backgroundColor = kHeaderBackgroundColor;
    callUsFreeButtonObj.titleLabel.font = kVerifyingMessageTextFont;
    [callUsFreeButtonObj setTitleColor:kVerifyingMessageTextColor forState:UIControlStateNormal];
    callUsFreeButtonObj.layer.cornerRadius = 3.0;
    [self setHeaderMessageAndAllignItAccordingToText:FALSE];
    [self showTimerView];
    
    
    
//    submitButtonObj.enabled = FALSE;
//    submitButtonObj.backgroundColor = kHeaderBackgroundColor_Disabled;
    [self enableSubmitbutton:FALSE];
    smsCodeTextFieldObj.userInteractionEnabled = FALSE;
    
}

-(void)makeSendSMSToPhoneApiCall{
    
    NSString *countryCode = [_countryCodeString length]>0?_countryCodeString:@"";
    
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    if (reachability.isReachable || reachability.isReachableViaWiFi || reachability.isReachableViaWWAN) {
        //###$$$LUV change the country code value. It is hardcoced right now but it should be varaible
        NSLog(@"sms ki call mari hai");
//        http://apifv.foneverify.com/U2opia_Verify/v1.0/flow/sms?customerId=ble6go3s&isoCountryCode=IN&appKey=55a7420199070a9c0961fff9d4fe12f6&msisdn=9999081881
//        NSString *sendSmsCodeToPhoneURL = [NSString stringWithFormat:@"%@%@?appId=%@&isoCountryCode=%@&mobileNumber=%@&sourceType=IPHONE",kFoneVerifyBaseURLV1,kFoneVerificationSendSmsToPhoneAPI,kFoneVerifyAppID,countryCode,_mobileNumber];
        NSString *sendSmsCodeToPhoneURL = [NSString stringWithFormat:@"%@%@?customerId=%@&isoCountryCode=%@&msisdn=%@&appKey=%@",kFoneVerifyBaseURLV1_New,kFoneVerificationSendSmsToPhoneAPI_New,kFoneVerifyCustomerId,countryCode,_mobileNumber,kFoneVerifyAppSecretKey];
        WooRequest *wooRequestObj = [[WooRequest alloc]init];
        wooRequestObj.url =sendSmsCodeToPhoneURL;
        wooRequestObj.time =900;
        wooRequestObj.requestParams =nil;
        wooRequestObj.methodType =postRequest;
        wooRequestObj.numberOfRetries =3;
        wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
        wooRequestObj.requestType = foneVerifySendSmsToVerify;
        isSentOTPCallMade = TRUE;
        [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
            if (requestType == foneVerifySendSmsToVerify) {
                if (statusCode == 200) {
                    verificationID = [response objectForKey:@"verificationId"];
                    NSLog(@"response :%@",response);
                    if ( ([[response objectForKey:@"responseCode"] intValue] == 506) || ([[response objectForKey:@"responseCode"] intValue] == 708)) {
                        if ([[response objectForKey:@"responseCode"] intValue] == 506) {
                            showWeHaveSendYouCode = TRUE;
                        }
                        
                        [self showWeHaveSendYouCodeView];
                        smsCodeTextFieldObj.userInteractionEnabled = TRUE;
//                        [self checkUpdateStatusFromFoneverifyAutomatically];
                        [self handleResponseFromfoneverifyServer:[[response objectForKey:@"responseCode"] intValue] andVerififcationStatus:[response objectForKey:@"verificationStatus"] withResponse:response];
                        [self hideCustomLoader];
//                        [APP_Utilities displayAlertWithTitle:NSLocalizedString(@"Oops!", nil) message:[response objectForKey:@"errorMessage"] withDelegate:self];
//                        U2AlertView *errorMessageAlert = [[U2AlertView alloc] init];
//                        NSString *errorMsg = NSLocalizedString(@"Something went wrong. Please try after sometime.", nil);
//                        sendUserToSubmitNumberView = TRUE;
//                        if ([[response objectForKey:@"responseCode"] intValue] == 506) {
//                            errorMsg = NSLocalizedString(@"We have already sent a code. Please check SMS inbox.", nil);
//                            sendUserToSubmitNumberView = FALSE;
//                            [self checkUpdateStatusFromFoneverifyAutomatically];
//                        }
//                        [errorMessageAlert alertWithHeaderText:NSLocalizedString(@"Oops!", nil) description:errorMsg leftButtonText:@"OK" andRightButtonText:nil];
//                        [errorMessageAlert setSelectorOnAlertButtonTapped:@selector(okButtonTapped:)];
//                        [errorMessageAlert setDelegate:self];
//                        [errorMessageAlert show];
                    }
                    else{
                        [self startCountDown:[[response objectForKey:@"timeout"] intValue]>0?90:90];
                        //                    [self startCountDown:[[response objectForKey:@"timeout"] intValue]>0?30:90];
                        NSInteger numberOfTimesResendButtonTapped = [[NSUserDefaults standardUserDefaults] integerForKey:kNumberOfTimeResendButtonTappedForDay];
                        [[NSUserDefaults standardUserDefaults] setInteger:++numberOfTimesResendButtonTapped forKey:kNumberOfTimeResendButtonTappedForDay];
                        if (([[NSDate date] timeIntervalSince1970] - [[NSUserDefaults standardUserDefaults] doubleForKey:kDisableResendSMSButtonTime]) >86400) {
                            [[NSUserDefaults standardUserDefaults] setDouble:[[NSDate date] timeIntervalSince1970] forKey:kDisableResendSMSButtonTime];
                            
                        }
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                    
                }
            }
        } shouldReachServerThroughQueue:YES];
    }
    else{
        if (amIVisibleToUser) {
            [APP_Utilities displayAlertWithTitle:nil message:@"No internet connection\nPlease try again." withDelegate:self];
            [smsCodeTextFieldObj resignFirstResponder];
        }
    }
}
-(void)okButtonTapped:(NSString *)buttonIndex{
    if ([buttonIndex integerValue] == 0 && sendUserToSubmitNumberView) {
        PhoneVerificatonBlock(FALSE, @"");
        [self backButtonTapped];
    }
}

-(void)showTimerView{
    codeNotRecievedViewObj.hidden = TRUE;
    timerBackgroundViewObj.hidden = FALSE;
    timerBackgroundViewObj.alpha = 1;
    codeNotRecievedViewObj.alpha = 0;
    countDownLabelObj.hidden = TRUE;
//    [self performSelector:@selector(startCountDown) withObject:nil afterDelay:4.0];

}

-(void)startCountDown:(int)timeOutTime;
{
//    submitButtonObj.enabled = TRUE;
//    submitButtonObj.backgroundColor = kHeaderBackgroundColor;
    smsCodeTextFieldObj.userInteractionEnabled = TRUE;
    
///####$$$$LUV
    currMinuteVal = timeOutTime/60;
    currSecondsVal = timeOutTime%60;
    
//    currMinuteVal = 0;
//    currSecondsVal = 30;
    [self hideCustomLoader];
    countDownLabelObj.hidden = FALSE;
    [countDownLabelObj setText:[NSString stringWithFormat:@"%d%@%02d",currMinuteVal,@":",currSecondsVal]];
    
    if (!timerObj) {
        timerObj=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countdownFired) userInfo:nil repeats:YES];
    }
    isTimerExpired = FALSE;
}
-(void)countdownFired
{
    NSLog(@"countDownLabelObj : %@",countDownLabelObj.text);
    if((currMinuteVal>0 || currSecondsVal>=0) && currMinuteVal>=0)
    {
        if(currSecondsVal==0)
        {
            currMinuteVal-=1;
            currSecondsVal=59;
        }
        else if(currSecondsVal>0)
        {
            currSecondsVal-=1;
        }
        if(currMinuteVal>-1)
            [countDownLabelObj setText:[NSString stringWithFormat:@"%d%@%02d",currMinuteVal,@":",currSecondsVal]];
        
    }
    else
    {
        
        
        [timerObj invalidate];
        timerObj = nil;
        isTimerExpired = TRUE;
        showWeHaveSendYouCode = TRUE;
        //Timer over call sms failed to send
        if (isTimerExpired && isFallbackOptionShownToUser) {
            [self showResendCodeView];
        }
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkUpdateStatusFromFoneverifyAutomatically) object:nil];
        [self checkUpdateStatusFromFoneverifyAutomatically];
        
    }
}

-(void)showResendCodeView{

    if (!_isPushedFromCallVerficationScreen) {
        [callUsFreeButtonObj setTitle:NSLocalizedString(@"Cancel",nil) forState:UIControlStateNormal];
        callUsFreeButtonObj.hidden = TRUE;
    }
    if ((([[NSDate date] timeIntervalSince1970] - [[NSUserDefaults standardUserDefaults] doubleForKey:kDisableResendSMSButtonTime]) >86400) || [[NSUserDefaults standardUserDefaults] integerForKey:kNumberOfTimeResendButtonTappedForDay]<390) {
        //date is either 24 hours ago or number of time resend button is clicked is less than 3
        if ([[NSUserDefaults standardUserDefaults] integerForKey:kNumberOfTimeResendButtonTappedForDay] >=3) {
            //its here as the number of times the resend button clicked is 3 or greater that means the the is of 24 hours ago, so we need to reset it.
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:kNumberOfTimeResendButtonTappedForDay];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
    }
    if (([[NSUserDefaults standardUserDefaults] integerForKey:kNumberOfTimeResendButtonTappedForDay] >= 3)) {
       // resendCodeButtonObj.backgroundColor = kHeaderBackgroundColor_Disabled;
        resendCodeButtonObj.userInteractionEnabled = FALSE;
        resendCodeButtonObj.enabled = FALSE;
    }
    else{
       // resendCodeButtonObj.backgroundColor = kHeaderBackgroundColor;
        resendCodeButtonObj.userInteractionEnabled = TRUE;
        resendCodeButtonObj.enabled = TRUE;
    }
    
    resendCodeButtonObj.backgroundColor = [UIColor clearColor];
    resendCodeButtonObj.titleLabel.textColor = kHeaderBackgroundColor;
    [resendCodeButtonObj setButtonLineColorBasedOnisTaggableIsCommonWithName:nil withTagId:nil withTagsDToType:nil withIsTagable:YES withIsCommon:nil];
    [resendCodeButtonObj setTitle:NSLocalizedString(@"Resend Code", nil) forState:UIControlStateNormal];
    
    [UIView animateWithDuration:0.2 animations:^{
        timerBackgroundViewObj.alpha = 0;
        codeNotRecievedViewObj.alpha = 1;
    } completion:^(BOOL finished) {
        timerBackgroundViewObj.hidden = TRUE;
        codeNotRecievedViewObj.hidden = FALSE;
    }];
    
}

-(IBAction)resendCodeButtonTapped:(id)sender{
    isSentOTPCallMade = FALSE;
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    if (reachability.isReachable || reachability.isReachableViaWiFi || reachability.isReachableViaWWAN) {
        [self showTimerView];
        
        
        [self setHeaderMessageAndAllignItAccordingToText:FALSE];
        [self showCustomLoader];
        [self makeSendSMSToPhoneApiCall];
        isFallbackOptionShownToUser = FALSE;
        isTimerExpired = FALSE;
        //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Clicks_on_resend_code_from_enter_code_screen forScreenName:@"FV"];
        
    }
    else{
        
        [APP_Utilities displayAlertWithTitle:nil message:@"No internet connection\nPlease try again." withDelegate:self];
        [smsCodeTextFieldObj resignFirstResponder];
    }
    
    
}
-(IBAction)callUsFreeButtonTapped:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
    //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Clicks_on_call_us_from_enter_code_screen forScreenName:@"FV"];
}
-(IBAction)submitCodeButtonTapped:(id)sender{
    
    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"SubmitOTP" forScreenName:@"FoneVerify"];
    if ([OTPString length]>0) {
        [self sendEnteredCodeToFoneverifyServer:OTPString andRetry:FALSE];
    }
    else{
        [self setHeaderMessageAndAllignItAccordingToText:FALSE];
    }
}

-(void)sendEnteredCodeToFoneverifyServer:(NSString *)codeText andRetry:(BOOL)retryUpdate{
        NSLog(@"make webservice call");
        AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
        if (reachability.isReachable || reachability.isReachableViaWiFi || reachability.isReachableViaWWAN) {
            [self enableSubmitbutton:FALSE];
//            if (!retryUpdate) {
                [self showCustomLoader];
//            }
            [smsCodeTextFieldObj resignFirstResponder];
            NSString *sendSmsCodeToPhoneURL = [NSString stringWithFormat:@"%@%@?verificationId=%@&appKey=%@&customerId=%@",kFoneVerifyBaseURLV1_New,kFoneVerificationUpdateAPI_New,verificationID,kFoneVerifyAppSecretKey,kFoneVerifyCustomerId];
            if ([codeText length]>0) {
                sendSmsCodeToPhoneURL = [NSString stringWithFormat:@"%@&code=%@",sendSmsCodeToPhoneURL,codeText];
            }
            
            WooRequest *wooRequestObj = [[WooRequest alloc]init];
            wooRequestObj.url =sendSmsCodeToPhoneURL;
            wooRequestObj.time =900;
            wooRequestObj.requestParams =nil;
            wooRequestObj.methodType =getRequest;
            wooRequestObj.numberOfRetries =3;
            wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
            wooRequestObj.requestType = foneVerifySendSmsToVerify;
            [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
                if (requestType == foneVerifySendSmsToVerify) {
                    NSLog(@"response  >>>>> submitCodeButtonTapped >>>>> SMSCodeVerificationController : %@",response);
                    if (success && statusCode == 200) {
                        
//                        if ([[response objectForKey:@"errorMessage"] length]>0 && [[response objectForKey:@"responseCode"] length]>0) {
//                            [self setHeaderMessageAndAllignItAccordingToText:TRUE];
//                        }
//                        else if ([[response objectForKey:@"responseCode"] intValue] == 701|| [[response objectForKey:@"responseCode"] intValue] == 706){
//                            //Trying fall back
//
//                        }
//                        else if ([[response objectForKey:@"responseCode"] intValue] == 702 || [[response objectForKey:@"responseCode"] intValue] == 708){
//                            [self showTimerView];
//                            [self performSelector:@selector(checkUpdateStatusFromFoneverifyAutomatically) withObject:nil afterDelay:5.0];
//                            
//                        }
//                        else if ([[response objectForKey:@"verificationStatus"] caseInsensitiveCompare:@"Verified"] == NSOrderedSame) {
//                            [self sendVerifiedMobileDetailsToServer:_mobileNumber forWooID:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
//                        }
//                        else{
//                            [self performSelector:@selector(checkUpdateStatusFromFoneverifyAutomatically) withObject:nil afterDelay:5.0];
//                            [self setHeaderMessageAndAllignItAccordingToText:TRUE];
//                        }
                        
                        [self handleResponseFromfoneverifyServer:[[response objectForKey:@"responseCode"] intValue] andVerififcationStatus:[response objectForKey:@"verificationStatus"] withResponse:response];
                        [self hideCustomLoader];
                        
                    }
                    else if (statusCode == 8){
                        //Show error message
                        [self enableSubmitbutton:TRUE];
                        [self hideCustomLoader];
                        [smsCodeTextFieldObj becomeFirstResponder];
                        [self setHeaderMessageAndAllignItAccordingToText:FALSE];
                    }
                    else{
                        [self hideCustomLoader];
                    }
                }
            } shouldReachServerThroughQueue:YES];
        }
        else{
            if (amIVisibleToUser) {
                [APP_Utilities displayAlertWithTitle:nil message:@"No internet connection\nPlease try again." withDelegate:self];
                //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:No_internet_connection forScreenName:@"FV"];
            }
            
            [smsCodeTextFieldObj resignFirstResponder];
        }
        
        
    
}


-(void)handleResponseFromfoneverifyServer:(int)statusCode andVerififcationStatus:(NSString *)verificatoinStatus withResponse:(NSDictionary *)response{
    
    
    
    switch (statusCode) {
            
        case 200:{
//            VERIFICATION_COMPLETED
            [self sendVerifiedMobileDetailsToServer:_mobileNumber forWooID:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
        }
            break;
        case 700:{
            //VERIFICATION_FAILED
            [self showResendCodeView];
            break;
        }
        case 701:
        case 705:
        case 707:
        case 706:{
            //Trying fallback
            verificationID = [response objectForKey:@"verificationId"];
            [self startCountDown:[[response objectForKey:@"timeout"] intValue]>0?90:90];
            isFallbackOptionShownToUser = TRUE;
         
        }
            break;
        case 703:{
            U2AlertView *alertObj= [[U2AlertView alloc] init];
            [alertObj alertWithHeaderText:nil description:NSLocalizedString(@"You have entered a mobile number that already exists.",nil) leftButtonText:NSLocalizedString(@"CMP00356", nil) andRightButtonText:nil];
            
            [alertObj setU2AlertActionBlockForButton:^(int tagValue , id data){
                PhoneVerificatonBlock(FALSE, @"");
                [self backButtonTapped];
                
            }];
            

            
            
            
            [alertObj show];
            [smsCodeTextFieldObj resignFirstResponder];
        }
        case 702:{
//            WRONG_OTP_PROVIDED
            //Show error message
            
            [self hideCustomLoader];
            
            U2AlertView *wrongOTP = [[U2AlertView alloc] init];
            [wrongOTP alertWithHeaderText:nil description:NSLocalizedString(@"Please re-check the code", nil) leftButtonText:NSLocalizedString(@"CMP00356", nil) andRightButtonText:nil];
            [wrongOTP show];
            
            [wrongOTP setU2AlertActionBlockForButton:^(int tagValue , id data){
                    [self wrongOTPOkButtonTapped];
            }];

            break;
        }
        case 506:
        case 708:
        {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkUpdateStatusFromFoneverifyAutomatically) object:nil];
            [self performSelector:@selector(checkUpdateStatusFromFoneverifyAutomatically) withObject:nil afterDelay:5.0];
        }
            break;
//        default:
//            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkUpdateStatusFromFoneverifyAutomatically) object:nil];
//            [self performSelector:@selector(checkUpdateStatusFromFoneverifyAutomatically) withObject:nil afterDelay:5.0];
//            break;
    }
    
    
    [self showWeHaveSendYouCodeView];
    
}

-(void)showWeHaveSendYouCodeView{
    weHaveSendYouCodeLbl.hidden = !showWeHaveSendYouCode;
}

-(void)wrongOTPOkButtonTapped{
        [self enableSubmitbutton:TRUE];
        [smsCodeTextFieldObj becomeFirstResponder];
}
-(void)checkUpdateStatusFromFoneverifyAutomatically{
    if (isTimerExpired && !isFallbackOptionShownToUser) {
        [self showCustomLoader];
        [self showTimerView];
        codeSentAgainLbl.hidden = FALSE;
    }
    else{
        codeSentAgainLbl.hidden = TRUE;
    }
    [self sendEnteredCodeToFoneverifyServer:@"" andRetry:TRUE];
}

-(void)sendVerifiedMobileDetailsToServer:(NSString *)mobileNumber forWooID:(NSString *)wooId{
    
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    if (reachability.isReachable || reachability.isReachableViaWiFi || reachability.isReachableViaWWAN) {
        NSString *verificationIDURL = [NSString stringWithFormat:@"%@%@?wooId=%@&msisdn=%@&msisdnVerificationMode=%@",[NSString stringWithFormat:@"%@",kBaseURLV1],kSaveVerifiedNumberOnServerAPI,wooId,_mobileNumber,@"SMS"];
        
        
        WooRequest *wooRequestObj = [[WooRequest alloc]init];
        wooRequestObj.url =verificationIDURL;
        wooRequestObj.time =900;
        wooRequestObj.requestParams =nil;
        wooRequestObj.methodType =postRequest;
        wooRequestObj.numberOfRetries =3;
        wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
        wooRequestObj.requestType = saveVerifiedNumberOnServer;
        [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
            if (requestType == saveVerifiedNumberOnServer) {
                NSLog(@"response  >>>>> sendVerifiedMobileDetailsToServer >>>>> SMSCodeVerificationController : %@",response);
                [self enableSubmitbutton:TRUE];
                [self hideCustomLoader];
//                [smsCodeTextFieldObj becomeFirstResponder];
                if (statusCode == 200 || statusCode == 302) {
                    if (statusCode == 200) {
                        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kUserShouldGetNewProfilesAsIncentive];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                    PhoneVerificatonBlock(TRUE, mobileNumber);
                    if (amIVisibleToUser) {
                        

                        [APP_DELEGATE sendSwrveEventWithEvent:@"EditProfile.PhoneDone" andScreen:@"EditProfile"];
                        [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"FoneVerifyDone" forScreenName:@"EditProfile"];
//                        U2AlertView *alertObj= [[U2AlertView alloc] init];
//                        [alertObj alertWithHeaderText:NSLocalizedString(@"Verification Complete",nil) description:NSLocalizedString(@"CFV0021",nil) leftButtonText:NSLocalizedString(@"CMP00356", nil) andRightButtonText:nil];
//                        alertObj.delegate = self;
//                        [alertObj setSelectorOnAlertButtonTapped:@selector(buttonTapped:)];
//                        [alertObj show];
                        [APP_Utilities showToastWithText:NSLocalizedString(@"Phone number verified", nil)];
                        [smsCodeTextFieldObj resignFirstResponder];
                        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kIsVerifiedMsisdnKey];
//                        [[NSUserDefaults standardUserDefaults] synchronize];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kPhoneNumberVierfiedUpdateView object:nil];
                        
                        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kIsPreferencesChanged];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        [self.navigationController popToRootViewControllerAnimated:YES];
                        
                        //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Phone_verification_successful forScreenName:@"FV"];
                    }
                    
                }
                else if (statusCode == 208 || statusCode == 226){
                    if (amIVisibleToUser) {
                        //Already verified
                        U2AlertView *alertObj= [[U2AlertView alloc] init];
                        [alertObj alertWithHeaderText:nil description:NSLocalizedString(@"Mobile number already verified! Please enter another number.",nil) leftButtonText:NSLocalizedString(@"CMP00356", nil) andRightButtonText:nil];

                        [alertObj setU2AlertActionBlockForButton:^(int tagValue , id data){
                            PhoneVerificatonBlock(FALSE, @"");
                            [self backButtonTapped];
                        }];
                        
                        [alertObj show];
                        [smsCodeTextFieldObj resignFirstResponder];
                        //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Mobile_number_already_verified forScreenName:@"FV"];
                    }
                    
                }
            }
            
        } shouldReachServerThroughQueue:YES];
        
    }
    else{
        if (amIVisibleToUser) {
            [APP_Utilities displayAlertWithTitle:nil message:@"No internet connection\nPlease try again." withDelegate:self];
            [smsCodeTextFieldObj resignFirstResponder];
        }
        
    }
}


-(void)buttonTapped:(NSString *)buttonIndex{
//    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kUserShouldGetNewProfilesAsIncentive];
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kIsPreferencesChanged];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (([string length]>1) || (([textField.text length]>0) && [string length] >0)) {
        return FALSE;
    }
    
    
    OTPString = [NSString stringWithFormat:@"%@%@",OTPString,string];
    NSString *finalString = OTPString;
//    if (([string length] < 1) && ([finalString length] > 0)) {
//        
//        
//    }
    
    if ([string length] > 0) {
        [self moveToNextTextFieldIfPresent:textField.tag moveForward:TRUE];
    }
    else{
        if ([textField.text length] == 0) {
            [self moveToNextTextFieldIfPresent:textField.tag moveForward:FALSE];
        }
        else{
            OTPString = [OTPString substringToIndex:[OTPString length]-1];
            finalString = [finalString substringToIndex:[finalString length]-1];
        }
        
    }
    textField.text = string;
    if ([finalString length]>0) {
        [self enableSubmitbutton:TRUE];
//        submitButtonObj.enabled = TRUE;
//        submitButtonObj.backgroundColor = kHeaderBackgroundColor;
    }
    else{
        [self enableSubmitbutton:FALSE];
//        submitButtonObj.enabled = FALSE;
//        submitButtonObj.backgroundColor = kHeaderBackgroundColor_Disabled;
    }
    if ([textField.text length]>0 && [string length]>0) {
        return FALSE;
    }
    return FALSE;
}
-(void)moveToNextTextFieldIfPresent:(NSInteger)currentTextFieldTagId moveForward:(BOOL)moveForward{
    if (moveForward) {
        if (currentTextFieldTagId < _lengthOfOtpCode) {
            UITextField *nextTextFiledObj = [codeContainerView viewWithTag:currentTextFieldTagId+1];
            if (nextTextFiledObj) {
                [nextTextFiledObj becomeFirstResponder];
            }
        }
        
    }
    else{
        if (currentTextFieldTagId > 1) {
            UITextField *nextTextFiledObj = [codeContainerView viewWithTag:currentTextFieldTagId-1];
            if (nextTextFiledObj) {
                [nextTextFiledObj becomeFirstResponder];
            }
        }
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if ([smsCodeTextFieldObj.text length]>0) {
        [self enableSubmitbutton:TRUE];
    }
}

-(void)enableSubmitbutton:(BOOL)isSubmitButtonEnabled{
    submitButtonObj.enabled = isSubmitButtonEnabled;
    submitButtonObj.userInteractionEnabled = isSubmitButtonEnabled;
    submitButtonObj.backgroundColor = isSubmitButtonEnabled?kHeaderBackgroundColor:kHeaderBackgroundColor_Disabled;
}

-(void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:YES];
    if (timerObj) {
        [timerObj invalidate],timerObj = nil;
    }
    amIVisibleToUser = FALSE;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}


-(void)addObserversForManagingTimerInBackground{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveTimerState) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeTimer) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)saveTimerState{
    NSLog(@"-----");
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble: [[NSDate date] timeIntervalSince1970]] forKey:@"TimeStampAtBackground"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)resumeTimer{
    NSNumber *backgroundTimestamp = [[NSUserDefaults standardUserDefaults] objectForKey:@"TimeStampAtBackground"];
    NSNumber *currentTimestamp = [NSNumber numberWithDouble: [[NSDate date] timeIntervalSince1970]];
    int elapsedTime;
    elapsedTime = [currentTimestamp intValue] - [backgroundTimestamp intValue];
    
    NSLog(@"++++\n\n\n\n ++++ %d",elapsedTime);
    
    int seconds = elapsedTime % 60;
    int minutes = (elapsedTime / 60) % 60;
    
    currMinuteVal = currMinuteVal - minutes;
    currSecondsVal = currSecondsVal - seconds;
    if (currSecondsVal < 0) {
        currSecondsVal = 0;
    }
    if (currMinuteVal < 0) {
        currMinuteVal = 0;
    }
}

-(void)showCustomLoader{
    if (!customLoader) {
        customLoader = [[WooLoader alloc]initWithFrame:wooLoaderContainerViewObj.bounds];
        [customLoader customLoadingText:@""];
        [customLoader startAnimationOnView:wooLoaderContainerViewObj WithBackGround:NO];
    }
    wooLoaderContainerViewObj.hidden = FALSE;
}
-(void)hideCustomLoader{
    if (customLoader) {
        [customLoader removeFromSuperview];
        customLoader = nil;
    }
    wooLoaderContainerViewObj.hidden = TRUE;
    
}
-(void)isPhoneVerifySuccess:(void(^)(BOOL isSuccess, NSString *phoneNumberVerified))verificationBlock{
    PhoneVerificatonBlock = verificationBlock;
}
@end
