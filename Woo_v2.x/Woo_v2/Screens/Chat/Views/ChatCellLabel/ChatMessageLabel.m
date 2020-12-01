//
//  ChatMessageLabel.m
//  Woo
//
//  Created by Umesh Mishra on 06/05/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "ChatMessageLabel.h"
#define PADDING 15
#define TOP_PADDING -2
#define BOTTOM_PADDING 0
#define RIGHT_PADDING 15

@implementation ChatMessageLabel


- (void)drawTextInRect:(CGRect)rect {
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(TOP_PADDING, PADDING, BOTTOM_PADDING, RIGHT_PADDING))];
}

//- (BOOL)canBecomeFirstResponder {
//    return YES;
//}
//-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
//    return action ==@selector(copy:);
//}
//-(void)copy:(id)center{
//    UIPasteboard *pb = [UIPasteboard generalPasteboard];
//    [pb setString:[self text]];
//}

@end
