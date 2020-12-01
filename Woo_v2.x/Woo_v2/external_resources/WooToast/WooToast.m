//
//  WooToast.m
//  Woo_v2
//
//  Created by Suparno Bose on 20/04/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "WooToast.h"


#define kWooAnimationDuration .2f
#define kWooNormalPadding 14
#define kTextAndViewHorizontalPadding 14
#define kWooLargePadding 24
#define kWooCornerRadius 24
#define kToastDistanceFromScreenCornors 24
#define kWooMaxWidth 568

@implementation WooToast {
    UIView      *rootView;
    UILabel     *textLabel;
    BOOL        isAnimating;
    NSTimer     *toastTimer;
    CGFloat     cornerradius;
    UIVisualEffectView *blurEffectView;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.text = @"";
        [self createContent];
    }
    return self;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedInstance];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

#pragma mark- Exposed functions
+ (WooToast *)sharedInstance {
    static WooToast *sharedInstance = nil;
    if (!sharedInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedInstance = [[super allocWithZone:NULL] init];
            // custom initialisation
        });
    }
    return sharedInstance;
}

- (void)showWithText:(NSString *)text duration:(NSTimeInterval)duration{
    if (![self.text isEqualToString:text]) {
        self.text = text;
        self.duration = duration;
        _isShowing = FALSE;
        [toastTimer invalidate];
        toastTimer = nil;
        [self doShow];
    }
}

#pragma mark setter
- (void)setText:(NSString *)text {
    _text = text;
    textLabel.text = text;
}

-(void)setToastCornerRadius:(CGFloat)radius{
    cornerradius = radius;
    self.layer.cornerRadius = cornerradius;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    textLabel.textColor = textColor;
}
#pragma mark- Private Methods
- (void)createContent {
    _duration = kMDToastDurationShort;
    cornerradius = kWooCornerRadius;
    self.clipsToBounds = YES;
    
    textLabel = [[UILabel alloc] init];
    textLabel.font = [UIFont systemFontOfSize:14.0];
    textLabel.numberOfLines = 0;
    textLabel.translatesAutoresizingMaskIntoConstraints = false;
    textLabel.textAlignment = NSTextAlignmentCenter;
    [textLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow
                                               forAxis:UILayoutConstraintAxisHorizontal];

    self.textColor = [UIColor darkGrayColor];
    
    self.translatesAutoresizingMaskIntoConstraints = false;
    
    self.layer.cornerRadius = cornerradius;
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    blurEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
}

- (void)arrangeContent {
    [self addSubview:textLabel];
    
    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).with.offset(kWooNormalPadding);
        make.bottom.equalTo(self).with.offset(-kWooNormalPadding);
        make.leading.equalTo(self).with.offset(kWooNormalPadding);
        make.trailing.equalTo(self).with.offset(-kWooNormalPadding);
    }];
}

- (void)addSelfToScreen {
    rootView = [self getMainView];
    
    [rootView addSubview:self];

    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(rootView.mas_leading).with.offset(kWooLargePadding);
        make.trailing.equalTo(rootView.mas_trailing).with.offset(-kWooLargePadding);
        make.bottom.equalTo(rootView.mas_bottom).with.offset(-kWooLargePadding);
        make.centerX.equalTo(rootView.mas_centerX);
        make.height.equalTo(textLabel.mas_height).with.offset(2*kWooNormalPadding);
    }];
}

- (void)doShow {
    self.backgroundColor = [UIColor colorWithRed:190.0/255.0 green:190.0/255.0 blue:190.0/255.0 alpha:0.35];
    if (_isShowing)
        return;
    
    
    _isShowing = true;
    [self arrangeContent];
    [self addSelfToScreen];
    [self addBlurEffectView];
    [rootView layoutIfNeeded];
    [UIView animateWithDuration:kWooAnimationDuration
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             isAnimating = false;
                             toastTimer = [NSTimer scheduledTimerWithTimeInterval:_duration target:self
                                                                         selector:@selector(dismiss) userInfo:nil repeats:NO];
                         }
                     }];
}

- (void)dismiss {
    if (!_isShowing || isAnimating)
        return;
    isAnimating = true;
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(dismiss)
                                               object:nil];
    [rootView layoutIfNeeded];
    [UIView animateWithDuration:kWooAnimationDuration * 2
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             isAnimating = false;
                             [self removeBlurEffectView];
                             [self removeFromSuperview];
                             [textLabel removeFromSuperview];
                             _isShowing = false;
                             self.text = @"";
                         }
                     }];
}

-(void)addBlurEffectView{
    [self addSubview:blurEffectView];
    
    [blurEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.bottom.equalTo(self);
        make.leading.equalTo(self);
        make.trailing.equalTo(self);
    }];
    
    [self sendSubviewToBack:blurEffectView];
}

-(void)removeBlurEffectView{
    [blurEffectView removeFromSuperview];
}

#pragma mark - Utility Function
- (UIView *)getMainView {
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        if (!window)
            window = [[UIApplication sharedApplication].windows objectAtIndex:0];
        return [window subviews].lastObject;
    } else {
        UIWindow *window =[[UIApplication sharedApplication] keyWindow];
        if (window == nil)
            window = [[[UIApplication sharedApplication] delegate] window];//#14
        return window;
    }
}

@end
