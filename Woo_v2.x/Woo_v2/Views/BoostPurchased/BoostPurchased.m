//
//  BoostPurchased.m
//  Woo_v2
//
//  Created by Deepak Gupta on 1/8/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "BoostPurchased.h"

@interface BoostPurchased (){
    BoostPurchasedGetBlock _getBlock;
}

@end

@implementation BoostPurchased
- (IBAction)tapPerformed:(id)sender {
    _getBlock(NO);
    [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib{
    [[btn_ActivateBoost layer] setCornerRadius:5.0];
    [[view_middleView layer] setCornerRadius:5.0];
    
    NSURL *croppedImageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(75),IMAGE_SIZE_FOR_POINTS(75),[APP_Utilities encodeFromPercentEscapeString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooProfilePicURL]]]];
    NSString *placeHolderImage = @"";
    if ([APP_Utilities isGenderMale:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserGender]]) {
        placeHolderImage = @"placeholder_male";
    }
    else{
        placeHolderImage = @"placeholder_female";
    }
    [imgView_obj sd_setImageWithURL:croppedImageURL placeholderImage:[UIImage imageNamed:placeHolderImage]];
    
    NSInteger boostAvialable = [BoostModel sharedInstance].availableBoost;
   // [lbl_title setText:[NSString stringWithFormat:@"You have %ld boosts",(long)boostAvialable]]; // Setting Title

    [lbl_title setText:[NSString stringWithFormat:NSLocalizedString(@"You have %ld boosts", @"You have %ld boosts"),(long)boostAvialable]]; // Setting Title

}

#pragma mark - Button Clicked
- (IBAction)ButtonClicked:(UIButton *)sender{
    
    if (sender.tag == 100) {  // Activate Boost
        _getBlock(YES);
        [APP_DELEGATE sendSwrveEventWithEvent:@"Boost.ActivateBoost" andScreen:@"Boost"];
        [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"Boost.ActivateBoost" forScreenName:@"Boost"];
        
    }else if (sender.tag == 200){
        _getBlock(NO);
        [APP_DELEGATE sendSwrveEventWithEvent:@"Boost.CompleteProfile" andScreen:@"Boost"];
        [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"Boost.CompleteProfile" forScreenName:@"Boost"];
    }
    [self removeFromSuperview];
}

- (void)moveToUserProfileViewControllerWithBlock:(BoostPurchasedGetBlock)block
{
    _getBlock = block;
}

@end
