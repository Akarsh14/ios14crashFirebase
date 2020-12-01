//
//  ConnectingView.m
//  Woo_v2
//
//  Created by Umesh Mishraji on 14/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "ConnectingView.h"

@implementation ConnectingView

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
        
        NSArray *nibArray = [[NSBundle mainBundle]loadNibNamed:@"ConnectingView" owner:self options:nil];
        UIView *viewObj = [nibArray lastObject];
        viewObj.frame =self.bounds;
        [self addSubview:viewObj];
        bottomLinesLbl.hidden = FALSE;
        
    }
    return self;
}

-(void)changeLoadingTextView:(NSString *)newText{
    loadingTextLbl.text = newText;
}
-(void)animateActivityIndicatorView{
    activityIndicatorObj.hidden =FALSE;
    centerAlignContraint.constant = 10;
    if (!activityIndicatorObj.isAnimating) {
        [activityIndicatorObj startAnimating];
    }
}

-(void)stopAndHideActivityIndicatorView{
    if (activityIndicatorObj.isAnimating) {
        [activityIndicatorObj stopAnimating];
    }
    activityIndicatorObj.hidden = TRUE;
    centerAlignContraint.constant = 0;
}
-(void)hideBottomLine{
    bottomLinesLbl.hidden = TRUE;
}
-(void)setBackgroundColorOfView:(UIColor *)backgroundColor{
    self.backgroundColor = backgroundColor;
}
-(void)setLoadingTextColor:(UIColor *)textColor{
    loadingTextLbl.textColor = textColor;
}
@end
