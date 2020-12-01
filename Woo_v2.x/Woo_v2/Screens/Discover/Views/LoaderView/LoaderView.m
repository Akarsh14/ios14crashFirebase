//
//  LoaderView.m
//  Woo_v2
//
//  Created by Umesh Mishra on 13/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "LoaderView.h"

@implementation LoaderView

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
        
        NSArray *arrayObj = [[NSBundle mainBundle] loadNibNamed:@"LoaderView" owner:self options:nil];
        UIView *viewObj = [arrayObj objectAtIndex:0];
        viewObj.frame = frame;
        [self addSubview:viewObj];
        
            [[NSNotificationCenter defaultCenter] removeObserver:self name:kUserLoggedOutSuccessfullyLoadDiscover object:nil];
            //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeView) name:kUserLoggedOutSuccessfullyLoadDiscover object:nil];
    }

    return self;
}

-(void)removeView{
    [self removeFromSuperview];
}


-(void)setTextOnLabelWithGrayColor:(NSString *)grayText andWithHighlightedText:(NSString *)highlightedText{
    [self layoutIfNeeded];
    
//    for (id subViews in self.subviews) {
//        NSLog(@"subview class ^^^^^^^:%@",[subViews class]);
//    }
    if (highlightedText && [highlightedText length]>0) {
        NSMutableAttributedString *loadingText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@",grayText,highlightedText]];
        
        [loadingText addAttribute:NSForegroundColorAttributeName value:kButtonTextRedColor range:NSMakeRange([grayText length]+1, [highlightedText length])];
        [messagLabel setAttributedText:loadingText];
        [activityIndicatorObj startAnimating];
    }
    else{
        NSMutableAttributedString *loadingText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",grayText]];
        
//        [loadingText addAttribute:NSForegroundColorAttributeName value:kButtonTextRedColor range:NSMakeRange([grayText length]+1, [highlightedText length])];
        [messagLabel setAttributedText:loadingText];
        [activityIndicatorObj startAnimating];
    }
    
        
}

@end
