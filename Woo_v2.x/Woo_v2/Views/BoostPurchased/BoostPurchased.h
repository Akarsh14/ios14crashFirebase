//
//  BoostPurchased.h
//  Woo_v2
//
//  Created by Deepak Gupta on 1/8/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

typedef void (^BoostPurchasedGetBlock)(BOOL needToActivateBoost);

#import <UIKit/UIKit.h>

@interface BoostPurchased : UIView
{
    __weak IBOutlet UIView          *view_middleView;
    __weak IBOutlet UIImageView     *imgView_obj;
    __weak IBOutlet UIButton        *btn_ActivateBoost;
    
    __weak IBOutlet UILabel         *lbl_title;
    __weak IBOutlet UILabel         *lbl_desc;
}

- (IBAction)ButtonClicked:(UIButton *)sender;

- (void)moveToUserProfileViewControllerWithBlock:(BoostPurchasedGetBlock)block;

@end
