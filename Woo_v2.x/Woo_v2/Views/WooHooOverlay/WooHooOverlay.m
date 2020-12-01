//
//  WooHooOverlay.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 09/07/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "WooHooOverlay.h"

@implementation WooHooOverlay

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    //check if memory is allocated to self
    if (self) {
        //getting array of views from the xib
        NSArray *viewArrayFromXib = [[NSBundle mainBundle] loadNibNamed:@"WooHooOverlay" owner:self options:nil];
        UIView *viewObj = [viewArrayFromXib firstObject];
        viewObj.frame = self.bounds;
        [self addSubview:viewObj];
    }
    [self createBlurredBackground];
    return self;
}


-(void)createBlurredBackground{
//    return;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
        
        blurEffectView.frame = self.bounds;
        [self addSubview:blurEffectView];

        [self bringSubviewToFront:nameLabel];
        [self bringSubviewToFront:centreView];
        [self bringSubviewToFront:introTextLAbel];
        [self bringSubviewToFront:crossButton];
        [self bringSubviewToFront:wooHooLabel];
        [self sendSubviewToBack:blurEffectView];
    }else{
        self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)fixPlacementOfCrossButtonForScreenWithoutNavBar{
    crossTopLayoutConstraint.constant = 86.0f;
}

-(void)presentViewWithImageURL:(NSURL *)imageURL timerForConnection:(int )timer nameOfUser:(NSString *)nameOfUser andTeaserLine:(NSString *)teaserText forPresentingView:(UIView *)viweRef{

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        crossTopLayoutConstraint.constant = 86.0f;
    }
    
    
    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"MatchOverlay" forScreenName:@"MatchOverlay"];
    [APP_DELEGATE sendSwrveEventWithEvent:@"MatchOverlay" andScreen:@"MatchOverlay"];
    timeToDisplay = timer;
    
    stepper = 1.0f/(timer * 10);
    
    [self setAlpha:0];
    [viweRef addSubview:self];
    
    NSURL *ImageCroppedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(285),IMAGE_SIZE_FOR_POINTS(207),[APP_Utilities encodeFromPercentEscapeString:[imageURL absoluteString]]]];
    
    [userImageView sd_setImageWithURL:ImageCroppedUrl placeholderImage:[UIImage imageNamed:@"placeholder_male"]];
    
    [nameLabel setText:[NSString stringWithFormat:@"%@ %@",nameOfUser,NSLocalizedString(@"likes you back!", nil)]];
    [introTextLAbel setText:teaserText];
    
    [self createCircualarProgressView];
    
    [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        [self setAlpha:1.0f];
        
    } completion:^(BOOL finished) {
        //        do nothing here
    }];
    
    [self startAnimation];
    
}

-(void)updateLoader{
    
    timeElapsed = timeElapsed + 0.10;
    
    [progressView setProgress:(progressView.progress+stepper) animated:YES];
    
    float remainingTime =ceilf(timeToDisplay-timeElapsed);
    if (remainingTime <= 0) {
        remainingTime =0;
    }
    [progressView.progressLabel setText:[NSString stringWithFormat:@"%1.0f",remainingTime]];
    
    if ((progressView.progress + stepper) >= 1.0f) {
        [self stopAnimation];
        
    }
}

- (void)startAnimation
{
    
    loaderTimer = [NSTimer scheduledTimerWithTimeInterval:0.10
                                             target:self
                                           selector:@selector(updateLoader)
                                           userInfo:nil
                                            repeats:YES];

}

-(void)stopAnimation{
    
    [loaderTimer invalidate];
    
    if (!crossButtonTapped) {
        if ([_delegate respondsToSelector:_selectorForOverlayRemoved]) {
            [_delegate performSelector:_selectorForOverlayRemoved withObject:_matchId];
        }
    }
    [self removeFromSuperview];

}


-(void)createCircualarProgressView{
    progressView = [[DALabeledCircularProgressView alloc] initWithFrame:CGRectMake(118.0f, 280, 50.0f, 50.0f)];
    progressView.roundedCorners = YES;
    progressView.trackTintColor = kVeryLightGrayColor;
    progressView.progressTintColor = kHeaderTextRedColor;
    [centreView addSubview:progressView];
}

- (IBAction)crossButtonTapped:(id)sender {
//    [self stopAnimation];
    crossButtonTapped = TRUE;
    [loaderTimer invalidate];
    [self removeFromSuperview];
    if ([_delegate respondsToSelector:_selectorForCrossButtonClicked])
        [_delegate performSelector:_selectorForCrossButtonClicked];
}
@end
