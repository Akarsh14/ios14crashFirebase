//
//  RecieverImageCell.h
//  Woo_v2
//
//  Created by Umesh Mishra on 31/07/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatMessage.h"
//#import "DACircularProgressView.h"

@interface RecieverImageCell : UITableViewCell{
    __weak IBOutlet UIImageView *recievedImageObj;
    __weak IBOutlet UIView *downloadView;
    __weak IBOutlet UILabel *kbLabel;
    __weak IBOutlet UIView *imageContainerView;
    ChatMessage *chatMessageObj;
    BOOL isImageDownloadedForIncomingImageChat;
    __weak IBOutlet EditProfileProgressbar *circularProgressView;
//    DACircularProgressView *circularProgressView;
    void(^downloadButtonTappedBlock)(ChatMessage *);
    
}
-(void)setImageRecievedByTheUser:(ChatMessage *)imageChatDetail;

@property (nonatomic, weak) id delegate;

-(IBAction)downloadButtonTapped:(id)sender;
-(void)downloadButtonTappedBlock:(void(^)(ChatMessage *messageObj))block;
@end
