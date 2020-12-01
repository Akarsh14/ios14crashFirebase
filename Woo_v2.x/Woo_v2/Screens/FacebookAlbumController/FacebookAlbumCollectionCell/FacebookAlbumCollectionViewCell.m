//
//  FacebookAlbumCollectionViewCell.m
//  Woo_v2
//
//  Created by Deepak Gupta on 6/1/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "FacebookAlbumCollectionViewCell.h"

@implementation FacebookAlbumCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


#pragma mark - Update Data on UI
-(void)updateDataOnCellFromDictionay:(NSDictionary *)dataDict withBottomViewVisible : (BOOL)isVisible withWidth:(int)width withHeight:(int)height{
    
    NSURL *urlImage = nil;
    
    if (isVisible) {
        [viewBottom setHidden:NO];
        [lblAlbumName setText:[dataDict objectForKey:@"albumName"]];
        urlImage =   [NSURL URLWithString:[dataDict objectForKey:@"albumUrl"]];

        
   //     [imgViewCover sd_setImageWithURL:[NSURL URLWithString:[dataDict objectForKey:@"albumUrl"]] placeholderImage:GET_SAME_GENDER_PLACEHOLDER completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
  //      }];

    }else{
        
        [viewBottom setHidden:YES];
        
        urlImage =   [NSURL URLWithString:[dataDict objectForKey:@"srcBig"]];

//        [imgViewCover sd_setImageWithURL:[NSURL URLWithString:[dataDict objectForKey:@"srcBig"]] placeholderImage:GET_SAME_GENDER_PLACEHOLDER completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        }];

        
    }
    
    
    NSURL *   croppedImageURL = [NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(width),IMAGE_SIZE_FOR_POINTS(height), [APP_Utilities encodeFromPercentEscapeString:[urlImage absoluteString]]];
    
    
    NSString *placeHolderImageStr = [APP_Utilities isGenderMale:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserGender]] ? @"placeholder_male" : @"placeholder_female";
    
    [imgViewCover sd_setImageWithURL:croppedImageURL
               placeholderImage:[UIImage imageNamed:placeHolderImageStr]];

    
    
    
}
@end
