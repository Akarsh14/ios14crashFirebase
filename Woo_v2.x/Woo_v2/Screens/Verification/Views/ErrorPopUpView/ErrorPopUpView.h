//
//  ErrorPopUpView.h
//  Woo_v2
//
//  Created by Umesh Mishra on 05/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ErrorPopUpView : UIView{
    
    __weak IBOutlet UIView *centerContainerView;
    __weak IBOutlet UIView *headerView;
    __weak IBOutlet UIView *genderOptionView;
    __weak IBOutlet UIView *dobOptionView;
    __weak IBOutlet UIView *footerView;
    
    __weak IBOutlet UIButton *femaleButton;
    __weak IBOutlet UIButton *maleButton;
    
    
    __weak IBOutlet UILabel *dobYearLabel;
    __weak IBOutlet UILabel *dobMonthLabel;
    __weak IBOutlet UILabel *dobDateLabel;
    
    __weak IBOutlet UIButton *okButton;
    

    __weak IBOutlet NSLayoutConstraint *heightConstraint;
    
    __weak IBOutlet UILabel *headerLabelObj;
}

@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) SEL selectorForOkButtonTapped;

@property (nonatomic, assign) GenderOptions selectedGender;
@property (nonatomic, retain) NSString *dobString;

-(IBAction)okButtonTapped:(id)sender;

-(IBAction)genderSelectionButtonTapped:(id)sender;
-(IBAction)showDatePickerView:(id)sender;

@property (nonatomic, assign)VerificationErrorType verificationErrorObj;

-(void)setUpViewAccordingToError;

-(void)checkAndUnableOkButton;

@end
