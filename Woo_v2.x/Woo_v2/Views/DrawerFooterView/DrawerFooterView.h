//
//  DrawerFooterView.h
//  Woo_v2
//
//  Created by Suparno Bose on 05/01/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^FooterActionBlock)(void);

typedef enum DrawerFooterViewMode{
    ModeNone =0,
    ModeBoost,
    ModeCrush
}DrawerFooterViewMode;

@interface DrawerFooterView : UIView
{
    __weak IBOutlet UIView          *backgroundView;
    __weak IBOutlet UILabel         *titleLabel;
    __weak IBOutlet UILabel         *descriptionLabel;
    __weak IBOutlet UIImageView     *crushBoostImageView;
    
    FooterActionBlock               actionBlock;
    DrawerFooterViewMode            _mode;
}

-(void) setMode:(DrawerFooterViewMode) mode;

-(DrawerFooterViewMode) mode;

-(void) setTapActionBlock:(FooterActionBlock) block;

@end
