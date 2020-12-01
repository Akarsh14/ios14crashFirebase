//
//  AgeGenderViewController.m
//  Woo_v2
//
//  Created by Deepak Gupta on 6/6/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "AgeGenderViewController.h"
#import "UpdateAgeGenderAPIClass.h"
#import "LogInAPIClass.h"
#import "VPImageCropperViewController.h"
#import "LoginErrorFeedbackViewController.h"

@interface AgeGenderViewController ()<VPImageCropperDelegate,LoginErroFeedbackDelegate>{
    
    __weak IBOutlet UIView *dateButtonContainerView;
    __weak IBOutlet UIView *datePickerView;
    __weak IBOutlet UIDatePicker *birthDatePicker;
    __weak IBOutlet UIButton *dayButton;
    __weak IBOutlet UIButton *monthButton;
    __weak IBOutlet UIButton *yearButton;

    BOOL isAgeOnlyNeedToBeSelected;
}

@end

@implementation AgeGenderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
    [lblPageNumber setText:[NSString stringWithFormat:@"%d of %d",APP_DELEGATE.onBaordingPageNumber , APP_DELEGATE.totalOnboardingPages]];

    if ([[[LoginModel sharedInstance] gender] isEqualToString:@"UNKNOWN"] &&[[LoginModel sharedInstance] age] == 0) { // if both age & gender is not available

        isAgeOnlyNeedToBeSelected = false;
            [self setAgeDialer];
        
        [nextBtn setEnabled:NO];
        [nextBtn setAlpha:0.7];

        [lblSliderValue setText:[NSString stringWithFormat:@"%d",[LoginModel sharedInstance].minimumAgeAllowedInApp]];

        
    }else if ([[LoginModel sharedInstance] age] == 0){ // if gender if available , hide gender view
        isAgeOnlyNeedToBeSelected = true;
        [lblAgeTitleLabel setText:NSLocalizedString(@"My Birthday", @"My Birthday")];
        
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        
        genderView_y.constant = -viewGender.frame.size.height + (SCREEN_HEIGHT - viewAge.frame.size.height)/2 - 100;
        [viewGender layoutIfNeeded];
        
        
        [viewGender setHidden:YES];
        
        [nextBtn setEnabled:YES];
        [nextBtn setAlpha:1.0];
        [self setAgeDialer];
        
        [lblSliderValue setText:[NSString stringWithFormat:@"%d",[LoginModel sharedInstance].minimumAgeAllowedInApp]];

    }else{ // if age is available , then hide age view.
        isAgeOnlyNeedToBeSelected = false;
        [lblGenderTitleLabel setText:NSLocalizedString(@"I'm a...", @"I'm a...")];
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        
        [nextBtn setEnabled:NO];
        [nextBtn setAlpha:0.7];
        genderView_y.constant = (SCREEN_HEIGHT - viewGender.frame.size.height)/2 - 100;
        [viewGender layoutIfNeeded];
        [viewAge setHidden:YES];

        viewGender.backgroundColor = [UIColor clearColor];
    }
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
}

- (void)updateDateButtonsBasedOnAge:(BOOL)hasAge{
    NSString *buttonColorName = nil;
    if (hasAge){
        buttonColorName = @"#090909";
        [self updateButtonsText];
    }
    else{
        buttonColorName = @"#CDCDD0";
    }
    [dayButton setTitleColor:[UIColorHelper colorFromRGB:buttonColorName withAlpha:1.0] forState:UIControlStateNormal];
    [monthButton setTitleColor:[UIColorHelper colorFromRGB:buttonColorName withAlpha:1.0] forState:UIControlStateNormal];
    [yearButton setTitleColor:[UIColorHelper colorFromRGB:buttonColorName withAlpha:1.0] forState:UIControlStateNormal];

}

- (void)updateButtonsText{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    if ([LoginModel sharedInstance].birthday != nil){
        NSDate *selectedDate = [formatter dateFromString:[LoginModel sharedInstance].birthday];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSInteger day = [calendar component:NSCalendarUnitDay fromDate:selectedDate];
        if (day > 9){
            [dayButton setTitle:[NSString stringWithFormat:@"%ld",(long)day] forState:UIControlStateNormal];
        }
        else{
            [dayButton setTitle:[NSString stringWithFormat:@"0%ld",(long)day] forState:UIControlStateNormal];
        }
        NSInteger month = [calendar component:NSCalendarUnitMonth fromDate:selectedDate];
        
        if (month > 9){
        [monthButton setTitle:[NSString stringWithFormat:@"%ld",(long)month] forState:UIControlStateNormal];
        }
        else{
            [monthButton setTitle:[NSString stringWithFormat:@"0%ld",(long)month] forState:UIControlStateNormal];
        }
        NSInteger year = [calendar component:NSCalendarUnitYear fromDate:selectedDate];
        [yearButton setTitle:[NSString stringWithFormat:@"%ld",(long)year] forState:UIControlStateNormal];
    }
}

- (void)updateBirthdayOfUser{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    NSString *birthdayString = [formatter stringFromDate:birthDatePicker.date];
    [[LoginModel sharedInstance] setBirthday:birthdayString];
}


#pragma mark - Setting Age Dialer
- (void)setAgeDialer{
    
    NSLog(@"age  = %d",[[LoginModel sharedInstance] maximumAgeAllowedInApp]);
    
    NSLog(@"age = %d",[[LoginModel sharedInstance] minimumAgeAllowedInApp]);
    
    [ageSlider addTarget:self action:@selector(updateProgress:) forControlEvents:UIControlEventValueChanged];
    ageSlider.continuous = YES;
    ageSlider.minimumTrackTintColor = [UIColor clearColor];
    ageSlider.maximumTrackTintColor = [UIColor clearColor];

    ageSlider.thumbTintColor = kSliderNobColorNew;//kSliderNobColor;

    
 //   ageSlider.maximumTrackTintColor = [UIColor colorWithRed:246.0/256.0 green:246.0/256.0 blue:246.0/256.0 alpha:1.0];
    ageSlider.transform = CGAffineTransformMakeRotation(M_PI);
    
}


#pragma mark - Update Slider Progresss
- (IBAction)updateProgress:(UISlider *)sender {
    float progress = translateValueFromSourceIntervalToDestinationInterval(sender.value, sender.minimumValue, sender.maximumValue, [LoginModel sharedInstance].minimumAgeAllowedInApp, [LoginModel sharedInstance].maximumAgeAllowedInApp);
    
    NSLog(@"%f",progress);
    
    [lblSliderValue setText:[NSString stringWithFormat:@"%.f",progress]];
}

#pragma mark - ***************************** Button Clicked Method *************************************
#pragma mark - Male - Female Button Clicked
- (IBAction)maleFemaleButtonClicked:(UIButton *)sender{
    
    NSLog(@"HEIGHT  = %f",viewGender.frame.size.height);
    
    [nextBtn setEnabled:YES];
    [nextBtn setAlpha:1.0];
    
    [btnMale setImage:[UIImage imageNamed:@"ic_man_btn"] forState:UIControlStateNormal];
    [btnFemale setImage:[UIImage imageNamed:@"ic_woman_btn"] forState:UIControlStateNormal];
    
    
    if (sender.tag == 0) {
        [btnMale setImage:[UIImage imageNamed:@"ic_man_btn_selected"] forState:UIControlStateNormal];
        selectedGender = @"MALE";
    }else if (sender.tag == 1){
        [btnFemale setImage:[UIImage imageNamed:@"ic_woman_btn_selected"] forState:UIControlStateNormal];
        selectedGender = @"FEMALE";
    }
    LoginModel.sharedInstance.gender = selectedGender;
}
- (IBAction)datePicked:(id)sender {
    [nextBtn setEnabled:YES];
    [nextBtn setAlpha:1.0];
    [self updateBirthdayOfUser];
    [datePickerView setHidden:YES];
    [self updateDateButtonsBasedOnAge:YES];
    [dateButtonContainerView setHidden:NO];
    [nextBtn setHidden:NO];
    [lblPageNumber setHidden:NO];
}
- (IBAction)showDatePicker:(id)sender {
    [datePickerView setHidden:NO];
    if (isAgeOnlyNeedToBeSelected){
    [dateButtonContainerView setHidden:YES];
    }
    [nextBtn setHidden:YES];
    [lblPageNumber setHidden:YES];
}


#pragma mark - Next Button Clicked
- (IBAction)nextButtonClicked:(id)sender{
    
    if (![APP_Utilities reachable]){
        
        [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];


        return;
    }
    
    [LogInAPIClass makeRegistrationCallwithCompletionBlock:^(BOOL success, id response, int statusCode , BOOL userChanged) {
        
        
        if (statusCode == 401) { // Authentication Failed
            [self handleErrorForResponseCode:401];
            return;
        }
        else if (statusCode == 416){
            LoginErrorFeedbackViewController *errorLogin = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginErrorFeedbackViewController"];
            errorLogin.isShownForAgeLimit = YES;
            errorLogin.delegate = self;
            [self presentViewController:errorLogin animated:YES completion:^{
                
            }];
            return;
        }
        
        if (success) {
            
            if ([[LoginModel sharedInstance] favIntent] != INTENT_TYPE_NONE){
                APP_DELEGATE.onBaordingPageNumber++;
                [self performSegueWithIdentifier:kIntentScreenControllerID sender:nil];
            }else if (([response objectForKey:kuserRelationshipTagsAvailable] && [[response objectForKey:kuserRelationshipTagsAvailable] boolValue] == false) || ([response objectForKey:kuserLifestyleTagsAvailable] && [[response objectForKey:kuserLifestyleTagsAvailable] boolValue] == false)) {
                APP_DELEGATE.onBaordingPageNumber++;
                RelationshipViewController *relationshipController = [RelationshipViewController loadNib:@"Relationship and Lifestyle"];
                [relationshipController setViewsfor:1 tagData:0 closeBtn:false title:@"Relationship and Lifestyle"];
                [self.navigationController pushViewController:relationshipController animated:true];
                
            }
            else if(![[LoginModel sharedInstance] userOtherTagsAvailable]){      //changed condition as if the value is true user should not see the tag screen
                
                APP_DELEGATE.onBaordingPageNumber++;
                //[self performSegueWithIdentifier:kTagScreenControllerID sender:nil];
                WizardTagsViewController *wizardTagsVC = [[WizardTagsViewController alloc] initWithNibName:@"WizardTagsViewController" bundle:nil];
                [wizardTagsVC setIsUsedOutOfWizard:true];
                [wizardTagsVC setIsPartOfOnboarding:true];
                [self.navigationController pushViewController:wizardTagsVC animated:true];
            }
            else if([[LoginModel sharedInstance] aboutMetext] && [[LoginModel sharedInstance] aboutMeDefault]){
                
                APP_DELEGATE.onBaordingPageNumber++;
                [self performSegueWithIdentifier:kAboutMeScreenControllerID sender:nil];
            }
            else if([[LoginModel sharedInstance] profilePicUrl] == nil){ // new user no pic
                
                int width = SCREEN_WIDTH * .7361;
                
                VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:[UIImage imageNamed:@"crop_default"] cropFrame:CGRectMake((SCREEN_WIDTH - width)/2,0.122*SCREEN_HEIGHT, width, 0.655*SCREEN_HEIGHT) limitScaleRatio:3.0];
                
                
                imgCropperVC.delegate = self;
                imgCropperVC.isImageAdded = YES;
                
                [self.navigationController pushViewController:imgCropperVC animated:YES];
            }
            else // If there is no dto comes from login api response
                if ([[LoginModel sharedInstance].gender isEqualToString:@"FEMALE"]){
                    [ProfileAPIClass fetchDataForUserWithUserID:[[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] longLongValue] withCompletionBlock:^(id response, BOOL success, int status) {
                        
                        if (status == 200){
                            APP_DELEGATE.onBaordingPageNumber++;
                            WizardPhotoViewController *photoViewController = [[WizardPhotoViewController alloc] initWithNibName:@"WizardPhotoViewController" bundle:[NSBundle mainBundle]];
                            [self.navigationController pushViewController:photoViewController animated:true];
                        }
                    }];
                }
                else{
                    [APP_Utilities sendToDiscover];
                }
        }
    }];
}



#pragma mark - VPIImage Cropper Delegate

#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(NSDictionary *)editedImageData {
    
    //    self.portraitImageView.image = [editedImageData objectForKey:@"imageObj"];
    [cropperViewController.navigationController popViewControllerAnimated:NO];
    [APP_Utilities sendToDiscover];

    
    
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    
    [cropperViewController.navigationController popViewControllerAnimated:NO];
    [APP_Utilities sendToDiscover];
}


#pragma mark - Login Error Feedback Delegate
- (void)gettingResponseFromLoginErrorFeebackWithLoginErrorReference:(LoginErrorFeedbackViewController *)errorFeedback{
    
    [errorFeedback dismissViewControllerAnimated:YES completion:^{
        [self.navigationController popToRootViewControllerAnimated:false];
    }];
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
