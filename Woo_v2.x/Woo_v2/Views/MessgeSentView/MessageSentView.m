//
//  MessageSentView.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 16/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "MessageSentView.h"

@implementation MessageSentView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    //check if memory is allocated to self
    if (self) {
        NSArray *viewArrayFromXib = [[NSBundle mainBundle] loadNibNamed:@"MessageSentView" owner:self options:nil];
        UIView *viewObj = [viewArrayFromXib objectAtIndex:0];
        viewObj.frame = self.bounds;
        [self addSubview:viewObj];
    }
    [self addSingleTapGestureOnView];
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)updateLabelOfRemainingMessages:(int )messagesRemaining{
    
    if (messagesRemaining < 1) {
        [remainingMessageCounterLabel setText:[NSString stringWithFormat:NSLocalizedString(@"CDI0014", nil)]];
    }else{
        [remainingMessageCounterLabel setText:[NSString stringWithFormat:NSLocalizedString(@"%d crushes left",nil) ,messagesRemaining]];
    }
}


-(void)presentViewDuration:(float )animationDuration onView:(UIView *)presentingView isCrushRemaining:(BOOL)isCrushRemaining{
    [self setAlpha:0];
    [presentingView addSubview:self];
    dismissAnimationTime = animationDuration;
    if (isCrushRemaining) {
        crushSendViewheightConstraint.constant = 230;
        getMoreCrushBtn.hidden = TRUE;
    }
    else{
        crushSendViewheightConstraint.constant = 290;
        getMoreCrushBtn.hidden = FALSE;
    }
    
    [UIView animateWithDuration:(animationDuration/3) delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self setAlpha:1.0f];
    } completion:^(BOOL finished) {
        if (isCrushRemaining) {
            [UIView animateWithDuration:(animationDuration/3) delay:(animationDuration/3) options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self setAlpha:0.0f];
            } completion:^(BOOL finished) {
                //            [[NSNotificationCenter defaultCenter] postNotificationName:kHeartAnimationEnded object:nil];
            }];
        }
        
    }];
}

-(void)setGetMoreCrushBtnTappedBlock:(GetMoreCrushBtnTapped)block{
    getmoreCrushBlockObj = block;
}
-(IBAction)getMoreCrushBtnTapped:(id)sender{
    [self dismissView:TRUE];
}
-(void)addSingleTapGestureOnView{
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
    [blankAreaView addGestureRecognizer:singleTapGesture];
}
-(void)handleSingleTap{
    [self dismissView:FALSE];
}
-(void)dismissView:(BOOL)isCrushBtnTapped{
    [UIView animateWithDuration:(dismissAnimationTime/3) delay:(dismissAnimationTime/3) options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self setAlpha:0.0f];
    } completion:^(BOOL finished) {
        getmoreCrushBlockObj(isCrushBtnTapped);
        //            [[NSNotificationCenter defaultCenter] postNotificationName:kHeartAnimationEnded object:nil];
    }];
}

@end
