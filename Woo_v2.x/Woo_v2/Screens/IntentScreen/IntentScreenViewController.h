//
//  OnboardingViewController.h
//  OnboardingSprint
//
//  Created by Suparno Bose on 11/05/16.
//  Copyright © 2016 Umesh Mishra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntentScreenViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource>{
    IntentType selectedIntent;
    
//    SelectedGenderPreference genderPreferenceForCasual;
//    SelectedGenderPreference genderPreferenceForLove;
//    SelectedGenderPreference genderPreferenceForFriend;
//    
    SelectedGenderPreference genderPreference;
    
    __weak IBOutlet UIButton *femaleButton;
    __weak IBOutlet UIButton *maleButton;
    NSMutableArray *detailArray;
    
    IBOutlet NSLayoutConstraint *topViewHeightConstraint;
    IBOutlet NSLayoutConstraint *topView_TitleLabelTopMarginConstraint;
    IBOutlet NSLayoutConstraint *topView_TableViewHeightConstraint;
    
    IBOutlet NSLayoutConstraint *trailingMarginOfAddButton_MinWheel;
    IBOutlet NSLayoutConstraint *leadingMarginOfSubtractButton_MinWheel;
    
    IBOutlet NSLayoutConstraint *trailingMarginOfAddButton_MaxWheel;
    IBOutlet NSLayoutConstraint *leadingMarginOfSubtractButton_MaxWheel;
    
}

-(IBAction)backButtonClicked:(id)sender;
-(IBAction)moveToNextScreen:(id)sender;

-(BOOL)willAtleastOneGenderPreferenceBeSelected:(BOOL) isGenderSelected withSelectedGenderPref:(GenderPreference)tappedGenderButton andSelectedIntent:(IntentType)mySelectedIntent;

- (IBAction)femaleButtonTapped:(id)sender;
- (IBAction)maleButtonTapped:(id)sender;

@end
