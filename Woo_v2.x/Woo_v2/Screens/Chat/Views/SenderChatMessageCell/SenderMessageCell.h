//
//  SenderMessageCell.h
//  Woo_v2
//
//  Created by Umesh Mishraji on 19/09/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatMessageLabel.h"
#import "PPLabel.h"

@interface SenderMessageCell : UITableViewCell<PPLabelDelegate>{
    
    IBOutlet UIImageView *statusIcon;
    BOOL senderMessage;
    IBOutlet NSLayoutConstraint *widhtContraint;
    
}

@property(nonatomic, strong) NSArray* stringMatches;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatBackgroundviewTopConstraint;

@property(nonatomic, retain)IBOutlet ChatMessageLabel *messageLabelObj;
@property(nonatomic, retain)IBOutlet UILabel *messageLabelObj_New;
@property(nonatomic, retain)IBOutlet UIView *chatBackgroudView;

-(void)setChatMessageData:(NSString *)chatMessage andIsSender:(BOOL)isSender andSoWeNeedToChangeYPos:(BOOL)changeYPos;
-(void)makeLabelRounder:(BOOL)isSender;

//-(void)setMessageStatusIcon:(LYRRecipientStatus)status applozic:(BOOL)isApplozic;
-(void)showDeliveryIcon:(BOOL)shouldShowDeliveryIcon;

@end
