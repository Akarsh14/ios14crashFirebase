//
//  CrushMessageCell.m
//  Woo_v2
//
//  Created by Umesh Mishraji on 21/09/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "CrushMessageCell.h"
#define LabelRadius 3
#define kMessageSentImageIcon @"chat_sent"
#define kMessageDeliveredImageIcon  @"chat_delivered"
#define kMessageReadImageIcon   @"chat_read"
#define kMessageInvalidImageIcon @"chat_timer"

@implementation CrushMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setChatMessageData:(NSString *)chatMessage andIsSender:(BOOL)isSender andSoWeNeedToChangeYPos:(BOOL)changeYPos{
    
    
    _messageLabelObj.text = chatMessage;
    _messageLabelObj.layer.cornerRadius = 3.0;
    _messageLabelObj.layer.masksToBounds = TRUE;
    
    crushBackgroundView.layer.cornerRadius = 3.0;
    crushBackgroundView.layer.masksToBounds = TRUE;
    
    
    NSError *error = NULL;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    
    if ([[APP_Utilities validString:_messageLabelObj.text] length]>0) {
        self.stringMatches = [detector matchesInString:_messageLabelObj.text options:0 range:NSMakeRange(0, _messageLabelObj.text.length)];
    }
    
    float maxWidht = APP_DELEGATE.window.frame.size.width - 105;
    CGSize constraint = CGSizeMake(maxWidht, MAXFLOAT);
    //    calcu
    CGRect textRect = [_messageLabelObj.text boundingRectWithSize:constraint
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:[[NSDictionary alloc]initWithObjectsAndKeys:
                                                                   _messageLabelObj.font,NSFontAttributeName,
                                                                   nil]//@{NSFontAttributeName:_messageLabelObj.font}
                                                          context:nil];
    //float cellHeight;
    // text
    //    NSString *messageText = _messageLabelObj.text;
    //
    //    CGSize boundingSize = CGSizeMake(260, 10000000);
    //cellHeight = [APP_Utilities getHeightForText:_messageLabelObj.text forFont:kVerifyingMessageTextFont widthOfLabel:maxWidht];
    
    CGRect newFrame = textRect;
    if (textRect.size.width < 20) {
        newFrame.size.width = 60;
    }
    else{
        newFrame.size.width = textRect.size.width+25+10;
    }
    widhtContraint.constant = newFrame.size.width;
    viewWidhtContraint.constant = newFrame.size.width;
    
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
    
    NSMutableAttributedString* attributedString = [_messageLabelObj.attributedText mutableCopy];
    
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
    
    _messageLabelObj.attributedText = attributedString;
    
}



-(void)makeLabelRounder:(BOOL)isSender{
    UIBezierPath *buttonMaskPath =  nil;
    if (isSender) {
        buttonMaskPath = [UIBezierPath bezierPathWithRoundedRect:_messageLabelObj.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight|UIRectCornerBottomLeft cornerRadii:CGSizeMake(LabelRadius, LabelRadius)];
        _messageLabelObj.backgroundColor = kMineChatBackgroundColor;
    }else{
        buttonMaskPath = [UIBezierPath bezierPathWithRoundedRect:_messageLabelObj.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight|UIRectCornerBottomRight cornerRadii:CGSizeMake(LabelRadius, LabelRadius)];
        _messageLabelObj.backgroundColor = kOtherChatBackgroundColor;
    }
    
    
    CAShapeLayer *buttonMaskLayer = [[CAShapeLayer alloc]init];
    buttonMaskLayer.frame = _messageLabelObj.bounds;
    buttonMaskLayer.path = buttonMaskPath.CGPath;
    _messageLabelObj.layer.mask = buttonMaskLayer;
}

@end
