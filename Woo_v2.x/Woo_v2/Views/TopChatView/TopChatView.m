//
//  TopChatView.m
//  Woo_v2
//
//  Created by Deepak Gupta on 2/18/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "TopChatView.h"
#define HeightOfView_Detailed 64
#define HeightOfView_Small    20

@implementation TopChatView

static TopChatView *sharedInstance = nil;

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedInstance];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

+ (TopChatView *)sharedInstance {
    static TopChatView *sharedInstance = nil;
    if (!sharedInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedInstance = [[super allocWithZone:NULL] init];
            // custom initialisation
        });
    }
    return sharedInstance;
}

+ (TopChatView *)sharedInstanceWithNotificationType:(NotificationType)notificationType{
    static TopChatView *sharedInstance = nil;
    if (!sharedInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedInstance = [[super allocWithZone:NULL] initWithViewType:notificationType];
            // custom initialisation
        });
    }
    return sharedInstance;
}



/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */


//-(id)initWithFrame:(CGRect)frame{
//    self = [super initWithFrame:frame];
//    self.windowLevel = UIWindowLevelStatusBar+2.0f;
//
//    //check if memory is allocated to self
//    if (self) {
//        NSArray *viewArrayFromXib = [[NSBundle mainBundle] loadNibNamed:@"TopChatView" owner:self options:nil];
//        UIView *viewObj = [viewArrayFromXib objectAtIndex:0];
//        viewObj.frame = self.bounds;
//        [self addSubview:viewObj];
//
//    }
//    return self;
//}

-(id)init{
    
    self = [super initWithFrame:CGRectMake(0, -HeightOfView_Small, SCREEN_WIDTH, HeightOfView_Small)];
    self.windowLevel = UIWindowLevelStatusBar+1.0f;
    heightOfView = HeightOfView_Small;
    //check if memory is allocated to self
    if (self) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]) {
            NSArray *viewArrayFromXib = [[NSBundle mainBundle] loadNibNamed:@"TopChatView" owner:self options:nil];
            UIView *viewObj = [viewArrayFromXib objectAtIndex:0];
            viewObj.frame = self.bounds;
            backgroundView = viewObj;
            [self addSubview:viewObj];
            viewDisAppearInProgress = FALSE;
        }
    }
    return self;
}
    
-(id)initWithViewType:(NotificationType)notificationType{
    self = [super initWithFrame:CGRectMake(0, -64, SCREEN_WIDTH, 64)];
    self.windowLevel = UIWindowLevelStatusBar+1.0f;
    heightOfView = 64;
    //check if memory is allocated to self
    if (self) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]) {
            NSArray *viewArrayFromXib = [[NSBundle mainBundle] loadNibNamed:@"TopChatView" owner:self options:nil];
            UIView *viewObj = [viewArrayFromXib objectAtIndex:0];
            viewObj.frame = self.bounds;
            backgroundView = viewObj;
            [self addSubview:viewObj];
            viewDisAppearInProgress = FALSE;
        }
    }
    return self;
}

//-(void)swipeHandler:(UISwipeGestureRecognizer *)recognizer {
//    
//    if ( recognizer.direction == UISwipeGestureRecognizerDirectionLeft )
//        NSLog(@" *** SWIPE LEFT ***");
//    if ( recognizer.direction == UISwipeGestureRecognizerDirectionRight )
//        NSLog(@" *** SWIPE RIGHT ***");
//    if ( recognizer.direction == UISwipeGestureRecognizerDirectionDown )
//        NSLog(@" *** SWIPE DOWN ***");
//    if ( recognizer.direction == (UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown) )
//        NSLog(@" *** SWIPE UP ***");
//    
//    NSLog(@"Swipe received.%lu",(unsigned long)recognizer.direction);
//    [self removeNotification];
//}

    
-(void)showNewChatMessageFromTop:(NSString *)message withHeader:(NSString *)headerStr andUserImage:(NSString *)userImg{
    CGFloat safeLayoutTop = [[Utilities sharedUtility] getSafeAreaForTop:true andBottom:false];

    if([headerStr isEqualToString:@""])
    {
        [self centerMsgLabelView];
    }
    else
    {
        [self recenterMsgLabelViewToItsOriginalPosition];
    }
    self.hidden = NO;
    backgroundView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    NSURL *imageUrl;
    if([userImg containsString:kImageCroppingServerURL])
    {
        userImg = [userImg stringByReplacingOccurrencesOfString:kImageCroppingServerURL withString:@""];
        userImg = [userImg stringByReplacingOccurrencesOfString:@"?url=" withString:@""];
        NSArray *prefixSuffixArray = [userImg componentsSeparatedByString:@"&"];
        userImg = [prefixSuffixArray firstObject];
    }
    imageUrl =  [NSURL URLWithString:[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(kCircularImageSize), IMAGE_SIZE_FOR_POINTS(kCircularImageSize),userImg]];

    [userImage sd_setImageWithURL:imageUrl];
    userImage.layer.cornerRadius = 25.0;
    userImage.layer.masksToBounds = TRUE;
    self.backgroundColor = [UIColor clearColor];
    headingLbl.text = headerStr;
//    if (notificationType == chatBoxLanding) {
        msgLbl.numberOfLines = kMaximumNumberOfLinesAllowedForChatNotification;
        msgLbl.minimumScaleFactor = kMaximumScaleFactorForChatNotification;
//    }
    msgLbl.text = message;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeNotification) object:nil];

    [UIView animateWithDuration:0.2f animations:^{
        [self setFrame:CGRectMake(0, safeLayoutTop, SCREEN_WIDTH, 64)];
    } completion:^(BOOL finished){
        
        [self performSelector:@selector(removeNotification) withObject:nil afterDelay:5];
        
    }];
}
    
-(IBAction)viewTapped:(id)sender{
    
    switch (notificationType) {
        case incomingVisitorLanding:
        //show visitor section
        break;
        case likedMeSection:
        //show visitor section
        break;
        case chatBoxLanding:
        //show visitor section
        break;
        
        default:
        break;
    }
    

    UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate]window];

    for (UIView *subView in [keyWindow subviews]) {
        if ([subView isKindOfClass:[NewMatchOverlayView class]]) {
            [subView removeFromSuperview];
        }
    }
    
    handlerBlock(TRUE);
    [self removeNotification];
}

//-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
//    
//    UITouch *aTouch = [touches anyObject];
//    CGPoint newLocation = [aTouch locationInView:self];
//    CGPoint prevLocation = [aTouch previousLocationInView:self];
//    
//    if (newLocation.x > prevLocation.x) {
//        //finger touch went right
//    } else {
//        //finger touch went left
//    }
//    if (newLocation.y > prevLocation.y) {
//        //finger touch went upwards
//        NSLog(@"fab");
//        if (!viewDisAppearInProgress) {
//            [self removeNotification];
//        }
//    } else {
//        //finger touch went downwards
//        NSLog(@"moved 1");
//        if (!viewDisAppearInProgress) {
//            [self removeNotification];
//        }
//        
//    }
//}

-(void)setNotificationTypeForView:(NotificationType)notificationVal{
    notificationType = notificationVal;
}


- (void)showNewChatMessageFromTop : (NSString *)message{
//    [self centerMsgLabelView];
    self.hidden = NO;
    
    UILabel *lblChatMsg = nil;
    lblChatMsg = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH-heightOfView, heightOfView)];
    lblChatMsg.textAlignment = NSTextAlignmentCenter;
    lblChatMsg.opaque = 1.0;
    [lblChatMsg setLineBreakMode:NSLineBreakByTruncatingTail];
    [lblChatMsg setTextColor:kHeaderTextRedColor];
    [lblChatMsg setFont:kRightNotificationErrorFont];
    [lblChatMsg setText:message];
    [lblChatMsg setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:lblChatMsg];
    
    
    [UIView animateWithDuration:0.2f animations:^{
        [self setFrame:CGRectMake(0, 0, SCREEN_WIDTH, heightOfView)];
    } completion:^(BOOL finished){
        [self performSelector:@selector(removeNotification) withObject:nil afterDelay:kTimeforWhichAppInAppPurchaseNotificationWillBeVisible];        
    }];
    
    
}

- (void)removeNotification {
    viewDisAppearInProgress = TRUE;
    [UIView animateWithDuration:0.5f animations:^{
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y-self.frame.size.height, SCREEN_WIDTH, self.frame.size.height)];
    } completion:^(BOOL finished) {
        self.hidden = YES;
        viewDisAppearInProgress = FALSE;
    }];
}

-(void)setButtonTapHandler:(void(^)(BOOL btnTapped))btnTappedHandler{
    UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate]window];
    
    for (UIView *subView in [keyWindow subviews]) {
        if ([subView isKindOfClass:[NewMatchOverlayView class]]) {
            [subView removeFromSuperview];
        }
    }
    handlerBlock = btnTappedHandler;
}

- (IBAction)panGetureHandler:(UIPanGestureRecognizer *)sender {
    CGPoint velocity =  [sender velocityInView:self];
    CGPoint translation = [sender translationInView:self];
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:{
            int directionVal = velocity.y < 1.0 ? -1 : 1;
            switch (directionVal) {
                case -1:
                    NSLog(@"swiping up");
                    sender.view.center = CGPointMake(sender.view.center.x, sender.view.center.y + translation.y);
                    break;
                case 1:
                    NSLog(@"swiping down");
                    sender.view.center = CGPointMake(sender.view.center.x, sender.view.center.y + translation.y);
                    break;
                    
                default:
                    break;
            }
            [sender setTranslation:CGPointMake(0, 0) inView:self];
            
            if (sender.view.frame.origin.y > (sender.view.frame.size.height)) {
                [self removeFromSuperview];
            }
        }
            
            break;
            
        case UIGestureRecognizerStateEnded:{
            NSLog(@"Pata nahi kya karna hai");
            [self removeNotification];
        }
            break;
            
        default:
            break;
    }
    
}

- (IBAction)tapGestureHandler:(UITapGestureRecognizer *)sender {
    if(notificationType == unknown){
      [self removeNotification];
    }
    else{
        handlerBlock(TRUE);
        [self removeNotification];
    } 
}


-(void)centerMsgLabelView
{
    //remove image view and header lbl
    //msg label has 15 + 7  padding on the left and 8 on the right
    userImageWidthConstraint.constant = 0;
    float spaceOnEitherSide = (self.frame.size.width - msgLbl.bounds.size.width)/2.0;
    msgLblToUserImageConstraint.constant =  spaceOnEitherSide -7;
    msgLbltoRightConstraint.constant =  spaceOnEitherSide -8;
    
    //
    float verticalSpacing = (self.frame.size.height - msgLbl.bounds.size.height)/2.0;
    headingLblHeightConstraint.constant = 0;
    headingToMsgLblConstraint.constant  = verticalSpacing - 7.0;
    msgLabelToBottomConstraint.constant = verticalSpacing - 2.0;
    [self layoutIfNeeded];
}

-(void)recenterMsgLabelViewToItsOriginalPosition
{
    //remove image view and header lbl
    //msg label has 15 + 7  padding on the left and 8 on the right
    userImageWidthConstraint.constant = 50.0;
    msgLblToUserImageConstraint.constant =  15.0;
    msgLbltoRightConstraint.constant = 8.0;
    
    //
    headingLblHeightConstraint.constant = 18.0;
    headingToMsgLblConstraint.constant  = 0.0;
    msgLabelToBottomConstraint.constant = 2.0;
    [self layoutIfNeeded];

}



@end
