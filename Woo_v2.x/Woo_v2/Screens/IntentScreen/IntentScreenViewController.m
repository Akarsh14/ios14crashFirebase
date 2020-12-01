//
//  OnboardingViewController.m
//  OnboardingSprint
//
//  Created by Suparno Bose on 11/05/16.
//  Copyright © 2016 Umesh Mishra. All rights reserved.
//

#import "IntentScreenViewController.h"
#import "OnboardingCell.h"
#import "UICircularSlider.h"
#import "VPImageCropperViewController.h"
#define CELL_COUNT 3

@interface IntentScreenViewController ()<VPImageCropperDelegate>

@end

@implementation IntentScreenViewController
{
    __weak IBOutlet UITableView *tableView;
    
    
    __weak IBOutlet UILabel     *titleAgeDialer;
    __weak IBOutlet UICircularSlider *minWheel;
    
    __weak IBOutlet UICircularSlider *maxWheel;
    
    __weak IBOutlet UILabel *minWheelText;
    
    __weak IBOutlet UILabel *maxWheelText;
    
    __weak IBOutlet UILabel *lblPageNumber;
    __weak IBOutlet UIButton *nextBtn;
    __weak IBOutlet UIButton *backBtn;
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Swrve Event
    [APP_DELEGATE sendSwrveEventWithEvent:@"3-Onboarding.Onboard_Intent.OB_Intent_Landing" andScreen:@"Onboard_Intent"];

    
    [self configSliderViews];
    
    selectedIntent = [LoginModel sharedInstance].favIntent;
    genderPreference = [LoginModel sharedInstance].genderPreference;
    
    
    
    if (APP_DELEGATE.onBaordingPageNumber <= ON_BOARDING_PAGE_NUMBER_ONE) {
        [backBtn setHidden:YES];
    }
    [lblPageNumber setText:[NSString stringWithFormat:@"%d of %d",APP_DELEGATE.onBaordingPageNumber , APP_DELEGATE.totalOnboardingPages]];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    

    [self updateGenderPreferences];
    
    if (![APP_Utilities reachable]){
        
        [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];


    }
    
    detailArray = [NSMutableArray arrayWithArray:@[[NSMutableDictionary dictionaryWithDictionary:
                                                    [[NSDictionary alloc] initWithObjectsAndKeys:
                                                     NSLocalizedString(@"Friends", @"Friends"),kIntentTitleKey,
                                                     [NSNumber numberWithInt:INTENT_TYPE_FRIEND],kIntentTypeKey,
                                                     nil]],
  //@{kIntentTitleKey:NSLocalizedString(@"Friends", @"Friends") ,kIntentTypeKey:[NSNumber numberWithInt:INTENT_TYPE_FRIEND]}],
                                                   [NSMutableDictionary dictionaryWithDictionary:
                                                    [[NSDictionary alloc] initWithObjectsAndKeys:
                                                     NSLocalizedString(@"Dating", @"Dating"),kIntentTitleKey,
                                                     [NSNumber numberWithInt:INTENT_TYPE_CASUAL],kIntentTypeKey,
                                                     nil]],
  //@{kIntentTitleKey:NSLocalizedString(@"Dating", @"Dating"),kIntentTypeKey:[NSNumber numberWithInt:INTENT_TYPE_CASUAL]}],
                                                   [NSMutableDictionary dictionaryWithDictionary:
                                                    [[NSDictionary alloc] initWithObjectsAndKeys:
                                                     NSLocalizedString(@"Love of my life", @"Love of my life"),kIntentTitleKey,
                                                     [NSNumber numberWithInt:INTENT_TYPE_LOVE_OF_MY_LIFE],kIntentTypeKey,
                                                     nil]]]];
  //@{kIntentTitleKey:NSLocalizedString(@"Love of my life", @"Love of my life"),kIntentTypeKey:[NSNumber numberWithInt:INTENT_TYPE_LOVE_OF_MY_LIFE]}]]];
    
    NSLog(@"detail array :%@",detailArray);
    if (IS_IPHONE_4) {
        topView_TitleLabelTopMarginConstraint.constant = 24;    //for others 44
        topView_TableViewHeightConstraint.constant = 160;       //for others 190
        topViewHeightConstraint.constant = 230;                 //for others 290
    }
}

-(void)updateGenderPreferences{
    if (genderPreference == SELECTED_GENDER_PREFERENCE_MALE ) {
        [maleButton setBackgroundImage:[UIImage imageNamed:@"ic_man_btn_selected"] forState:UIControlStateNormal];
        [femaleButton setBackgroundImage:[UIImage imageNamed:@"ic_woman_btn"] forState:UIControlStateNormal];
    }else{
        [maleButton setBackgroundImage:[UIImage imageNamed:@"ic_man_btn"] forState:UIControlStateNormal];
        [femaleButton setBackgroundImage:[UIImage imageNamed:@"ic_woman_btn_selected"] forState:UIControlStateNormal];
    }
}


-(void)configSliderViews{
    
    [minWheel addTarget:self action:@selector(updateProgress:) forControlEvents:UIControlEventValueChanged];
    minWheel.minimumValue = [LoginModel sharedInstance].minimumAgeAllowedInApp;
    minWheel.maximumValue =[LoginModel sharedInstance].maximumAgeAllowedInApp-[LoginModel sharedInstance].intentAgeDifferenceThreshold;
    minWheel.continuous = YES;
    minWheel.minimumTrackTintColor = [UIColor clearColor];
    minWheel.maximumTrackTintColor = [UIColor clearColor];
    minWheel.thumbTintColor = kSliderNobColorNew;//kSliderNobColor;

    minWheel.transform = CGAffineTransformMakeRotation(M_PI);
    
    NSLog(@"minWheel.value :%f",minWheel.value);
    
    
    [maxWheel addTarget:self action:@selector(updateProgress:) forControlEvents:UIControlEventValueChanged];
    maxWheel.minimumValue = [LoginModel sharedInstance].minimumAgeAllowedInApp+[LoginModel sharedInstance].intentAgeDifferenceThreshold;
    maxWheel.maximumValue =[LoginModel sharedInstance].maximumAgeAllowedInApp;
    maxWheel.continuous = YES;
    maxWheel.minimumTrackTintColor = [UIColor clearColor];
    maxWheel.maximumTrackTintColor = [UIColor clearColor];
    maxWheel.thumbTintColor = kSliderNobColorNew; //kSliderNobColor;

    maxWheel.transform = CGAffineTransformMakeRotation(M_PI);
    
    
    minWheel.value = [LoginModel sharedInstance].intentMinAge;
    [minWheelText setText:[NSString stringWithFormat:@"%d",(int)minWheel.value]];
    
    maxWheel.value = [LoginModel sharedInstance].intentMaxAge;
    [maxWheelText setText:[NSString stringWithFormat:@"%d",(int)maxWheel.value]];
    NSLog(@"minWheel.value :%f",maxWheel.value);
    
    NSLog(@"constant value :%f",0.1 * SCREEN_WIDTH);
    NSLog(@"constant value: %f",0.32 * SCREEN_WIDTH);
    
    [self.view needsUpdateConstraints];
    [minWheel needsUpdateConstraints];
    [maxWheel needsUpdateConstraints];
    NSLog(@"trailingMarginOfAddButton_MinWheel.constan: %f",trailingMarginOfAddButton_MinWheel.constant);
    if (IS_IPHONE_4 || IS_IPHONE_5) {
        trailingMarginOfAddButton_MinWheel.constant = 0.1 * SCREEN_WIDTH;
        trailingMarginOfAddButton_MaxWheel.constant = 0.1 * SCREEN_WIDTH;
        leadingMarginOfSubtractButton_MaxWheel.constant = 0.1 * SCREEN_WIDTH;
        leadingMarginOfSubtractButton_MinWheel.constant = 0.1 * SCREEN_WIDTH;
    }
    else{
        trailingMarginOfAddButton_MinWheel.constant = 45;
        trailingMarginOfAddButton_MaxWheel.constant = 45;
        leadingMarginOfSubtractButton_MaxWheel.constant = 45;
        leadingMarginOfSubtractButton_MinWheel.constant = 45;
    }
    

    [minWheel layoutIfNeeded];
    [maxWheel layoutIfNeeded];
    [self.view layoutIfNeeded];
    
    NSLog(@"trailingMarginOfAddButton_MinWheel.constan: %f",trailingMarginOfAddButton_MinWheel.constant);
    
    
    titleAgeDialer.text = [NSString stringWithFormat:NSLocalizedString(@"Between the ages of %d to %d", @"between ages") ,[LoginModel sharedInstance].intentMinAge , [LoginModel sharedInstance].intentMaxAge];

    
}


#pragma mark - Slider Selectors

- (IBAction)updateProgress:(UISlider *)sender {
    //float progress = translateValueFromSourceIntervalToDestinationInterval(sender.value, sender.minimumValue, sender.maximumValue, 0.0, 1.0);
    //    NSLog(@"%f>>>%f",progress,sender.value);
    
    if ([sender isEqual:minWheel]) {
        [minWheelText setText:[NSString stringWithFormat:@"%d",(int)sender.value]];
        if (maxWheel.value - minWheel.value < [LoginModel sharedInstance].intentAgeDifferenceThreshold) {
            [maxWheel setValueAndDoNotNotify:minWheel.value + [LoginModel sharedInstance].intentAgeDifferenceThreshold];
            [maxWheelText setText:[NSString stringWithFormat:@"%d",(int)maxWheel.value]];
        }
    }
    else{
        [maxWheelText setText:[NSString stringWithFormat:@"%d",(int)sender.value]];
        if (maxWheel.value - minWheel.value < [LoginModel sharedInstance].intentAgeDifferenceThreshold) {
            [minWheel setValueAndDoNotNotify:maxWheel.value - [LoginModel sharedInstance].intentAgeDifferenceThreshold];
            [minWheelText setText:[NSString stringWithFormat:@"%d",(int)minWheel.value]];
        }
    }
    
    titleAgeDialer.text = [NSString stringWithFormat: NSLocalizedString(@"Between the ages of %@ to %@", @"between the ages") ,minWheelText.text , maxWheelText.text];

    
    
}

#pragma mark - TableView Delegate Fuctions

- (NSInteger)tableView:(UITableView *)tblView numberOfRowsInSection:(NSInteger)section{
    return CELL_COUNT;
}

- (UITableViewCell *)tableView:(UITableView *)tblView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"OnboardingCell";
    OnboardingCell *cell = (OnboardingCell *)[tblView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSDictionary *cellDetail = [detailArray objectAtIndex:indexPath.row];
    if (!cell){
        cell = [[OnboardingCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    [cell genderButtonStateChanged:^(GenderPreference tappedGenderButton, BOOL isGenderSelected, IntentType myIntentType) {
        if (![self willAtleastOneGenderPreferenceBeSelected:isGenderSelected withSelectedGenderPref:tappedGenderButton andSelectedIntent:myIntentType]) {

            [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"You cannot unselected all gender preferences. Atleast one gender preference is required.", @"You cannot unselected all gender preferences") withActionTitle:@"" withDuration:1.0];
            
            
            [tableView reloadData];
            return;
        }
        
        
        NSLog(@"detail array :%@",detailArray);
        [tableView reloadData];
    }];
    [cell intentButtonTapped:^(IntentType selectedIntentType) {
        selectedIntent = selectedIntentType;
        [tableView reloadData];
    }];
    [cell setTileForTheCell:[cellDetail objectForKey:kIntentTitleKey] withIntentType:[[cellDetail objectForKey:kIntentTypeKey] intValue] withSelectedIntent:selectedIntent andSelectedGenderForIntent:[[cellDetail objectForKey:kGenderForIntentKey] intValue]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    if (IS_IPHONE_4) {
        return 40.0;
//    }
//    else{
//        
//        return (SCREEN_WIDTH*0.1875);
//    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    selectedIntent = [[[detailArray objectAtIndex:indexPath.row] objectForKey:kIntentTypeKey] intValue];
    [tableView reloadData];
    
}


-(IBAction)backButtonClicked:(id)sender{
    
    if (![APP_Utilities reachable]){
        
        [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];

        
        return;
    }
    
    APP_DELEGATE.onBaordingPageNumber--;
    [self.navigationController popViewControllerAnimated:YES];
}


-(IBAction)moveToNextScreen:(id)sender{
    
    [APP_DELEGATE sendSwrveEventWithEvent:@"3-Onboarding.Onboard_Intent.OB_Intent_Next" andScreen:@"Onboard_Intent"];
    
    if (![APP_Utilities reachable]){
        
        [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];


        return;
    }
    
    
    self.navigationController.navigationBarHidden = YES;
    
    if ([APP_Utilities reachable]) {
        [self makePreferenceChangeCallToServer];
//        if ([self isGenderPreferenceForSelectedIntentSelected]) {

        if (LoginModel.sharedInstance.userLifestyleTagsAvailable == false || LoginModel.sharedInstance.userRelationshipTagsAvailable == false) {
            APP_DELEGATE.onBaordingPageNumber++;
            RelationshipViewController *relationshipController = [RelationshipViewController loadNib:@"Relationship and Lifestyle"];
            [relationshipController setViewsfor:1 tagData:0 closeBtn:false title:@"Relationship and Lifestyle"];
            [self.navigationController pushViewController:relationshipController animated:true];
            
        }
           else if(![[LoginModel sharedInstance] userOtherTagsAvailable]){                //changed condition as if the value is true user should not see the tag screen
                
                APP_DELEGATE.onBaordingPageNumber++;
                //[self performSegueWithIdentifier:kTagScreenControllerID sender:nil];
                
                WizardTagsViewController *wizardTagsVC = [[WizardTagsViewController alloc] initWithNibName:@"WizardTagsViewController" bundle:nil];
                [wizardTagsVC setIsUsedOutOfWizard:true];
                [wizardTagsVC setIsPartOfOnboarding:true];
                [self.navigationController pushViewController:wizardTagsVC animated:true];
            
            }else if([[LoginModel sharedInstance] aboutMetext] && [[LoginModel sharedInstance] aboutMeDefault]){  // If there is no dto comes from login api response
                
                
                APP_DELEGATE.onBaordingPageNumber++;
                [self performSegueWithIdentifier:kAboutMeScreenControllerID sender:nil];

            
            }else if([[LoginModel sharedInstance] profilePicUrl] == nil){ // new user no pic
                
                int width = SCREEN_WIDTH * .7361;
                
                VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:[UIImage imageNamed:@"crop_default"] cropFrame:CGRectMake((SCREEN_WIDTH - width)/2,0.122*SCREEN_HEIGHT, width, 0.655*SCREEN_HEIGHT) limitScaleRatio:3.0];

                
                imgCropperVC.delegate = self;
                
                [self.navigationController pushViewController:imgCropperVC animated:YES];
            }
            else{
            
                if ([[LoginModel sharedInstance].gender isEqualToString:@"FEMALE"]){
                    APP_DELEGATE.onBaordingPageNumber++;
                    WizardPhotoViewController *photoViewController = [[WizardPhotoViewController alloc] initWithNibName:@"WizardPhotoViewController" bundle:[NSBundle mainBundle]];
                    [self.navigationController pushViewController:photoViewController animated:true];
                }
                else{
                APP_DELEGATE.onBaordingPageNumber++;
                [APP_Utilities sendToDiscover];
                }

            }
//        }
//        else{
//
//            [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"Select gender for star intent.", nil) withActionTitle:@"" withDuration:1.0];
//            
//        }
    }
    else{
        
        [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];
    
    }
    
}
-(void)makePreferenceChangeCallToServer{
    
    NSString *userWooID = [[NSUserDefaults standardUserDefaults] valueForKey:@"id"];
    NSString *minAgeStr = [NSString stringWithFormat:@"%d",(int)minWheel.value];
    NSString *maxAgeStr = [NSString stringWithFormat:@"%d",(int)maxWheel.value];
    NSString *prefereceChangeCall = [NSString stringWithFormat:@"%@%@?wooId=%@&minAge=%@&maxAge=%@&favIntent=%@",kBaseURLV2,kIntentPreferenceCall,userWooID,minAgeStr,maxAgeStr,[APP_Utilities getIntentTypeStringForSelectedIntent:selectedIntent]];
    
    if (genderPreference == SELECTED_GENDER_PREFERENCE_MALE || genderPreference == SELECTED_GENDER_PREFERENCE_FEMALE ) {
        
        prefereceChangeCall = [NSString stringWithFormat:@"%@&interestedGender=%@",prefereceChangeCall,[APP_Utilities getGenderStringForGenderType:genderPreference]];
        
    }
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =prefereceChangeCall;
    wooRequestObj.time =900;
    wooRequestObj.requestParams = nil;
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = sendUserLocationToServer;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        NSLog(@"statusCode :%d",statusCode);
        
        
        if (statusCode == 401) {
            [self handleErrorForResponseCode:statusCode];
            return;
        }
        
        NSLog(@"response :%@",response);
    } shouldReachServerThroughQueue:YES ];
}

- (IBAction)femaleButtonTapped:(id)sender {
    
    genderPreference = SELECTED_GENDER_PREFERENCE_FEMALE;
    [self updateGenderPreferences];
}

- (IBAction)maleButtonTapped:(id)sender {
    
    genderPreference = SELECTED_GENDER_PREFERENCE_MALE;
    [self updateGenderPreferences];
}


#pragma mark - VPIImage Cropper Delegate

- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(NSDictionary *)editedImageData {
    
    //    self.portraitImageView.image = [editedImageData objectForKey:@"imageObj"];
    [cropperViewController.navigationController popViewControllerAnimated:NO];
    
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {

    [cropperViewController.navigationController popViewControllerAnimated:NO];
    
}






@end
