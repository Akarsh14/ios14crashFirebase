//
//  UIButton+TaggableButtons.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 11/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "UIButton+TaggableButtons.h"

#pragma mark -
#pragma mark FILEBASENAME
#pragma mark -

#pragma mark -> Implementation
@implementation UIButton (TaggableButtons)

static char key;
static char tagKey;

#define kTagsCornerRadius 5.0f
#define kTagTextLeftRightPadding 7.0f
#define kTagTextTopBottomPadding 5.0f
#define kMaximumSelectableTags 10 // set -1 for no limit no maximum selectable tags

- (void)setTagTypeKey:(NSString *)tagTypeKey
{
    [self.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    objc_setAssociatedObject(self, &key, tagTypeKey, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setCustomTagValue:(NSString *)customTagValue
{
//    NSString *buttonText = self.titleLabel.text;
//    NSMutableAttributedString *attributedTagString = [[NSMutableAttributedString alloc] initWithString:buttonText];
//    [attributedTagString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [attributedTagString length])];

    
    [self.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    
//    [self setAttributedTitle:attributedTagString forState:UIControlStateNormal];
    
    objc_setAssociatedObject(self, &tagKey, customTagValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSString *)tagTypeKey
{
    return objc_getAssociatedObject(self, &key);
}

- (NSString *)customTagValue
{
    return objc_getAssociatedObject(self, &tagKey);
}

-(void)makeMeSelected:(BOOL)doINeedToGetSelected{

    NSString *buttonText = self.titleLabel.text;
    NSLog(@"string = %@",buttonText);
    NSLog(@"attrib string %@",self.titleLabel.attributedText);
    
    NSRange foundRange = [buttonText rangeOfString:@" ✕"];
    
    if (foundRange.location != NSNotFound) {
        buttonText = [buttonText stringByReplacingCharactersInRange:foundRange withString:@""];
    }
    
    buttonText = [NSString stringWithFormat:@"%@ ✕",buttonText];
    NSMutableAttributedString *attributedTagString = [[NSMutableAttributedString alloc] initWithString:buttonText];
    
    [self.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [self setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self setContentEdgeInsets:UIEdgeInsetsMake(kTagTextTopBottomPadding, kTagTextLeftRightPadding, kTagTextTopBottomPadding, kTagTextLeftRightPadding)];
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    [self.layer setCornerRadius:kTagsCornerRadius];
    self.tintColor = [UIColor clearColor];
    self.selected = TRUE;
    
    [self setTitleColor:kTagUnselectedTextColor forState:UIControlStateNormal];
    [self setBackgroundColor:kTagUnselectedBackgroundColor];
    
    if (doINeedToGetSelected) {
        
        [attributedTagString addAttribute:NSForegroundColorAttributeName
                                    value:kTagSelectedTextColor
                                    range:NSMakeRange(0, [attributedTagString length])];
        

        [self setAttributedTitle:attributedTagString forState:UIControlStateNormal];
        
        [self setTitleColor:kTagSelectedTextColor forState:UIControlStateNormal];
        [self setBackgroundColor:kTagSelectedBackgroundColor];
    }else{
        [attributedTagString addAttribute:NSForegroundColorAttributeName
                                    value:kTagUnselectedTextColor
                                    range:NSMakeRange(0, [attributedTagString length]-2)];
        
        [attributedTagString addAttribute:NSForegroundColorAttributeName
                                    value:kTagSelectedTextColor
                                    range:NSMakeRange(([attributedTagString length] -2), 2)];
        [self setAttributedTitle:attributedTagString forState:UIControlStateNormal];
        
        
        [self setTitleColor:kTagUnselectedTextColor forState:UIControlStateNormal];
        [self setBackgroundColor:kTagUnselectedBackgroundColor];
    }
    CGRect newFrame = self.frame;
    [self sizeToFit];
    newFrame.size.width = self.frame.size.width;
    self.frame = newFrame;
    
}

#pragma mark -> Properties

@end
