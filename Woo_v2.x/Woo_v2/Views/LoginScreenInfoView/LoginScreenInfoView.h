//
//  LoginScreenInfoView.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 16/03/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

typedef void (^LoginInfoViewDismissed) (BOOL isViewDismissed , BOOL isPrivacyOpened , BOOL isTermsOpened);

#import <UIKit/UIKit.h>
@interface LoginScreenInfoView : UIView{
    
    __weak IBOutlet UIView *centerView;
    LoginInfoViewDismissed viewDismissedBlock;
}

- (IBAction)removeButtonTapped:(id)sender;
- (IBAction)privacyButtonTapped:(id)sender;
- (IBAction)termsButtonTapped:(id)sender;

-(void)presentViewOnView:(UIView *)viewObj;
-(void)viewDismissed:(LoginInfoViewDismissed)callBack;

-(void)dismissLoginInfoView;
@end
