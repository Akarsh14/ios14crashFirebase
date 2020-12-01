//
//  TopLeftNavItemView.h
//  Woo_v2
//
//  Created by Suparno Bose on 16/01/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopRightNavItemView : UIView
{
    BOOL isDrawerOpen;
    __weak IBOutlet UILabel *boostedLabel;
    __weak IBOutlet UIButton *boostedButton;
    
}
@property (weak, nonatomic) IBOutlet UIButton *matchboxButton;
@property (weak, nonatomic) IBOutlet UILabel *unreadMatchLabel;

+(TopRightNavItemView* _Nonnull) createFromNIBWithOwner:(id _Nonnull)owner
                                               AndFrame:(CGRect)frame;

- (void)UpdateViewIfItsBoosted;
@end
