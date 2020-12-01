//
//  TopLeftNavItemView.m
//  Woo_v2
//
//  Created by Suparno Bose on 16/01/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "TopRightNavItemView.h"

@interface TopRightNavItemView ()
{
    NSTimer *timer;
}

@end

@implementation TopRightNavItemView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
@property (nonatomic) */

+(TopRightNavItemView* _Nonnull) createFromNIBWithOwner:(id _Nonnull)owner
                                               AndFrame:(CGRect)frame{
    NSArray *xibArray = [[NSBundle mainBundle] loadNibNamed:@"TopRightNavItemView"
                                                      owner:owner options:nil];
    TopRightNavItemView *topLeftNavItemView = [xibArray firstObject];

    [topLeftNavItemView setFrame:frame];
    
    return topLeftNavItemView;
}

- (void)UpdateViewIfItsBoosted
{
    BoostModel *boostModel = [BoostModel sharedInstance];
    if ([boostModel checkIfUserNeedsToPurchase] == YES) {
        boostedLabel.hidden = YES;
        boostedButton.hidden = YES;
    }
    else{
        if (boostModel.currentlyActive == NO) {
            boostedLabel.hidden = YES;
            boostedButton.hidden = YES;
        }
        else{
            boostedLabel.hidden = NO;
            boostedButton.hidden = NO;
        }
    }
}

- (IBAction)boostButtonTapped:(id)sender {
    
    [boostedLabel.layer removeAllAnimations];
    if (timer) {
        [timer invalidate];
        timer = nil;
    }

    [UIView animateWithDuration:0.75
                          delay:0.0
         usingSpringWithDamping:0.4
          initialSpringVelocity:0.5
                        options:0 animations:^{
                            [boostedButton setUserInteractionEnabled:NO];
                            if (isDrawerOpen) {
                                boostedLabel.frame = CGRectMake(141, boostedLabel.frame.origin.y,
                                                                boostedLabel.frame.size.width, boostedLabel.frame.size.height);
                            }
                            else{
                                boostedLabel.frame = CGRectMake(20, boostedLabel.frame.origin.y,
                                                                boostedLabel.frame.size.width, boostedLabel.frame.size.height);
                                timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(boostButtonTapped:) userInfo:nil repeats:NO];
                            }
                        }
                     completion:^(BOOL finished) {
                         isDrawerOpen = !isDrawerOpen;
                         [boostedButton setUserInteractionEnabled:YES];
                     }];
}

@end
