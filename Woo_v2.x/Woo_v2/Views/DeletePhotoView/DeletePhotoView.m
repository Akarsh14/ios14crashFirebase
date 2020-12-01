//
//  PopularUserView.m
//  Woo_v2
//
//  Created by Suparno Bose on 1/14/16.
//  Copyright © 2016 Woo. All rights reserved.
//

#import "DeletePhotoView.h"
#import "SDWebImageDownloader.h"

@interface DeletePhotoView ()
{
    __weak IBOutlet UIVisualEffectView *blurrEffectView;
    __weak IBOutlet NSLayoutConstraint *blurrEffectViewHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *overlayImageViewHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *popularUserImageViewHieghtConstriant;
    __weak IBOutlet NSLayoutConstraint *middleViewHeightConstraint;
    __weak IBOutlet UIButton *cancelOrDiscoverProfilesButton;
    __weak IBOutlet UIImageView *imageViewOverlayImageView;
    __weak IBOutlet UILabel *subHeaderLabel;
    
    DeletePhotoBlock _getBlock;
}

@end

@implementation DeletePhotoView

- (void)awakeFromNib{
 
    [[viewMiddle layer] setCornerRadius:5.0f];
    
    blurrEffectView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.6, 0.6);
    [UIView animateWithDuration:0.25 delay:0.0 usingSpringWithDamping:0.7f
          initialSpringVelocity:2.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         blurrEffectView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                     } completion:nil];


}

- (IBAction)btnClicked:(UIButton *)sender{
    
    if (sender.tag != 100){ // Cancel or DiscoverProfiles Button Clicked
            _getBlock();
        }
    [self removePopularFromSuperview];
}

- (void)setDeleteDataOnViewWithImage:(UIImage *)image withBlock:(DeletePhotoBlock)block{
    
    _getBlock = block;

    [subHeaderLabel setText:NSLocalizedString(@"You can only send a purchased crush to a popular user.", nil)];
    [subHeaderLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:14.0f]];
    [subHeaderLabel setTextColor:[UIColor colorWithRed:118.0f/255.0f
                                                 green:118.0f/255.0f
                                                  blue:118.0f/255.0f alpha:1.0f]];

    imgUserPopular.image = image;
    imgUserPopular.layer.borderWidth = 1.0;
    imgUserPopular.layer.borderColor = [UIColor colorWithRed:224.0/255.0 green:65.0/255.0 blue:72.0/255.0 alpha:1.0].CGColor;
    
    middleViewHeightConstraint.constant = 300;
    blurrEffectViewHeightConstraint.constant = 300;
    
}

- (void)removePopularFromSuperview{
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         blurrEffectView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.4, 0.4);
                     }
                     completion:^(BOOL finished){
                         [super removeFromSuperview];
                     }];
}


@end
