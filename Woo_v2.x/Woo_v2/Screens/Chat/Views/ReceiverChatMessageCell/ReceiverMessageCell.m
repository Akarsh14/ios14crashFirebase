//
//  ReceiverMessageCell.m
//  Woo_v2
//
//  Created by Umesh Mishraji on 19/09/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "ReceiverMessageCell.h"

#define LabelRadius 3
#define kMessageSentImageIcon @"chat_sent"
#define kMessageDeliveredImageIcon  @"chat_delivered"
#define kMessageReadImageIcon   @"chat_read"
#define kMessageInvalidImageIcon @"chat_timer"

@implementation ReceiverMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setChatMessageData:(NSString *)chatMessage andIsSender:(BOOL)isSender andSoWeNeedToChangeYPos:(BOOL)changeYPos{
    
    
    _messageLabelObj_New.text = chatMessage;
//    _messageLabelObj_New.backgroundColor = [UIColor redColor];
    _chatBackgroudView.layer.cornerRadius = 3.0;
    _chatBackgroudView.layer.masksToBounds = TRUE;
    _chatBackgroudView.backgroundColor = kMineChatBackgroundColor;
    NSError *error = NULL;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    
    if ([[APP_Utilities validString:_messageLabelObj_New.text] length]>0) {
        self.stringMatches = [detector matchesInString:_messageLabelObj_New.text options:0 range:NSMakeRange(0, _messageLabelObj_New.text.length)];
    }
    
    float maxWidht = APP_DELEGATE.window.frame.size.width*2/3 - 20 ;
    CGSize constraint = CGSizeMake(maxWidht, MAXFLOAT);
    //    calcu
    CGRect textRect = [_messageLabelObj_New.text boundingRectWithSize:constraint
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName:kChatFont}
                                                          context:nil];
    CGRect newFrame = textRect;
    newFrame.size.width = textRect.size.width + 25;
    if (newFrame.size.width < 75) {
        newFrame.size.width = 75;
    }
    
    widhtContraint.constant = newFrame.size.width;
    
    NSLog(@"constraint bhi set le liya hai isne");
}

- (BOOL)label:(PPLabel *)label didBeginTouch:(UITouch *)touch onCharacterAtIndex:(CFIndex)charIndex {
    
    [self highlightLinksWithIndex:NSNotFound];
    
    for (NSTextCheckingResult *match in self.stringMatches) {
        
        if ([match resultType] == NSTextCheckingTypeLink) {
            
            NSRange matchRange = [match range];
            
            if ([self isIndex:charIndex inRange:matchRange]) {
                
                [[UIApplication sharedApplication] openURL:match.URL];
                break;
            }
        }
    }
    
    return NO;
    
}

- (BOOL)label:(PPLabel *)label didMoveTouch:(UITouch *)touch onCharacterAtIndex:(CFIndex)charIndex {
    
    [self highlightLinksWithIndex:charIndex];
    return NO;
}

- (BOOL)label:(PPLabel *)label didEndTouch:(UITouch *)touch onCharacterAtIndex:(CFIndex)charIndex {
    
    [self highlightLinksWithIndex:NSNotFound];
    
    for (NSTextCheckingResult *match in self.stringMatches) {
        
        if ([match resultType] == NSTextCheckingTypeLink) {
            
            NSRange matchRange = [match range];
            
            if ([self isIndex:charIndex inRange:matchRange]) {
                
                [[UIApplication sharedApplication] openURL:match.URL];
                break;
            }
        }
    }
    
    return NO;
}

- (BOOL)label:(PPLabel *)label didCancelTouch:(UITouch *)touch {
    
    [self highlightLinksWithIndex:NSNotFound];
    return NO;
}


- (BOOL)isIndex:(CFIndex)index inRange:(NSRange)range {
    return index > range.location && index < range.location+range.length;
}

- (void)highlightLinksWithIndex:(CFIndex)index {
    
    NSMutableAttributedString* attributedString = [_messageLabelObj_New.attributedText mutableCopy];
    
    for (NSTextCheckingResult *match in self.stringMatches) {
        
        if ([match resultType] == NSTextCheckingTypeLink) {
            
            NSRange matchRange = [match range];
            
            if (senderMessage) {
                if ([self isIndex:index inRange:matchRange]) {
                    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:matchRange];
                }
                else {
                    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:matchRange];
                }
            }else{
                if ([self isIndex:index inRange:matchRange]) {
                    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:matchRange];
                }
                else {
                    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:matchRange];
                }
            }
            
            
            [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:matchRange];
        }
    }
    
    _messageLabelObj_New.attributedText = attributedString;
    
    
    NSLog(@"lo ji message bhi aa gya hai");
}



-(void)makeLabelRounder:(BOOL)isSender{
    UIBezierPath *buttonMaskPath =  nil;
    if (isSender) {
        buttonMaskPath = [UIBezierPath bezierPathWithRoundedRect:_messageLabelObj_New.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight|UIRectCornerBottomLeft cornerRadii:CGSizeMake(LabelRadius, LabelRadius)];
        _messageLabelObj_New.backgroundColor = kMineChatBackgroundColor;
    }else{
        buttonMaskPath = [UIBezierPath bezierPathWithRoundedRect:_messageLabelObj_New.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight|UIRectCornerBottomRight cornerRadii:CGSizeMake(LabelRadius, LabelRadius)];
        _messageLabelObj_New.backgroundColor = kOtherChatBackgroundColor;
    }
    
    
    CAShapeLayer *buttonMaskLayer = [[CAShapeLayer alloc]init];
    buttonMaskLayer.frame = _messageLabelObj_New.bounds;
    buttonMaskLayer.path = buttonMaskPath.CGPath;
    _messageLabelObj_New.layer.mask = buttonMaskLayer;
}


@end
