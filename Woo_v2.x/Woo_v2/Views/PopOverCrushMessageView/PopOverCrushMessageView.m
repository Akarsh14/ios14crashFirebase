//
//  PopOverCrushMessageView.m
//  Woo_v2
//
//  Created by Deepak Gupta on 1/14/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "PopOverCrushMessageView.h"

@implementation PopOverCrushMessageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib{
    [[viewPopOverMessageMiddleView layer] setCornerRadius:5.0f];
    txtViewPopOverMessageDesc.contentInset = UIEdgeInsetsMake(-7.0, 0.0, 0.0, 0.0);
    
}

#pragma mark - Cross Button Clicked
- (IBAction)crossButtonClicked:(id)sender{
    if ([_delegate performSelector:@selector(crossButtonClickedFromPopOverCrushMessage)]) {
        [_delegate performSelector:@selector(crossButtonClickedFromPopOverCrushMessage)];
    }
}

#pragma mark - Setting Data on View
- (void)settingPopOverCrushMessageViewWithTitle:(NSString *)title withDescription:(NSString *)desc{
    
    [lblPopOverMessageTitle setText:[NSString stringWithFormat:@"%@ %@",title , NSLocalizedString(@"has a crush on you", "title")]];
    [txtViewPopOverMessageDesc setText:desc];
    
    [txtViewPopOverMessageDesc setContentOffset:CGPointMake(0,-10000) animated:NO];
    [txtViewPopOverMessageDesc setSelectable:NO];
    
    


}

@end
