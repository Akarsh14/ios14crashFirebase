//
//  ChatStickerCell.m
//  Woo
//
//  Created by Umesh Mishra on 09/05/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "ChatStickerCell.h"
#define kLeftAlignedImageFrame CGRectMake(20, 10, 132, 115)
#define kRightAlignedImageFrame CGRectMake(SCREEN_WIDTH - 135, 10, 132, 115)


@implementation ChatStickerCell

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

-(void)showImage:(NSString *)imageURL{
    UIActivityIndicatorView *activityIndicatorViewObj;
    if (!activityIndicatorViewObj) {
        activityIndicatorViewObj = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    [imageViewObj addSubview:activityIndicatorViewObj];
    [imageViewObj setContentMode:UIViewContentModeScaleAspectFit];
    activityIndicatorViewObj.center = CGPointMake(66, 57.5);
    [activityIndicatorViewObj startAnimating];
    activityIndicatorViewObj.hidden = FALSE;
//    NSString *stickerURL = [[NSString stringWithFormat:@"%@sticker_%@",kStickerBaseURL,imageURL] stringByReplacingOccurrencesOfString:@"jpeg" withString:@"png"];
    NSString *stickerURL = [NSString stringWithFormat:@"%@%@",kStickerBaseURL,imageURL];
    [imageViewObj sd_setImageWithURL:[NSURL URLWithString:stickerURL] placeholderImage:nil];
    [imageViewObj sd_setImageWithURL:[NSURL URLWithString:stickerURL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [activityIndicatorViewObj stopAnimating];
        activityIndicatorViewObj.hidden = TRUE;
    }];
}
-(void)alignImageViewToLeft:(BOOL)allignLeft{
    
    UIImageView *stickerImage = (UIImageView *)[self.contentView viewWithTag:111117];
    [stickerImage setContentMode:UIViewContentModeScaleAspectFit];
    if (stickerImage) {
        [stickerImage removeFromSuperview];
        stickerImage = nil;
    }
    if (!stickerImage) {
        stickerImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 13, 8)];
    }
    stickerImage.tag = 111117;
    stickerImage.image = imageViewObj.image;
    [self.contentView addSubview:stickerImage];
    imageViewObj = stickerImage;
    if (allignLeft) {
        imageViewObj.frame = kLeftAlignedImageFrame;
    }
    else{
        imageViewObj.frame = kRightAlignedImageFrame;
    }
}

@end
