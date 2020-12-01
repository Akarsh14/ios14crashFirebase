//
//  LoginErrorFeedbackViewController.h
//  Woo_v2
//
//  Created by Deepak Gupta on 6/9/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoginErrorFeedbackViewController;

@protocol LoginErroFeedbackDelegate <NSObject>

- (void)gettingResponseFromLoginErrorFeebackWithLoginErrorReference:(LoginErrorFeedbackViewController *)errorFeedback;

@end

@interface LoginErrorFeedbackViewController : UIViewController{
    
    __weak IBOutlet UIButton         *btnSend;
    __weak IBOutlet UIView           *viewBottom;
    __weak IBOutlet UILabel          *lblBoom;
    __weak IBOutlet UITextView       *textViewObj;

    BOOL        isDefaultText;

//    NSString *wooUserID;
}

@property(nonatomic, assign)BOOL isShownForAgeLimit;

@property (assign) id<LoginErroFeedbackDelegate>       delegate;

-(IBAction)sendButtonClicked:(id)sender;



@end
