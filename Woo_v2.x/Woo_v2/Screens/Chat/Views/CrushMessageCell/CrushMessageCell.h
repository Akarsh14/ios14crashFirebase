//
//  CrushMessageCell.h
//  Woo_v2
//
//  Created by Umesh Mishraji on 21/09/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatMessageLabel.h"
#import "PPLabel.h"

@interface CrushMessageCell : UITableViewCell<PPLabelDelegate>{
    BOOL senderMessage;
    IBOutlet NSLayoutConstraint *widhtContraint;
    IBOutlet NSLayoutConstraint *viewWidhtContraint;
    IBOutlet UIView *crushBackgroundView;
}

@property(nonatomic, strong) NSArray* stringMatches;

@property(nonatomic, retain)IBOutlet ChatMessageLabel *messageLabelObj;

-(void)setChatMessageData:(NSString *)chatMessage andIsSender:(BOOL)isSender andSoWeNeedToChangeYPos:(BOOL)changeYPos;
-(void)makeLabelRounder:(BOOL)isSender;
@end
