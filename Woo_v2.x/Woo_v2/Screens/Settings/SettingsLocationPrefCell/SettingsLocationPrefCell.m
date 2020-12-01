//
//  SettingsLocationPrefCell.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 17/10/15.
//  Copyright © 2015 Vaibhav Gautam. All rights reserved.
//

#import "SettingsLocationPrefCell.h"

@interface SettingsLocationPrefCell()
{
    __weak IBOutlet NSLayoutConstraint *firstButtonWidthConstraint;
    __weak IBOutlet NSLayoutConstraint *firstButtonHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *secondButtonWidthConstraint;
    __weak IBOutlet NSLayoutConstraint *secondButtonHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *thirdButtonwidthConstraint;
    __weak IBOutlet NSLayoutConstraint *thirdButtonHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *fourthButtonWidthConstraint;
    __weak IBOutlet NSLayoutConstraint *fourthButtonHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *fifthButtonHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *fifthButtonWidthConstraint;
    __weak IBOutlet UIButton *firstBehindButton;
    __weak IBOutlet UIButton *secondBehindButton;
    __weak IBOutlet UIButton *thirdBehindButton;
    __weak IBOutlet UIButton *fourthBehindButton;
    __weak IBOutlet UIButton *fifthBehindButton;
    BOOL isKmsCurrentState;
    BOOL isKmsSelectedState;
    NSInteger currentMaxDistance;
    NSInteger selectedMaxDistance;
}

@property (nonatomic, retain)UIButton *lastSelectedButton;

@end

@implementation SettingsLocationPrefCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)prepareCellForLocation:(NSInteger)maxDist{
    UIButton *btn;
    [self layoutIfNeeded];
    
    currentMaxDistance = maxDist;

    if (maxDist == 10) {
        btn = firstButton;
    }else if (maxDist == 20){
        btn = secondButton;
    }else if (maxDist == 50){
        btn = thirdButton;
    }else if (maxDist == 100){
        btn = fourthButton;
    }else if (maxDist > 200 ){
        btn = fifthButton;
    }
    
    isKmsCurrentState = [DiscoverProfileCollection sharedInstance].intentModelObject.isKms.boolValue;
    
    if ([DiscoverProfileCollection sharedInstance].intentModelObject.isKms.boolValue == true) {
        milesFadedView.alpha = 0.6;
        kmFadedView.alpha = 0;
    }
    else{
        milesFadedView.alpha =  0;
        kmFadedView.alpha = 0.6;
    }

    [self performSelector:@selector(updateRedBarWidthBasedOnButtonTapped:) withObject:btn afterDelay:0.3];
}

- (void)updateRedBarWidthBasedOnButtonTapped:(UIButton *)selectedButton{
    
    if (_lastSelectedButton == selectedButton) {
        return;
    }
    
    _lastSelectedButton = selectedButton;
    
    [self layoutIfNeeded];
    
    firstButtonHeightConstraint.constant = 11;
    firstButtonWidthConstraint.constant = 11;
    firstBehindButton.layer.cornerRadius = 5.5;
    secondButtonHeightConstraint.constant = 11;
    secondButtonWidthConstraint.constant = 11;
    secondBehindButton.layer.cornerRadius = 5.5;
    thirdButtonHeightConstraint.constant = 11;
    thirdButtonwidthConstraint.constant = 11;
    thirdBehindButton.layer.cornerRadius = 5.5;
    fourthButtonHeightConstraint.constant = 11;
    fourthButtonWidthConstraint.constant = 11;
    fourthBehindButton.layer.cornerRadius = 5.5;
    fifthButtonHeightConstraint.constant = 11;
    fifthButtonWidthConstraint.constant = 11;
    fifthBehindButton.layer.cornerRadius = 5.5;

    if (selectedButton == firstButton) {
        
        selectedMaxDistance = 10;
        redBarWidthConstraint.constant = 0;
        firstButtonHeightConstraint.constant = 22;
        firstButtonWidthConstraint.constant = 22;
        firstBehindButton.layer.cornerRadius = 11;
        
        [UIView animateWithDuration:0.5 animations:^{
            [self layoutIfNeeded];
            [firstBehindButton setBackgroundColor:[UIColor colorWithRed:250.0f/255.0f green:72.0f/255.0f blue:73.0f/255.0f alpha:1.0]];
            [secondBehindButton setBackgroundColor:[UIColor clearColor]];
            [thirdBehindButton setBackgroundColor:[UIColor clearColor]];
            [fourthBehindButton setBackgroundColor:[UIColor clearColor]];
            [fifthBehindButton setBackgroundColor:[UIColor clearColor]];
        }];

        
    }else if (selectedButton == secondButton){
        
        selectedMaxDistance = 20;

        [firstBehindButton setBackgroundColor:[UIColor colorWithRed:250.0f/255.0f green:72.0f/255.0f blue:73.0f/255.0f alpha:1.0]];

        redBarWidthConstraint.constant = 270 * 0.25;
        
        [UIView animateWithDuration:0.5 animations:^{
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            secondButtonWidthConstraint.constant = 22;
            secondButtonHeightConstraint.constant = 22;
            secondBehindButton.layer.cornerRadius = 11;
            [UIView animateWithDuration:0.5 animations:^{
                [self layoutIfNeeded];
                [secondBehindButton setBackgroundColor:[UIColor colorWithRed:250.0f/255.0f green:72.0f/255.0f blue:73.0f/255.0f alpha:1.0]];
                [thirdBehindButton setBackgroundColor:[UIColor clearColor]];
                [fourthBehindButton setBackgroundColor:[UIColor clearColor]];
                [fifthBehindButton setBackgroundColor:[UIColor clearColor]];
            }];

        }];
        
    }else if (selectedButton == thirdButton){
        
        selectedMaxDistance = 50;

        [firstBehindButton setBackgroundColor:[UIColor colorWithRed:250.0f/255.0f green:72.0f/255.0f blue:73.0f/255.0f alpha:1.0]];
        redBarWidthConstraint.constant = 270 * 0.50;
        
        [UIView animateWithDuration:0.5 animations:^{
            [self layoutIfNeeded];
            [secondBehindButton setBackgroundColor:[UIColor colorWithRed:250.0f/255.0f green:72.0f/255.0f blue:73.0f/255.0f alpha:1.0]];
            [fourthBehindButton setBackgroundColor:[UIColor clearColor]];
            [fifthBehindButton setBackgroundColor:[UIColor clearColor]];
        } completion:^(BOOL finished) {
            thirdButtonHeightConstraint.constant = 22;
            thirdButtonwidthConstraint.constant = 22;
            thirdBehindButton.layer.cornerRadius = 11;
            
            [UIView animateWithDuration:0.5 animations:^{
                [self layoutIfNeeded];
                [thirdBehindButton setBackgroundColor:[UIColor colorWithRed:250.0f/255.0f green:72.0f/255.0f blue:73.0f/255.0f alpha:1.0]];
            }];
        }];
        
        
    }else if (selectedButton == fourthButton){
        
        selectedMaxDistance = 100;

        [firstBehindButton setBackgroundColor:[UIColor colorWithRed:250.0f/255.0f green:72.0f/255.0f blue:73.0f/255.0f alpha:1.0]];
        redBarWidthConstraint.constant = 270 * 0.75;

        [UIView animateWithDuration:0.5 animations:^{
            [self layoutIfNeeded];
            [secondBehindButton setBackgroundColor:[UIColor colorWithRed:250.0f/255.0f green:72.0f/255.0f blue:73.0f/255.0f alpha:1.0]];
            [thirdBehindButton setBackgroundColor:[UIColor colorWithRed:250.0f/255.0f green:72.0f/255.0f blue:73.0f/255.0f alpha:1.0]];
            [fifthBehindButton setBackgroundColor:[UIColor clearColor]];
        } completion:^(BOOL finished) {
            fourthButtonHeightConstraint.constant = 22;
            fourthButtonWidthConstraint.constant = 22;
            fourthBehindButton.layer.cornerRadius = 11;

            [UIView animateWithDuration:0.5 animations:^{
                [self layoutIfNeeded];
                [fourthBehindButton setBackgroundColor:[UIColor colorWithRed:250.0f/255.0f green:72.0f/255.0f blue:73.0f/255.0f alpha:1.0]];
            }];
        }];
    }else if (selectedButton == fifthButton){
        
        selectedMaxDistance = 2147483647;

        [firstBehindButton setBackgroundColor:[UIColor colorWithRed:250.0f/255.0f green:72.0f/255.0f blue:73.0f/255.0f alpha:1.0]];
        redBarWidthConstraint.constant = 270;

        [UIView animateWithDuration:0.5 animations:^{
            [self layoutIfNeeded];
            [secondBehindButton setBackgroundColor:[UIColor colorWithRed:250.0f/255.0f green:72.0f/255.0f blue:73.0f/255.0f alpha:1.0]];
            [thirdBehindButton setBackgroundColor:[UIColor colorWithRed:250.0f/255.0f green:72.0f/255.0f blue:73.0f/255.0f alpha:1.0]];
            [fourthBehindButton setBackgroundColor:[UIColor colorWithRed:250.0f/255.0f green:72.0f/255.0f blue:73.0f/255.0f alpha:1.0]];
            
        } completion:^(BOOL finished) {
            fifthButtonHeightConstraint.constant = 22;
            fifthButtonWidthConstraint.constant = 22;
            fifthBehindButton.layer.cornerRadius = 11;
            
            [UIView animateWithDuration:0.5 animations:^{
                [self layoutIfNeeded];
                [fifthBehindButton setBackgroundColor:[UIColor colorWithRed:250.0f/255.0f green:72.0f/255.0f blue:73.0f/255.0f alpha:1.0]];
            }];
        }];
    }
    
    if (currentMaxDistance != selectedMaxDistance) {
        [DiscoverProfileCollection sharedInstance].intentModelObject.maxDistance = [NSNumber numberWithInteger:selectedMaxDistance];
        [DiscoverProfileCollection sharedInstance].needToMakeDiscoverCallAsPreferencesHasBeenChanged = true;
    }
    else{
        [DiscoverProfileCollection sharedInstance].intentModelObject.maxDistance = [NSNumber numberWithInteger:currentMaxDistance];
        [DiscoverProfileCollection sharedInstance].needToMakeDiscoverCallAsPreferencesHasBeenChanged = false;
    }
}

- (IBAction)kmsTapped:(id)sender {
    isKmsSelectedState = true;
    if (isKmsCurrentState != isKmsSelectedState) {
        [DiscoverProfileCollection sharedInstance].intentModelObject.isKms = [NSNumber numberWithBool:true];
        [DiscoverProfileCollection sharedInstance].needToMakeDiscoverCallAsPreferencesHasBeenChanged = true;
    }
    else{
        [DiscoverProfileCollection sharedInstance].intentModelObject.isKms = [NSNumber numberWithBool:isKmsCurrentState];
        [DiscoverProfileCollection sharedInstance].needToMakeDiscoverCallAsPreferencesHasBeenChanged = false;
    }
    
    milesFadedView.alpha = 0.6;
    kmFadedView.alpha = 0;
}

- (IBAction)milesTapped:(id)sender {
    isKmsSelectedState = false;
    if (isKmsCurrentState != isKmsSelectedState) {
        [DiscoverProfileCollection sharedInstance].intentModelObject.isKms = [NSNumber numberWithBool:false];
        [DiscoverProfileCollection sharedInstance].needToMakeDiscoverCallAsPreferencesHasBeenChanged = true;
    }
    else{
        [DiscoverProfileCollection sharedInstance].intentModelObject.isKms = [NSNumber numberWithBool:isKmsCurrentState];
        [DiscoverProfileCollection sharedInstance].needToMakeDiscoverCallAsPreferencesHasBeenChanged = false;
    }
    milesFadedView.alpha =  0;
    kmFadedView.alpha = 0.6;
}


- (IBAction)locationSelectorButtonTapped:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    [self updateRedBarWidthBasedOnButtonTapped:button];
}


@end
