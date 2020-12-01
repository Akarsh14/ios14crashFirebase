//
//  DiscoverEmptyView.m
//  Woo_v2
//
//  Created by Akhil Singh on 11/20/15.
//  Copyright © 2015 Vaibhav Gautam. All rights reserved.
//

#import "DiscoverEmptyView.h"
#import <SafariServices/SafariServices.h>
#import "FaqViewController.h"
#import "TipsContainerView.h"

@interface DiscoverEmptyView()
{
    UITextView *feedbackTextviewObj;
    UILabel *placeholderLabel;
    UIView *containerView;
    UILabel *charaterLimitLbl;
    U2AlertView *feedbackAlertViewObj;
    __weak IBOutlet NSLayoutConstraint *discoverEmptyImageViewWidthConstraint;
    __weak IBOutlet NSLayoutConstraint *discoverEmptyImageViewHeightCOnstraint;
    __weak IBOutlet NSLayoutConstraint *body1LabelHeightConstraint;
}

@end

@implementation DiscoverEmptyView

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
        
        NSArray *arrayObj = [[NSBundle mainBundle] loadNibNamed:@"DiscoverEmptyView" owner:self options:nil];
        UIView *viewObj = [arrayObj objectAtIndex:0];
        viewObj.frame = frame;
        [self addSubview:viewObj];
        self = (DiscoverEmptyView *)viewObj;
    }
    return self;
}

- (void)awakeFromNib
{
    NSString *gender = [[NSUserDefaults standardUserDefaults]objectForKey:kWooUserGender];
    
    if( [gender caseInsensitiveCompare:@"FEMALE"] == NSOrderedSame ) {
        [self.tipsButton setHidden:YES];
    }
    else{
        [self.tipsButton setHidden:NO];
    }
    self.ctaButton.layer.masksToBounds = YES;
    self.ctaButton.layer.cornerRadius = 5.0f;
    
    self.ctaButtonIphone4.layer.masksToBounds = YES;
    self.ctaButtonIphone4.layer.cornerRadius = 5.0f;
    
}

/*
- (void)setupItemsForType:(NSString *)type
{
    if (IS_IPHONE_4) {
        self.body2Label.font = [UIFont fontWithName:@"Heavenetica5SH" size:12.0f];
        self.bodyLabelHeightConstraint.constant = 0.0f;
        //[self.meantimeHeightConstraint setConstant:0.0f];
    }
    else{
        [self.meantimeLabel setHidden:YES];
    }
    if ([type isEqualToString:@"feedback"]) {
      self.headerLabel.text = @"More profiles coming right up!";
        self.discoverEmptyImageView.image = [UIImage imageNamed:@"empty_dislike"];
        self.body1Label.text = @"Didn't like anyone?";
        self.body2Label.text = @"Share your experience with me, tell me what you were looking for.\n I would be glad to help you find love.";
        self.ctaButton.titleLabel.text = @"Give Feedback";
    }
    else if ([type isEqualToString:@"askQuestion"]){
        self.headerLabel.text = @"More profiles coming right up!";
        self.discoverEmptyImageView.image = [UIImage imageNamed:@"empty_ask"];
        self.body1Label.text = @"Looking for your kind of guy?";
        self.body2Label.text = @"Post a question to men out there. Match with ones whose answer you like.";
        self.ctaButton.titleLabel.text = @"Ask";
        
    }
    else if ([type isEqualToString:@"noMatches"]){
        self.headerLabel.text = @"More profiles coming right up!";
        self.discoverEmptyImageView.image = [UIImage imageNamed:@"empty_nomatch"];
        self.body1Label.text = @"No matches yet?";
        self.body2Label.text = @"Men with a 90% complete profiles are likely to recieve a match in 7-10 days.\n\n Follow all the tips to increase your changes of getting a match.";
        self.ctaButton.titleLabel.text = @"Complete My Profile";

    }
    else if ([type isEqualToString:@"preferences"]){
        self.headerLabel.text = @"More profiles coming right up!";
        self.discoverEmptyImageView.image = [UIImage imageNamed:@"empty_prefrence"];
        self.body1Label.text = @"Your filters seem narrow";
        self.body2Label.text = @"You may be seeing fewer profile because of narrow age or location filters";
        self.ctaButton.titleLabel.text = @"Change Settings";

    }
    else if ([type isEqualToString:@"intro"]){
        self.headerLabel.text = @"More profiles coming right up!";
        self.discoverEmptyImageView.image = [UIImage imageNamed:@"empty_intro"];
        self.body1Label.text = @"Really liked a profile?";
        self.body2Label.text = @"Send an intro message to impress and conquer. The message will appear on your profile and will boost your chances of a positive response.";
        self.ctaButton.titleLabel.text = @"";
        self.ctaButton.hidden = YES;

    }
}
 */

-(void)setEmptyImage:(UIImage *)emptyImage setHeadingText:(NSString *)headingText setMeantimeText:(NSString *)meantimeText setBody1Text:(NSString *)body1Text setBody2Text:(NSString *)body2Text buttonText:(NSString *)buttonText faqButtonText:(NSString *)faqButtonText feedbackButtonText:(NSString *)feedbackButtonText andVisiblityButtonText:(NSString *)visibiltyText andType:(NSString *)type
{
    if (IS_IPHONE_4) {
        if (buttonText) {
            self.body2Label.font = [UIFont fontWithName:@"Heavenetica5SH" size:12.0f];
            self.body2LabelVerticalSpacingConstraint.constant = 0.0f;
            self.body1LabelTopConstraint.constant = 0.0f;
            self.discoverEmptyImageViewTopConstraint.constant = 0.0f;
        }
    }
    if (IS_IPHONE_5) {
        self.talkToUsButton.titleLabel.font = [UIFont fontWithName:@"Heavenetica5SH" size:11.0f];
        if (buttonText) {
            self.body1LabelTopConstraint.constant = 5.0f;
            self.body2LabelVerticalSpacingConstraint.constant = 5.0f;
            if ([type isEqualToString:kInviteFriendsView]) {
                self.body2LabelVerticalSpacingConstraint.constant = 0.0f;
                self.body2Label.font = [UIFont fontWithName:@"Heavenetica5SH" size:12.0f];
            }
            else{
                self.body2Label.font = [UIFont fontWithName:@"Heavenetica5SH" size:13.0f];
            }
        }
    }

    if ([type isEqualToString:kRecordVoiceIntroView]) {
        self.discoverEmptyImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    else if ([type isEqualToString:kThatsAll10PercentView]){
        self.discoverEmptyImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    else if ([type isEqualToString:kLocationView]){
        
    }
    else if ([type isEqualToString:kGetBoostedView]){
        [self.ctaButton setImage:[UIImage imageNamed:@"boostButtonImage"] forState:UIControlStateNormal];
        self.discoverEmptyImageView.contentMode = UIViewContentModeScaleAspectFit;
        if (IS_IPHONE_4) {
            self.discoverEmptyImageViewTopConstraint.constant = 5.0f;
        }

    }
    else if ([type isEqualToString:kGetCrushesView]){
        self.discoverEmptyImageView.contentMode = UIViewContentModeScaleAspectFill;
        discoverEmptyImageViewHeightCOnstraint.constant = 175.0f;
        discoverEmptyImageViewWidthConstraint.constant = 117.0f;
        body1LabelHeightConstraint.constant = 0.0f;
    }
    
    if (meantimeText) {
        [self.meantimeLabel setText:meantimeText];
    }
    else{
        if (IS_IPHONE_4) {
            [self.meantimeHeightConstraint setConstant:0.0f];
        }
        else{
            [self.meantimeLabel setHidden:YES];
        }
    }

    if (emptyImage) {
        self.discoverEmptyImageView.image = emptyImage;
    }
    if (headingText) {
        self.headerLabel.text = headingText;
    }
    if (body1Text) {
        self.body1Label.text = body1Text;
    }
    if (body2Text) {
        self.body2Label.text = body2Text;
    }
    if (buttonText) {
        if (IS_IPHONE_4) {
            self.ctaButton.hidden = YES;
            self.ctaButtonIphone4.hidden = NO;
        }
        else{
            self.ctaButton.hidden = NO;
            self.ctaButtonIphone4.hidden = YES;
        }
        [self.ctaButton setTitle:buttonText forState:UIControlStateNormal];
        [self.ctaButtonIphone4 setTitle:buttonText forState:UIControlStateNormal];
    }
    else{
        //self.body2LabelheightConstraint.constant = 140;
        NSLog(@"height = %f",self.body2Label.frame.size.height);
        if (IS_IPHONE_4) {
            self.ctaButtonHeightConstraint.constant = 0;
            self.ctaButton.hidden = YES;
            self.ctaButtoniPhone4HeightConstraint.constant = 0;
            self.ctaButtonIphone4.hidden = YES;
        }
        else{
            self.ctaButtonHeightConstraint.constant = 0;
            self.ctaButton.hidden = YES;
        }
    }
    if (faqButtonText) {
        [self.faqButton setTitle:faqButtonText forState:UIControlStateNormal];
    }
    else{
        self.faqButton.hidden = YES;
    }
    if (feedbackButtonText) {
        [self.talkToUsButton setTitle:feedbackButtonText forState:UIControlStateNormal];
    }
    else{
        self.talkToUsButton.hidden = YES;
    }
    if (visibiltyText) {
        [self.tipsButton setTitle:visibiltyText forState:UIControlStateNormal];
    }
    else{
        self.tipsButton.hidden = YES;
    }
}

- (IBAction)CTAButtonClicked:(id)sender {
    if ([_delegate respondsToSelector:_selectorForCTAButtonTapped]) {
        [_delegate performSelector:_selectorForCTAButtonTapped withObject:nil];
    }
}
- (IBAction)infoClicked:(id)sender {
}
- (IBAction)faqClicked:(id)sender {
    [APP_DELEGATE sendSwrveEventWithEvent:@"DiscoverEmpty.FAQs" andScreen:@"DiscoverEmpty"];

    [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:kNeedToChangeFillerOnViewAppear];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        NSURL *faqUrl = [AppLaunchModel sharedInstance].faqUrl;
        if (faqUrl == nil) {
            faqUrl = [NSURL URLWithString:@"http://www.getwoo.at/faq.html"];
        }

        SFSafariViewController *faqSafariViewcontroller = [[SFSafariViewController alloc]initWithURL:faqUrl];
        [APP_DELEGATE.window.rootViewController presentViewController:faqSafariViewcontroller animated:YES completion:nil];
    }
    else{
        FaqViewController *faqViewController = [[FaqViewController alloc]initWithNibName:@"FaqViewController" bundle:nil];
        
        [APP_DELEGATE.window.rootViewController presentViewController:faqViewController animated:YES completion:nil];
    }
    
}

- (IBAction)tipsClicked:(id)sender {
    [APP_DELEGATE sendSwrveEventWithEvent:@"DiscoverEmpty.TipSheetforMales" andScreen:@"DiscoverEmpty"];
    
    if ([_delegate respondsToSelector:_selectorForTipsButtonTapped]) {
        [_delegate performSelector:_selectorForTipsButtonTapped withObject:nil];
    }
}

#pragma mark UITextViewDelegates

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    int messageCharLimit = 250;
    if ((([textView.text length] + text.length) > messageCharLimit) && [text length]>0) {
        return FALSE;
    }
    
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView{
    
    int messageCharLimit = 250;
    NSString *finalString = @"";
    
    if (textView.text.length> 0) {
        [placeholderLabel setHidden:YES];
        [feedbackAlertViewObj enableRightButton];
        
    }else{
        [placeholderLabel setHidden:NO];
        [feedbackAlertViewObj DisableRightButton];
    }
    
    [charaterLimitLbl setText:[NSString stringWithFormat:@"%lu",messageCharLimit-[textView.text length]]];
    
    NSLog(@"length = %lu",(unsigned long)[[APP_Utilities validString:finalString] length]);
    
    
}

- (void)feedbackAlertButtonTapped{
    
    if ([[feedbackTextviewObj.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] < 1) {
        SHOW_TOAST_WITH_TEXT(@"Please enter some text.");
        
        return;
    }
    
    SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"CMP00320",nil));
    
    [APP_DELEGATE sendSwrveEventWithEvent:@"Settings.Feedback" andScreen:@"Settings"];
    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"GiveFeedback" forScreenName:@"Settings"];
    [APP_DELEGATE sendSwrveEventWithEvent:@"DiscoverEmpty.FeedbackSent" andScreen:@"DiscoverEmpty"];
    
    if ([feedbackTextviewObj.text length]>0) {
        NSString *urlString = [NSString stringWithFormat:@"%@%@?wooId=%@&feedBackText=%@",kBaseURLV2, kUserFeedback, [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],[feedbackTextviewObj.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        WooRequest *wooRequestObj = [[WooRequest alloc]init];
        wooRequestObj.url =urlString;
        wooRequestObj.time =900;
        wooRequestObj.requestParams =nil;
        wooRequestObj.methodType =postRequest;
        wooRequestObj.numberOfRetries = 3;
        wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
        wooRequestObj.requestType = userFeedback;
        
        [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
            
            if (statusCode==401 || statusCode==402 || statusCode==500) {
                //                    [self handleErrorForResponseCode:statusCode];
            }
            if (error) {
                //                    [ALToastView toastInView:APP_DELEGATE.window withText:@"Unable to sent feedback."];
            }
            if (requestType == userFeedback && statusCode==200) {
                
                
                //                    [ALToastView toastInView:APP_DELEGATE.window withText:@"Feedback sent successfully."];
            }
        }   shouldReachServerThroughQueue:TRUE];
        [feedbackAlertViewObj removeFromSuperview];
    }

}


@end
