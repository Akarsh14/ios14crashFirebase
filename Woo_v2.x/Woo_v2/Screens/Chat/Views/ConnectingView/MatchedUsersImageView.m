//
//  MatchedUsersImageView.m
//  Woo_v2
//
//  Created by Umesh Mishraji on 15/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "MatchedUsersImageView.h"

@implementation MatchedUsersImageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        NSArray *nibArray = [[NSBundle mainBundle]loadNibNamed:@"MatchedUsersImageView" owner:self options:nil];
        UIView *viewObj = [nibArray lastObject];
        viewObj.frame =self.bounds;
        [self addSubview:viewObj];
        
    }
    return self;
}

-(void)setLeftUserImage:(NSString *)leftUserImageUrlString getFromUrl:(BOOL)getLeftImageFromUrl andRightUserImage:(NSString *)rightUserImageUrlString getFromURl:(BOOL)getRightImageFromUrl{
    leftUserImage.layer.cornerRadius = 50;
    leftUserImage.layer.masksToBounds =  TRUE;
    if (getLeftImageFromUrl) {
        [leftUserImage sd_setImageWithURL:[NSURL URLWithString:leftUserImageUrlString] placeholderImage:[UIImage imageNamed:@"ic_me_avatar_big"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            leftUserImage.layer.cornerRadius = 50;
            leftUserImage.layer.masksToBounds =  TRUE;
        }];
    }
    else{
        leftUserImage.image = [UIImage imageNamed:leftUserImageUrlString];
    }
    
    if ([rightUserImageUrlString length] < 1) {
        rightUserImageUrlString = @"ic_me_avatar_big";
        getRightImageFromUrl = false;
    }
    
    rightUserImage.layer.cornerRadius = 50;
    rightUserImage.layer.masksToBounds =  TRUE;
    if (getRightImageFromUrl) {
        if (rightUserImageUrlString.length > 0) {
            [rightUserImage sd_setImageWithURL:[NSURL URLWithString:rightUserImageUrlString] placeholderImage:[UIImage imageNamed:@"ic_me_avatar_big"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                rightUserImage.layer.cornerRadius = 50;
                rightUserImage.layer.masksToBounds =  TRUE;
                
            }];
        }
        
    }
    else{
        rightUserImage.image = [UIImage imageNamed:rightUserImageUrlString];
    }
    
    rightUserContainerView.layer.cornerRadius = 55;
    rightUserContainerView.layer.masksToBounds = TRUE;
    
}

@end
