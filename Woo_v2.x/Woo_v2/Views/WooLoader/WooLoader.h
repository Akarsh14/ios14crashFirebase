//
//  WooLoader.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 10/07/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WooLoader : UIView{
    
    NSMutableArray *animationFrames;
    
    UIView *centreLayerView;
    UILabel *customLabel;
    CAShapeLayer *lineForRedLogo;
    UIBezierPath *bezierPathForColors;
    CAShapeLayer *lineForLogo;
    BOOL animationStopped;
    
    
    // layers and shapes
    CAShapeLayer *layerForPurpleAnimation;
    CAShapeLayer *layerForCyanAnimation;
    CAShapeLayer *layerForGreenColor;
    
    UIActivityIndicatorView *spinner;
}

//@property (nonatomic)__weak IBOutlet UILabel     *loaderText;
@property (nonatomic, assign) BOOL shouldShowWooLoader;
-(void)startAnimationOnView:(UIView *)viewRef WithBackGround:(BOOL) ifYes;
-(void)stopAnimation;
-(void)startAnimatingOnWindowWithBackgrooundColor:(BOOL) ifYes;


-(void)customLoadingText:(NSString *)customText;
@end
