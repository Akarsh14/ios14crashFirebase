//
//  TypingCell.m
//  Woo
//
//  Created by Umesh Mishra on 01/04/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "TypingCell.h"
#define LabelRadius 15

@implementation TypingCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)animateImage{
//    [self makeLabelRounder:FALSE];
//    [typingImageView setAnimationImages:@[[UIImage imageNamed:@"chat_writing_1"] ,[UIImage imageNamed:@"chat_writing_2"],[UIImage imageNamed:@"chat_writing_3"]]];
//    typingImageView.animationDuration = 1.0;
//    typingImageView.animationRepeatCount = 0;
//    [typingImageView startAnimating];
}
-(void)makeLabelRounder:(BOOL)isSender{
//    UIBezierPath *buttonMaskPath =  nil;
//
//        buttonMaskPath = [UIBezierPath bezierPathWithRoundedRect:containerView.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight|UIRectCornerBottomRight cornerRadii:CGSizeMake(LabelRadius, LabelRadius)];
//        containerView.backgroundColor = kOtherChatBackgroundColor;

    
    
//    CAShapeLayer *buttonMaskLayer = [[CAShapeLayer alloc]init];
//    buttonMaskLayer.frame = containerView.bounds;
//    buttonMaskLayer.path = buttonMaskPath.CGPath;
//    containerView.layer.mask = buttonMaskLayer;
}

@end
