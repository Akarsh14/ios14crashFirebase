//
//  DrawerFooterView.m
//  Woo_v2
//
//  Created by Suparno Bose on 05/01/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "DrawerFooterView.h"

#define kPinkColor     [UIColor colorWithRed:251.0/256.0 green:234.0/256.0 blue:226.0/256.0 alpha:1.0]
#define kOrangeColor     [UIColor colorWithRed:241.0/256.0 green:152.0/256.0 blue:0.0/256.0 alpha:1.0]

@implementation DrawerFooterView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setMode:ModeNone];
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

-(void) setMode:(DrawerFooterViewMode) mode{
    _mode = mode;
    if (_mode == ModeCrush) {
        [self setHidden:NO];
        [self setViewForCrush];
    }
    else if (_mode == ModeBoost){
        [self setHidden:NO];
        [self setViewForBoost];
    }
    else{
        [self setHidden:YES];
    }
}

-(DrawerFooterViewMode) mode{
    return _mode;
}

-(void) setTapActionBlock:(FooterActionBlock) block{
    actionBlock = block;
}

- (IBAction)footerTapped:(id)sender {
    actionBlock();
}


-(void) setViewForCrush{
    [backgroundView setBackgroundColor:kPinkColor];
    [crushBoostImageView setImage:[UIImage imageNamed:@"ic_left_menu_crush_ad"]];
    [titleLabel setTextColor:[UIColor blackColor]];
    [descriptionLabel setTextColor:[UIColor blackColor]];
    [titleLabel setText:NSLocalizedString(@"Send a Crush", nil)];
    [descriptionLabel setText:NSLocalizedString(@"Let them know that you have crush on them", nil)];
}

-(void) setViewForBoost{
    [backgroundView setBackgroundColor:kOrangeColor];
    [crushBoostImageView setImage:[UIImage imageNamed:@"ic_left_menu_boost_ad"]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [descriptionLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setText:NSLocalizedString(@"Boost your profile", nil)];
    [descriptionLabel setText:NSLocalizedString(@"Get a week's worth of visibility in one day", nil)];
}

@end
