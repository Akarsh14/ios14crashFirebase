//
//  ActivityIndicatorWithTextAndTimer.m
//  Woo
//
//  Created by Umesh Mishra on 29/10/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "ActivityIndicatorWithTextAndTimer.h"

@implementation ActivityIndicatorWithTextAndTimer

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        NSArray *nibArray = [[NSBundle mainBundle]loadNibNamed:@"ActivityIndicatorWithTextAndTimer" owner:self options:nil];
        UIView *viewObj = [nibArray lastObject];
       
        [self addSubview:viewObj];
        viewObj.layer.cornerRadius = 10.0;
        viewObj.layer.masksToBounds = YES;
        timerLabelObj.hidden = TRUE;
        timerLabelObj.font = kVerifyingMessageTextFont;
        timerLabelObj.textColor = kVerifyingMessageTextColor;
        waitingTextLabelObj.hidden = TRUE;
        waitingTextLabelObj.font = kVerifyingMessageTextFont;
        waitingTextLabelObj.textColor = kVerifyingMessageTextColor;
        [self addObserversForManagingTimerInBackground];
    }
    return self;
}


-(void)addObserversForManagingTimerInBackground{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveTimerState) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeTimer) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)StartIndicatorWithStartTime:(int)timeInSeconds{
    
    timerLabelObj.hidden = FALSE;
    
    currMinute = (timeInSeconds)/60;
    
    currSeconds=(timeInSeconds)%60;
    
    [timerLabelObj setText:[NSString stringWithFormat:@"%d%@%02d",currMinute,@":",currSeconds]];
    
    [self start];
}

-(void)showWaitingTextWithText:(NSString *)waitingText{
    waitingTextLabelObj.hidden = FALSE;
    if ([waitingText length]>0) {
        waitingTextLabelObj.text = waitingText;
    }
}

-(void)startIndicator{
    if (!activityIndicatorObj.isAnimating) {
        [activityIndicatorObj startAnimating];
    }
    activityIndicatorObj.hidden = FALSE;
    self.layer.cornerRadius = 10.0;
    self.layer.masksToBounds = YES;
}

-(void)hideActivityIndicator{
    if (activityIndicatorObj.isAnimating) {
        [activityIndicatorObj stopAnimating];
    }
    [self removeFromSuperview];
}


-(void)invalidateTimer{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }

}

-(void)start
{
    if (!timer) {
        timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
    }
}



-(void)timerFired
{

    if((currMinute>0 || currSeconds>=0) && currMinute>=0)

    {
        if(currSeconds==0)
        {
            currMinute-=1;
            currSeconds=59;
        }
        else if(currSeconds>0)
        {
            currSeconds-=1;
        }
        if(currMinute>-1)
            [timerLabelObj setText:[NSString stringWithFormat:@"%d%@%02d",currMinute,@":",currSeconds]];
        
        [activityIndicatorObj setHidden:FALSE];
        
    }
    else
    {
        
        
        [timer invalidate];
        timer = nil;
        //Timer over please start another process
        if (!activityIndicatorObj.hidden) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kFoneVerifyCallTimerExpires object:nil];
        }
        
        [activityIndicatorObj stopAnimating];
        
        [activityIndicatorObj setHidden:TRUE];
        
        
        
        
    }
}


-(void)saveTimerState{
    NSLog(@"-----");
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble: [[NSDate date] timeIntervalSince1970]] forKey:@"TimeStampAtBackground"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}


-(void)resumeTimer{
    NSNumber *backgroundTimestamp = [[NSUserDefaults standardUserDefaults] objectForKey:@"TimeStampAtBackground"];
    NSNumber *currentTimestamp = [NSNumber numberWithDouble: [[NSDate date] timeIntervalSince1970]];
    int elapsedTime;
    elapsedTime = [currentTimestamp intValue] - [backgroundTimestamp intValue];
    
    NSLog(@"++++\n\n\n\n ++++ %d",elapsedTime);
    
    int seconds = elapsedTime % 60;
    int minutes = (elapsedTime / 60) % 60;
//    int hours = elapsedTime / 3600;
    
    currMinute = currMinute - minutes;
    currSeconds = currSeconds - seconds;
    if (currSeconds < 0) {
        currSeconds = 0;
    }
    if (currMinute < 0) {
        currMinute = 0;
    }
    
}

-(void)dealloc{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
