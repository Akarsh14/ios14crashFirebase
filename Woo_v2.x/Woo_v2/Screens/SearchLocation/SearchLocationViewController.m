//
//  SearchLocationViewController.m
//  Woo_v2
//
//  Created by Deepak Gupta on 2/24/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "SearchLocationViewController.h"
#import "SearchLocationCell.h"
#import "SearchPredictionCellTableViewCell.h"

#import "PlaceDetail.h"
#import "UpdateUserLocationAPIClass.h"
#import "Woo_v2-Swift.h"
#import "GoogleHeaderView.h"
@import GooglePlaces;

#define kSearchBarDefaultColor [UIColor colorWithRed:255.0f/255.0f green:255.0/255.0f blue:255.0f/255.0f alpha:0.5]


@interface SearchLocationViewController ()<PlaceDetailDelegate>
{
    BOOL isDataFromGoogle;
    GMSPlacesClient *_placesClient;
    __weak IBOutlet NSLayoutConstraint *topViewConstraint;
    __weak IBOutlet NSLayoutConstraint *topConstraintSearch;
}
@end

@implementation SearchLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    isDataFromGoogle = NO;
    
    if (_comingFromSettings == YES){
        topViewConstraint.constant = 0;
        [btnCancel setImage:[UIImage imageNamed:@"ic_arrow_back_white"] forState:UIControlStateNormal];
    }
    
   
    [[Utilities sharedUtility]colorStatusBar: [UIColor colorWithRed:117.0/255.0 green:196.0/255.0 blue:219.0/255.0 alpha:1.0]];
  

    if(IS_IPHONE_X || IS_IPHONE_XS_MAX ){
        topConstraintSearch.constant = 0;
    }
    if (_isCancelButtonVisible)
        [btnCancel setHidden:NO];
    
    [self makingCustomizedSearchBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   [[Utilities sharedUtility]colorStatusBar:[UIColor colorWithRed:117.0/255 green:196.0/255 blue:219.0/255 alpha:1.0]];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kLocationOptions] && [[[NSUserDefaults standardUserDefaults] objectForKey:kLocationOptions] isKindOfClass:[NSArray class]]){
        
        arrDefaultLocation = [[NSUserDefaults standardUserDefaults] objectForKey:kLocationOptions]; // Getting prediction list from user default
    }
    
    _placesClient = [GMSPlacesClient sharedClient];
    SearchBarObj.placeholder = NSLocalizedString(@"Select City", nil);
    
    if ([arrDefaultLocation count] == 0 || !arrDefaultLocation) {
        [tblView setHidden:YES];
        [tblViewSearch setHidden:NO];
        
        [tblViewSearch setDelegate:self];
        [tblViewSearch setDataSource:self];
        [tblViewSearch reloadData];
        
    }else{
        [tblViewSearch setHidden:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [SearchBarObj becomeFirstResponder];
}



- (void) makingCustomizedSearchBar{
    
    UIImage* clearImg = [self imageWithColor:[UIColor clearColor] andSize:SearchBarObj.frame.size];
    [SearchBarObj setBackgroundImage:clearImg];
    
    [SearchBarObj setImage:[UIImage imageNamed:@"searchMagnifyer"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [SearchBarObj setImage:[UIImage imageNamed:@"searchClear"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
    if ([tblView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tblView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    [[UILabel appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:kSearchBarDefaultColor];
    
    
    //    for(UIView *subView in SearchBarObj.subviews) {
    //        if ([subView isKindOfClass:[UITextField class]]) {
    //            UITextField *searchField = (UITextField *)subView;
    //            searchField.font = [UIFont fontWithName:@"Lato-Medium" size:16.0f];
    //            searchField.backgroundColor = [UIColor colorWithRed:117.0/255.0 green:196.0/255.0 blue:219.0/255.0 alpha:1.0];
    //        }
    //    }
    
    
    UITextField *tf = [SearchBarObj valueForKey:@"searchField"];
    tf.font = [UIFont fontWithName:@"Lato-Medium" size:16.0f];
    tf.backgroundColor = [UIColor colorWithRed:117.0/255.0 green:196.0/255.0 blue:219.0/255.0 alpha:1.0];
    tf.textColor = [UIColor whiteColor];
    tf.leftViewMode = UITextFieldViewModeNever;
    [tf setTintColor:[UIColor whiteColor]];
    tf.textAlignment = NSTextAlignmentLeft;
    
}

- (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size
{
    UIImage *img = nil;
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,
                                   color.CGColor);
    CGContextFillRect(context, rect);
    
    img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

#pragma mark - ***************** Button Clicked Method *********************

- (IBAction)okButtonClicked:(id)sender{
    
    if (![APP_Utilities reachable]){
        
        [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];
        
        return;
    }
    
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kOpenPredictionLeastAtleastOnce] == true) {
        [DiscoverProfileCollection sharedInstance].needToMakeDiscoverCallAsPreferencesHasBeenChanged = true;
    }
    if ([arrSearchData count]>0){ // For Searching
        
        if (selectedIndex >= [arrSearchData count]) {
            return;
        }
        NSDictionary *searchDataDict = [arrSearchData objectAtIndex:selectedIndex];
        NSString *desc = [searchDataDict objectForKey:@"description"];
        
        NSArray *arrValue = [desc componentsSeparatedByString:@","];
        
        [SearchBarObj setText:[arrValue firstObject]];
        [self getLatLongFromPlaceId:searchDataDict];
        isDataFromGoogle = YES;
    }else{ // For Prediction List
        
        isDataFromGoogle = NO;
        NSDictionary *locationOption = [arrDefaultLocation objectAtIndex:selectedIndex];
        
        [[NSUserDefaults standardUserDefaults] setObject:@{kLastLocationLatitudeKey:[NSNumber numberWithDouble:[[locationOption objectForKey:@"latitude"] doubleValue]],kLastLocationLongitudeKey:[NSNumber numberWithDouble:[[locationOption objectForKey:@"longitude"] doubleValue]]} forKey:kUserLastLocationKey];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@, %@",[locationOption objectForKey:@"city"],[locationOption objectForKey:@"state"]] forKey:kLastLocationName];
        [DiscoverProfileCollection sharedInstance].myProfileData.location = [NSString stringWithFormat:@"%@, %@",[locationOption objectForKey:@"city"],[locationOption objectForKey:@"state"]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kLocationNeedsToBeUpdatedOnServer];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsPreferencesChanged];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kOpenPredictionLeastAtleastOnce];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self dismissThisViewController];
    }
}


#pragma mark - Cancel Button Clicked
- (IBAction)cancelButtonClicked:(id)sender{
    if (_comingFromSettings == YES){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}


#pragma mark - Table view data source


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    // DEEPAK GUPTA
    if (tblView.hidden)
        if (arrSearchData.count > 0)
            return 0;
        else
            return 70;
    else
        return 110;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50;
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = nil;
    
    if (tblView.hidden) {
        
        if (arrSearchData.count <= 0) {
            
            
            view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 70)];
            
            GoogleHeaderView  *headerView = [[[NSBundle mainBundle] loadNibNamed:@"GoogleHeaderView" owner:nil options:nil] objectAtIndex:0];
            
            [headerView setMyCurrentLocationActionBlockForButton:^{
                
                // My Current Location Clicked
                
                if (![APP_Utilities reachable]){
                    
                    [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];
                    
                    return;
                }
                
                [self getUserCurrentLocation];
                
                
                
            }];
            [view addSubview:headerView];
            view.backgroundColor = [UIColor whiteColor];
            
        }
    }else{
        
        
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 120)];
        
        
        GoogleHeaderView  *headerView = [[[NSBundle mainBundle] loadNibNamed:@"GoogleHeaderView" owner:nil options:nil] objectAtIndex:0];
        
        [headerView setMyCurrentLocationActionBlockForButton:^{
            
            // My Current Location Clicked
            
            
            if (![APP_Utilities reachable]){
                
                [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];
                
                return;
            }
            
            [self getUserCurrentLocation];
            
            
        }];
        [view addSubview:headerView];
        view.backgroundColor = [UIColor whiteColor];
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(28, 70, 100, 30)];
        [lbl setTextColor:[UIColor colorWithRed:55.0f/255.0f green:58.0f/255.0f blue:67.0f/255.0f alpha:1.0]];
        [lbl setBackgroundColor:[UIColor whiteColor]];
        [lbl setText:NSLocalizedString(@"Top Cities", @"Top Cities")];
        [lbl setFont:[UIFont fontWithName:@"Lato-Semibold" size:18.0f]];
        [view addSubview:lbl];
        return view;
    }
    
    return view;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tblView.hidden)
        return  arrSearchData.count;
    else
        return arrDefaultLocation.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = nil;
    
    if (tblView.hidden) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"SearchPredictionCellTableViewCell"];
        if (cell == nil) {
            // Load the top-level objects from the custom cell XIB.
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SearchPredictionCellTableViewCell" owner:self options:nil];
            // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
            cell = [topLevelObjects objectAtIndex:0];
        }
        
        SearchPredictionCellTableViewCell *searchCell = (SearchPredictionCellTableViewCell *)cell;
        
        [searchCell.cityLabel setHidden:NO];
        
        
        searchCell.backgroundColor = [UIColor whiteColor];
        
        NSDictionary *placeDict = [arrSearchData objectAtIndex:indexPath.row];
        
        NSString *desc = [placeDict objectForKey:@"description"];
        
        NSArray *arrValue = [desc componentsSeparatedByString:@","];
        
        if ([arrValue count] == 0)
            return cell;
        
        
        searchCell.cityLabel.attributedText = [self gettingAttributedStringFromString:[placeDict objectForKey:@"description"]];
        
    }else{ // Prediction List
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"SearchLocationCell"];
        if (cell == nil) {
            // Load the top-level objects from the custom cell XIB.
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SearchLocationCell" owner:self options:nil];
            // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
            cell = [topLevelObjects objectAtIndex:0];
        }
        
        SearchLocationCell *searchCell = (SearchLocationCell *)cell;
        
        if (arrDefaultLocation && arrDefaultLocation.count > 0) {
            NSDictionary *locationOption = [arrDefaultLocation objectAtIndex:indexPath.row];
            searchCell.specificLocationLbl.text = [NSString stringWithFormat:@"%@, %@",[locationOption objectForKey:@"city"],[locationOption objectForKey:@"state"]];
            
            [searchCell.stateCountryLabel setHidden:YES];
            [searchCell.cityLabel setHidden:YES];
            
            [searchCell.specificLocationLbl setHidden:NO];
        }
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    //tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    return cell;
    
}


- (NSAttributedString *)gettingAttributedStringFromString:(NSString *)locationString{
    
    int count = 0;
    count = (int)[SearchBarObj.text length];
    
    if (count < 1) {
        return [[NSAttributedString alloc] initWithString:@""];
    }
    
    NSString *firstString = @"";
    if ([firstString length] > count){
        firstString = [locationString substringToIndex:count];
    }
    NSString *secondString = [locationString stringByReplacingOccurrencesOfString:firstString withString:@""];
    
    
    UIFont *latoFontBold = [UIFont fontWithName:@"Lato-Bold" size:16.0f];
    NSDictionary *arialDict = [NSDictionary dictionaryWithObject: latoFontBold forKey:NSFontAttributeName];
    NSMutableAttributedString *aAttrString = [[NSMutableAttributedString alloc] initWithString:firstString attributes: arialDict];
    
    UIFont *latoFont = [UIFont fontWithName:@"Lato-Regular" size:16.0f];
    NSDictionary *verdanaDict = [NSDictionary dictionaryWithObject:latoFont forKey:NSFontAttributeName];
    NSMutableAttributedString *vAttrString = [[NSMutableAttributedString alloc]initWithString:secondString attributes:verdanaDict];
    
    [aAttrString appendAttributedString:vAttrString];
    
    return aAttrString;
    
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    selectedIndex = (int)indexPath.row;
    
    [self okButtonClicked:nil];
}

- (void)dismissThisViewController
{
    DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded = true;
    
    [SearchBarObj resignFirstResponder];
    if (self.comingFromSettings) {
        [[NSUserDefaults standardUserDefaults] setObject:NSLocalizedString(@"Manual_settings", nil) forKey:KSourceOfLocation];
    }
    else{
        [[NSUserDefaults standardUserDefaults] setObject:NSLocalizedString(@"Manual", nil) forKey:KSourceOfLocation];
    }
    if (isDataFromGoogle) {
        [[NSUserDefaults standardUserDefaults] setObject:NSLocalizedString(@"GoogleSearchApi", nil) forKey:kSubSourceOfLocation];
    }
    else{
        [[NSUserDefaults standardUserDefaults] setObject:NSLocalizedString(@"List", nil) forKey:kSubSourceOfLocation];
    }
    [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:kLastLocationUpdatedTime];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationHasBeenUpdated object:nil];
    
    if (self.comingFromSettings) {
        
        [self.navigationController popViewControllerAnimated:YES];
        if (_doneBlock) {
            self.doneBlock([DiscoverProfileCollection sharedInstance].myProfileData.location);
        }
    }
    else
    {
        [self dismissViewControllerAnimated:true completion:^{
            
            if (_doneBlock) {
                self.doneBlock([DiscoverProfileCollection sharedInstance].myProfileData.location);
            }
        }];
    }
}

#pragma mark - Google API Calls
#pragma mark - Get Google Place API call with Autocomplete

-(void )getPlacesAutoSuggetionFromGoogleForText:(NSString *)searchText{
    
    if (![APP_Utilities reachable]){
        [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];
        
        return;
    }
    
    NSString *aQuery=searchText;
    [NSObject cancelPreviousPerformRequestsWithTarget:_placesClient selector:@selector(autocompleteQuery:bounds:filter:callback:) object:self];
    
    if(aQuery.length>0){
        GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
        filter.type = kGMSPlacesAutocompleteTypeFilterCity;
        
        
        [_placesClient findAutocompletePredictionsFromQuery:aQuery filter:filter sessionToken:nil callback:^(NSArray<GMSAutocompletePrediction *> * _Nullable results, NSError * _Nullable error) {
            
            NSLog(@"%@",results);
            NSLog(@"%@",error);
                                    if (error != nil) {
                                        NSLog(@"Autocomplete error of getPlacesAutoSuggetionFromGoogleForText %@", [error localizedDescription]);
                                        return;
                                    }
                                    if(results.count>0){
                                        NSMutableArray *arrfinal=[NSMutableArray array];
                                        for (GMSAutocompletePrediction* result in results) {
                                            NSDictionary *aTempDict =  [NSDictionary dictionaryWithObjectsAndKeys:result.attributedFullText.string,@"description",result.placeID,@"reference", nil];
                                            [arrfinal addObject:aTempDict];
                                        }
                                        if ([arrSearchData count]>0)
                                            [arrSearchData removeAllObjects];
                                        
                                        arrSearchData = arrfinal;
                                        
                                        if ([arrSearchData count] > 0){
                                            [tblViewSearch setDelegate:self];
                                            [tblViewSearch setDataSource:self];
                                            [tblViewSearch setHidden:NO];
                                            [tblView setHidden:YES];
                                            [tblViewSearch reloadData];
                                            [tblView setUserInteractionEnabled:NO];
                                        }
                                    }else{
                                    }
        }];
        
    }else{
        
    }
}



#pragma mark - Get Google Place detail API call for Place Id
- (void)getLatLongFromPlaceId : (NSDictionary *)searchData{
    
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    BOOL isNetworkReachable = (reachability.isReachable || reachability.isReachableViaWiFi || reachability.isReachableViaWWAN);
    
    if (!isNetworkReachable) {
        SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"Please check your internet connection",nil));
        return;
    }
    
    NSString *aStrPlaceReferance=[searchData objectForKey:@"reference"];
    PlaceDetail *placeDetail=[[PlaceDetail alloc]initWithApiKey:kGoogleAPIKey];
    placeDetail.delegate=self;
    [placeDetail getPlaceDetailForReferance:aStrPlaceReferance];
    NSString *desc = [searchData objectForKey:@"description"];
    
    NSArray *arrValue = [desc componentsSeparatedByString:@","];
    
    NSString *location = [arrValue firstObject];
    location = [location stringByTrimmingCharactersInSet:
                [NSCharacterSet whitespaceCharacterSet]];
    int stateValue = (int)[arrValue count]-2;
    if (stateValue>0) {
        NSString *state = [arrValue objectAtIndex:stateValue];
        state = [state stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        location = [NSString stringWithFormat:@"%@, %@",location,state];
    }
    [DiscoverProfileCollection sharedInstance].myProfileData.location = location;
    
    [[NSUserDefaults standardUserDefaults] setObject:location forKey:kLastLocationName];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kLocationNeedsToBeUpdatedOnServer];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsPreferencesChanged];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}



#pragma mark - UISearchBar delegate

-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    if(text.length > 2){
        [self getPlacesAutoSuggetionFromGoogleForText:text];
    }
    else{
        [arrSearchData removeAllObjects];
        
        
        if (arrDefaultLocation.count>0) {
            
            [tblView setHidden:NO];
            [tblViewSearch setHidden:YES];
            
            [tblView setUserInteractionEnabled:YES];
            [tblView reloadData];
            
            
            
        }else{
            [tblViewSearch reloadData];
        }
    }
}

#pragma mark - PlaceDetail Delegate

-(void)placeDetailForReferance:(NSString *)referance didFinishWithResult:(GMSPlace*)resultDict{
    //Respond To Delegate
    [[NSUserDefaults standardUserDefaults] setObject:@{kLastLocationLatitudeKey:[NSNumber numberWithDouble:resultDict.coordinate.latitude],kLastLocationLongitudeKey:[NSNumber numberWithDouble:resultDict.coordinate.longitude]} forKey:kUserLastLocationKey];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kLocationNeedsToBeUpdatedOnServer];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsPreferencesChanged];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kOpenPredictionLeastAtleastOnce];
    
    
    [[NSUserDefaults standardUserDefaults] setValue:resultDict.placeID forKey:kGoogleReferenceId];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    [self dismissThisViewController];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [SearchBarObj resignFirstResponder];
}

#pragma mark /********************************* Location Flow *****************************************/

-(void)getUserCurrentLocation{
    
    if(_locationManager){
        
        _locationManager = nil;
    }
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    
    
    if (![CLLocationManager locationServicesEnabled]) {
        [self askUserToEnableSystemLocationService];
    }else{
        
        if (customLoader) {
            customLoader = nil;
        }
        customLoader = [[WooLoader alloc]initWithFrame:self.view.frame];
        [customLoader startAnimationOnView:self.view WithBackGround:NO];
        
        [_locationManager startUpdatingLocation];
        
        [SearchBarObj resignFirstResponder];
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
        [customLoader stopAnimation];
        [SearchBarObj becomeFirstResponder];
    }];
    
    [locationAlert addAction:okAction];
    [locationAlert addAction:cancelAction];
    [self presentViewController:locationAlert animated:YES completion:nil];
}

-(void)checkIfLocationChangedByUSer{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    if (![CLLocationManager locationServicesEnabled]) {
    }else{
        [self getUserCurrentLocation];
    }
}



#pragma mark - CLLocationManager Delegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    
    NSLog(@"manager >>>%@",manager);
    
    NSLog(@"State >>>> %d",status);
    
    
    if ([CLLocationManager locationServicesEnabled]) {
        
        if (status == kCLAuthorizationStatusDenied){
            
            [self askUserToEnableSystemLocationService];
            
            
        }else if (status == kCLAuthorizationStatusAuthorizedWhenInUse){
            
            [customLoader startAnimationOnView:self.view WithBackGround:NO];
            [SearchBarObj resignFirstResponder];
            [manager startUpdatingLocation];
            
        }else if (status == kCLAuthorizationStatusNotDetermined){
            
            [manager requestWhenInUseAuthorization];
            
        }
    }
    
}



-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    NSLog(@"%@",locations);
    
    [_locationManager stopUpdatingLocation]; //stop updating user location
    _locationManager = nil;
    
    if ([locations lastObject]){
        
        locationObj = [locations lastObject];
        
        NSUserDefaults *userDefaultObj = [NSUserDefaults standardUserDefaults];
        [userDefaultObj setObject:@{kLastLocationLatitudeKey:[NSNumber numberWithDouble:locationObj.coordinate.latitude],kLastLocationLongitudeKey:[NSNumber numberWithDouble:locationObj.coordinate.longitude]} forKey:kUserLastLocationKey];
        [userDefaultObj synchronize];
        
        
        [self makeLocationStringFromLatLongAndStartTheFlow];
    }
}



- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
    // [self makeLocationStringFromLatLongAndStartTheFlow];
    
    [customLoader stopAnimation];
    [SearchBarObj becomeFirstResponder];
}



- (void)makeLocationStringFromLatLongAndStartTheFlow
{
    
    
    NSDictionary *locationObject = [[NSUserDefaults standardUserDefaults] objectForKey:kUserLastLocationKey];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    
    //    NSString *lat = @"40.836318";
    //    NSString *lon = @"-74.123546";
    
    CLLocation *locationToBeUsedHere = [[CLLocation alloc]initWithLatitude:[[locationObject objectForKey:kLastLocationLatitudeKey] doubleValue] longitude:[[locationObject objectForKey:kLastLocationLongitudeKey] doubleValue]];
    
    
    
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
                 
                 if (self.comingFromSettings){
                    if (self.doneBlock) {
                         self.doneBlock([DiscoverProfileCollection sharedInstance].myProfileData.location);
                     }
                     [self.navigationController popViewControllerAnimated:YES];
                 }
                 else{
                 [self dismissViewControllerAnimated:NO completion:^{
                     
                     if (self.doneBlock) {
                         self.doneBlock([DiscoverProfileCollection sharedInstance].myProfileData.location);
                     }
                 }];}
                 
             }
             
             [customLoader stopAnimation];
             
         }
         
         [customLoader stopAnimation];
         [SearchBarObj becomeFirstResponder];
         
     }];
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

