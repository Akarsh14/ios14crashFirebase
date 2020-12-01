//
//  WooToast.h
//  Woo_v2
//
//  Created by Suparno Bose on 20/04/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kWooToastDurationLong 3.5f
#define kWooToastDurationShort 2

@interface WooToast : UIControl

@property(nullable, nonatomic) NSString *text;
@property(nullable, nonatomic) UIColor *textColor;
@property(nonatomic) NSTimeInterval duration;
@property(nonatomic, readonly) BOOL isShowing;

+ (nonnull WooToast *)sharedInstance;
- (void)showWithText:(nonnull NSString *)text duration:(NSTimeInterval)duration;
- (void)dismiss;
@end
