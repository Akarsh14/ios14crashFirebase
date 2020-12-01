//
//  AgeGenderViewController.h
//  Woo_v2
//
//  Created by Deepak Gupta on 6/6/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICircularSlider.h"

@interface AgeGenderViewController : BaseViewController
{
    __weak IBOutlet UIButton    *btnMale;
    __weak IBOutlet UIButton    *btnFemale;
    
    __weak IBOutlet UIView      *viewGender;
    __weak IBOutlet UIView      *viewAge;
    
    __weak IBOutlet NSLayoutConstraint *genderView_y;
    
    __weak IBOutlet UICircularSlider        *ageSlider;
    
    __weak IBOutlet UILabel                 *lblSliderValue;
    
    __weak IBOutlet UIButton                *nextBtn;
    
    __weak IBOutlet UILabel                 *lblPageNumber;

    
    __weak IBOutlet UILabel                 *lblAgeTitleLabel;
    __weak IBOutlet UILabel                 *lblGenderTitleLabel;


    
    NSString *      selectedGender;


}

- (IBAction)maleFemaleButtonClicked:(UIButton *)sender;
- (IBAction)nextButtonClicked:(id)sender;

@end
