//
//  TopChatView.h
//  Woo_v2
//
//  Created by Deepak Gupta on 2/18/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopChatView : UIWindow{
    
    __weak IBOutlet NSLayoutConstraint *userImageToLeftConstraint;
    __weak IBOutlet NSLayoutConstraint *msgLbltoRightConstraint;
    __weak IBOutlet NSLayoutConstraint *userImageWidthConstraint;
    __weak IBOutlet NSLayoutConstraint *msgLblToUserImageConstraint;
    IBOutlet UIImageView *userImage;
    __weak IBOutlet NSLayoutConstraint *headingLblHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *topToHeadingLabelConstraint;
    __weak IBOutlet NSLayoutConstraint *headingToMsgLblConstraint;
    
    __weak IBOutlet NSLayoutConstraint *msgLabelToBottomConstraint;
    IBOutlet UILabel *headingLbl;
    IBOutlet UILabel *msgLbl;
    IBOutlet UIButton *btnObj;
    NotificateViewType notificateViewTypeVal;
    NotificationType notificationType;
    int heightOfView;
    void(^handlerBlock)(BOOL btnTapped);
    BOOL viewDisAppearInProgress;
    UIView *backgroundView;
}
-(id)initWithViewType:(NotificationType)notificationType;
- (void)showNewChatMessageFromTop : (NSString *)message;
-(void)showNewChatMessageFromTop:(NSString *)message withHeader:(NSString *)headerStr andUserImage:(NSString *)userImg;
    
-(IBAction)viewTapped:(id)sender;
-(void)setNotificationTypeForView:(NotificationType)notificationVal;
-(void)setButtonTapHandler:(void(^)(BOOL btnTapped))btnTappedHandler;
- (IBAction)panGetureHandler:(UIPanGestureRecognizer *)sender;
- (IBAction)tapGestureHandler:(UITapGestureRecognizer *)sender;



+ (TopChatView *)sharedInstance;
+ (TopChatView *)sharedInstanceWithNotificationType:(NotificationType)notificationType;
@end
