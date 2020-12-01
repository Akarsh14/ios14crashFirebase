//
//  SenderImageCell.m
//  Woo_v2
//
//  Created by Umesh Mishra on 31/07/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "SenderImageCell.h"
#define LabelRadius 9
#define kMessageSentImageIcon @"chat_delivered"
#define kMessageDeliveredImageIcon  @"chat_delivered"
#define kMessageReadImageIcon   @"chat_delivered"
#define kMessageInvalidImageIcon @"chat_timer"
#import "ApplozicChatHelperClass.h"

@interface SenderImageCell(){
    BOOL isApplozicUser;
}
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation SenderImageCell

- (void)awakeFromNib {
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
  
}

-(void)addprogressLoaderView{
    if (!circularProgressView) {
        circularProgressView = [[EditProfileProgressbar alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [circularProgressView setFillColorVarlue:[UIColor lightGrayColor]];
        circularProgressView.hidden = TRUE;
        [imageContainerView addSubview:circularProgressView];
    }
//    circularProgressView.frame = CGRectMake(0, 0, 44, 44);
    
//    circularProgressView.center = imageContainerView.center;
}

-(void)setImageSendByTheUser:(ChatMessage *)imageChatDetail isSendertagged:(BOOL)isFlagged isApplozic:(BOOL)applozicUser{
    self.isSenderFlagged = isFlagged;
    isApplozicUser = applozicUser;
    imageContainerView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self addprogressLoaderView];
    NSString *cacheDirectory = [NSString stringWithFormat:@"%@/%@",[APP_Utilities applicationCacheDirectory],kSelfieImagesFolderName];
    NSString *imagePathName = [[imageChatDetail.message componentsSeparatedByString:@"/"] lastObject];
    NSString *getImagePath = [cacheDirectory stringByAppendingPathComponent:imagePathName];
    UIImage *img = [UIImage imageWithContentsOfFile:getImagePath];
    sendImageView.image = img;
    sendImageView.backgroundColor = [APP_Utilities getUIColorObjectFromHexString:@"EDEDED" alpha:1.0];
    circularProgressView.hidden = TRUE;
    chatMessageObj = imageChatDetail;
    
    NSNumber *messageCreatedTime = [chatMessageObj chatMessageCreatedTime];
    NSString *messageTimeString = messageCreatedTime.stringValue;
    NSTimeInterval _interval=[messageTimeString doubleValue]/1000;
    NSDate *dateOfMessage = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm a"];
    NSLog(@"Time: %@", [formatter stringFromDate:dateOfMessage]);
    [self.timeLabel setText:[formatter stringFromDate:dateOfMessage]];
    
//    [self checkAndRemoveOtherProgressViewFromCell];
    NSString *uploadImageUrl = [NSString stringWithFormat:@"%@%@?wooId=%@",kBaseURLV1,kUploadPictures,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
    
    if ([APP_Utilities reachable]) {
        if (![imageChatDetail.ifchatImageIsItUploaded boolValue] && !imageChatDetail.layerMessageID) {
            
            NSData *imageDataAfterReduction = UIImageJPEGRepresentation(img,0);
            [self checkAndUploadImageToServerAndShowProgress:imageDataAfterReduction withChatDetails:imageChatDetail isSenderFlagged:isFlagged];
            [ChatMessage updateDeliveryStatusOfImage:imageChatDetail.clientMessageID withUpdationHandler:nil];
            retryView.hidden = TRUE;
        }
        else{
            if ([imageChatDetail.layerMessageID length]>0) {
                UIImage *lowResImage = sendImageView.image;
                if (img) {
                    sendImageView.image = img;
                }
                else{
                    [sendImageView sd_setImageWithURL:[NSURL URLWithString:imageChatDetail.message] placeholderImage:lowResImage];
                }
                
                retryView.hidden = TRUE;
            }
            else{
                if ([[APIQueue sharedAPIQueue] getUploadOpertaionIfExistForUrl:uploadImageUrl andImageName:imageChatDetail.message]) {
                    // Convert UIImage object into NSData (a wrapper for a stream of bytes) formatted according to PNG spec
                    NSData *imageDataAfterReduction = UIImageJPEGRepresentation(img,0);
                    [self checkAndUploadImageToServerAndShowProgress:imageDataAfterReduction withChatDetails:imageChatDetail isSenderFlagged:isFlagged];
                    retryView.hidden = TRUE;
                }
                else{
                    retryView.hidden = FALSE;
                    //            [tryAgainButtonObj setBackgroundColor:[UIColor redColor]];
                }
            }
        }
    }
    else{
        if ([imageChatDetail.ifchatImageIsItUploaded boolValue] && [imageChatDetail.layerMessageID length] > 0) {
            [sendImageView sd_setImageWithURL:[NSURL URLWithString:imageChatDetail.message] placeholderImage:nil];
            retryView.hidden = TRUE;
            circularProgressView.hidden = TRUE;
        }
        else{
            NSString *cacheDirectory = [NSString stringWithFormat:@"%@/%@",[APP_Utilities applicationCacheDirectory],kSelfieImagesFolderName];
            NSString *getImagePath = [cacheDirectory stringByAppendingPathComponent:imageChatDetail.message];
            UIImage *img = [UIImage imageWithContentsOfFile:getImagePath];
            circularProgressView.hidden = TRUE;
            sendImageView.image = img;
            chatMessageObj = imageChatDetail;
            [ChatMessage updateDeliveryStatusOfImage:imageChatDetail.clientMessageID withUpdationHandler:nil];
            retryView.hidden = FALSE;
        }
    }
//    [self setMessageStatusIcon:[imageChatDetail.chatDeliveryStatus intValue]];
}

-(void)checkAndUploadImageToServerAndShowProgress:(NSData *)imageData withChatDetails:(ChatMessage *)chatDetails isSenderFlagged:(BOOL)isFlagged{
    
    circularProgressView.progressValue = 5.0;
    circularProgressView.frame = CGRectMake(imageContainerView.frame.size.width/2 -22, imageContainerView.frame.size.height/2 -22, 44, 44);
    [imageContainerView bringSubviewToFront:circularProgressView];
    circularProgressView.hidden = FALSE;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (isApplozicUser){
            [APPLOZIC_HELPER uploadPicAndShowProgressForCell:self withCircularProgressView:circularProgressView forChatMessage:chatDetails isSenderFlagged:isFlagged];
        }
        else{
        [LAYER_HELPER uploadPicAndShowProgressForCell:self withCircularProgressView:circularProgressView forChatMessage:chatDetails isSenderFlagged:isFlagged];
        }
    });
}

- (void)layoutSubviews
{
    [super layoutSubviews];
//    circularProgressView.frame = CGRectMake(self.frame.size.width- 24 - (imageContainerView.frame.size.width/2)-22, self.frame.size.height - 3 - (imageContainerView.frame.size.height/2) -22, 44, 44);
}
-(void)viewDidLayoutSubviews
{
    

}
//-(void)setMessageStatusIcon:(LYRRecipientStatus)status{
//    
//    if (isApplozicUser){
//        switch (status) {
//                
//            case LYRRecipientStatusPending:
//                [statusIconImage setImage:[UIImage imageNamed:kMessageInvalidImageIcon]];
//                break;
//                
//            case LYRRecipientStatusSent:
//                [statusIconImage setImage:[UIImage imageNamed:kMessageSentImageIcon]];
//                break;
//                
//                
//            case APPLOZICRead | LYRRecipientStatusDelivered | LYRRecipientStatusRead:
//                [statusIconImage setImage:[UIImage imageNamed:kMessageDeliveredImageIcon]];
//                break;
//                
//            case APPLOZICdelivered:
//                [statusIconImage setImage:[UIImage imageNamed:kMessageDeliveredImageIcon]];
//                break;
//                
//            default:
//                [statusIconImage setImage:[UIImage imageNamed:kMessageInvalidImageIcon]];
//                break;
//        }
//        
//    }
//    else{
//    switch (status) {
//        case LYRRecipientStatusSent:
//            [statusIconImage setImage:[UIImage imageNamed:kMessageSentImageIcon]];
//            break;
//            
//        case LYRRecipientStatusDelivered:
//            [statusIconImage setImage:[UIImage imageNamed:kMessageDeliveredImageIcon]];
//            break;
//            
//        case LYRRecipientStatusRead:
//            [statusIconImage setImage:[UIImage imageNamed:kMessageReadImageIcon]];
//            break;
//            
//        case LYRRecipientStatusInvalid:
//            [statusIconImage setImage:[UIImage imageNamed:kMessageInvalidImageIcon]];
//            break;
//            
//        default:
//            [statusIconImage setImage:[UIImage imageNamed:kMessageInvalidImageIcon]];
//            break;
//    }
//    }
//}

-(IBAction)retryButtonTapped:(id)sender{
    if ([chatMessageObj.layerMessageID length]>0) {
        
        if (retryButtonTappedBlock) {
            retryButtonTappedBlock(chatMessageObj);
        }
    }
    else{
        retryView.hidden = TRUE;
        NSString *cacheDirectory = [NSString stringWithFormat:@"%@/%@",[APP_Utilities applicationCacheDirectory],kSelfieImagesFolderName];
        NSString *getImagePath = [cacheDirectory stringByAppendingPathComponent:chatMessageObj.message];
        UIImage *img = [UIImage imageWithContentsOfFile:getImagePath];
        sendImageView.image = img;
        NSData *imageDataAfterReduction = UIImageJPEGRepresentation(img,0);
        [self checkAndUploadImageToServerAndShowProgress:imageDataAfterReduction withChatDetails:chatMessageObj isSenderFlagged:self.isSenderFlagged];

    }
}

-(void)checkAndRemoveOtherProgressViewFromCell{
    EditProfileProgressbar *firstProgressView = nil;
    EditProfileProgressbar *secodnProgressView = nil;
    for (id subView in [imageContainerView subviews]) {
        if ([subView isKindOfClass:[EditProfileProgressbar class]]) {
            if (!firstProgressView) {
                firstProgressView = (EditProfileProgressbar *)subView;
            }
            else{
                if (!secodnProgressView) {
                    secodnProgressView = (EditProfileProgressbar *)subView;
                }
            }
        }
    }
}
-(void)retryButtonTappedBlock:(void(^)(ChatMessage *messageObj))block{
    retryButtonTappedBlock = block;
}

@end
