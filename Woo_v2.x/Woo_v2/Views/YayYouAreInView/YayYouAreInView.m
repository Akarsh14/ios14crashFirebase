//
//  YayYouAreInView.m
//  Woo_v2
//
//  Created by Umesh Mishra on 08/09/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "YayYouAreInView.h"

@interface YayYouAreInView()
{
    int yayYouAreInType;
}

@end
@implementation YayYouAreInView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithFrame:(CGRect)frame andVariantType:(int)variantType{
    self = [super initWithFrame:frame];
    
    //check if memory is allocated to self
    if (self) {
        //getting array of views from the xib
        if (variantType == 1 || variantType == 2) {
            _autoDismissView = FALSE;
        }
        else{
            _autoDismissView = TRUE;
        }
        
        NSArray *viewArrayFromXib = [[NSBundle mainBundle] loadNibNamed:@"YayYouAreInView" owner:self options:nil];
        UIView *viewObj = [viewArrayFromXib objectAtIndex:variantType];
        viewObj.frame = self.bounds;
        [self addSubview:viewObj];
        
        [self updateScreenDataAccordingToTheViewType:variantType];

        if (variantType == 2) {
            [self performSelector:@selector(updateContraintsAccordingToPhone) withObject:nil afterDelay:0.0];
        }
    }
    return self;
}
-(void)updateScreenDataAccordingToTheViewType:(int)screenType{
    
    if (!IS_IPHONE_4) {
        distanceBetweenCardAndGetStarted.constant = 40;
        distanceBetweenCardAndHeader.constant = 30;
        
        heightOfEditProfileBtn_v3.constant = 35;
        heightOfGetStartedBtn_v2.constant = 35;
        heightOfGetStartedBtn_v3.constant = 35;
    }
    
    yayYouAreInType = screenType;
    
    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"YayScreen" forScreenName:[NSString stringWithFormat:@"Screen%dView",screenType+1]];

    CGFloat imageWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat imageHeight = ([[UIScreen mainScreen] bounds].size.width *0.8);
    
    NSURL *imageURL =[NSURL URLWithString:[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(imageWidth), IMAGE_SIZE_FOR_POINTS(imageHeight),[APP_Utilities encodeFromPercentEscapeString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooProfilePicURL]]]];
    
    NSString *gender = [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserGender];
    BOOL amIMale = [APP_Utilities isGenderMale:gender];
    
    
    UserProfileModel *myProfile = APP_DELEGATE.oMyProfileModel;
    
    switch (screenType) {
        case 2:
        {
            [APP_DELEGATE sendSwrveEventWithEvent:@"Yay.TypeA" andScreen:@"YayScreen"];
            
            if (myProfile.educationHistory && myProfile.educationHistory.count>0) {
                //
                [instituteNameBtn setTitle:[[[myProfile.educationHistory objectAtIndex:0] objectForKey:@"college"]objectForKey:@"name"] forState:UIControlStateNormal];
                [degreLbl setText:[[myProfile.educationHistory objectAtIndex:0] objectForKey:@"degree"]];
            }
            else{
                educationInfoMissingObj.hidden = FALSE;
            }
            
            if (myProfile.workExperienceHistory && myProfile.workExperienceHistory.count>0) {
                //
                [workPlaceBtn setTitle:[[[myProfile.workExperienceHistory objectAtIndex:0] objectForKey:@"work"] objectForKey:@"name"] forState:UIControlStateNormal];
                [designationLbl setText:[[myProfile.workExperienceHistory objectAtIndex:0] objectForKey:@"designation"]];
            }
            else{
                workInfoMissingViewObj.hidden = FALSE;
            }
            
            userNameAgeLbl.text = [NSString stringWithFormat:@"%@, %ld",myProfile.firstName,(long)myProfile.age];
            userLocationLbl.text = myProfile.location;
            imageCounterLbl.text = [NSString stringWithFormat:@"%lu",myProfile.wooAlbum.count];
            
            [userPhotoForVariant2 sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:amIMale?@"placeholder_male":@"placeholder_female"]];
            
            
            
            float allowedWidthForLbl = APP_DELEGATE.window.frame.size.width-80;
            UILabel *tempLblToCheckWidth = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, APP_DELEGATE.window.frame.size.width-80, 18)];
            tempLblToCheckWidth.font = kAlertViewDescriptionTextFont;
            int xPos = 0;
            BOOL isAnyBtnAddedToView = FALSE;
            likesLbl.text = @"";
            
            if (myProfile.interests == nil || myProfile.interests.count==0){
                [lblLikesTitle setText:NSLocalizedString(@"CDI008", @"not updated yet")];
                [lblLikesTitle setTextColor:kTrackLineColor];
                lblLikesTitle.font = kTimertextFont;
            }
            else{
                NSArray *likesArray = myProfile.interests;
                if ([likesArray count] == 0){
                    [lblLikesTitle setText:NSLocalizedString(@"CDI008", @"not updated yet")];
                    [lblLikesTitle setTextColor:kTrackLineColor];
                    lblLikesTitle.font = kTimertextFont;
                    
                }else if ([likesArray count]>0) {
                    for (NSDictionary *likesDetails in likesArray) {
                        DY_UnderLineButton *likeBtn = [DY_UnderLineButton buttonWithType:UIButtonTypeCustom];
                        likeBtn.backgroundColor = [UIColor clearColor];
                        likeBtn.frame = CGRectMake(xPos, 0, 300, 18);
                        [likeBtn setTitleColor:kButtonTextRedColor forState:UIControlStateNormal];
                        [likeBtn.titleLabel setFont:kAlertViewDescriptionTextFont];
                        NSString *str = [likesDetails objectForKey:@"name"];
                        [likeBtn setTitle:str forState:UIControlStateNormal];
                        [likeBtn sizeToFit];
                        
                        if (!isAnyBtnAddedToView) {
                            if (likeBtn.frame.size.width > allowedWidthForLbl) {
                                likeBtn.frame = CGRectMake(xPos, 0, allowedWidthForLbl, 18);
                                
                                float buttonWidth = likeBtn.frame.size.width;
                                likeBtn.frame = CGRectMake(xPos, 0, buttonWidth, 18);
                                
                                [likesViewObj addSubview:likeBtn];
                            }
                            else{
                                
                                float buttonWidth = likeBtn.frame.size.width;
                                likeBtn.frame = CGRectMake(xPos, 0, buttonWidth, 18);
                                
                                [likesViewObj addSubview:likeBtn];
                            }
                            isAnyBtnAddedToView = TRUE;
                        }
                        else{
                            if ((xPos+likeBtn.frame.size.width) > allowedWidthForLbl) {
                                break;
                            }
                            else{
                                float buttonWidth = likeBtn.frame.size.width;
                                likeBtn.frame = CGRectMake(xPos, 0, buttonWidth, 18);
                                
                                [likesViewObj addSubview:likeBtn];
                            }
                        }
                        xPos = xPos + likeBtn.frame.size.width + 5;
                    }
                }
            }
        }
            break;
            
        case 1:{
            [APP_DELEGATE sendSwrveEventWithEvent:@"Yay.TypeB" andScreen:@"YayScreen"];

//                maleFrndCountLbl.text = [NSString stringWithFormat:@"%d",[[userDetails objectForKey:@"maleFriendCount"] intValue]];
//                femaleFrndCountLbl.text = [NSString stringWithFormat:@"%d",[[userDetails objectForKey:@"femaleFriendCount"] intValue]];
//            int totalFrndOnWoo = [[userDetails objectForKey:@"maleFriendCount"] intValue] + [[userDetails objectForKey:@"femaleFriendCount"] intValue];
            int totalFrndOnWoo = 0;
            
            NSString *numberText = [NSString stringWithFormat:@"%d",totalFrndOnWoo];
            NSMutableAttributedString *loadingText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@",numberText,NSLocalizedString(@"YYAI007", nil)]];
            [loadingText addAttribute:NSForegroundColorAttributeName value:kButtonTextRedColor range:NSMakeRange(0, [numberText length])];
            
            mutualFrndOnFbMsgLbl.attributedText = loadingText;
            userNameLbl.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Welcome", nil), [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserName]];
            [userPhotoForVariant1 sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:amIMale?@"placeholder_male":@"placeholder_female"]];
        }
            break;
        case 0:{
            [APP_DELEGATE sendSwrveEventWithEvent:@"Yay.TypeC" andScreen:@"YayScreen"];

            headerLbl.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Welcome", nil), [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserName]];
            
            messageLbl.text = NSLocalizedString(@"COB0031", @"you are in screen sub text");
            
            [userPhoto sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:amIMale?@"placeholder_male":@"placeholder_female"]];
        }
            break;
            
        default:
            break;
    }
    
}
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    //check if memory is allocated to self
    if (self) {
        //getting array of views from the xib
        NSArray *viewArrayFromXib = [[NSBundle mainBundle] loadNibNamed:@"YayYouAreInView" owner:self options:nil];
        UIView *viewObj = [viewArrayFromXib objectAtIndex:3];
        viewObj.frame = self.bounds;
        [self addSubview:viewObj];
    
        headerLbl.text = [NSString stringWithFormat:NSLocalizedString(@"COB0030", @"yay you are in screen user welcome text"),[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserName]];
        
        messageLbl.text = NSLocalizedString(@"COB0031", @"you are in screen sub text");
        
        CGFloat imageWidth = [[UIScreen mainScreen] bounds].size.width;
        CGFloat imageHeight = ([[UIScreen mainScreen] bounds].size.width *0.8);
        
        NSURL *imageURL =[NSURL URLWithString:[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(imageWidth), IMAGE_SIZE_FOR_POINTS(imageHeight),[APP_Utilities encodeFromPercentEscapeString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooProfilePicURL]]]];

       NSString *gender = [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserGender];
        BOOL amIMale = [APP_Utilities isGenderMale:gender];

        [userPhoto sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:amIMale?@"placeholder_male":@"placeholder_female"]];
        [self performSelector:@selector(updateContraintsAccordingToPhone) withObject:nil afterDelay:0.0];
    }
    return self;
}

-(void)updateContraintsAccordingToPhone{
    if (IS_IPHONE_4) {
                    [centerContainerViewObj addConstraint:[NSLayoutConstraint
                                                           constraintWithItem:centerContainerViewObj
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                           toItem:centerContainerViewObj
                                                           attribute:NSLayoutAttributeWidth
                                                           multiplier:1.1
                                                           constant:0]];
//        containerViewRatioOutlet.constant = 1.0714285714;
        educationInfoView.hidden = TRUE;
        educationInfoHeightOutlet.constant = 0;
        educationTopValueOutlet.constant = 0;
    }
    else{
        [centerContainerViewObj addConstraint:[NSLayoutConstraint
                                               constraintWithItem:centerContainerViewObj
                                               attribute:NSLayoutAttributeHeight
                                               relatedBy:NSLayoutRelationEqual
                                               toItem:centerContainerViewObj
                                               attribute:NSLayoutAttributeWidth
                                               multiplier:1.35
                                               constant:0]];
    }
}

-(void)presentViewDuration:(float )animationDuration onView:(UIView *)presentingView{
    [self setAlpha:0];
    [presentingView addSubview:self];
    
    [UIView animateWithDuration:(animationDuration/10) delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        [loaderObj startAnimating];
        
        [self setAlpha:1.0f];
    } completion:^(BOOL finished) {
        if (_autoDismissView) {
            [UIView animateWithDuration:(animationDuration/10) delay:(((animationDuration/10)*8)) options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self setAlpha:0.0f];
            } completion:^(BOOL finished) {
                if ([_delegate respondsToSelector:_selectorForViewFading]) {
                    [_delegate performSelector:_selectorForViewFading withObject:nil afterDelay:0.0];
                }
                //            [[NSNotificationCenter defaultCenter] postNotificationName:kHeartAnimationEnded object:nil];
            }];
        }
        
    }];
}

-(void)presentViewDuration:(float )animationDuration onView:(UIView *)presentingView withDismissBlock:(ViewDismissedBlock)dismissBlock{
    [self setAlpha:0];
    [presentingView addSubview:self];
    viewDismissBlock = dismissBlock;
    
    [UIView animateWithDuration:(animationDuration/10) delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        [loaderObj startAnimating];
        
        [self setAlpha:1.0f];
    } completion:^(BOOL finished) {
        if (_autoDismissView) {
            [UIView animateWithDuration:(animationDuration/10) delay:(((animationDuration/10)*8)) options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"YayYouAreInOrPhotoUploadViewHasNotBeenDismissed"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                viewDismissBlock(YES);
                if ([_delegate respondsToSelector:_selectorForViewFading]) {
                    [_delegate performSelector:_selectorForViewFading withObject:nil afterDelay:0.0];
                }
                //            [[NSNotificationCenter defaultCenter] postNotificationName:kHeartAnimationEnded object:nil];
            }];
        }
        
    }];
}


-(IBAction)syncWithLinkedInButtonTapped:(id)sender{
    [APP_DELEGATE sendSwrveEventWithEvent:@"Yay.TypeCLinkedIn" andScreen:@"YayScreen"];
    NSLog(@"syncWithLinkedInButtonTapped");
    [UIView animateWithDuration:(3.0/10.0) delay:(((0.0/10)*8)) options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self setAlpha:0.0f];
    } completion:^(BOOL finished) {
        if ([_delegate respondsToSelector:_selectorForViewFading]) {
            [_delegate performSelector:_selectorForViewFading withObject:nil afterDelay:0.0];
        }
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"YayYouAreInOrPhotoUploadViewHasNotBeenDismissed"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        viewDismissBlock(NO);
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kShouldScrollToLinkedIn];
        [[NSUserDefaults standardUserDefaults] synchronize];
        //            [[NSNotificationCenter defaultCenter] postNotificationName:kHeartAnimationEnded object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kOpenProfileInEditMode object:nil];
    }];
}

-(IBAction)editProfileButtonTapped:(id)sender{
    [APP_DELEGATE sendSwrveEventWithEvent:@"Yay.TypeCEditP" andScreen:@"YayScreen"];
    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"YayScreen" forScreenName:@"Screen3EditProfilebutton"];

    [UIView animateWithDuration:(3.0/10.0) delay:(((0.0/10)*8)) options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self setAlpha:0.0f];
    } completion:^(BOOL finished) {
        if ([_delegate respondsToSelector:_selectorForViewFading]) {
            [_delegate performSelector:_selectorForViewFading withObject:nil afterDelay:0.0];
        }
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"YayYouAreInOrPhotoUploadViewHasNotBeenDismissed"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        viewDismissBlock(NO);
        //            [[NSNotificationCenter defaultCenter] postNotificationName:kHeartAnimationEnded object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kOpenProfileInEditMode object:nil];
    }];

}
-(IBAction)getStartedButtonTapped:(id)sender{
    if (yayYouAreInType == 2) {
        [APP_DELEGATE sendSwrveEventWithEvent:@"Yay.TypeBTap" andScreen:@"YayScreen"];
    }
    else if (yayYouAreInType == 1){
        [APP_DELEGATE sendSwrveEventWithEvent:@"Yay.TypeCGetS" andScreen:@"YayScreen"];
    }
    
    [UIView animateWithDuration:(3.0/10.0) delay:(((0.0/10)*8)) options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self setAlpha:0.0f];
    } completion:^(BOOL finished) {
        if ([_delegate respondsToSelector:_selectorForViewFading]) {
            [_delegate performSelector:_selectorForViewFading withObject:nil afterDelay:0.0];
        }
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"YayYouAreInOrPhotoUploadViewHasNotBeenDismissed"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        viewDismissBlock(TRUE);
//        [[NSNotificationCenter defaultCenter] postNotificationName:kOpenProfileInEditMode object:nil];
        //            [[NSNotificationCenter defaultCenter] postNotificationName:kHeartAnimationEnded object:nil];
    }];

}

-(IBAction)infoButtonTapped:(id)sender{
    NSLog(@"info button tapped");
    U2AlertView *infoAlertObj = [[U2AlertView alloc] init];
//    [infoAlertObj alertWithHeaderText:nil description:@"No fb frnds name. \n\n also your info is also kept private too." leftButtonText:@"Ok" andRightButtonText:nil];

    [infoAlertObj alertWithHeaderText:nil description:NSLocalizedString(@"To maintain their privacy we cannot disclose the names of your FB friends. \n\n Don\'t worry, your info will be kept private too and we will never show you to your friends.", nil)  leftButtonText:@"Ok" andRightButtonText:nil];

    
    [infoAlertObj setU2AlertActionBlockForButton:^(int tagValue , id data){

    }];
    
    [infoAlertObj show];
}

@end
