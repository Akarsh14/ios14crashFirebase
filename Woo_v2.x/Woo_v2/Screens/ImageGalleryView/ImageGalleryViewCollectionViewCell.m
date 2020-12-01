//
//  ImageGalleryViewCollectionViewCell.m
//  Woo_v2
//
//  Created by Akhil Singh on 09/06/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "ImageGalleryViewCollectionViewCell.h"
#import <QuartzCore/QuartzCore.h>

@import PINRemoteImage;

@interface ImageGalleryViewCollectionViewCell()
{
    UIImageView *topGradientImageView;
    UIImageView *bottomGradientImageView;
    
}

@property (nonatomic) UIActivityIndicatorView *progressLoader;

@end

@implementation ImageGalleryViewCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"ImageGalleryViewCollectionViewCell" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex:0];
    }
    
    return self;
}

- (void)loadImageWithImageNamed:(NSString *)imageName ForGender:(BOOL)isMale
{
    NSURL *imageURL =[NSURL URLWithString:imageName];
    self.hidden = false;
    
    if (!self.progressLoader) {
        self.progressLoader = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.progressLoader.center = self.center;
        [self.profileImageView addSubview:self.progressLoader];
    }
    
    [self.progressLoader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.profileImageView.mas_centerY);
        make.centerX.equalTo(self.profileImageView.mas_centerX);
    }];

    self.progressLoader.color = [UIColor darkGrayColor];
    self.progressLoader.hidesWhenStopped = true;
    
    if (_isProfileImageAlreadyLoaded) {
        self.progressLoader.hidden = true;
//        UIImageView *imageView = [[UIImageView alloc] init];
//        [imageView sd_setImageWithURL:imageURL placeholderImage:nil options:SDWebImageHighPriority progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//            self.profileImageView.image = image;
//        }];
    }
    else{

    self.progressLoader.hidden = true;
    
//    [self.progressLoader startAnimating];
//        [[[PINRemoteImageManager sharedImageManager] cache] removeAllObjects];
        [[PINRemoteImageManager sharedImageManager] setProgressiveRendersShouldBlur:YES completion:nil];
        [[PINRemoteImageManager sharedImageManager] shouldBlurProgressive];
        [self.profileImageView setPin_updateWithProgress:YES];
        
//        [self.profileImageView pin_setImageFromURL:imageURL completion:^(PINRemoteImageManagerResult * _Nonnull result) {
//
//            NSData *highestImageCompressionData = UIImageJPEGRepresentation(self.profileImageView.image, 1.0);
//            self.profileImageView.image = [UIImage imageWithData:highestImageCompressionData];
//
//            CIFilter * controlsFilter = [CIFilter filterWithName:@"CIColorControls"];
//
//            CIImage *img = [CIImage imageWithCGImage:self.profileImageView.image.CGImage];
//            [controlsFilter setValue:img forKey:kCIInputImageKey];
//            [controlsFilter setValue:[NSNumber numberWithDouble:1.15] forKey:@"inputContrast"];
////            [controlsFilter setValue:[NSNumber numberWithDouble:1.2] forKey:@"inputSaturation"];
//            CIContext *context = [CIContext contextWithOptions:nil];
//
//            self.profileImageView.image = [UIImage imageWithCGImage: [context createCGImage:controlsFilter.outputImage fromRect:controlsFilter.outputImage.extent]];
//        }];
        
    [self.profileImageView sd_setImageWithURL:imageURL placeholderImage:nil options:SDWebImageHighPriority progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [self.progressLoader stopAnimating];
        if(!self->_isProfileImageAlreadyLoaded){

            CIFilter * controlsFilter = [CIFilter filterWithName:@"CIColorControls"];

            CIImage *img = [CIImage imageWithCGImage:self.profileImageView.image.CGImage];
            [controlsFilter setValue:img forKey:kCIInputImageKey];
            [controlsFilter setValue:[NSNumber numberWithDouble:1.07] forKey:@"inputContrast"];

            CIContext *context = [CIContext contextWithOptions:nil];

            self.profileImageView.image = [UIImage imageWithCGImage: [context createCGImage:controlsFilter.outputImage fromRect:controlsFilter.outputImage.extent]];

        }

    }];
          
    }
    
    
//    if (!topGradientImageView) {
//    topGradientImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"discover_overlay_top"]];
//    }
//    else{
//        [topGradientImageView removeFromSuperview];
//    }
//    topGradientImageView.frame = CGRectMake(0, 0, self.profileImageView.frame.size.width, self.profileImageView.frame.size.height);
////    [self.profileImageView addSubview:topGradientImageView];
//    
//    if (!bottomGradientImageView) {
//        bottomGradientImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"discover_overlay_bottom"]];
//    }
//    else{
//        [bottomGradientImageView removeFromSuperview];
//    }
//    bottomGradientImageView.frame = CGRectMake(0, 0, self.profileImageView.frame.size.width, self.profileImageView.frame.size.height);
//    [self.profileImageView addSubview:bottomGradientImageView];
    
//    [topGradientImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.profileImageView.mas_top);
//        make.left.equalTo(self.profileImageView.mas_left);
//        make.right.equalTo(self.profileImageView.mas_right);
//        make.height.equalTo(self.profileImageView).with.multipliedBy(0.3);
//
//    }];
//    
//    [bottomGradientImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(topGradientImageView.mas_bottom);
//        make.bottom.equalTo(self.profileImageView.mas_bottom);
//        make.left.equalTo(self.profileImageView.mas_left);
//        make.right.equalTo(self.profileImageView.mas_right);
//        make.height.equalTo(self.profileImageView).with.multipliedBy(0.5);
//        
//    }];
}

-(void) removeShadowLayers {
    if (topGradientImageView) {
        [bottomGradientImageView removeFromSuperview];
    }
    
    if (bottomGradientImageView) {
        [bottomGradientImageView removeFromSuperview];
    }
}

@end
