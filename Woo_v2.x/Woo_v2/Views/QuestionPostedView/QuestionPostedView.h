//
//  QuestionPostedView.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 08/07/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestionPostedView : UIView{
    
    __weak IBOutlet UILabel *answersRemainingLAbel;
}

-(void)setRemainingQuestionsForUser:(int)remainingAnswers;

-(void)presentViewDuration:(float )animationDuration onView:(UIView *)presentingView;

@end
