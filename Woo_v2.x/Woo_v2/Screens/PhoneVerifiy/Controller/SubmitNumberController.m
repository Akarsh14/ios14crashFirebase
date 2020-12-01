//
//  SubmitNumberController.m
//  Woo
//
//  Created by Umesh Mishra on 27/10/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "SubmitNumberController.h"
#import "AlmostThereController.h"
#import "SMSCodeVerificationController.h"
#import "WooLoader.h"

typedef enum {
    CALL_TO_VERIFY = 1,
    SEND_SMS_TO_VERIFY = 1 << 1
    
    
}foneVerifyFlowConfiguration;


@interface SubmitNumberController ()

@end

@implementation SubmitNumberController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    foneVerificationFlowValue =SEND_SMS_TO_VERIFY;
    //configure navigation bar
    [self configureNavBar];
//    [self initialiseView];
//    [self getFoneVerfiyConfigurationFromServer];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    phoneLabelBackground.layer.borderColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0].CGColor;
    [self initialiseView];
}

-(void)getFoneVerfiyConfigurationFromServer{
    
    if (([[NSDate date] timeIntervalSince1970] - [[NSUserDefaults standardUserDefaults] doubleForKey:kDisableResendSMSButtonTime]) >86400) {
        //If time has been
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:kNumberOfTimeResendButtonTappedForDay];
            [[NSUserDefaults standardUserDefaults] synchronize];
    }
    NSString *urlString = [NSString stringWithFormat:@"%@application/%@/verificationFlow",kFoneVerifyBaseURLV1,kFoneVerifyAppID];
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =urlString;
    wooRequestObj.time =900;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =getRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = getFoneVerificationConfiguration;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        if (success) {
            for (NSString *flowVal in [response objectForKey:@"flows"]) {
                if ([flowVal isEqualToString:@"CALLDID"]) {
                    foneVerificationFlowValue = foneVerificationFlowValue | CALL_TO_VERIFY;
                }
                else if([flowVal isEqualToString:@"SMS"]){
                    foneVerificationFlowValue = foneVerificationFlowValue | SEND_SMS_TO_VERIFY;
                }
            }
            foneVerificationFlowValue =SEND_SMS_TO_VERIFY;
        }
    } shouldReachServerThroughQueue:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Configure the navigation bar of the view. Add title and back button on navigatin bar
-(void)configureNavBar{

    titleLbl.text = NSLocalizedString(@"Submit Number",nil);
    
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    
    [self.navigationController setNavigationBarHidden:TRUE animated:YES];
 
    
}

-(IBAction)backButtonTapped:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
    PhoneVerificatonBlock(FALSE, @"");
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

-(void)backButtonTapped{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initialiseView{
//    headingMessageLabelObj.font = kVerifyingMessageTextFont;
//    headingMessageLabelObj.textColor = kVerifyingMessageTextColor;
    
//    countryCodeLabelObj.font = kVerifyingMessageTextFont;
//    countryCodeLabelObj.textColor = kVerifyingMessageTextColor;
    if ([_countryCode length]>0) {
        countryCodeLabelObj.text = _countryCode;
    }
    if ([_flagImageUrlString length]>0) {
        [flagImageViewObj sd_setImageWithURL:[NSURL URLWithString:_flagImageUrlString]];
    }
//    
//    warningMessageLabel.font = kVerifyingMessageTextFont;
//    warningMessageLabel.textColor = kVerifyingMessageTextColor;
//    
//    numberTextFieldObj.font = kVerifyingMessageTextFont;
    
//    submitButtonObj.backgroundColor = kHeaderBackgroundColor;
//    submitButtonObj.titleLabel.font = kVerifyingMessageTextFont;
//    [submitButtonObj setTitleColor:kVerifyingMessageTextColor forState:UIControlStateNormal];
    submitButtonObj.layer.cornerRadius = 3.0;
    
//    textFieldBackgroundLabalObj.layer.cornerRadius = 3.0;
    textFieldBackgroundLabalObj.layer.masksToBounds = YES;
    [textFieldBackgroundLabalObj.layer setCornerRadius:3.0];
    
    activityIndicatorBackgroundViewObj.hidden = TRUE;
    if (customLoader) {
        [customLoader removeFromSuperview];
        customLoader = nil;
    }
    if ([numberTextFieldObj.text length]<1) {
        [self enableSubmitButton:FALSE];
    }
    else{
        [self enableButtonAndTextField:TRUE];
    }
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSScanner *scanner = [NSScanner scannerWithString:string];
    BOOL isNumeric = [scanner scanInteger:NULL] && [scanner isAtEnd];
    NSString *finalNumberString = nil;
    if (isNumeric && [string length]>0) {
        if ([string length]>0) {
            finalNumberString = [NSString stringWithFormat:@"%@%@",textField.text,string];
        }
        
        if ([finalNumberString length]<=[_phoneDigitCount intValue]) {
            if (!submitButtonObj.isEnabled) {
                [self enableSubmitButton:TRUE];
            }
            return TRUE;
        }
        else{
            if (!submitButtonObj.isEnabled) {
                [self enableSubmitButton:TRUE];
            }
            return FALSE;
        }
        
    }
    else{
        if ([string length] == 0) {
            if ([numberTextFieldObj.text length] == 1) {
                [self enableSubmitButton:FALSE];
            }
            return TRUE;
        }
        
    }
    return FALSE;
}

-(IBAction)submitButtonTapped:(id)sender{
    
    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"SubmitNumber" forScreenName:@"FoneVerify"];
    NSScanner *scanner = [NSScanner scannerWithString:numberTextFieldObj.text];
    BOOL isNumeric = [scanner scanInteger:NULL] && [scanner isAtEnd];
    [numberTextFieldObj resignFirstResponder];
    if (!isNumeric || [numberTextFieldObj.text length]<[_phoneDigitCount intValue]) {
        
        U2AlertView *alertObj = [[U2AlertView alloc] init];
        [alertObj alertWithHeaderText:nil description:NSLocalizedString(@"Please submit a valid mobile number!",nil) leftButtonText:NSLocalizedString(@"CMP00356", nil) andRightButtonText:nil];
        
        [alertObj setU2AlertActionBlockForButton:^(int tagValue , id data){
            [numberTextFieldObj becomeFirstResponder];
        }];
        
        [alertObj show];
    }
    else{
        
        AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
        
        if(reachability.isReachable || reachability.isReachableViaWiFi || reachability.isReachableViaWWAN){
            
            NSString *alertMessage = [NSString stringWithFormat:NSLocalizedString(@"Is this your mobile number? \n(%@) %@", nil),countryCodeLabelObj.text,numberTextFieldObj.text];
            U2AlertView *alertObj = [[U2AlertView alloc] init];
            [alertObj alertWithHeaderText:nil description:alertMessage leftButtonText:NSLocalizedString(@"Edit",nil) andRightButtonText:NSLocalizedString(@"CMP00356", nil)];

            [alertObj setU2AlertActionBlockForButton:^(int tagValue , id data){
                NSLog(@"%d",tagValue);
                
                if (tagValue == 0)
                    [numberTextFieldObj becomeFirstResponder];
                else
                    [self submitAlertButtonTapped];
                
            }];

            
            
            [alertObj show];
        }
        else{
            [APP_Utilities displayAlertWithTitle:nil message:@"No internet connection\nPlease try again." withDelegate:self];
            //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:No_internet_connection forScreenName:@"FV"];
            [numberTextFieldObj resignFirstResponder];
        }
    }
}


-(void)submitAlertButtonTapped{
{
        //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Confirm_When_Number_Format_Is_Correct forScreenName:@"FV"];
        AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
        if (reachability.isReachable || reachability.isReachableViaWiFi || reachability.isReachableViaWWAN) {
//            if (!activityObj) {
//                activityObj = [[ActivityIndicatorWithTextAndTimer alloc] initWithFrame:CGRectMake(50, 225, 228, 136)];
//                [activityIndicatorBackgroundViewObj addSubview:activityObj];
//                activityIndicatorBackgroundViewObj.hidden = FALSE;
//            }
//            [activityObj startIndicator];
//            activityObj.hidden = FALSE;
//            activityObj.alpha = 1.0;
            if (!customLoader) {
                customLoader = [[WooLoader alloc]initWithFrame:wooLoaderContainerViewObj.frame];
                [customLoader customLoadingText:@""];
                [customLoader startAnimationOnView:wooLoaderContainerViewObj WithBackGround:NO];
            }
            
            
//            [self makeFoneVerifyCall];
            NSString *countrycode = [_countryCodeString length]>0?_countryCodeString:@"";
            [self pushToSmsVerificationScreenWithMobileNumber:numberTextFieldObj.text andCountryCode:countrycode withTimeOutTime:0];
            [self enableButtonAndTextField:FALSE];
        }
        else{
            [APP_Utilities displayAlertWithTitle:nil message:@"No internet connection\nPlease try again." withDelegate:self];
            //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:No_internet_connection forScreenName:@"FV"];
            [numberTextFieldObj resignFirstResponder];
            [self enableButtonAndTextField:TRUE];
        }
        
    }
}
-(void)makeFoneVerifyCall{
    //###$$$LUV change the country code value. It is hardcoced right now but it should be varaibles
    
    NSString *countrycode = [_countryCodeString length]>0?_countryCodeString:@"";
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    if (reachability.isReachable || reachability.isReachableViaWiFi || reachability.isReachableViaWWAN) {
//        NSString *urlString = [NSString stringWithFormat:@"%@%@?mobileNumber=%@&appId=%@&sourceType=IPHONE&isoCountryCode=%@&transactionID=",kFoneVerifyBaseURLV1,kFoneVerificationCallDIDAPI,numberTextFieldObj.text,kFoneVerifyAppID,countrycode];
        
        NSString *urlString = [NSString stringWithFormat:@"%@%@?msisdn=%@&appKey=%@&isoCountryCode=%@&customerId=%@",kFoneVerifyBaseURLV1_New,kFoneVerificationVoiceAPI_New,numberTextFieldObj.text,kFoneVerifyAppSecretKey,countrycode,kFoneVerifyCustomerId];
        WooRequest *wooRequestObj = [[WooRequest alloc]init];
        wooRequestObj.url =urlString;
        wooRequestObj.time =900;
        wooRequestObj.requestParams =nil;
        wooRequestObj.methodType =postRequest;
        wooRequestObj.numberOfRetries =kDoNotPutMeInFailedQueue;
        wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
        wooRequestObj.requestType = foneVerifyValidateNumber;
        
        [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
            NSLog(@"success :%d",success);
            NSLog(@"response :%@",response);
            NSLog(@"error : %@",error);
            NSLog(@"statusCode : %d",statusCode);
            
            if (requestType == foneVerifyValidateNumber) {
                if (statusCode == 200) {
                    
                    if ([[response objectForKey:@"errorMessage"] length]>0 && [[response objectForKey:@"responseCode"] length]>0) {
                        [self handleErrorForAPICalls:[[response objectForKey:@"responseCode"] intValue]];
                    }
                    else{
                        // Reading the verification id, mobile number, assignedDID from the json object
                        NSString *verificationIdentifier = [response objectForKey:@"verificationId"];
                        
                        NSString *mobileNumber = [response objectForKey:@"mobileNumber"];
                        
                        NSString *assignedDID = [response objectForKey:@"didAssigned"];
                        
                        NSNumber *timeOutNumber = [NSNumber numberWithInt:[[response objectForKey:@"timeout"] intValue]];
                        if (customLoader) {
                            [customLoader removeFromSuperview];
                            customLoader = nil;
                        }
                        
                        [self pushtoNextViewWithMobieNumber:mobileNumber countryCode:countryCodeLabelObj.text verificationId:verificationIdentifier andWithAssignedID:assignedDID withTimeOutTime:timeOutNumber];
                    }
                    
                }
                else{
                    [self handleErrorForAPICalls:statusCode];
                }
            }
            
        } shouldReachServerThroughQueue:YES];
    }
    else{
        [APP_Utilities displayAlertWithTitle:nil message:@"No internet connection\nPlease try again." withDelegate:self];
        [numberTextFieldObj resignFirstResponder];
    }
    
   
    
//    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType){
//        
//    }]; 
    
}
-(void)PushToAlmostThereScreenWithMobieNumber:(NSString *)mobileNumber countryCode:(NSString *)countryCode verificationId:(NSString *)verficationId withAssignedID:(NSString *)assignedId andAllowSmsVerification:(BOOL)isSmsVerificationAllowed withTimeOutTime:(NSNumber *)timeout{
    
    BOOL isCallScreenInNavigationStack = FALSE;
    for (id viewControllerObj in [self.navigationController viewControllers]) {
        if ([viewControllerObj isKindOfClass:[AlmostThereController class]]) {
            isCallScreenInNavigationStack = TRUE;
        }
    }
    if (!isCallScreenInNavigationStack) {
        AlmostThereController *almostThereVCObj = [self.storyboard instantiateViewControllerWithIdentifier:kAlmostThereControllerID];
        [almostThereVCObj setMobileNumber:mobileNumber];
        [almostThereVCObj setCountryCode:countryCode];
        [almostThereVCObj setCountryCodeString:_countryCodeString];
        [almostThereVCObj setVerificationID:verficationId];
        [almostThereVCObj setAssignedDID:assignedId];
        [almostThereVCObj setTimeOut:timeout];
        [almostThereVCObj setIsSmsVerficationAllowed:isSmsVerificationAllowed];
        [self.navigationController pushViewController:almostThereVCObj animated:YES];
        [self enableButtonAndTextField:TRUE];
    }
}

-(void)enableButtonAndTextField:(BOOL)isEnable{
    [self enableSubmitButton:isEnable];
    [self enableNumberTextField:isEnable];
}

-(void)enableSubmitButton:(BOOL)isEnable{
    submitButtonObj.userInteractionEnabled = isEnable;
    submitButtonObj.enabled = isEnable;
    submitButtonObj.backgroundColor = isEnable?kHeaderBackgroundColor:kHeaderBackgroundColor_Disabled;
}
-(void)enableNumberTextField:(BOOL)isEnable{
    numberTextFieldObj.userInteractionEnabled = isEnable;
    numberTextFieldObj.enabled = isEnable;
}
-(void)pushtoNextViewWithMobieNumber:(NSString *)mobileNumber countryCode:(NSString *)countryCode verificationId:(NSString *)verficationId andWithAssignedID:(NSString *)assignedId withTimeOutTime:(NSNumber *)timeout{
    switch (foneVerificationFlowValue) {
        case 1:
            NSLog(@"only Call ");
            [self PushToAlmostThereScreenWithMobieNumber:mobileNumber countryCode:countryCode verificationId:verficationId withAssignedID:assignedId andAllowSmsVerification:FALSE withTimeOutTime:timeout];
            break;
        case 2:
            NSLog(@"SMS Only");
            [self pushToSmsVerificationScreenWithMobileNumber:mobileNumber andCountryCode:countryCode withTimeOutTime:timeout];
            break;
        case 3:
            NSLog(@"Call and Sms both");
            [self PushToAlmostThereScreenWithMobieNumber:mobileNumber countryCode:countryCode verificationId:verficationId withAssignedID:assignedId andAllowSmsVerification:TRUE withTimeOutTime:timeout];
        default:
            break;
    }
    [self enableButtonAndTextField:TRUE];
}
-(void)pushToSmsVerificationScreenWithMobileNumber:(NSString *)mobileNumber andCountryCode:(NSString *)countryCode withTimeOutTime:(NSNumber *)timeout{
    
    if ((([[NSDate date] timeIntervalSince1970] - [[NSUserDefaults standardUserDefaults] doubleForKey:kDisableResendSMSButtonTime]) <86400) && [[NSUserDefaults standardUserDefaults] integerForKey:kNumberOfTimeResendButtonTappedForDay]>=390) {
        //this means number of resend has been clicked for three in one day, so we should not show the SMS screen as discussed with Ankit Sir on Tuesday, 25 November 2014.
        [APP_Utilities displayAlertWithTitle:nil message:@"All Woo servers are busy! \nPlease try again in a while." withDelegate:self];
    }
    else{
        BOOL isSMSScreenInNavigationStack = FALSE;
        for (id viewControllerObj in [self.navigationController viewControllers]) {
            if ([viewControllerObj isKindOfClass:[SMSCodeVerificationController class]]) {
                isSMSScreenInNavigationStack = TRUE;
            }
        }
        if (!isSMSScreenInNavigationStack) {
            SMSCodeVerificationController *smsCodeVerificationObj = [self.storyboard instantiateViewControllerWithIdentifier:kSMSCodeVerificationControllerID];
            [smsCodeVerificationObj setIsPushedFromCallVerficationScreen:FALSE];
            [smsCodeVerificationObj setMobileNumber:mobileNumber];
            [smsCodeVerificationObj setCountryCodeString:_countryCodeString];
            [smsCodeVerificationObj setCountryCode:countryCode];
            [smsCodeVerificationObj isPhoneVerifySuccess:^(BOOL isSuccess, NSString *phoneNumberVerified) {
                if (isSuccess) {
                    NSLog(@"phoneNumberVerified ;%@",phoneNumberVerified);
                    PhoneVerificatonBlock(isSuccess, phoneNumberVerified);
                }
                else{
                    NSLog(@"phone number not verified");
                }
            }];
            [self.navigationController pushViewController:smsCodeVerificationObj animated:YES];
        }
    }
    
}

-(void)handleErrorForAPICalls:(int)responseCode{
    [self enableButtonAndTextField:TRUE];
    if (customLoader) {
        [customLoader removeFromSuperview];
        customLoader = nil;
    }
    NSString *returnErrorResponse = @"";
    
    switch (responseCode) {
            
        case 1:
            
//            returnErrorResponse = @"INVALID_MSISDN";
            returnErrorResponse = NSLocalizedString(@"Please submit a valid mobile number!",nil);
            
            break;
            
        case 2:
            
            returnErrorResponse = @"INVALID_ISO_COUNTRY_CODE";
            
            break;
            
        case 3:
            
            returnErrorResponse = @"INVALID_VERIFICATION_ID";
            
            break;
            
        case 4:
            
            returnErrorResponse = @"INVALID_APPLICATION_ID";
            
            break;
            
        case 5:
            
            returnErrorResponse = @"INVALID_TRANSACTION_ID";
            
            break;
            
        case 6:
//            returnErrorResponse = @"DUPLICATE_TRANSACTION_ID";
            returnErrorResponse = NSLocalizedString(@"Mobile number already verified! Please enter another number.",nil);
            //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Mobile_number_already_verified forScreenName:@"FV"];
            break;
            
        case 7:
            ///###LUV : It should be the below commented code not the one that is working.
            if (foneVerificationFlowValue == 2 || foneVerificationFlowValue == 3) {
                [self pushToSmsVerificationScreenWithMobileNumber:numberTextFieldObj.text andCountryCode:countryCodeLabelObj.text withTimeOutTime:[NSNumber numberWithInt:45]];
            }
//            [self pushtoNextViewWithMobieNumber:numberTextFieldObj.text countryCode:countryCodeLabelObj.text verificationId:@"1234" andWithAssignedID:@"9971768507"];
            
//            returnErrorResponse = @"DID_POOL_EXHAUSTED";
            
            break;
            
        case 401:
            
            returnErrorResponse = @"NOT_AUTHORIZED";
            
            break;
            
        default:
            break;
    }
    
    if([returnErrorResponse length]>0){
        [APP_Utilities displayAlertWithTitle:nil message:returnErrorResponse withDelegate:self];
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)isPhoneVerifySuccess:(void(^)(BOOL isSuccess, NSString *phoneNumberVerified))verificationBlock{
    PhoneVerificatonBlock = verificationBlock;
}

@end
