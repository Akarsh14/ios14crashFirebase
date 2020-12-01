//
//  MessageSentView.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 16/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^GetMoreCrushBtnTapped)(BOOL isGetCrushButtonTapped);

@interface MessageSentView : UIView{
    
    __weak IBOutlet UILabel *remainingMessageCounterLabel;
    __weak IBOutlet UIButton *getMoreCrushBtn;
    GetMoreCrushBtnTapped getmoreCrushBlockObj;
    __weak IBOutlet NSLayoutConstraint *crushSendViewheightConstraint;
    __weak IBOutlet UIView *blankAreaView;
    float dismissAnimationTime;
}

-(void)updateLabelOfRemainingMessages:(int )messagesRemaining;
-(void)presentViewDuration:(float )animationDuration onView:(UIView *)presentingView isCrushRemaining:(BOOL)isCrushRemaining;

-(void)setGetMoreCrushBtnTappedBlock:(GetMoreCrushBtnTapped)block;

-(IBAction)getMoreCrushBtnTapped:(id)sender;

@end
