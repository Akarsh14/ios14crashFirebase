//
//  PopularUserView.m
//  Woo_v2
//
//  Created by Deepak Gupta on 1/14/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "PopularUserView.h"
#import "SDWebImageDownloader.h"
#import "LoginModel.h"

@interface PopularUserView ()
{
    __weak IBOutlet UIVisualEffectView *blurrEffectView;
    __weak IBOutlet NSLayoutConstraint *blurrEffectViewHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *overlayImageViewHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *popularUserImageViewHieghtConstriant;
    __weak IBOutlet NSLayoutConstraint *middleViewHeightConstraint;
    __weak IBOutlet UIButton *cancelOrDiscoverProfilesButton;
    __weak IBOutlet UIImageView *imageViewOverlayImageView;
    __weak IBOutlet UILabel *subHeaderLabel;
    BOOL isOutOfCrushesTypeView;
    GetPopularBlock _getBlock;
}

@end

@implementation PopularUserView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib{
 
    [[viewMiddle layer] setCornerRadius:5.0f];
    [[imgUserPopular layer] setCornerRadius:55];
    
    blurrEffectView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.4, 0.4);
    [UIView animateWithDuration:0.25 delay:0.0 usingSpringWithDamping:0.7f
          initialSpringVelocity:2.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         blurrEffectView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                     } completion:nil];


}

- (IBAction)btnClicked:(UIButton *)sender{
    
    if (sender.tag == 100){ // Cancel or DiscoverProfiles Button Clicked
        _getBlock(0,isOutOfCrushesTypeView);
        }else{
        _getBlock(1,isOutOfCrushesTypeView);
        }
    [self removePopularFromSuperview];
}

- (void)setPopularDataOnViewWithImage:(NSString *)imageName withName:(NSString *)name andType:(BOOL)outOfCrushesTypeView withGender:(NSString *)gender withBlock:(GetPopularBlock)block{
    
    _getBlock = block;
    
    isOutOfCrushesTypeView = outOfCrushesTypeView;
    
    if (isOutOfCrushesTypeView == YES) {
        [lblUserName setText:[NSString stringWithFormat:@"%@",NSLocalizedString(@"Crush - Chat before Match", nil)]];
      //  [lblUserName setFont:[UIFont fontWithName:@"Heavenetica5SH" size:18.0f]];
        [lblUserName setTextColor:[UIColor blackColor]];
        
//        [subHeaderLabel setText:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Don't lose the opportunity to send a crush to", nil),name]];

        [subHeaderLabel setText:[NSString stringWithFormat:NSLocalizedString(@"Send a Crush to %@ with a special customised message and get featured in Crush received section.", nil),name]];

        
        // [subHeaderLabel setFont:[UIFont fontWithName:@"Heavenetica5SH" size:16.0f]];
        [subHeaderLabel setTextColor:[UIColor colorWithRed:118.0f/255.0f green:118.0f/255.0f blue:118.0f/255.0f alpha:1.0f]];
        
        [imageViewOverlayImageView setImage:nil];
        [imgUserPopular setImage:nil];
        popularUserImageViewHieghtConstriant.constant = 0;
        overlayImageViewHeightConstraint.constant = 0;
        middleViewHeightConstraint.constant = 165;
        blurrEffectViewHeightConstraint.constant = 165;
        
        //[cancelOrDiscoverProfilesButton setTitle:NSLocalizedString(@"Discover Profiles", nil) forState:UIControlStateNormal];
    }
    else{
        [APP_DELEGATE sendSwrveEventWithEvent:@"Discover.Popular" andScreen:@"Discover.Popular"];

//        [lblUserName setText:[NSString stringWithFormat:@"%@ %@",name,NSLocalizedString(@"is a popular user!", @"Popular user text")]];
        [lblUserName setText:[NSString stringWithFormat:@"%@",NSLocalizedString(@"Crush - Chat before Match", nil)]];

       // [lblUserName setFont:[UIFont fontWithName:@"Heavenetica5SH" size:18.0f]];
        [lblUserName setTextColor:[UIColor blackColor]];
        
//        [subHeaderLabel setText:NSLocalizedString(@"You can only send a purchased crush to a popular user.", nil)];

        
        NSString *strGender = nil;
        
        if ([gender isEqualToString:@"FEMALE"]) {
            strGender = NSLocalizedString(@"her", @"her");
        }else{
            strGender = NSLocalizedString(@"his", @"his");
        }
        
//        [subHeaderLabel setText:[NSString stringWithFormat:NSLocalizedString(@"%@ is a hot user. Send a crush to %@ with a special message.", @"Hot user"),name , strGender]];

        
        [subHeaderLabel setText:[NSString stringWithFormat:NSLocalizedString(@"Send a crush to %@ and let %@ know your liking with a special message.", @"Hot user"),name , strGender]];

        
        
       // [subHeaderLabel setFont:[UIFont fontWithName:@"Heavenetica5SH" size:16.0f]];
        [subHeaderLabel setTextColor:[UIColor colorWithRed:118.0f/255.0f green:118.0f/255.0f blue:118.0f/255.0f alpha:1.0f]];
        
       // [imageViewOverlayImageView setImage:[UIImage imageNamed:@"ic_crush_overlay_purchase"]];
        
        //[cancelOrDiscoverProfilesButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
        
        CGFloat imageWidth = [[UIScreen mainScreen] bounds].size.width;
        CGFloat imageHeight = ([[UIScreen mainScreen] bounds].size.width *0.8);
        
        NSURL *croppedImageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(imageWidth),IMAGE_SIZE_FOR_POINTS(imageHeight),[APP_Utilities encodeFromPercentEscapeString:imageName]]];
        
        NSString *placeHolderImageStr = [APP_Utilities isGenderMale:[[NSUserDefaults standardUserDefaults] objectForKey:kGenderPreference]] ? @"placeholder_male" : @"placeholder_female";
        [imgUserPopular sd_setImageWithURL:croppedImageURL placeholderImage:[UIImage imageNamed:placeHolderImageStr]];
        middleViewHeightConstraint.constant = 300;
        blurrEffectViewHeightConstraint.constant = 300;

    }

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
