//
//  ActivityIndicatorWithTextAndTimer.h
//  Woo
//
//  Created by Umesh Mishra on 29/10/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityIndicatorWithTextAndTimer : UIView{
    
    __weak IBOutlet UILabel *waitingTextLabelObj;
    __weak IBOutlet UILabel *timerLabelObj;
    __weak IBOutlet UIActivityIndicatorView *activityIndicatorObj;
    
    NSTimer *timer;
    
    int currMinute;
    int currSeconds;
}

-(void)StartIndicatorWithStartTime:(int)timeInSeconds;
-(void)showWaitingTextWithText:(NSString *)waitingText;
-(void)startIndicator;
-(void)hideActivityIndicator;

-(void)invalidateTimer;

@end
