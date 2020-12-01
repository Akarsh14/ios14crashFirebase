//
//  UnderlinedButton.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 17/08/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UnderlinedButton : UIButton{
    
}

+ (UnderlinedButton*) underlinedButton;

- (void)setTitle:(NSString *)title forState:(UIControlState)state;
- (void)setTitle:(NSString *)title forState:(UIControlState)state andMakeMeSelected:(BOOL)amISelected;
@end
