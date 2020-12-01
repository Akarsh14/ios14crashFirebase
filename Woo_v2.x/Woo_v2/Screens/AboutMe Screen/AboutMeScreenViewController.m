//
//  AboutMeScreenViewController.m
//  Woo_v2
//
//  Created by Deepak Gupta on 5/17/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "AboutMeScreenViewController.h"
#import "IQKeyboardManager.h"
#import "VPImageCropperViewController.h"
#import "NoInternetScreenView.h"
#import "Woo_v2-Swift.h"

@interface AboutMeScreenViewController ()<VPImageCropperDelegate, UITextViewDelegate>{
   
    NSInteger maxCharacter;
    NSInteger minCharacter;
    NSString *placeholderText;
    WooLoader *customLoader;
    BOOL isCloseTapped;
    BOOL isChanged;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *introduceLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UIButton *wizardBackButton;
@property (weak, nonatomic) IBOutlet UIButton *wizardNextButton;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UIView *nextBackView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLabelHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wizardBottomViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *postButton;
@property (weak, nonatomic) IBOutlet UILabel *placeHolderLabel;
@property (weak, nonatomic) IBOutlet UILabel *stickLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stickLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineTopBottomConstraint;

@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *limitLabelDiscoverWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *limitCountDiscoverLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *introduceLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *wizardBackNextView;
@property (weak, nonatomic) IBOutlet UILabel *viewCounterLabel;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stickLabelHeightConstraint;

@end

@implementation AboutMeScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    isCloseTapped = false;
    [APP_DELEGATE sendSwrveEventWithEvent:@"3-Onboarding.Onboard_PersonalQuote.PQ_Landing" andScreen:@"Onboard_PersonalQuote"];
    //[self performSelector:@selector(openKeyboard) withObject:nil afterDelay:0.8];

    NSLog(@"ONBOARDING PAGE NUMBER = %d",APP_DELEGATE.onBaordingPageNumber);
    if (APP_DELEGATE.onBaordingPageNumber <= ON_BOARDING_PAGE_NUMBER_ONE && !LoginModel.sharedInstance.isAlternateLogin){
        btnBack.hidden = YES;
    }else{
       if (_isThisFirstScreenAfterRegistration){
            btnBack.hidden = YES;
        }
        else{
            btnBack.hidden = NO;
        }
    }
//    else if (LoginModel.sharedInstance.isAlternateLogin){
        
//    }
    
    [lblPageNumber setText:[NSString stringWithFormat:@"%d of %d",APP_DELEGATE.onBaordingPageNumber , APP_DELEGATE.totalOnboardingPages]];
    if (!_isOpenedFromWizard){
        _textViewHeightConstraint.constant =  (IS_IPHONE_5) ? 100 : 180;
        _lineTopBottomConstraint.constant = 215;
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
}

- (void)keyboardWillShow:(NSNotification *)aNotification {
    
    NSDictionary *userInfo = aNotification.userInfo;
    
    NSValue *endFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardEndFrame = [self.view convertRect:endFrameValue.CGRectValue fromView:nil];
    
    //    NSValue *beginFrameValue = userInfo[UIKeyboardFrameBeginUserInfoKey];
    //    CGRect keyboardBeginFrame = [self.view convertRect:beginFrameValue.CGRectValue fromView:nil];
    
    NSLog(@"end frame == %f",keyboardEndFrame.size.height);
    if (keyboardEndFrame.size.height > 100) {
        limitCountBottomConstraintObj.constant = keyboardEndFrame.size.height+30;
    }
}





- (void)showStickViewRelatedNow{
    [_lineView setHidden:false];
    [_stickLabel setHidden:false];
    [lblLimitCount setHidden:false];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];

    if (_isOpenedFromWizard){
         btnBack.hidden = NO;
        isChanged = false;
    }else{
        [_introduceLabel setText:@"Introduce yourself to meet\nlike-minded people"];
    }
    if (![APP_Utilities reachable]){
        [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];
    }
    
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:FALSE];
    [[IQKeyboardManager sharedManager] setEnable:true];
   
    //[self openKeyboard];
    [textViewObj becomeFirstResponder];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasDismissed:) name:UIKeyboardDidHideNotification object:nil];
    
    if (self.isOpenedFromWizard){
        
        [[Utilities sharedUtility] sendFirebaseEventWithScreenName:@"" withEventName:@"AnalyzeProfile_MyStory_Landing"];
        
        if ([WizardScreensCalculator sharedInstance].currentWizardScreen == [WizardScreensCalculator sharedInstance].wizardScreenArray.count){
            [_wizardNextButton setTitle:NSLocalizedString(@"Done", nil)  forState:UIControlStateNormal];
        }
        else if ([WizardScreensCalculator sharedInstance].currentWizardScreen == 1){
            [_wizardBackButton setHidden:true];
        }
        
      
        _viewCounterLabel.text = [NSString stringWithFormat:@"%d of %d",[WizardScreensCalculator sharedInstance].currentWizardScreen,[WizardScreensCalculator sharedInstance].wizardScreenArray.count];
        
        
        if (SCREEN_WIDTH == 320){
            _topLabelBottomConstraint.constant =
            (_isOpenedFromWizard) ? 10 : 45;
            
            _topLabelTopConstraint.constant = 15;
            _introduceLabelTopConstraint.constant = 0;
            [_topLabel setFont:[UIFont fontWithName:@"Lato-Black" size:22.0]];
            [_introduceLabel setFont:[UIFont fontWithName:@"Lato-Medium" size:14.0]];
        }
        else{
            _topLabelBottomConstraint.constant =
            (_isOpenedFromWizard) ? 20 : 80;
            _textViewHeightConstraint.constant = 100;
            _topLabelTopConstraint.constant = 40;
        }
        [_introduceLabel setHidden:false];
        [_wizardBackNextView setHidden:false];
        [_nextBackView setHidden:true];
        lblLimitCount.textColor = [[Utilities sharedUtility] getUIColorObjectFromHexString:@"#72778A" alpha:1.0];
        [_topLabel setText:NSLocalizedString(@"My Story", nil)];
        [_topLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:30.0f]];
        _topLabel.textColor = [[Utilities sharedUtility] getUIColorObjectFromHexString:@"#75DB87" alpha:1.0];
       // _lineView.backgroundColor = [[Utilities sharedUtility] getUIColorObjectFromHexString:@"#E5E7EB" alpha:1.0];
        [_stickLabelHeightConstraint setConstant:50.0];
        [self showStickViewRelatedNow];
       minCharacter = 0;
        maxCharacter = 300;
        placeholderText = @"Tell them about yourself, your life, interests, beliefs etc. Genuine and witty works best.";
       NSMutableAttributedString *newString = [[NSMutableAttributedString alloc] initWithAttributedString:[[NSAttributedString alloc] initWithString:placeholderText]];
//
//        NSRange changeRange2 = (NSRange){0,[newString length]};
//        UIFont *replacementFont2 =  [UIFont fontWithName:@"Lato-Regular" size:13.0];
//        UIColor *mainColor = [[Utilities sharedUtility] getUIColorObjectFromHexString:@"#AEAEAE" alpha:1.0];
//        [newString addAttribute:NSForegroundColorAttributeName value:mainColor range:changeRange2];
//        [newString addAttribute:NSFontAttributeName value:replacementFont2 range:changeRange2];
//
//        NSRange changeRange1 = (NSRange){0,[newString length] - 90};
//        UIFont *replacementFont1 =  [UIFont fontWithName:@"Lato-Regular" size:16.0];
//        UIColor *boldColor = [[Utilities sharedUtility] getUIColorObjectFromHexString:@"#7F7F7F" alpha:1.0];
//        [newString addAttribute:NSForegroundColorAttributeName value:boldColor range:changeRange1];
//        [newString addAttribute:NSFontAttributeName value:replacementFont1 range:changeRange1];
//
        placeholderLbl.attributedText = newString;
        [placeholderLbl setHidden:true];
        self.view.backgroundColor = [UIColor whiteColor];
        _limitCountDiscoverLabel.hidden = true;
        _limitLabelDiscoverWidthConstraint.constant = 0;
        textViewObj.textColor = [[Utilities sharedUtility] getUIColorObjectFromHexString:@"#373A43" alpha:1.0f];
        if ([DiscoverProfileCollection sharedInstance].myProfileData.personalQuote != nil && [DiscoverProfileCollection sharedInstance].myProfileData.personalQuote.length > 0){
            textViewObj.text = [DiscoverProfileCollection sharedInstance].myProfileData.personalQuote;
        }
        else{
            textViewObj.text = @"";
        }
        //        if (textViewObj.text.length > 0) {
        //            [placeholderLbl setHidden:true];
        //        }
        //        else{
        //            [placeholderLbl setHidden:false];
        //        }
        
        
        
    }
    else{
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isOnboardingMyProfileShown"] == true){
            [LoginModel sharedInstance].personalQuoteText = @"Introduce yourself to meet like-minded people";
            [_textViewHeightConstraint setConstant:127.0];
            [_stickLabelHeightConstraint setConstant:50.0];
            [_stickLabel setHidden:false];
        }
        else{
            [LoginModel sharedInstance].personalQuoteText = @"Write about yourself…";
        }
        [LoginModel sharedInstance].personalQuoteMaxCharLength = 300;
        [LoginModel sharedInstance].personalQuoteMinCharLength = 0;
        minCharacter = [LoginModel sharedInstance].personalQuoteMinCharLength;
        maxCharacter = [LoginModel sharedInstance].personalQuoteMaxCharLength;
        placeholderText = [LoginModel sharedInstance].personalQuoteText;
        
        NSMutableAttributedString *newString = [[NSMutableAttributedString alloc] initWithAttributedString:[[NSAttributedString alloc] initWithString:placeholderText]];
        
        NSRange changeRange1;
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isOnboardingMyProfileShown"] == false){
            NSRange changeRange2 = (NSRange){0,[newString length]};
            UIFont *replacementFont2 =  [UIFont fontWithName:@"Lato-Regular" size:14.0];
            [newString addAttribute:NSFontAttributeName value:replacementFont2 range:changeRange2];
            changeRange1 = (NSRange){0,[newString length]};
        }
        else{
            changeRange1 = (NSRange){0,[newString length]};
        }
        
        UIFont *replacementFont1 =  [UIFont fontWithName:@"Lato-Regular" size:16.0];
        [newString addAttribute:NSFontAttributeName value:replacementFont1 range:changeRange1];
        
        placeholderLbl.attributedText = newString;
        [_introduceLabel setHidden:true];
        [_closeButton setHidden:true];
        [_wizardBackNextView setHidden:true];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isOnboardingMyProfileShown"] == true){
            [_postButton setTitle:NSLocalizedString(@"SAVE",nil) forState:UIControlStateNormal];
            _nextBackView.hidden = true;
            _topLabel.hidden = true;
            _topLabelHeightConstraint.constant = 0;
            _lineView.hidden = true;
            lblLimitCount.hidden = true;
            self.view.backgroundColor = [UIColor whiteColor];
            placeholderLbl.textColor = [[Utilities sharedUtility] getUIColorObjectFromHexString:@"#5F6377" alpha:0.7f];
            textViewObj.textColor = [[Utilities sharedUtility] getUIColorObjectFromHexString:@"#373A43" alpha:1.0f];
             [[Utilities sharedUtility]colorStatusBar:[[Utilities sharedUtility] getUIColorObjectFromHexString:@"#9275DB" alpha:1.0f] ];
             _headerView.hidden = false;
            _limitCountDiscoverLabel.hidden = false;
            //_limitLabelDiscoverWidthConstraint.constant = 0;
        }
        else{
            [[Utilities sharedUtility]colorStatusBar:[[Utilities sharedUtility] getUIColorObjectFromHexString:@"#75C4DB" alpha:1.0f] ];
            [[Utilities sharedUtility] sendMixPanelEventWithName:@"OnBoarding_PQ_Landing"];
            placeholderLbl.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.7f];
            textViewObj.textColor = [UIColor whiteColor];
            _headerView.hidden = true;
            _limitCountDiscoverLabel.hidden = true;
            _limitLabelDiscoverWidthConstraint.constant = 0;
            [lblLimitCount setHidden:false];
            [_lineView setHidden:false];
        }
        
//        if ([LoginModel sharedInstance].isAlternateLogin){
            [lblPageNumber setHidden:true];
            
//        }
    }
    [self updateLimitCount];


}
-(void)openKeyboard{
    dispatch_async(dispatch_get_main_queue(), ^{
        [textViewObj becomeFirstResponder];
    });
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [super viewDidDisappear:animated];
}

- (void)showWooLoader{
    if (customLoader != nil){
        [customLoader removeFromSuperview];
        customLoader = nil;
    }
    if (customLoader == nil){
        CGRect loaderFrame = CGRectMake(0, 34, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64);
        customLoader = [[WooLoader alloc] initWithFrame:loaderFrame];
    }
    [customLoader setShouldShowWooLoader:false];
    [customLoader startAnimationOnView:self.view WithBackGround:false];
}

- (void)hideWooLoader{
    [UIView animateWithDuration:0.25 animations:^{
        
    } completion:^(BOOL finished) {
        [customLoader stopAnimation];
        [customLoader removeFromSuperview];
        customLoader = nil;
    }];
}

- (void)checkIfToShowDiscoverOrMe{
    if ([DiscoverProfileCollection sharedInstance].discoverModelCollection.count > 0){
        [[[WooScreenManager sharedInstance] oHomeViewController] moveToTab:1];
    }
    else{
        [[[WooScreenManager sharedInstance] oHomeViewController] moveToTab:0];
    }
}


- (void)showWizardCompleteView:(BOOL)isCompleted{
    WizardCompleteView *wizardPopupView = [WizardCompleteView showView:isCompleted];

    [wizardPopupView setCloseWizardHandler:^{
        [self checkIfToShowDiscoverOrMe];
        if (isCompleted && isChanged){
            [[WizardScreensCalculator sharedInstance] makeDiscoverCallIfRequired];
        }
        [self.navigationController popToRootViewControllerAnimated:true];
    }];
}

- (BOOL)checkIfFlowIsComplete{
    if ([WizardScreensCalculator sharedInstance].currentWizardScreen == [WizardScreensCalculator sharedInstance].wizardScreenArray.count){
        return true;
    }
    else{
        return false;
    }
}

#pragma mark ------------ Button Action Event -------------

- (IBAction)close:(id)sender {
    [textViewObj resignFirstResponder];
    isCloseTapped = true;
    if (![APP_Utilities reachable]){
        [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];
        return;
    }
    [[Utilities sharedUtility] sendFirebaseEventWithScreenName:@"" withEventName:@"AnalyzeProfile_MyStory_Close"];
    if ([self isValueChanged]){
        [[Utilities sharedUtility] sendFirebaseEventWithScreenName:@"" withEventName:@"AnalyzeProfile_MyStory_Type"];
    [self showWooLoader];
    [self sendUserStoryDataToServer];
    }
    else{
        
            int profileCompleteness = [DiscoverProfileCollection sharedInstance].myProfileData.profileCompletenessScore.intValue;
            int profileCompletenessFallbackThreshold =
            (int)[AppLaunchModel sharedInstance].profileCompletenessFallbackThreshold;
            if (profileCompleteness < profileCompletenessFallbackThreshold){
                [self showWizardCompleteView:false];
            }
            else{
                if ([self checkIfFlowIsComplete]) {
                    [self showWizardCompleteView:true];
                }
                else{
                [self checkIfToShowDiscoverOrMe];
                [self.navigationController popToRootViewControllerAnimated:true];
                }
            }
    }
}

-(IBAction)nextButtonClicked:(id)sender{
    [textViewObj resignFirstResponder];
    
    if (_isOpenedFromWizard){
        if (![APP_Utilities reachable]){
            [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];
            return;
        }
        [[Utilities sharedUtility] sendFirebaseEventWithScreenName:@"" withEventName:@"AnalyzeProfile_MyStory_Landing"];

    if ([self isValueChanged]){
        [[Utilities sharedUtility] sendFirebaseEventWithScreenName:@"" withEventName:@"AnalyzeProfile_MyStory_Type"];
        isCloseTapped = false;
    BOOL isFlowComplete = [self checkIfFlowIsComplete];
    if (isFlowComplete){
        [self showWooLoader];
        [self sendUserStoryDataToServer];
    }
    else{
        [self sendUserStoryDataToServer];
        [[WizardScreensCalculator sharedInstance] moveToNextScreenForIndex];
      }
     }
    else{
        isCloseTapped = false;
        BOOL isFlowComplete = [self checkIfFlowIsComplete];
        if (isFlowComplete){
            [self showWizardCompleteView:true];
        }
        else{
            [[WizardScreensCalculator sharedInstance] moveToNextScreenForIndex];
        }
    }
    }
    else{
        if (![APP_Utilities reachable]){
            if([[LoginModel sharedInstance] profilePicUrl] == nil){
                [self showNoInternetScreen];
                return;
            }
            
            [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];
            
            return;
        }
        [self checkingConditionForSendingAboutMeDataToServer];
    }
    
}

-(IBAction)backButtonClicked:(id)sender{
    
    [textViewObj resignFirstResponder];
    
    if (_isOpenedFromWizard){
        [WizardScreensCalculator sharedInstance].currentWizardScreen--;
        
    }
    else{
        if (![APP_Utilities reachable]){
            
            [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];
            
            return;
        }
        
        APP_DELEGATE.onBaordingPageNumber--;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
   
}

- (BOOL)isValueChanged{
    if (([DiscoverProfileCollection sharedInstance].myProfileData.personalQuote == nil) || ([[DiscoverProfileCollection sharedInstance].myProfileData.personalQuote length] <= 0)){
        if ([textViewObj.text length] > 0){
            isChanged = true;
        }
        else{
            isChanged = false;
        }
    }
    else{
        NSString *personalQoute = [[DiscoverProfileCollection sharedInstance].myProfileData.personalQuote stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *textviewText = [textViewObj.text stringByReplacingOccurrencesOfString:@" " withString:@""];


        NSLog(@"personalqoute = %@",[DiscoverProfileCollection sharedInstance].myProfileData.personalQuote);
        if ([personalQoute isEqualToString:textviewText]){
            isChanged = false;
        }
        else{
            isChanged = true;
        }
    }
    return isChanged;
}

- (void)sendUserStoryDataToServer{
    
    NSMutableDictionary *myProfileDictionary = [NSMutableDictionary dictionary];
    [myProfileDictionary setValue:[APP_Utilities encodeFromPercentEscapeString:[APP_Utilities validString:textViewObj.text]] forKey:@"personalQuote"];
    [[WizardScreensCalculator sharedInstance] updateProfileForDictionary:[[DiscoverProfileCollection sharedInstance].myProfileData jsonfyForDictionary:myProfileDictionary]];
    
    [[WizardScreensCalculator sharedInstance] setEditProfileApiCompletionHandler:^(BOOL success) {
        [self hideWooLoader];
        if (![self.navigationController.viewControllers.lastObject isKindOfClass:[AboutMeScreenViewController class]]){
            [[WizardScreensCalculator sharedInstance] makeDiscoverCallIfRequired];
            return;
        }
        if (isCloseTapped){
            isCloseTapped = false;
        if (success){
            
            int profileCompleteness = [DiscoverProfileCollection sharedInstance].myProfileData.profileCompletenessScore.intValue;
            int profileCompletenessFallbackThreshold =
            (int)[AppLaunchModel sharedInstance].profileCompletenessFallbackThreshold;
            if (profileCompleteness < profileCompletenessFallbackThreshold){
                isChanged = false;
                [self showWizardCompleteView:false];
            }
            else{
                if ([self checkIfFlowIsComplete]) {
                    [self showWizardCompleteView:true];
                }
                else{
                    isChanged = false;
                    [self checkIfToShowDiscoverOrMe];
                    [self.navigationController popToRootViewControllerAnimated:true];
                }
            }
        }
        }
        else{
            if (success){
                if ([self checkIfFlowIsComplete]) {
                    [self showWizardCompleteView:true];
                }
                else{
                    [[WizardScreensCalculator sharedInstance] makeDiscoverCallIfRequired];
                }
            }
        }
    }];
}


- (void) checkingConditionForSendingAboutMeDataToServer{
    
    if ([LoginModel sharedInstance].aboutMeRequired) {
        if ([[APP_Utilities validString:textViewObj.text] length] >= [LoginModel sharedInstance].aboutMeMinCharLength && [[APP_Utilities validString:textViewObj.text] length] <= maxCharacter) {
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isOnboardingMyProfileShown"] == true){
                NSMutableDictionary *myProfileDictionary = [NSMutableDictionary dictionary];
                [myProfileDictionary setValue:[APP_Utilities encodeFromPercentEscapeString:[APP_Utilities validString:textViewObj.text]] forKey:@"personalQuote"];
                [[WizardScreensCalculator sharedInstance] updateProfileForDictionary:[[DiscoverProfileCollection sharedInstance].myProfileData jsonfyForDictionary:myProfileDictionary]];
                [self moveToNextScreen];
            }
            else{
            [self sendAboutMeInfoToServer:[APP_Utilities validString:textViewObj.text]];
            }
        }else{
            
            [APP_DELEGATE sendSwrveEventWithEvent:@"3-Onboarding.Onboard_PersonalQuote.PQ_CharCount_SnackBar" andScreen:@"Onboard_PersonalQuote"];

            [APP_Utilities addingNoInternetSnackBarWithText:[NSString stringWithFormat:NSLocalizedString(@"Please enter at least %d characters.", @"Please enter at least %d characters."),[[LoginModel sharedInstance] aboutMeMinCharLength]] withActionTitle:@"" withDuration:3.0];

        }
    }else{
        if ([[APP_Utilities validString:textViewObj.text] length] > 0) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isOnboardingMyProfileShown"] == true){
                NSMutableDictionary *myProfileDictionary = [NSMutableDictionary dictionary];
                [myProfileDictionary setValue:[APP_Utilities encodeFromPercentEscapeString:[APP_Utilities validString:textViewObj.text]] forKey:@"personalQuote"];
                [[WizardScreensCalculator sharedInstance] updateProfileForDictionary:[[DiscoverProfileCollection sharedInstance].myProfileData jsonfyForDictionary:myProfileDictionary]];
                [self moveToNextScreen];
            }
            else{
            [self sendAboutMeInfoToServer:[APP_Utilities validString:textViewObj.text]];
            }
        }else{
            [self moveToNextScreen];
        }
        
    }
    
}


#pragma mark - loading third screen
- (void)showNoInternetScreen{
    
    [textViewObj resignFirstResponder];
    NoInternetScreenView *noInternet = [[NoInternetScreenView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [noInternet setDelegate:self];
    [noInternet setShowLoader:YES];
    noInternet.tag = 10000;
    [self.view addSubview:noInternet];
    
}


#pragma mark - Refresh button clicked
- (void)refreshButtonClicked:(UIButton *)sender{
    
    if ([APP_Utilities reachable]){
        [self removeNoInternetScreen];
        [self checkingConditionForSendingAboutMeDataToServer];
    }
    
}


- (void) removeNoInternetScreen{
    
    for (UIView *view in self.view.subviews)
        if (view.tag == 10000)
            [view removeFromSuperview];
    
    
}

- (void)keyboardWasShown:(NSNotification *)notifObject{
    [self.view layoutIfNeeded];
    CGRect keyboardRect = [[[notifObject userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize keyboardSize = keyboardRect.size;
    int heightInInt =  (int)keyboardSize.height;
    int widthInInt = (int)keyboardSize.width;
    int height = MIN(heightInInt, widthInInt);
    CGFloat expectedKeyBoardHeight = (CGFloat)height;
    if (expectedKeyBoardHeight > 216) {
        _bottomViewBottomConstraint.constant = expectedKeyBoardHeight + 10;
        _wizardBottomViewBottomConstraint.constant = expectedKeyBoardHeight;
    }
    else{
        _bottomViewBottomConstraint.constant = 216 + 10;
        _wizardBottomViewBottomConstraint.constant = 216;
    }
    
    if (_isOpenedFromWizard){
        [_stickLabelBottomConstraint setConstant:expectedKeyBoardHeight + 50];
   }
    else{
    [_stickLabelBottomConstraint setConstant:expectedKeyBoardHeight + 10];
        _textViewHeightConstraint.constant =  (IS_IPHONE_5) ? 100 : 200;
        _lineTopBottomConstraint.constant = expectedKeyBoardHeight + 60;
        
    }
    
    CGFloat safeAreaBottom = [[Utilities sharedUtility] getSafeAreaForTop:false andBottom:true];
    if (IS_IPHONE_XS_MAX || IS_IPHONE_X){
        if (keyboardSize.height > 0){
            if (_isOpenedFromWizard){
                _wizardBottomViewBottomConstraint.constant = expectedKeyBoardHeight - safeAreaBottom;
                [_stickLabelBottomConstraint setConstant:expectedKeyBoardHeight + 50 - safeAreaBottom];
               // _lineTopBottomConstraint.constant = expectedKeyBoardHeight + 60 + safeAreaBottom;
            }
            else{
            _lineTopBottomConstraint.constant = expectedKeyBoardHeight + 60 - safeAreaBottom;
            }
            
        }
    }
   
    

   
    
    
    
    [UIView animateWithDuration:0.1 animations:^{
        [self.view layoutIfNeeded];
    }];

}

- (void)keyboardWasDismissed:(NSNotification *)notifObject{
    if (!_isOpenedFromWizard){
        [_stickLabelBottomConstraint setConstant:50];
    }
    _bottomViewBottomConstraint.constant = 20;
    _wizardBottomViewBottomConstraint.constant = 0;
    [UIView animateWithDuration:0.1 animations:^{
        [self.view layoutIfNeeded];
    }];
}




#pragma mark -------------- UITextView Delegate ---------------

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    [self updateLimitCount];
    
    if(range.location==0 && ![text isEqualToString:@""])
    {
        _placeHolderLabel.hidden = YES;
    }
    else if(range.location==0)
    {
        _placeHolderLabel.hidden = NO;
    }

    long finalTextLength = [[textView text] length] + [text length];
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        
        return NO;
    }else if(finalTextLength > maxCharacter && [text length] > 0 ){
        
        
        unsigned int pendingTextLength = maxCharacter - (int)[[textView text] length];
        
        if (pendingTextLength != 0 && ![APP_Utilities stringContainsEmoji:text] && pendingTextLength < [text length]){
            text = [text substringToIndex:pendingTextLength];
            textView.text = [NSString stringWithFormat:@"%@%@",textView.text,text];
            [self updateLimitCount];

        }
        return NO;
    }
    
    return YES;
}



-(void) textViewDidChange:(UITextView *)textView
{
    if (textView.text.length >= minCharacter)
            btnNext.enabled = TRUE;
    else
            btnNext.enabled = TRUE;
    
    if (!_isOpenedFromWizard){
    if (textView.text.length > 0) {
        [placeholderLbl setHidden:true];
    }
    else{
        [placeholderLbl setHidden:false];
    }
    }
    
    
    [self updateLimitCount];
    
}




- (void)updateLimitCount{
        int diff = maxCharacter - textViewObj.text.length;
    NSString *limitText= [@"Upto " stringByAppendingString:[NSString stringWithFormat:@"%d",diff]];
    lblLimitCount.text = limitText;
       _limitCountDiscoverLabel.text = limitText;
}


#pragma mark - Move to Next Screen
- (void)moveToNextScreen{
    
//    if ([LoginModel sharedInstance].isAlternateLogin){
        [APP_Utilities sendToDiscover];
//    }
//    else{
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isOnboardingMyProfileShown"] == false){
//    [APP_DELEGATE sendSwrveEventWithEvent:@"3-Onboarding.Onboard_PersonalQuote.PQ_Next" andScreen:@"Onboard_PersonalQuote"];
//    [self.view endEditing:YES];
//    if([[LoginModel sharedInstance] profilePicUrl] == nil){ // new user no pic
//
//        int width = SCREEN_WIDTH * .7361;
//
//        VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:[UIImage imageNamed:@"crop_default"] cropFrame:CGRectMake((SCREEN_WIDTH - width)/2,0.122*SCREEN_HEIGHT, width, 0.655*SCREEN_HEIGHT) limitScaleRatio:3.0];
//
//
//        imgCropperVC.delegate = self;
//        imgCropperVC.isImageAdded = YES;
//
//        [self.navigationController pushViewController:imgCropperVC animated:YES];
//    }else
//        if ([[LoginModel sharedInstance].gender isEqualToString:@"FEMALE"]){
//            [ProfileAPIClass fetchDataForUserWithUserID:[[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] longLongValue] withCompletionBlock:^(id response, BOOL success, int status) {
//                if (status == 200){
//                APP_DELEGATE.onBaordingPageNumber++;
//                WizardPhotoViewController *photoViewController = [[WizardPhotoViewController alloc] initWithNibName:@"WizardPhotoViewController" bundle:[NSBundle mainBundle]];
//                [self.navigationController pushViewController:photoViewController animated:true];
//                }
//            }];
//        }
//        else{
//        [APP_Utilities sendToDiscover];
//        }
//    }
//    else{
//        [self.navigationController popViewControllerAnimated:YES];
////        [self dismissViewControllerAnimated:true completion:^{
////        }];
//    }
//    }
    
}

#pragma mark --------------- API Call --------------
-(void)sendAboutMeInfoToServer:(NSString *)aboutMe{
    
    // #TO_BE_ENCODED
//    NSData *emojiData = [aboutMe dataUsingEncoding:NSNonLossyASCIIStringEncoding];
//    NSString *encodedString = [[NSString alloc] initWithData:emojiData encoding:NSUTF8StringEncoding];
    
    if ([DiscoverProfileCollection sharedInstance].myProfileData == nil){
    [DiscoverProfileCollection sharedInstance].myProfileData = [[MyProfileModel alloc] initWithUserInfoDto:[[NSDictionary alloc] init]];
    }
    [DiscoverProfileCollection sharedInstance].myProfileData.personalQuote = aboutMe;
    
    NSString *userWooID = [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId];
    
    NSString *aboutMeEncoded = [aboutMe stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            aboutMeEncoded,  @"aboutMeText",
                            userWooID,       @"wooId",
                            nil];
    
    NSString *aboutMeURL = [NSString stringWithFormat:@"%@%@?wooId=%@",kBaseURLV2,KSendAboutMeText,userWooID];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [manager setRequestSerializer:requestSerializer];
    
    [manager  POST:aboutMeURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSInteger statusCode = operation.response.statusCode;
        
        NSLog(@"RESPONSE : %@",responseObject);
        
        
        if (statusCode == 401) { // Authentication Failed
            [self handleErrorForResponseCode:401];
            return;
        }

        if (statusCode == 408) { // No Internet Scenario
            [self showNoInternetScreen];
            return ;
        }
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    } caching:GET_DATA_FROM_URL_ONLY andNumberOfRetries:3];
    
    [self moveToNextScreen];
}


#pragma mark - VPIImage Cropper Delegate

- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(NSDictionary *)editedImageData {
    
    //    self.portraitImageView.image = [editedImageData objectForKey:@"imageObj"];
    [cropperViewController.navigationController popViewControllerAnimated:NO];
    [APP_Utilities sendToDiscover];

    
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    
    [cropperViewController.navigationController popViewControllerAnimated:NO];
    [APP_Utilities sendToDiscover];
}

- (IBAction)dismiss:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    //[self dismissViewControllerAnimated:true completion:nil];
}
- (IBAction)postPersonalQoute:(id)sender {
    if (![APP_Utilities reachable]){
        [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];
        return;
    }
    
    [self checkingConditionForSendingAboutMeDataToServer];
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
