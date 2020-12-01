//
//  WooLoader.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 10/07/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "WooLoader.h"
#import "LoaderView.h"
#import "UIImage+GIF.h"
#import <FLAnimatedImage/FLAnimatedImage.h>

@implementation WooLoader

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    //check if memory is allocated to self
    if (self) {

    }
    return self;
}


-(void)removeView{
    animationStopped = TRUE;
    [self removeFromSuperview];
}


-(void)startAnimationOnView:(UIView *)viewRef WithBackGround:(BOOL) ifYes{
    
    if (!_shouldShowWooLoader) {
        [self createActivityIndicator];
        [self setAlpha:1.0f];
        [viewRef addSubview:self];
        return;
    }
    
    animationStopped = FALSE;
    BOOL isOtherLoaderAddedOnView = FALSE;
    
    for (UIView *loaderViewObj in [viewRef subviews]) {
        if ([loaderViewObj isKindOfClass:[LoaderView class]]) {
            isOtherLoaderAddedOnView = TRUE;
        }
    }
    if (isOtherLoaderAddedOnView) {
        return;
    }
    
    if (ifYes) {
        UIView *bgView = [[UIView alloc] initWithFrame:viewRef.frame];
        bgView.backgroundColor = [UIColor blackColor];
        bgView.alpha = 0.6;
        [self addSubview:bgView];
    }
    
    [self setAlpha:0];
    [self createLoader];
    [viewRef addSubview:self];
    
    [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self setAlpha:1.0f];
    } completion:^(BOOL finished) {
        //        do nothing here
    }];
    
    
}

-(void)startAnimatingOnWindowWithBackgrooundColor:(BOOL) ifYes{
    if (!_shouldShowWooLoader) {
        [self createActivityIndicator];
        [self setAlpha:1.0f];
        [APP_DELEGATE.window addSubview:self];
        return;
    }
    
    animationStopped = FALSE;
    BOOL isOtherLoaderAddedOnView = FALSE;
    
    for (UIView *loaderViewObj in [APP_DELEGATE.window subviews]) {
        if ([loaderViewObj isKindOfClass:[LoaderView class]]) {
            isOtherLoaderAddedOnView = TRUE;
        }
    }
    if (isOtherLoaderAddedOnView) {
        return;
    }
    
    if (ifYes) {
        UIView *bgView = [[UIView alloc] initWithFrame:APP_DELEGATE.window.frame];
        bgView.backgroundColor = [UIColor blackColor];
        bgView.alpha = 0.6;
        [self addSubview:bgView];
    }
    
    [self setAlpha:0];
    [self createLoader];
    [APP_DELEGATE.window addSubview:self];
    
    [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self setAlpha:1.0f];
    } completion:^(BOOL finished) {
        //        do nothing here
    }];
}

-(void) createActivityIndicator{

    
    if (!centreLayerView) {
        centreLayerView = [[UIView alloc] initWithFrame:CGRectZero];
        [centreLayerView setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f]];
        
        [self addSubview:centreLayerView];
        
        [centreLayerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(@60);
            make.height.mas_equalTo(@60);
            make.centerX.equalTo(self.mas_centerX);
            make.centerY.equalTo(self.mas_centerY);
        }];
    }
    
    [centreLayerView setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f]];
    centreLayerView.layer.cornerRadius = 5.0f;
    centreLayerView.layer.masksToBounds = YES;
    centreLayerView.clipsToBounds = YES;
    
    if (!spinner) {
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [centreLayerView addSubview:spinner];
    }
    
    
    [spinner mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(centreLayerView.mas_centerX);
        make.centerY.equalTo(centreLayerView.mas_centerY);
    }];
    if (![spinner isAnimating]) {
        [spinner startAnimating];
    }
    [self layoutSubviews];
    
}


-(void)createLoader{
    
    [centreLayerView setBackgroundColor:[UIColor clearColor]];
    
    if (!centreLayerView) {
        centreLayerView = [[UIView alloc] initWithFrame:CGRectZero];
        [centreLayerView setBackgroundColor:[UIColor clearColor]];
        
        [self addSubview:centreLayerView];
        
        [centreLayerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(@60);
            make.height.mas_equalTo(@40);
            make.centerX.equalTo(self.mas_centerX);
            make.centerY.equalTo(self.mas_centerY);
        }];
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"loader_new_3x" ofType:@"gif"];
    NSURL *url = [NSURL fileURLWithPath:path];

    FLAnimatedImageView *loaderImageView = [[FLAnimatedImageView alloc] init];
    [loaderImageView sd_setImageWithURL:url];
    [centreLayerView addSubview:loaderImageView];
    
    
    
    [loaderImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(@60);
        make.height.mas_equalTo(@40);
        make.centerX.equalTo(centreLayerView.mas_centerX);
        make.centerY.equalTo(centreLayerView.mas_centerY);
        
    }];
    
    return;
    //// Adding Layer for creating gray logo
    UIBezierPath* bezierPathForGrayLogo = UIBezierPath.bezierPath;
    [bezierPathForGrayLogo moveToPoint: CGPointMake(13, 19)];
    [bezierPathForGrayLogo addLineToPoint: CGPointMake(23, 19)];
    [bezierPathForGrayLogo addLineToPoint: CGPointMake(33, 36)];
    [bezierPathForGrayLogo addLineToPoint: CGPointMake(42, 19)];
    [bezierPathForGrayLogo addLineToPoint: CGPointMake(33, 19)];
    [bezierPathForGrayLogo addLineToPoint: CGPointMake(23, 36)];
    [bezierPathForGrayLogo addLineToPoint: CGPointMake(13, 19)];
    [bezierPathForGrayLogo closePath];
    
    lineForLogo = [CAShapeLayer layer];
    lineForLogo.path=bezierPathForGrayLogo.CGPath;
    lineForLogo.fillColor = [UIColor clearColor].CGColor;
    lineForLogo.strokeColor = [UIColor whiteColor].CGColor;
    lineForLogo.lineWidth = 3.0;
    lineForLogo.lineCap = kCALineCapRound;
    lineForLogo.lineJoin = kCALineJoinRound;
    
    
    
    bezierPathForColors = UIBezierPath.bezierPath;
    [bezierPathForColors moveToPoint:CGPointMake(28, 56)];
    [bezierPathForColors addLineToPoint:CGPointMake(28, 0)];
    
    [self performFirstAnimation];
    
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (animationStopped) {
        return;
    }
    if ([[anim valueForKey:@"id"] isEqual:@"firstAnimation"]) {
        
        [self performSecondAnimation];
        [layerForGreenColor removeFromSuperlayer];
        
    }else if ([[anim valueForKey:@"id"] isEqual:@"secondAnimation"]) {
        
        [self performThirdAnimation];
        [layerForPurpleAnimation removeFromSuperlayer];
        
        
    }else if ([[anim valueForKey:@"id"] isEqual:@"thirdAnimation"]) {
        
        [self performFirstAnimation];
        [layerForCyanAnimation removeFromSuperlayer];
        
        
    }
    
}


-(void)performFirstAnimation{
    if (animationStopped) {
        return;
    }
    //this will be purple
    layerForPurpleAnimation = [CAShapeLayer layer];
    layerForPurpleAnimation.path = bezierPathForColors.CGPath;
    layerForPurpleAnimation.fillColor = kIntroPurpleColor.CGColor;
    layerForPurpleAnimation.strokeColor = kIntroPurpleColor.CGColor;
    layerForPurpleAnimation.lineWidth = 70.0;
    
    [[centreLayerView layer] addSublayer:layerForPurpleAnimation];
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 0.5f;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    pathAnimation.repeatCount = 1;
    pathAnimation.autoreverses = NO;
    pathAnimation.delegate = self;
    pathAnimation.removedOnCompletion=false;
    [pathAnimation setValue:@"firstAnimation" forKey:@"id"];
    
    [layerForPurpleAnimation addAnimation:pathAnimation forKey:@"strokeEnd"];
    
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:)];
    [[centreLayerView layer] addSublayer:lineForLogo];
}

-(void)performSecondAnimation{
    if (animationStopped) {
        return;
    }
    // this will be cyan
    layerForCyanAnimation = [CAShapeLayer layer];
    layerForCyanAnimation.path = bezierPathForColors.CGPath;
    layerForCyanAnimation.fillColor = kIntroCyanColor.CGColor;
    layerForCyanAnimation.strokeColor = kIntroCyanColor.CGColor;
    layerForCyanAnimation.lineWidth = 70.0;
    
    [[centreLayerView layer] addSublayer:layerForCyanAnimation];
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 0.5f;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    pathAnimation.repeatCount = 1;
    pathAnimation.autoreverses = NO;
    pathAnimation.delegate = self;
    pathAnimation.removedOnCompletion=false;
    [pathAnimation setValue:@"secondAnimation" forKey:@"id"];
    
    [layerForCyanAnimation addAnimation:pathAnimation forKey:@"strokeEnd"];
    
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:)];
    [[centreLayerView layer] addSublayer:lineForLogo];
}

-(void)performThirdAnimation{
    if (animationStopped) {
        return;
    }
    // this will be green
    layerForGreenColor = [CAShapeLayer layer];
    layerForGreenColor.path = bezierPathForColors.CGPath;
    layerForGreenColor.fillColor = kIntroGreenColor.CGColor;
    layerForGreenColor.strokeColor = kIntroGreenColor.CGColor;
    layerForGreenColor.lineWidth = 70.0;
    
    [[centreLayerView layer] addSublayer:layerForGreenColor];
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 0.5f;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    pathAnimation.repeatCount = 1;
    pathAnimation.autoreverses = NO;
    pathAnimation.delegate = self;
    pathAnimation.removedOnCompletion=false;
    [pathAnimation setValue:@"thirdAnimation" forKey:@"id"];
    
    [layerForGreenColor addAnimation:pathAnimation forKey:@"strokeEnd"];
    
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:)];
    [[centreLayerView layer] addSublayer:lineForLogo];
}


-(void)stopAnimation{
    [centreLayerView.layer removeAllAnimations];
    [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        [self setAlpha:0.0f];
        
    } completion:^(BOOL finished) {
        animationStopped = TRUE;
        [self removeFromSuperview];
    }];
}


-(void)customLoadingText:(NSString *)customText{
    if (!customLabel) {
        customLabel = [[UILabel alloc]init];
    }
    [customLabel setBackgroundColor:[UIColor clearColor]];
    [customLabel setText:customText];
    customLabel.numberOfLines = 0;
    [customLabel setFrame:CGRectMake(0, (self.frame.size.height) - 50 , SCREEN_WIDTH, 50)];
    [customLabel setTextAlignment:NSTextAlignmentCenter];
    [customLabel setTextColor:[APP_Utilities getUIColorObjectFromHexString:@"898989" alpha:1.0]];
    [customLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:18.0f]];
    [self addSubview:customLabel];
    
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
