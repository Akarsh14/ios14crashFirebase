//
//  InviteFriendViewController.h
//  Woo_v2
//
//  Created by Deepak Gupta on 4/26/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <MessageUI/MessageUI.h>

@interface InviteFriendViewController : BaseViewController<MFMailComposeViewControllerDelegate , MFMessageComposeViewControllerDelegate>{
    
    IBOutlet  UIView        *viewWhatsAppView;
    IBOutlet  UIView        *viewMessageView;
    IBOutlet  UIView        *viewEmailView;
    
    IBOutlet  UIImageView   *imgViewInvite;
    
    IBOutlet  UIActivityIndicatorView   *activityIndicatorView;
    
    UIViewController *foreignViewController;
}

- (IBAction)backButtonTapped:(id)sender;

- (void)sendEmail;
- (void)sendEmailOnViewController:(UIViewController *)viewControllerObj withEmailDetail:(NSDictionary *)emailDetail;
- (void)sendWhatsApp;
- (void)sendWhatsAppWithDetail:(NSDictionary *)whatsAppDetail;
- (void)sendMessage;
@end
