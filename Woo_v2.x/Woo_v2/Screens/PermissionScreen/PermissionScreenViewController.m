//
//  PermissionScreenViewController.m
//  Woo_v2
//
//  Created by Deepak Gupta on 5/17/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "PermissionScreenViewController.h"
#import "IntentScreenViewController.h"
#import "NoInternetScreenView.h"
#import "VPImageCropperViewController.h"
#import "LogInAPIClass.h"
#import "Woo_v2-Swift.h"

@interface PermissionScreenViewController ()<VPImageCropperDelegate>

{
  //  BOOL boatScreenHasBeenPushed;
}

@property (nonatomic, strong)PermissionPopupScreen *popupObject;

@end

@implementation PermissionScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
//
//    // Try to use the newer isRegisteredForRemoteNotifications otherwise use the enabledRemoteNotificationTypes.
//    if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
//    {
//        [self getUserCurrentLocation];
//    }

    
    
  //  boatScreenHasBeenPushed = false;
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:KAPNS_PERMISSION] boolValue]) {
        [self getUserCurrentLocation];
    }else{

        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:KAPNS_PERMISSION_ASKED];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notificationCallBack)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:[UIApplication sharedApplication]];
        
        [APP_Utilities getPushNotificationPermission];   // APNS permission has not been given
        [self showOrHidePopupMessage:true ForPermissionType:true];
    }
    
//    if([APP_Utilities checkIfPushNotificationIsEnabled] || [[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) // APNS permission has already been given
//            [self getUserCurrentLocation];
//        else {
//           
//            [[NSNotificationCenter defaultCenter] addObserver:self
//                                                     selector:@selector(notificationCallBack)
//                                                         name:UIApplicationDidBecomeActiveNotification
//                                                       object:[UIApplication sharedApplication]];
//
//            [APP_Utilities getPushNotificationPermission];   // APNS permission has not been given
//
//        }
    
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    [self performSelector:@selector(addingWooLoader) withObject:nil afterDelay:0.1];
    if ([[LoginModel sharedInstance].gender isEqualToString:@"FEMALE"]){
        [self performSelector:@selector(addOnBoardingNameView) withObject:nil afterDelay:0.2];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:YES];
    [self resetTimer];
}

- (void)notificationCallBack{
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KAPNS_PERMISSION];
    [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:KAPNS_PERMISSION_ASKED];
    
    [self showOrHidePopupMessage:false ForPermissionType:true];
    
    if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
        //user tapped "Allow"
        NSLog(@"ALLOW Notification");
        
        [self getUserCurrentLocation];
    }
    else{
        //user tapped "Don't Allow"
        NSLog(@"Don't Allow Notification");
        
        [self getUserCurrentLocation];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
}

- (void)showOrHidePopupMessage:(BOOL)showOrHide ForPermissionType:(BOOL)type{
    if (showOrHide == true) {
        if (_popupObject == nil) {
            _popupObject = [PermissionPopupScreen loadViewFromNibWithFrame:CGRectMake(SCREEN_WIDTH/2 - 125, SCREEN_HEIGHT/2 + 100, 250, 90)];
            [self.view addSubview:_popupObject];
            [self.view bringSubviewToFront:_popupObject];
        }
        if (type == true) {
            [_popupObject setTextForPopupLabelWithTextString:@"We will inform you as soon as someone likes you on Woo"];
        }
        else{
            [_popupObject setTextForPopupLabelWithTextString:@"In order to show you profiles around you, we need to know where you are"];
        }
        _popupObject.alpha = 0;
        
        [UIView animateWithDuration:1.5 delay:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            _popupObject.alpha = 1;
        } completion:nil];
    }
    else{
        [UIView animateWithDuration:0.5 animations:^{
            _popupObject.alpha = 0;
            _popupObject = nil;
        }];
    }
}


#pragma mark - Adding Woo Loader
- (void)addingWooLoader{
    
    if (!customLoader)
        customLoader = [[WooLoader alloc]initWithFrame:CGRectMake(viewLoaderBase.frame.origin.x, viewLoaderBase.frame.origin.y, SCREEN_WIDTH, viewLoaderBase.frame.size.height)];
    
    
    if ([[LoginModel sharedInstance].gender isEqualToString:@"FEMALE"]){
        [customLoader customLoadingText:NSLocalizedString(@"Let's build your profile", @"Let's build your profile")];
    }
    else{
    [customLoader customLoadingText:NSLocalizedString(@"Setting up Woo for you", @"Setting up Woo for you")];
    }
    customLoader.shouldShowWooLoader = YES;
    [customLoader startAnimationOnView:viewLoaderBase WithBackGround:NO];
    
}

- (void)addOnBoardingNameView{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"FemaleOnboardingNameView"
                                                      owner:self
                                                    options:nil];
    
    FemaleOnboardingNameView* nameView = [nibViews lastObject];
    [nameView setFrame:CGRectMake(0, 50, [UIScreen mainScreen].bounds.size.width, 150)];
    [nameView.nameLabel setText:[NSString stringWithFormat:@"Hi %@!",[[LoginModel sharedInstance] firstName]]];
    [viewLoaderBase addSubview:nameView];
}

-(void)getUserCurrentLocation{
    
    if (_locationManager) {
        _locationManager = nil;
    }
    
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
    if (![CLLocationManager locationServicesEnabled]) {
        [self askUserToEnableSystemLocationService];
    }else{
        [_locationManager startUpdatingLocation];
    }
}


-(void)askUserToEnableSystemLocationService{
    
    UIAlertController *locationAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"System Location Service Disabled", @"System location service header") message:NSLocalizedString(@"Please enable location services. Go to Settings > Privacy > Location services > ON", @"System location service description text") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         
                                                        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                         
                                                         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkIfLocationChangedByUSer) name:UIApplicationWillEnterForegroundNotification object:nil];
                                                     }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"cancel button text") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self moveToBoatScreen];
    }];
    
    [locationAlert addAction:okAction];
    [locationAlert addAction:cancelAction];
    [self presentViewController:locationAlert animated:YES completion:nil];
}

- (void) moveToBoatScreen{
    
    [_locationManager stopUpdatingLocation];
    _locationManager = nil;
    
    [self resetTimer];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self moveToNextScreenAndNewUserNoPicShown:false];
    });
}

-(void)checkIfLocationChangedByUSer{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    if (![CLLocationManager locationServicesEnabled]) {
        [self moveToBoatScreen];
    }else{
       // [_locationManager startUpdatingLocation];
        
        
        [self getUserCurrentLocation];
    }
}

-(void)askUserToEnableWooLocation{
    
    UIAlertController *locationAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Allow Woo to use location", @"location service header") message:NSLocalizedString(@"To Enable, Please go to Settings, Privacy and turn on Location Service for Woo.", @"location service text") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                         
                                                     }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"cancel button text") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    //    if (boatScreenHasBeenPushed == false) {
   //     if ([[NSUserDefaults standardUserDefaults] boolForKey:kBoatScreenPushed] == false){
            
     //       [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kBoatScreenPushed];

//        boatScreenHasBeenPushed = true;
            [self moveToBoatScreen];
       // }
    }];
    
    
    [locationAlert addAction:okAction];
    [locationAlert addAction:cancelAction];
    [self presentViewController:locationAlert animated:YES completion:nil];
    
}

#pragma mark - CLLocationManager Delegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    
    NSLog(@"manager >>>%@",manager);
    
    NSLog(@"State >>>> %d",status);
    
    
    if ([CLLocationManager locationServicesEnabled]) {
        
        if (status == kCLAuthorizationStatusDenied){
            
//            [self askUserToEnableWooLocation];
 //           if (boatScreenHasBeenPushed == false) {
   //         if ([[NSUserDefaults standardUserDefaults] boolForKey:kBoatScreenPushed] == false){
                
     //           [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kBoatScreenPushed];

//            boatScreenHasBeenPushed = true;
                [self moveToBoatScreen];
       //     }
            
        }else if (status == kCLAuthorizationStatusAuthorizedWhenInUse){
            
            [self resetTimer];

            myTimer =     [NSTimer scheduledTimerWithTimeInterval:[[LoginModel sharedInstance] locationTimeout]                  //8.0
                                                           target:self
                                                         selector:@selector(moveToBoatScreen)
                                                         userInfo:nil
                                                          repeats:NO];

            
            [manager startUpdatingLocation];
            
        }else if (status == kCLAuthorizationStatusNotDetermined){
            
            [manager requestWhenInUseAuthorization];
            [self showOrHidePopupMessage:true ForPermissionType:false];
        }
    }
    
}


- (void)resetTimer{
    
    if (myTimer) {
        
        [myTimer invalidate];
        myTimer = nil;
        
    }

}

//Delegate method when user's location udpates
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    NSLog(@"%@",locations);
    
    [self resetTimer];

    [self showOrHidePopupMessage:false ForPermissionType:false];
    
    [_locationManager stopUpdatingLocation]; //stop updating user location
    _locationManager = nil;
    
    arrLocation = locations;
    if ([locations lastObject]){
        // Saving User Location
        CLLocation *foundLocation = [locations lastObject];
        [[NSUserDefaults standardUserDefaults] setObject:@{kLastLocationLatitudeKey:[NSNumber numberWithDouble:foundLocation.coordinate.latitude],kLastLocationLongitudeKey:[NSNumber numberWithDouble:foundLocation.coordinate.longitude]} forKey:kUserLastLocationKey];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:kLocationNeedsToBeUpdatedOnServer];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self makeRegistrationCallToServer];
    
    }else{
     //   if (boatScreenHasBeenPushed == false) {
      //  if ([[NSUserDefaults standardUserDefaults] boolForKey:kBoatScreenPushed] == false){
            
        //    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kBoatScreenPushed];

//        boatScreenHasBeenPushed = true;
        
            [self moveToBoatScreen];
       // }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{

    [self showOrHidePopupMessage:false ForPermissionType:false];
    
//    if ([LoginModel sharedInstance].isAlternateLogin){
        [self moveToNextScreenAndNewUserNoPicShown:false];
//    }
//    else{
//        [self moveToBoatScreen];
//    }
    
    
}

#pragma mark - Login Call To Server
-(void)makeRegistrationCallToServer {
    
    if (![APP_Utilities reachable]){
        [self loadingThirdScreenWhenNoInternet];
        return;
    }
    
    [self resetScreen];
//    if ([LoginModel sharedInstance].isAlternateLogin){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self moveToNextScreenAndNewUserNoPicShown:false];
        });
//    }
//    else{
//        if ([LoginModel sharedInstance].age == 0 || [[LoginModel sharedInstance].gender isEqualToString:@"UNKNOWN"]){
//            APP_DELEGATE.onBaordingPageNumber++;
//            [self performSegueWithIdentifier:kAgeGenderControllerID sender:nil];
//        }
//        else{
//            [LogInAPIClass makeRegistrationCallwithCompletionBlock:^(BOOL sucess, id response, int statusCode, BOOL isUserChanged) {
//                if (statusCode == 408 || statusCode == 0){  //            Request Timeout
//                    [self loadingThirdScreenWhenNoInternet];
//                    return ;
//                }
//
//                if (sucess) {
//
//                    [self calculateTotalNumberOfOnboardingPages:response];
//                    [self moveToBoatScreen];
//                }
//            }];
//        }
//    }
}

- (void) moveToOnBoardingScreensBasedOnData{
    UIStoryboard *onBoardingStoryboard = [UIStoryboard storyboardWithName:@"onboarding" bundle:nil];
    OnBoardingNameViewController *onBoardingName = [onBoardingStoryboard instantiateViewControllerWithIdentifier:@"OnBoardingNameViewController"];
    [self.navigationController pushViewController:onBoardingName animated:true];

}

#pragma mark - Calculate total number of pages
- (void) calculateTotalNumberOfOnboardingPages:(NSDictionary *)response{
    
    APP_DELEGATE.totalOnboardingPages = 0;

    if ([response objectForKey:kIntentDto]) {
        APP_DELEGATE.totalOnboardingPages++;
    }
    
    if (([response objectForKey:kuserRelationshipTagsAvailable] && [[response objectForKey:kuserRelationshipTagsAvailable] boolValue] == false) || ([response objectForKey:kuserLifestyleTagsAvailable] && [[response objectForKey:kuserLifestyleTagsAvailable] boolValue] == false)) {
        APP_DELEGATE.totalOnboardingPages++;
    }
    
    if ([response objectForKey:kUserTagAvailable] && [[response objectForKey:kUserTagAvailable] boolValue] == false) {       //changed condition as if the value is true user should not see the tag screen
        APP_DELEGATE.totalOnboardingPages++;
    }
    
    if ([LoginModel sharedInstance].age == 0 || [[LoginModel sharedInstance].gender isEqualToString:@"UNKNOWN"]) {
        APP_DELEGATE.totalOnboardingPages++;
    }
    
    if([[LoginModel sharedInstance] personalQuoteText]){
        APP_DELEGATE.totalOnboardingPages++;
    }
    
    if ([[LoginModel sharedInstance].gender isEqualToString:@"FEMALE"] && [LoginModel sharedInstance].profilePicUrl != nil){
        APP_DELEGATE.totalOnboardingPages++;
    }
    
    NSLog(@"TOTAL NUMBER OF ONBOARDING PAGES %d",APP_DELEGATE.totalOnboardingPages);
    
}

#pragma mark - Move to next screen
- (void)moveToNextScreenAndNewUserNoPicShown:(BOOL)newUserNoPicHasBeenShown{
    [self resetTimer];
    BOOL newUserNoPicOn = LoginModel.sharedInstance.isNewUserNoPicScreenOn;
    if (newUserNoPicHasBeenShown){
        newUserNoPicOn = false;
    }
    else if ([LoginModel sharedInstance].profilePicUrl != nil){
        newUserNoPicOn = false;
    }

    if ([LoginModel sharedInstance].isAlternateLogin){
        if(newUserNoPicOn){ // new user no pic
            
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
                   // [self performSegueWithIdentifier:kTagScreenControllerID sender:nil];
                    
                    WizardTagsViewController *wizardTagsVC = [[WizardTagsViewController alloc] initWithNibName:@"WizardTagsViewController" bundle:nil];
                    [wizardTagsVC setIsUsedOutOfWizard:true];
                    [wizardTagsVC setIsPartOfOnboarding:true];
                    [self.navigationController pushViewController:wizardTagsVC animated:true];
                }
                else{
                    [self moveToOnBoardingScreensBasedOnData];
                }
            }
            else if([[LoginModel sharedInstance] aboutMetext] && [[LoginModel sharedInstance] aboutMeDefault]){ // Showing About Me Screen.
                if ([LoginModel sharedInstance].isUserRegistered){
                    APP_DELEGATE.onBaordingPageNumber++;
                    [self performSegueWithIdentifier:kAboutMeScreenControllerID sender:nil];
                }
                else{
                    [self moveToOnBoardingScreensBasedOnData];
                }
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


#pragma mark - VPIImageCropper Delegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(NSDictionary *)editedImageData{
    
    if ([LoginModel sharedInstance].isAlternateLogin){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self moveToNextScreenAndNewUserNoPicShown:true];
        });
    }
    else{
//    [cropperViewController.navigationController popViewControllerAnimated:NO];
//    [APP_Utilities sendToDiscover];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self moveToNextScreenAndNewUserNoPicShown:true];
        });
    }

}
- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController{
    
    if ([LoginModel sharedInstance].isAlternateLogin){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
               [self moveToNextScreenAndNewUserNoPicShown:true];
        });
    }
    else{
//        [cropperViewController.navigationController popViewControllerAnimated:NO];
//        [APP_Utilities sendToDiscover];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
               [self moveToNextScreenAndNewUserNoPicShown:true];
        });
    }
}



#pragma mark - loading third screen
- (void)loadingThirdScreenWhenNoInternet{
    
    [self resetScreen];
    NoInternetScreenView *noInternet = [[NoInternetScreenView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [noInternet setDelegate:self];
    noInternet.tag = 10000;
    [noInternet setShowLoader:YES];
    [self.view addSubview:noInternet];
    
    [customLoader customLoadingText:@"No internet connection"];
    
}


#pragma mark - Reset Screen to Loading
- (void)resetScreen{
    
    [customLoader customLoadingText:NSLocalizedString(@"Setting up Woo for you", @"Setting up Woo for you")];

    for (UIView *view in self.view.subviews) {
        if (view.tag == 10000 ) {
            [view removeFromSuperview];
        }
    }
}


#pragma mark - Refresh button clicked
- (void)refreshButtonClicked:(UIButton *)sender{
        
    [self makeRegistrationCallToServer];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     NSLog(@"self navigation controller %@",self.navigationController);
     NSLog(@"self navigation controller views :%@",self.navigationController.viewControllers);
     if ([segue.identifier isEqualToString:kBoatScreenControllerID]) {
         NSLog(@"destination segue :%@",segue.destinationViewController);
         NSLog(@"source view :%@",segue.sourceViewController);
         NSLog(@"navigation controller :%@",self.navigationController);
     }
 }
 

@end
