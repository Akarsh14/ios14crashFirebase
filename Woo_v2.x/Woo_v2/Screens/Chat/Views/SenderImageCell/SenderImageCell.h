//
//  SenderImageCell.h
//  Woo_v2
//
//  Created by Umesh Mishra on 31/07/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatMessage.h"
//#import "DACircularProgressView.h"
@class EditProfileProgressbar;
@interface SenderImageCell : UITableViewCell{
    __weak IBOutlet UIImageView *sendImageView;
    __weak IBOutlet UIView *retryView;
    __weak IBOutlet UIImageView *statusIconImage;
    __weak IBOutlet UIView *imageContainerView;
    ChatMessage *chatMessageObj;
    EditProfileProgressbar *circularProgressView;
//    DACircularProgressView *circularProgressView;
    void(^retryButtonTappedBlock)(ChatMessage *);
}

-(IBAction)retryButtonTapped:(id)sender;

-(void)setImageSendByTheUser:(ChatMessage *)imageChatDetail isSendertagged:(BOOL)isFlagged isApplozic:(BOOL)applozicUser;
-(void)retryButtonTappedBlock:(void(^)(ChatMessage *messageObj))block;

@property(nonatomic) BOOL isSenderFlagged;
@property (nonatomic, weak) id delegate;

@end
