//
//  BoatScreenViewController.m
//  Woo_v2
//
//  Created by Deepak Gupta on 5/19/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "BoatScreenViewController.h"
#import "SDWebImageDownloader.h"
#import "Woo_v2-Swift.h"
#import "VPImageCropperViewController.h"
#import "AgeGenderViewController.h"
#import "StartScreenAPIClass.h"
//#define DISCOVER_TEST 1

@interface BoatScreenViewController ()<VPImageCropperDelegate>

@end

@implementation BoatScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    buttonBottom.contentEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);


    [self performSelector:@selector(settingLayerOnUI) withObject:nil afterDelay:0.1];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    APP_DELEGATE.onBaordingPageNumber =  ON_BOARDING_PAGE_NUMBER_NONE;
    self.navigationController.navigationBarHidden = YES;
    
    [self performSelector:@selector(loadingDataOnUI) withObject:nil afterDelay:0.1];
    
    [self setBackGroundGradientColor];
}


- (void)setBackGroundGradientColor{
    
    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
    gradientLayer.frame = self.view.bounds;
    NSArray *gradientColor = [NSArray arrayWithObjects:kBoatTopColor.CGColor ,kBoatBottomColor.CGColor , nil];
    gradientLayer.colors = gradientColor;
    gradientLayer.startPoint = CGPointMake(1.0, 0.3);
    gradientLayer.endPoint = CGPointMake(1.0, 1.0);
    [self.view.layer insertSublayer:gradientLayer atIndex:0];
    
}

-(void) settingLayerOnUI{
    
//    imgView.layer.cornerRadius = imgView.frame.size.height/2;
//    [imgView.layer setMasksToBounds:YES];
//    [imgView.layer setBorderWidth:2.0f];
//    imgView.layer.borderColor = [UIColor whiteColor].CGColor;
    
}


- (void)setTitleLabelForMiddleViewWithFirstBody : (NSString *)body1 withSecondBody : (NSString *)body2{
    
    if (body1 == nil || body2 == nil){
        return;
    }
    
    UIFont *arialFont = [UIFont fontWithName:@"Candela-Book" size:14.0];
    NSDictionary *arialDict = [NSDictionary dictionaryWithObject: arialFont forKey:NSFontAttributeName];
    NSMutableAttributedString *aAttrString = [[NSMutableAttributedString alloc] initWithString:body1 attributes: arialDict];
    
    UIFont *VerdanaFont = [UIFont fontWithName:@"Candela-Book" size:20.0];
    NSDictionary *verdanaDict = [NSDictionary dictionaryWithObject:VerdanaFont forKey:NSFontAttributeName];
    NSMutableAttributedString *vAttrString = [[NSMutableAttributedString alloc]initWithString:body2 attributes:verdanaDict];
    
    [aAttrString appendAttributedString:vAttrString];
    
    
    titleMiddleView.attributedText = aAttrString;

}

- (void) loadingDataOnUI{

    titleLabel.text = [LoginModel sharedInstance].startScreenTitle;

    body.text = [LoginModel sharedInstance].startScreenBody3;

    footer.text = [LoginModel sharedInstance].startScreenFooter;

    [buttonBottom setTitle:[LoginModel sharedInstance].startScreenButtonText forState:UIControlStateNormal];

    [self setTitleLabelForMiddleViewWithFirstBody:[LoginModel sharedInstance].startScreenBody1 withSecondBody:[NSString stringWithFormat:@" %@",[LoginModel sharedInstance].startScreenBody2]];
    
    
//  NSURL *   croppedImageURL = [NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(110),IMAGE_SIZE_FOR_POINTS(110), [APP_Utilities encodeFromPercentEscapeString:[[LoginModel sharedInstance].startScreenImageUrl absoluteString]]];
//    
//    
//    NSString *placeHolderImageStr = [APP_Utilities isGenderMale:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserGender]] ? @"placeholder_male" : @"placeholder_female";
//    
//    [imgView sd_setImageWithURL:croppedImageURL
//               placeholderImage:[UIImage imageNamed:placeHolderImageStr]];

    
    
    
    
    
    [imgView sd_setImageWithURL:[LoginModel sharedInstance].startScreenImageUrl completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
        }];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)startButtonClicked:(id)sender{
    
//    [self performSegueWithIdentifier:kIntentScreenControllerID sender:nil];
//    return;
//    [self performSegueWithIdentifier:kAgeGenderControllerID sender:nil];
//    return;
    
    [APP_DELEGATE sendSwrveEventWithEvent:@"3-Onboarding.Onboard_Prep.Prep_Start" andScreen:@"Onboard_Prep"];
    
    if (![APP_Utilities reachable]){
        
        [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];


        return;
    }
    
    
    [StartScreenAPIClass makeStartScreenCallWithCompletionBlock:^(id response, BOOL success , int statusCode) {
        
        if (statusCode == 401) { // Authentication Failed
            [self handleErrorForResponseCode:401];
            return;
        }
        
        if (success) {
            NSLog(@"START SCREEN SEEN DONE");
        }
    }];
    
#ifdef DISCOVER_TEST
    [[WooScreenManager sharedInstance] loadDrawerView];
#else
    if ([LoginModel sharedInstance].age == 0 || [[LoginModel sharedInstance].gender isEqualToString:@"UNKNOWN"]){ // Showing Age Gender Screen
        APP_DELEGATE.onBaordingPageNumber++;
        [self performSegueWithIdentifier:kAgeGenderControllerID sender:nil];
    }
    else if ([[LoginModel sharedInstance] favIntent] != INTENT_TYPE_NONE){ // Showing Intent Screen
        APP_DELEGATE.onBaordingPageNumber++;

        [self performSegueWithIdentifier:kIntentScreenControllerID sender:nil];
    }
    else if (LoginModel.sharedInstance.userLifestyleTagsAvailable == false || LoginModel.sharedInstance.userRelationshipTagsAvailable == false) {
        APP_DELEGATE.onBaordingPageNumber++;
        RelationshipViewController *relationshipController = [RelationshipViewController loadNib:@"Relationship and Lifestyle"];
        [relationshipController setViewsfor:1 tagData:0 closeBtn:false title:@"Relationship and Lifestyle"];
        [self.navigationController pushViewController:relationshipController animated:true];
        
    }
    else if(![[LoginModel sharedInstance] userOtherTagsAvailable]){       //changed condition as if the value is true user should not see the tag screen
        APP_DELEGATE.onBaordingPageNumber++;
        //[self performSegueWithIdentifier:kTagScreenControllerID sender:nil];
        
        WizardTagsViewController *wizardTagsVC = [[WizardTagsViewController alloc] initWithNibName:@"WizardTagsViewController" bundle:nil];
        [wizardTagsVC setIsUsedOutOfWizard:true];
        [wizardTagsVC setIsPartOfOnboarding:true];
        [self.navigationController pushViewController:wizardTagsVC animated:true];
    }
    else if([[LoginModel sharedInstance] aboutMetext] && [[LoginModel sharedInstance] aboutMeDefault]){ // Showing About Me Screen.
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
            APP_DELEGATE.onBaordingPageNumber++;
            WizardPhotoViewController *photoViewController = [[WizardPhotoViewController alloc] initWithNibName:@"WizardPhotoViewController" bundle:[NSBundle mainBundle]];
            [self.navigationController pushViewController:photoViewController animated:true];
        }
        else{
        [APP_Utilities sendToDiscover];
        }

#endif
    
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




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
