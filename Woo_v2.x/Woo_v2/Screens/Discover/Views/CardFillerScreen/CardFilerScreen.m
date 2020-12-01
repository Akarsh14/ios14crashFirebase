//
//  CardFilerScreen.m
//  Woo_v2
//
//  Created by Umesh Mishra on 09/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "CardFilerScreen.h"

@implementation CardFilerScreen

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
        
        NSArray *arrayObj = [[NSBundle mainBundle] loadNibNamed:@"CardFilerScreen" owner:self options:nil];
        UIView *viewObj = [arrayObj objectAtIndex:0];
        viewObj.frame = frame;
        [self addSubview:viewObj];
    }
    return self;
}

-(void)setErrorImage:(UIImage *)errorImage setHeadingText:(NSString *)headingText setMessageText:(NSString *)messageText andButtonText:(NSString *)buttonText{
    if (errorImage) {
        errorImageView.image = errorImage;
    }
    if (headingText) {
        headingLabel.text = headingText;
    }
    if (messageText) {
        messageLabel.text = messageText;
    }
    if (buttonText) {
        [buttonObject setTitle:buttonText forState:UIControlStateNormal];
    }
}

-(IBAction)buttonTapped:(id)sender{
    if ([_delegate respondsToSelector:_selectorForButtonTapped]) {
        [_delegate performSelector:_selectorForButtonTapped withObject:nil afterDelay:0.0];
    }
}

-(void)showButton:(BOOL)needToshowButton{
    buttonObject.hidden = !needToshowButton;
}

@end
