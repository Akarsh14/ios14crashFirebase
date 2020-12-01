//
//  FacebookSyncView.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 24/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "FacebookSyncView.h"

@implementation FacebookSyncView


-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
        if (self) {
        //getting array of views from the xib
        NSArray *viewArrayFromXib = [[NSBundle mainBundle] loadNibNamed:@"FacebookSyncView" owner:self options:nil];
        UIView *viewObj = [viewArrayFromXib firstObject];
        viewObj.frame = self.bounds;
        [self addSubview:viewObj];
            
            _isWorkPlaceSelected = YES;
            _isAgeSelected = YES;
            _isGenderSelected = YES;
            _isEducationSelected = YES;
    }
    

    
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)workplaceButtonTapped:(id)sender {
    _isWorkPlaceSelected = !_isWorkPlaceSelected;
    [self enableDisableStatusOfSyncButton];
    
    if (_isWorkPlaceSelected) {
        [workPlaceRadio setImage:[UIImage imageNamed:@"reportTickSelected"] forState:UIControlStateNormal];
    }else{
        [workPlaceRadio setImage:[UIImage imageNamed:@"radioUnselected"] forState:UIControlStateNormal];
    }
}

- (IBAction)educationButtonTapped:(id)sender {
    _isEducationSelected = !_isEducationSelected;
    [self enableDisableStatusOfSyncButton];
    
    if (_isEducationSelected) {
        [educationRadio setImage:[UIImage imageNamed:@"reportTickSelected"] forState:UIControlStateNormal];
    }else{
        [educationRadio setImage:[UIImage imageNamed:@"radioUnselected"] forState:UIControlStateNormal];
    }
}

- (IBAction)genderButtonTapped:(id)sender {
    _isGenderSelected = !_isGenderSelected;
    [self enableDisableStatusOfSyncButton];
    
    if (_isGenderSelected) {
        [genderRadio setImage:[UIImage imageNamed:@"reportTickSelected"] forState:UIControlStateNormal];
    }else{
        [genderRadio setImage:[UIImage imageNamed:@"radioUnselected"] forState:UIControlStateNormal];
    }
}

- (IBAction)ageButtonTapped:(id)sender {
    _isAgeSelected = !_isAgeSelected;
    [self enableDisableStatusOfSyncButton];
    
    if (_isAgeSelected) {
        [ageRadio setImage:[UIImage imageNamed:@"reportTickSelected"] forState:UIControlStateNormal];
    }else{
        [ageRadio setImage:[UIImage imageNamed:@"radioUnselected"] forState:UIControlStateNormal];
    }
}

- (IBAction)cancelButtonTapped:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)syncButtonTapped:(id)sender {
    
    if ([_delegate respondsToSelector:_selectorForsubmittButtonTapped]) {
        [_delegate performSelector:_selectorForsubmittButtonTapped withObject:nil afterDelay:0.0];
    }
//    if ([syncButton isEnabled]) {
//        [self removeFromSuperview];
//    }
    
}


-(void)enableDisableStatusOfSyncButton{
    if (_isAgeSelected || _isGenderSelected || _isEducationSelected || _isWorkPlaceSelected) {
        [syncButton setEnabled:YES];
    }else{
        [syncButton setEnabled:NO];
    }
}
@end
