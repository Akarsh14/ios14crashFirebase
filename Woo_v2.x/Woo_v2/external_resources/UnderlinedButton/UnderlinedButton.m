//
//  UnderlinedButton.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 17/08/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "UnderlinedButton.h"

#define kTagsCornerRadius 5.0f
#define kTagTextLeftRightPadding 7.0f
#define kTagTextTopBottomPadding 5.0f
#define kMaximumSelectableTags 10 // set -1 for no limit no maximum selectable tags

@implementation UnderlinedButton

+ (UnderlinedButton*) underlinedButton {
    UnderlinedButton* button = [[UnderlinedButton alloc] init];
    return button;
}
- (void)setTitle:(NSString *)title forState:(UIControlState)state andMakeMeSelected:(BOOL)amISelected{
    if (title.length < 1) {
        return;
    }
    NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] initWithString:title];
    [commentString addAttribute:NSForegroundColorAttributeName value:kHeaderTextRedColor range:NSMakeRange(0, [commentString length])];
    
    [self setAttributedTitle:commentString forState:state];
    [super setAttributedTitle:commentString forState:state];
    
    
    NSString *buttonText = title;
    NSLog(@"string = %@",buttonText);
    NSLog(@"attrib string %@",self.titleLabel.attributedText);
    
    NSRange foundRange = [buttonText rangeOfString:@" ✕"];
    
    if (amISelected) {
        if (foundRange.location != NSNotFound ) {
//        Do nothing here
        }else{
            buttonText = [NSString stringWithFormat:@"%@ ✕",buttonText];
        }
    }else{
        if (foundRange.location != NSNotFound) {
            buttonText = [buttonText stringByReplacingCharactersInRange:foundRange withString:@""];
        }else{
//            do nothing here
        }
    }
    
    NSMutableAttributedString *attributedTagString = [[NSMutableAttributedString alloc] initWithString:buttonText];
    
    [self.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [self setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self setContentEdgeInsets:UIEdgeInsetsMake(kTagTextTopBottomPadding, kTagTextLeftRightPadding, kTagTextTopBottomPadding, kTagTextLeftRightPadding)];
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    [self.layer setCornerRadius:kTagsCornerRadius];
    self.tintColor = [UIColor clearColor];
    self.selected = amISelected;
    
    
    if (amISelected) {
        
        if (foundRange.location != NSNotFound ) {
            //        Do nothing here
        }else{

            [attributedTagString addAttribute:NSForegroundColorAttributeName
                                        value:kTagSelectedTextColor
                                        range:NSMakeRange(0, [attributedTagString length])];
            
            
            [self setAttributedTitle:attributedTagString forState:UIControlStateNormal];
            
            [self setTitleColor:kTagSelectedTextColor forState:UIControlStateNormal];
            [self setBackgroundColor:kTagSelectedBackgroundColor];
        }
        
    }else{
        
        if (foundRange.location != NSNotFound) {

            [attributedTagString addAttribute:NSForegroundColorAttributeName
                                        value:kTagUnselectedTextColor
                                        range:NSMakeRange(0, [attributedTagString length]-2)];
            
            [attributedTagString addAttribute:NSForegroundColorAttributeName
                                        value:kTagSelectedTextColor
                                        range:NSMakeRange(([attributedTagString length] -2), 2)];
            [self setAttributedTitle:attributedTagString forState:UIControlStateNormal];
            
            
            [self setTitleColor:kTagUnselectedTextColor forState:UIControlStateNormal];
            [self setBackgroundColor:kTagUnselectedBackgroundColor];

        }else{
            //            do nothing here
        }
        
    }
    CGRect newFrame = self.frame;
    [self sizeToFit];
    newFrame.size.width = self.frame.size.width;
    self.frame = newFrame;
    
//    if (amISelected) {
//        [self setTitleColor:kTagSelectedTextColor forState:UIControlStateNormal];
//        [self setBackgroundColor:kTagSelectedBackgroundColor];
//    }
//    else{
//        [self setTitleColor:kTagUnselectedTextColor forState:UIControlStateNormal];
//        [self setBackgroundColor:kTagUnselectedBackgroundColor];
//    }
}



- (void)setTitle:(NSString *)title forState:(UIControlState)state{

    
    NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] initWithString:title];

    //Uncomment the line below to enable underline of searchable tag buttons
//    [commentString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [commentString length])];
    
    
    [commentString addAttribute:NSForegroundColorAttributeName value:kHeaderTextRedColor range:NSMakeRange(0, [commentString length])];
    
    [self setAttributedTitle:commentString forState:state];
    [super setAttributedTitle:commentString forState:state];
    
    
    
    
//    [super setTitleColor:kHeaderTextRedColor forState:state];
}

@end
