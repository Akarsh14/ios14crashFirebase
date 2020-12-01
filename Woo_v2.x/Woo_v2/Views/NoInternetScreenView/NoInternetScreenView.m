//
//  NoInternetScreenView.m
//  Woo_v2
//
//  Created by Deepak Gupta on 6/15/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "NoInternetScreenView.h"

@implementation NoInternetScreenView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/




-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    //check if memory is allocated to self
    if (self) {
        //getting array of views from the xib
        NSArray *viewArrayFromXib = [[NSBundle mainBundle] loadNibNamed:@"NoInternetScreenView" owner:self options:nil];
        UIView *viewObj = [viewArrayFromXib firstObject];
        viewObj.frame = self.bounds;
        [self addSubview:viewObj];
        if(_showLoader){
        [self performSelector:@selector(addingWooLoader) withObject:nil afterDelay:0.1];
        }
    }
    return self;
}

#pragma mark - Adding Woo Loader
- (void)addingWooLoader{
    
    WooLoader  *customLoader = [[WooLoader alloc]initWithFrame:viewLoader.frame];
    [customLoader customLoadingText:NSLocalizedString(@"No internet connection", @"No internet connection") ];
    customLoader.shouldShowWooLoader = YES;
    [customLoader startAnimationOnView:viewLoader WithBackGround:NO];
}


- (IBAction)refreshButtonClicked:(UIButton *)sender{
    if ([_delegate respondsToSelector:@selector(refreshButtonClicked:)]) {
        [_delegate refreshButtonClicked:nil];
    }
    
}


@end
