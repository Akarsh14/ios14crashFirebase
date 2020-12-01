//
//  Utilities.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 18/05/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "Utilities.h"
#import <FacebookSDK/FacebookSDK.h>
#import "U2opiaFBLoginView.h"
#import "MyAnswers.h"
#import "Applozic.h"
#import "NSData+Base64.h"
#import "AppSessionManager.h"
#import "FreeTrailModel.h"
#import "MeDashboard.h"
#import "CrushesDashboard.h"
#import "LayerManager.h"
#import "LikedMe.h"
#import "InAppPurchaseManager.h"

#import "WooToast.h"
#import "AppSettingsApiClass.h"
#import "WhatsappShareActivity.h"
#import "CustomMailActivity.h"
#import "MessageCustomActivity.h"
#import "FBSDKLogin.h"
#import "LoginModel.h"
#import "SkippedProfiles.h"
#import "AFNetworkReachabilityManager.h"
#import "UNetworkReachability.h"
#import "PurchaseProductDetailModel.h"
#import "BoostAPIClass.h"
#import "LikedMeAPIClass.h"
#import "SkippedProfileAPIClass.h"
#import "LikedByMeAPIClass.h"
#import "CrushAPIClass.h"
#import "ApplozicChatManager.h"

#import "AgoraConnectionManager.h"
#import <AVFoundation/AVFoundation.h>

@interface Utilities()
{
    WooToast *toast;
    BOOL allBoostDataFetched;
    BOOL allLikedMeDataFetched;
    BOOL allSkippedDataFetched;
    BOOL allCrushDataFetched;
    BOOL allQnADataFetched;
    //    int totalMeBadgeCount;
}

@end
@implementation Utilities

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


+ (id)sharedUtility {
    static Utilities *sharedUtilityObj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUtilityObj = [[self alloc] init];
    });
    return sharedUtilityObj;
}

-(UserProfileModel*)myprofile{
    return APP_DELEGATE.oMyProfileModel;
}

-(void)sendFCMPushTokenToServer
{
    [APP_DELEGATE sendFCMPushTokenToServer];
}

-(void)showVoiceCallIntroductionPopup
{
    [APP_DELEGATE showVoiceCallIntroductionPopup];
}
-(UIBarButtonItem *)createLeftButtonViewOnNavBar:(SEL)selectorForButtonTapped withDelegate:(id)delegate{
    
    UIView *viewRef = [UIView new];
    
    UIView *leftButtonView = [UIView new];
    [leftButtonView setFrame:CGRectMake(0, 0, 70, 44)];
    [leftButtonView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [leftButtonView setBackgroundColor:[UIColor clearColor]];
    [leftButtonView setUserInteractionEnabled:NO];
    [viewRef addSubview:leftButtonView];
    
    
    UIImageView *leftImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"hamburgerMenu"]];
    UIImageView *rightImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"buttonWooImage"]];
    
    [leftImage setTranslatesAutoresizingMaskIntoConstraints:NO];
    [rightImage setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [leftButtonView addSubview:leftImage];
    [leftButtonView addSubview:rightImage];
    
    NSDictionary *viewsDictionary = @{@"buttonView":leftButtonView,
                                      @"leftImage":leftImage,
                                      @"rightImage":rightImage
                                      };
    
    //    Adding view for button
    NSArray *leftViewWidthContraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[buttonView(98)]"
                                                                              options:NSLayoutFormatAlignAllBaseline
                                                                              metrics:nil
                                                                                views:viewsDictionary];
    
    NSArray *leftViewHeightContraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[buttonView(64)]"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:viewsDictionary];
    
    NSArray *viewXPosition = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[buttonView]"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:viewsDictionary];
    
    NSArray *viewYPosition = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[buttonView]"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:viewsDictionary];
    
    [viewRef addConstraints:viewXPosition];
    [viewRef addConstraints:viewYPosition];
    [leftButtonView addConstraints:leftViewHeightContraint];
    [leftButtonView addConstraints:leftViewWidthContraint];
    //    added view for button
    
    
    //    adding left and right image of button
    NSArray *leftImageWidth = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[leftImage(16)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary];
    
    NSArray *leftImageHeight = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[leftImage(15)]"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:viewsDictionary];
    
    NSArray *leftImageXPosition = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[leftImage]"
                                                                          options:NSLayoutFormatAlignAllCenterX
                                                                          metrics:nil
                                                                            views:viewsDictionary];
    
    NSArray *leftImageYPosition = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-35-[leftImage]"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:viewsDictionary];
    
    
    
    NSArray *rightImageWidth = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[rightImage(68)]"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:viewsDictionary];
    
    NSArray *rightImageHeight = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[rightImage(24)]"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];
    
    NSArray *rightImageXPosition = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[rightImage]-0-|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:viewsDictionary];
    
    NSArray *rightImageYPosition = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[rightImage]"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:viewsDictionary];
    [leftImage addConstraints:leftImageHeight];
    [leftImage addConstraints:leftImageWidth];
    [leftButtonView addConstraints:leftImageXPosition];
    [leftButtonView addConstraints:leftImageYPosition];
    
    [rightImage addConstraints:rightImageHeight];
    [rightImage addConstraints:rightImageWidth];
    [leftButtonView addConstraints:rightImageXPosition];
    [leftButtonView addConstraints:rightImageYPosition];
    //    added left and right image button
    
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton addSubview:leftButtonView];
    [menuButton setFrame:leftButtonView.frame];
    [menuButton addTarget:delegate action:selectorForButtonTapped forControlEvents:UIControlEventTouchUpInside];
    
    __block UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(rightImage.frame.origin.x+2, rightImage.frame.origin.y+1, 20, 20)];
    [numberLabel setBackgroundColor:kHeaderTextRedColor];
    [numberLabel setTextColor:[UIColor whiteColor]];
    [numberLabel setFont:kNavBarButtonFont];
    [numberLabel setAlpha:0.0f];
    [numberLabel setTextAlignment:NSTextAlignmentCenter];
    
    [rightImage addSubview:numberLabel];
    
    
    if ([[AppSessionManager sharedManager] isNotificationCallMade] ||
        [[AppSessionManager sharedManager] isCrushCallMade] ||
        [[AppSessionManager sharedManager] isVisitorCallMade]) {
        
        int notifCount = 0;
        NSLog(@"notifCount >:%d",notifCount);
        NSLog(@"APP_DELEGATE.notificationsDataArray :%@",APP_DELEGATE.notificationsDataArray);
        for (NSDictionary *tempDict in APP_DELEGATE.notificationsDataArray) {
            if ([[tempDict objectForKey:@"read"] boolValue] == FALSE) {
                notifCount++;
            }
        }
        NSLog(@"notifCount >>:%d",notifCount);
        notifCount += [MeDashboard getTotalNumberOfUnvisitedVisitor];
        NSLog(@"notifCount >>>:%d",notifCount);
        notifCount += [CrushesDashboard getTotalUnreadCrushes];
        NSLog(@"notifCount >>>>:%d",notifCount);
        if (notifCount < 10) {
            [numberLabel setText:[NSString stringWithFormat:@"%d",notifCount]];
        }
        else{
            [numberLabel setText:[NSString stringWithFormat:@"9+"]];
        }
        
        if (notifCount > 0) {
            [UIView animateWithDuration:0.3f delay:1.0f options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                [numberLabel setAlpha:1.0f];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3f delay:1.0f options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                    [numberLabel setAlpha:0.0f];
                } completion:^(BOOL finished) {
                    [numberLabel removeFromSuperview];
                    numberLabel = nil;
                }];
            }];
        }
    }
    
    return [[UIBarButtonItem alloc]initWithCustomView:menuButton];
}

- (NSString *)validString:(NSString *)string
{
    if (((NSNull *)string == [NSNull null]) || !string || [string isEqualToString:@"(null)"] || [string isEqualToString:@"<null>"]) {
        return @"";
    }
    string = [NSString stringWithFormat:@"%@",string];
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return (string!=nil && !((NSNull *)string == [NSNull null])) ? string : @"";
}

- (NSString*) encodeFromPercentEscapeString:(NSString*)feedbackStr{
    
    CFStringRef str = CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)feedbackStr,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
    return CFBridgingRelease(str);
}

//This has to used after iOS 10
-(NSString *)getURLDecodedStringFromString:(NSString *)encodedString{
    
    NSString *localEnCodedString = encodedString;
    if (localEnCodedString && localEnCodedString.length > 0) {
        localEnCodedString = [[localEnCodedString stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"encodedString=%@",localEnCodedString);
        NSString *checkString = [self validString:localEnCodedString];
        if (checkString.length > 0) {
            return localEnCodedString;
        }
        else{
            return encodedString;
        }
    }
    else{
        return @"";
    }
}


- (NSString *)decodeFromPercentEscapingString:(NSString *)stringToDecode{
    CFStringRef str = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)stringToDecode, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
    return CFBridgingRelease(str);
}

-(NSDate *)returnDateFromTimeStamp:(long long)timeStamp{
    NSDate *dateTime = nil;
    dateTime = [NSDate dateWithTimeIntervalSince1970:timeStamp/1000];
    
    return dateTime;
}


-(NotificationType )getNotificationTypeFor:(NSString *)notificationTypeString{
    NSLog(@"notificationTypeString :%@",notificationTypeString);
    NSLog(@"notificationTypeString :%@",[notificationTypeString uppercaseString]);
    notificationTypeString = [notificationTypeString uppercaseString];

    NotificationType type;
    
    if ([notificationTypeString isEqualToString:@"DISCOVER"]) {
        type = discoverScreen;
    }else if ([notificationTypeString isEqualToString:@"ME"] || [notificationTypeString isEqualToString:@"ME_SECTION_LANDING"]) {
        type = meSectionLanding;
    }else if ([notificationTypeString isEqualToString:@"VISITORS"] || [notificationTypeString isEqualToString:@"VISITOR_LANDING"]) {
        type = visitorSection;
    }else if ([notificationTypeString isEqualToString:@"LIKEDME"] || [notificationTypeString isEqualToString:@"LIKED_ME_LANDING"]) {
        type = likedMeSection;
    }else if ([notificationTypeString isEqualToString:@"CRUSH"] || [notificationTypeString isEqualToString:@"CRUSH_RECEIVED_LANDING"]) {
        type = crushReceivedSection;
    }else if ([notificationTypeString isEqualToString:@"SKIPPED"] || [notificationTypeString isEqualToString:@"SKIPPED_PROFILE_LANDING"]) {
        type = skippedProfileSection;
    }else if ([notificationTypeString isEqualToString:@"MY_QUESTION_LANDING"]) {
        type = myQuestionsSection;
    }else if ([notificationTypeString isEqualToString:@"MATCH_BOX_LANDING"] || [notificationTypeString isEqualToString:@"MATCH"]) {
        type = matchBoxSection;
    }else if ([notificationTypeString isEqualToString:@"MYPURCHASES"] || [notificationTypeString isEqualToString:@"MY_PURCHASES_LANDING"]) {
        type = myPurchasesSection;
    }else if ([notificationTypeString isEqualToString:@"BOOSTPURCHASE"] || [notificationTypeString isEqualToString:@"BOOST_WHAT_YOU_GET_LANDING"] || [notificationTypeString isEqualToString:@"BoostPurchase"]) {
        type = boostPurchaseSection;
    }else if ([notificationTypeString isEqualToString:@"CRUSHPURCHASE"] || [notificationTypeString isEqualToString:@"CRUSH_WHAT_YOU_GET_LANDING"] || [notificationTypeString isEqualToString:@"CrushPurchase"]) {
        type = crushPurchaseSection;
    }else if ([notificationTypeString isEqualToString:@"WOOPLUSPURCHASE"] || [notificationTypeString isEqualToString:@"WOOPLUS_WHAT_YOU_GET_LANDING"] || [notificationTypeString isEqualToString:@"WooPlusPurchase"]) {
        type = wooplusPurchaseSection;
    }else if ([notificationTypeString isEqualToString:@"WOOGLOBEPURCHASE"] || [notificationTypeString isEqualToString:@"WOOGLOBE_WHAT_YOU_GET_LANDING"] || [notificationTypeString isEqualToString:@"WooGlobePurchase"]) {
        type = wooGlobePurchaseSection;
    }else if ([notificationTypeString isEqualToString:@"EDITPROFILE"] || [notificationTypeString isEqualToString:@"EDIT_PROFILE_LANDING"]) {
        type = editProfilePurchaseSection;
    }else if ([notificationTypeString isEqualToString:@"CHAT_BOX_LANDING"]) {
        type = chatBoxLanding;
    }else if ([notificationTypeString isEqualToString:@"SETTINGS"] || [notificationTypeString isEqualToString:@"DISCOVER_SETTINGS_LANDING"]) {
        type = discoverSettingsSection;
    }else if ([notificationTypeString isEqualToString:@"APP_SETTINGS_LANDING"]) {
        type = appSettingsSection;
    }else if ([notificationTypeString isEqualToString:@"WOO_PLAY_APP_STORE_PAGE"]) {
        type = appStoreLandingSection;
    }else if([notificationTypeString isEqualToString:@"IN_APP_BROWSER"]){
        type = inAppBrowserSection;
    }else if([notificationTypeString isEqualToString:@"REFERFRIEND"]){
        type = referFriend;
    }else if([notificationTypeString isEqualToString:@"INVITECAMPAIGN"] || [notificationTypeString isEqualToString:@"INVITE_CODE"]){
        type = referFriend;
    }else if([notificationTypeString isEqualToString:@"TAGSELECTION"] || [notificationTypeString isEqualToString:@"TAG_BUBBLE_SELECTION_LANDING"] ||[notificationTypeString isEqualToString:@"TAG_SELECTION_LANDING"]){
        type = tagBubbleLanding;
    }else if([notificationTypeString isEqualToString:@"INCOMING_VISITOR_LANDING"]){
        type = incomingVisitorLanding;
    }
    else if([notificationTypeString isEqualToString:@"WOOVIP_INVITE"])
    {
        type = voipInviteLanding;
    }
    else if([notificationTypeString isEqualToString:@"CONTENT_GUIDELINES"]){
        type = contentguidelines;
    }
    else if([notificationTypeString isEqualToString:@"PREFERENCE_FEEDBACK_LANDING"] || [notificationTypeString isEqualToString:@"FEEDBACK"] || [notificationTypeString isEqualToString:@"FEEDBACKPREFERENCE"]){
        type = feedback;
    }
    else{
        type = unknown;
    }
    
    return type;
}

-(NSString *)getAddidtionalDataKeyForNotificationType:(NotificationType )typeOfNotif{
    switch (typeOfNotif) {
            //        case introduced:
            //        {
            //            return @"recommendationData";
            //        }
            //            break;
            //
            //        case introduceMe:
            //        {
            //            return @"recommendationData";
            //        }
            //            break;
            //        case iAmMatched:
            //        {
            //            return @"matchEventDto";
            //        }
            //            break;
        default:
        {
            return @"";
        }
            break;
    }
}

//show activity indicaotr
-(void)showActivityIndicator{
    
    if (!backgroundView) {
        backgroundView = [[UIView alloc] init];
    }
    backgroundView.frame = [APP_DELEGATE window].bounds;
    backgroundView.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.5f];
    
    if (!customLoader) {
        customLoader = [[WooLoader alloc]initWithFrame:backgroundView.bounds];
        [customLoader customLoadingText:@""];
        [customLoader startAnimationOnView:backgroundView WithBackGround:NO];
    }
    
    [[APP_DELEGATE window] addSubview:backgroundView];
}


-(void)hideActivityIndicator{
    if (customLoader) {
        [customLoader removeFromSuperview];
        customLoader = nil;
    }
    
    if ([backgroundView superview]) {
        [backgroundView removeFromSuperview];
    }
    
}


-(int)getImageSizeForPoints:(int)pointSize{
    
    float scale;
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        scale = 2;
    }else{
        scale = [[UIScreen mainScreen] nativeScale];
    }
    
    return (int)(pointSize * scale);
}

-(BOOL)isGenderMale:(NSString *)gender{
    BOOL isMale =TRUE;
    
    if (gender!=nil && !([gender caseInsensitiveCompare:@"male"] == NSOrderedSame)) {
        isMale = FALSE;
    }
    
    return isMale;
}


- (NSString *)applicationDocumentsDirectory{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    return basePath;
}
- (NSString *)applicationCacheDirectory{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    return basePath;
}

- (void)displayAlertWithTitle:(NSString *)alertTitle message:(NSString *)alertMessage withDelegate:(id)delegate
{
    BOOL  isAlreadyAdded = FALSE;
    
    for (UIWindow *viewObj in [APP_DELEGATE.window subviews]) {
        if (viewObj.tag == 1090) {
            isAlreadyAdded = TRUE;
            break;
        }
    }
    
    if(!isAlreadyAdded){
        
        U2AlertView *alertObj = [[U2AlertView alloc]init];
        NSString *alertMessageWithNewLine = [NSString stringWithFormat:@" %@ ",alertMessage];
        [alertObj alertWithHeaderText:alertTitle description:alertMessageWithNewLine leftButtonText:NSLocalizedString(@"CMP00356",nil) andRightButtonText:nil];
        [alertObj setTag:1090];
        
        [alertObj setU2AlertActionBlockForButton:^(int tagValue , id data){
        }];
        
        [alertObj show];
        
    }
}

-(BOOL)isFacebookPermissionMissing{
    BOOL isIncompletePermission = FALSE;
    
    for (NSString *permission in [[U2opiaFBLoginView sharedU2opiaFBLoginView] fetchReadPermissions]) {
        if (![[FBSession activeSession].permissions containsObject:permission]) {
            isIncompletePermission = TRUE;
            break;
        }
    }
    
    return isIncompletePermission;
}

-(float )returnOSVersion{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

-(void)getPushNotificationPermission{
    
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:KAPNS_PERMISSION_ASKED];
    UIApplication *application = [UIApplication sharedApplication];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        //Adding Code for call reminder category
        UIMutableUserNotificationAction *acceptAction = [[UIMutableUserNotificationAction alloc]init];
        acceptAction.identifier = @"Accept";
        acceptAction.title = NSLocalizedString(@"Accept", nil);
        acceptAction.activationMode = UIUserNotificationActivationModeForeground;
        acceptAction.destructive = NO;
        acceptAction.authenticationRequired = NO;
        
        UIMutableUserNotificationAction *declineAction = [[UIMutableUserNotificationAction alloc]init];
        declineAction.identifier = @"Decline";
        declineAction.title = NSLocalizedString(@"Decline", nil);
        declineAction.activationMode = UIUserNotificationActivationModeBackground;
        declineAction.destructive = YES;
        declineAction.authenticationRequired = NO;
        
        NSArray *actionsArray = [NSArray arrayWithObjects:acceptAction,declineAction, nil];
        
        UIMutableUserNotificationCategory *voiceCallReminderCategory = [[UIMutableUserNotificationCategory alloc] init];
        [voiceCallReminderCategory setIdentifier:@"voiceCallReminderCategory"];
        [voiceCallReminderCategory setActions:actionsArray forContext:UIUserNotificationActionContextDefault];
        NSSet *categoriesForNotification = [NSSet setWithObject:voiceCallReminderCategory];
        
        
        
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:categoriesForNotification];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        //        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    //    else {
    //        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    //    }
#else
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
#endif
    // [APP_DELEGATE registerForVOIPPush];
    
}

-(void)fadeInView:(UIView *)viewObj{
    [UIView animateWithDuration:0.3 animations:^{
        viewObj.alpha = 1;
    } completion:^(BOOL finished) {
        nil;
    }];
}

-(void)fadeOutAndRemoveView:(UIView *)viewObj{
    [UIView animateWithDuration:0.3 animations:^{
        viewObj.alpha = 0;
    } completion:^(BOOL finished) {
        [viewObj removeFromSuperview];
    }];
    
}

-(void)makeTopCornersOfViewRounded:(UIView *)viewObj{
    
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:viewObj.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(5.0, 5.0)];
    
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    
    viewObj.layer.mask = shape;
    
}



-(void)makeBottomCornersOfViewRounded:(UIView *)viewObj{
    
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:viewObj.bounds byRoundingCorners:UIRectCornerBottomRight | UIRectCornerBottomLeft cornerRadii:CGSizeMake(15.0, 15.0)];
    
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    
    viewObj.layer.mask = shape;
    
}



-(void)makeBottomCornersOfViewRounded:(UIView *)viewObj withRadiud:(float)raiudVal{
    
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:viewObj.bounds byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight cornerRadii:CGSizeMake(raiudVal, raiudVal)];
    
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    
    viewObj.layer.mask = shape;
    
}

-(float)getHeightForText:(NSString *)text forFont:(UIFont *)font widthOfLabel:(float )width{
    if ([text isEqualToString:@""] || text == nil) {
        return 0.0f;
    }
    
    CGSize constraint = CGSizeMake(width, MAXFLOAT);
    //    calcu
    CGRect textRect = [text boundingRectWithSize:constraint
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:font}
                                         context:nil];
    return ceilf(textRect.size.height);
}



-(NSDictionary *)createTappedTagDataDictForButton:(UIButton *)tappedButton{
    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc]init];
    
    if (tappedButton && !tappedButton.isSelected) {
        [dataDict setObject:[self validString:tappedButton.tagTypeKey] forKey:kTappableTagTypeKey];
        NSLog(@"is selected :%d",tappedButton.isSelected);
        NSLog(@"tappedButton.customTagValue :%@",tappedButton.customTagValue);
        [dataDict setObject:tappedButton.customTagValue forKey:kTappableTagIDKey];
        //        [dataDict  setObject:tappedButton.titleLabel.text forKey:kTappableTagNameKey];
        if (tappedButton.isSelected) {
            [dataDict setObject:[tappedButton.titleLabel.text substringToIndex:[tappedButton.titleLabel.text length]-2] forKey:kTappableTagNameKey];
            
        }
        else{
            [dataDict setObject:tappedButton.titleLabel.text forKey:kTappableTagNameKey];
        }
        [dataDict setObject:[NSNumber numberWithBool:FALSE] forKey:kIsTagFromSelf];
    }
    else{
        dataDict = nil;
        tappedButton.selected = FALSE;
    }
    
    return dataDict;
}

//Added by Umesh : Give scale animation to an object
-(void)scaleUpAnimationOnView:(id)viewObj withNumberOfTimes:(int)repeatCount{
    
    UIView *viewToScaleObj = (UIView *)viewObj;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.duration = 0.4;
    animation.autoreverses = YES;
    animation.repeatCount = repeatCount;
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue = [NSNumber numberWithFloat:1.4f];
    [viewToScaleObj.layer addAnimation:animation forKey:@"animateOpacity"];
    
}

-(void)scaleUpAnimationOnView:(id)viewObj withNumberOfTimes:(int)repeatCount withTimeDuration:(CGFloat )animationDuration{
    
    UIView *viewToScaleObj = (UIView *)viewObj;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.duration = animationDuration;
    animation.autoreverses = YES;
    animation.repeatCount = repeatCount;
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue = [NSNumber numberWithFloat:1.4f];
    [viewToScaleObj.layer addAnimation:animation forKey:@"animateOpacity"];
    
}



-(void)showNoInternetAvailableToast{
    SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"Please check your internet connection",nil));
}

-(void)showLoaderViewWithText:(NSString *)grayText andHighlightedText:(NSString *)highlightedText onView:(UIView *)viewObj{
    if (!loaderViewObj) {
        loaderViewObj = [[LoaderView alloc] initWithFrame:APP_DELEGATE.window.bounds];
    }
    //    [APP_DELEGATE.window addSubview:loaderViewObj];
    float ver = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (ver >= 9.0) {
        // Only executes on version 9 or above.
        [viewObj addSubview:loaderViewObj];
    }else{
        [APP_DELEGATE.window addSubview:loaderViewObj];
    }
    [loaderViewObj setTextOnLabelWithGrayColor:grayText andWithHighlightedText:highlightedText];
    
    
}

-(void)showLoaderViewWithText:(NSString *)firstText andMiddleText:(NSString *)middleText andHighlightedText:(NSString *)highlightedText onView:(UIView *)viewObj{
    if (!loaderViewObj) {
        loaderViewObj = [[LoaderView alloc] initWithFrame:APP_DELEGATE.window.bounds];
    }
    //    [APP_DELEGATE.window addSubview:loaderViewObj];
    float ver = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (ver >= 9.0) {
        // Only executes on version 9 or above.
        [viewObj addSubview:loaderViewObj];
    }else{
        [APP_DELEGATE.window addSubview:loaderViewObj];
    }
    [loaderViewObj setTextOnLabelWithGrayColor:firstText andWithHighlightedText:highlightedText];
}

-(void)hideLoaderView{
    if (loaderViewObj && [loaderViewObj superview]) {
        [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            [loaderViewObj setAlpha:0.0f];
            
        } completion:^(BOOL finished) {
            if (loaderViewObj && [loaderViewObj superview]) {
                [loaderViewObj removeFromSuperview];
                loaderViewObj = nil;
            }
        }];
    }
}

// Method to check if location services is available.
-(BOOL)isLocationServicesAvailable
{
    //Here,We assumed this application is only support iOS 4.0 onwards.
    return  [CLLocationManager locationServicesEnabled];
}

// Method to check if app has permission to use location.
-(BOOL)isAuthorizedToUseLocationService{
    //Changes made to support iOS 8 and 7
    if ([self returnOSVersion]>=8.0) {
        return (([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse))?YES:NO;
    }
    else{
        return [CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorized?YES:NO;
    }
    
}

-(BOOL)isLocationServicesDisabled{
    BOOL locationServicesDisabled = FALSE;
    
    BOOL locationAllowed = [self isLocationServicesAvailable];
    
    BOOL appLocationFetchDisabled = [self isAuthorizedToUseLocationService];
    
    if (locationAllowed==NO || appLocationFetchDisabled==NO){
        locationServicesDisabled = TRUE;
    }
    
    return locationServicesDisabled;
}

-(BOOL)isDayChangedFromTheDate:(NSDate *)lastDateVal{
    BOOL dateChanged = FALSE;
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd"];
    int todayDate = [[dateFormatter stringFromDate:currentDate] intValue];
    int lastDateDateVal =[[dateFormatter stringFromDate:lastDateVal] intValue];
    if (todayDate != lastDateDateVal) {
        dateChanged = TRUE;
    }
    return dateChanged;
}

-(BOOL)reachable{
    // return [[UNetworkReachability sharedNetworkReachability] getInterentStatus];
    
    Reachability *r = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if(internetStatus == NotReachableAtAll) {
        return NO;
    }
    return YES;
    
}


-(void)openURLForURLString:(NSString *)URLString{
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URLString]];
    
}


-(BOOL)deleteFileAtPath:(NSString *)filePath{
    NSError *error;
    BOOL isFileDeleted = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    return isFileDeleted;
}
-(BOOL)checkIfFileExistsAtPath:(NSString *)filePath{
    //    NSError *error;
    BOOL isFilePresent = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:FALSE];
    return isFilePresent;
    
}
-(NSString *)filePathAfterAppendingDocumentDirectoryPathToGivenFileName:(NSString *)fileName{
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //    Full path of audio file
    NSString* outputFileURL = [documentsPath stringByAppendingPathComponent:fileName];
    
    return outputFileURL;
}

-(NSString *)getAudioPathForFileName:(NSString *)fileName{
    //    document directory path
    NSString* documentsPath = [APP_Utilities applicationCacheDirectory];
    NSString *finalDocumentsPath = [NSString stringWithFormat:@"%@/audio",documentsPath];
    NSString *audioFile = nil;
    NSString *fileNameStr = [NSString stringWithFormat:@"%@",fileName];
    if([fileNameStr hasSuffix:@".m4a"] || [fileNameStr hasSuffix:@".mp4"]){
        audioFile =   [NSString stringWithFormat:@"%@",fileName];
    }else{
        audioFile =  [NSString stringWithFormat:@"%@.%@",fileName,kAudioFileExtension];
    }
    
    //    Full path of audio file
    NSString* outputFileURL = [finalDocumentsPath stringByAppendingPathComponent:audioFile];
    //    returning audio file path
    return outputFileURL;
}

-(BOOL)renameFilePresentAtPath:(NSString *)filePath withNewFilePath:(NSString *)newFilePath{
    NSError *error;
    if ([self checkIfFileExistsAtPath:newFilePath]) {
        [self deleteFileAtPath:newFilePath];
    }
    BOOL isFileRenamed = [[NSFileManager defaultManager] copyItemAtPath:filePath toPath:newFilePath error:&error];
    if (isFileRenamed) {
        [self deleteFileAtPath:filePath];
    }
    return isFileRenamed;
}

-(BOOL)canAskMoreQuestions{
    
    NSInteger questionsAllowed = [AppLaunchModel sharedInstance].qaQuestionLimit;
    
    NSInteger questionsAsked = [AppLaunchModel sharedInstance].questionsAskedToday ;
    
    if ((questionsAllowed - questionsAsked) <=0) {
        return NO;
    }
    return YES;
    
}

//-(void)checkAndUpdateUserProfilesTagsOptions{
////    kFirstTimeProfileOptionsFetched
//
//    long long int newTimestampOfProfileTags = 0;
//    long long int oldTimestamoOfProfileTags = 0;
//
//    if ([AppLaunchModel sharedInstance].profileOptionsUpdatedTime>0) {
//
//        newTimestampOfProfileTags = [AppLaunchModel sharedInstance].profileOptionsUpdatedTime;
//
//    }
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:kProfileUpdatedOn] && [[[NSUserDefaults standardUserDefaults] objectForKey:kProfileUpdatedOn] longLongValue] >0) {
//
//        oldTimestamoOfProfileTags = [[[NSUserDefaults standardUserDefaults] objectForKey:kProfileUpdatedOn] longLongValue];
//    }
//
//    if (newTimestampOfProfileTags > oldTimestamoOfProfileTags || ![[NSUserDefaults standardUserDefaults] boolForKey:kFirstTimeProfileOptionsFetched] || [[NSUserDefaults standardUserDefaults] boolForKey:kFirstTimeProfileOptionsFetched] == FALSE) {
//
//        NSString *postQuestionURL = [NSString stringWithFormat:@"%@%@?wooUserId=%lld",kBaseURLV5,kGetUserProfileTags,[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue]];
//
//        WooRequest *wooRequestObj = [[WooRequest alloc]init];
//        wooRequestObj.url =postQuestionURL;
//        wooRequestObj.time =0;
//        wooRequestObj.requestParams =nil;
//        wooRequestObj.methodType =getRequest;
//        wooRequestObj.numberOfRetries =3;
//        wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
//        wooRequestObj.requestType = getUserProfileTagsData;
//
//        [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
//
//
//            if (success && requestType == getUserProfileTagsData) {
//
//                NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
//                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",timestamp] forKey:kProfileUpdatedOn];
//
//                NSMutableDictionary *profileData = [response mutableCopy];
//
//                [[NSUserDefaults standardUserDefaults] setObject:profileData forKey:kUserProfileDataKey];
//                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%lld",newTimestampOfProfileTags] forKey:kProfileUpdatedOn];
//                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFirstTimeProfileOptionsFetched];
//                [[NSUserDefaults standardUserDefaults] synchronize];
//
//            }
//        } shouldReachServerThroughQueue:TRUE];
//    }
//}


-(NSString *)getDateStringForTimeInterval:(long long)timeInterVal withDateFormatting:(NSString *)dateFormattingStrng{
    NSString *dateString = nil;
    
    NSDate *dateFromTimeStamp = [NSDate dateWithTimeIntervalSince1970:timeInterVal];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormattingStrng];
    dateString = [dateFormatter stringFromDate:dateFromTimeStamp];
    
    return dateString;
}

-(NSString *)getDateStringForDate:(NSDate *)dateVal forDateFormate:(NSString *)dateFromate{
    NSString *dateString = nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFromate];
    dateString = [dateFormatter stringFromDate:dateVal];
    return dateString;
}

- (NSString*) convertDictionaryToString:(NSMutableDictionary*) dict{
    NSError* error;
    NSDictionary* tempDict = [dict copy]; // get Dictionary from mutable Dictionary
    //giving error as it takes dic, array,etc only. not custom object.
    // #TO_BE_ENCODED
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:tempDict
                                                       options:NSJSONReadingMutableLeaves error:&error];
    NSString* nsJson=  [[NSString alloc] initWithData:jsonData
                                             encoding:NSUTF8StringEncoding];
    return nsJson;
}
-(NSDictionary *)convertStringToDictionary:(NSString *)jsonString{
    NSError *jsonError;
    // #TO_BE_ENCODED
    NSData *objectData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&jsonError];
    return json;
}




//move all these method to layerChatHelperClass
-(void)uploadPicAndShowProgressForCell:(SenderImageCell *)chatImageCellObj withCircularProgressView:(EditProfileProgressbar *)progressViewObj forChatMessage:(ChatMessage *)chatMessageObj{
    
    //    [modelName rangeOfString:@"iPhone3"].location != NSNotFound)
    
    NSLog(@"progressViewObj :%@",progressViewObj);
    
    if ([chatMessageObj.message rangeOfString:@"wooTempImage"].location != NSNotFound) {
        NSString *cacheDirectory = [NSString stringWithFormat:@"%@/%@",[APP_Utilities applicationCacheDirectory],kSelfieImagesFolderName];
        NSString *getImagePath = [cacheDirectory stringByAppendingPathComponent:chatMessageObj.message];
        UIImage *img = [UIImage imageWithContentsOfFile:getImagePath];
        
        NSString *oldImagePath = [cacheDirectory stringByAppendingPathComponent:chatMessageObj.message];
        
        //    if (![chatMessageObj.ifchatImageIsItUploaded boolValue]) {
        
        CGSize imageSize = img.size;
        float red = 720.0/imageSize.width;
        CGSize compressedSize = CGSizeMake(imageSize.width*red, imageSize.height*red);
        UIGraphicsBeginImageContext( compressedSize );
        [img drawInRect:CGRectMake(0,0,compressedSize.width,compressedSize.height)];
        UIImage* newCompresssedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData *imageDataAfterCompressed = UIImageJPEGRepresentation(newCompresssedImage,0);
        
        float imaegSizeVal = imageDataAfterCompressed.length;
        if (imaegSizeVal<1) {
            return;
        }
        
        NSString *uploadImageUrl = [NSString stringWithFormat:@"%@%@?wooId=%@",kBaseURLV3,kUploadPictures,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
        [[APIQueue sharedAPIQueue] uploadAnyFileOnServer:uploadImageUrl
                                    withBinaryDataOfFile:imageDataAfterCompressed
                                          withRetryCount:3
                                 withDoYouWantToUseQueue:YES
                                       withCachingPolicy:GET_DATA_FROM_URL_ONLY
                                            withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
                                                NSLog(@"success : %d",success);
                                                NSLog(@"response : %@",response);
                                                NSLog(@"error : %@",error);
                                                NSLog(@"statusCode : %d",statusCode);
                                                if(success){
                                                    [ChatMessage updateDeliveryStatusOfImage:chatMessageObj.clientMessageID withChatMessage:[response objectForKey:@"photoUrl"]];
                                                    [ChatMessage updateImageSizeOfImageChat:imaegSizeVal forChatId:chatMessageObj.clientMessageID withUpdationHandler:^(BOOL success) {
                                                        [self sendImage:[response objectForKey:@"photoUrl"] forChatRoom:chatMessageObj.chatRoomID withChatObject:chatMessageObj withImageSize:imaegSizeVal];
                                                        NSString *newImageName = [[[response objectForKey:@"photoUrl"] componentsSeparatedByString:@"/"] lastObject];
                                                        NSString *newImagePath = [cacheDirectory stringByAppendingPathComponent:newImageName];
                                                        [APP_Utilities renameFilePresentAtPath:oldImagePath withNewFilePath:newImagePath];
                                                    }];
                                                    //                [APP_Utilities deleteFileAtPath:getImagePath];
                                                    //                [progressViewObj removeFromSuperview];
                                                    //                progressViewObj.hidden = TRUE;
                                                }
                                                
                                            } withKindOfRequest:uploadPictureToServer andKindOfFileImage:TRUE withProgress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
                                                NSLog(@"Wrote========== %lld/%lld", totalBytesWritten, totalBytesExpectedToWrite);
                                                float received = (float )totalBytesWritten;
                                                float expected = (float )totalBytesExpectedToWrite;
                                                NSLog(@"percent :%f",received/expected);
                                                progressViewObj.progressValue = (received/expected)*100;
                                            } andImageTemporaryName:chatMessageObj.message];
    }
    else{
        [self sendImage:chatMessageObj.message forChatRoom:chatMessageObj.chatRoomID withChatObject:chatMessageObj withImageSize:[chatMessageObj.imageSize floatValue]];
        //        [progressViewObj removeFromSuperview];
        //        progressViewObj.hidden = TRUE;
    }
    
    
    //    }
}

- (void)sendImage:(NSString *)messageText forChatRoom:(NSString *)chatRoomId withChatObject:(ChatMessage *)chatObj withImageSize:(float)imageSize{
    //FIXREQUIRED: There is an overhead here for fetching mymatches object. See if you can pass MyMatch object from the newchat controller, don’t worry if you need to make a global object in LayerChatManager or you need to pass through couple of methods. Because, mymatch object already has a status of flagging, but if you try to retrieve flag status from db on every upload image, it will slows down the app performance.
    
    __weak  MyMatches * matchObj = [MyMatches getMatchDetailForMatchedUSerID:chatRoomId isApplozic:false];
    
//    [[LayerManager sharedLayerManager] getConversationObjectForLayerConversationId:matchObj.layerChatID withCompletionHandler:^(BOOL isSyncCompleted, id  _Nullable conversation, NSError *error) {
//        if(conversation != nil)
//        {
//            LYRConversation *conversationObj = (LYRConversation *)conversation;
//            NSDictionary *msgDict = @{@"imageurl":messageText,@"imagesize":chatObj.imageSize,@"imagetype":@"Image"};
//            NSString *msgStr = [APP_Utilities convertDictionaryToString:(NSMutableDictionary *)msgDict];
//            if(matchObj.isRequesterFlagged != nil )
//            {
//                [[LayerManager sharedLayerManager] sendChatToLayer:msgStr ForMimeType:MIME_TYPE_APPLICATION_JSON withPushText:kImageText forConversation:conversationObj isRequesterFlagged:matchObj.isRequesterFlagged.boolValue chatSendToLayerCompletion:^(BOOL chatSendSuccessFully, LYRMessage *layerMessageObj) {
//                    if (chatObj) {
//                        [self updateLayerIdOfChatObject:chatObj withLayerId:layerMessageObj];
//                    }
//                    [LAYER_HELPER insertLayerChatFromToLocalDB:layerMessageObj withCompletionHandler:^(ChatMessage *chatMessageObj) {
//
//                    }];
//                }];
//            }
//
//        }
//    }];
    //    static NSString *const MIMETypeApplicationJSON = MIME_TYPE_APPLICATION_JSON;
    
    
}

//-(void)updateLayerIdOfChatObject:(ChatMessage *)chatMessageObj withLayerId:(LYRMessage *)layerMessageObj{
//    NSString *receiverPresonId = @"";
//    for (LYRIdentity *participant in layerMessageObj.conversation.participants) {
//        if (![layerMessageObj.sender.userID isEqualToString:participant.userID]) {
//            receiverPresonId = participant.userID;
//        }
//    }
//    [ChatMessage updateLayerIdOfChatMessageWithLayerId:layerMessageObj.identifier.lastPathComponent andDeliveryStatus:[NSNumber numberWithInt:[layerMessageObj recipientStatusForUserID:receiverPresonId]] forChatObject:chatMessageObj withUpdationHandler:nil];
//}

//-(void)insertLayerChatIntoLocalDB:(LYRMessage *)messageObj forChatMessage:(ChatMessage *)chatObj{
//
//    if (!messageObj.sender | [messageObj.conversation isEqual:[NSNull null]] | !messageObj.conversation) {
//        return;
//    }
//    /Users/ankitbatra/Woo-client-iOS/Woo_v2.x/Woo_v2/Utilities/Utilities.m://-(void)insertLayerChatIntoLocalDB:(LYRMessage *)messageObj forChatMessage:(ChatMessage *)chatObj{
//    LYRMessagePart *messagePart = messageObj.parts[0];
//    // text
//    NSString *enterText = [[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding];
//    NSString *imageSizeText = @"";
//    if ([messagePart.MIMEType isEqualToString:MIME_TYPE_APPLICATION_JSON]) {
//        NSDictionary *msgJson = [APP_Utilities convertStringToDictionary:enterText];
//        enterText = [msgJson objectForKey:@"imageurl"];
//        imageSizeText = [msgJson objectForKey:@"imagesize"];
//    }
//    //    NSLog(@"reciepeintDict: %@",reciepeintDict);
//
//    //    NSLog(@"message text : %@",enterText);
//
//
//
//
//    NSDate* datetime = [NSDate date];
//    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]]; // Prevent adjustment to user's local time zone.
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS z"];
//    //    NSString* gmtTime = [dateFormatter stringFromDate:datetime];
//
//    if (enterText == nil  && [enterText length]<1 ) {
//        enterText = @"";
//    }
//
//    NSTimeInterval currentDate = [datetime timeIntervalSince1970]*1000;
//    if (messageObj.sentAt) {
//        currentDate = [messageObj.sentAt timeIntervalSince1970]*1000;
//    }
//    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
//    [dictionary setObject:chatObj.clientMessageID forKey:kChatMessageIDKey];
//    [dictionary setObject:chatObj.messageType forKey:kMessageTypeKey];
//
//    [dictionary setObject:enterText forKey:kMessageKey];
//    [dictionary setObject:[NSNumber numberWithBool:TRUE] forKey:kIsDeliveredKey];
//
//    [dictionary setObject:@"" forKey:kServerMessageID];
//    [dictionary setObject:imageSizeText forKey:kImageSize];
//
//    [dictionary setObject:messageObj.identifier.lastPathComponent forKeyedSubscript:kChatMessageLayerID];
//    //    [dictionary setObject:[NSNumber numberWithInt:] forKeyedSubscript:kChatMessageDeliveryLayerStatus];
//
//
//    NSString *participantId = nil;
//    NSString *reciverId = nil;
//    for (NSString *participant in messageObj.conversation.participants) {
//        if (![participant isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]]) {
//            participantId = participant;
//        }
//        if (![participant isEqualToString:messageObj.sender.userID]) {
//            reciverId = participant;
//        }
//    }
//
//
//
//
//    if ([messageObj.sender.userID isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]]) {
//        //I am sender I am god here... :)
//        [dictionary setObject:messageObj.sender.userID forKey:kMessageSenderIDKey];
//        [dictionary setObject:chatObj.chatRoomID forKey:kChatRoomIDKey];
//        [dictionary setObject:chatObj.chatRoomID forKey:kMessageReceiverID];
//        [dictionary setObject:[NSNumber numberWithInt:[messageObj recipientStatusForUserID:chatObj.chatRoomID]] forKeyedSubscript:kChatMessageDeliveryLayerStatus];
//    }
//    else{
//        // I am reciever here Still I am god here :)
//        [dictionary setObject:messageObj.sender.userID forKey:kMessageSenderIDKey];
//        [dictionary setObject:chatObj.chatRoomID forKey:kChatRoomIDKey];
//        [dictionary setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] forKey:kMessageReceiverID];
//        [dictionary setObject:[NSNumber numberWithInt:[messageObj recipientStatusForUserID:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]]] forKeyedSubscript:kChatMessageDeliveryLayerStatus];
//
//    }
//    [dictionary setObject:[NSNumber numberWithLongLong:currentDate] forKey:kChatMessageCreatedTime];
//    NSLog(@"");
////    ChatMessage *chatObjU = [ChatMessage insertMessageIntoDatabaseFromLayer:dictionary andAlsoMarkChatRoomAsRead:TRUE];
//    [ChatMessage insertImageMessageIntoDatabaseFromLayer:dictionary andAlsoMarkChatRoomAsRead:TRUE withMimeType:messagePart];
//
//}

//-(LYRConversation *)getConversationObjectForConversationID:(NSString *)conversationID{
//    NSURL *conversationIdentifier = [NSURL URLWithString:conversationID];
//    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
//    query.predicate = [LYRPredicate predicateWithProperty:@"identifier" predicateOperator:LYRPredicateOperatorIsEqualTo value:conversationIdentifier];
//    query.limit = 1;
//    NSError *error = nil;
//    NSOrderedSet *conversations = [APP_DELEGATE.layerClient executeQuery:query error:&error];
//    if ([conversations count] == 1) {
//        // Push on your Conversation view and you can start chatting
//        return [conversations lastObject];
//    }
//    return nil;
//}



-(NSString *)returnDateStringOfTimestamp:(NSDate *)convertedDate {
    
    NSDate *todayDate = [NSDate date];
    int ti = [todayDate timeIntervalSinceDate:convertedDate];
    if (ti<0) {
        ti = 0;
    }
    
    if (ti < 60) {
        if (ti < 2) {
            return [NSString stringWithFormat:@"%d sec",ti];
        }
        return [NSString stringWithFormat:@"%d secs",ti];
        
    } else if (ti < 3600) {
        
        int diff = round(ti / 60);
        if (diff < 2) {
            return [NSString stringWithFormat:@"%d min", diff];
        }
        return [NSString stringWithFormat:@"%d mins", diff];
        
    } else if (ti < 86400) {
        
        int diff = round(ti / 60 / 60);
        if (diff < 2) {
            return[NSString stringWithFormat:@"%d hr", diff];
        }
        return[NSString stringWithFormat:@"%d hrs", diff];
        
    } else if (ti < 2592000) {
        
        int diff = round(ti / 60 / 60 / 24);
        if (diff < 2) {
            return [NSString stringWithFormat:@"%d day", diff];
        }
        return [NSString stringWithFormat:@"%d days", diff];
        
    } else{
        int diff = round(ti / 60 / 60 / 24 / 30);
        if (diff < 2) {
            return [NSString stringWithFormat:@"%d month", diff];
        }
        return [NSString stringWithFormat:@"%d months", diff];
    }
    
}




//-(void)alertShowing:(NSString *)Title messageString: (NSString *)MessageString{
//
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:Title message:MessageString preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
//    [alertController addAction:ok];
//
//    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
//    while (topController.presentedViewController) {
//        topController = topController.presentedViewController;
//    }
//    [topController presentViewController:alertController animated:YES completion:nil];
//
//}


-(BOOL)isIndianUser{
    
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    NSString *countrycode = [carrier isoCountryCode];
    NSString *mcc = [carrier mobileCountryCode];
    [[NSUserDefaults standardUserDefaults] setValue:mcc forKey:kMcc];
    NSString *mnc = [carrier mobileNetworkCode];
    [[NSUserDefaults standardUserDefaults] setValue:mnc forKey:kMnc];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
    NSString *countryCodeLocal = [currentLocale objectForKey:NSLocaleCountryCode];
    
    if([countrycode isEqualToString:@"in"]){
        if([countryCodeLocal isEqualToString:@"IN"]){
            
            return YES;
        }else{
            
            return NO;
        }
        
    }else if(countrycode == nil){
        if([countryCodeLocal isEqualToString:@"IN"]){
            
            return YES;
        }else{
            
            return NO;
        }
    }else{
        return NO;
    }
    
    return NO;
    
}

-(ScreenOpenNotificationType )getScreenToBeOpenedFromNotificationString:(NSString *)redirectionString{
    
    if ([redirectionString isEqualToString:@"MY_PROFILE"]) {
        
        return ScreenOpenNotificationTypeMyProfile;
        
    }else if ([redirectionString isEqualToString:@"DISCOVER"]){
        
        return ScreenOpenNotificationTypeDiscover;
        
    }else if ([redirectionString isEqualToString:@"MATCHES"]){
        
        return ScreenOpenNotificationTypeMatchbox;
        
    }else if ([redirectionString isEqualToString:@"QUESTIONS"]){
        
        return ScreenOpenNotificationTypeQuestions;
        
    }else if ([redirectionString isEqualToString:@"NOTIFICATIONS"]){
        
        return ScreenOpenNotificationTypeNotificaions;
        
    }else if ([redirectionString isEqualToString:@"INVITE_FRIENDS"]){
        
        return ScreenOpenNotificationTypeInvite;
        
    }else if ([redirectionString isEqualToString:@"SETTINGS"]){
        
        return ScreenOpenNotificationTypeSettings;
        
    }else if ([redirectionString isEqualToString:@"PURCHASES"]){
        
        return ScreenOpenNotificationTypePurchases;
    }
    return ScreenOpenNotificationTypeUnknown;
    
}

-(NSMutableArray *)getArrayAfterFiltering:(NSArray *)arrayToBeFiltered forKey:(NSString *)keyVal andForValue:(NSString *)value{
    NSMutableArray *filteredArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *objectDetail in arrayToBeFiltered) {
        //        NSLog(@"tag id :%@",[NSString stringWithFormat:@"%@",[objectDetail objectForKey:keyVal]]);
        if ([objectDetail objectForKey:keyVal] && [[NSString stringWithFormat:@"%@",[objectDetail objectForKey:keyVal]] isEqualToString:value]) {
            [filteredArray addObject:objectDetail];
        }
    }
    return filteredArray;
}

-(NSMutableArray *)getArrayAfterFiltering:(NSArray *)arrayToBeFiltered forKey:(NSString *)keyVal andForTagTypeKey:(NSString *)tagTaypeKey andForTagDetail:(NSDictionary *)tagDetail{
    //    NSLog(@"tagDetail :%@",tagDetail);
    NSString *selectedTagId = [NSString stringWithFormat:@"%@",[tagDetail objectForKey:keyVal]];
    NSString *selectedTagType = [NSString stringWithFormat:@"%@",[tagDetail objectForKey:tagTaypeKey]];
    
    NSMutableArray *filteredArray = [[NSMutableArray alloc] init];
    for (NSDictionary *objectDetail in arrayToBeFiltered) {
        NSString *currentTagId = [NSString stringWithFormat:@"%@",[objectDetail objectForKey:keyVal]];
        NSString *currentTagType = [NSString stringWithFormat:@"%@",[objectDetail objectForKey:tagTaypeKey]];
        
        
        //        NSLog(@"objectDetail :%@",objectDetail);
        //        NSLog(@"tagDToType :%d",[currentTagType isEqualToString:selectedTagType]);
        //        NSLog(@"tagId :%d",[currentTagId isEqualToString:selectedTagId]);
        
        if ([objectDetail objectForKey:keyVal] && [currentTagId isEqualToString:selectedTagId] && [currentTagType isEqualToString:selectedTagType]) {
            
            NSMutableDictionary *tagDetailM = [[NSMutableDictionary alloc] initWithDictionary:objectDetail];
            if (![[tagDetailM allKeys] containsObject:@"name"]) {
                [tagDetailM setObject:[tagDetail objectForKey:@"name"] forKey:@"name"];
            }
            
            if ([[objectDetail allKeys] containsObject:kIsTaggable]) {
                [tagDetailM setObject:[tagDetail objectForKey:kIsTaggable] forKey:kIsTaggable];
            }
            
            if ([[objectDetail allKeys] containsObject:kIsCommon]) {
                [tagDetailM setObject:[tagDetail objectForKey:kIsCommon] forKey:kIsCommon];
            }
            
            [filteredArray addObject:tagDetailM];
        }
    }
    return filteredArray;
}

-(NSString *)getBadgeTextForMatchboxButton{
    int totalUnseenChatrooms = 0;
    int totalUnreadAnswers = 0;
    
    totalUnseenChatrooms = [MyMatches getCountOfUnreadChatrooms];
    totalUnreadAnswers = [MyQuestions getTotalUnreadAnswersCount];
    
    if (totalUnreadAnswers+totalUnseenChatrooms > 9) {
        return @"9+";
    }
    return [NSString stringWithFormat:@"%d",(totalUnseenChatrooms + totalUnreadAnswers)];
}

-(BOOL)isitAniPhone5{
    return CGSizeEqualToSize([[UIScreen mainScreen] preferredMode].size,CGSizeMake(640, 1136));
}
-(BOOL)isitAniPhone4{
    return IS_IPHONE_4;
}
-(BOOL)checkIfPushNotificationIsEnabled{
    BOOL isPushEnabled = FALSE;
    
    if ([self returnOSVersion]>=8.0) {
        isPushEnabled = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
        if (isPushEnabled) {
            NSUInteger notificationType = [UIApplication sharedApplication].currentUserNotificationSettings.hash;
            if (notificationType == 0) {
                isPushEnabled = FALSE;
            }
            else{
                isPushEnabled = TRUE;
            }
        }
    }
    return isPushEnabled;
    
}



-(UIImage *)getSameGenderPlaceholder{
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserGender] isEqualToString:@"MALE"]) {
        
        return [UIImage imageNamed:@"placeholder_male"];
    }
    return [UIImage imageNamed:@"placeholder_female"];
    
}

-(UIImage *)getOppositeGenderPlaceholder{
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserGender] isEqualToString:@"MALE"]) {
        return [UIImage imageNamed:@"placeholder_female"];
    }
    return [UIImage imageNamed:@"placeholder_male"];
}
-(BOOL)isUserAlreadyMyMatche:(NSString *)userWooId{
    BOOL isUserAlreadyMatchedWithMe = FALSE;
    if ([MyMatches getMatchDetailForMatchedUSerID:userWooId isApplozic:false]) {
        isUserAlreadyMatchedWithMe = TRUE;
    }
    return isUserAlreadyMatchedWithMe;
}

-(void)deleteAudioFolder{
    NSString *audioFolderPath = [NSString stringWithFormat:@"%@/%@",[APP_Utilities applicationCacheDirectory],@"audio"];
    //    NSURL *url = [[NSURL alloc] initWithString:audioFolderPath];
    BOOL isDir = TRUE;
    NSError *errorObj;
    if ([[NSFileManager defaultManager] fileExistsAtPath:audioFolderPath isDirectory:&isDir]) {
        [[NSFileManager defaultManager] removeItemAtPath:audioFolderPath error:&errorObj];
    }
    
}
-(void)deleteImageFolder{
    NSString *audioFolderPath = [NSString stringWithFormat:@"%@/%@",[APP_Utilities applicationCacheDirectory],kSelfieImagesFolderName];
    //    NSURL *url = [[NSURL alloc] initWithString:audioFolderPath];
    BOOL isDir = TRUE;
    NSError *errorObj;
    if ([[NSFileManager defaultManager] fileExistsAtPath:audioFolderPath isDirectory:&isDir]) {
        [[NSFileManager defaultManager] removeItemAtPath:audioFolderPath error:&errorObj];
    }
    
}
-(void)deleteImageAndAudioFolder{
    [self deleteImageFolder];
    [self deleteAudioFolder];
}

-(BOOL)isValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}



-(NSString *)createHashedTokenForTimestamp:(NSString *)timestamp{
    
    NSString *token;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kWooEncryptionTokenFromServer]) {
        token =[[NSUserDefaults standardUserDefaults] objectForKey:kWooEncryptionTokenFromServer];
    }else{
        return @"";
    }
    
    //    token = @"dd5235dd-46c0-4edb-af57-c218cc7d47f5";
    
    //    Token converted to NSData 1
    NSData *tokenData = [token dataUsingEncoding:NSASCIIStringEncoding];
    
    //    Token encrypted 2
    NSData *tokenEncryptedData = [tokenData AES128EncryptedDataWithKey:timestamp];
    
    //    base 64 calculated and changed to nsstring 3
    NSString *base64Encoded = [tokenEncryptedData base64EncodedStringWithOptions:0];
    
    return base64Encoded;
    
    
}

-(void)makeSilentLoginCallToFetchWooSecurityToken{
    //    [APP_Utilities showActivityIndicator];
    if ([FBSession activeSession].accessTokenData && [[NSUserDefaults standardUserDefaults] objectForKey:kFacebookNumbericUserID]) {
        //    NSDictionary *parmaValues = [notificationObj userInfo];
        NSTimeZone *timeZone = [NSTimeZone localTimeZone];      //getting time zone
        
        NSInteger gmtTime = [timeZone secondsFromGMT];  //getting the difference between user time zone and GMT
        
        NSString *language = [APP_Utilities getDeviceLanguageString];   //User default language
        NSString *locale = [APP_Utilities getDeviceLocaleCode];
        NSString *udid = [NSString stringWithFormat:@"%@",[[UIDevice currentDevice] identifierForVendor].UUIDString];   //getting user vendor ID, (device UDID is no longer used)
        
        NSDictionary *params = @{@"userId":[[NSUserDefaults standardUserDefaults] objectForKey:kFacebookNumbericUserID],
                                 @"access_token":[FBSession activeSession].accessTokenData,
                                 @"gmtTime":[NSString stringWithFormat:@"%ld",(long)gmtTime],
                                 @"language":language,
                                 @"locale":locale,
                                 @"deviceId":udid,
                                 @"appVersion":[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
                                 @"deviceType":kDeviceType
                                 };
        NSString *loginURL = [NSString stringWithFormat:@"%@%@",kLoginURLV4_HTTPS,kLoginCall];
        
        WooRequest *wooRequestObj = [[WooRequest alloc]init];
        wooRequestObj.url =loginURL;
        wooRequestObj.time =0;
        wooRequestObj.requestParams =params;
        wooRequestObj.methodType =postRequest;
        wooRequestObj.numberOfRetries =3;
        wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
        wooRequestObj.requestType = registerUserToServer;
        NSLog(@"params : %@",params);
        
        [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
            
            if (requestType == registerUserToServer) {
                NSLog(@"response in make login call - util:%@",response);
                if (success) {
                    
                    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kIsUpdateVersion2_1];
                    
                    if ([response objectForKey:kWooEncryptionTokenFromServer]) {
                        
                        [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:kWooEncryptionTokenFromServer] forKey:kWooEncryptionTokenFromServer];
                        
                    }
                    
                    NSUserDefaults *userDefaultObj = [NSUserDefaults standardUserDefaults];
                    NSLog(@"[userDefaultObj objectForKey:kWooUserId] :%@",[userDefaultObj objectForKey:kWooUserId]);
                    if (![[NSString stringWithFormat:@"%@",[response objectForKey:@"id"]] isEqualToString:[userDefaultObj objectForKey:kWooUserId]]) {
                        [APP_DELEGATE reinitialiseUserDefaultAndDatabase];
                    }
                    
                    
                    if ([response objectForKey:kWooToken]) {
                        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",[response objectForKey:kWooToken]] forKey:kWooToken];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                    }
                    
                    [userDefaultObj setObject:[NSString stringWithFormat:@"%@",[response objectForKey:@"id"]] forKey:kWooUserId];
                    
                    [userDefaultObj setObject:[APP_Utilities validString:[NSString stringWithFormat:@"%@",[response objectForKey:@"firstName"]]] forKey:kWooUserName];
                    [userDefaultObj setObject:[APP_Utilities validString:[[NSUserDefaults standardUserDefaults] objectForKey:kFacebookNumbericUserID]] forKey:kFacebookNumbericUserID];
                    [userDefaultObj setObject:[APP_Utilities validString:[NSString stringWithFormat:@"%@",[response objectForKey:@"profilePicUrl"]]] forKey:kWooProfilePicURL];
                    [userDefaultObj setObject:[response objectForKey:kProfileCompletenessScoreKey] forKey:kProfileCompletenessScoreKey];
                    
                    [userDefaultObj setObject:[response objectForKey:@"age"] forKey:kAgeFromServer];
                    [userDefaultObj setObject:[response objectForKey:kMinAgePreference] forKey:kMinAgePreference];
                    [userDefaultObj setObject:[response objectForKey:kMaxAgePreference] forKey:kMaxAgePreference];
                    [userDefaultObj setObject:[response objectForKey:kGenderPreference] forKey:kGenderPreference];
                    [userDefaultObj setObject:[response objectForKey:kGenderKey] forKey:kWooUserGender];
                    
                    //Added by Umesh : to save sound preference : on 19 Sept, 2104
                    //$$$LUV***
                    //Uncomment below two user default when
                    
                    
                    [userDefaultObj setBool:([[response objectForKey:@"chatSoundOn"] boolValue]?TRUE:FALSE) forKey:kMessagesSoundPreference];
                    [userDefaultObj setBool:([[response objectForKey:@"otherSoundOn"] boolValue]?TRUE:FALSE) forKey:kMatchesSoundPreferences];
                    //End here
                    [userDefaultObj synchronize];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInSuccessfullyNotification object:nil];
                    [APP_DELEGATE sendSwrveEventWithEvent:@"FBLogin.Success" andScreen:@"FBLogin"];
                    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"Success" forScreenName:@"Login"];
                    // NSString *url = [[NSUserDefaults standardUserDefaults]objectForKey:kWooProfilePicURL];
                    
                    /*
                     NSString *imageURL = nil;
                     if([[APP_Utilities validString:url] length]>0){
                     imageURL = [NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(100),IMAGE_SIZE_FOR_POINTS(100), [APP_Utilities encodeFromPercentEscapeString:url]];
                     }
                     
                     */
                    
                    BOOL alreadyRegistered = [[response objectForKey:@"confirmed"] boolValue];
                    if(alreadyRegistered){
                        
                    }else{
                        if ([response objectForKey:kIsFakeDtoInLoginKey]) {
                            [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:kIsFakeDtoInLoginKey] forKey:kIsFakeDtoInLoginKey];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        }
                    }
                }
                else{
                    //Error handling
                }
            }
            
        }  shouldReachServerThroughQueue:TRUE];
    }
}


-(void)updatePendingFavListWithMatchID:(NSString *)favMatchID{
    
    NSString *favList = @"";
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kPendingFavListKey]) {
        favList = [[NSUserDefaults standardUserDefaults] objectForKey:kPendingFavListKey];
    }
    
    NSMutableArray *favArray = [[NSMutableArray alloc] init];
    
    if ([favList length] > 0) {
        favArray = [[favList componentsSeparatedByString:@","] mutableCopy];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kPendingUnFavListKey]) {
        
        NSString *unfavString = [[NSUserDefaults standardUserDefaults] objectForKey:kPendingUnFavListKey];
        NSMutableArray *newUnfavArray = [[unfavString componentsSeparatedByString:@","] mutableCopy];
        if ([newUnfavArray containsObject:favMatchID]) {
            [newUnfavArray removeObject:favMatchID];
            NSString *newUnfav = [newUnfavArray componentsJoinedByString:@","];
            
            [[NSUserDefaults standardUserDefaults] setObject:newUnfav forKey:kPendingUnFavListKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            return;
        }
    }
    
    
    [favArray addObject:favMatchID];
    
    //favList = @"";
    
    favList = [favArray componentsJoinedByString:@","];
    
    [[NSUserDefaults standardUserDefaults] setObject:favList forKey:kPendingFavListKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(void)updatePendingUnFavListWithMatchID:(NSString *)unFavMatchID{
    
    NSString *unFavList = @"";
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kPendingUnFavListKey]) {
        unFavList = [[NSUserDefaults standardUserDefaults] objectForKey:kPendingUnFavListKey];
    }
    
    NSMutableArray *unFavArray = [[NSMutableArray alloc] init];
    
    if ([unFavList length] > 0) {
        unFavArray = [[unFavList componentsSeparatedByString:@","] mutableCopy];
    }
    
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kPendingFavListKey]) {
        
        NSString *favString = [[NSUserDefaults standardUserDefaults] objectForKey:kPendingFavListKey];
        NSMutableArray *newfavArray = [[favString componentsSeparatedByString:@","] mutableCopy];
        if ([newfavArray containsObject:unFavMatchID]) {
            [newfavArray removeObject:unFavMatchID];
            NSString *newfav = [newfavArray componentsJoinedByString:@","];
            
            [[NSUserDefaults standardUserDefaults] setObject:newfav forKey:kPendingFavListKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            return;
        }
    }
    
    
    [unFavArray addObject:unFavMatchID];
    
    // unFavList = @"";
    
    unFavList = [unFavArray componentsJoinedByString:@","];
    
    [[NSUserDefaults standardUserDefaults] setObject:unFavList forKey:kPendingUnFavListKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}


#pragma mark - Getting Width & Height OF UILabel Text
-(CGSize)getTextWidthHeight: (id)sender{
    CGSize expectedLabelSize;
    
    
    if ([sender isKindOfClass:[UILabel class]]) {
        
        UILabel *lblValue = (UILabel *)sender;
        
        CGSize maximumLabelSize = CGSizeMake(296,9999);
        
        expectedLabelSize = [lblValue.text sizeWithFont:lblValue.font
                                      constrainedToSize:maximumLabelSize
                                          lineBreakMode:NSLineBreakByWordWrapping];
        
    } else     if ([sender isKindOfClass:[UIButton class]]) {
        
        UIButton *btnValue = (UIButton *)sender;
        
        CGSize maximumLabelSize = CGSizeMake(296,9999);
        
        expectedLabelSize = [btnValue.titleLabel.text sizeWithFont:btnValue.font
                                                 constrainedToSize:maximumLabelSize
                                                     lineBreakMode:NSLineBreakByWordWrapping];
        
    }
    
    
    
    
    return expectedLabelSize;
    
    
}

#pragma mark - isKeyExist Method
-(BOOL)isKeyExist:(NSDictionary *)dict withKey : (NSString *)str_key{
    
    BOOL flag = false;
    
    if ([dict objectForKey:str_key])
        flag = true;
    else
        flag = false;
    
    return flag;
}


-(void) showToastWithText:(NSString *)text;{
    //    toast = [[MDToast alloc]
    //                      initWithText:text
    //                      duration:kMDToastDurationShort];
    //    [toast show];
    
    toast = [WooToast sharedInstance];
    [toast showWithText:text duration:kWooToastDurationShort];
}

- (void)removeToast
{
    if (toast.isShowing) {
        [toast dismiss];
    }
}
///method to get first part of message that is displayed on loader view when user is performing tag search
-(NSString *)getFirstMessageOnLoaderScreenForTagType:(NSString *)tagType{
    NSString *messageStr = @"";
    if ([tagType isEqualToString:@"USER_WORK_AS"] || [tagType isEqualToString:@"USER_HOMETOWN"] || [tagType isEqualToString:@"USER_WORK_AREA"] || [tagType isEqualToString:@"USER_WORK"] || [tagType isEqualToString:@"USER_HOME_TOWN"]) {
        messageStr = NSLocalizedString(@"Searching for people from", nil) ;
    }
    else if ([tagType isEqualToString:@"USER_EDUCATION"]){
        messageStr = NSLocalizedString(@"Searching for people who studied at", nil) ;
    }
    else if ([tagType isEqualToString:@"USER_STUDIED"]){
        messageStr = NSLocalizedString(@"Searching for people who studied", nil);
    }
    else if ([tagType isEqualToString:@"USER_RELIGION"]){
        messageStr = NSLocalizedString(@"Searching for people whose religion is set to", nil);
    }
    else if ([tagType isEqualToString:@"USER_LIFESTYLE"]){
        messageStr = NSLocalizedString(@"Searching for people whose preference is", nil);
    }
    else if ([tagType isEqualToString:@"USER_PASSION"] || [tagType isEqualToString:@"USER_INTEREST"]){
        messageStr = NSLocalizedString(@"Searching for", nil);
    }
    else if ([tagType isEqualToString:@"USER_RELATIONSHIP_STATUS"]){
        messageStr = NSLocalizedString(@"Searching for people who are", nil);
    }
    else{
        messageStr = NSLocalizedString(@"Searching for people who like", nil);
    }
    return messageStr;
}

///method to get first of message that is displared on leaser view when user performs a tag search and no profile is found.
-(NSString *)getNoMorePeopleTextForTagType:(NSString *)tagType{
    NSString *messageStr = @"";
    if ([tagType isEqualToString:@"USER_WORK_AS"] || [tagType isEqualToString:@"USER_HOMETOWN"] || [tagType isEqualToString:@"USER_WORK_AREA"] || [tagType isEqualToString:@"USER_WORK"]) {
        messageStr = NSLocalizedString(@"CDI0058", nil) ;
    }
    else if ([tagType isEqualToString:@"USER_EDUCATION"]){
        messageStr = NSLocalizedString(@"CDI0055", nil) ;
    }
    else if ([tagType isEqualToString:@"USER_STUDIED"]){
        messageStr = NSLocalizedString(@"CDI0056", nil);
    }
    else if ([tagType isEqualToString:@"USER_RELIGION"]){
        messageStr = NSLocalizedString(@"CDI0060", nil);
    }
    else if ([tagType isEqualToString:@"USER_LIFESTYLE"]){
        messageStr = NSLocalizedString(@"No more people whose preference is", nil);
    }
    else if ([tagType isEqualToString:@"USER_PASSION"] || [tagType isEqualToString:@"USER_INTEREST"]){
        messageStr = NSLocalizedString(@"CDI0054", nil);
    }
    else if ([tagType isEqualToString:@"USER_RELATIONSHIP_STATUS"]){
        messageStr = NSLocalizedString(@"CDI0059", nil);
    }
    else{
        messageStr = NSLocalizedString(@"CDI0057", nil);
    }
    return messageStr;
}

-(void)deleteMatchUserFromAppExceptMatchBox:(NSString *)userId shouldDeleteFromAnswer:(BOOL)isdelete withCompletionHandler:(DeletionCompletionHandler __nullable)completionHandler{
    
    
    [self deleteMatchUserFromAppExceptMatchBoxData:userId shouldDeleteFromAnswer:isdelete withCompletionHandler:^(BOOL isDeletionCompleted) {
        
        [[DiscoverProfileCollection sharedInstance] removeUserFromCollection:userId reloadDiscover:TRUE];
        if(completionHandler)
            completionHandler(TRUE);
        
    }];
    
}

-(void)deleteMatchUserFromAppExceptMatchBoxWithoutReload:(NSString *)userId shouldDeleteFromAnswer:(BOOL)isdelete withCompletionHandler:(DeletionCompletionHandler __nullable)completionHandler{
    
    [self deleteMatchUserFromAppExceptMatchBoxData:userId shouldDeleteFromAnswer:isdelete withCompletionHandler:^(BOOL isDeletionCompleted) {
        
        if(completionHandler)
            completionHandler(TRUE);
        
    }];
    
}

-(void)deleteMatchUserFromAppExceptMatchBoxData:(NSString *)userId shouldDeleteFromAnswer:(BOOL)isdelete withCompletionHandler:(DeletionCompletionHandler)completionHandler{
    if(userId == nil)
        return;
    
    NSArray *boostedUser = [MeDashboard getBoostDataForVisitorId:userId];
    
    if (boostedUser && [boostedUser count]>0) {
        [MeDashboard deleteBoostDataFromDBWithUserIDs:[NSArray arrayWithObject:userId] withCompletionHandler:^(BOOL isDeletionCompleted) {
            [self performDeletionInCrushesProfile:userId shouldDeleteFromAnswer:isdelete withCompletionHandler:completionHandler];
        }];
    }else{
        [self performDeletionInCrushesProfile:userId shouldDeleteFromAnswer:isdelete withCompletionHandler:completionHandler];
    }
}


-(void)performDeletionInCrushesProfile:(NSString*)userId shouldDeleteFromAnswer:(BOOL)isdelete withCompletionHandler:(DeletionCompletionHandler)completionHandler{
    
    CrushesDashboard *crushesDashboardObj = [CrushesDashboard getDataCorCrushWithUserID:userId];
    
    if (crushesDashboardObj) {
        [CrushesDashboard deleteCrushDataFromDBWithUserIDs:[NSArray arrayWithObject:userId] withCompletionHandler:^(BOOL isDeletionCompleted) {
            [self performDeletionInLikedMeProfile:userId shouldDeleteFromAnswer:isdelete withCompletionHandler:completionHandler];
        }];
    }else{
        [self performDeletionInLikedMeProfile:userId shouldDeleteFromAnswer:isdelete withCompletionHandler:completionHandler];
    }
}

-(void)performDeletionInLikedMeProfile:(NSString*)userId shouldDeleteFromAnswer:(BOOL)isdelete withCompletionHandler:(DeletionCompletionHandler)completionHandler{
    
    NSArray *likedMeObjects = [LikedByMe getSkippedProfileDataForUserId:userId];
    
    if (likedMeObjects && [likedMeObjects count]>0) {
         [LikedByMe deleteSkippedProfileDataFromDBWithUserIDs:[NSArray arrayWithObject:userId] withCompletionHandler:^(BOOL isDeletionCompleted) {
            if(isDeletionCompleted){
                [self performDeletionInSkippedProfile:userId shouldDeleteFromAnswer:isdelete withCompletionHandler:completionHandler];
            }
        }];
    }else{
        [self performDeletionInSkippedProfile:userId shouldDeleteFromAnswer:isdelete withCompletionHandler:completionHandler];
    }
}

-(void)performDeletionInSkippedProfile:(NSString*)userId shouldDeleteFromAnswer:(BOOL)isdelete withCompletionHandler:(DeletionCompletionHandler)completionHandler{
    
    NSArray *skippedProfiles = [SkippedProfiles getSkippedProfileDataForUserId:userId];
    
    if (skippedProfiles && [skippedProfiles count]>0) {
        [SkippedProfiles deleteSkippedProfileDataFromDBWithUserIDs:[NSArray arrayWithObject:userId] withCompletionHandler:^(BOOL isDeletionCompleted) {
            if(isDeletionCompleted){
                
                if (isdelete) {
                    if ([MyAnswers getAllAnswerByUserID:[userId longLongValue]]) {
                        [MyAnswers deleteAllAnswersByUserWithUserID:[userId longLongValue] withCompletionHandler:^(BOOL isDeletionCompleted) {
                            [self returnCompletionHandlerWithCompletionHandler:completionHandler];
                        }];
                    }else{
                        [self returnCompletionHandlerWithCompletionHandler:completionHandler];
                    }
                }else{
                    [self returnCompletionHandlerWithCompletionHandler:completionHandler];
                }
            }else{
                [self returnCompletionHandlerWithCompletionHandler:completionHandler];
            }
        }];
    }else{
        
        if (isdelete) {
            
            NSArray *answeredObjects = [MyAnswers getAllAnswerByUserID:[userId longLongValue]];
            
            if (answeredObjects && [answeredObjects count]>0) {
                [MyAnswers deleteAllAnswersByUserWithUserID:[userId longLongValue]withCompletionHandler:^(BOOL isDeletionCompleted) {
                    [self returnCompletionHandlerWithCompletionHandler:completionHandler];
                }];
            }else{
                [self returnCompletionHandlerWithCompletionHandler:completionHandler];
            }
        }else{
            [self returnCompletionHandlerWithCompletionHandler:completionHandler];
        }
    }
    
}

-(void)returnCompletionHandlerWithCompletionHandler:(DeletionCompletionHandler)completionHandler{
    dispatch_async(dispatch_get_main_queue(), ^{
        // LAST COMPLETION
        if(completionHandler)
            completionHandler(TRUE);
    });
}

-(BOOL)detectFacesInImage:(UIImage*)image{
    
    if (image){
        CIImage *detectionImage = [CIImage imageWithCGImage:image.CGImage];
        
        CIDetector *faceDector = [CIDetector detectorOfType:CIDetectorTypeFace
                                                    context:nil
                                                    options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy]];
        
        NSArray *arrayOfFaces = [faceDector featuresInImage:detectionImage];
        
        
        if ([arrayOfFaces count] < 1) {
            return NO;
        }
        else{
            return YES;
        }
    }
    else{
        return NO;
    }
}

-(BOOL)isJailbroken
{
#if TARGET_IPHONE_SIMULATOR
    return NO;
#else
    FILE *f = fopen("/bin/bash", "r");
    
    if (errno == ENOENT)
    {
        // device is NOT jailbroken
        fclose(f);
        return NO;
    }
    else {
        // device IS jailbroken
        fclose(f);
        return YES;
    }
#endif
}


-(NSString *)getGenderStringForGenderType:(SelectedGenderPreference)genderPreference{
    NSString *genderString = @"";
    switch (genderPreference) {
        case SELECTED_GENDER_PREFERENCE_MALE:
            genderString = @"MALE";
            break;
        case SELECTED_GENDER_PREFERENCE_FEMALE:
            genderString = @"FEMALE";
            break;
        case SELECTED_GENDER_PREFERENCE_BOTH:
            genderString = @"BOTH";
            break;
            
        default:
            break;
    }
    return genderString;
}
-(NSString *)getIntentTypeStringForSelectedIntent:(IntentType)intentType{
    NSString *intentString = @"";
    switch (intentType) {
        case INTENT_TYPE_FRIEND:
            intentString = @"FRIENDS";
            break;
        case INTENT_TYPE_CASUAL:
            intentString = @"CASUAL";
            break;
        case INTENT_TYPE_LOVE_OF_MY_LIFE:
            intentString = @"LOVE";
            break;
            
        default:
            break;
    }
    return intentString;
}

-(SelectedGenderPreference)getGenderPreference:(NSString *)genderString{
    SelectedGenderPreference genderPreferenceValue = SELECTED_GENDER_PREFERENCE_NONE;
    if ([genderString caseInsensitiveCompare:@"male"] == NSOrderedSame) {
        genderPreferenceValue = SELECTED_GENDER_PREFERENCE_MALE;
    }
    else if ([genderString caseInsensitiveCompare:@"female"] == NSOrderedSame){
        genderPreferenceValue = SELECTED_GENDER_PREFERENCE_FEMALE;
    }
    else if ([genderString caseInsensitiveCompare:@"both"] == NSOrderedSame){
        genderPreferenceValue = SELECTED_GENDER_PREFERENCE_BOTH;
    }
    return genderPreferenceValue;
}

-(IntentType)getIntentType:(NSString *)favIntentString{
    IntentType intentTypeValue = INTENT_TYPE_NONE;
    
    if ([favIntentString caseInsensitiveCompare:@"FRIENDS"] == NSOrderedSame) {
        intentTypeValue = INTENT_TYPE_FRIEND;
    }
    else if ([favIntentString caseInsensitiveCompare:@"LOVE"] == NSOrderedSame){
        intentTypeValue = INTENT_TYPE_LOVE_OF_MY_LIFE;
    }
    else if ([favIntentString caseInsensitiveCompare:@"CASUAL"] == NSOrderedSame){
        intentTypeValue = INTENT_TYPE_CASUAL;
    }
    
    return intentTypeValue;
}

- (void)deleteImagesFromCacheForProfile:(NSArray *)profileCardImages{
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    for (NSString *imageString in profileCardImages) {
        // [imageCache removeImageForKey:imageString fromDisk:true];
        [imageCache removeImageForKey:imageString fromDisk:YES withCompletion:nil];
    }
}
-(void)deleteAccount_Temp:(LayerDeAuthenticationSuccessHandler _Nullable )layerDeAuthSuccessBlock{
    
//    [[LayerManager sharedLayerManager] disconnectFromLayer:^(BOOL deAuhtenticationSuccess) {
//        if(layerDeAuthSuccessBlock)
//
//    }];
    
//    [[ApplozicChatManager sharedApplozicChatManager] disconnectFromApplozic:^(BOOL deAuhtenticationSuccess) {
//        [];
    
//    }];
    
    [APP_DELEGATE.applozic unsubscribeToConversation];
    [APP_DELEGATE.applozic unSubscribeToTypingStatusForOneToOne];
    APP_DELEGATE.applozic.delegate = nil;
    APP_DELEGATE.applozic = nil;
    /*
    ALRegisterUserClientService *clientService = [[ALRegisterUserClientService alloc] init];
    [clientService logoutWithCompletionHandler:^(ALAPIResponse *response, NSError *error) {
    
    }];
     
    
    [[AgoraConnectionManager sharedManager]logoutFromAgora:[[NSUserDefaults standardUserDefaults]objectForKey:kWooUserId] withCompletionHandler:^(BOOL completed) {
        
    }];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"tagOverlayShown"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstTimeLiked"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstTimeDisliked"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"QualityScoreUploaded"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:KAPNS_PERMISSION];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"hasSeenTutorialForVoiceCall"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"VoiceCallingTutorialSeenfor"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"hasSeenTutorialForVoiceCallForFirstTap"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"hasSeenInviteViewForVoiceCall"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"inviteCampaignUpdatedTime"];
    //[[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastLocationUpdatedTimeFromSettings];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kUserDeniedRenew];
    
    [[FBSession activeSession] clearJSONCache];
    [[FBSession activeSession] close];
    [[FBSession activeSession] closeAndClearTokenInformation];
    
    [FBSession setActiveSession:nil];
    
    [[FBSDKLogin sharedManagerFBSDKLogin] logOutUserFromFacebook];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"FBAccessTokenInformationKey"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserAlreadyRegistered];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kIsLoginProcessCompleted];
    
    //NSNotificationCenter.defaultCenter().addObserver[(self, selector: #selector(internetConnectionStatusChanged),
    //name: kInternetConnectionStatusChanged, object: nil)
    /*commented by Umesh
     [APP_DELEGATE reInitialiseUserDefault];
     */
    
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"firstProfileFaked"];
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"secondProfileFaked"];

    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"ProfileCanExpireHasBeenShowed"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[FBSession activeSession] clearJSONCache];
    [[FBSession activeSession] close];
    [[FBSession activeSession] closeAndClearTokenInformation];
    
    [FBSession setActiveSession:nil];
    [FBSDKAccessToken setCurrentAccessToken:nil];
    [[FBSDKLogin sharedManagerFBSDKLogin] logOutUserFromFacebook];
    
    [APP_DELEGATE reinitialiseUserDefaultAndDatabase];
    
    /* Deleting Audio Folder & Image start */
    [APP_Utilities deleteImageAndAudioFolder];
    /* Deleting Audio Folder & Image end */
    
    [APP_DELEGATE.store deleteManagedObject];
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDiskOnCompletion:nil];
    // [imageCache clearDisk];
    // [imageCache cleanDisk];
    //    [[WooLogger sharedWooLogger] removeLoggerFile];
    [[APIQueue sharedAPIQueue] removeFailedRequestFile];
    //    [self presentLoginScreen];
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserIsLoggedOut object:nil];
    
    
    [[BoostModel sharedInstance] resetModel];
     [[FreeTrailModel sharedInstance] resetModel];
    [[CrushModel sharedInstance] resetModel];
    [[MyPurchaseTemplate sharedInstance] resetModel];
    [[PurchaseProductDetailModel sharedInstance] resetModel];
    [[AppLaunchModel sharedInstance] resetSharedInstance];
    //[InAppPurchaseManager resetSharedInstance];
    [[PurchaseProductDetailModel sharedInstance] resetModel];
    [[WooGlobeModel sharedInstance] resetModel];
    [[FreeTrailModel sharedInstance] resetModel];
    [[LoginModel sharedInstance] resetSharedInstance];
    [[DiscoverProfileCollection sharedInstance] setMyProfileData:nil];
    [[DiscoverProfileCollection sharedInstance] clearAllData];
    
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey: @"MyProfileModel"];
    [userDefault removeObjectForKey:@"isOnboardingMyProfileShown"];
    [userDefault removeObjectForKey:@"IntentModel"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUpgradeIsCompleteToClearUpMeSectionData];
    [userDefault synchronize];
    
    APP_DELEGATE.onBaordingPageNumber = ON_BOARDING_PAGE_NUMBER_NONE;
    APP_DELEGATE.totalOnboardingPages = 0;
    [APP_DELEGATE disconnectFromFCM];
    layerDeAuthSuccessBlock(TRUE);
}

#pragma mark - Send Swrve Event Method
- (void)sendSwrveEventWithScreenName:(NSString *)screenName withEventName:(NSString *)eventName{
    
    [APP_DELEGATE sendSwrveEventWithEvent:eventName andScreen:screenName];
}

#pragma mark Send MixPanel Event Method
- (void)sendMixPanelEventWithName:(NSString *_Nullable)eventName{
    
    NSString *eventiOS = [eventName stringByAppendingString:@"_iOS"];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId];
    
    [mixpanel identify:userID];
    
    NSMutableDictionary *fieldsDictionary = [[NSMutableDictionary alloc]init];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] && [[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue] > 0) {
        [fieldsDictionary setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] forKey:@"WooID"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kWooUserGender] && [[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserGender] length] > 0) {
        
        [fieldsDictionary setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserGender] forKey:@"gender"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kAgeFromServer] && [[[NSUserDefaults standardUserDefaults] objectForKey:kAgeFromServer] intValue] > 0) {
        NSString *ageDimensionValue = [[NSUserDefaults standardUserDefaults] objectForKey:kAgeFromServer];
        [fieldsDictionary setObject:ageDimensionValue forKey:@"age"];
        NSString *ageBracketValue = @"";
        if (ageDimensionValue.intValue <= 21) {
            ageBracketValue = @"21 and below";
        }
        else if(ageDimensionValue.intValue > 21 && ageDimensionValue.intValue < 24){
            ageBracketValue = @"22-23 yrs";
        }
        else if(ageDimensionValue.intValue >= 24 && ageDimensionValue.intValue < 31){
            ageBracketValue = @"24 to 30yrs";
        }
        else if(ageDimensionValue.intValue >= 30){
            ageBracketValue = @"30 and 30+ years";
        }
        [fieldsDictionary setObject:ageBracketValue forKey:@"WooUserAgeBracket"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userRegion"]) {
        [fieldsDictionary setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userRegion"] forKey:@"location"];
    }
    
    if([NSLocale currentLocale]){
        NSString *countryCode = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];
        if([[self validString:countryCode] length]>0){
            [fieldsDictionary setObject:countryCode forKey:@"WooUserGeoLocation"];
        }
    }
    
    if ([AppLaunchModel sharedInstance].wooUserCurrentDayOnApp >= 0) {
        [fieldsDictionary setObject:[NSString stringWithFormat:@"%d",[AppLaunchModel sharedInstance].wooUserCurrentDayOnApp] forKey:@"WooUserCurrentDayOnApp"];
    }
    
    if ([AppLaunchModel sharedInstance].userDayStatus.length > 0) {
        [fieldsDictionary setObject:[AppLaunchModel sharedInstance].userDayStatus forKey:@"userDayStatus"];
    }
    
    if ([AppLaunchModel sharedInstance].isPurchaseKeyAvailable == true) {
        if ([AppLaunchModel sharedInstance].isPaidUser == true) {
            [fieldsDictionary setObject:@"PAID(has an active service running)" forKey:@"WooUserPaidStatus"];
        }
        else{
            if ([AppLaunchModel sharedInstance].hasEverPurchased == true) {
                [fieldsDictionary setObject:@"FREE(no active service running , but purchased in the past)" forKey:@"WooUserPaidStatus"];
            }
            else{
                [fieldsDictionary setObject:@"NEVER-PURCHASED(has never bought anything)" forKey:@"WooUserPaidStatus"];
            }
        }
    }
    
    NSString *actualVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [fieldsDictionary setObject:actualVersion forKey:@"WooUserAppVersion"];
    NSString *authTypeString = @"";
    if ([LoginModel sharedInstance].isAlternateLogin){
        if ([LoginModel sharedInstance].isAlertnativeLoginTypeTrueCaller){
            authTypeString = LoginViaTrueCaller;
        }
        else{
            authTypeString = LoginViaFirebase;
        }
    }
    else{
        authTypeString = LoginViaFacebook;
    }
    [fieldsDictionary setObject:authTypeString forKey:@"WooAuthType"];
    
    if ([[fieldsDictionary allKeys] count] > 0) {
        [mixpanel registerSuperProperties:fieldsDictionary];
    }
    
    [mixpanel track:eventiOS];
}

#pragma mark - Send Firebase Event Method

- (void)sendFirebaseEventWithScreenName:(NSString *)screenName withEventName:(NSString *)eventName{
    
    [APP_DELEGATE sendFirebaseEvent:eventName andScreen:screenName];
}

- (void)sendPurchasedFirebaseEventwithEventName:(NSString *_Nullable)eventName andPurchaseData:(NSDictionary *)purchaseDict{
    [APP_DELEGATE sendPurchasedFirebaseEvent:eventName ForPurchaseData:purchaseDict];
}

- (void)deAuthenticateLayerAndResetDatabase{
//    [APP_DELEGATE.layerClient deauthenticateWithCompletion:^(BOOL success, NSError *error) {
//        NSLog(@"success :%d",success);
//        APP_DELEGATE.layerClient = nil;
//    }];
    [APP_DELEGATE reinitialiseUserDefaultAndDatabase];
    [APP_DELEGATE.store deleteDatabase];
    [APP_Utilities deleteImageAndAudioFolder];
    
    [APP_DELEGATE.store deleteManagedObject];
    
}

- (UIColor *)getUIColorObjectFromHexString:(NSString *)hexStr alpha:(CGFloat)alpha
{
    // Convert hex string to an integer
    unsigned int hexint = [self intFromHexString:hexStr];
    
    // Create color object, specifying alpha as well
    UIColor *color =
    [UIColor colorWithRed:((CGFloat) ((hexint & 0xFF0000) >> 16))/255
                    green:((CGFloat) ((hexint & 0xFF00) >> 8))/255
                     blue:((CGFloat) (hexint & 0xFF))/255
                    alpha:alpha];
    
    return color;
}


- (unsigned int)intFromHexString:(NSString *)hexStr
{
    unsigned int hexInt = 0;
    
    // Create scanner
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    
    // Tell scanner to skip the # character
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    
    // Scan hex value
    [scanner scanHexInt:&hexInt];
    
    return hexInt;
}


#pragma mark - Adding No Internet Snack Bar
- (void)addingNoInternetSnackBarWithText:(NSString *)text withActionTitle:(NSString *)actionTitle withDuration:(double)duration{
    
    MDSnackbar *snackBarObj = [[MDSnackbar alloc] initWithText:text actionTitle:actionTitle duration:duration];
    snackBarObj.multiline = TRUE;
    [snackBarObj show];
    
}

- (void) sendToDiscover{
    
    [APP_Utilities getPushNotificationPermission];
    
    [[AppSessionManager sharedManager] makeAppLaunchCallToServer];
    [[WooScreenManager sharedInstance] loadDrawerView];
    
}

- (NSString*)getfeetAndInches:(float)centimeter {
    float totalHeight = centimeter * 0.032808;
    float myFeet = (int)totalHeight; //returns 5 feet
    float myInches = fabsf((totalHeight - myFeet) * 12);
    NSLog(@"%f",myInches);
    
    if (roundf(myInches) == 12) {
        myInches = 0.0;
        myFeet++;
    }
    
    NSLog(@"%@",[NSString stringWithFormat:@"%d\'%0.0f\''",(int)myFeet,roundf(myInches)]);
    
    return [NSString stringWithFormat:@"%d\'%0.0f\''",(int)myFeet,roundf(myInches)];
    
}


- (NSString *)getCentimeterFromFeetInches:(NSString *)theMeasure
{
    NSString *result = nil;
    
    NSArray* theConvertion = [theMeasure componentsSeparatedByCharactersInSet:
                              [NSCharacterSet characterSetWithCharactersInString:@"\'\''"]];
    
    if (theConvertion.count > 0){
    NSInteger value1 = [theConvertion[0] intValue];
        if (theConvertion.count > 1){
    NSInteger value2 = [theConvertion[1] intValue];
    
    float number = ceil((value1 * 12) + value2) * 2.54;
    result = [NSString stringWithFormat:@"%.0f", round(number * 100.0) / 100.0];
    }
        else{
            result = [NSString stringWithFormat:@"%.0ld", (long)value1];
        }
    }
    NSLog(@"result: %@", result);
    return result;
}


-(BOOL)showUnreadViewOnMeSection{
    BOOL isAnyThingunreadInMeSection = FALSE;
    if (([MeDashboard getTotalNumberOfUnvisitedVisitor] > 0) || ([LikedMe getTotalNumberOfUnvisitedLikedMeProfiles] > 0) || ([CrushesDashboard getTotalUnreadCrushes] > 0) || [MyQuestions getTotalUnreadAnswersCount] > 0 || ([SkippedProfiles getTotalNumberOfUnvisitedSkippedProfiles] > 0)) {
        isAnyThingunreadInMeSection = TRUE;
    }
    
    return isAnyThingunreadInMeSection;
    
}

-(NSInteger)getBadgeCountforMeSection{
    
    //We need to show only those counter in badge, for which the counter label is red in me section >> Discussed
    //    UITabBarItem *aboutMeTabBarItem  = [[[WooScreenManager sharedInstance] oHomeViewController].tabBar.items firstObject];
    
    NSInteger totalBadgeCount = 0;//aboutMeTabBarItem.badgeValue.intValue;
    
    if ([AppLaunchModel sharedInstance].isNewDataPresentInVisitorSection && ![BoostAPIClass getIsfetchingVisitorDataFromServerValue]) {
        totalBadgeCount += [MeDashboard getTotalNumberOfUnvisitedVisitor];
    }
    if ([AppLaunchModel sharedInstance].isNewDataPresentInLikedMESection && ![LikedMeAPIClass getIsfetchingLikedMeDataFromServerValue]) {
        totalBadgeCount += [LikedMe getTotalNumberOfUnvisitedLikedMeProfiles];
    }
    if ([AppLaunchModel sharedInstance].isNewDataPresentInCrushSection ) {
        totalBadgeCount += [CrushesDashboard getTotalUnreadCrushes];
    }
    if ([AppLaunchModel sharedInstance].isNewDataPresentInLikedByMeSection && ![LikedByMeAPIClass getIsfetchingLikedByMeDataFromServerValue]) {
           totalBadgeCount += [LikedByMe getTotalNumberOfUnvisitedLikedByMe];
       }
    
    if ([AppLaunchModel sharedInstance].isNewDataPresentInSkippedSection && ![SkippedProfileAPIClass getIsfetchingSkippedDataFromServerValue]) {
        totalBadgeCount += [SkippedProfiles getTotalNumberOfUnvisitedSkippedProfiles];
    }
    if ([AppLaunchModel sharedInstance].isNewDataPresentMyQuestionSection) {
        totalBadgeCount += [MyQuestions getTotalUnreadAnswersCount];
    }
    return totalBadgeCount;
    
}

-(NSInteger)getTotalBadgeCount{
    
    NSInteger totalMeBadgeCount = 0;//aboutMeTabBarItem.badgeValue.intValue;
    
    allBoostDataFetched = ![BoostAPIClass getIsfetchingVisitorDataFromServerValue] && [MeDashboard getInsertionCompleted];
    allLikedMeDataFetched = ![LikedMeAPIClass getIsfetchingLikedMeDataFromServerValue] && [LikedMe getInsertionCompleted];
    allSkippedDataFetched = ![SkippedProfileAPIClass getIsfetchingSkippedDataFromServerValue]  && [SkippedProfiles getInsertionCompleted];
    
    allQnADataFetched = ![MyAnswers getIsFetchingAnswers];
    allCrushDataFetched = ![CrushAPIClass getIsfetchingCrushDataFromServerValue];
    //
    //    NSLog(@"Boost data fetched %d ", allBoostDataFetched);
    //    NSLog(@"liked me data fetched %d ", allLikedMeDataFetched);
    //    NSLog(@"Skipped data fetched %d ", allSkippedDataFetched);
    //    NSLog(@"QnA data fetched %d ", allQnADataFetched);
    //    NSLog(@"Crush data fetched %d ", allCrushDataFetched);
    //
    
    if ([AppLaunchModel sharedInstance].isNewDataPresentInVisitorSection) {
        if (![[WooPlusModel sharedInstance] isExpired] && [[[DiscoverProfileCollection sharedInstance]myProfileData].gender isEqualToString:@"MALE"]){
            totalMeBadgeCount += [MeDashboard getTotalNumberOfVisitors];
        }
        else
        {
            totalMeBadgeCount += [MeDashboard getTotalNumberOfUnvisitedVisitor];
        }
    }
    if ([AppLaunchModel sharedInstance].isNewDataPresentInLikedMESection) {
        if (![[WooPlusModel sharedInstance] isExpired] && [[[DiscoverProfileCollection sharedInstance]myProfileData].gender isEqualToString:@"MALE"]){
            totalMeBadgeCount += [LikedMe getTotalNumberOfLikedMeProfiled];
        }
        else
        {
            totalMeBadgeCount += [LikedMe getTotalNumberOfUnvisitedLikedMeProfiles];
        }
    }
    if ([AppLaunchModel sharedInstance].isNewDataPresentInCrushSection ) {
        totalMeBadgeCount += [CrushesDashboard getTotalUnreadCrushes];
    }
    BOOL hasVisitedLikedByMeSection = [[NSUserDefaults standardUserDefaults] boolForKey:@"hasVisitedLikedByMeSection"];
    if ([AppLaunchModel sharedInstance].isNewDataPresentInLikedByMeSection && !hasVisitedLikedByMeSection) {
        if (![[WooPlusModel sharedInstance] isExpired] && [[[DiscoverProfileCollection sharedInstance]myProfileData].gender isEqualToString:@"MALE"]){
            totalMeBadgeCount += [LikedByMe getTotalNumberOfSkippedProfiled];
        }
        else
        {
            totalMeBadgeCount += [LikedByMe getTotalNumberOfUnvisitedLikedByMe];
        }
    }
    
    BOOL hasVisitedSkippedSection = [[NSUserDefaults standardUserDefaults] boolForKey:@"hasVisitedSkippedSection"];
    if ([AppLaunchModel sharedInstance].isNewDataPresentInSkippedSection && !hasVisitedSkippedSection) {
        if (![[WooPlusModel sharedInstance] isExpired] && [[[DiscoverProfileCollection sharedInstance]myProfileData].gender isEqualToString:@"MALE"]){
            totalMeBadgeCount += [SkippedProfiles getTotalNumberOfSkippedProfiled];
        }
        else
        {
            totalMeBadgeCount += [SkippedProfiles getTotalNumberOfUnvisitedSkippedProfiles];
        }
    }
    if ([AppLaunchModel sharedInstance].isNewDataPresentMyQuestionSection) {
        totalMeBadgeCount += [MyQuestions getTotalUnreadAnswersCount];
    }
    UITabBarItem *aboutMeTabBarItem  = [[[WooScreenManager sharedInstance] oHomeViewController].tabBar.items firstObject];
    int currentValue = aboutMeTabBarItem.badgeValue.intValue;
    
    if( allBoostDataFetched  == true && allLikedMeDataFetched== true  && allSkippedDataFetched == true && allCrushDataFetched== true  && allQnADataFetched== true )
    {
        return totalMeBadgeCount;
    }
    else
    {
        if (totalMeBadgeCount !=0 && currentValue != 0)
        {
            return totalMeBadgeCount;
        }
        else
        {
            return 0;
            
        }
    }
}



- (void)showInviteActivityOnViewController:(UIViewController *)viewController {
    
    NSString *messageBody = NSLocalizedString(@"Text for whatsapp", nil);
    // messageBody = [NSString stringWithFormat:@"%@<br><br>%@ </body></html>",messageBody,[[NSUserDefaults standardUserDefaults] valueForKeyPath:kWooUserName]];
    messageBody = [NSString stringWithFormat:@"%@ %@",messageBody,[[NSUserDefaults standardUserDefaults] valueForKeyPath:kWooUserName]];
    
    NSArray *itemsArray = @[messageBody];
    
    WhatsappShareActivity *speechActivity = [[WhatsappShareActivity alloc] init];
    CustomMailActivity *customMailActivity = [[CustomMailActivity alloc] init];
    MessageCustomActivity *messageCustomActivity = [[MessageCustomActivity alloc] init];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsArray applicationActivities:@[speechActivity,customMailActivity,messageCustomActivity]];
    [activityVC  setCompletionHandler:^(NSString *activityType, BOOL completed) {
        NSLog(@"samothing tapped");
    }];
    NSString *emailTitle = NSLocalizedString(@"CMP00366", nil);
    
    [activityVC setValue:emailTitle forKey:@"subject"];
    
    
    activityVC.excludedActivityTypes = @[UIActivityTypePostToFacebook,
                                         UIActivityTypePostToTwitter,
                                         UIActivityTypePostToWeibo,
                                         UIActivityTypePrint,
                                         UIActivityTypeCopyToPasteboard,
                                         UIActivityTypeAssignToContact,
                                         UIActivityTypeSaveToCameraRoll,
                                         UIActivityTypeAddToReadingList,
                                         UIActivityTypePostToFlickr,
                                         UIActivityTypePostToVimeo,
                                         UIActivityTypeMail,
                                         UIActivityTypePostToTencentWeibo,
                                         UIActivityTypeMessage,
                                         UIActivityTypeAirDrop];
    
    
    //activityVC.excludedActivityTypes = @[UIActivityTypeAirDrop];
    
    [viewController presentViewController:activityVC animated:YES completion:nil];
}


- (UIImage *)getImageFromView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

-(NSDate *)dateAfterSubtractingDaysInCurrentDate:(int)numberOfDays{
    NSDate *currentDate = [NSDate date];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:-numberOfDays];
    NSDate *dateAfterDeletingGivenDays = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:currentDate options:0];
    return dateAfterDeletingGivenDays;
}

- (NSString *)substringToIndex:(int)indexValue withString:(NSString *)strValue{
    return [strValue substringToIndex:indexValue];
}

-(BOOL )shouldWeShowRatingPopup{
    return NO; // Added no explicitely because Peush on 20th september 2016 asked us to remove ratings thing
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kFirstMAtchOnV3Key]){
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserSubmittedV3Feedback] && [[[NSUserDefaults standardUserDefaults] objectForKey:kUserSubmittedV3Feedback] boolValue] == true) {
            return NO;
        }
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kRemindMePopupTimestampV3] && [[[NSUserDefaults standardUserDefaults] objectForKey:kRemindMePopupTimestampV3] isKindOfClass:[NSDate class]]) {
            
            NSDate *localDateObj = [[NSUserDefaults standardUserDefaults] objectForKey:kRemindMePopupTimestampV3];
            
            long long int currentDate = [[NSDate date] timeIntervalSince1970];
            long long int localDate = [localDateObj timeIntervalSince1970];
            
            if (currentDate < (localDate + 172800)) {
                return false;
            }
        }
        
        
        return true;
        
    }
    
    return false;
}

-(NSString *)getDeviceLanguageString{
    return [[NSLocale currentLocale] displayNameForKey:NSLocaleLanguageCode value:[[NSLocale preferredLanguages] objectAtIndex:0]];
}

-(NSString *)getDeviceLocaleCode{
    
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSDictionary *languageDic = [NSLocale componentsFromLocaleIdentifier:language];
    
    NSString *languageCode = [languageDic objectForKey:@"kCFLocaleLanguageCodeKey"];
    
    return languageCode;
}




- (UIButton *)addingShadowOnButton:(UIButton *)btn{
    
    btn.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
    btn.layer.shadowOpacity = 0.4;
    btn.layer.shadowRadius = 3.0;
    btn.layer.shadowOffset = CGSizeMake(0.0, 2.0);
    
    
    return btn;
}


-(BOOL)isViewControllerPresented:(id )controller{
    
    if([controller presentingViewController])
        return YES;
    if([[controller presentingViewController] presentedViewController] == controller)
        return YES;
    if([[[controller navigationController] presentingViewController] presentedViewController] == [controller navigationController])
        return YES;
    if([[[controller tabBarController] presentingViewController] isKindOfClass:[UITabBarController class]])
        return YES;
    
    return NO;
}

- (BOOL)stringContainsEmoji:(NSString *)string {
    __block BOOL returnValue = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     returnValue = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 returnValue = YES;
             }
             
         } else {
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff) {
                 returnValue = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 returnValue = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 returnValue = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 returnValue = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 returnValue = YES;
             }
         }
     }];
    
    return returnValue;
}

-(void)precacheCarouselDataWithData:(NSArray *)carouselArray circleImage:(NSString *)circle  backgroundImage:(NSArray *)bgImageArray andBaseURL:(NSString *)baseURL{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray *imageArray = [[NSMutableArray alloc]init];
        
        for (NSDictionary *dataDictionary in carouselArray) {
            if ([dataDictionary objectForKey:@"iconImgUrl"]) {
                [imageArray addObject:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",baseURL,[dataDictionary objectForKey:@"iconImgUrl"]]]];
            }
        }
        
        for (NSString *backgroundImage in bgImageArray) {
            [imageArray addObject:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",baseURL,backgroundImage]]];
        }
        
        if (baseURL.length > 0) {
            [imageArray addObject:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",baseURL,circle]]];
        }
        
        for (NSURL *urlOfImage in imageArray) {
            
            [[SDWebImageManager sharedManager] loadImageWithURL:urlOfImage options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                
            } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                NSLog(@"completed url = %@",[NSString stringWithFormat:@"%@",imageURL]);
                
            }];
            //            [[SDWebImageManager sharedManager] downloadImageWithURL:urlOfImage options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            //
            //            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            //            }];
        }
        //    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:imageArray];
        
        [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:imageArray progress:^(NSUInteger noOfFinishedUrls, NSUInteger noOfTotalUrls) {
            NSLog(@"finished urls = %lu / %lu",(unsigned long)noOfFinishedUrls, (unsigned long)noOfTotalUrls);
        } completed:^(NSUInteger noOfFinishedUrls, NSUInteger noOfSkippedUrls) {
            NSLog(@"completed urls = %lu / %lu",(unsigned long)noOfFinishedUrls, (unsigned long)noOfSkippedUrls);
        }];
    });
}

-(void)precacheDiscoverImagesWithData:(NSArray *)discoverArray{
    
    NSMutableArray *imageArray = [[NSMutableArray alloc]init];
    
    if (discoverArray && discoverArray.count > 0) {
        for (NSString *imageUrlString in discoverArray) {
            if (imageUrlString && imageUrlString.length > 0) {
                [imageArray addObject:[NSURL URLWithString:imageUrlString]];
            }
        }
    }
    
    if (imageArray.count > 0) {
        for (NSURL *urlOfImage in imageArray) {
            [[SDWebImageManager sharedManager] loadImageWithURL:urlOfImage options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                
            } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                NSLog(@"completed url = %@",[NSString stringWithFormat:@"%@",imageURL]);
                
            }];
            //            [[SDWebImageManager sharedManager] downloadImageWithURL:urlOfImage options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            //
            //            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            //                NSLog(@"completed url = %@",[NSString stringWithFormat:@"%@",imageURL]);
            //            }];
        }
        //    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:imageArray];
        
        
        [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:imageArray progress:^(NSUInteger noOfFinishedUrls, NSUInteger noOfTotalUrls) {
            NSLog(@"finished urls = %lu / %lu",(unsigned long)noOfFinishedUrls, (unsigned long)noOfTotalUrls);
        } completed:^(NSUInteger noOfFinishedUrls, NSUInteger noOfSkippedUrls) {
            NSLog(@"completed urls = %lu / %lu",(unsigned long)noOfFinishedUrls, (unsigned long)noOfSkippedUrls);
        }];
        
    }
}

- (void)downloadMatchImageForImageUrl:(NSURL *)imageUrl{
    [[SDWebImageManager sharedManager] loadImageWithURL:imageUrl options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        NSLog(@"completed url = %@",[NSString stringWithFormat:@"%@",imageURL]);
        
    }];
    //    [[SDWebImageManager sharedManager] downloadImageWithURL:imageUrl options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
    //
    //    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
    //        NSLog(@"completed match image url = %@",[NSString stringWithFormat:@"%@",imageURL]);
    //    }];
}

-(void)precacheImagesWithData:(NSArray *)imageArray withCompletionHandler:(ImageCompletionHandler __nullable)completionHandler{
    
    NSMutableArray *imagesArray = [[NSMutableArray alloc]init];
    
    if (imageArray && imageArray.count > 0) {
        for (NSString *imageUrlString in imageArray) {
            if (imageUrlString && imageUrlString.length > 0) {
                [imagesArray addObject:[NSURL URLWithString:imageUrlString]];
            }
        }
    }
    
    if (imagesArray.count > 0) {
        for (NSURL *urlOfImage in imagesArray) {
            //            [[SDWebImageManager sharedManager] downloadImageWithURL:urlOfImage options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            //
            //            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            //                NSLog(@"completed review Photo url = %@",[NSString stringWithFormat:@"%@",imageURL]);
            //                NSString *lastImageUrl = [[imagesArray lastObject] absoluteString];
            //                NSString *downloadedImageUrl = [imageURL absoluteString];
            //                if ([lastImageUrl isEqualToString:downloadedImageUrl]) {
            //                    completionHandler(true);
            //
            //                }
            //            }];
            [[SDWebImageManager sharedManager] loadImageWithURL:urlOfImage options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                
            } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                NSLog(@"completed review Photo url = %@",[NSString stringWithFormat:@"%@",imageURL]);
                NSString *lastImageUrl = [[imagesArray lastObject] absoluteString];
                NSString *downloadedImageUrl = [imageURL absoluteString];
                if ([lastImageUrl isEqualToString:downloadedImageUrl]) {
                    completionHandler(true);
                    
                }
                
            }];
        }
    }
}

-(BOOL)isChatRoomPresentInNavigationController:(UINavigationController *)navController{
    BOOL isChatRoomPresent = FALSE;
    
    for (id viewController in [navController viewControllers]) {
        if ([viewController isKindOfClass:[NewChatViewController class]]) {
            isChatRoomPresent = TRUE;
        }
    }
    if (APP_DELEGATE.currentActiveChatRoomId && [APP_DELEGATE.currentActiveChatRoomId length] > 0) {
        isChatRoomPresent = TRUE;
    }
    return isChatRoomPresent;
}

-(NSString *)getCurrentlyActiveChatRoomId{
    return APP_DELEGATE.currentActiveChatRoomId?APP_DELEGATE.currentActiveChatRoomId:@"";
}

-(NewChatViewController *)getCurrentlyActiveChatRoomObj:(UINavigationController *)navController{
    NewChatViewController *chatVCObj = nil;
    for (id viewController in [navController viewControllers]) {
        if ([viewController isKindOfClass:[NewChatViewController class]]) {
            chatVCObj = (NewChatViewController *)viewController;
        }
    }
    return chatVCObj;
}

/**
 *  method to check if given string start with vowel of not (it will check for a, e, i, o, u)
 *
 *  @param stringToBechecked string that needs to be checked
 *
 *  @return true or false, true if first char is vowel otherwise false
 */

-(BOOL)checkIfStringStartsWithVowelOfNot:(NSString *)stringToBeChecked{
    if (stringToBeChecked && [stringToBeChecked length]>1) {
        NSString *firstChar = [stringToBeChecked substringToIndex:1];
        if (([firstChar caseInsensitiveCompare:@"a"] == NSOrderedSame) || ([firstChar caseInsensitiveCompare:@"e"] == NSOrderedSame) || ([firstChar caseInsensitiveCompare:@"i"] == NSOrderedSame) || ([firstChar caseInsensitiveCompare:@"o"] == NSOrderedSame) || ([firstChar caseInsensitiveCompare:@"u"] == NSOrderedSame) ) {
            return TRUE;
        }
    }
    return FALSE;
}

-(BOOL)checkIfNeedToShowLoaderInMatchbox{
    return [APP_DELEGATE getIsFetchingMatchDataFromServerValue];
}

-(UIView *)blurView:(UIView *)view;
{
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleProminent];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = view.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        return blurEffectView;
        
    }
    return [[UIView alloc]init];
}
-(int)checkMicrophonePermission
{
    AVAudioSessionRecordPermission permissionStatus = [[AVAudioSession sharedInstance] recordPermission];
    switch (permissionStatus) {
        case AVAudioSessionRecordPermissionUndetermined:{
            return -1;
            break;
        }
        case AVAudioSessionRecordPermissionDenied:
            // direct to settings...
            return 0;
            break;
        case AVAudioSessionRecordPermissionGranted:
            // mic access ok...
            return 1;
            break;
        default:
            // this should not happen.. maybe throw an exception.
            break;
    }
    return NO;
}

//54321
-(void)colorStatusBar:(UIColor *)colorStatusBar{
    if((IS_IPHONE_X) || (IS_IPHONE_XS_MAX)){
//    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
//    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
//        statusBar.backgroundColor = colorStatusBar;
//    }
    
        
        if (@available(iOS 13.0, *)) {
            NSInteger tag = 38482;
            UIView *tagStatusBar = [[UIApplication sharedApplication].keyWindow viewWithTag:tag];
            
            UIView *statusBar = [[UIView alloc]initWithFrame:[UIApplication sharedApplication].keyWindow.windowScene.statusBarManager.statusBarFrame];
            
            if(tagStatusBar){
                tagStatusBar.backgroundColor = colorStatusBar;
                [[UIApplication sharedApplication].keyWindow addSubview:tagStatusBar];
            }else{
                statusBar.backgroundColor = colorStatusBar;
                statusBar.tag = tag;
                [[UIApplication sharedApplication].keyWindow addSubview:statusBar];
            }
//            [[UIApplication sharedApplication].keyWindow viewWithTag:tag];
            
        } else {
            // Fallback on earlier versions
            
             UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
                if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
                    statusBar.backgroundColor = colorStatusBar;
                }
        }
    }
}

- (CGFloat)getSafeAreaForTop:(BOOL)top andBottom:(BOOL)bottom{
    
    float safeArea = 0.0;
    
//    if (@available(iOS 11, *)) {
//        if (top) {
//            if ([[UIApplication sharedApplication] keyWindow].safeAreaInsets.top > 0) {
//                safeArea = [[UIApplication sharedApplication] keyWindow].safeAreaInsets.top;
//            }
//        }
//
//        if(bottom){
//            if ([[UIApplication sharedApplication] keyWindow].safeAreaInsets.bottom > 0) {
//                safeArea = safeArea + [[UIApplication sharedApplication] keyWindow].safeAreaInsets.bottom;
//            }
//        }
//    }
//
//    CGFloat floatSafeArea = [[NSNumber numberWithFloat:safeArea] floatValue];
//    return floatSafeArea;
    
    if (IS_IPHONE_X || IS_IPHONE_XS_MAX ){
        if (top && bottom){
            return 78;
        }else if (top){
            return 44;
        }else{
            return 34;
        }
    }else{
        return 0;
    }

}

- (NSDictionary *)getOnboardingPageNumberAndTotalNumberOfPages{
    OnboardingPageNumber pageNumber = [APP_DELEGATE onBaordingPageNumber];
    NSString *page = [NSString stringWithFormat:@"%d",pageNumber];
    NSString *total = [NSString stringWithFormat:@"%d",[APP_DELEGATE totalOnboardingPages]];
    NSDictionary *pagesDict = [[NSDictionary alloc] initWithObjects:@[page,total] forKeys:@[@"pageNumber",@"totalPages"]];
    return pagesDict;
}

- (void)increaseOnBoardingPageNumber{
    NSLog(@"onboard increase %u",APP_DELEGATE.onBaordingPageNumber);
    APP_DELEGATE.onBaordingPageNumber ++;
}

- (void)decreaseOnBoardingPageNumber{
    NSLog(@"onboard decrease %u",APP_DELEGATE.onBaordingPageNumber);
    APP_DELEGATE.onBaordingPageNumber --;
}

-(void)logPurchaseEventOnFacebook:(NSString*)currency withParameters:(NSDictionary*)parameters withPurchaseAmount:(double)purchaseAmount{
    [FBSDKAppEvents logPurchase:purchaseAmount
                       currency:currency
                     parameters: parameters];
}

- (NSString *)getMonthStringFromIntegerValue:(NSInteger)monthInInteger{
    NSString *monthInString = @"";
    switch (monthInInteger) {
        case 1:
            monthInString = @"January";
            break;
        case 2:
            monthInString = @"February";
            break;
        case 3:
            monthInString = @"March";
            break;
        case 4:
            monthInString = @"April";
            break;
        case 5:
            monthInString = @"May";
            break;
        case 6:
            monthInString = @"June";
            break;
        case 7:
            monthInString = @"July";
            break;
        case 8:
            monthInString = @"August";
            break;
        case 9:
            monthInString = @"September";
            break;
        case 10:
            monthInString = @"October";
            break;
        case 11:
            monthInString = @"November";
            break;
        case 12:
            monthInString = @"December";
            break;
        default:
            break;
    }
    return monthInString;
}

@end
