//
//  ErrorPopUpView.m
//  Woo_v2
//
//  Created by Umesh Mishra on 05/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "ErrorPopUpView.h"
#import "SWActionSheet.h"
#import "ActionSheetDatePicker.h"

@implementation ErrorPopUpView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        NSArray *arrayObj = [[NSBundle mainBundle] loadNibNamed:@"ErrorPopUpView" owner:self options:nil];
        UIView *viewObj = [arrayObj objectAtIndex:0];
        viewObj.frame = frame;
        [self addSubview:viewObj];
    }
    return self;
}

-(IBAction)okButtonTapped:(id)sender{
    
    if ([_delegate respondsToSelector:_selectorForOkButtonTapped]) {
        [_delegate performSelector:_selectorForOkButtonTapped withObject:nil afterDelay:0.0];
    }
 
//    switch (_verificationErrorObj) {
//        case VERIFICATION_ERROR_DOB_MISSING:
//            //check only if dob is selected or not
//            break;
//        case VERIFICATION_ERROR_GENDER_MISSING:
//            //check only if gender is selected or not
//
//            break;
//        default:
//            //check if both gender and dob is selected
//
//            break;
//    }
    
}

-(IBAction)genderSelectionButtonTapped:(id)sender{
    [APP_DELEGATE sendSwrveEventWithEvent:@"Onboarding.Gender" andScreen:@"Onboarding"];
    UIButton *buttonObj = (UIButton *)sender;
    _selectedGender = buttonObj.tag;
    if (buttonObj.tag == 1) {
        femaleButton.selected = TRUE;
        maleButton.selected = FALSE;
    }
    else{
        maleButton.selected = TRUE;
        femaleButton.selected = FALSE;
    }
    [self checkAndUnableOkButton];
//    okButton.enabled = TRUE;
}

-(IBAction)showDatePickerView:(id)sender{
    [APP_DELEGATE sendSwrveEventWithEvent:@"Onboarding.Birthdate" andScreen:@"Onboarding"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy/MMM/dd";
    
    _dobString = @"YYYY/MM/DD";
    NSDate *minimumDate = [dateFormatter dateFromString:@"1935/JAN/01"];
    NSDate *maxmimumDate = [NSDate date];
    NSDate *selectedDate = [dateFormatter dateFromString:@"1985/JAN/01"];
    
    [ActionSheetDatePicker showPickerWithTitle:@"" datePickerMode:UIDatePickerModeDate selectedDate:selectedDate minimumDate:minimumDate maximumDate:maxmimumDate doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
//        okButton.enabled = TRUE;
        dateFormatter.dateFormat = @"MM/dd/yyyy";
        _dobString = [dateFormatter stringFromDate:selectedDate];
        
        dateFormatter.dateFormat = @"yyyy";
        dobYearLabel.text = [dateFormatter stringFromDate:selectedDate];
        
        dateFormatter.dateFormat = @"MMM";
        dobMonthLabel.text = [dateFormatter stringFromDate:selectedDate];
        
        dateFormatter.dateFormat = @"dd";
        dobDateLabel.text = [dateFormatter stringFromDate:selectedDate];
        
        NSLog(@"UIDatePickerModeDate : %@",picker);
        
        [self checkAndUnableOkButton];
        NSLog(@"selectedDate :%@",selectedDate);
    } cancelBlock:^(ActionSheetDatePicker *picker) {
//        okButton.enabled = TRUE;
        [self checkAndUnableOkButton];
        NSLog(@"cancelled :%@",picker);
    } origin:self];
}
-(void)setUpViewAccordingToError{
//    NSDictionary *viewsDictionary = @{@"headerView":headerView, @"footerView":footerView, @"genderView":genderOptionView, @"dobView":dobOptionView};
    
    headerView.translatesAutoresizingMaskIntoConstraints = NO;
    footerView.translatesAutoresizingMaskIntoConstraints = NO;
    genderOptionView.translatesAutoresizingMaskIntoConstraints = NO;
    dobOptionView.translatesAutoresizingMaskIntoConstraints = NO;
    centerContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    switch (_verificationErrorObj) {
        case VERIFICATION_ERROR_DOB_MISSING:{
            //remove gender view
            genderOptionView.hidden = TRUE;
            dobOptionView.hidden = FALSE;
            okButton.enabled = FALSE;
            
            [centerContainerView addConstraint:[NSLayoutConstraint constraintWithItem:dobOptionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeBottom multiplier:1 constant:1]];
            heightConstraint.constant = 208;
            headerLabelObj.text = NSLocalizedString(@"Age matters!", nil);
        }
            break;
        case VERIFICATION_ERROR_GENDER_MISSING:{
            //remove dob view
            dobOptionView.hidden = TRUE;
            genderOptionView.hidden = FALSE;
            [centerContainerView addConstraint:[NSLayoutConstraint constraintWithItem:genderOptionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeBottom multiplier:1 constant:1]];
            [centerContainerView addConstraint:[NSLayoutConstraint constraintWithItem:footerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:genderOptionView attribute:NSLayoutAttributeBottom multiplier:1 constant:1]];
            heightConstraint.constant = 256;
            headerLabelObj.text = NSLocalizedString(@"Male/Female?", nil);
            
            okButton.enabled = FALSE;
        }
            
            break;
        default:
            [APP_DELEGATE sendSwrveEventWithEvent:@"Onboarding.Gender&Bday" andScreen:@"Onboarding"];
            //keep both views
            dobOptionView.hidden = FALSE;
            genderOptionView.hidden = FALSE;
            okButton.enabled = FALSE;
            headerLabelObj.text = NSLocalizedString(@"Info Missing!", nil);
            break;
    }
    
    _selectedGender = NO_GENDER_SELECTED;
    
}


-(void)checkAndUnableOkButton{
    
    switch (_verificationErrorObj) {
        case VERIFICATION_ERROR_DOB_MISSING:
            //check only if dob is selected or not
            if (![dobYearLabel.text isEqualToString:@"YYYY"]) {
                okButton.enabled = TRUE;
            }
            break;
        case VERIFICATION_ERROR_GENDER_MISSING:
            //check only if gender is selected or not
            if (_selectedGender != NO_GENDER_SELECTED) {
                okButton.enabled = TRUE;
            }
            
            break;
        default:
            //check if both gender and dob is selected
            if ((_selectedGender != NO_GENDER_SELECTED) && ![dobYearLabel.text isEqualToString:@"YYYY"]) {
                okButton.enabled = TRUE;
            }
            
            break;
    }

}
@end
