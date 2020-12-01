//
//  RecieverImageCell.m
//  Woo_v2
//
//  Created by Umesh Mishra on 31/07/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "RecieverImageCell.h"

@interface RecieverImageCell()
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation RecieverImageCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    circularProgressView.hidden = TRUE;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setImageRecievedByTheUser:(ChatMessage *)imageChatDetail{
    imageContainerView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    chatMessageObj = imageChatDetail;
//    circularProgressView.hidden = TRUE;
    circularProgressView.hidden = TRUE;
    [circularProgressView setFillColorVarlue:[UIColor lightGrayColor]];
    
    NSNumber *messageCreatedTime = [chatMessageObj chatMessageCreatedTime];
    NSString *messageTimeString = messageCreatedTime.stringValue;
    NSTimeInterval _interval=[messageTimeString doubleValue]/1000;
    NSDate *dateOfMessage = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm a"];
    NSLog(@"Time: %@", [formatter stringFromDate:dateOfMessage]);
    [self.timeLabel setText:[formatter stringFromDate:dateOfMessage]];
    
    [[SDImageCache sharedImageCache] queryCacheOperationForKey:imageChatDetail.message done:^(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType) {
        
        if (image) {
            isImageDownloadedForIncomingImageChat = TRUE;
            downloadView.hidden = TRUE;
            [recievedImageObj sd_setImageWithURL:[NSURL URLWithString:imageChatDetail.message] placeholderImage:nil];
        }
        else{
            isImageDownloadedForIncomingImageChat = FALSE;
            NSURL *lowResImageUrl =[NSURL URLWithString:[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(5), IMAGE_SIZE_FOR_POINTS(5),imageChatDetail.message]];
            [recievedImageObj sd_setImageWithURL:lowResImageUrl placeholderImage:nil];
            downloadView.hidden = FALSE;
            kbLabel.text = NSLocalizedString(@"65 KB", @"");
            if ([[APP_Utilities validString:imageChatDetail.imageSize] length]>0) {
                kbLabel.text = [NSString stringWithFormat:@"%d KB",[imageChatDetail.imageSize intValue]/1024];
            }
        }
    }];
}

-(IBAction)downloadButtonTapped:(id)sender{
    if (isImageDownloadedForIncomingImageChat) {
        
        if (downloadButtonTappedBlock) {
            downloadButtonTappedBlock(chatMessageObj);
        }
    }
    else{
        if(![APP_Utilities reachable]){
            return;
        }
        if (!isImageDownloadedForIncomingImageChat) {
            circularProgressView.hidden = FALSE;
            circularProgressView.progressValue = 5.0;
            circularProgressView.tag = 111115;
            [circularProgressView setFillColorVarlue:[UIColor lightGrayColor]];
            UIImage *lowResImage = recievedImageObj.image;
            
            downloadView.hidden = TRUE;
            NSURL *imageUrls = [NSURL URLWithString:chatMessageObj.message];
            
            [recievedImageObj sd_setImageWithPreviousCachedImageWithURL:imageUrls placeholderImage:lowResImage options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                float received = (float )receivedSize;
                float expected = (float )expectedSize;
                circularProgressView.hidden = FALSE;
                circularProgressView.progressValue = received/expected;
            } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                if (error) {
                    isImageDownloadedForIncomingImageChat = FALSE;
                    downloadView.hidden = FALSE;
                }
                else{
                    isImageDownloadedForIncomingImageChat = TRUE;
                    downloadView.hidden = TRUE;
                }
                circularProgressView.hidden = TRUE;
                [circularProgressView removeFromSuperview];
            }];
        }
    }
}
-(void)downloadButtonTappedBlock:(void(^)(ChatMessage *messageObj))block{
    downloadButtonTappedBlock = block;
}

@end
