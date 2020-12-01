//
//  LocationManager.m
//  Woo_v2
//
//  Created by Suparno Bose on 04/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "LocationManager.h"
#import "SearchLocationViewController.h"
#import "NoInternetScreenView.h"
#import "LoginAPIClass.h"
#import "DiscoverAPIClass.h"
#import "LoginModel.h"
#import "Woo_v2-Swift.h"

@interface LocationManager()<CLLocationManagerDelegate>{
    WooLoader               *customLoader;
    
    UIViewController        *parentViewController;
    
}

@property(nonatomic, strong)CLLocationManager *locationManager;
@end


@implementation LocationManager

- (instancetype)initWithParentViewController:(UIViewController*) parent
{
    self = [super init];
    if (self) {
        parentViewController = parent;
    }
    return self;
}

-(BOOL)isLocationAvailable{
    doNotChangeBlock = FALSE;
    hideSearchPredicationView = FALSE;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserLastLocationKey] &&
        [[NSUserDefaults standardUserDefaults] boolForKey:kUserAlreadyRegistered]){
        //[self getUserCurrentLocation];
        return YES;
    }
    return NO;
}

- (void)startGetLocationFlow{
    doNotChangeBlock = FALSE;
    hideSearchPredicationView = FALSE;
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kUserAlreadyRegistered])
        [self sendConfirmUserToServer];
    [self getUserCurrentLocation];
}

-(void)getUserCurrentLocation{
    if(!_locationManager){
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    
    if (![CLLocationManager locationServicesEnabled]) {
        [self askUserToEnableSystemLocationService];
    }
    else if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied &&
             ![LoginModel sharedInstance].locationFound){
        [self moveToSearchLocationScreen];
    }
    doNotChangeBlock = FALSE;
    hideSearchPredicationView = FALSE;
}

-(void)gettingUserCurrentLocationForDiscover{
    if(!_locationManager){
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    
    [_locationManager startUpdatingLocation];
    doNotChangeBlock = FALSE;
    hideSearchPredicationView = FALSE;
}

-(void)getUserCurrentLocation:(UserLocationFetched)block{
    if(!_locationManager){
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    
    [_locationManager startUpdatingLocation];
    doNotChangeBlock = FALSE;
    hideSearchPredicationView = FALSE;
    fetchedUserLocationCompleteBlock = block;
}

-(void)getUserCurrentLocation:(UserLocationFetched)block withoutChangingBlock:(BOOL)doNotchangeTab{
    if(!_locationManager){
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    
    [_locationManager startUpdatingLocation];
    doNotChangeBlock = doNotchangeTab;
    hideSearchPredicationView = doNotchangeTab;
    fetchedUserLocationCompleteBlock = block;
}

-(void)askUserToEnableSystemLocationService{
    
    UIAlertController *locationAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"System Location Service Disabled", @"System location service header") message:NSLocalizedString(@"Please enable location services. Go to Settings > Privacy > Location services > ON", @"System location service description text") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         
                                                         [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                         
                                                       
                                                         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkIfLocationChangedByUSer) name:UIApplicationWillEnterForegroundNotification object:nil];
                                                         
                                                     }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"cancel button text") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        if (![[NSUserDefaults standardUserDefaults] objectForKey:kUserLastLocationKey])
            [self moveToSearchLocationScreen];
        
    }];

    [locationAlert addAction:okAction];
    [locationAlert addAction:cancelAction];
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:locationAlert animated:YES completion:nil];
}

-(void)checkIfLocationChangedByUSer{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    if (![CLLocationManager locationServicesEnabled])
        if (![[NSUserDefaults standardUserDefaults] objectForKey:kUserLastLocationKey])
            [self moveToSearchLocationScreen];
}

- (BOOL)isWooAllowedForLocation{
    if ([CLLocationManager locationServicesEnabled]) {
        
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
            
            return false;
            
        }else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse){
            
            return true;
            
        }else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined){
            
            return false;
        }
    }
    return false;
}

-(BOOL)checkIfUserIsAuthorisedToUseUserLocationOrNot{
    doNotChangeBlock = FALSE;
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        
        return false;
        
    }else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse){
        
        return true;
        
    }else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined){
        
        return false;
    }
    return false;
}

#pragma mark - Move to Search Location Screen.
- (void)moveToSearchLocationScreen{
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kOpenPredictionLeastAtleastOnce]){
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"onboarding" bundle:nil];
        
        SearchLocationViewController *search = [storyboard instantiateViewControllerWithIdentifier:kSearchLocationViewControllerID];
        
        [parentViewController presentViewController:search animated:YES completion:nil];
    }
    
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
    
    NSString *loginDone = [NSString stringWithFormat:@"%@%@?wooId=%@",kBaseURLV3_HTTPS,kSendConfirmUser,userWooID];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [manager setRequestSerializer:requestSerializer];
    
    [manager  POST:loginDone parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {

        
        NSInteger statusCode = operation.response.statusCode;
        
        if (statusCode == 200) {
            
            [LoginModel sharedInstance].confirmed = true;
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserAlreadyRegistered];
        }
        else if (statusCode == 406){
            [LoginModel sharedInstance].confirmed = false;
            [LoginModel sharedInstance].isUserRegistered = false;
            [[WooScreenManager sharedInstance] loadLoginView];
            return;
        }
        
        
        NSLog(@"RESPONSE : %@",responseObject);
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            
            if (![[LoginModel sharedInstance] locationFound]){
                if (![CLLocationManager locationServicesEnabled]) {
                    
                    [self moveToSearchLocationScreen];
                    
                }else{
                    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
                        [self moveToSearchLocationScreen];
                    }
                }
//                [self getUserCurrentLocation];
                
            }else{
//                [[WooScreenManager sharedInstance] loadDrawerView];
//                [DiscoverAPIClass fetchDiscoverDataFromServer:NO AndPrefrence:NO AndCompletionBlock:nil];
            }
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@" Failure %@",[error localizedDescription]);
    } caching:GET_DATA_FROM_URL_ONLY andNumberOfRetries:3];
    
}

#pragma mark - CLLocationManager Delegate

//Delegate method when user's location udpates
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    NSLog(@"location update karni thi");
    [_locationManager stopUpdatingLocation]; //stop updating user location
    _locationManager = nil;

    if (fetchedUserLocationCompleteBlock) {
        if ([locations lastObject]) {
            CLLocation *locationObj = [locations lastObject];
            
            
            [[NSUserDefaults standardUserDefaults] setObject:[[NSDictionary alloc] initWithObjectsAndKeys:
                                                              [NSNumber numberWithDouble:locationObj.coordinate.latitude],kLastLocationLatitudeKey,
                                                              [NSNumber numberWithDouble:locationObj.coordinate.longitude],kLastLocationLongitudeKey,nil]
                                                      forKey:kUserLastLocationKey];
//  @{kLastLocationLatitudeKey:[NSNumber numberWithDouble:locationObj.coordinate.latitude],kLastLocationLongitudeKey:[NSNumber numberWithDouble:locationObj.coordinate.longitude]} forKey:kUserLastLocationKey];
            if ([[NSUserDefaults standardUserDefaults] boolForKey:kLocationNeedsToBeUpdatedOnServer] == false) {
                [[NSUserDefaults standardUserDefaults] setBool:true forKey:kLocationNeedsToBeUpdatedOnServer];
                if (!doNotChangeBlock) {
                    [[[WooScreenManager sharedInstance] oHomeViewController] moveToTab:1];
                }
                
            }
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsPreferencesChanged];
            
            [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:kLastLocationUpdatedTime];
            [[NSUserDefaults standardUserDefaults] synchronize];
            fetchedUserLocationCompleteBlock(TRUE, locationObj);
            fetchedUserLocationCompleteBlock = nil;
        }
        else{
            fetchedUserLocationCompleteBlock(FALSE, nil);
            fetchedUserLocationCompleteBlock = nil;
            
        }
        
    }
    else{
        if ([locations lastObject]){
            CLLocation *locationObj = [locations lastObject];
            [[NSUserDefaults standardUserDefaults] setObject:[[NSDictionary alloc] initWithObjectsAndKeys:
                                                     [NSNumber numberWithDouble:locationObj.coordinate.latitude],kLastLocationLatitudeKey,
                                                     [NSNumber numberWithDouble:locationObj.coordinate.longitude],kLastLocationLongitudeKey,nil]
                                                      forKey:kUserLastLocationKey];
//  @{kLastLocationLatitudeKey:[NSNumber numberWithDouble:locationObj.coordinate.latitude],kLastLocationLongitudeKey:[NSNumber numberWithDouble:locationObj.coordinate.longitude]} forKey:kUserLastLocationKey];
            if ([[NSUserDefaults standardUserDefaults] boolForKey:kLocationNeedsToBeUpdatedOnServer] == false) {
                [[NSUserDefaults standardUserDefaults] setBool:true forKey:kLocationNeedsToBeUpdatedOnServer];
                [[[WooScreenManager sharedInstance] oHomeViewController] moveToTab:1];
            }
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsPreferencesChanged];
            [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:kLastLocationUpdatedTime];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }else{
            if (![[NSUserDefaults standardUserDefaults] objectForKey:kUserLastLocationKey])
                [self moveToSearchLocationScreen];
        }
    }
    
}

- (void)makeLocationStringFromLatLongAndStartTheFlowForLocation:(CLLocation *)locationObj
{
    
    
//    NSDictionary *locationObject = [[NSUserDefaults standardUserDefaults] objectForKey:kUserLastLocationKey];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    
    //    NSString *lat = @"40.836318";
    //    NSString *lon = @"-74.123546";
    
    CLLocation *locationToBeUsedHere = [[CLLocation alloc]initWithLatitude:locationObj.coordinate.latitude longitude:locationObj.coordinate.longitude];
    
    
    
    //    CLLocation *locationToBeUsedHere = [[CLLocation alloc]initWithLatitude:[lat doubleValue] longitude:[lon doubleValue]];
    
    
    
    [geocoder reverseGeocodeLocation:locationToBeUsedHere completionHandler:^(NSArray *placemarks, NSError *error)
     {
         //[customLoader stopAnimation];

         if (error == nil && [placemarks count] > 0)
         {
             CLPlacemark *placemark;
             
             placemark = [placemarks lastObject];
             
             // strAdd -> take bydefault value nil
             NSString *strAdd = nil;
             
             if ([placemark.locality length] != 0)
             {
                 strAdd = placemark.locality;
             }
             
             if ([placemark.administrativeArea length] != 0)
             {
                 if ([strAdd length] != 0)
                     strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[placemark administrativeArea]];
                 else
                     strAdd = placemark.administrativeArea;
             }
             
             
             if ([strAdd length] > 0) {
                 
                 [DiscoverProfileCollection sharedInstance].myProfileData.location = strAdd;
                 
                 NSUserDefaults *userDefaultObj = [NSUserDefaults standardUserDefaults];
                 [userDefaultObj setObject:strAdd forKey:kLastLocationName];
                 
                 [DiscoverProfileCollection sharedInstance].myProfileData.location = strAdd;
                 
                 [[NSUserDefaults standardUserDefaults] setObject:@"GPS_settings" forKey:KSourceOfLocation];
                 [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kLocationNeedsToBeUpdatedOnServer];
                 [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsPreferencesChanged];
                 [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kOpenPredictionLeastAtleastOnce];
                 
                 [DiscoverProfileCollection sharedInstance].needToMakeDiscoverCallAsPreferencesHasBeenChanged = true;
                 
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 
             }
             
//             [customLoader stopAnimation];
             
         }
         
//         [customLoader stopAnimation];
         
     }];
}

- (void)makeLocationStringFromLatLongAndStartTheFlowForLocation:(CLLocation *)locationObj withCompletion:(void(^)(BOOL done, NSString *cityName))block{
    //    NSDictionary *locationObject = [[NSUserDefaults standardUserDefaults] objectForKey:kUserLastLocationKey];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    
    //    NSString *lat = @"40.836318";
    //    NSString *lon = @"-74.123546";
    
    CLLocation *locationToBeUsedHere = [[CLLocation alloc]initWithLatitude:locationObj.coordinate.latitude longitude:locationObj.coordinate.longitude];
    
    
    
    //    CLLocation *locationToBeUsedHere = [[CLLocation alloc]initWithLatitude:[lat doubleValue] longitude:[lon doubleValue]];
    
    
    
    [geocoder reverseGeocodeLocation:locationToBeUsedHere completionHandler:^(NSArray *placemarks, NSError *error)
     {
         //[customLoader stopAnimation];

         if (error == nil && [placemarks count] > 0)
         {
             CLPlacemark *placemark;
             
             placemark = [placemarks lastObject];
             
             // strAdd -> take bydefault value nil
             NSString *strAdd = nil;
             
             if ([placemark.locality length] != 0)
             {
                 strAdd = placemark.locality;
             }
             
             if ([placemark.administrativeArea length] != 0)
             {
                 if ([strAdd length] != 0)
                     strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[placemark administrativeArea]];
                 else
                     strAdd = placemark.administrativeArea;
             }
             
             
             if ([strAdd length] > 0) {
                 
                 if (![DiscoverProfileCollection sharedInstance].myProfileData) {
                     DiscoverProfileCollection.sharedInstance.myProfileData = [[MyProfileModel alloc] init];
                 }
                 
                 [DiscoverProfileCollection sharedInstance].myProfileData.location = strAdd;
                 
                 NSUserDefaults *userDefaultObj = [NSUserDefaults standardUserDefaults];
                 [userDefaultObj setObject:strAdd forKey:kLastLocationName];
                 
                 [[NSUserDefaults standardUserDefaults] setObject:@"GPS_settings" forKey:KSourceOfLocation];
                 [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kLocationNeedsToBeUpdatedOnServer];
                 [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsPreferencesChanged];
                 [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kOpenPredictionLeastAtleastOnce];
                 
                 [DiscoverProfileCollection sharedInstance].needToMakeDiscoverCallAsPreferencesHasBeenChanged = true;
                 
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 
             }
             block(TRUE,strAdd);
             
             //             [customLoader stopAnimation];
             
         }
         
         //         [customLoader stopAnimation];
         
     }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [manager stopUpdatingLocation]; //stop updating user location
    //manager = nil;
    
    if (!hideSearchPredicationView && ![LoginModel sharedInstance].locationFound) {
        [self moveToSearchLocationScreen];
    }
    else{
        if (fetchedUserLocationCompleteBlock){
            [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:kLastLocationUpdatedTime];
            [[NSUserDefaults standardUserDefaults] synchronize];
        fetchedUserLocationCompleteBlock(TRUE, nil);
        fetchedUserLocationCompleteBlock = nil;
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager
didFinishDeferredUpdatesWithError:(nullable NSError *)error{
    
}

#pragma mark - CLLocationManager Delegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    
    NSLog(@"manager >>>%@",manager);
    
    NSLog(@"State >>>> %d",status);
    
    
    if ([CLLocationManager locationServicesEnabled]) {
        
        if (status == kCLAuthorizationStatusDenied){
            if (![LoginModel sharedInstance].locationFound){
                [self moveToSearchLocationScreen];
            }
        }else if (status == kCLAuthorizationStatusAuthorizedWhenInUse){
            
            [manager startUpdatingLocation];
            
        }else if (status == kCLAuthorizationStatusNotDetermined){
            if (SYSTEM_VERSION_LESS_THAN(@"9.0")) {
                if (![LoginModel sharedInstance].locationFound){
                    [self moveToSearchLocationScreen];
                }
            }
            [manager requestWhenInUseAuthorization];
        }
    }
}

@end
