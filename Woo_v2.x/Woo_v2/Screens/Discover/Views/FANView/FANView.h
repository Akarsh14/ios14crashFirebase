//
//  FANView.h
//  Woo_v2
//
//  Created by Umesh Mishra on 12/10/15.
//  Copyright © 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

#import <FBAudienceNetwork/FBAudienceNetwork.h>

@interface FANView : UIView{
    
    __weak IBOutlet FBMediaView *fbMediaViewObj;
    __weak IBOutlet UIImageView *logoImageView;
    __weak IBOutlet UILabel *sponseredLbl;
    __weak IBOutlet UIButton *adChoiceBtn;
    __weak IBOutlet UILabel *adTitleLbl;
    __weak IBOutlet UILabel *adDescriptionLbl;
    __weak IBOutlet UIButton *installNowBtn;
    
    __weak IBOutlet UIView *adChoiceContainerView;
    
    FBNativeAd *facebookNativeAdvObj;
    
}

@property(nonatomic, assign)BOOL hadUserSeenMe;


-(IBAction)installNowButtonTapped:(id)sender;
//-(IBAction)adChoiceButtonTapped:(id)sender;
-(void)setAdDataOnView:(FBNativeAd *)nativeAdObj forViewController:(UIViewController *)viewControllerObj;
@end
