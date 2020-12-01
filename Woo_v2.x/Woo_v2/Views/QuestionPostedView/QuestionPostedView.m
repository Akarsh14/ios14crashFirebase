//
//  QuestionPostedView.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 08/07/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "QuestionPostedView.h"

@implementation QuestionPostedView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    //check if memory is allocated to self
    if (self) {
        //getting array of views from the xib
        NSArray *viewArrayFromXib = [[NSBundle mainBundle] loadNibNamed:@"QuestionPostedView" owner:self options:nil];
        UIView *viewObj = [viewArrayFromXib firstObject];
        viewObj.frame = self.bounds;
        [self addSubview:viewObj];
    }
    return self;
}

-(void)setRemainingQuestionsForUser:(int)remainingAnswers{
    [answersRemainingLAbel setText:[NSString stringWithFormat:@"%d %@",remainingAnswers,NSLocalizedString(@"question left", nil)]];
}

-(void)presentViewDuration:(float )animationDuration onView:(UIView *)presentingView{

    [self setAlpha:0];
    [presentingView addSubview:self];
    
    [UIView animateWithDuration:(animationDuration/3) delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self setAlpha:1.0f];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:(animationDuration/3) delay:(animationDuration/3) options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kHeartAnimationEnded object:nil];
        }];
    }];
}


@end
