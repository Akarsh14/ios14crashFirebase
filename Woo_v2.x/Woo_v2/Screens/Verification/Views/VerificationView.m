//
//  VerificationView.m
//  Woo
//
//  Created by Umesh Mishra on 20/02/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "VerificationView.h"
#import <MessageUI/MessageUI.h>
#import <QuartzCore/QuartzCore.h>

@interface VerificationView()<UITextViewDelegate>
{
    UITextView *feedbackTextviewObj;
    UILabel *placeholderLabel;
    UIView *containerView;
    UILabel *charaterLimitLbl;
    U2AlertView *feedbackAlertViewObj;
}

@end

@implementation VerificationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        NSArray *arrayObj = [[NSBundle mainBundle] loadNibNamed:@"VerificationView" owner:self options:nil];
        UIView *viewObj = [arrayObj objectAtIndex:0];
        viewObj.frame = frame;
        [self addSubview:viewObj];
    }
    return self;
}

#pragma mark ---Verification View method

-(void)initialiseViewAccordingScreenHeight{
    
    
    CGRect progressViewFrame = CGRectMake((SCREEN_WIDTH - 159)/2, 128, 159, 12);
    

    if (!progressViewObj1) {
        UIView *progressBackgroundView = [[UIView alloc] initWithFrame:progressViewFrame];
        progressBackgroundView.backgroundColor = [UIColor whiteColor];
        progressBackgroundView.layer.cornerRadius = 5.0;
        [whiteBandView addSubview:progressBackgroundView];
        progressViewObj1 = [[LDProgressView alloc] initWithFrame:CGRectMake(1, 1, 157, 10)];
        progressViewObj1.color = [UIColor colorWithRed:188.0f/255.0f green:83.0f/255.0f blue:83.0f/255.0f alpha:1.0f];
        progressViewObj1.showText = @NO;
        progressViewObj1.progress = 0.0;
        progressViewObj1.borderRadius = @5;
        progressViewObj1.showStroke = @NO;
        progressViewObj1.animate = @YES;
        progressViewObj1.background = [UIColor whiteColor];
        progressViewObj1.type = LDProgressSolid;
        [progressBackgroundView addSubview:progressViewObj1];
    }
}
-(void)setProgressValue:(float)progress{
    
    progressViewObj1.progress = progress;

}

-(void)setImage:(UIImage *)imageObj{
    if (imageObj) {
        [_imageView setImage:imageObj];
    }
    
}
-(void)setHeading:(NSString *)headingText andMessage:(NSString *)messageText{
    _containerView.hidden = FALSE;
    _errorContainerView.hidden = TRUE;
    _headingLabel.text = headingText;
    _messageLabel.text = messageText;
}
-(void)hideProgressView{
    progressViewObj1.hidden = TRUE;
}
-(void)hideAppreciationLabel{
    _nameAppreciationLabel.hidden = TRUE;
}

#pragma mark ---Verification View method --=--Ends-=----

#pragma mark ---Error View method

-(void)setErrorHeading:(NSString *)errorHeadingText withFirstMessage:(NSString *)firstMessageString andSecondMessageText:(NSString *)secondMessageString{
    return;
//    _errorContainerView.hidden = FALSE;
//    _containerView.hidden = TRUE;
//    _errorHeaderLabel.text = errorHeadingText;
////    newFirstMessageString = @"test\n\ntest";
//    firstMessageString = [firstMessageString stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
//    _firstErrorMessageLabel.text = firstMessageString;
//    NSLog(@"firstMessageString:%@",firstMessageString);
//    CGRect frameOfLabel = _firstErrorMessageLabel.frame;
//    [_firstErrorMessageLabel sizeToFit];
//    frameOfLabel.size.height = _firstErrorMessageLabel.frame.size.height;
//    _firstErrorMessageLabel.frame = frameOfLabel;
//    _secondErrorMessageLabel.text = secondMessageString;
}

-(void)setErrorImage:(UIImage *)errorImage{
    if (errorImage) {
//        _errorImageView.image = errorImage;
    }
    
}

#pragma mark ---Error View method --=--Ends-=----



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{_containerView	UIView *	0x9429de0	0x09429de0
    // Drawing code
}
*/

-(void)setViewForProgressStateVal:(int)progressState{
    switch (progressState) {
        case kProgressState1_Value:{
            secondPhaseView.hidden = TRUE;
            thirdPhaseView.hidden = TRUE;
        }
            break;
        case kProgressState2_Value:{
            secondPhaseView.hidden = FALSE;
            thirdPhaseView.hidden = TRUE;
        }
            break;
        case kProgressState3_Value:{
            secondPhaseView.hidden = TRUE;
            thirdPhaseView.hidden = FALSE;
            verificatinHeaderLabel.text = NSLocalizedString(@"COB0024", @"the Key should be mapped with key in the sheet");
            verificationHeaderImage.image = [UIImage imageNamed:@"onboarding_profile.png"];
        }
        default:
            break;
    }
}
-(void)showErrorScreenForErrorVal:(int)errorVal withHeaderText:(NSString *)fakeHeaderText andFakeReasonText:(NSString *)fakeReasonText{

    secondPhaseView.hidden = TRUE;
    thirdPhaseView.hidden = TRUE;
    if (whiteBandView.frame.origin.y>0) {
        _topHeightContraint.constant = whiteBandView.frame.origin.y;
    }
    else{
        float ratioVal = APP_DELEGATE.window.frame.size.height/900.0;
        _topHeightContraint.constant = (212*ratioVal);
    }
    
    //_errorMsgTopLayoutContraint.constant = whiteBandView.frame.origin.y + 171 + 35;
    _errorContainerView.hidden = FALSE;
    
    fakeHeaderText = [fakeHeaderText stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
    
    fakeReasonText = [fakeReasonText stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
    
    _errorHeaderLabel.text = fakeHeaderText;
    _firstErrorMessageLabel.hidden = FALSE;
    _firstErrorMessageLabel.attributedText = [[NSAttributedString alloc] initWithString:fakeReasonText];
    
    switch (errorVal) {
        case VERIFICATION_ERROR_PROFILE_NOT_VERIFIED_ON_FB:{
            _errorImageView.image = [UIImage imageNamed:@"onboarding_fb.png"];
        }
            break;
        case VERIFICATION_ERROR_GENDER_MISSING:{
            //nothing here
        }
            break;
        case VERIFICATION_ERROR_RELATIONSHIP_NOT_ALLOWED:
        case VERIFICATION_ERROR_RELATIONSHIP_NOT_ALLOWED_MARRIED:
        case VERIFICATION_ERROR_RELATIONSHIP_NOT_ALLOWED_OTHERS:{
            _errorImageView.image = [UIImage imageNamed:@"onboarding_singles.png"];
        }
            break;
        case VERIFICATION_ERROR_DOB_MISSING:{
            //nothing here
        }
            break;
        case VERIFICATION_ERROR_UNDER_AGE:{
            _errorImageView.image = [UIImage imageNamed:@"onboarding_block.png"];
        }
            break;
        case VERIFICATION_ERROR_DOB_AND_GENDER_MISSING:{
            //nothing here
        }
            break;
        case VERIFICATION_ERROR_LESS_FRIEND_ON_FB:{
            _errorImageView.image = [UIImage imageNamed:@"onboarding_friends.png"];
        }
            break;
        case VERIFICATION_ERROR_NEW_USER_ON_FB:{
            _errorImageView.image = [UIImage imageNamed:@"onboarding_old.png"];
        }
            break;
        case VERIFICATION_ERROR_INVALID_USER_PROFILE:{
            _errorImageView.image = [UIImage imageNamed:@"onboarding_balloon.png"];
        }
            break;
        
        default:
            break;
    }
    
    NSRange range = [_firstErrorMessageLabel.attributedText.string rangeOfString:NSLocalizedString(@"Write_To_Us", nil)];
    if (range.length > 0) {
        NSDictionary* style = @{NSUnderlineStyleAttributeName: [NSNumber numberWithInt:1]};
        
        NSMutableAttributedString* myString = [_firstErrorMessageLabel.attributedText mutableCopy];
        [myString setAttributes:style range:range];
        _firstErrorMessageLabel.attributedText = myString;
        
        _firstErrorMessageLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(singleTapView:)];
        singleTap.numberOfTapsRequired = 1;
        [_firstErrorMessageLabel addGestureRecognizer:singleTap];
    }
}

- (void) singleTapView:(UIPanGestureRecognizer *)tapGestureRecognizer
{
//    [self openFeedbackView];
}

-(void)createViewAccordingToNavBarWithNavBarStatus:(BOOL )isNavBarVisible{
    
    if (isNavBarVisible) {
//        [_containerView setFrame:CGRectMake(_containerView.frame.origin.x, _containerView.frame.origin.y-64, _containerView.frame.size.width, _containerView.frame.size.height)];

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


-(void)alertButtonTapped{
    
        if ([[feedbackTextviewObj.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] < 1) {
            SHOW_TOAST_WITH_TEXT(@"Please enter some text.");
            return;
        }
        
        SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"CMP00320",nil));
        
        [APP_DELEGATE sendSwrveEventWithEvent:@"Settings.Feedback" andScreen:@"Settings"];
        [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"GiveFeedback" forScreenName:@"Settings"];
        
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
