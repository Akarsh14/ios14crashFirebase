//
//  AlmostThereController.m
//  Woo
//
//  Created by Umesh Mishra on 29/10/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "AlmostThereController.h"
#import "SMSCodeVerificationController.h"

@interface AlmostThereController ()

@end

@implementation AlmostThereController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSMutableDictionary *titleBarAttributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
    //
    [titleBarAttributes setValue:kHeaderTextFont forKey:NSFontAttributeName];
    [titleBarAttributes setValue:kHeaderTextRedColor forKey:NSForegroundColorAttributeName];
    
    [self.navigationController.navigationBar setTitleTextAttributes:titleBarAttributes];
    
    internetStatus = -2;
    self.title = NSLocalizedString(@"Almost there!", nil);
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFoneVerifyCallTimerExpires object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callTimerExpires) name:kFoneVerifyCallTimerExpires object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kInternetConnectionStatusChanged object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(internetConnectionStatusChanged:) name:kInternetConnectionStatusChanged object:nil];
    [self setCustomBackButton];
}
-(void)internetConnectionStatusChanged:(NSNotification*)notif{
    
    if (internetStatus == [notif.object intValue]) {
        internetStatus = [notif.object intValue];
        return;
    }
    internetStatus = [notif.object intValue];
    if (internetStatus == AFNetworkReachabilityStatusReachableViaWWAN || internetStatus == AFNetworkReachabilityStatusReachableViaWiFi) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(makeRequestForFetchingTheStatus) object:nil];
        [self makeRequestForFetchingTheStatus];
    }
    //    [self startMoniteringNetworkingFluctuations:internetStatus];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFoneVerifyCallTimerExpires object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (activityObj) {
        [activityObj invalidateTimer];
        [activityObj superview]?[activityObj removeFromSuperview]:nil;
        activityObj = nil;
    }
    amIVisibleToUser = FALSE;
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
    
//    headerTextLabelObj.font = kVerifyingMessageTextFont;
//    headerTextLabelObj.textColor = kVerifyingMessageTextColor;
//    
    verifyNumberButtonObj.backgroundColor = kHeaderBackgroundColor;
//    verifyNumberButtonObj.titleLabel.font = kVerifyingMessageTextFont;
    [verifyNumberButtonObj setTitleColor:kVerifyingMessageTextColor forState:UIControlStateNormal];
    verifyNumberButtonObj.layer.cornerRadius = 3.0;
    
    [verifyNumberButtonObj setTitle:[NSString stringWithFormat:NSLocalizedString(@"Call %@",nil),_assignedDID] forState:UIControlStateNormal];
    
    if (activityObj) {
        [activityObj superview]?[activityObj removeFromSuperview]:nil;
        [activityObj invalidateTimer];
        activityObj = nil;
    }
    
    if (!activityObj) {
        activityObj = [[ActivityIndicatorWithTextAndTimer alloc] initWithFrame:CGRectMake(0, 0, 228, 136)];
        [activityBackgroundView addSubview:activityObj];
    }
    [activityObj startIndicator];
    [activityObj showWaitingTextWithText:NSLocalizedString(@"Waiting...",nil)];
    if ([_timeOut intValue]>0) {
        ///####$$$$LUV
//        [activityObj StartIndicatorWithStartTime:30];
//        [activityObj StartIndicatorWithStartTime:35];
        [activityObj StartIndicatorWithStartTime:[_timeOut intValue]];
    }
    else{
        [activityObj StartIndicatorWithStartTime:90];
    }
    
    

    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFoneVerifyCallTimerExpires object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callTimerExpires) name:kFoneVerifyCallTimerExpires object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kInternetConnectionStatusChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(internetConnectionStatusChanged:) name:kInternetConnectionStatusChanged object:nil];
    
    NSLog(@"kNumberOfTimeResendButtonTappedForDay>>> :%ld",(long)[[NSUserDefaults standardUserDefaults] integerForKey:kNumberOfTimeResendButtonTappedForDay]);
    NSLog(@"time difference  :%f",([[NSDate date] timeIntervalSince1970] - [[NSUserDefaults standardUserDefaults] doubleForKey:kDisableResendSMSButtonTime]));
    if ((([[NSUserDefaults standardUserDefaults] doubleForKey:kDisableResendSMSButtonTime] - [[NSDate date] timeIntervalSince1970]) <86400) && [[NSUserDefaults standardUserDefaults] integerForKey:kNumberOfTimeResendButtonTappedForDay]>=3) {
        //this means number of resend has been clicked for three in one day, so we should not show the SMS screen as discussed with Ankit Sir on Tuesday, 25 November 2014.
        _isSmsVerficationAllowed = FALSE;
    }
    
    amIVisibleToUser = TRUE;
    [self initialiseView];
    [self makeRequestForFetchingTheStatus];
    
}

-(IBAction)callToVerifyNumberButtonTapped:(id)sender{
    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"GiveMissCall" forScreenName:@"FoneVerify"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",_assignedDID]]];
    //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Clicks_on_call_button_with_a_number forScreenName:@"FV"];
}


-(void)callTimerExpires{
    if (!_isSmsVerficationAllowed) {
        U2AlertView *alertObj= [[U2AlertView alloc] init];
        [alertObj alertWithHeaderText:NSLocalizedString(@"Oops!", nil) description:NSLocalizedString(@"We didn’t receive your call! \nWe will send you a verification code via SMS",nil) leftButtonText:NSLocalizedString(@"Cancel",nil) andRightButtonText:NSLocalizedString(@"CMP00356", nil)];
        
        [alertObj setU2AlertActionBlockForButton:^(int tagValue , id data){
            NSLog(@"%d",tagValue);
            
            if (tagValue == 1) {
                
                [self callTimerExpiresAlertTapped];
            
            }else{

                [self.navigationController popViewControllerAnimated:YES];

            }
            
        }];
        
        [alertObj show];
    }
    else{
        U2AlertView *alertObj= [[U2AlertView alloc] init];
        [alertObj alertWithHeaderText:NSLocalizedString(@"Oops!", nil) description:@"We didn't receive your call! \nPlease try again in a while." leftButtonText:NSLocalizedString(@"CMP00356", nil) andRightButtonText:nil];
        
        [alertObj setU2AlertActionBlockForButton:^(int tagValue , id data){
            NSLog(@"%d",tagValue);
            
            if (tagValue == 1) {
                
                [self callTimerExpiresAlertTapped];
                
            }else{
                
                [self.navigationController popViewControllerAnimated:YES];
                
            }
            
        }];

        
        
        [alertObj show];
//        [self.navigationController popViewControllerAnimated:YES];
    }
    
}


-(void)callTimerExpiresAlertTapped{
    
    //Show message screen
    BOOL isSMSScreenInNavigationStack = FALSE;
    for (id viewControllerObj in [self.navigationController viewControllers]) {
        if ([viewControllerObj isKindOfClass:[SMSCodeVerificationController class]]) {
            isSMSScreenInNavigationStack = TRUE;
        }
    }
    if (!isSMSScreenInNavigationStack) {
        SMSCodeVerificationController *smsCodeVerificationObj = [self.storyboard instantiateViewControllerWithIdentifier:kSMSCodeVerificationControllerID];
        [smsCodeVerificationObj setIsPushedFromCallVerficationScreen:TRUE];
        [smsCodeVerificationObj setMobileNumber:_mobileNumber];
        [smsCodeVerificationObj setCountryCode:_countryCode];
        [smsCodeVerificationObj setCountryCodeString:_countryCodeString];
        //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Clicks_on_yes_after_process_time_out_happens forScreenName:@"FV"];
        [self.navigationController pushViewController:smsCodeVerificationObj animated:YES];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)makeRequestForFetchingTheStatus{
    
    if (!amIVisibleToUser) {
        return;
    }
    
    
    
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    BOOL isNetworkReachable = (reachability.isReachable || reachability.isReachableViaWiFi || reachability.isReachableViaWWAN);
    if (!isNetworkReachable) {
        //        [APP_Utilities displayAlertWithTitle:NSLocalizedString(@"Oops!", nil) message:NSLocalizedString(@"No internet connection! Please try again.", nil) withDelegate:self];
        
        SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"Please check your internet connection",nil));
        return;
    }

    
    NSString *verificationIDURL = [NSString stringWithFormat:@"%@%@/%@",[NSString stringWithFormat:@"%@",kFoneVerifyBaseURLV1],kFoneVerificationVerifyOtpAPI,_verificationID];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =verificationIDURL;
    wooRequestObj.time =900;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =getRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = foneVerifyStatusCheck;
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        if (requestType == foneVerifyStatusCheck) {
            NSLog(@"response >>> makeRequestForFetchingTheStatus >>>> Almost there controller :%@",response);
            if (statusCode == 200) {
                NSString *verificationStatus = [response objectForKey:@"verificationStatus"];
                
                BOOL isVerificationIdEmpty = [_verificationID length]>0?FALSE:TRUE;
                
                if(isVerificationIdEmpty){
                    //                [[UAppDelegate appDelegate] handleErrorForAPICalls:3];
                }
                
                
                if([verificationStatus caseInsensitiveCompare:@"Verified"] == NSOrderedSame){
                    ;
                    [self sendVerifiedMobileDetailsToServer:_mobileNumber forWooID:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
                    
                }else if([verificationStatus caseInsensitiveCompare:@"Pending"] == NSOrderedSame){
                    [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(makeRequestForFetchingTheStatus) userInfo:nil repeats:NO];
                    
                }else {
                    [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(makeRequestForFetchingTheStatus) userInfo:nil repeats:NO];
                }
            }
            

            else if(statusCode==0 || statusCode==408){
                if (self->amIVisibleToUser) {
                    [APP_Utilities displayAlertWithTitle:NSLocalizedString(@"Oops!", nil) message:NSLocalizedString(@"No internet connection! Please try again.", nil) withDelegate:self];
                }
                
            }
            else if(statusCode==401 || statusCode==2 || statusCode==3 || statusCode==500){
                if (self->amIVisibleToUser) {
                    [APP_Utilities displayAlertWithTitle:NSLocalizedString(@"Oops!", nil) message:[error localizedDescription] withDelegate:self];
                }
            }
            else{
                if (self->amIVisibleToUser) {
                    [APP_Utilities displayAlertWithTitle:@"FoneVerify" message:@"Unable to reach server. Please try after some time." withDelegate:self];
                }
                
            }
        }
        
    } shouldReachServerThroughQueue:YES];
}
//"http://localhost:8080/woo/api/v1/foneverify/saveMsisdn? wooId=3421456&msisdn=9811534293&msisdnVerificationMode=

-(void)sendVerifiedMobileDetailsToServer:(NSString *)mobileNumber forWooID:(NSString *)wooId{
    
    if (!amIVisibleToUser) {
        return;
    }
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    if (reachability.isReachable || reachability.isReachableViaWiFi || reachability.isReachableViaWWAN) {
        NSString *verificationIDURL = [NSString stringWithFormat:@"%@%@?wooId=%@&msisdn=%@&msisdnVerificationMode=%@",[NSString stringWithFormat:@"%@",kBaseURLV1],kSaveVerifiedNumberOnServerAPI,wooId,_mobileNumber,@"CALLDID"];
        
        
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
                NSLog(@"response >>> sendVerifiedMobileDetailsToServer >>>> Almost there controller :%@",response);
                if (statusCode == 200 || statusCode == 302) {
                    
                    if (statusCode == 200) {
                        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kUserShouldGetNewProfilesAsIncentive];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                    if (amIVisibleToUser) {
                        U2AlertView *alertObj= [[U2AlertView alloc] init];
                        [alertObj alertWithHeaderText:NSLocalizedString(@"Verification Complete",nil) description:NSLocalizedString(@"CFV0021",nil) leftButtonText:NSLocalizedString(@"CMP00356", nil) andRightButtonText:nil];
                        
                        [alertObj setU2AlertActionBlockForButton:^(int tagValue , id data){
                            NSLog(@"%d",tagValue);
                            
                            [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kIsPreferencesChanged];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            [self.navigationController popToRootViewControllerAnimated:YES];

                            
                        }];

                        
                        [alertObj show];
                        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kIsVerifiedMsisdnKey];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kPhoneNumberVierfiedUpdateView object:nil];
                        //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Phone_verification_successful forScreenName:@"FV"];
                        
                    }
                }
                else if (statusCode == 208 || statusCode == 226){
                    if (amIVisibleToUser) {
                        //Already verified
                        U2AlertView *alertObj= [[U2AlertView alloc] init];
                        [alertObj alertWithHeaderText:NSLocalizedString(@"Oops!", nil) description:NSLocalizedString(@"Mobile number already verified! Please enter another number.",nil) leftButtonText:NSLocalizedString(@"CMP00356", nil) andRightButtonText:nil];
                        
                        [alertObj setU2AlertActionBlockForButton:^(int tagValue , id data){
                            NSLog(@"%d",tagValue);
                            [self backButtonTapped];

                        }];

                        
                        [alertObj show];
                        //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Mobile_number_already_verified forScreenName:@"FV"];
                    }
                }
                [[NSNotificationCenter defaultCenter] removeObserver:self name:kFoneVerifyCallTimerExpires object:nil];
                if (activityObj) {
                    [activityObj invalidateTimer];
                    [activityObj superview]?[activityObj removeFromSuperview]:nil;
                    activityObj = nil;
                }
            }
            
        } shouldReachServerThroughQueue:YES];

    }
    else{
        if (amIVisibleToUser) {
            [APP_Utilities displayAlertWithTitle:NSLocalizedString(@"Oops!", nil) message:NSLocalizedString(@"No internet connection! Please try again.", nil) withDelegate:self];
            //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:No_internet_connection forScreenName:@"FV"];
        }
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFoneVerifyCallTimerExpires object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kInternetConnectionStatusChanged object:nil];
    if (activityObj) {
        [activityObj invalidateTimer];
        [activityObj superview]?[activityObj removeFromSuperview]:nil;
        activityObj = nil;
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

@end
