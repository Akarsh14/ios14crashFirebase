//
//  ChatImageCell.h
//  Woo_v2
//
//  Created by Umesh Mishra on 02/07/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatMessage.h"
#define kLeftAlignedImageFrame CGRectMake(20, 5, 150, 150)
#define kRightAlignedImageFrame CGRectMake(SCREEN_WIDTH-170, 5, 150, 150)

@interface ChatImageCell : UITableViewCell{
    __weak IBOutlet UIImageView *imageObj;
    __weak IBOutlet UIButton *tryAgainButtonObj;
    IBOutlet UIImageView *statusIcon;
    ChatMessage *chatMessageObj;
    BOOL isSenderSelf;
    BOOL isImageDownloadedForIncomingImageChat;
    
}

@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) SEL selectorForButtonTapped;

-(void)setChatImage:(ChatMessage *)imageChatDetail isSenderMe:(BOOL)isSenderMe;
-(void)checkAndUploadImageToServerAndShowProgress:(NSData *)imageData withChatDetails:(ChatMessage *)chatDetails isSender:(BOOL)isSenderMe;
-(void)alignImageViewToLeft:(BOOL)alignLeft;
-(IBAction)buttonTapped:(id)sender;

@end
