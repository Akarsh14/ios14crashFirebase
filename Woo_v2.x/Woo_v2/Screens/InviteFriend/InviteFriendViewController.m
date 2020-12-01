//
//  InviteFriendViewController.m
//  Woo_v2
//
//  Created by Deepak Gupta on 4/26/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "InviteFriendViewController.h"
#import "WhatsappShareActivity.h"
#import "CustomMailActivity.h"
#import "MessageCustomActivity.h"
#import "InviteFriendAPIClass.h"
@interface InviteFriendViewController ()

@end

@implementation InviteFriendViewController



- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self settingNavigationBarView];
    UITapGestureRecognizer *tapWhatsApp = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewClicked:)];
    [viewWhatsAppView addGestureRecognizer:tapWhatsApp];
    UITapGestureRecognizer *tapMessage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewClicked:)];
    [viewMessageView addGestureRecognizer:tapMessage];
    UITapGestureRecognizer *tapEmail = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewClicked:)];
    [viewEmailView addGestureRecognizer:tapEmail];
    [self callInviteFriends];
}

-(void)callInviteFriends{
    [InviteFriendAPIClass getInviteFriendDataWithCompletionBlock:^(BOOL success, id response) {
        if (success)
            [self->imgViewInvite sd_setImageWithURL:[NSURL URLWithString:[[response objectForKey:@"compaign"] objectForKey:@"logoUrl"]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                self->activityIndicatorView.hidden = YES;
            }];
        
    }];
}

#pragma mark - Back Button Clicked
- (IBAction)backButtonTapped:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Setting NavigationBar View
- (void) settingNavigationBarView{
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    UILabel *navBarLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
    navBarLabel.text = NSLocalizedString(@"Invite Friends", nil);
    navBarLabel.textColor = kHeaderTextRedColor;
    [navBarLabel setFont:kHeaderTextFont];
    [navBarLabel setBackgroundColor:[UIColor clearColor]];
    [navBarLabel sizeToFit];
    [self.navigationItem setTitleView:navBarLabel];
}

#pragma mark - View Clicked
- (void) viewClicked:(UIPanGestureRecognizer *)tapGestureRecognizer{
    NSLog(@"%ld",tapGestureRecognizer.view.tag);
    
    if (tapGestureRecognizer.view.tag == 0) { // For WhatsApp Clicked
        
        [InviteFriendAPIClass sendInviteFriendEventOnServer:kInviteSourceWhatsApp withCompletionBlock:^(BOOL success, id response) {

        }];
        [self sendWhatsApp];
    }else if (tapGestureRecognizer.view.tag == 1){ // For Message Clicked

        [InviteFriendAPIClass sendInviteFriendEventOnServer:kInviteSourceMessage withCompletionBlock:^(BOOL success, id response) {
        
        }];

        [self sendMessage];
    }else if (tapGestureRecognizer.view.tag == 2){ // For email Clicked
        
        [InviteFriendAPIClass sendInviteFriendEventOnServer:kInviteSourceEmail withCompletionBlock:^(BOOL success, id response) {
        
        }];

        [self sendEmail];
    }
}


#pragma mark - Send WhatsApp
- (void)sendWhatsApp{
    
    NSString *messageBody = NSLocalizedString(@"Text for whatsapp", nil);
    messageBody = [NSString stringWithFormat:@"%@<br><br>%@",messageBody,[[NSUserDefaults standardUserDefaults] valueForKeyPath:kWooUserName]];

    NSString * urlWhats = [NSString stringWithFormat:@"whatsapp://send?text=%@",messageBody];
    urlWhats = [urlWhats stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL * whatsappURL = [NSURL URLWithString:urlWhats];
    [[UIApplication sharedApplication] openURL: whatsappURL];
}

- (void)sendWhatsAppWithDetail:(NSDictionary *)whatsAppDetail{
    NSString *messageBody = [whatsAppDetail objectForKey:@"referMediaDesc"];
    messageBody = [NSString stringWithFormat:@"%@\n %@: %@ \n %@: %@",messageBody,@"Download Android Link",[whatsAppDetail objectForKey:@"androidTinyUrl"],@"Download IOS Link",[whatsAppDetail objectForKey:@"iosTinyUrl"]];
    
    NSString * urlWhats = [NSString stringWithFormat:@"whatsapp://send?text=%@",messageBody];
    urlWhats = [urlWhats stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL * whatsappURL = [NSURL URLWithString:urlWhats];
    [[UIApplication sharedApplication] openURL: whatsappURL];
}

#pragma mark - Send Email
- (void)sendEmail{
    
    if ([MFMailComposeViewController canSendMail]) {
        // Email Content
        
        NSString *messageBody = NSLocalizedString(@"Text for email", nil);
        messageBody = [NSString stringWithFormat:@"%@<br><br>%@",messageBody,[[NSUserDefaults standardUserDefaults] valueForKeyPath:kWooUserName]];
        // To address
        NSArray *toRecipents = [NSArray arrayWithObject:@""];
        NSString *emailTitle = NSLocalizedString(@"CMP00366", nil);
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setBccRecipients:[NSArray arrayWithObject:@"talktous@getwoo.at"]];
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:YES];
        [mc setToRecipients:toRecipents];
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
    }
}

- (void)sendEmailOnViewController:(UIViewController *)viewControllerObj withEmailDetail:(NSDictionary *)emailDetail{
    foreignViewController = viewControllerObj;
    if ([MFMailComposeViewController canSendMail]) {
        // Email Content
        
//        NSString *messageBody = NSLocalizedString(@"Text for email", nil);
//        messageBody = [NSString stringWithFormat:@"%@<br><br>%@",messageBody,[[NSUserDefaults standardUserDefaults] valueForKeyPath:kWooUserName]];
        NSString *messageBody = [emailDetail objectForKey:@"referMediaDesc"];
        [messageBody stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
        messageBody = [NSString stringWithFormat:@"%@ <br><br> %@: %@ <br><br> %@: %@",messageBody,@"Download Android Link",[emailDetail objectForKey:@"androidTinyUrl"],@"Download IOS Link",[emailDetail objectForKey:@"iosTinyUrl"]];
        
//        messageBody = [NSString stringWithFormat:@"%@ <br><br> <a hreaf:\"%@\"> %@ </a> <br><br> <a hreaf:\"%@\"> %@ </a>",messageBody,[emailDetail objectForKey:@"androidTinyUrl"],@"Download Android Link",[emailDetail objectForKey:@"iosTinyUrl"],@"Download IOS Link"];
        // To address
        NSArray *toRecipents = [NSArray arrayWithObject:@""];
        NSString *emailTitle = [emailDetail objectForKey:@"referMediaMiniDesc"];
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setBccRecipients:[NSArray arrayWithObject:@"referral@getwoo.at"]];
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:YES];
        [mc setToRecipients:toRecipents];
        
        // Present mail view controller on screen
        [viewControllerObj presentViewController:mc animated:YES completion:NULL];
    }
}

#pragma mark - Send Message
- (void)sendMessage{
    
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    [controller setMessageComposeDelegate:self];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = NSLocalizedString(@"Text for email", nil);
        [self presentViewController:controller animated:YES completion:^{
            
        }];
    }

}

#pragma mark - Mail Composer Delegate
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            
            break;
        case MFMailComposeResultSaved:
            
            break;
        case MFMailComposeResultSent:
            
            break;
        case MFMailComposeResultFailed:
            
            break;
        default:
            break;
    }
    
    if (foreignViewController) {
        [foreignViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else{
      [self dismissViewControllerAnimated:YES completion:NULL];
    }
    
    
}

#pragma mark - Message Composer Delegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [controller dismissViewControllerAnimated:YES completion:^{

    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
