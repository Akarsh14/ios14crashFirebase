//
//  FANView.m
//  Woo_v2
//
//  Created by Umesh Mishra on 12/10/15.
//  Copyright © 2015 Vaibhav Gautam. All rights reserved.
//

#import "FANView.h"

@implementation FANView

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
        
        NSArray *arrayObj = [[NSBundle mainBundle] loadNibNamed:@"FANView" owner:self options:nil];
        UIView *viewObj = [arrayObj objectAtIndex:0];
        viewObj.frame = frame;
        [self addSubview:viewObj];
    }
    return self;
}


-(IBAction)installNowButtonTapped:(id)sender{
    NSLog(@"installNowButtonTapped");
    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"FanView" forScreenName:@"FanTap"];
    [APP_DELEGATE sendSwrveEventWithEvent:@"FAN.FanTap" andScreen:@"FAN"];
    
}
//-(IBAction)adChoiceButtonTapped:(id)sender{
//    
//    NSLog(@"adChoiceButtonTapped");
//    
//}
-(void)setAdDataOnView:(FBNativeAd *)nativeAdObj forViewController:(UIViewController *)viewControllerObj{
    
    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"FanView" forScreenName:@"FanView"];
    [APP_DELEGATE sendSwrveEventWithEvent:@"FAN.FanView" andScreen:@"FAN"];

    facebookNativeAdvObj = nativeAdObj;
    adTitleLbl.text = ([nativeAdObj.title length]>0)?nativeAdObj.title:@"";
    adDescriptionLbl.text = ([nativeAdObj.body length]>0)?nativeAdObj.body:@"";
    
    //Code added to load image, used code from fb sample code. 
//    [nativeAdObj.icon loadImageAsyncWithBlock:^(UIImage *image) {
//        logoImageView.image = image;
//    }];
    [logoImageView sd_setImageWithURL:nativeAdObj.icon.url];
    
    [fbMediaViewObj setNativeAd:nativeAdObj];
    [fbMediaViewObj setAutoplayEnabled:TRUE];
    [installNowBtn setTitle:nativeAdObj.callToAction forState:UIControlStateNormal];
    
    [nativeAdObj registerViewForInteraction:self withViewController:viewControllerObj withClickableViews:[NSArray arrayWithObject:installNowBtn]];
    
    FBAdChoicesView *fbAdChoiceViewObj = [[FBAdChoicesView alloc] initWithNativeAd:nativeAdObj expandable:TRUE];
    [adChoiceContainerView addSubview:fbAdChoiceViewObj];
    [fbAdChoiceViewObj updateFrameFromSuperview];
    fbAdChoiceViewObj.center = CGPointMake(70, 13);
    
}

-(void)dealloc{
    [facebookNativeAdvObj unregisterView];
    [[NSNotificationCenter defaultCenter] postNotificationName:kFANViewhasBeenDeallocated object:nil];
}

@end
