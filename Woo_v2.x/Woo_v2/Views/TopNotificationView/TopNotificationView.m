//
//  TopNotificationView.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 27/07/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "TopNotificationView.h"

@implementation TopNotificationView


-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.windowLevel = UIWindowLevelStatusBar+1.0f;
    
    //check if memory is allocated to self
    if (self) {
        NSArray *viewArrayFromXib = [[NSBundle mainBundle] loadNibNamed:@"TopNotificationView" owner:self options:nil];
        UIView *viewObj = [viewArrayFromXib objectAtIndex:0];
        viewObj.frame = self.bounds;
        [self addSubview:viewObj];
                
    }
    return self;
}

-(void)createBlurredBackground{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
        
        blurEffectView.frame = self.bounds;
        [self addSubview:blurEffectView];
        [self sendSubviewToBack:blurEffectView];
    }else{
        self.backgroundColor = [UIColor colorWithRed:225.0f/255.0f green:225.0f/255.0f blue:225.0f/255.0f alpha:1.0f];
    }
}
-(id)init{
    
    self = [super initWithFrame:CGRectMake(0, -66, SCREEN_WIDTH, 66)];
    self.windowLevel = UIWindowLevelStatusBar+1.0f;

    //check if memory is allocated to self
    if (self) {
        NSArray *viewArrayFromXib = [[NSBundle mainBundle] loadNibNamed:@"TopNotificationView" owner:self options:nil];
        UIView *viewObj = [viewArrayFromXib objectAtIndex:0];
        viewObj.frame = self.bounds;
        [self addSubview:viewObj];
        
    }
    return self;
}

-(void)presentMatchNotificationWithText:(NSString *)textToDisplay andImageURL:(NSURL *)imageURL forMatchID:(NSString *)matchID{
    
    [self createBlurredBackground];
    NSLog(@"------------------------------------------");
    NSLog(@"|       presentmatchnotificationwithtext       ");
    NSLog(@"------------------------------------------");
    self.hidden = NO;
    
    NSURL *ImageCroppedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(kCircularImageSize),IMAGE_SIZE_FOR_POINTS(kCircularImageSize),[APP_Utilities encodeFromPercentEscapeString:[imageURL absoluteString]]]];
    
    [userImageView sd_setImageWithURL:ImageCroppedUrl placeholderImage:[UIImage imageNamed:@"placeholder_male"]];
    [notificationText setText:textToDisplay];
    
    matchedID = matchID;
    
    [UIView animateWithDuration:0.25f animations:^{
        
        [self setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 66)];
        
    } completion:^(BOOL finished){
        
        [self performSelector:@selector(removeNotification:) withObject:nil afterDelay:[[[NSUserDefaults standardUserDefaults] objectForKey:kWaitTimeChatStart] intValue]];
        
    }];
}

- (IBAction)removeNotification:(id)sender {
    
    [UIView animateWithDuration:0.25f animations:^{
        
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y-self.frame.size.height, SCREEN_WIDTH, self.frame.size.height)];
        
    } completion:^(BOOL finished) {
        self.hidden = YES;
//        [self removeFromSuperview];
        
    }];
}

- (IBAction)pushToChat:(id)sender {

    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenChatRoomFromTopNotification object:matchedID];
    [self removeFromSuperview];
}

@end
