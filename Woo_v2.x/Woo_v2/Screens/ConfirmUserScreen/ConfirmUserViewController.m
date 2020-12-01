//
//  ConfirmUserViewController.m
//  Woo_v2
//
//  Created by Deepak Gupta on 5/26/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "ConfirmUserViewController.h"
#import "SearchLocationViewController.h"
#import "NoInternetScreenView.h"
#import "LoginAPIClass.h"

@interface ConfirmUserViewController ()

@end

@implementation ConfirmUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    
    // new code
    
    if (![APP_Utilities reachable])
        [self loadingNoInternetScreenwithTag];
    else if (![[NSUserDefaults standardUserDefaults] boolForKey:kUserAlreadyRegistered])
        [self sendConfirmUserToServer];
    else {
       
        [self getUserCurrentLocation];
        
    }
    


}


-(void)getUserCurrentLocation{
    
    
    if(!locationManager){
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
    }
    
    if (![CLLocationManager locationServicesEnabled]) {
        [self askUserToEnableSystemLocationService];
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
        
        [self moveToSearchLocationScreen];
        
    }];
    
    
    [locationAlert addAction:okAction];
    [locationAlert addAction:cancelAction];
    [self presentViewController:locationAlert animated:YES completion:nil];
}



-(void)checkIfLocationChangedByUSer{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    if (![CLLocationManager locationServicesEnabled]) {
        [self moveToSearchLocationScreen];
    }
    
}


#pragma mark - CLLocationManager Delegate


//Delegate method when user's location udpates
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    NSLog(@"%@",locations);
    
    [locationManager stopUpdatingLocation]; //stop updating user location
    locationManager = nil;
    
    
    
    if ([locations lastObject]){
        
        CLLocation *locationObj = [locations lastObject];

        
        [[NSUserDefaults standardUserDefaults] setObject:[[NSDictionary alloc]initWithObjectsAndKeys:
                                                          [NSNumber numberWithDouble:locationObj.coordinate.latitude],kLastLocationLatitudeKey,
                                                          [NSNumber numberWithDouble:locationObj.coordinate.longitude],
                                                          kLastLocationLongitudeKey,
                                                          nil]
                                                  forKey:kUserLastLocationKey];
                                                          
  //@{kLastLocationLatitudeKey:[NSNumber numberWithDouble:locationObj.coordinate.latitude],kLastLocationLongitudeKey:[NSNumber numberWithDouble:locationObj.coordinate.longitude]} forKey:kUserLastLocationKey];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kLocationNeedsToBeUpdatedOnServer];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsPreferencesChanged];
        [[NSUserDefaults standardUserDefaults] synchronize];

        [[WooScreenManager sharedInstance] loadDrawerView];
    
    }else{
        [self moveToSearchLocationScreen];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [locationManager stopUpdatingLocation]; //stop updating user location
    locationManager = nil;
    
    [self moveToSearchLocationScreen];
}


#pragma mark - CLLocationManager Delegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    
    NSLog(@"manager >>>%@",manager);
    
    NSLog(@"State >>>> %d",status);
    
    
    if ([CLLocationManager locationServicesEnabled]) {
        
        if (status == kCLAuthorizationStatusDenied){
            
            [self moveToSearchLocationScreen];
            
        }else if (status == kCLAuthorizationStatusAuthorizedWhenInUse){
            
            [manager startUpdatingLocation];
            
        }else if (status == kCLAuthorizationStatusNotDetermined){
            
            [manager requestWhenInUseAuthorization];
            
        }
    }
    
}




#pragma mark - Move to Search Location Screen.
- (void)moveToSearchLocationScreen{
    
    SearchLocationViewController *search = [self.storyboard instantiateViewControllerWithIdentifier:kSearchLocationViewControllerID];
    
    [self presentViewController:search animated:YES completion:^{
        //        // TO DO
    }];
    

}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
  //  [self performSelector:@selector(addingWooLoader) withObject:nil afterDelay:0.1];
}





#pragma mark - loading third screen
- (void)loadingNoInternetScreenwithTag{
    
    NoInternetScreenView *noInternet = [[NoInternetScreenView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [noInternet setDelegate:self];
    [noInternet setShowLoader:YES];
    noInternet.tag = 10000;
    [self.view addSubview:noInternet];
    
}

#pragma mark - Refresh button clicked
- (void)refreshButtonClicked:(UIButton *)sender{
    
    if ([APP_Utilities reachable]){
        [self removeNoInternetScreenWithTag];
        [self sendConfirmUserToServer];
        
    }
    
}


- (void) removeNoInternetScreenWithTag{
    
    for (UIView *view in self.view.subviews)
        if (view.tag == 10000) // For Cancel Button Clicked
            [view removeFromSuperview];
    
}






#pragma mark - Adding Woo Loader
- (void)addingWooLoader{
    
    customLoader = [[WooLoader alloc]initWithFrame:self.view.frame];
    [customLoader customLoadingText:@"Confirming user...."];

    [customLoader startAnimationOnView:self.view WithBackGround:NO];
    
}


#pragma mark - Login Call To Server
// Method to send confirmation to server
-(void)sendConfirmUserToServer{
    
    //Send "user_confirmed" event to firebase once user confirmation call is fired from the client.
    [APP_DELEGATE sendFirebaseEvent:@"user_confirmed" andScreen:@""];
    [APP_DELEGATE logEventOnFacebook:@"User_Confirmed"];

    NSString *userWooID = [[NSUserDefaults standardUserDefaults] valueForKey:kWooUserId];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            userWooID,       @"wooId",
                            nil];
    
    NSString *aboutMeURL = [NSString stringWithFormat:@"%@%@?wooId=%@",kBaseURLV2_HTTPS,kSendConfirmUser,userWooID];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [manager setRequestSerializer:requestSerializer];
    
    [manager  POST:aboutMeURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"RESPONSE : %@",responseObject);
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserAlreadyRegistered];
            [[NSUserDefaults standardUserDefaults] synchronize];

            
            if (![[LoginModel sharedInstance] locationFound]){
                
                [self getUserCurrentLocation];

                
        }else
            [[WooScreenManager sharedInstance] loadDrawerView];

        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    } caching:GET_DATA_FROM_URL_ONLY andNumberOfRetries:3];
    
    
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
