//
//  AnswerAQuestionFillerView.m
//  Woo_v2
//
//  Created by Umesh Mishra on 26/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "AnswerAQuestionFillerView.h"

@implementation AnswerAQuestionFillerView

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
        
        NSArray *arrayObj = [[NSBundle mainBundle] loadNibNamed:@"AnswerAQuestionFillerView" owner:self options:nil];
        UIView *viewObj = [arrayObj objectAtIndex:0];
        viewObj.frame = frame;
        [self addSubview:viewObj];
    }
    return self;
}


-(void)setMessageText:(NSString *)messageText buttonText:(NSString *)buttonText andFooterText:(NSString *)footerText{
    messageLabel.text = messageText;
    footerLabel.text = footerText;
    [askButton setTitle:buttonText forState:UIControlStateNormal];
    
}

-(IBAction)askButtonTapped:(id)sender{
    if ([_delegate respondsToSelector:_selectorForButtonTapped]) {
        [_delegate performSelector:_selectorForButtonTapped withObject:@"Hi" afterDelay:0.0];
    }
}

-(void)setAskQuestionImage:(NSString *)imageName{
    askQuestionImageView.image = [UIImage imageNamed:imageName];
}

@end
