//
//  ChatImageCell.m
//  Woo_v2
//
//  Created by Umesh Mishra on 02/07/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "ChatImageCell.h"
//#import "DACircularProgressView.h"
#import "APIQueue.h"


#define LabelRadius 9
#define kMessageSentImageIcon @"chat_delivered"
#define kMessageDeliveredImageIcon  @"chat_delivered"
#define kMessageReadImageIcon   @"chat_delivered"
#define kMessageInvalidImageIcon @"chat_timer"



@implementation ChatImageCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setChatImage:(ChatMessage *)imageChatDetail isSenderMe:(BOOL)isSenderMe{
    chatMessageObj = imageChatDetail;
    isSenderSelf = isSenderMe;
    
    for (id viewObj in [self.contentView subviews]) {
      //  UIView *changedView = (UIView *)viewObj;
        [viewObj removeFromSuperview];
//        NSLog(@"view tag :%ld",(long)changedView.tag);
    }
//    NSLog(@"\n\n"); 
    
    UIImageView *imageViewObj = (UIImageView *)[self.contentView viewWithTag:111113];
    if (imageViewObj) {
        [imageViewObj removeFromSuperview];
        imageViewObj = nil;
    }
    if (!imageViewObj) {
        imageViewObj = [[UIImageView alloc] init];
    }
    
    if (!isSenderMe) {
        imageViewObj.frame = kLeftAlignedImageFrame;
    }
    else{
        imageViewObj.frame = kRightAlignedImageFrame;
    }
    imageViewObj.tag = 111113;
    [self.contentView addSubview:imageViewObj];
    
    imageObj = imageViewObj;
    
    UIButton *tryButton = (UIButton *)[self.contentView viewWithTag:111114];
    if (tryButton) {
        [tryButton removeFromSuperview];
        tryButton = nil;
    }
    if (!tryButton) {
        tryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    tryButton.frame = imageObj.frame;
    tryAgainButtonObj = tryButton;
    [tryAgainButtonObj addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    tryAgainButtonObj.backgroundColor = [UIColor colorWithRed:0.12 green:0.13 blue:0.14 alpha:0.2];
    [self.contentView addSubview:tryButton];
    
    
    if (isSenderMe) {
        
        NSString *cacheDirectory = [NSString stringWithFormat:@"%@/%@",[APP_Utilities applicationCacheDirectory],kSelfieImagesFolderName];
        NSString *getImagePath = [cacheDirectory stringByAppendingPathComponent:imageChatDetail.message];
        UIImage *img = [UIImage imageWithContentsOfFile:getImagePath];
        imageObj.image = img;
        
        NSString *uploadImageUrl = [NSString stringWithFormat:@"%@%@?wooId=%@",kBaseURLV3,kUploadPictures,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
        
        if (![imageChatDetail.ifchatImageIsItUploaded boolValue] && !imageChatDetail.layerMessageID) {
            
            NSData *imageDataAfterReduction = UIImageJPEGRepresentation(img,0);
            [self checkAndUploadImageToServerAndShowProgress:imageDataAfterReduction withChatDetails:imageChatDetail isSender:isSenderMe];
            [ChatMessage updateDeliveryStatusOfImage:imageChatDetail.clientMessageID withUpdationHandler:nil];
        }
        else{
            if ([imageChatDetail.layerMessageID length]>0) {
                [imageObj sd_setImageWithURL:[NSURL URLWithString:imageChatDetail.message] placeholderImage:nil];
            }
            else{
                if ([[APIQueue sharedAPIQueue] getUploadOpertaionIfExistForUrl:uploadImageUrl andImageName:imageChatDetail.message]) {
                    // Convert UIImage object into NSData (a wrapper for a stream of bytes) formatted according to PNG spec
                    NSData *imageDataAfterReduction = UIImageJPEGRepresentation(img,0);
                    [self checkAndUploadImageToServerAndShowProgress:imageDataAfterReduction withChatDetails:imageChatDetail isSender:isSenderMe];
                }
                else{
                    [tryAgainButtonObj setImage:[UIImage imageNamed:@"chat_retry"] forState:UIControlStateNormal];
                    //            [tryAgainButtonObj setBackgroundColor:[UIColor redColor]];
                }
            }
        }
    }
    else{
        [[SDImageCache sharedImageCache] queryCacheOperationForKey:imageChatDetail.message done:^(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType) {
            if (image) {
                isImageDownloadedForIncomingImageChat = TRUE;
                [imageObj sd_setImageWithURL:[NSURL URLWithString:imageChatDetail.message] placeholderImage:nil];
            }
            else{
                isImageDownloadedForIncomingImageChat = FALSE;
                NSURL *lowResImageUrl =[NSURL URLWithString:[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(50), IMAGE_SIZE_FOR_POINTS(50),imageChatDetail.message]];
                [imageObj sd_setImageWithURL:lowResImageUrl placeholderImage:nil];
                [tryAgainButtonObj setImage:[UIImage imageNamed:@"chat_kb"] forState:UIControlStateNormal];
            }
        }];
    }
    
    imageObj.layer.cornerRadius = 5;
    imageObj.layer.masksToBounds = TRUE;
    imageObj.layer.borderWidth = 1;
    imageObj.layer.borderColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0].CGColor;
    
    
    UIImageView *statusImage = (UIImageView *)[self.contentView viewWithTag:111112];
    if (statusImage) {
        [statusImage removeFromSuperview];
        statusImage = nil;
    }
    if (!statusImage) {
        statusImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 13, 9)];
    }
    statusImage.tag = 111112;
    statusImage.image = [UIImage imageNamed:kMessageInvalidImageIcon];
    statusImage.contentMode = UIViewContentModeScaleAspectFit;
    statusIcon = statusImage;
    statusIcon.hidden = !isSenderMe;
//    senderMessage = isSenderMe;
    CGRect iconFrame = statusIcon.frame;
    iconFrame.origin.x = imageObj.frame.origin.x + imageObj.frame.size.width - 20;
    iconFrame.origin.y = imageObj.frame.origin.y + imageObj.frame.size.height - 13;
    statusIcon.frame = iconFrame;
    [self.contentView addSubview:statusIcon];
//    [self setMessageStatusIcon:[imageChatDetail.chatDeliveryStatus intValue]];

}
//-(void)setMessageStatusIcon:(LYRRecipientStatus)status{
//
//    NSLog(@"setMessageStatusIcon status: %ld",(long)status);
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
//            [statusIcon setImage:[UIImage imageNamed:kMessageReadImageIcon]];
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
-(IBAction)buttonTapped:(id)sender{
    if (isSenderSelf || (!isSenderSelf && isImageDownloadedForIncomingImageChat)) {
        if (tryAgainButtonObj.isSelected || [chatMessageObj.layerMessageID length]>0) {
            if ([chatMessageObj.layerMessageID length]>0) {
                if ([_delegate respondsToSelector:_selectorForButtonTapped]) {
                    [_delegate performSelector:_selectorForButtonTapped withObject:chatMessageObj afterDelay:0.0];
                }
            }
            return;
        }
    }
    else{
        if (!isImageDownloadedForIncomingImageChat) {
            
//            DACircularProgressView *circularProgressView = (DACircularProgressView *)[self.contentView viewWithTag:111115];
//            
//            if (circularProgressView) {
//                [circularProgressView removeFromSuperview];
//                circularProgressView = nil;
//            }
            
            
//            circularProgressView = [[DACircularProgressView alloc]init];
//            circularProgressView.roundedCorners = YES;
//            circularProgressView.tag = 111115;
//            circularProgressView.trackTintColor = kVeryLightGrayColor;
//            circularProgressView.progressTintColor = kHeaderTextRedColor;
//            [circularProgressView setCenter:CGPointMake(75, 75)];
            //    [circularProgressView setCenter:imageObj.center];
//            [imageObj addSubview:circularProgressView];
            
            [tryAgainButtonObj setImage:nil forState:UIControlStateNormal];
            [imageObj sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:chatMessageObj.message] placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                float received = (float )receivedSize;
                float expected = (float )expectedSize;
                
//                [circularProgressView setProgress:(received/expected) animated:YES];
            } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                NSLog(@"image object ");
                isImageDownloadedForIncomingImageChat = TRUE;
//                [circularProgressView removeFromSuperview];
                
            }];
            return;
        }
    }
    
    
    [tryAgainButtonObj setImage:nil forState:UIControlStateNormal];
    NSString *cacheDirectory = [NSString stringWithFormat:@"%@/%@",[APP_Utilities applicationCacheDirectory],kSelfieImagesFolderName];
    NSString *getImagePath = [cacheDirectory stringByAppendingPathComponent:chatMessageObj.message];
    UIImage *img = [UIImage imageWithContentsOfFile:getImagePath];
    imageObj.image = img;
 //   NSData *imageData = UIImageJPEGRepresentation(img, 1);
    
    
//    NSString *uploadImageUrl = [NSString stringWithFormat:@"%@%@?wooId=%@",kBaseURLV1,kUploadPictures,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
//    float imageQualityPercent = (float)(768000/ imageData.length);
    
    NSData *imageDataAfterReduction = UIImageJPEGRepresentation(img,0);
    [self checkAndUploadImageToServerAndShowProgress:imageDataAfterReduction withChatDetails:chatMessageObj isSender:TRUE];
    tryAgainButtonObj.selected = TRUE;
    
//    
    
}

-(void)checkAndUploadImageToServerAndShowProgress:(NSData *)imageData withChatDetails:(ChatMessage *)chatDetails isSender:(BOOL)isSenderMe{
    
    DACircularProgressView *circularProgressView = (DACircularProgressView *)[self.contentView viewWithTag:111115];
    
    if (circularProgressView) {
        [circularProgressView removeFromSuperview];
        circularProgressView = nil;
    }
    
    
    circularProgressView = [[DACircularProgressView alloc]init];
    circularProgressView.roundedCorners = YES;
    circularProgressView.tag = 111115;
    circularProgressView.trackTintColor = kVeryLightGrayColor;
    circularProgressView.progressTintColor = kHeaderTextRedColor;
    [circularProgressView setCenter:CGPointMake(75, 75)];
    [imageObj addSubview:circularProgressView];
    [APP_Utilities uploadPicAndShowProgressForCell:self withCircularProgressView:nil forChatMessage:chatDetails];
}
-(void)alignImageViewToLeft:(BOOL)allignLeft{
    
    UIImageView *imageViewObj = (UIImageView *)[self.contentView viewWithTag:111113];
    if (imageViewObj) {
        [imageViewObj removeFromSuperview];
        imageViewObj = nil;
    }
    
//    if (!imageViewObj) {
//        imageViewObj = [[UIImageView alloc] init];
//    }
    
    if (allignLeft) {
        imageObj.frame = kLeftAlignedImageFrame;
    }
    else{
        imageObj.frame = kRightAlignedImageFrame;
    }
}

@end
