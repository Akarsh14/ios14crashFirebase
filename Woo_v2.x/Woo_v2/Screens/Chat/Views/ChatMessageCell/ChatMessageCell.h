//
//  ChatMessageCell.h
//  Woo
//
//  Created by Umesh Mishra on 06/05/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatMessageLabel.h"
#import "PPLabel.h"

@interface ChatMessageCell : UITableViewCell<PPLabelDelegate>{
    
    IBOutlet UIImageView *statusIcon;
    BOOL senderMessage;
    __weak IBOutlet NSLayoutConstraint *labelWidth;
    __weak IBOutlet NSLayoutConstraint *labelHeight;
    __weak IBOutlet NSLayoutConstraint *labelXPos;
    __weak IBOutlet NSLayoutConstraint *labelYPos;
}
@property(nonatomic, strong) NSArray* stringMatches;

@property(nonatomic, retain)IBOutlet ChatMessageLabel *messageLabelObj;

-(void)setChatMessageData:(NSString *)chatMessage andIsSender:(BOOL)isSender andSoWeNeedToChangeYPos:(BOOL)changeYPos;
-(void)makeLabelRounder:(BOOL)isSender;

//-(void)setMessageStatusIcon:(LYRRecipientStatus)status;
-(void)showDeliveryIcon:(BOOL)shouldShowDeliveryIcon;

@end
