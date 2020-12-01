//
//  ChatMessageCell.m
//  Woo
//
//  Created by Umesh Mishra on 06/05/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "ChatMessageCell.h"
#define LabelRadius 3
#define kMessageSentImageIcon @"chat_delivered"
#define kMessageDeliveredImageIcon  @"chat_delivered"
#define kMessageReadImageIcon   @"chat_delivered"
#define kMessageInvalidImageIcon @"chat_timer"


@implementation ChatMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)chatMessageLongTapGesture{
//    UILongPressGestureRecognizer *longPressLabel = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(copyLabelText)];
//    
//    longPressLabel.minimumPressDuration = 1.0;
//    longPressLabel.delegate = self;
//    [_messageLabelObj addGestureRecognizer:longPressLabel];
}

-(void)copyLabelText{
//    UIMenuController *menuCOntrollerObj = [UIMenuController sharedMenuController];
//    [menuCOntrollerObj setTargetRect:_messageLabelObj.frame inView:[APP_DELEGATE window]];
//    [menuCOntrollerObj setMenuVisible:YES animated:YES];
//    NSAssert([_messageLabelObj becomeFirstResponder], @"Sorry, UIMenuController will not work with %@ since it cannot become first responder", self);
}
//- (BOOL)canBecomeFirstResponder {
//    return YES;
//}
//-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
//    return action ==@selector(copy:);
//}
//-(void)copy:(id)center{
//    UIPasteboard *pb = [UIPasteboard generalPasteboard];
//    [pb setString:[_messageLabelObj text]];
//}
-(void)setChatMessageData:(NSString *)chatMessage andIsSender:(BOOL)isSender andSoWeNeedToChangeYPos:(BOOL)changeYPos{
    
//    self.backgroundColor = [UIColor purpleColor];
//    self.contentView.backgroundColor = [UIColor orangeColor];
    
    ChatMessageLabel *labelObj = (ChatMessageLabel *)[self.contentView viewWithTag:111111];
    if (labelObj) {
        [labelObj removeFromSuperview];
        labelObj = nil;
    }
    if (!labelObj) {
        labelObj = [[ChatMessageLabel alloc] init];
    }
    
    labelObj.font = kVerifyingMessageTextFont;
    labelObj.text = [APP_Utilities validString:chatMessage];
    labelObj.delegate = self;
    labelObj.tag = 111111;
    labelObj.numberOfLines = 0;
    
    _messageLabelObj = labelObj;
    
    float maxWidht = APP_DELEGATE.window.frame.size.width - 120;
    CGSize constraint = CGSizeMake(maxWidht, MAXFLOAT);
    //    calcu
    CGRect textRect = [labelObj.text boundingRectWithSize:constraint
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes: [[NSDictionary alloc]initWithObjectsAndKeys:labelObj.font,NSFontAttributeName,nil]
  //@{NSFontAttributeName:labelObj.font}
                                                          context:nil];
    
    float cellHeight;
    // text
    NSString *messageText = labelObj.text;
    //
    //    CGSize boundingSize = CGSizeMake(260, 10000000);
    cellHeight = [APP_Utilities getHeightForText:messageText forFont:kVerifyingMessageTextFont widthOfLabel:maxWidht];
    
    CGRect newFrame = textRect;
    if (textRect.size.width < 20) {
        newFrame.size.width = 45+20;
    }
    else{
        newFrame.size.width = textRect.size.width+25+05;
    }
    //Changed Padding from 20 to 10 now. On 06 April 2015
    newFrame.size.height = cellHeight+10 + 1;             //Added this 1 extra height to remove trucated messages. On August 06, 2014
//    int changeInY = 0;
//    if (changeYPos) {
//        changeInY = 3;
//    }
    newFrame.origin.y = 2;
    if (!isSender) {
        newFrame.origin.x = 20;
//        labelObj.textColor = [UIColor blackColor];
    }
    else{
        newFrame.origin.x = APP_DELEGATE.window.frame.size.width - newFrame.size.width - 10;
//        labelObj.textColor = [UIColor whiteColor];
    }
    labelObj.frame = newFrame;
    [self makeLabelRounder:isSender];
    [self.contentView addSubview:labelObj];
    
    UIImageView *statusImage = (UIImageView *)[self.contentView viewWithTag:111112];
    if (statusImage) {
        [statusImage removeFromSuperview];
        statusImage = nil;
    }
    if (!statusImage) {
        statusImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 13, 8)];
    }
    statusImage.tag = 111112;
    statusImage.image = [UIImage imageNamed:kMessageSentImageIcon];
    statusIcon = statusImage;
    statusImage.contentMode = UIViewContentModeScaleAspectFit;
    statusIcon.hidden = !isSender;
    senderMessage = isSender;
    CGRect iconFrame = statusIcon.frame;
    iconFrame.origin.x = _messageLabelObj.frame.origin.x + _messageLabelObj.frame.size.width - 20;
    iconFrame.origin.y = _messageLabelObj.frame.origin.y + _messageLabelObj.frame.size.height - 13;
    statusIcon.frame = iconFrame;
    [self.contentView addSubview:statusIcon];
    NSError *error = NULL;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    
    if ([[APP_Utilities validString:_messageLabelObj.text] length]>0) {
        self.stringMatches = [detector matchesInString:_messageLabelObj.text options:0 range:NSMakeRange(0, _messageLabelObj.text.length)];
    }
    
//    _messageLabelObj.backgroundColor = [UIColor redColor];
//    [self highlightLinksWithIndex:NSNotFound];
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

//-(void)setMessageStatusIcon:(LYRRecipientStatus)status{
//    
//    switch (status) {
//        case LYRRecipientStatusSent:
//            [statusIcon setImage:[UIImage imageNamed:kMessageSentImageIcon]];
//            break;
//            
//        case LYRRecipientStatusDelivered:
//            [statusIcon setImage:[UIImage imageNamed:kMessageDeliveredImageIcon]];
//            break;
//            
//        case LYRRecipientStatusRead:
//            [statusIcon setImage:[UIImage imageNamed:kMessageDeliveredImageIcon]];
//            break;
//            
//        case LYRRecipientStatusInvalid:
//            [statusIcon setImage:[UIImage imageNamed:kMessageInvalidImageIcon]];
//            break;
//            
//        default:
//            [statusIcon setImage:[UIImage imageNamed:kMessageInvalidImageIcon]];
//            break;
//    }
//}
-(void)showDeliveryIcon:(BOOL)shouldShowDeliveryIcon{
    statusIcon.hidden = !shouldShowDeliveryIcon;
}

@end
