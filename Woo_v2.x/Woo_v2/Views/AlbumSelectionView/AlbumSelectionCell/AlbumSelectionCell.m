//
//  AlbumSelectionCell.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 13/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "AlbumSelectionCell.h"

@implementation AlbumSelectionCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:NO animated:YES];
    // Configure the view for the selected state
}



-(void)setDataOnCellForAlbumName:(NSString *)nameOfAlbum withAbumImage:(NSURL *)imageURL andNumberOfImages:(int )imagesInAlbum{
    
    [albumNameLabel setText:[APP_Utilities validString:nameOfAlbum]];
    [imageInAlbumLabel setText:[NSString stringWithFormat:@"%d Photos",imagesInAlbum]];
    
    bool isMale = [APP_Utilities isGenderMale:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserGender]];
    UIImage *placeholderImage;
    
    if (isMale) {
        placeholderImage = [UIImage imageNamed:@"placeholder_male"];
    }else{
        placeholderImage = [UIImage imageNamed:@"placeholder_female"];
    }
    [albumKeyImage sd_setImageWithURL:imageURL placeholderImage:placeholderImage];
    
    NSLog(@"URL === %@",[NSURL URLWithString:[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(40), IMAGE_SIZE_FOR_POINTS(40),imageURL]]);
}
@end
