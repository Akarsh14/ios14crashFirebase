//
//  VerificationViewController.m
//  Woo
//
//  Created by Vaibhav Gautam on 11/02/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "VerificationViewController.h"
#import "VerificationView.h"
#import "YayYouAreInView.h"
#import "LogInAPIClass.h"

@interface VerificationViewController ()
{
    BOOL isLocationAlertTapped;
}
@end

@implementation VerificationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    progressedValue = 0.0f;
    fakeHeaderString = @"";
    fakeTextString = @"";
    self.navigationController.navigationBarHidden = YES;
    [self addVerificationView];
    isNoInternetShownWhenProgressWasStillInProgress = FALSE;
    pauseProgressOfView = FALSE;
    isUserDetailRecievedFromServer = TRUE;
    NSString *userWooID = [self.responseObj valueForKey:@"id"];
    
    verificationError = VERIFICATION_ERROR_NONE;
    
    if ([_responseObj objectForKey:kIsFakeDtoInLoginKey] && [[[_responseObj objectForKey:kIsFakeDtoInLoginKey] objectForKey:kIsFakeUserKey] boolValue]) {
        userVerificationState = FakeUser;
        fakeHeaderString = [[_responseObj objectForKey:kIsFakeDtoInLoginKey] objectForKey:kFakeHeaderKey];
        fakeTextString = [[_responseObj objectForKey:kIsFakeDtoInLoginKey] objectForKey:kFakeTextKey];
        moveToLoginScreenAutomaticallyIfUserIsFake = [[[_responseObj objectForKey:kIsFakeDtoInLoginKey] objectForKey:kReloginRequiredKey] boolValue];
    }
    else{
        BOOL wasPushedToInvite = [[NSUserDefaults standardUserDefaults] boolForKey:kIsPushedToInviteScreen];
        userVerificationState = [self getUserVerificationStateForUser:userWooID];
        
        if (userVerificationState == VerifiedUser && wasPushedToInvite) {
            isLocationAlertTapped = TRUE;
            [self pushToConfirmProfileScreen];
            return;
        }
        else{
            userVerificationState = UnverifiedUser;
        }
        
    }
    if (userVerificationState==FakeUser) {
        [self changeImageAndTextOnScreenForProgressState:kProgressState4_Value];
    }
    else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getVerificationState];
            [self showViewAccordingToCurrentVarificationState];
            
        });
    }
    isSendToConfirmScreenCallMade = FALSE;
    
    [self getUserCurrentLocation];

    isFakeResponseRecievedFromServer = FALSE;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDetector:) name:AFNetworkingReachabilityDidChangeNotification object:nil];

    // Do any additional setup after loading the view.
    
}



-(void)reachabilityDetector:(NSNotification*)notificationObj{

    NSDictionary *dict = [notificationObj userInfo];
    
    AFNetworkReachabilityStatus status = [[dict objectForKey:@"AFNetworkingReachabilityNotificationStatusItem"] intValue];
    isNoInternetShownWhenProgressWasStillInProgress = FALSE;
    switch (status) {
        case AFNetworkReachabilityStatusNotReachable:
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi:
        case AFNetworkReachabilityStatusReachableViaWWAN:{
            SHOW_TOAST_WITH_TEXT(@"We are resuming your profile check!");
            NSString *userWooID = [self.responseObj valueForKey:@"id"];
            [self isUserFake:userWooID withGender:nil andDob:nil];
            
        }
        break;
        default:
            break;
    }
}



-(void)addVerificationView{
    if (!verificationViewObj) {
        verificationViewObj = [[VerificationView alloc] initWithFrame:self.view.bounds];
        [verificationViewObj initialiseViewAccordingScreenHeight];
    }
    [self changeImageAndTextOnScreenForProgressState:kProgressState1_Value];
    [self.view addSubview:verificationViewObj];
}


/*
 Method to update progress bar automatically
 */
-(void)autoUpateProgressValue:(NSTimer *)timer{
    int progressVal = progressedValue*100;
    if (progressVal >= 100) {
        if (!isSendToConfirmScreenCallMade) {
            [self performSelector:@selector(pushToConfirmProfileScreen) withObject:nil afterDelay:0.001];
        }
        if (isLocationAlertTapped && [[NSUserDefaults standardUserDefaults] boolForKey:kNotificationTapped]) {
            if ([timer isValid]) {
                [timer invalidate];
                
            }
            timer = nil;
        }
    }
    
    if (progressVal>=kProgressState4_Value && (userVerificationState == UnverifiedUser)) {
        if(!isNoInternetShownWhenProgressWasStillInProgress){
            isNoInternetShownWhenProgressWasStillInProgress = TRUE;
            SHOW_TOAST_WITH_TEXT(@"It seems your internet connectivity is too low.");
        }
        return;
    }

    if ((progressVal<kProgressState5_Value-1 )|| (userVerificationState != UnverifiedUser)) {
        if (progressVal <100 && !pauseProgressOfView) {
            progressedValue +=0.001;
        }
        [self updateProgressBarValue:progressedValue];
    }
    if (progressVal == kProgressState2_Value-1) {
        pauseProgressOfView = !isFakeResponseRecievedFromServer;
    }
    
    if (progressVal > 89) {
        pauseProgressOfView = !isUserDetailRecievedFromServer;
    }

    if (progressVal == kProgressState2_Value) {
        
        [self makePushNotificationCallToServer];
        [self changeImageAndTextOnScreenForProgressState:kProgressState2_Value];
    }
    else if (progressVal == kProgressState3_Value){
        //making push notification call and changing the text message after 50% progress
        
//        [self performSelector:@selector(getUserCurrentLocation) withObject:nil afterDelay:4];
        [self changeImageAndTextOnScreenForProgressState:kProgressState3_Value];
    }
     else if (progressVal == kProgressState4_Value){
         [self changeImageAndTextOnScreenForProgressState:kProgressState4_Value];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Method to update the progress bar value.
-(void)updateProgressBarValue:(float)progressValue{
    NSLog(@"progress bar :%f",progressValue);
    if (verificationViewObj) {
        [verificationViewObj setProgressValue:progressValue];
    }
}

// Method to get the last verification state, state where the user left if the verification was not complete and set it to UserFakenessVerifyingState if no value for kLastVerificationState is not saved
-(void)getVerificationState{
    
    [self updateVerificationState:UserFakenessVerifyingState];
}

// Method to update the verification state.
-(void)updateVerificationState:(VerificationState)currentVerificationStateVal{

    NSUserDefaults *userDefaultObj = [NSUserDefaults standardUserDefaults];
    [userDefaultObj setValue:[NSString stringWithFormat:@"%d",currentVerificationStateVal] forKey:kLastVerificationState];
    [userDefaultObj synchronize];
    currentVerificationState = [[[NSUserDefaults standardUserDefaults] valueForKey:kLastVerificationState] intValue];

}
// Method to get user current location of the user

-(void)getUserCurrentLocation{
//    if(!locationManager){
//        locationManager = [[CLLocationManager alloc] init];
//        locationManager.delegate = self;
//        locationManager.distanceFilter = kCLDistanceFilterNone;
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//    }
//    
//    if ([APP_Utilities returnOSVersion]>=8.0) {
//        [locationManager requestWhenInUseAuthorization];
//    }
//    [locationManager startUpdatingLocation];
    [self startAutoupdateTimeWithMaxProgressValue:1.0f];
    [self makeLocationCallToServer:nil];    //making call to save user location to server
    isLocationAlertTapped = YES;
}


// Method to send user current location to server
-(void)makeLocationCallToServer:(CLLocation *)location{
//    updating current verification state
     [self updateVerificationState:LocationCallDoneState];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kIsRegisteredForLocation]) {
        //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Approvals_for_Location_Access_Permission];
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kIsRegisteredForLocation];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    //checking if locaiton call to server is made once as didupdate location method is called multiple times
    if (!isLocationCallMade) {
        isLocationCallMade = TRUE;
        if (self.responseObj) {
            NSString *userWooID = [self.responseObj valueForKey:@"id"];
//            NSDictionary *params = @{@"wooId":userWooID,
//                                     @"latitude":[NSString stringWithFormat:@"%f",location.coordinate.latitude],
//                                     @"longitude":[NSString stringWithFormat:@"%f",location.coordinate.longitude],
//                                     };
            //Base url has been changed from v1 to v2
            NSString *loginURL = [NSString stringWithFormat:@"%@%@?wooId=%@&latitude=%@&longitude=%@",kBaseURLV2,kUserLocationCall,userWooID,[NSString stringWithFormat:@"%f",0.0],[NSString stringWithFormat:@"%f",0.0]];
            
            WooRequest *wooRequestObj = [[WooRequest alloc]init];
            wooRequestObj.url =loginURL;
            wooRequestObj.time =900;
            wooRequestObj.requestParams = nil;
            wooRequestObj.methodType =postRequest;
            wooRequestObj.numberOfRetries =10;
            wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
            wooRequestObj.requestType = sendUserLocationToServer;
            
            [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
            
                if (requestType == sendUserLocationToServer) {
                    if (statusCode==401 || statusCode==402 || statusCode==500) {
                        [self handleErrorForResponseCode:statusCode];
                    }
                    
                    if (success) {
                        //send
                        if ([response objectForKey:kEnableInvite] && ![[response objectForKey:kEnableInvite] isKindOfClass:[NSNull class]] ) {
                            [AppLaunchModel sharedInstance].inviteOnlyEnabled = [[response objectForKey:kEnableInvite] boolValue];
                        }
                        if ([response objectForKey:kInviteBlockerEnableDisable] && ![[response objectForKey:kInviteBlockerEnableDisable] isKindOfClass:[NSNull class]] ) {
                            [AppLaunchModel sharedInstance].inviteBlockerEnableDisable = [[response objectForKey:kInviteBlockerEnableDisable] boolValue];
                        }

                    }
                    else{
                        //not send
                    }
                }
            } shouldReachServerThroughQueue:TRUE];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    NSLog(@"manager >>>%@",manager);
    
    NSLog(@"State >>>> %d",status);
    
    
}

//Delegate method when user's location udpates
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *locationObj = [locations lastObject];
    [locationManager stopUpdatingLocation]; //stop updating user location
    [self makeLocationCallToServer:locationObj];    //making call to save user location to server
    isLocationAlertTapped = YES;
}

// Added by Lokesh - Location Services
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
//    BOOL locationAllowed = [self isLocationServicesAvailable];
//    
//    BOOL appLocationFetchDisabled = [self isAuthorizedToUseLocationService];
    
//    if (locationAllowed==NO || appLocationFetchDisabled==NO)
//    {
//        [self performSelectorOnMainThread:@selector(showLocationDisabledAlert) withObject:nil waitUntilDone:NO];
//        
//        
//    }
//    updating verification state if location service is not available or user has not given location permission
    
    //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:No_Location_sharing_view];
    
    [locationManager stopUpdatingLocation];
    [self updateVerificationState:LocationCallDoneState];
    isLocationAlertTapped = YES;
    [self makeLocationCallToServer:nil];
//    [self performSelector:@selector(showViewAccordingToCurrentVarificationState) withObject:nil afterDelay:3.0f];
}

-( BOOL ) isIPhoneOS4Installed
{
	BOOL iPhoneOS4Installed = NO;
	
	NSString *sysVersion = [[UIDevice currentDevice] systemVersion]; //this should be 1.2 or 2.2.1 or 4.o etc
	
	if([[[sysVersion componentsSeparatedByString:@"."] objectAtIndex:0] intValue] >= 4)
    {
		iPhoneOS4Installed = YES;
    }
	return iPhoneOS4Installed;
}

// Added by Lokesh - Location Services
-(BOOL)isLocationServicesAvailable
{
	//Here,We assumed this application is only support iOS 4.0 onwards.
	return  [CLLocationManager locationServicesEnabled];
}

// Added by Lokesh - Location Services
-(BOOL)isAuthorizedToUseLocationService{
    return [CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorized?YES:NO;
}
// Method to send deviceToken to server
-(void)makePushNotificationCallToServer{
    [self updateVerificationState:PushNotificationCallDoneState];
    [self startAutoupdateTimeWithMaxProgressValue:1.0f];
    
    
    //Changed by Umesh on 18 Sept, 2014 as moved the push permission code to Utilities class
    [APP_Utilities getPushNotificationPermission];
    
//    UIApplication *application = [UIApplication sharedApplication];
//#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
//    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
//        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
//        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
//        [[UIApplication sharedApplication] registerForRemoteNotifications];
//    } else {
//        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
//    }
//#else
//    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
//#endif
    
    
}

// method to save fake user flag. If user is not valid/fake save a value and show error.
-(void)saveFakeUserFlag:(NSString *)userID isUserValid:(UserVerificationState)userState{

    //creating key to save woo user id. It will like WooID_<userWooId> eg for woo Id 1, it will be WooID_1
    NSString *keyText = [NSString stringWithFormat:@"WooID_%@",userID];
    NSUserDefaults *userDefaultObj = [NSUserDefaults standardUserDefaults];
    [userDefaultObj setValue:[NSString stringWithFormat:@"%d",userState] forKey:keyText];
    [userDefaultObj synchronize];
}
// method to get user's last verification state if no state is available return UnverifiedUser state
-(UserVerificationState )getUserVerificationStateForUser:(NSString *)userID{
    NSString *keyText = [NSString stringWithFormat:@"WooID_%@",userID];
    NSUserDefaults *userDefaultObj = [NSUserDefaults standardUserDefaults];
    UserVerificationState userCurrentState = [[userDefaultObj valueForKey:keyText] intValue];
    return userCurrentState;
}

// Method to check if user is fake.

-(BOOL)isUserFake:(NSString *)userID withGender:(NSString *)genderVal andDob:(NSString *)dobVal{
    if (self.responseObj) {
        isFakeResponseRecievedFromServer = FALSE;
        [LogInAPIClass isUserFake:userID withGender:genderVal andDob:dobVal AndCompletionBlock:^(BOOL success, id response , int statusCode , BOOL userChanged) {
            {
                if (success) {
                    isFakeResponseRecievedFromServer = TRUE;
                    if ([[response allKeys] containsObject:@"isFake"]) {
                        fakeHeaderString = [APP_Utilities validString:[response objectForKey:kFakeHeaderKey]];
                        fakeTextString = [APP_Utilities validString:[response objectForKey:kFakeTextKey]];
                        moveToLoginScreenAutomaticallyIfUserIsFake = [[response objectForKey:kReloginRequiredKey] boolValue];
                        
                        if ([response objectForKey:kFakeStatusCodeKey]) {
                            verificationError = [[response objectForKey:kFakeStatusCodeKey] intValue];
                        }
                        if (verificationError != VERIFICATION_ERROR_NONE) {
                            userVerificationState = FakeUser;
                        }
                        
                        if (userVerificationState == FakeUser) {
                            [self changeImageAndTextOnScreenForProgressState:kProgressState4_Value];
                        }
                        [self showAgeAndGenderPopupIfNeededAndPauseProgressView];
                    }
                    else{
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kNumberOfTotalRetries];
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTimeForNextShowLoginButton];
                        
                        //if user is not fake an array of images will be returned
                        self.userImages = [response objectForKey:kWooAlbumKey];
                        [self updateVerificationState:UserFakenessVerifiedState];
                        
                        [APP_DELEGATE.oMyProfileModel updateModel:response];
                        
                        if ([response objectForKey:@"work_experience"])
                            APP_DELEGATE.oMyProfileModel.workExperienceHistory = [NSArray arrayWithObject:[response objectForKey:@"work_experience"]];

                        
                        if ([response objectForKey:@"education"])
                            APP_DELEGATE.oMyProfileModel.educationHistory = [NSArray arrayWithObject:[response objectForKey:@"education"]];

                        if ([response objectForKey:@"likes"])
                            APP_DELEGATE.oMyProfileModel.interests = [response objectForKey:@"likes"];

                        
                        
                        
                        
                       // UserProfileModel *model = APP_DELEGATE.oMyProfileModel;
                        
                        if ([self.userImages count]>0) {
                            NSArray *filtered = [self.userImages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(profilePic == %d)", [@"1" boolValue]]];
                            NSDictionary *data = [filtered objectAtIndex:0];
                            [[NSUserDefaults standardUserDefaults] setObject:[data objectForKey:@"srcBig"] forKey:kWooProfilePicURL];
                            NSDictionary *dataDisctionary = nil;
                            if ([[data objectForKey:@"isFakePhoto"] isEqual:[NSNull null]] || [[NSString stringWithFormat:@"%@",[data objectForKey:@"isFakePhoto"]] isEqualToString:@"<null>"]) {
                                dataDisctionary = @{@"srcBig" : [data objectForKey:@"srcBig"],
                                                    @"srcBigHeight" : [data objectForKey:@"srcBigHeight"],
                                                    @"srcBigWidth" : [data objectForKey:@"srcBigWidth"],
                                                    @"profilePic" : [data objectForKey:@"profilePic"],
                                                    @"objectId" : [data objectForKey:@"objectId"]};
                            }
                            else{
                                dataDisctionary = data;
                            }
                            [[NSUserDefaults standardUserDefaults] setObject:dataDisctionary forKey:kProfileImageObj];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        }
                        else{
                            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kNeedtoShowUploadPhotoScreen];
                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kWooProfilePicURL];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        }
                        
                        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kUserAlreadyRegistered];
                        
                        [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:kProfileCompletenessScoreKey]
                                                                  forKey:kProfileCompletenessScoreKey];
                        [[NSUserDefaults standardUserDefaults]setObject:[response valueForKey:@"screen"]
                                                                 forKey:kYayYouAreInScreenType];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        isUserDetailRecievedFromServer = TRUE;
                        
                        //here should be userVerificationState = VerifiedUser; if other change it to VerifiedUser
                        userVerificationState = VerifiedUser;
                        
                        [self saveFakeUserFlag:userID isUserValid:userVerificationState];
                    }
                }
            }
        }
         ];
    }
    return TRUE;
}



-(void)fakeProfileFlowForUserID:(NSString *)userID{
   
    int numberOfTotalRetries = 0;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kNumberOfTotalRetries]) {
        numberOfTotalRetries = [[[NSUserDefaults standardUserDefaults] objectForKey:kNumberOfTotalRetries] intValue];
    }
    
    if (numberOfTotalRetries >= 2) {
        
        NSDate *now = [NSDate date];
        long long nowAsLong = [now timeIntervalSince1970];
        nowAsLong = nowAsLong + 86400;
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%lld",nowAsLong] forKey:kTimeForNextShowLoginButton];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kNumberOfTotalRetries]) {
        numberOfTotalRetries = numberOfTotalRetries+1;
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",numberOfTotalRetries] forKey:kNumberOfTotalRetries];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kNumberOfTotalRetries];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
//    SettingsController *settingObj = [[SettingsController alloc]init];
//    [settingObj performSelector:@selector(logoutAlertTapped:) withObject:@"1" afterDelay:10.0f];
//    [self performSelector:@selector(showLoginScreen) withObject:nil afterDelay:10.05f];
    locationManager = nil;
}


/*
 Method to show message and progress based on current verificationstate.
 It will push to ConfirmProfile view if user is current state is LocationCallDoneState
 */


-(void)showViewAccordingToCurrentVarificationState{
    
    switch (currentVerificationState) {
//            if user's fakeness is not verified
        case UserFakenessVerifyingState:{
//            update the progress of progress bar
//            progressedValue = 0.0f;
            [self updateProgressBarValue:progressedValue];
            
//            showing the first message to user
//            [self changeMessage:kFirstVerificationText];
            [self changeImageAndTextOnScreenForProgressState:kProgressState1_Value];
            
//            gettign the WooId of registered user
            NSString *userWooID = [self.responseObj valueForKey:@"id"];
            
//            checking the fakeness of user
            [self isUserFake:userWooID withGender:nil andDob:nil];
            
//            setting a timer to update the progress value of progress bar automatically with the maximum progress till 45%
            [self startAutoupdateTimeWithMaxProgressValue:0.45f];
            [self changeImageAndTextOnScreenForProgressState:kProgressState1_Value];
            isLocationCallMade = FALSE;
        }
            break;
        case UserFakenessVerifiedState:{
//            if user is verified and push notification call was not made
            progressedValue = (float)kProgressState2_Value/100;
            [self updateProgressBarValue:progressedValue];
            [self makePushNotificationCallToServer];
            [self changeImageAndTextOnScreenForProgressState:kProgressState2_Value];
        }
            break;
        case PushNotificationCallDoneState:{
//            if user is verified, push notification call was made but user current location is send to server
            progressedValue = (float)kProgressState3_Value/100;
            [self updateProgressBarValue:progressedValue];
//            [self getUserCurrentLocation];
            [self changeImageAndTextOnScreenForProgressState:kProgressState3_Value];
        }
            break;
        case LocationCallDoneState:{
//            if verfication process is complete, send user to Confirm profile screen
            [self performSelector:@selector(pushToConfirmProfileScreen) withObject:nil afterDelay:0.01];
        }
            break;
        default:
            break;
    }
}

// Method to create time to automatically update the progress bar, till the given maximum value. This method will invalidate previous timer,if any, and create a new one.
-(void)startAutoupdateTimeWithMaxProgressValue:(float)maxProgressValue{
    if ([timerObj isValid]) {
        [timerObj invalidate];
    }
    timerObj = nil;
    timerObj = [NSTimer scheduledTimerWithTimeInterval:0.009 target:self selector:@selector(autoUpateProgressValue:) userInfo:[NSString stringWithFormat:@"%f",1.0f] repeats:YES];
}

//Method to push user to Confirm profile screen
-(void)pushToConfirmProfileScreen{
    if (userVerificationState == VerifiedUser && isLocationAlertTapped) {
        
            NSUserDefaults *userObj = [NSUserDefaults standardUserDefaults];
            if (![userObj boolForKey:kNeedtoShowUploadPhotoScreen]) {
                [userObj setBool:YES forKey:kNeedtoShowYayScreen];
            }
            [userObj synchronize];
            isSendToConfirmScreenCallMade = TRUE;
            [self updateVerificationState:VerificationComplete];
            [self pushToDiscoverView];
            
            [userObj setBool:TRUE forKey:kIsLoginProcessCompleted];
            [userObj synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInSuccessfullyLoadDiscover object:nil];
            [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kNeedToShowUserFirstDayExperience];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    
        if ([timerObj isValid]) {
            [timerObj invalidate];
        }
        timerObj = nil;
}

-(void)pushToDiscoverView{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark StoryBoardMethods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:kPushToConfirmProfileViewContollerSegue]) {
        
//        ConfirmProfileViewController *confirmProfileViewControllerObj = [segue destinationViewController];
//        confirmProfileViewControllerObj.userImages =  nil; // set your properties here
    }
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

-(void)changeImageAndTextOnScreenForProgressState:(NSInteger)progressState{
    switch (progressState) {
        case kProgressState1_Value:
            
            //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Users_Navigated_to_Profile_Check_Screen_1];
//            [verificationViewObj setImage:[UIImage imageNamed:@"onboarding_eligi.png"]];
//            [verificationViewObj setHeading:[NSString stringWithFormat:NSLocalizedString(@"Hi %@!", nil),[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserName]] andMessage:NSLocalizedString(@"Cute name! Hang on while we run some quick checks", nil)];
            [verificationViewObj setViewForProgressStateVal:kProgressState1_Value];
            break;
        case kProgressState2_Value:
            
            //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Users_Navigated_to_Profile_Check_Screen_2];
//            [verificationViewObj setImage:[UIImage imageNamed:@"onboarding_know.png"]];
//            [verificationViewObj setHeading:[NSString stringWithFormat:NSLocalizedString(@"Hi %@!", nil),[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserName]] andMessage:NSLocalizedString(@"Getting to know you better!", nil)];
//            [verificationViewObj hideAppreciationLabel];
            [verificationViewObj setViewForProgressStateVal:kProgressState2_Value];
            break;
        case kProgressState3_Value:{
//            NSString *messageText = [NSString stringWithFormat:@"%@\n\n%@",NSLocalizedString(@"Almost there!", nil),NSLocalizedString(@"We will be asking you to allow notifications. Please tap OK so that we can tell you when you get a match or a new message.", nil)];
//            //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Users_Navigated_to_Profile_Check_Screen_3];
//            [verificationViewObj setImage:[UIImage imageNamed:@"onboarding_almost.png"]];
//            [verificationViewObj setHeading:[NSString stringWithFormat:NSLocalizedString(@"Hi %@!", nil),[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserName]] andMessage:messageText];
            [verificationViewObj setViewForProgressStateVal:kProgressState3_Value];
            pauseProgressOfView = !isLocationAlertTapped;
            break;
        }
        case kProgressState4_Value:{
            
            //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Users_Navigated_to_Profile_Check_Screen_4];
            if (userVerificationState == VerifiedUser) {
                //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Profiles_Approved];
//                [verificationViewObj setImage:[UIImage imageNamed:@"onboarding_welcome.png"]];
//                [verificationViewObj setHeading:NSLocalizedString(@"Welcome to Woo!", nil) andMessage:NSLocalizedString(@"Yay... you're through! Happy Wooing!", nil)];
                [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"YayYouarein" forScreenName:@"Approval"];
                [APP_DELEGATE sendSwrveEventWithEvent:@"Approval.YayYouarein" andScreen:@"Approval"];
            }
            else if (userVerificationState == FakeUser){
                [self updateProgressBarValue:0.0f];
                [verificationViewObj showErrorScreenForErrorVal:verificationError withHeaderText:fakeHeaderString andFakeReasonText:fakeTextString];
                [APP_DELEGATE makeAppsflyerFakeUserCall];
                [APP_DELEGATE sendSwrveEventWithEvent:@"Rejection.Rejection" andScreen:@"Rejection"];
                [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"Rejection" forScreenName:@"Rejection"];
                [self setFakeScreenText];
                [self fakeProfileFlowForUserID:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
                [self invalidateAutoUpdateTimer];
                
                if (moveToLoginScreenAutomaticallyIfUserIsFake) {
                    [self logoutWithoutRaisingAnyNotificaiton];
                    [self performSelector:@selector(popToLoginViewControllerWithAnimation) withObject:nil afterDelay:10.0f];
                    moveToLoginScreenAutomaticallyIfUserIsFake = FALSE;
                    
                }
                
                
            }
            else{
                
            }
        }
            break;
        default:
            break;
    }
}


-(void)popToLoginViewControllerWithAnimation{
    [self.navigationController popViewControllerAnimated:TRUE];
}

-(void)preloadImagesOfUserForUserID:(long long int)userID{
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =[NSString stringWithFormat:@"%@/user/fbAlbum/full?wooUserId=%lld",kBaseURLV7,userID];
    wooRequestObj.time =90;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =getRequest;
    wooRequestObj.numberOfRetries =1;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_AND_UPDATE_CACHE;
    wooRequestObj.requestType = getUserProfileImage;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        if (requestType == getUserProfileImage) {
            if(success){
                
//                [[Preload sharedPreload] preloadImagesOfPhotoSelectionViewFromArray:(NSArray *)response];
                
            }else{
                
            }
            
        }
    }  shouldReachServerThroughQueue:FALSE];
}

-(void)invalidateAutoUpdateTimer{
    if ([timerObj isValid]) {
        [timerObj invalidate];
        
    }
    timerObj = nil;
}

-(void)setFakeScreenText{
    
    
    if (verificationError == VERIFICATION_ERROR_RELATIONSHIP_NOT_ALLOWED) {
        [APP_DELEGATE sendSwrveEventWithEvent:@"Rejection.Relationship" andScreen:@"Rejection"];
        [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"Relationship" forScreenName:@"Rejection"];
        [verificationViewObj setErrorImage:[UIImage imageNamed:@"onboarding_single"]];
    }
    else{
        [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"Relationship" forScreenName:@"Rejection"];
        [APP_DELEGATE sendSwrveEventWithEvent:@"Rejection.UnderAge" andScreen:@"Rejection"];
        [verificationViewObj setErrorImage:[UIImage imageNamed:@"onboarding_age"]];
    }
    [verificationViewObj setErrorHeading:fakeHeaderString withFirstMessage:fakeTextString andSecondMessageText:nil];

    
//    
//    if ([_responseObj objectForKey:kIsFakeDtoInLoginKey] && [[[_responseObj objectForKey:kIsFakeDtoInLoginKey] objectForKey:kIsFakeUserKey] boolValue]) {
//        if (([[APP_Utilities validString:[[_responseObj objectForKey:kIsFakeDtoInLoginKey] objectForKey:kFakeHeaderKey]] length]>0) && ([[APP_Utilities validString:[[_responseObj objectForKey:kIsFakeDtoInLoginKey] objectForKey:kFakeTextKey]] length]>0)) {
//            [verificationViewObj setImage:[UIImage imageNamed:@"board_broke.png"]];
//            [verificationViewObj setHeading:[[_responseObj objectForKey:kIsFakeDtoInLoginKey] objectForKey:kFakeHeaderKey] andMessage:[APP_Utilities validString:[[_responseObj objectForKey:kIsFakeDtoInLoginKey] objectForKey:kFakeTextKey]]];
//        }
//    }
//    else{
//        if (([[APP_Utilities validString:fakeHeaderString] length]>0) && ([[APP_Utilities validString:fakeTextString] length]>0)) {
//            [verificationViewObj setImage:[UIImage imageNamed:@"board_broke.png"]];
////            [verificationViewObj setHeading:fakeHeaderString andMessage:fakeHeaderString];
//            [verificationViewObj setErrorHeading:fakeHeaderString withFirstMessage:fakeTextString andSecondMessageText:nil];
//        }
//        else{
//            [verificationViewObj setImage:[UIImage imageNamed:@"board_broke.png"]];
//            [verificationViewObj setErrorHeading:fakeHeaderString withFirstMessage:fakeTextString andSecondMessageText:nil];
////            [verificationViewObj setHeading:kFourthVerificationHeadingText_Negative andMessage:kFourthVerificationText_Negative];
//        }
//    }
}

//-(void)getErrorCodeForVerification:(NSDictionary *)responseDict{
//    
//}

-(void)showAgeAndGenderPopupIfNeededAndPauseProgressView{
    
    
    switch (verificationError) {
        case VERIFICATION_ERROR_GENDER_MISSING:
        case VERIFICATION_ERROR_DOB_MISSING:
        case VERIFICATION_ERROR_DOB_AND_GENDER_MISSING:
            //dob and gender both are missing
            [self initialiseErrorPopView];
            pauseProgressOfView = TRUE;
            break;
            
        default:
            break;
    }
}

-(void)initialiseErrorPopView{
    if (!errorPopUpViewObj) {
        errorPopUpViewObj = [[ErrorPopUpView alloc] initWithFrame:self.view.bounds];
    }
    errorPopUpViewObj.delegate =self;
    errorPopUpViewObj.selectorForOkButtonTapped = @selector(okButtonTapped);
    [errorPopUpViewObj setVerificationErrorObj:verificationError];
    [self.view addSubview:errorPopUpViewObj];
    [errorPopUpViewObj setUpViewAccordingToError];
}
-(void)okButtonTapped{
    
     NSString *userWooID = [self.responseObj valueForKey:@"id"];
    pauseProgressOfView = FALSE;
    progressedValue = 0.0;
    switch (verificationError) {
        case VERIFICATION_ERROR_DOB_MISSING:{
            //check only if dob is selected or not
            [self isUserFake:userWooID withGender:nil andDob:errorPopUpViewObj.dobString];
        }
        break;
        case VERIFICATION_ERROR_GENDER_MISSING:{
            //check only if gender is selected or not
            NSString *genderVal = (errorPopUpViewObj.selectedGender == MALE)?@"MALE":@"FEMALE";
            [self isUserFake:userWooID withGender:genderVal andDob:nil];
        }
        break;
        default:{
            //check if both gender and dob is selected
            NSString *genderVal = (errorPopUpViewObj.selectedGender == MALE)?@"MALE":@"FEMALE";
            [self isUserFake:userWooID withGender:genderVal andDob:errorPopUpViewObj.dobString];
        }
        break;
    }

    [errorPopUpViewObj removeFromSuperview];
    errorPopUpViewObj = nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
