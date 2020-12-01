//
//  UConstant.h
//  Woo
//
//  Created by Umesh Mishra on 13/02/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#ifndef Woo_UConstant_h
#define Woo_UConstant_h

#define APP_DELEGATE [AppDelegate appDelegate]
#define API_BASE_URL @"API_BASE_URL"
//#define BASE_URL [[[NSBundle mainBundle] infoDictionary] objectForKey:API_BASE_URL]

#define BASE_URL            [NSString stringWithFormat:@"%@",[[NSUserDefaults                                           standardUserDefaults]                                                                    objectForKey:@"API_SERVER_LIVE_iOS"]]

#define BASE_URL_LOGIN      [NSString stringWithFormat:@"%@",[[NSUserDefaults                                           standardUserDefaults]                                                                    objectForKey:@"API_SERVER_LIVE_LOGIN_iOS"]]

#define NOTIFICATION_VIEW_CONTROLLER_OBJ [[AppDelegate appDelegate] returnNotificationControllerObj]

#define STORE [Store sharedInstance]//APP_DELEGATE.store

#define APP_Utilities [Utilities sharedUtility]

#define APP_IAPMANAGER [InAppPurchaseManager sharedIAPManager]

#define LAYER_HELPER [LayerChatHelperClass sharedLayerChatHelperClass]

#define APPLOZIC_HELPER [ApplozicChatHelperClass sharedApplozicChatHelperClass]




#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

#define kIsLiveServer YES // THIS BOOLEAN IS TO ENABLE OR DISABLE LIVE SERVER

#define HEIGHT_IPHONE_5 568
#define HEIGHT_IPHONE_4 480
#define HEIGHT_IPHONE_6P 736
#define HEIGHT_IPHONE_6 667
#define WIDTH_IPHONE_x 375
#define HEIGHT_IPHONE_X 812
#define HEIGHT_IPHONE_XS_MAX 896

#define IS_IPHONE   ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 ([[UIScreen mainScreen] bounds ].size.height == HEIGHT_IPHONE_5 )
#define IS_IPHONE_4 ([[UIScreen mainScreen] bounds ].size.height == HEIGHT_IPHONE_4 )
#define IS_IPHONE_6P ([[UIScreen mainScreen] bounds ].size.height == HEIGHT_IPHONE_6P )
#define IS_IPHONE_X ([[UIScreen mainScreen] bounds ].size.height == HEIGHT_IPHONE_X)
#define IS_IPHONE_XS_MAX ([[UIScreen mainScreen] bounds ].size.height == HEIGHT_IPHONE_XS_MAX)
#define IS_IPHONE_SmallerThanIphone_6 ([[UIScreen mainScreen] bounds ].size.height < HEIGHT_IPHONE_6 )
#define IS_IPHONE_HigherThanIphone_6 ([[UIScreen mainScreen] bounds ].size.height > HEIGHT_IPHONE_6 )
#define IS_IPHONE_EqualToIphone_6 ([[UIScreen mainScreen] bounds ].size.height == HEIGHT_IPHONE_6)

#define meColor [UIColor colorWithRed:117.0/255 green:196.0/255.0 blue:219.0/255.0 alpha:1.0]
#define discoverColor [UIColor colorWithRed:146.0/255 green:117.0/255.0 blue:219.0/255.0 alpha:1.0]

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

#define CAN_ASK_QUESTIONS [APP_Utilities canAskMoreQuestions]

#define IS_INDIAN_USER  [APP_Utilities isIndianUser]

#define CURRENT_TIMESTAMP_IN_LONG [[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] longLongValue]

#define CURRENT_TIMESTAMP_IN_LONG_MILLI [[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]*1000] longLongValue]


#define isLoggingEnabled 0

#define kNameCellTagKey 121212
#define kDoNotPutMeInFailedQueue -10
#define kHeightOfRowInProfileScreen 24


#define kPageLengthForCrushes 10

#define kPageLengthForBoost 10

#define kCircularImageSize 85

#define kHostNameForReachability @"www.google.com"

#define kiStore

//Check version

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


#define IMAGE_SIZE_FOR_POINTS(v) ([[Utilities sharedUtility] getImageSizeForPoints:v])
#define SHOW_TOAST_WITH_TEXT(text) ([[Utilities sharedUtility] showToastWithText:text])

#define LOCALISED_IMAGE_NAME(v) NSLocalizedString(v, nil)

//Notification

#define kUserLoggedInSuccessfully             @"userLoggedInSuccessfully"

#define kLastLocationUpdatedTimeFromSettings               @"kLastLocationUpdatedTimeFromSettings"
#define kPushToVerificationScreen             @"PushToVerificationScreen"
#define kAppComesToForeground                 @"appComesToForeground"
#define kPlayVideo                            @"playVideo"
#define kResumeVideo                          @"resumeVideo"
#define kShowProfilePicsNotification          @"showProfilePicsNotification"
#define kShowChangeButton                     @"showChangeButton"
#define kShowPicker                           @"showPicker"
#define kAudioFileCreated                     @"audioFileCreated"
#define kAudioStartedRecording                @"audioStartedRecording"
#define kAudioEndRecording                    @"audioEndRecording"
#define kAllMatchesExhausted                  @"allMatchesExhausted"
#define kDislikedAProfile                     @"dislikedAProfile"
#define kFlaggedAProfile                      @"flaggedAProfile"
#define kLikedAProfile                        @"likedAProfile"
#define kTimerFinishedGetNewDiscoverData      @"timerFinishedGetNewDiscoverData"
#define kShowFriendList                       @"showFriendList"
#define kRightPanelNotificationDeleted        @"rightPanelNotificationDeleted"
#define kFileDownloaded                       @"fileDownloaded"
#define kPerformInitialChecksOnDiscoverView   @"performInitialChecksOnDiscoverView"
#define kAskPressedOnProfile                  @"askButtonPressed"
#define kPushToUserProfile                    @"pushToUserProfileFromNotification"
#define kMatchDataSavedInLocalDatabase        @"matchSavedInDB"
#define kMatchDeletedByNotification           @"matchDeletedByNotification"
#define kMatchStatusSetToDeleted              @"matchStatusSetToDeleted"

#define kShowProfileCompletenessScreen        @"showProfileCompletenessScreen"
#define kShowIndicatorViewOnLoginScreen       @"showIndicatorViewOnLoginScreen"
#define kHideIndicatorViewOnLoginScreen       @"hideIndicatorViewOnLoginScreen"
#define kProfilePictureBubbleIconTapped       @"ProfilePictureBubbleIconTapped"
#define kDismissLoginViewAndMakeToFBSync      @"dismissLoginViewAndMakeToFBSync"
#define kMakeFbSyncCall                       @"makeFBSyncCall"
#define kVerifyYourPhoneNumber                @"verifyjYourNumber"
#define kAuthorizeFacebookButtonTapped        @"authorizeButtonTappedNotification"
#define kUserProvidedNewFbPermission          @"newFbPermissionGrantedByUser"
#define kShowFBAlbumView                      @"showFBAlbumView"
#define kLayerClientInitialiseNotification    @"LayerClientInitialisedNotification"
#define kRefreshDataOnNotificationScreen      @"UpdateDataOnNotificationScreen"
#define kRefetchNotifications                 @"RefetchAllNotifications"
#define kCarouselDidScrolled                  @"CarouselDidScrolled"
#define kCarouselBeginScrolling               @"CarouselBeginScrolling"
#define kTagTappedWithTagDataNotification     @"TagTappedWithTagData"
#define kReAddFillersNotification             @"reAddFillersNotification"
#define kRemovePurchaseCardFromCarousal       @"removeBoostCardFromCarousal"
#define kShowCameraAgainNotification          @"showCameraAgain"
#define kShowLastImageSelectionOptionAgain    @"showLastImageSelectionOptionAgain"
#define kUserHasBeenBlocked                   @"userHasBeenBlocked"
#define kDismissTheScreenNotification         @"dismssScreenNotification"
#define kNotificationForCancelledFromFacebook @"cancelledFromFacebook"

//Notifications - V2.0+ ---------------
#define kDiscoverTappedOnLeftPanel      @"DISCOVER_TAPPED_ON_LEFT_PANEL"
#define kProfileTappedOnLeftPanel       @"PROFILE_TAPPED_ON_LEFT_PANEL"
#define kNotificationsTappedOnLeftPanel @"NOTIFICATIONS_TAPPED_ON_LEFT_PANEL"
#define kSettingsTappedOnLeftPanel      @"SETTINGS_TAPPED_ON_LEFT_PANEL"
#define kFAQTappedOnLeftPanel           @"FAQ_TAPPED_ON_LEFT_PANEL"
#define kInviteTappedOnLeftPanel        @"INVITE_TAPPED_ON_LEFT_PANEL"
#define kPurchasesTappedOnLeftPanel     @"PURCHASE_TAPPED_ON_LEFT_PANEL"
#define kVisitorTappedOnLeftPanel       @"VISITOR_TAPPED_ON_LEFT_PANEL"
#define kCrushTappedOnLeftPanel         @"CRUSH_TAPPED_ON_LEFT_PANEL"
#define kPowerUpsTappedOnLeftPanel      @"POWERUPS_TAPPED_ON_LEFT_PANEL"
#define kDeleteRecommendationAndReload  @"DELETE_RECOMMENDATION_AND_RELOAD"
#define kAppCameToForeground            @"APP_CAME_TO_FOREGROUND"
#define kBoostDashBoardMigration            @"kBoostDashBoardMigration"
#define kLikedMeMigration            @"kLikedMeMigration"
//#define kRemoveViewWithKeyboard         @"removeViewWithKeyboard"

// Adding My Comment

#define kPurchaseOptionBoost            @"PURCHASE_OPTION_BOOST"
#define kPurchaseOptionCrush            @"PURCHASE_OPTION_CRUSH"


#define kPurchaseTappedOnLeftPanel      @"PPURCHASE_TAPPED_ON_LEFT_PANEL"
#define kMessagesTappedOnLeftPanel      @"MESSAGES_BUTTON_TAPPED"
#define kQuestionsTapped                @"QUESTIONS_TAPPED"
#define kTakeUserToDiscoverScreen       @"TAKE_USER_TO_DISCOVER"
#define kTutorialTappedOnLeftPanel      @"TUTORIAL_TAPPED_ON_LEFT_PANEL"
#define kImageSelectionNotification     @"ImageSelectionNotification"

#define kInviteAFriendTappedOnLeftPanel @"INVITE_A_FRIEND_LEFT_TAPPED_ON_LEFT_PANEL"


//#define kFetchNewAnswersNotification            @"FETCH_NEW_ANSWERS_NOTIFICATION"
#define kAnswersFetched                         @"FETCHED_NEW_ANSWERS_SUCCESFULLY"
#define kStopAudioPlayOnCardView                @"STOP_AUDIO_PLAY_ON_CARD_VIEW"


#define kOpenProfileInEditMode                  @"openProfileInEditMode"


//FAN
#define kFANViewhasBeenDeallocated              @"FANViewDeallocated"

//-----------------------------

//#define kMaxCharactersAllowedForIntroduction 140

#define kMyProfileMessageCellHeightKey @"HEIGHT_OF_USER"
#define kMyProfileMessageCellStatusKey @"STATUS_OF_USER"
#define kMyProfileMessageCellMessageKey @"MESSAGE_TO_USER"

#define kMyProfileInfoCellTitleKey @"TITLE_FOR_CELL"
#define kMyProfileInfoCellDescriptionKey @"DESCRIPTION_FOR_CELL"
#define kMyProfileInfoCellOptionalPictureKey @"CELL_OPTIONAL_IMAGE"
#define kMyProfileInfoCellIsTappbaleKey @"IS_CELL_TAPPABLE"

#define kMyProfileRoundedCellImageKey @"url"
#define kMyProfileRoundedCellTextKey @"name"
#define kMyProfileRoundedCellIsTappableKey @"IS_CELL_TAPPABLE"

#define kMyProfileLikeCellButtonTitleKey @"LIKE_TEXT"
#define kMyProfileLikeCellButtonTagValueKey @"LIKE_TAG_ID"

#define kDownloadURL                @"downloadURL"
#define kDownloadClass              @"downloadClass"

//API Keys
#define kBigImageSourceKey @"srcBig"
//#define kGoogleAPIKey      @"AIzaSyAJ18A8Pfv9kJTr9FCOYaEoS_1iMM8aC6w"

#define kGoogleAPIKey      @"AIzaSyAqC2RqtuNeqmB9LuhIZpJbBrnLkkNpK3s"
//AIzaSyAqC2RqtuNeqmB9LuhIZpJbBrnLkkNpK3s
// Above key exists under woo-app project of our gmail account

//@"AIzaSyBQ0NJuewc1YMEk_Gj3M5VJR6u8rRmRYaw" //@"AIzaSyAFRDSo9ZdHkW21nATJ_Ah60-FWy1QCGpQ"

//API

#define kCrashReporterURL         @"http://api.getwooapp.com/QuincyKit/crash_v300.php"
#define kStickerBaseURL           @"http://u2-woostore.s3.amazonaws.com/stickers/iphone/"



#define kImageCroppingServerURL   @"https://dd66jla1ca8rb.cloudfront.net/image-server/api/v3/image/crop/"

//#define kImageCroppingServerURL   @"http://54.169.167.12:8082/image-server/api/v1/image/crop/"
//#define kImageCroppingServerV2URL @"http://dd66jla1ca8rb.cloudfront.net/image-server/api/v2/image/crop/"

#define kFirebaseParameterKey                @"firebaseParameterKey"
#define kFirebaseParameterValue              @"firebaseParameterValue"

#define kLocationThreshold                   3600




#ifdef DEBUG
#define kAppId_Applozic         @"3d51651ee1e6bfe50b79f5e611cb3fe2e"
#else
//#define kAppId_Applozic         @"3d51651ee1e6bfe50b79f5e611cb3fe2e"
#define kAppId_Applozic         @"doubleyou393a25ca31528e80f8c2f"
#endif

#define kIndianProdLoginUrl     @"https://login-api.getwooapp.com/"

// now these constants are common for all the configuration
#define kLoginURLV3             [NSString stringWithFormat:@"%@/woo/api/v3",BASE_URL_LOGIN]
#define kLoginURLV1             [NSString stringWithFormat:@"%@/woo/api/v1",BASE_URL_LOGIN]
#define kLoginURLV2             [NSString stringWithFormat:@"%@/woo/api/v2",BASE_URL_LOGIN]
#define kLoginURLV4             [NSString stringWithFormat:@"%@/woo/api/v4",BASE_URL_LOGIN]
#define kLoginURLV5             [NSString stringWithFormat:@"%@/woo/api/v5",BASE_URL_LOGIN]
#define kLoginURLV2_HTTPS       [NSString stringWithFormat:@"%@/woo/api/v2",BASE_URL_LOGIN]
#define kLoginURLV3_HTTPS       [NSString stringWithFormat:@"%@/woo/api/v3",BASE_URL_LOGIN]
#define kLoginURLV4_HTTPS       [NSString stringWithFormat:@"%@/woo/api/v4",BASE_URL_LOGIN]
//#define kLoginURLV3_HTTPS       @"https://login-api.getwooapp.com/woo/api/v3"
#define kBaseURLV1_HTTPS        [NSString stringWithFormat:@"%@/woo/api/v1",BASE_URL]
#define kBaseURLV2_HTTPS        [NSString stringWithFormat:@"%@/woo/api/v2",BASE_URL]
#define kBaseURLV3_HTTPS        [NSString stringWithFormat:@"%@/woo/api/v3",BASE_URL]
#define kBaseURLV4_HTTPS        [NSString stringWithFormat:@"%@/woo/api/v4",BASE_URL]

#define kLoginBaseURL           BASE_URL@"/"
#define kServerURL              BASE_URL


//#ifdef DEBUG
//
//#define kAppId_Applozic         @"3d51651ee1e6bfe50b79f5e611cb3fe2e"
//#define kLoginURLV3             [NSString stringWithFormat:@"%@/woo/api/v3",BASE_URL_LOGIN]
//#define kLoginURLV1             [NSString stringWithFormat:@"%@/woo/api/v1",BASE_URL_LOGIN]
//#define kLoginURLV2             [NSString stringWithFormat:@"%@/woo/api/v2",BASE_URL_LOGIN]
//#define kLoginURLV4             [NSString stringWithFormat:@"%@/woo/api/v4",BASE_URL_LOGIN]
//#define kLoginURLV5             [NSString stringWithFormat:@"%@/woo/api/v5",BASE_URL_LOGIN]
//#define kLoginURLV2_HTTPS       [NSString stringWithFormat:@"%@/woo/api/v2",BASE_URL_LOGIN]
//#define kLoginURLV3_HTTPS       [NSString stringWithFormat:@"%@/woo/api/v3",BASE_URL_LOGIN]
//#define kBaseURLV1_HTTPS        [NSString stringWithFormat:@"%@/woo/api/v1",BASE_URL]
//#define kBaseURLV2_HTTPS        [NSString stringWithFormat:@"%@/woo/api/v2",BASE_URL]
//#define kBaseURLV3_HTTPS        [NSString stringWithFormat:@"%@/woo/api/v3",BASE_URL]
//#define kBaseURLV4_HTTPS        [NSString stringWithFormat:@"%@/woo/api/v4",BASE_URL]
//
//#else
//#define kAppId_Applozic         @"doubleyou393a25ca31528e80f8c2f"
//#define kLoginURLV3             [NSString stringWithFormat:@"%@woo/api/v3",BASE_URL_LOGIN]
//#define kLoginURLV1             [NSString stringWithFormat:@"%@woo/api/v1",BASE_URL_LOGIN]
//#define kLoginURLV2             [NSString stringWithFormat:@"%@woo/api/v2",BASE_URL_LOGIN]
//#define kLoginURLV4             [NSString stringWithFormat:@"%@woo/api/v4",BASE_URL_LOGIN]
//#define kLoginURLV5             [NSString stringWithFormat:@"%@woo/api/v5",BASE_URL_LOGIN]
//#define kLoginURLV2_HTTPS       [NSString stringWithFormat:@"%@woo/api/v2",BASE_URL_LOGIN]
//#define kLoginURLV3_HTTPS       [NSString stringWithFormat:@"%@woo/api/v3",BASE_URL_LOGIN]
////#define kLoginURLV3_HTTPS       @"https://login-api.getwooapp.com/woo/api/v3"
//#define kBaseURLV1_HTTPS        [NSString stringWithFormat:@"%@/woo/api/v1",BASE_URL]
//#define kBaseURLV2_HTTPS        [NSString stringWithFormat:@"%@/woo/api/v2",BASE_URL]
//#define kBaseURLV3_HTTPS        [NSString stringWithFormat:@"%@/woo/api/v3",BASE_URL]
//#define kBaseURLV4_HTTPS        [NSString stringWithFormat:@"%@/woo/api/v4",BASE_URL]
//
//#endif

#define kLoginBaseURL           BASE_URL@"/"
#define kServerURL              BASE_URL

#define kBaseURLV1              [NSString stringWithFormat:@"%@/woo/api/v1",BASE_URL]
#define kBaseURLV2              [NSString stringWithFormat:@"%@/woo/api/v2",BASE_URL]
#define kBaseURLV3              [NSString stringWithFormat:@"%@/woo/api/v3",BASE_URL]
#define kBaseURLV4              [NSString stringWithFormat:@"%@/woo/api/v4",BASE_URL]
#define kBaseURLV5              [NSString stringWithFormat:@"%@/woo/api/v5",BASE_URL]
#define kBaseURLV6              [NSString stringWithFormat:@"%@/woo/api/v6",BASE_URL]
#define kBaseURLV7              [NSString stringWithFormat:@"%@/woo/api/v7",BASE_URL]
#define kBaseURLV8              [NSString stringWithFormat:@"%@/woo/api/v8",BASE_URL]
#define kBaseURLV9              [NSString stringWithFormat:@"%@/woo/api/v9",BASE_URL]
#define kBaseURLV10             [NSString stringWithFormat:@"%@/woo/api/v10",BASE_URL]
#define kBaseURLV11             [NSString stringWithFormat:@"%@/woo/api/v11",BASE_URL]
#define kBaseURLV12             [NSString stringWithFormat:@"%@/woo/api/v12",BASE_URL]
#define kBaseURLV13             [NSString stringWithFormat:@"%@/woo/api/v13",BASE_URL]
#define kBaseURLV14             [NSString stringWithFormat:@"%@/woo/api/v14",BASE_URL]
#define kBaseURLV15             [NSString stringWithFormat:@"%@/woo/api/v15",BASE_URL]
#define kBaseURLV16             [NSString stringWithFormat:@"%@/woo/api/v16",BASE_URL]
#define kBaseURLV17             [NSString stringWithFormat:@"%@/woo/api/v17",BASE_URL]
#define kBaseURLV18             [NSString stringWithFormat:@"%@/woo/api/v18",BASE_URL]
#define kBaseURLV19             [NSString stringWithFormat:@"%@/woo/api/v19",BASE_URL]
#define kBaseURLV20             [NSString stringWithFormat:@"%@/woo/api/v20",BASE_URL]

//#ifdef kIsLiveServer
//
//////////////////////=======New Dev URL===========////////////////////////////

//#define kLoginBaseURL           @"http://apidev.getwooapp.com/"
//#define kServerURL              @"http://apidev.getwooapp.com"
//#define kLoginURLV3             @"http://apidev.getwooapp.com/woo/api/v3"
//#define kLoginURLV1             @"http://apidev.getwooapp.com/woo/api/v1"
//#define kLoginURLV2             @"http://apidev.getwooapp.com/woo/api/v2"
//#define kLoginURLV4             @"http://apidev.getwooapp.com/woo/api/v4"
//#define kLoginURLV5             @"http://apidev.getwooapp.com/woo/api/v5"
//#define kLoginURLV2_HTTPS       @"http://apidev.getwooapp.com/woo/api/v2"
//#define kBaseURLV1              @"http://apidev.getwooapp.com/woo/api/v1"
//#define kBaseURLV2              @"http://apidev.getwooapp.com/woo/api/v2"
//#define kBaseURLV3              @"http://apidev.getwooapp.com/woo/api/v3"
//#define kBaseURLV4              @"http://apidev.getwooapp.com/woo/api/v4"
//#define kBaseURLV5              @"http://apidev.getwooapp.com/woo/api/v5"
//#define kBaseURLV6              @"http://apidev.getwooapp.com/woo/api/v6"
//#define kBaseURLV7              @"http://apidev.getwooapp.com/woo/api/v7"
//#define kBaseURLV8              @"http://apidev.getwooapp.com/woo/api/v8"
//#define kBaseURLV9              @"http://apidev.getwooapp.com/woo/api/v9"
//#define kBaseURLV10             @"http://apidev.getwooapp.com/woo/api/v10"
//#define kBaseURLV11             @"http://apidev.getwooapp.com/woo/api/v11"
//#define kBaseURLV12             @"http://apidev.getwooapp.com/woo/api/v12"
//#define kBaseURLV13             @"http://apidev.getwooapp.com/woo/api/v13"
//#define kBaseURLV14             @"http://apidev.getwooapp.com/woo/api/v14"
//#define kBaseURLV15             @"http://apidev.getwooapp.com/woo/api/v15"
//#define kBaseURLV16             @"http://apidev.getwooapp.com/woo/api/v16"
//#define kBaseURLV17             @"http://apidev.getwooapp.com/woo/api/v17"
//#define kBaseURLV18             @"http://apidev.getwooapp.com/woo/api/v18"
//
//#define kBaseURLV1_HTTPS        @"http://apidev.getwooapp.com/woo/api/v1"
//#define kBaseURLV2_HTTPS        @"http://apidev.getwooapp.com/woo/api/v2"
//#define kBaseURLV3_HTTPS        @"http://apidev.getwooapp.com/woo/api/v3"
//#define kBaseURLV4_HTTPS        @"http://apidev.getwooapp.com/woo/api/v4"
//
//#define kMessageBaseURLV1       @"http://Messaging-Testing-260255742.ap-southeast-1.elb.amazonaws.com/woo-messaging/api/v1/"

//
//////////////////////=======Callback URL===========////////////////////////////

//#define kLoginBaseURL           @"http://callback.getwooapp.com/"
//#define kServerURL              @"http://callback.getwooapp.com"
//#define kLoginURLV3             @"http://callback.getwooapp.com/woo/api/v3"
//#define kLoginURLV1             @"http://callback.getwooapp.com/woo/api/v1"
//#define kLoginURLV2             @"http://callback.getwooapp.com/woo/api/v2"
//#define kLoginURLV4             @"http://callback.getwooapp.com/woo/api/v4"
//#define kLoginURLV5             @"http://callback.getwooapp.com/woo/api/v5"
//#define kLoginURLV2_HTTPS       @"http://callback.getwooapp.com/woo/api/v2"
//#define kBaseURLV1              @"http://callback.getwooapp.com/woo/api/v1"
//#define kBaseURLV2              @"http://callback.getwooapp.com/woo/api/v2"
//#define kBaseURLV3              @"http://callback.getwooapp.com/woo/api/v3"
//#define kBaseURLV4              @"http://callback.getwooapp.com/woo/api/v4"
//#define kBaseURLV5              @"http://callback.getwooapp.com/woo/api/v5"
//#define kBaseURLV6              @"http://callback.getwooapp.com/woo/api/v6"
//#define kBaseURLV7              @"http://callback.getwooapp.com/woo/api/v7"
//#define kBaseURLV8              @"http://callback.getwooapp.com/woo/api/v8"
//#define kBaseURLV9              @"http://callback.getwooapp.com/woo/api/v9"
//#define kBaseURLV10             @"http://callback.getwooapp.com/woo/api/v10"
//#define kBaseURLV11             @"http://callback.getwooapp.com/woo/api/v11"
//#define kBaseURLV12             @"http://callback.getwooapp.com/woo/api/v12"
//#define kBaseURLV13             @"http://callback.getwooapp.com/woo/api/v13"
//#define kBaseURLV14             @"http://callback.getwooapp.com/woo/api/v14"
//#define kBaseURLV15             @"http://callback.getwooapp.com/woo/api/v15"
//#define kBaseURLV16             @"http://callback.getwooapp.com/woo/api/v16"
//#define kBaseURLV17             @"http://callback.getwooapp.com/woo/api/v17"
//#define kBaseURLV18             @"http://callback.getwooapp.com/woo/api/v18"
//
//#define kBaseURLV1_HTTPS        @"http://callback.getwooapp.com/woo/api/v1"
//#define kBaseURLV2_HTTPS        @"http://callback.getwooapp.com/woo/api/v2"
//#define kBaseURLV3_HTTPS        @"http://callback.getwooapp.com/woo/api/v3"
//#define kBaseURLV4_HTTPS        @"http://callback.getwooapp.com/woo/api/v4"
//
//#define kMessageBaseURLV1       @"http://Messaging-Testing-260255742.ap-southeast-1.elb.amazonaws.com/woo-messaging/api/v1/"

//
//////////////////////=======New Testing URL===========////////////////////////////

//#define kLoginBaseURL           @"http://api-testing-1816224593.ap-southeast-1.elb.amazonaws.com/"
//#define kServerURL              @"http://api-testing-1816224593.ap-southeast-1.elb.amazonaws.com"
//#define kLoginURLV3             @"http://api-testing-1816224593.ap-southeast-1.elb.amazonaws.com/woo/api/v3"
//#define kLoginURLV1             @"http://api-testing-1816224593.ap-southeast-1.elb.amazonaws.com/woo/api/v1"
//#define kLoginURLV2             @"http://api-testing-1816224593.ap-southeast-1.elb.amazonaws.com/woo/api/v2"
//#define kLoginURLV4             @"http://api-testing-1816224593.ap-southeast-1.elb.amazonaws.com/woo/api/v4"
//#define kLoginURLV5             @"http://api-testing-1816224593.ap-southeast-1.elb.amazonaws.com/woo/api/v5"
//#define kLoginURLV2_HTTPS       @"http://api-testing-1816224593.ap-southeast-1.elb.amazonaws.com/woo/api/v2"
//#define kBaseURLV1              @"http://api-testing-1816224593.ap-southeast-1.elb.amazonaws.com/woo/api/v1"
//#define kBaseURLV2              @"http://api-testing-1816224593.ap-southeast-1.elb.amazonaws.com/woo/api/v2"
//#define kBaseURLV3              @"http://api-testing-1816224593.ap-southeast-1.elb.amazonaws.com/woo/api/v3"
//#define kBaseURLV4              @"http://api-testing-1816224593.ap-southeast-1.elb.amazonaws.com/woo/api/v4"
//#define kBaseURLV5              @"http://api-testing-1816224593.ap-southeast-1.elb.amazonaws.com/woo/api/v5"
//#define kBaseURLV6              @"http://api-testing-1816224593.ap-southeast-1.elb.amazonaws.com/woo/api/v6"
//#define kBaseURLV7              @"http://api-testing-1816224593.ap-southeast-1.elb.amazonaws.com/woo/api/v7"
//#define kBaseURLV8              @"http://api-testing-1816224593.ap-southeast-1.elb.amazonaws.com/woo/api/v8"
//#define kBaseURLV9              @"http://api-testing-1816224593.ap-southeast-1.elb.amazonaws.com/woo/api/v9"
//#define kBaseURLV10             @"http://api-testing-1816224593.ap-southeast-1.elb.amazonaws.com/woo/api/v10"
//#define kBaseURLV11             @"http://api-testing-1816224593.ap-southeast-1.elb.amazonaws.com/woo/api/v11"
//#define kBaseURLV12             @"http://api-testing-1816224593.ap-southeast-1.elb.amazonaws.com/woo/api/v12"
//#define kBaseURLV13             @"http://api-testing-1816224593.ap-southeast-1.elb.amazonaws.com/woo/api/v13"
//#define kBaseURLV14             @"http://api-testing-1816224593.ap-southeast-1.elb.amazonaws.com/woo/api/v14"
//#define kBaseURLV15             @"http://api-testing-1816224593.ap-southeast-1.elb.amazonaws.com/woo/api/v15"
//#define kBaseURLV16             @"http://api-testing-1816224593.ap-southeast-1.elb.amazonaws.com/woo/api/v16"
//#define kBaseURLV17             @"http://api-testing-1816224593.ap-southeast-1.elb.amazonaws.com/woo/api/v17"
//#define kBaseURLV18             @"http://api-testing-1816224593.ap-southeast-1.elb.amazonaws.com/woo/api/v18"
//
//#define kBaseURLV1_HTTPS        @"http://api-testing-1816224593.ap-southeast-1.elb.amazonaws.com/woo/api/v1"
//#define kBaseURLV2_HTTPS        @"http://api-testing-1816224593.ap-southeast-1.elb.amazonaws.com/woo/api/v2"
//#define kBaseURLV3_HTTPS        @"http://api-testing-1816224593.ap-southeast-1.elb.amazonaws.com/woo/api/v3"
//#define kBaseURLV4_HTTPS        @"http://api-testing-1816224593.ap-southeast-1.elb.amazonaws.com/woo/api/v4"
//
//#define kMessageBaseURLV1       @"http://Messaging-Testing-260255742.ap-southeast-1.elb.amazonaws.com/woo-messaging/api/v1/"

//#else
//////////////////////=======New Testing URL ENDS=======//////////////////////////

//=====================LIVE URLS STARTS HERE====================
//#define kLoginBaseURL           @"http://login-api.getwooapp.com/"
//#define kServerURL              @"http://api.getwooapp.com/"
//#define kLoginURLV3             @"http://login-api.getwooapp.com/woo/api/v3"
//#define kLoginURLV1             @"http://login-api.getwooapp.com/woo/api/v1"
//#define kLoginURLV2             @"http://login-api.getwooapp.com/woo/api/v2"
//#define kLoginURLV4             @"http://login-api.getwooapp.com/woo/api/v4"
//#define kLoginURLV5             @"http://login-api.getwooapp.com/woo/api/v5"
//#define kLoginURLV2_HTTPS       @"https://login-api.getwooapp.com/woo/api/v2"
//#define kBaseURLV1              @"http://api.getwooapp.com/woo/api/v1"
//#define kBaseURLV2              @"http://api.getwooapp.com/woo/api/v2"
//#define kBaseURLV3              @"http://api.getwooapp.com/woo/api/v3"
//#define kBaseURLV4              @"http://api.getwooapp.com/woo/api/v4"
//#define kBaseURLV5              @"http://api.getwooapp.com/woo/api/v5"
//#define kBaseURLV6              @"http://api.getwooapp.com/woo/api/v6"
//#define kBaseURLV7              @"http://api.getwooapp.com/woo/api/v7"
//#define kBaseURLV8              @"http://api.getwooapp.com/woo/api/v8"
//#define kBaseURLV9              @"http://api.getwooapp.com/woo/api/v9"
//#define kBaseURLV10             @"http://api.getwooapp.com/woo/api/v10"
//#define kBaseURLV11             @"http://api.getwooapp.com/woo/api/v11"
//#define kBaseURLV12             @"http://api.getwooapp.com/woo/api/v12"
//#define kBaseURLV13             @"http://api.getwooapp.com/woo/api/v13"
//#define kBaseURLV14             @"http://api.getwooapp.com/woo/api/v14"
//#define kBaseURLV15             @"http://api.getwooapp.com/woo/api/v15"
//#define kBaseURLV16             @"http://api.getwooapp.com/woo/api/v16"
//#define kBaseURLV17             @"http://api.getwooapp.com/woo/api/v17"
//#define kBaseURLV18             @"http://api.getwooapp.com/woo/api/v18"
//#define kBaseURLV1_HTTPS        @"https://api.getwooapp.com/woo/api/v1"
//#define kBaseURLV2_HTTPS        @"https://api.getwooapp.com/woo/api/v2"
//#define kBaseURLV3_HTTPS        @"https://api.getwooapp.com/woo/api/v3"
//#define kBaseURLV4_HTTPS        @"https://api.getwooapp.com/woo/api/v4"
//
//#define kMessageBaseURLV1       @"http://msg.getwooapp.com/woo-messaging/api/v1/"


//=====================LIVE URLS ENDS HERE====================

//#endif


//#define kLoginBaseURL           @"http://52.74.129.186:8080/"
//#define kLoginURLV3             @"http://52.74.129.186:8080/woo/api/v3"
//#define kLoginURLV1             @"http://52.74.129.186:8080//woo/api/v1"
//#define kLoginURLV2             @"http://52.74.129.186:8080//woo/api/v2"
//#define kLoginURLV4             @"http://52.74.129.186:8080//woo/api/v4"
//#define kLoginURLV5             @"http://52.74.129.186:8080//woo/api/v5"
//#define kServerURL              @"http://52.74.129.186:8080//"
//#define kBaseURLV1              @"http://52.74.129.186:8080//woo/api/v1"
//#define kBaseURLV2              @"http://52.74.129.186:8080//woo/api/v2"
//#define kBaseURLV3              @"http://52.74.129.186:8080//woo/api/v3"
//#define kBaseURLV4              @"http://52.74.129.186:8080//woo/api/v4"
//#define kBaseURLV5              @"http://52.74.129.186:8080//woo/api/v5"
//#define kBaseURLV6              @"http://52.74.129.186:8080//woo/api/v6"
//#define kBaseURLV7              @"http://52.74.129.186:8080//woo/api/v7"
//#define kBaseURLV8              @"http://52.74.129.186:8080//woo/api/v8"
//#define kBaseURLV9              @"http://52.74.129.186:8080//woo/api/v9"
//#define kBaseURLV1_HTTPS        @"https://10.109.11.105:8080/woo/api/v1"
//#define kMessageBaseURLV1       @"http://msg.getwooapp.com/woo-messaging/api/v1/"

#define kFoneVerifyBaseURLV1        @"http://api.foneverify.com/FoneVerify/v1/"
#define kFoneVerifyBaseURLV1_New    @"http://apifv.foneverify.com/U2opia_Verify/v1.0/flow/"

////////////////////=======New Testing URL  2===========////////////////////////////

//#define kLoginBaseURL           @"http://52.74.129.186:8080/"
//#define kLoginURLV3             @"http://52.74.129.186:8080/woo/api/v3"
//#define kLoginURLV1             @"http://52.74.129.186:8080/woo/api/v1"
//#define kLoginURLV4             @"http://52.74.129.186:8080/woo/api/v4"
//#define kLoginURLV5             @"http://52.74.129.186:8080/woo/api/v5"
//#define kServerURL              @"http://52.74.129.186:8080"
//#define kBaseURLV1              @"http://52.74.129.186:8080/woo/api/v1"
//#define kBaseURLV2              @"http://52.74.129.186:8080/woo/api/v2"
//#define kBaseURLV2x             @"http://52.74.129.186:8080/woo/api/v2"
//#define kBaseURLV3              @"http://52.74.129.186:8080/woo/api/v3"
//#define kBaseURLV4              @"http://52.74.129.186:8080/woo/api/v4"
//#define kBaseURLV5              @"http://52.74.129.186:8080/woo/api/v5"
//#define kBaseURLV6              @"http://52.74.129.186:8080/woo/api/v6"
//#define kBaseURLV7              @"http://52.74.129.186:8080/woo/api/v7"
//#define kBaseURLV8              @"http://52.74.129.186:8080/woo/api/v8"
//#define kBaseURLV9              @"http://52.74.129.186:8080/woo/api/v9"
//#define kBaseURLV10             @"http://52.74.129.186:8080/woo/api/v10"
//#define kBaseURLV1_HTTPS        @"http://52.74.129.186:8080/woo/api/v1"
//#define kMessageBaseURLV1       @"http://Messaging-Testing-260255742.ap-southeast-1.elb.amazonaws.com/woo-messaging/api/v1/"


//API methods


#define kSwrveLandingScreenKey                  @"LANDING_SCREEN"
#define kVoIPInviteKey                          @"WOOVIP_INVITE"
#define kDiscoverLandingNotification            @"discoverLanding"
#define kMeLandingNotification                  @"meLanding"
#define kVisitorLandingNotification             @"visitorLanding"
#define kLikedMeLandingNotification             @"likedMeLanding"
#define kCrushLandingNotification               @"crushLanding"
#define kSkippedProfileLandingNotification      @"skippedLanding"
#define kQuestionsLandingNotification           @"questionsLanding"
#define kMatchboxLandingNotification            @"matchboxLanding"
#define kPurchaseLandingNotification            @"purchaseLanding"
#define kBoostPurchaseLandingNotification       @"boostPurchaseLanding"
#define kCrushPurchaseLandingNotification       @"crushPurchaseLanding"
#define kWooPlusPurchaseLandingNotification     @"wooPlusPurchaseLanding"
#define kWooGlobePurchaseLandingNotification    @"wooGlobePurchaseLanding"
#define kInviteScreenLandingNotification        @"INVITE_CODE"
#define kFeedBackScreenLandingNotification       @"PREFERENCE_FEEDBACK_LANDING"
#define kEditProfileLandingNotification         @"editProfileLanding"
#define kChatBoxLandingNotification             @"chatboxLanding"
#define kDiscoverSettingsLandingNotification    @"discoverSettingsLanding"
#define kAppSettingsLandingNotification         @"appSettingsLanding"
#define kAppStoreLandingNotification            @"appStoreLanding"
#define kTagBubbleScreenLandingNotification     @"tagBubbleScreenLanding"
#define kAppSettingsHasBeenFetchedFromServer    @"appSettingsHasBeenFetchedFromServer"
#define kDismissPresentedViewController         @"dismissPresentedViewController"
#define kMatchDataUpdatedInDPV                  @"matchDataUpdatedInDPV"
#define kVisitorContentGuidelinesLandingNotification             @"contentGuidelinesLanding"


#define LoginViaFacebook @"FACEBOOK_LOGIN"
#define LoginViaFacebookAccountKit @"FACEBOOK_ACCOUNT_KIT"
#define LoginViaTrueCaller @"TRUE_CALLER"
#define LoginViaNativeOTP @"NATIVE_OTP"
#define LoginViaFirebase @"FIREBASE_LOGIN"
#define LoginViaAppple @"APPLE_LOGIN"

#define kRegistrationCall                       @"/user/activity/register"
#define kLoginCall                              @"/user/activity/login"
#define kCheckWooFakeUser                       @"/user/check/isFake/"
#define kCheckWooFakeUserTest                   @"/user/fake"
#define kDeviceDataCall                         @"/device/data/"
#define kFCMAPICall                             @"/save/firebaseToken/"
#define kUserLocationCall                       @"/user/location"
#define kUpdateUserAlbum                        @"/user/updateWooAlbum/"
#define kImageGoogleCheck                       @"/user/photo/googleImageResult"
#define kGetWooAlbum                            @"/user/wooAlbum/"
#define kGetDiscoverData                        @"/user/activity/discover"
#define kGetUserProfile                         @"/user/activity/profile/"
#define kLikeAProfile                           @"/user/activity/like/"
#define kDisLikeAProfile                        @"/user/activity/disLike/"
#define kFlagAProfile                           @"/user/activity/flag/"
#define kUploadFileToServer                     @"/user/uploadfile/"
#define kUploadLoggingFile                      @"/upload/statFile"
#define kUpdateUserProile                       @"/user/activity/profile/"
#define kIntroduceMeAPI                         @"/user/introduceMe/"
#define kIntroducedAPI                          @"/user/introduced/"
#define kGetNotifications                       @"/user/notifications/"
#define kdeleteAMatch                           @"/user/deletematch/"
#define kPostAChatMessage                       @"messages?"
#define kFetchChatMessages                      @"messages"
#define kLogoutUser                             @"/user/activity/logout"
#define kDeleteUser                             @"/user/activity/delete/"
#define kDisableUser                             @"/user/activity/disable/"
#define kUserFeedback                           @"/feedback"
#define kPaywallAPI                             @"/payWall"
#define kPurchaseAPI                            @"/purchases"
#define kReedemCodeAPI                          @"/redeem"
#define kAboutMeTags                            @"/user/aboutMeOptions"
#define kFacebookSyncAPI                        @"/user/activity/profile/syncWithFacebook/"
#define kFacebookSyncAPIv2                      @"/sync/facebook"
#define kDeleteNotificationFromServer           @"/user/notifications/status"
#define kAppLaunchAPI                           @"/appLaunch/"
#define kImageVerificationAPI                   @"/user/isFakePhoto/"
#define kFetchNewToken                          @"/user/security/token"
#define kUploadPictures                         @"/user/uploadPhoto"
#define kDeletePicture                          @"/user/deletePhoto"
#define kValidateUploadedPicture                @"/user/photo/validate"
#define kGetUserAlbums                          @"/user/fbAlbum"
#define kGetTemplateQuestions                   @"/templateQuestions"
#define kPostQuestion                           @"/questions"
#define kqnaPostAnswer                          @"/wooQuestionAnswer/postWooAnswer?"
#define kqnaUpdateAnswer                        @"/wooQuestionAnswer/updateWooAnswer?"
#define kqnaReplaceQuestion                     @"/wooQuestionAnswer/updateWooQuestion?"
#define kGetUserProfileTags                     @"/user/profileOptions/"
#define kQuestion                               @"/questions/"
#define kAnswers                                @"/answers/"
#define kReportAnswer                           @"/reportedAnswers/"
#define kReportQuestion                         @"/reportedQuestions/"
#define kDiscoveredQuestions                    @"/discoveredQuestions"
#define kCustomNotification                     @"/user/customNotifications"
#define kCustomNotificationUpdate               @"/user/customNotification"
#define kStickersAPI                            @"/stickers"
#define kAnswerSeenAPI                          @"/questions"
#define kVerifyCodeAPI                          @"/inviteUser/verifyCode"
#define kRequestCodeAPI                         @"/inviteUser/requestCode"
#define kUserStatusAPI                          @"/inviteUser/userStatus"
#define kUserFavouriteAPI                       @"/matches/favourite"
#define kSwrveUpdateCall                        @"/swrve"
#define kBrandCardSeenAPI                       @"/brandCard/"
#define kSelectionCardSeenAPI                   @"/user/selection/save"
#define kGetProductsFromServer                  @"/getProduct/"
#define kGetPurchaseProductsDetailFromServer    @"/getProduct/new"
#define kPurchaseProduct                        @"/user/product/purchase"
#define kActivateBoost                          @"/user/boost/activate"
#define kCrushDashboardAPI                      @"/dashboard/crush/"
#define kBo  ostDashboardAPi                      @"/dashboard/boost/"
#define kVisitorDashboardAPI_New                @"/dashboard/visitor/"
#define kLocationOptionsCall                    @"/location/options"
#define kAppConfigSyncCall                      @"/app/config/sync"
#define kIntentPreferenceCall                   @"/user/preferences/"
#define kUpdateUserAgeGender                    @"/user/update/"
#define kLoginErrorFeedback                     @"/feedback/new"
#define kStartScreenDone                        @"/user/startScreen"
#define kSendSounchPreferencesToServerAPI       @"/user/setting/notification/sound"
#define kGetTagsFromServerAPI                   @"/user/tags"
#define kPostRelationshipTagsToServerAPI                   @"/user/relationShipLifestyleTags"
#define kPostZodiacTagToServerAPI                   @"/user/zodiacTags"
#define kLikedMeDashboardAPI                    @"/dashboard/likedMe"
#define kSkippedProfileDashboardAPI             @"/dashboard/skippedProfiles/"
#define kLikedByMeDashboardAPI             @"/dashboard/likedByMe"
#define kNotificationPreferences                @"/user/preferences"
#define kGetWooQuestions                   @"/wooQuestionAnswer/getWooQuestion"
#define kUpdateNotificationPreferences          @"/user/app/settings"
#define kPurchaseEventAPI                       @"/event/"
#define kGenerateOTP                            @"/generateOtp"
#define kVerifyOTP                              @"/verify/otp"
#define kVerifyPhoneNumber                      @"/verify/phoneNumber"

#define kFoneVerificationCallDIDAPI            @"callDID"
#define kFoneVerificationStatusCheckAPI        @"status"
#define kFoneVerificationSendSmsToPhoneAPI     @"sms"
#define kFoneVerificationVerifyOtpAPI          @"verification"
#define kSaveVerifiedNumberOnServerAPI            @"/foneverify/saveMsisdn"

#define kFoneVerificationSendSmsToPhoneAPI_New  @"sms"
#define kFoneVerificationVoiceAPI_New         @"voice"
#define kFoneVerificationUpdateAPI_New          @"update"
#define kVoiceCallInitiationEvent               @"VOICE_CALL_INITIATOR"

#define kCheckChatServerOfUserAPI              @"/receiver/messaging/server/"
#define kAuthenticateLayerWithServerAPI        @"/auth/nonce/"
#define kDirectMessageAPI                      @"/user/activity/like/"
//#define kLikeAnserAPI                          @"/answers/%@/activity"
#define kAcknowledgement                       @"/acknowledgement"
#define kGetTemplateCrush                   @"/crush/templates/"
#define kSendInvitation                     @"/invited"
#define kGetInvitation                      @"/friends/invite"
#define kGetInviteCampaign                  @"/inviteCampaign"
#define kTrackVoIPInvite                    @"/invite/tracking"

#define KSendAboutMeText                    @"/user/aboutme"
#define kSendConfirmUser                    @"/user/activity/login/done/"

#define kSyncProfileViews                    @"/user/activity/view/"
#define kGetChannelKeyForCall               @"/app/agora/channelKey"
#define kSendVoipPushApn                @"/send/voip/push"
#define kTagSearchSource                @"TagSearchSource"

//On-boarding configurable
#define kShowMyProfileScreen                    @"showMyProfileScreen"
#define kshowNoUserNoPicScreen                    @"showNoUserNoPicScreen"
#define kshowGridScreen                         @"showGridScreen"

#define kDislikeSourceKey               @"source"
#define kDislikeSubSourceKey               @"subSource"

#define kDislikeSourceDiscoverValue               @"DISCOVER_VIEW"
#define kDislikeSourceProfileValue               @"PROFILE_VIEW"
#define kDislikeSubSourceDislikeValue               @"DISLIKE"
#define kDislikeSubSourcePassValue               @"PASS"

#define kInviteSourceWhatsApp                     @"WHATSAPP"
#define kInviteSourceMessage                      @"SMS"
#define kInviteSourceEmail                        @"EMAIL"
#define kverifyPhoneNumber                      @"foneverify/verify/otp"




// Reasons for reporting user

//Viewcontrollers
#define kLoginViewControllerID                  @"LoginViewControllerID"
#define kLoginNavigationControllerID            @"LoginNavigationControllerID"
#define kRightPanelViewControllerID             @"RightPanelViewControllerID"
#define kPurchaseViewControllerID               @"PurchaseViewController"
#define kSubmitNumberControllerID               @"SubmitNumberControllerID"
#define kAlmostThereControllerID                @"AlmostThereControllerID"
#define kSMSCodeVerificationControllerID        @"SMSCodeVerificationControllerID"
#define kPowerUpViewControllerID                @"PowerUpViewControllerID"
#define kPurchaseOptionViewControllerID         @"PurchaseOptionViewControllerID"
#define kSearchLocationViewControllerID         @"SearchLocationViewControllerID"
#define kIntentScreenControllerID               @"PushToIntentScreen"
#define kTagScreenControllerID                  @"PushToTagScreen"
#define kAboutMeScreenControllerID              @"PushToAboutMeScreen"
#define kPermissionScreenControllerID           @"PushToPermissionScreen"
#define kBoatScreenControllerID                 @"PushToBoatScreen"
#define kConfirmUserControllerID                @"PushToConfirmUser"
#define kFacebookAlbumControllerID              @"PushToFacebookAlbum"
#define kFacebookPhotoControllerID              @"FacebookPhotoViewController"
#define kAgeGenderControllerID                  @"AgeGenderViewController"
#define kLoginLoadingControllerID               @"LoginLoadingViewController"
#define kPushToLoginLoadingController           @"PushToLoginLoadingViewController"
#define kPushToFindTagView                      @"PushToFindTagView"
#define kPushToCrushViewController              @"PushToCrushViewController"
#define kPresentSkippedProfile                  @"PresentSkippedProfile"
#define kPresentLikedByMeProfile                @"PresentLikedByMeProfile"
#define kPushToMyQuestionsController            @"MeToMyQuestionSegue"


//LikesandVisit
#define kFromlikedMe     @"likedMe"
#define kFromvistors      @"Vistors"


//Segues
#define kPushToVerificationViewControllerSegue      @"pushToVerificationViewController"
#define kPushToConfirmProfileViewContollerSegue     @"pushToConfirmProfileViewContoller"
#define kPushToConfirmProfileViewContollerFromLogin @"pushToConfirmProfileViewContollerFromLogin"
#define kPushToProfileDetailScreen                  @"ProfilePushSegue"
#define kPushMatchesToChats                         @"MatchesToChatSegue"
#define kPushChatRoomToChats                        @"ChatRoomsToChatSegue"
#define kPushToPurchaseViewControllerSegue          @"pushToPurchaseViewController"
#define kPushToUserProfileFromCrushDashboard        @"PushToMyProfileFromCrushPanelSegue"

#define kPushToProfileView                          @"DiscoverToUserProfileSegue"
#define kPushToNotificationView                     @"DiscoverToNotificationSegue"
#define kPushToSettingsView                         @"DiscoverToSettingsSegue"
#define kPresentPurchaseView                         @"DiscoverToPurchaseSegue"
#define kPushToMatchboxView                         @"DiscoverToMatchboxSegue"
#define kMatchboxToAskQuestionView                  @"MatchboxToAskQuestionSegue"
#define kPushToImagesGalleryFromProfile             @"UserProfileToGallerySegue"
#define kPresentPowerupsSegue                       @"DiscoverToPowerupSegue"
#define kPresentCrushPanelSegue                     @"DiscoverToCrushPanelSegue"
#define kPresentVisitorPanelSegue                   @"DiscoverToVisitorPanelSegue"


#define kPushToLifestyleScreen                      @"PushToLifestyleSelectionScreen"
#define kPushToPersonalityScreen                    @"PushToPersonalitySelectionScreen"
#define kAskToTypeQuestionScreen                    @"AskToTypeSegue"
#define kPassionsToPassionSelection                 @"passionsToPassionSelection"
#define kMatchBoxToAnswersScreen                    @"MatchboxToAnswersSegue"
#define kDiscoverToAskSegue                         @"discoverToAskSegue"
#define kPushToProfileFromAnswerSegue               @"PushToProfileFromAnswer"
#define kAutoReadCodeAndMakeServerCall              @"autoReadCodeAndMakeServerCall"
#define kAutoReadCodeAndFillCode                    @"autoReadCodeAndFillCode"
#define kPresentPurchaseOptionVCSegue               @"PresentPurchaseOptionVCSegue"
#define kPushToProfileFromVisitor                   @"PushToProfileFromVisitor"
#define kPushToMyPurchaseViewControllerID           @"PushToMyPurchase"
#define kPushToVisitorViewController                @"PushToVisitorViewController"
#define kPushToLikedMeViewController                @"PushToLikedMeViewController"
#define kPushFromVisitorToDetailProfileView         @"PushFromVisitorToDetailProfileView"
#define kPushFromLikedMeToDetailProfileView         @"PushFromLikedMeToDetailProfileView"
#define kPushFromCrushToDetailProfileView           @"PushFromCrushToDetailProfileView"

#define kPushFromBundledExpiryToDetailProfileView         @"PushFromBundledExpiryToDetailProfileView"

#define kPushToDetailProfileFromChatRoom            @"PushToDetailProfileFromChatRoom"
#define kPushToChatFromMatchbox                     @"PushToChatFromMatchbox"
#define kPushToChatFromDiscover                     @"PushToChatFromDiscover"
#define kPushToChatFromDetailProfileView            @"PushToChatFromDetailProfileView"
#define kPushtFromSkippedProfileToDetailProfileView @"PushtFromSkippedProfileToDetailProfileView"
#define kPushToChatFromAnswerScreenOverlay          @"PushToChatFromAnswerScreenOverlay"
#define kPushToChatFromVisitor                      @"PushToChatFromVisitor"
#define kPushToChatFromLikedMe                      @"PushToChatFromLikedMe"
#define kPushToChatFromSkippedProfile               @"PushToChatFromSkippedProfile"
#define kPushToChatFromExpiryCollectionViewProfile  @"PushToChatFromExpiryCollectionViewProfile"
#define kPushToChatFromAnswer                       @"PushToChatFromAnswerScreenOverlay"
#define kPushToChatFromQuestions                    @"PushtoChatFromQuestions"
#define kPushToChatFromCrushPanel                   @"PushToChatFromCrushView"

// THESE HAVE TO BE REMOVED

//-------------------------- to be removed ends here -----------------------



//Story board ID

#define kConfirmProfileViewControllerID @"ConfirmProfileViewControllerID"



//fb subcode : used in login view
#define kSwitchToSettingTag 13

#define kFBOAuthError                    = 190;
#define kFBAPISessionError               = 102;
#define kFBAPIServiceError               = 2;
#define kFBAPIUnknownError               = 1;
#define kFBAPITooManyCallsError          = 4;
#define kFBAPIUserTooManyCallsError      = 17;
#define kFBAPIPermissionDeniedError      = 10;
#define kFBAPIPermissionsStartError      = 200;
#define kFBAPIPermissionsEndError        = 299;
#define kFBSDKRetryErrorSubcode          = 65000;
#define kFBSDKSystemPasswordErrorSubcode = 65001;

//test

#define kDeviceType @"IPHONE"
#define kDeviceToken @"UserPushDeviceToken"

//Total time is 22 sec
#define kProgressState1_Value 0
#define kProgressState2_Value 30        //4 sec
#define kProgressState3_Value 65        //6 sec
#define kProgressState4_Value 98        //8 sec
#define kProgressState5_Value 100       //4 sec

#define kVerfifcationProgressViewFrame CGRectMake(36.5, 250, 247, 10)



// Login API Response Key
#define kAboutMeInfoDto                     @"aboutMeInfoDto"
#define kData                               @"data"
#define kDefault                            @"default"
#define kAboutMePlaceHolder                 @"text"
#define kAboutMeMaxCharLength               @"maxCharLength"
#define kAboutMeMinCharLength               @"minCharLength"

#define kRequired                           @"required"
#define kPhotoFoundFromFacebook             @"photoFoundFromFacebook"
#define kLocationFound                      @"locationFound"
#define kLocationTimeOut                    @"locationTimeout"
#define kWooToken                              @"wooToken"

#define kAge                                @"age"
#define kBirthday                           @"birthday"
#define kProfilePicUrl                           @"profilePicUrl"
#define kChatSoundOn                           @"chatSoundOn"
#define kConfirmed                              @"confirmed"
#define kOnBoardingPassed                       @"onboardingPassed"
#define kIsUserRegistered                       @"isUserRegistered"
#define kisNewUserNoPicScreenOn                       @"isNewUserNoPicScreenOn"
#define kisPhotoScreenGridOn                       @"isPhotoScreenGridOn"
#define kuserLifestyleTagsAvailable                       @"userLifestyleTagsAvailable"
#define kuserOtherTagsAvailable                       @"userOtherTagsAvailable"
#define kuserRelationshipTagsAvailable                       @"userRelationshipTagsAvailable"
#define kuserZodiacTagsAvailable                       @"userZodiacTagsAvailable"

#define kGender                                 @"gender"
#define kHidden                             @"hidden"
#define kWooUserId                          @"id"
#define kIntentDto                          @"intentDto"
#define kAgeDifferenceThreshold             @"ageDifferenceThreshold"
#define kLove                               @"love"
#define kFriends                            @"friends"
#define kCasual                             @"casual"
#define kFavIntent                          @"favIntent"
#define kMaxAge                             @"maxAge"
#define kMinAge                             @"minAge"
#define kInterestedGender                   @"interestedGender"
#define kMaxDistance                        @"maxDistance"
#define kOtherSoundOn                       @"otherSoundOn"
#define kProfileCompletenessScore           @"profileCompletenessScore"
#define kStartScreenDto                     @"startScreenDto"
#define kUserTagAvailable                   @"userTagAvailable"
#define kStartScreenBody                    @"body"
#define kStartScreenButtonText              @"buttonText"
#define kStartScreenFooter                  @"footer"
#define kStartScreenImageUrl                @"iosImgUrl"
#define kStartScreenTitle                   @"title"
#define kMaxAllowedWoo                      @"maxAllowedWoo"
#define kMinAllowedWoo                      @"minAllowedWoo"

#define kphotoCountThresholdForWizard       @"photoCountThresholdForWizard"
#define kappLozicUserId       @"appLozicUserId"
#define kappLozicToken       @"appLozicToken"
#define kisAppLozicServer    @"APPLOZIC"
#define kDummyApplozicChatID @"abc0d1e2-34f5-6g7h-8910-i11121314151"
#define ktagsCountThresholdForWizard        @"tagsCountThresholdForWizard"
#define kLocationOptions                    @"locationOptions"

// My Purchase
#define kPurchaseType                           @"productType"
#define kIsPurchased                            @"isPurchased"
#define kIsActive                               @"isActive"
#define kPurchaseCount                          @"purchaseCount"
#define kPurchaseTypeBoost                      @"BOOST"
#define kPurchaseTypeCrush                      @"CRUSH"
#define kPurchaseTypeWooPlus                    @"WOOPLUS"
#define kPurchaseTypeWooGlobe                    @"WOOGLOBE"

#define kMyPurchaseContent                      @"content"
#define kMyPurchaseTitle                        @"title"

#define kPurchaseProductBoostDto                @"boostDto"
#define kPurchaseProductCrushDto                @"crushDto"
#define kPurchaseProductWooPlusDto              @"wooPlusDto"
#define kPurchaseProductWooGlobeDto              @"wooGlobeDto"
#define kPurchaseProductBackGroundImages        @"backGroundImages"
#define kPurchaseProductBaseUrl                 @"baseImageUrl"
#define kPurchaseProductCarousalType            @"carousalType"
#define kPurchaseProductCarousals               @"carousals"
#define kPurchaseProductCircleImage             @"circleImage"
#define kPurchaseProductWooProductDto           @"wooProductDto"
#define kProductsLastUpdatedTime                @"productsLastUpdatedTime"
#define kIsToShowMostPopular                    @"isToShowMostPopular"
//Drop off keys
#define kMaxCountInDay                          @"maxCountInDay"
#define kMaxCountInLifeTime                     @"maxCountInLifeTime"
#define kComboProductDto                        @"comboProductDto"


//User Default Keys
#define kUserInfo                              @"userInfo"
#define kIsUserFake                            @"isUserFake"
#define kWooUserId                             @"id"
#define kSwrveUserId                           @"swrveUserId"
#define kWooUserName                           @"wooUserName"
#define kFacebookNumbericUserID                @"fbNumericID"
#define kWooUserGender                         @"wooUserGender"
#define kWooProfilePicURL                      @"wooProfilePicURL"
#define kIsLoginProcessCompleted               @"isLogginProcessCompleted"
#define kWooLoggedInTime                       @"userLoggedInTime"


#define kIsUserRegisteredOnServer              @"isUserRegistered"
#define kLastVerificationState                 @"lastVerificationState"
#define kMyMatchesUpdatedKey                   @"myMatchesUpdate"
#define kMinAgePreference                      @"minAge"
#define kMinAgePreferenceEdited                @"minAgeEdited"
#define kMadeALike                @"madeALike"

#define kIsCommon                               @"isCommon"

#define kMaxAgePreference                      @"maxAge"
#define kMaxAgePreferenceEdited                      @"maxAgeEdited"

#define kMaxDistanceEdited                           @"maxDistanceEdited"

#define kGenderPreference                      @"interestedGender"
#define kGenderPreferenceEdited                      @"interestedGenderEdited"

#define kLocationOptions               @"locationOptions"
#define kProfileHidingPreference               @"isHidden"
#define kProfileHidingPreferenceEdited               @"isHiddenEdited"

#define kLastLocationUpdatedTime               @"lastLocationUpdatedTime"
#define kLastLocationUpdatedTimeFromSettings               @"kLastLocationUpdatedTimeFromSettings"
#define kIsPreferencesChanged                  @"isPreferencesChanged"
#define kNotificationTapped                    @"notificationTapped"
#define kLastNotificationID                    @"lastNotificationID"
#define kFirstTimeLaunch                       @"AppLaunchedForTheFirstTime"
#define kRightPanelNotificationID              @"id"
#define kRightPanelCellImageKey                @"rightPanelCellImage"
#define kRightPanelCellTextKey                 @"cellTextKey"
#define kRightPanelCellDateText                @"notificationDateText"
#define kRightPanelShouldHighlightDate         @"shouldHighlightDate"
#define kRightPanelIsRead                      @"rightPanelReadOrNot"
#define kRightPanelCellNotificationType        @"type"
#define kRightPanelTargetKey                   @"targetId"
#define kRightPanelFriendID                    @"friendId"
#define kRightPanelCellAdditionalData          @"additionalData"
#define kRightNotificationPanelHiddenDataArray @"hiddenDataArray"
#define kRightNotificationPanelDataAray        @"notifications"
#define kRightNotificaitonPanelDeleteKey       @"deleteArray"
#define kRightNotificationPanelUpdateKey       @"updateArray"
#define kRightNotificationPanleInsertKey       @"insertArray"
#define kSelectOneKey                          @"Select"
#define kServerTimestampKey                    @"lastMatchUpdateTime"
#define kCrushDashboardTimestampKey            @"kCrushDashboardUpdateTimestamp"
#define kPurchaseProductDetailTimestamp        @"kPurchaseProductDetailTimestamp"

#define kQualityScore                          @"qualityScore"
#define kMatchesTimestampKey                   @"matchesTimestamp"
#define kMatchesFetchedAfterUpdateTo1_1        @"AppUpdated"
#define kUserAboutTagsTimestamp                @"userAboutTagsTimestamp"
#define kTagIDKey                              @"id"
#define kUserAboutTags                         @"userAboutTags"
#define kUserLastLocationKey                   @"userLastLocation"             //Saves last location on disk and unable to get location.
#define kOpenPredictionLeastAtleastOnce        @"OpenPredictionLeastAtleastOnce"
#define kUserLastLocationTimeStampKey          @"userLastLocationTimeStamp"   //Saved last saved location time and uses to check if the last saved location is saved lass than 24 hours
#define kIsUserBlacklisted                     @"blackListed"
#define kBoostDashboardTimestampKey            @"boostDashboardUpdateTimestamp"
#define kLikedMeDashboardTimestampKey          @"likedMeDashboardTimestampKey"
#define kSkippedProfileDashboardTimeStampKey   @"skippedProfileDashboardTimeStampKey"
#define kLikedByMeProfileDashboardTimeStampKey   @"likedByMeProfileDashboardTimeStampKey"


#define kGoogleReferenceId                      @"googleReferenceId"


#define kMessagesSoundPreference               @"messagesSoundPreferences"
//#define kMessagesAlertsPreference              @"AlertSoundPreferences"
#define kMatchesSoundPreferences               @"matchesPreferences"

#define kNumberOfTimesCropButtonBlinked        @"numberOfTimesCropButtonBlinked"
#define kIsUserNumberVerified                  @"isUserNumberVerified"
#define kUserShouldGetNewProfilesAsIncentive   @"userShouldGetNewProfilesAsIncentive"
#define kShouldMoveToMatchBoxScreen            @"shouldMoveToMatchBoxScreen"


#define kDisableResendSMSButtonTime            @"disableResendSMSButtonTime"
#define kNumberOfTimeResendButtonTappedForDay  @"numberOfTimeResendButtonTapped"

#define kfirstTimeAppLaunchesOnDevice          @"firstTimeAppLaunchesOnDevice"
#define kLastTimeRatePopWasShowm               @"lastTimeRatePopWasShown"
#define kIsAppRated                            @"isAppRated"
#define kUserFBName                            @"userFBName"

#define kProfileImageObj                       @"profileImageObj"

#define kIsUserOnLayerChatOnly                 @"isUserOnLayerChat"
#define kUserAlreadyRegistered                 @"userAlreadyRegistered"
#define kUserAlreadyRegistered_V3              @"userAlreadyRegistered_V3"

#define kIsLayerclientInitialisedKey           @"isLayerClientInitialised"

#define kTotalNumberOfProfileForADay           @"totalProfilesCount"

#define kPhotoUploadOptions                    @"photoUploadOptions"
#define kIsCameraEnable                        @"cameraEnable"
#define kIsFacebookEnable                      @"facebookEnable"
#define kIsGalleryEnable                       @"galleryEnable"

#define kNumberOfDirectMessageSent             @"messagesConsumedToday"
#define kIsTagSelected                         @"isTagSelected"
#define kTimeUserWasFirstLandedOnDiscoverAfterLogginIn      @"timeUserWasFirstLandedOnDiscoverAfterLogginIn"
#define kNeedtoShowYayScreen                   @"needtoShowYayScreen"
#define kNeedtoShowUploadPhotoScreen           @"needtoShowUploadPhotoScreen"
#define kTutorialNotShown                      @"tutorialNotShown"
#define kFoneVerifyDto                         @"foneVerifyDto"
#define kAnswerCharacterLimit                  @"qaAnswerCharLimit"
#define kQuestionCharacterLimit                @"qaQuestionCharLimit"
#define kQuestionsLimit                        @"qaQuestionLimit"
#define kQuestionsAskedToday                   @"questionsAskedToday"
#define kAnswersLimit                          @"qaAnswerLimit"
#define kLinkedInEnabled                       @"linkedInEnable"
#define KIsChatEnabled                         @"isChatEnabled"
#define kisVoiceCallingOnForIOS                @"isVoiceCallingOnForIOS"
#define kCallingEnabled                        @"isVoiceCallingEnabled"
#define kvoiceCallingPopUpEnabled              @"voiceCallingPopUpEnabled"
#define kinviteCampaignUpdatedTime             @"inviteCampaignUpdatedTime"
#define kDisableFP                             @"disableFP"

#define kMaxResultAllowedForSuccessImageCheckOnGoogle @"maxResultAllowedForSuccessImageCheckOnGoogle"
#define kProfileOptionUpdateTimestamp          @"profileOptionsUpdatedTime"
#define kCountryDtoLastUpdatedTimestamp        @"countryDtoLastUpdatedTime"
#define kTipsUpdateTimestamp                   @"tipsUpdatedTime"
#define kCreatedTime                            @"createdTime"
#define kMaxLikeToShowLikeMeter                 @"maxLikeToShowLikeMeter"
#define kProfileWidgets                     @"profileWidgets"
#define kLikeGivenToday                         @"likeGivenToday"
#define kDeleteSkippedProfilesDays              @"deleteSkippedProfilesDays"
#define kDeleteProfilesOtherThanSkippedDays     @"deleteProfilesOtherThanSkippedDays"
#define kSellingMessageUpdateTime               @"sellingMessageUpdateTime"
#define kMeSectionProfileExpiryDays             @"meSectionProfileExpiryDays"
#define kMeSectionExpiredProfilesDaysThreshold           @"meSectionExpiredProfilesDaysThreshold"
#define kMeSectionProfileExpiryDaysThreshold    @"meSectionProfileExpiryDaysThreshold"

//#define kTipsData                              @"tipsData"
#define kCrushTemplateData                              @"crushTemplateData"
#define kFaqUrl                                @"faqUrl"
#define kTermsConditionUrl                      @"termUrl"
#define kPrivacyUrl                             @"privacyUrl"
#define kSwrveStatus                           @"swrveStatus"
#define kUpgradeText                            @"upgradeText"
#define kUpgradepopupHeader                     @"New Update Available"
#define kNormalUpgradepopupcontent       @"There is a newer version of app available please update it now to use new features."
#define kUpgradepopupcontent             @"We did some major improvements, performance optimisation and security updates. And we won't let users pass without it."
#define kGpsTimeout                             @"gpsTimeout"
#define kWooEncryptionTokenFromServer          @"wooToken"

#define kShouldOpenProfileInEditMode            @"shouldOpenProfileInEditMode"
#define kNeedToShowBoostPurchasedView            @"needToShowBoostPurchasedView"
#define kHasPurchasedCrushCurrently             @"hasPurchasedCrushCurrently"
#define kShowBoostPurchasedView                 @"showBoostPurchasedView"
#define kShouldScrollToLinkedIn                 @"shouldScrollToLinkedIn"
#define kGenericAttributeKey                    @"genericAttributes"
#define kTemplateUpdateTimestampKey             @"lastUpdate"
#define kLocalTemplatesQuestionTimeKey          @"templateUpdateTimestamp"


#define kUserProfileDataKey                     @"userProfileData"
#define kHeightTypeKey                          @"heightType"
#define kHeightTypeInches                       @"INCHES"
#define kUserLifestyleKey                       @"lifeStyle"
#define kUserPersonalityKey                     @"personality"
#define kUserPassiionsKey                       @"passionAndInterests"


#define kUserLifestyleSmoking                 @"Smoking"
#define kUserLifestyleDrinking                @"Drinking"
#define kUserLifestyleFood                    @"Food Pref."

#define kProfileUpdatedOn                       @"profileUpdatedOn"

#define kUserRelationShipStatus                 @"userRelationShipStatus"
#define kUserReligion                           @"userReligion"

#define kVoiceIntroAvailableKey               @"isVoiceIntroAvailable"
#define kLastFbSyncDate                       @"lastFbSyncDate"

#define kIsUserDetailsFetchOnce               @"isUserDetailsFetchedOnce"
#define kLastFilerScreenShowed                @"lastFilerScreenFiler"
#define kShouldReturnToDEOnDone                 @"ShouldReturnToDEOnDone"
#define kNeedToChangeFillerOnViewAppear       @"needToChangeFillerOnViewAppear"
#define kIsProfileCompletenessShown           @"isProfileCompletenessShown"
#define kIsLikedNoneFilerCardShown           @"isLikedNoneFilerCardShown"
#define kIsfirstTimeAutoScrollDone            @"isfirstTimeAutoScrollDone"
//#define kIsFirstAutomaticTagSelectionDone     @"isFirstAutomaticTagSelectionDone"
#define kShowLocationToggle                    @"showLocationToggle"

#define kIsFirstTimeLikeANswerButtonAlertShown @"isFirstTimeLikeANswerButtonAlertShown"
#define kAutoReadPushNotificationKey          @"autoReadPushNotificationKey"

#define kPendingFavListKey                          @"pendingFavListKey"
#define kPendingUnFavListKey                        @"pendingUnFavListKey"
#define kLogintimeOfUser                      @"loginTimeOfUser"
#define kFirstTimeFavouriteGlow                 @"firsttimefavglow"

// Questions Keys
#define kQuestionsArrayKey                  @"listTemplateQuestions"

#define kQuestionTextKey                    @"question"
#define kQuestionIDKey                      @"id"
#define kQuestionTotalAnswers               @"totalAnsReceived"
#define kQuestionUnreadAnswerCount          @"totalAnsUnread"
#define kIsNewQuestionPosted                @"isNewQuestionPosted"
#define kIsTagSearchLimitReachedForToday    @"isTagSearchLimitReachedForToday"

#define kPendingInAppPurchaseURL                   @"pendingInAppPurchaseURL"
#define kPendingReceiptData                         @"pendingReceiptData"

//Answer Keys

#define kUserWooIdKey                   @"wooId"
#define kAnswerIdKey                    @"id"
#define kAnswerTextKey                  @"answer"
#define kQuestionIdKey                  @"questionId"
#define kAnswerCreatedTimestampKey      @"createdTime"
#define kAnswerStatusKey                @"strStatus"
#define kUserFirstNameKey               @"firstName"
#define kUserImageURLKey                @"srcBig"
#define kAnswerReadStatusKey            @"read"

// Woo Plus Renew Key

#define kUserDeniedRenew                @"userDeniedRenew"


#define kEnableInvite                   @"inviteOnlyEnabled"
#define kInviteBlockerEnableDisable     @"inviteBlockerEnableDisable"
#define kIsPushedToInviteScreen         @"isPushedToInviteScreen"
#define kiPhoneInviteText               @"iphoneInviteText"
#define kInviteShareUrl                 @"inviteShareUrl"
#define kMcc                            @"mcc"
#define kMnc                            @"mnc"

#define kIsUpdateVersion2_1             @"isUpgradeVersion2_1"
#define kCheckUpgradeForAll             @"checkUpgradeForAll"
#define kCheckUpgradeFor3_0_2           @"checkUpgradeFor3_0_2"

//unused constant
//#define kQuestionUpdateFor2_0_9         @"questionUpdateFor2_0_9"

#define kYayYouAreInScreenType          @"yayYouAreInScreenType"

#define kLocationHasBeenUpdated      @"locationHasBeenUpdated"
#define kLocationNeedsToBeUpdatedOnServer       @"locationNeedsToBeUpdatedOnServer"
#define KSourceOfLocation               @"sourceOfLocation"
#define kSubSourceOfLocation            @"subSourceOfLocation"

#define kLocationStoredInTheApp       @"locationStoredInTheApp"

// All User defaults here
#define kStoredAccessToken @"storedAccessToken"
#define kStoredfbId @"storedfbId"
#define kUserSubmittedV3Feedback @"userSubmittedV3Feedback"
#define kRemindMePopupTimestampV3 @"remindMePopupTimestampV3"
#define kFirstMAtchOnV3Key @"firstMatchMadeOnV3Key"
//verification text
#define kFirstVerificationText @"Verifying eligibility"
#define kFourthVerificationText @"Yay! You’re in!"


// Login Error Feedback

#define kLoginErrorFeedbackTimeStamp    @"LoginErrorFeedbackTimeStamp"

// Discover text

#define kNoInternetAvailableHeadingText @"No Internet"

#define kNoInternetAvailableHeadingText @"No Internet"


#define kComingSoonToCityHeaderText @"Coming Soon!"
#define kComingSoonToCityText @"Thanks for checking out Woo, %@.\n\nWe’ll be launching in %@ very shortly and you'll be the first one to know!"

#define kProfileCompletenessHeaderText_NoTimer @"Profile Completeness"
#define kProfileCompletenessText_NoTimer @"Meanwhile help us out by completing your profile to help find better matches."


#define kInviteFriendsHeaderText @"The More The Merrier"
//#define kInviteFriendsText @"Invite friends to increase your chances of meeting someone nice."
#define kInviteFriendsText @"When you bring in friends, Woo will show you more interesting people. So go on, maximize your chances of meeting someone."
#define kInviteFriendsButtonText @"Invite Now"

#define kInviteFriendsHeaderText_NoTimer @"The More The Merrier"
#define kInviteFriendsText_NoTimer_SecondParagraph @"Invite friends to increase your chances of meeting someone nice."
#define kInviteFriendsButtonText_NoTimer @"Invite Now"

#define kNarrowPreferencesHeaderText @"Your preferences are too narrow"
#define kNarrowPreferencesText @"We're searching to find you people you'll like, but it'll help if you make your preferences broader."
#define kNarrowPreferencesButtonText @"Go to Settings"


//#define kUpgradeAlertHeaderText @"Upgrade Woo?"
#define kUpgradeAlertDescriptionText @"The new and improved Woo is out. Would you like to upgrade?"
//#define kUpgradeAlertCancelText @"Cancel"
//#define kUpgradeAlertUpgradeText @"Upgrade"

#define kInternetNotAvailableText @"No internet available"

#define kInviteFriendTextAfterFiveLaunchText @"Your next set of profiles will be ready in "
#define kInviteFriendTextAfterFiveLaunchTextSecondMessage_NoTimer @"Please check back in a while for some cool new profiles."


////////////////=============Login text

//#define kMoreDetailNeededText_Title @"Need more details!"
//#define kMoreDetailNeededText_Message @"We need some more details to build \nan accurate Woo profile for you. \nPlease allow Woo to access \nFacebook for this information. \n\nWoo never posts on your wall."
//#define kMoreDetailNeededButtonText @"Authorize Facebook"

//#define kSynchFacebookErrorAlertTitleText @"Authorize Facebook"
//#define kProfilePicsErrorAlertTitleText @"Authorize Facebook"
//#define kProfilePicsErrorAlertMessageText @"Please allow us to access your profile photos in Facebook."




//Font

//#define kProximaNovaFontRegular  @"ProximaNova-Regular"
//#define kProximaNovaFontSemiBold @"ProximaNova-Semibold"
#define kFreeStyleScriptRegular  @"FreestyleScript-Regular"
#define kKGWhenOcenRisesRegular  @"KGWhenOceansRise"



//Theme color

//Verification view






#define kYPosForiPhone5        153
#define kYPosForiPhone4        118
#define kImageTag              199
#define kReligionButtonTag     1
#define kHeightButtonTag       2
#define kCommunityButtonTag    3
#define kMobileNumberButtonTag 4
#define kDiscoverLoaderTag     98769876



// NSNotifications strings
#define kMyProfileButtonTapped                           @"MY_PROFILE_BUTTON_TAPPED"
#define kDiscoverButtonTapped                            @"DISCOVER_BUTTON_TAPPED"
#define kPrefetchImagesForFBAlbum                        @"PREFETCH_FB_ALBUM_IMAGES"
#define kOtherPersonProfileTapped                        @"OTHER_PERSON_PROFILE_TAPPED"
#define kFavedAFriendOnButtonTap                         @"FAVED_A_FRIEND_ON_BUTTON_TAP"
#define kChatsTapped                                     @"CHATS_TAPPED"
#define kNotificationsTapped                             @"NOTIFICATIONS_TAPPED"
#define kMyMatchesTapped                                 @"MY_MATCHES_TAPPED"
#define kSettingsTapped                                  @"SETTINGS_TAPPED"
#define kPreferenceTapped                                @"PREFERRENCE_TAPPED"
#define kConfirmProfileDoneTapped                        @"DONE_BUTTON_TAPPED_ON_CONFIRM_PROFILE"
#define kNotificationCellTapped                          @"NOTIFICATION_CELL_TAPPED"
//#define kSettingsTapped                     @"SETTINGS_TAPPED"
#define kChatCellTapped                                  @"CHAT_CELL_TAPPED"
#define kPushToChatScreen                                @"PUSH_TO_CHAT_SCREEN"
#define kMatchDeletedNotification                        @"MATCH_DELETED_ON_MATCH_SCREEN"
#define kChatRoomMigrationDone                           @"ChatRoomMigrationDone"
//#define kMatchOverlayWillAppear                          @"MATCH_OVERLAY_WILL_APPEAR"
#define kReinitialiseNumberOfTouchesCounter              @"reinitialiseNumberOfTouchesCounter"
#define kUserIsLoggedOut                                 @"userIsLoggedOut"
#define kNotificationForSendMail                         @"SendMailNotification"
#define kNotificationForSendMessage                      @"SendMessageNotification"
#define kNotificationForWhatsappSend                     @"SendWhatsappNotification"
#define kInternetConnectionStatusChanged                 @"InternetConnectionStatusChanged"
#define kPayWallScreenDismissed                          @"payWallScreenDismissed"
#define kChatRoomDeleted                                 @"CHAT_ROOM_DELETED_NOTIFICATION"
//#define kPopFromChatView                                 @"POP_FROM_CHAT_VIEW"
#define kMakeAMoveTapped                                 @"MAKE_A_MOVE_TAPPED"
#define kCatchUpLaterTapped                              @"CATCH_UP_LATER_TAPPED"
#define kMyProfileCellImage                              @"IMAGE_CELL"
#define kMyProfileCellProfileCompleteness                @"PROFILE_COMPLETENESS_CELL"
#define kMyProfileCellName                               @"NAME_CELL"
#define kMyProfileCellDetails                            @"DETAILS_CELL"
#define kMyProfileCellVoiceIntro                         @"VOICE_INTRO_CELL"
#define kMyProfileLinkedinCell                           @"LINKEDIN_CELL"
#define kMyProfileFbSyncCell                             @"FB_SYNC_CELL"
#define kMyProfileCellAskFriends                         @"ASK_CELL"
#define kMyProfileCellReportUser                         @"REPORT_USER"
#define kUserLoggedInSuccessfullyNotification            @"USER_LOGGED_IN"

//this observer is add by akarsh
#define kFirebasePhoneAuthenticationObserver                     @"FirebaseAuthenticationObserver"
#define kGetResultFromFirebaseAuthenticationObserver     @"kGetResultFromFirebaseAuthenticationObserver"
#define kFacebookPhotoLibraryRefreshNotification         @"REFRESH_PHOTO_LIBRARY_NOTIFICATION"
#define kFacebookPhotoLibraryUpdateNotification          @"REFRESH_PHOTO_LIBRARY_UPDATE_NOTIFICATION"
#define kFoneVerifyCallTimerExpires                      @"FoneVerifyCallTimerExpires"
#define kAuthenticationErrorNotification                 @"authenticationErrorNotification"
#define kPhotoPermissionMissingNotification              @"photoPermissionMissingNotification"
#define kBroadcastTypingIndicatorChangeEventNotification @"typingIndicatorDidChangeEventNotification"
#define kBroadcastTypingIndicatorChangeEventNotificationApplozic @"typingIndicatorDidChangeEventNotificationApplozic"
#define kNewConversationAvailableNotification            @"newConversationAvailableNotification"
#define kHeartAnimationEnded                             @"HEART_ANIMATION_ENDED_NOTIFICATION"
#define kUserLoggedInSuccessfullyLoadDiscover            @"USER_LOGGED_IN_LOAD_DISCOVER"
#define kUserLoggedOutSuccessfullyLoadDiscover           @"USER_LOGGED_OUT_LOAD_DISCOVER"
#define kImageAddedMakeConfirmCallAutomatically          @"imageAddedMakeConfirmCallAutomatically"
#define kDoneButtonTappedOnPassions                      @"DONE_BUTTON_TAPPED_FOR_PASSIONS"
#define kDoneButonTappedOnPersonality                    @"DONE_BUTTON_TAPPED_FOR_PERSONALITY"
#define kDoneButtonTappedOnLifestyle                     @"DONE_BUTTON_TAPPED_FOR_LIFESTYLE"
#define kUserSuccessfullyReported                        @"USER_REPORTED_SUCCESSFULLY"
#define kNotificationsFetchedSuccessfully                @"NOTIFICATION_FETCHED_SUCCESSFULLY"
#define kPushToMatchesNotification                       @"PUSH_TO_MATCHES_NOTIFICATION"
#define kCloseNavigationDrawerNotification               @"CLOSE_NAV_DRAWER_NOTIFICATION"
#define kNeedToShowUserFirstDayExperience                @"NeedToShowUserFirstDayExperience"
#define kPhoneNumberVierfiedUpdateView                   @"PHONE_NUMBER_VERIFIED_UPDATE_VIEW"
#define kChatRoomChatSnippetUpdated                      @"CHAT_ROOM_CHAT_SNIPPET_UPDATE"
#define kBoostValueUpdated                               @"BOOST_VALUE_UPDATED"
#define kOpenChatRoomFromTopNotification                 @"OPEN_CHAT_ROOM_FROM_TOP_NOTIFICATION"
#define kNotificationReadByUser                          @"NOTIFICATION_READ_BY_USER"
#define kPushToAnswerViewOnNotificationTap               @"PUSH_TO_ANSWER_ON_NOTIFICATION_TAP"
#define kUnlikeButtonTappedFromUserProfile              @"unlikeButtonTappedFromUserProfile"
#define kUpdateLeftMenu                                 @"updateLeftMenu"
#define kUpdateVisitorView_NewVisitorAdded              @"UpdateVisitorView_NewVisitorAdded"
#define kUpdateLikedMeView_NewLikedMeAdded              @"UpdateLikedMeView_NewLikedMeAdded"
#define kNewVisitorAddedOnPagination                    @"NewVisitorAddedOnPagination"
#define kVoiceCallFailedNotification                    @"VoiceCallFailedNotification"
#define KLoggedInToAgora                                @"LoggedInToAgora"

#define kPaginationCallStarted                          @"PaginationCallStarted"
#define kPaginationCallStopped                          @"PaginationCallStopped"


#define kNewLikedMeProfileAddedOnPagination                    @"NewLikedMeProfileAddedOnPagination"
#define kPaginationCallStartedLikedMe                          @"PaginationCallStartedLikedMe"
#define kPaginationCallStoppedLikedMe                          @"PaginationCallStoppedLikedMe"


#define kNewSkippedProfilesAddedOnPagination                        @"NewSkippedProfilesAddedOnPagination"
#define kNewLikedByMeAddedOnPagination                        @"NewLikedByMeAddedOnPagination"
#define kPaginationCallStartedSkippedProfiles                        @"PaginationCallStartedSkippedProfiles"
#define kPaginationCallStartedLikedByMeProfiles                        @"kPaginationCallStartedLikedByMeProfiles"

#define kPaginationCallStoppedSkippedProfiles                        @"PaginationCallStoppedSkippedProfiles"
#define kPaginationCallStoppedLikedByMeProfiles                        @"PaginationCallStoppedLikedByMeProfiles"



#define kNeedtoMoveToDiscoverAsTagSearchHasBeenPerformed          @"needtoMoveToDiscoverAsTagSearchHasBeenPerformed"

#define kLoaderViewNil                  @"isLoaderViewNil"
#define kDismissTips                    @"dismissTips"

#define kDeepLiking                     @"DeepLinking"
#define kAPNS                           @"APNS"
#define KAPNS_PERMISSION                @"APNS_PERMISSION"
#define KAPNS_PERMISSION_ASKED          @"KAPNS_PERMISSION_ASKED"


//My profile key
#define tagsViewTag           9090
#define kPhotoScrollerViewTag 102938

#define kTappableTagIDKey            @"tagId"
#define kTappableTagNameKey          @"name"
#define kTappableTagTypeKey          @"tagsDtoType"
#define kTappebleTagLabelKey         @"label"
#define kIsTagFromSelf               @"isTagFromSelf"

#define kIsTaggable                  @"isTagable"
#define kwork                        @"work"
#define kDesignation                 @"designation"
#define kCollege                     @"college"
#define kDegree                      @"degree"

#define kHeaderTextKey               @"headerText"
#define kHeaderShouldShowTabs        @"headerShouldShowTabs"
#define kHeaderType     @"headerType"
#define kHeaderTabSelectedIndexKey   @"headerTabSelectedIndex"


#define kReligionKey                 @"userReligion"

#define kWorkKey                     @"workArea"
#define kHeightKey                   @"height"
#define kStatusKey                   @"status"
#define kVoiceIntro                  @"voiceIntro"
#define kLinkedinToken               @"linkedInToken"
#define kIsReligionKey               @"isReligion"
#define kInterestsKey                @"interests"
#define kPickerButtonTag             @"pickerButtonTag"
#define kTagSelectedKey              @"isSelected"
#define kLinkedinVerifiedKey         @"isVerifiedOnLinkedin"
#define kUserEducationKey            @"userEducation"
#define kUserWorkKey                 @"userWork"
#define kProfileCompletenessScoreKey @"profileCompletenessScore"
#define kMutualFriendsKey            @"mutualFriends"
#define kIsVerifiedMsisdnKey         @"isVerifiedMsisdn"
#define kFoneVerifyAvailabilityDtoKey @"foneVerifyAvailabilityDto"
#define kMsisndKey                   @"msisdn"
#define kPhoneNumberKey              @"phoneNumber"
#define kTagsArray                   @"tagsDtos"
#define kVoiceIntroUrl               @"voiceIntroUrl"

#define kNotificationEnabled         @"NotificationEnabled"
#define kVisitorEnabled              @"VisitorEnabled"
#define kCrushEnabled                @"CrushEnabled"
#define kPowerUpsEnabled             @"PowerUpsEnabled"

#define kIntroMessageKey             @"introMessage"    //actual key needed
#define kUserWorksAtKey              @"userWork"
#define kPhoneVerifiedKey            @"isVerifiedMsisdn"
#define kHomeTownKey                 @"userHomeTown"    // actual key needed
#define kWorksAskey                  @"userWorkAs"
#define kWorksAreakey                @"userWorkArea"
#define kStudiedKey                  @"userStudied"
#define kUserRelationshipKey         @"userRelationShipStatus"
#define kWorkExperienceHistoryKey    @"workExperienceHistory"
#define kEducationHistoryKey        @"educationHistory"
#define kFacebookWorkKey            @"facebookWork"
#define kLinkedinWorkKey            @"linkedinWork"
#define kFacebookEducationKey        @"facebookEducation"
#define kLinkedinEducationKey        @"linkedinEducation"
#define kFacebookWorkExHistory  @"facebookWorkExHistory"
#define kLinkedinWorkExHistory  @"LinkedinWorkExHistory"


//Profile cell keys

#define kWooAlbumCellKey             @"wooAlbumCell"
#define kUserNameCellKey             @"userNameCell"
#define kUserCompletenessCellKey     @"userProfileCompletenessCell"
#define kUserNameAgeCellKey          @"userNameAgeCell"
#define kUserFriendsHeaderCellKey    @"userHeaderTextCell"
#define kUserIntroMessageCellKey      @"userIntroMessageHeaderTextCell"
#define kUserBasicHeaderCellKey      @"userBasicHeaderTextCell"
#define kUserHomeTownCellKey         @"userHomeTownCell"
#define kUserReligionCellKey         @"userReligionCell"
#define kUserRelationshipCellKey     @"userRelationshipCell"
#define kUserPhoneVerifiedCellKey    @"userPhoneVerifiedCell"
#define kUserWorkHistoryHeaderCellKey      @"userWorkHeaderTextCell"
#define kUserWorkHistoryCellKey      @"userWorkHistoryCell"
#define kUserEducationHistoryHeaderCellKey    @"userEducationHeaderTextCell"
#define kUserEducationHistoryCellKey @"userEducationHistoryCell"
#define kUserLikesHeaderCellKey      @"userLikesHeaderTextCell"
#define kUserFBLikesCellKey          @"userLikesCell"
#define kUserPersonalityHeaderKey    @"userPersonalityHeaderCell"
#define kUserPersonalityCellKey      @"userPersonalityCell"
#define kUserLifestyleHeaderCellKey  @"userLifestyleHeaderCell"
#define kUserLifestyleSmokingCellKey @"UserLifestyleSmokingCell"
#define kUserLifestyleDrinkingCellKey    @"UserLifestyleDrinkingCell"
#define kUserLifestyleFoodCellKey        @"UserLifestyleFoodCell"
#define kUserPassionHeaderCellKey    @"userPassionHeaderCell"
#define kUserPassionDetailsCellKey   @"userPassionCell"
#define kUserMessageCellKey          @"userMessageCell"
#define kPowerUpHeaderCellKey          @"powerUpHeaderCell"
#define kBoostCellKey                @"boostCell"
#define kCrushCellKey                @"crushCell"
#define kPowerUpCellKey                @"powerUpCell"

#define kUserWorksAtCellKey          @"userWorksAtCell"
#define kUserWorkAreaCellKey         @"userWorkAreaCell"
#define kUserStudiedCellKey          @"userStudiedCell"
#define kUserFriendsCellKey          @"userFriendsCell"




#define kCellIconImageKey       @"image"
#define kArrayTypeAboutMe       @"aboutMe"
#define kArrayTypeKey           @"arrayType"
#define kArrayTypeInterest      @"interests"
#define kMyProfilePickerTypeKey @"pickerType"

#define kFirstNahKey                             @"NAH_FIRST_TIME"
#define kfirstNiceKey                            @"NICE_FIRST_TIME"
#define kLikedFromProfile                        @"HEART_TAPPED_FROM_PROFILE"
#define kDislikedFromProfile                     @"CROSS_TAPPED_FROM_PROFILE"
#define kFirstDiscoverOverlayKey                 @"DISCOVER_OPENED_FIRST_TIME"
#define kHasFetchedMatchesAlready                @"HAS_FETCHED_MATCHES_ALREADY"
#define kHeightOfRowInProfileScreenForVoiceIntro 100
#define kLocalMyProfileUserKey                   @"LOCAL_MY_PROFILE"



#define kTagKey                   @"tag"
#define kAboutMeTagKey            @"aboutMeTagData"
#define kAboutMeTagStringKey      @"aboutMeTags"
#define kOtherInfoTagStringKey    @"otherInfo"
#define kAboutMeServerSportsTags  @"sportsSelectedTags"
#define kAboutMeServerMusicTags   @"musicSelectedTags"
#define kAboutMeServerMoviesTags  @"moviesSelectedTags"
#define kAboutMeServerOutdoorTags @"outDoorActivitySelectedTags"
#define kAboutMeServerFoodTags    @"foodsSelectedTags"
#define kAboutMeServerOthersTags  @"otherSelectedTags"
#define kMyProfileScreenDataKey   @"Data"
#define kMyProfileScreenNameKey   @"nameKey"
#define kMyProfileCellTypeKey     @"CellType"



#define kMatchIDKey                         @"matchId"
#define ktargetAppLozicId                   @"targetAppLozicId"
#define krequestAppLozicId                   @"requesterAppLozicId"

#define kchatServer                         @"chatServer"
#define ksecretChatKey                      @"impl"
#define kMatchedUserIDKey                   @"targetId"
#define kActorIDKey                         @"targetId"
#define kMatchNameKey                       @"targetName"
#define kMatchUserIntroKey                  @"defaultMessage"
#define kMatchUserOverlayText               @"text"
#define kUserFavKey                         @"fav"
#define KisTargetVoiceCallingEnabled        @"isTargetVoiceCallingEnabled"
#define KisRequesterVoiceCallingEnabled     @"isRequesterVoiceCallingEnabled"
#define KisTargetACelebrity                 @"isTargetACelebrity"
#define KisRequesterACelebrity              @"isRequesterACelebrity"

#define KisRequesterFlagged                 @"requesterFlagged"
#define KisTargetFlagged                    @"targetFlagged"
#define kLocked                             @"locked"
#define KRequesterSource                    @"requesterSource"
#define KTargetSource                       @"targetSource"

#define KTargetDeviceType                   @"targetDeviceType"
#define KRequesterDeviceType                @"requesterDeviceType"

#define kVoIPInviteParams                   @"VoIPInviteParams"

#define kMatchUserPicURLKey                 @"targetProfilePicture"
#define kMatchTime                          @"matchedTime"
#define kMatchExpiryTime                    @"expiryTime"
#define kMatchGenderKey                     @"targetGender"
#define kRequesterIDKey                     @"requesterId"
#define kRequesterNameKey                   @"requesterName"
#define kRequesterUserPicURLKey             @"requesterProfilePicture"
#define kRequesterGenderKey                 @"requesterGender"
#define kIsMultimediaMsgAllowed             @"isMultiMediaMsgAllowed"
#define kMatchedAnswer                      @"matchedAnswer"
#define kMatchedQuestion                    @"matchedQuestion"
#define kTargetUserLocation                 @"targetUserLocation"

#define kIsFakeDtoInLoginKey    @"fakeDto"
#define kIsFakeUserKey          @"isFake"
#define kFakeHeaderKey          @"fakeHeader"
#define kFakeTextKey            @"fakeText"
#define kFakeStatusCodeKey      @"fakeStatusCode"
#define kReloginRequiredKey     @"reloginRequired"



#define kLocationErrorShownToUser  @"USER_HAS_ALREADY_SEEN_LOCATION_ERROR"

//#define kReligionArray @"Buddhist",@"Hindu",@"Jain",@"Jewish",@"Muslim",@"Christian",@"Catholic",@"Parsi",@"Spiritual",@"Agnostic",@"Atheist",@"Zoroastrian",@"Sikh",@"Other",@"Not Religious"

#define kHeightArrayInches @"4'7\''",@"4'8\''",@"4'9\''",@"4'10\''",@"4'11\''",@"5'0\''",@"5'1\''",@"5'2\''",@"5'3\''",@"5'4\''",@"5'5\''",@"5'6\''",@"5'7\''",@"5'8\''",@"5'9\''",@"5'10\''",@"5'11\''",@"6'0\''",@"6'1\''",@"6'2\''",@"6'3\''",@"6'4\''",@"6'5\''",@"6'6\''",@"6'7\''",@"6'8\''",@"6'9\''",@"6'10\''",@"6'11\''",@"7'0\''",@"7'1\''",@"7'2\''",@"7'3\''",@"7'4\''"


#define kHeightArray @"139 cm",@"142 cm",@"144 cm",@"147 cm",@"149 cm",@"152 cm",@"154 cm",@"157 cm",@"160 cm",@"162 cm",@"165 cm",@"167 cm",@"170 cm",@"172 cm",@"175 cm",@"177 cm",@"180 cm",@"182 cm",@"185 cm",@"187 cm",@"190 cm",@"193 cm",@"195 cm",@"198 cm",@"200 cm",@"203 cm",@"205 cm",@"208 cm",@"210 cm",@"213 cm",@"215 cm",@"218 cm",@"220 cm",@"223 cm"


//#define kSmokingArray @"Leave this blank",@"Cannot stand smoking",@"I don’t, but don’t mind if others do",@"I am trying to quit",@"Occasionally, at party with friends",@"Heavy smoker"
//
//#define kDrinkingArray @"Leave this blank", @"Just mocktails, thank you", @"Wine or cocktails", @"Only when I want to dance", @"I can go on till 5 a.m."
//
//#define kFoodArray @"Leave this blank", @"Vegetarian", @"Eggetarian", @"Non Vegetarian"
//
//#define kRelationshipArray @"Single",@"Widowed",@"Separated",@"Divorced"


//#define kCommunityArray @"Maithil",@"Mohyal",@"Saraswat Brahmins",@"Anavil", @"Andhra Brahmin", @"Ayyangar Brahmin", @"Karhada", @"Kashmiri Brahmin", @"Madhava", @"Saraswat Brahmins", @"Kayasth", @"Deshastha", @"Nagar", @"Khatri", @"Maratha", @"Nayar", @"Sindhis", @"Dogras", @"Kumaonis", @"Rajput", @"Baidya", @"Bhatia", @"Bunt", @"Ezhava", @"Gujjar", @"Lingayat", @"Mahar", @"Reddi", @"Yadava",  @"Ahir",  @"Agrawal",  @"Bania", @"Maheshwari"

#define kWorkAreaArray @"Admin",@"Architecture",@"Banking",@"Business Intelligence",@"Construction",@"Consulting",@"Education",@"Finance",@"Health care",@"Hospitality",@"HR",@"Imports/Exports",@"IT Software",@"IT Hardware",@"ITES",@"Journalism",@"Legal",@"Logistics and Supply Chain",@"Marketing",@"Media",@"Merchandising",@"Sales/BD",@"Security",@"Self employed",@"Top Management",@"Travel",@"Others"

#define kTemporaryFileName @"temp"



/**
 *  These are the keys which will be used for user profile/detailed profile view/ my profile view
 *
 */

#define kUserProfileNameKey     @"firstName"
#define kUserProfileAgeKey      @"age"
#define kUserProfileHeightKey   @"height"
#define kUserProfileLocationKey @"location"
#define kIntroMessage           @"IntroMessage"

///////////////////////////////////============== Database keys ==========

#define databaseFileName    @"woo.sqlite"
#define databaseFileNameSHM @"woo.sqlite-shm"
#define databaseFileNameWAL @"woo.sqlite-wal"

#define kUserProfilePowerUpKey @"powerUps"
#define kWooAlbumKey        @"wooAlbum"
#define kWooUserIDKey       @"wooUserId"
#define kUserAgeKey         @"age"
#define kFirstNameKey       @"firstName"
#define kIsPopular          @"isPopular"
#define kGenderKey          @"gender"
//#define kInterestsKey @"interests"
#define kLocationKey        @"location"
#define kDistanceKey        @"distance"
#define kProfilePicKey      @"profilePic"
#define kProfilePicURLKey   @"srcBig" //chagnes by Umesh
//#define kProfilePicURLKey   @"imageURL"
#define kProfilePicSrcBigKey    @"srcBig"
#define kProfilePicObjectId @"objectId"
#define kPhotoStatus        @"photoStatus"

#define kVoiceIntroKey      @"voiceIntro"
#define kWooAlbumKey        @"wooAlbum"
#define kMutualFriendsSizeKey   @"mutualFriendSize"
#define kEducationKey       @"education"
#define kWorkExperienceKey  @"discoverWorkExperience"
#define kDiscoverEducation  @"discoverEducation"
#define kCommonWork         @"commonWork"
#define kcommonEducation    @"commonEducation"
#define kcommonLikes        @"commonLikes"

#define kDiscoverInterest  @"tagsDtos"
#define kDegreeKey          @"degree"
#define kHasLikedYou        @"like"
#define kTeaserLineKey      @"teaserLIne"
#define kIsLinkedInVerified @"linkedInVerified"
#define kIsFoneVerified     @"foneVerified"
#define kIsAlreadyMessaged  @"messagedToUser"
#define kMessageFromUser    @"crushText"
#define kSelectedTagDetail  @"selectedTagDetail"
#define kIsVerifiedMsisdn   @"isVerifiedMsisdn"

#define kCardType           @"cardType"
#define kCardInfo           @"cardInfo"

#define kQuestionInfoDto    @"questionInfoDto"

#define kProfileCard        @"PROFILE_CARD"
#define kBrandCard          @"BRAND_CARD"
#define kActivateBoostCard  @"ACTIVATE_BOOST"
#define kGetBoostedCard     @"GET_BOOSTED"
#define kViewVisitorsCard   @"view_visitors"
#define kSendCrushCard      @"SEND_CRUSH"
#define kQuestionCard       @"QA_CARD"
#define kInviteFriendCard   @"INVITE_FRIENDS"

#define kBrandCardExpiryType    @"expiryType"
#define kBrandCardExpiryTypeClick    @"CLICK"
#define kBrandCardExpiryTypePass    @"PASS"
#define kBrandCardExpiryTypeNextLaunch    @"NEXT_LAUNCH"
#define kCardId        @"cardId"
#define kCardActionUrl      @"actionUrl"
#define kCardButtonName     @"buttonName"
#define kCardDescription    @"description"
#define kCardImageUrls      @"imageUrls"
#define kCardTitle          @"title"
#define kCardExpiryType     @"expiryType"

//DiscoverCallType
#define kDiscoverCallTypeNormal @"NormalDiscoverCall"
#define kDiscoverCallTypeTagSearch @"TagSearchDiscoverCall"
#define kDiscoverCallTypePrefrencesChanged @"prefrencesChangedDiscoverCall"

//ChatMessage
#define kChatMessageIDKey       @"clientMessageID"
#define kChatRoomIDKey          @"chatRoomID"
#define kMessageTypeKey         @"messageType"
#define kMessageKey             @"message"
#define kIsDeliveredKey         @"isDelivered"
#define kMessageSenderIDKey     @"messageSenderID"
#define kServerMessageID        @"serverMessageID"
#define kMessageReceiverID      @"messageReceiverID"
#define kChatMessageCreatedTime @"chatMessageCreatedTime"
#define kChatMessageLayerID     @"layerMessageID"
#define kChatMessageDeliveryLayerStatus @"chatDeliveryStatus"
#define kIfchatImageIsItUploaded       @"ifchatImageIsItUploaded"
#define kImageSize              @"imageSize"
#define kMatchSource            @"source"
#define kTopNotificationForOldMessageShow @"topNotificationForOldMessageShow"
////LAyer

//#define kTypingIndicatorStateKey   @"TypingIndicatorState"
#define kParticipantIdKey          @"participantId"

#define ktypingTargetIdKey          @"targetID"


///////////////////////////////////============== Database keys Ends==========




#define kShowMutualFriends                                @"showMutualFriend"

#define kAudioFileExtension                               @"m4a"
#define kTempAudioFileName                                @"temp.m4a"
#define kTempImageName                                    @"temp.jpeg"


#define kTimeIntervalForGroupingMessageInMinutes          240
#define kMilliSecond                                      1000
#define kNumberOfMessageToBeShownAtATime                  50

#define kTimeFormateForHeaderTimeStamp @"MMM dd, yyyy' at 'HH:mm"
#define kAudioShouldBeStoped                              @"audioShouldBeStoped"
#define kRefreshProfileView                               @"refreshProfileView"

//================= Purchases ====================


#define kPassNameKey         @"passName"
#define kPassDurationKey     @"passDuration"
#define kPassPriceKey        @"passPrice"
#define kPassValidityKey     @"passValidity"
#define kPassTypeKey         @"passType"
#define kPassStickerImageURL @"stickerURL"


#define kCurrentPurchaseList           @"currentPurchaseList"
#define kProductList                   @"productList"
#define kShowRedeemWooCode             @"showRedeemWooCode"
#define kRedeemWooCodeTitle            @"title"
#define kRedeemWooCodeDescription      @"description"
#define kColorOfWooRedeemCodeWall      @"colorOfWooRedeemCodeWall"
#define kAccessPassKey                 @"accessPass"
#define kAccessPassId                  @"id"
#define kProductIdKey                  @"id"
#define kStoreProductIdKey             @"storeProductId"
#define kProductNameKey                @"productName"
#define kProductPriceKey               @"productPrice"
#define kProductDescriptionKey         @"productDescription"
#define kAccessPassCategoryKey         @"accessPassCategory"
#define kProductValidityInDaysKey      @"validity"
#define kProductCategoryKey            @"productCategory"
#define kColorCodeKey                  @"colorCode"
#define ktransactionIdKey              @"transactionId"
#define kPurchasedDeviceTypeKey        @"purchasedDeviceType"
#define kPurchasedChannelKey           @"purchasedChannel"
#define kStartDateKey                  @"startDate"
#define kEndDateKey                    @"endDate"
#define kPurchaseDateKey               @"purchaseDate"
#define kWooCodeRedeemTries            @"wooCodeRedeemTries"
#define kCurrentPurchaseList           @"currentPurchaseList"
#define kFirstLoginTime                @"firstLoginTime"
#define kWelcomeMessage                @"welcomeMessage"
#define kProductLoadedFromServer       @"productLoadedFromServer"
#define kProductFailedToLoadFromServer @"productFailedToLoadFromServer"


///Discover

#define kLastLocationLatitudeKey       @"lastLocationLatitude"
#define kLastLocationLongitudeKey      @"lastLocationLongitude"
#define kLastLocationName              @"lastLocationName"
#define kIsDeviceTokenActive           @"deviceTokenActive"
#define kNewUserNoPic                  @"newUserNoPic"

//Discover Filer screen

#define kViewTypeKey                   @"viewType"
#define kComingSoonView                @"comingSoonView"
#define kProfileCompletenessView       @"profileCompleteness"
#define kLocationView                  @"locationView"
#define kAddPhotoView                  @"addPhotoView"
#define kUploadMorePics                @"addMorePics"
#define kFoneVerifyView                @"foneVerifyView"
#define kVerifyUsingLinkedinView       @"verifyUsingLinkedinView"
#define kEnterAboutMeTagsView          @"enterAboutMeTagsView"
#define kRecordVoiceIntroView          @"recordVoiceIntroView"
#define kInviteFriendsView             @"inviteFriendsView"
#define kThatsAllForNowView            @"thatsAllForNowView"
#define kThatsAll10PercentView         @"thatsAll10PercentView"
#define kThatsAll20PercentView         @"thatsAll20PercentView"
#define kThatsAll40PercentView         @"thatsAll40PercentView"
#define kNoInternetView                @"noInternetView"
#define kServerBusyView                @"serverBusyView"
#define kAskAQuestionFillerView        @"askAQuestionFillerView"
#define kAnswerAQuestionFillerView     @"answerAQuestionFillerView"
#define kProfileIsHiddenView           @"profileIsHiddenView"
#define kNoNotificationView            @"noNotificationView"
#define kIntroMessageView            @"introMessageView"
#define kNarrowPreferencesView            @"narrowPreferncesView"
#define kNoMatchesYetView            @"noMatchesYetView"
#define kLikedNoneView            @"likedNoneView"
#define kFANAdView                     @"FANAdView"
#define kGetBoostedView                     @"getBoostedView"
#define kGetCrushesView                     @"getCrushesView"
#define kPaginationWooLoader                @"wooLoaderView"

#define kQuestionKey                   @"question"
#define kAnswerKey                     @"answerKey"
#define kQuestionUserName              @"firstName"
#define kQuestionUserAge               @"ageInYears"
#define kQuestionUserPic               @"srcBig"
#define kUserProfileInfoDto            @"userProfileInfoDto"

#define kHideAddMorePicCard            @"hideMorePics"

//AppConfigSyncType

#define AppConfigTypeProfileOptions    @"PROFILE_OPTIONS"
#define AppConfigTypeCrushTemplates    @"CRUSH_TEMPLATES"
#define AppConfigTypeTips              @"TIPS"
#define APPConfigTypeSelling           @"SELLING"
#define APPConfigCountryDto            @"COUNTRY_DTO"
#define AppConfigTypeProfileWidgets    @"PROFILE_WIDGETS"


/*
 accessPass: {
 accessPassId
 wooId
 product:{
 id
 storeProductId
 productName
 productPrice
 productDescription
 accessPassCategory – redeemWooCode/purchase
 validityInDays
 colorCode
 }
 transactionId - not null and unique
 purchasedDeviceType
 purchasedChannel
 accessPassStartDate
 accessPassEndDate
 accessPassPurchaseDate
 }
 */
//============

//================= Purchases Ends ===============

//New keys which needs to be cleared on logout
#define kIsRegisteredForPush                @"isRegisteredForPush"
#define kIsRegisteredForLocation            @"isRegisteredForLocation"
#define kDiscoverLaunchedForFirstTime       @"FirstLaunchedForTheFirstTime"
#define kGenderPrefrenceChangedForFirstTime @"GenderPrefChangedFirstTime"
#define kAgeFromServer                      @"userAge"

#define kNumberOfTotalRetries         @"numberOfTotalRetries"
#define kTimeForNextShowLoginButton   @"timeForNextShowLoginButton"
#define kIsRecordingAudioForFirstTime @"recordingAudioForFirstTime"
//----------------------------


//#define NSLog //


#define kInAppProducts                                  @"inAppProducts"
#define kUnRegisteredBoughtPasses                       @"unRegisteredBoughtPasses"
#define kTransactionID                                  @"transactionId"
#define kProductID                                      @"productId"
#define kLastErrorValue                                 @"lastErrorValue"
#define kNumberOfDiscoverLaunches                       @"numberOfDiscoverLaunches"
#define kNumberOfTimesProfileCompletenessScreenAppeared @"profileCompletenesScreenAppearedNumber"
#define kNumberOfTimesInviteFriendsScreenAppeared       @"inviteFriendsScreenAppearedNumber"
#define kNumberOfTimesTimerScreenAppeared               @"timerScreenAppearedNumber"
#define kAppStateOnPush                                 @"appStateOnPush"
#define kNextMatchTimer                                 @"nextMatchTimer"
#define kAvailableForCity                               @"availableForCity"
#define kNarrowPrefrences                               @"narrowPreferences"
#define kNoMatchesYet                               @"noMatchesYet"
//#define kIntroMessage                               @"introMessage"
#define kHidden                                         @"hidden"
#define kDiscoverUserInfoDtos                           @"discoverUserInfoDtos"
//#define kIsBlackListedKey                               @"blackListed"
#define kNumberOfTimesPhoneNumberVerifiedScreenAppeared @"numberOfTimesNumberVerifiedScreenAppeared"
#define kFirstTimeANewUserWithoutImagesLaunchesApp      @"firstTimeANewUserWithoutImagesLaunchesApp"
#define kTimeOfSuccessfullDiscoverCall                  @"TimeOfSuccessfullDiscoverCall"
#define kTimeOfLikedNoneShown                 @"timeOfLikedNoneShown"
#define kWaitTimeChatStart                              @"waitTimeChatStart"
#define kPopularityBucket                               @"popularityBucket"
#define kFanDto                                         @"fanDto"
#define kPlacementId                                    @"placementId"
#define kRelativePosition                               @"relativePosition"
#define kPlacementPosition                              @"placementPosition"
#define kNewUserNoPicStatus                             @"newUserNoPicStatus"

////Fone verify App Id

#define kFoneVerifyAppID                                @"FBFONEVERIFY26111010XMHDJHASKDFH56"

#define kFoneVerifyCustomerId                           @"a3fms94n"                           //(sms/sms Woo)     //@"ble6go3s"
//#define kFoneVerifyAppSecretKey                         @"55a7420199070a9c0961fff9d4fe12f6"       //sms/voice
#define kFoneVerifyAppSecretKey                         @"5e456646dbbf7ba910fa93e6bbca40eb"  //(sms/sms Woo)       //@"9c2381e3c52d4df8fa598d9794f8c00c"     //Sms/sms



#define kSecondsForThreeDays                            259200
#define kSecondsForTwoDays                              172800



#define kSender                     @"umesh"
#define kReciever                   @"vaibhav"

#define kSelfieImagesFolderName     @"selfieImages"


#define kQuestionsRestored              @"questionsRestored"
#define kLatestAnswerTimestampKey       @"answerLastUpdatedTime" // This key is introduced in V2.3
#define kAnswersRestored                @"answersRestored"
#define kAnswersUpdatedTimestamp        @"answersUpdatedTimestamp"
#define kAnswersLastUpdateAPIKey        @"lastUpdate"
#define kFirstTimeProfileOptionsFetched @"profileOptionsFetchedFirstTime"
#define kUpgradeIsCompleteToClearUpMeSectionData @"upgradeIsCompleteToClearUpMeSectionData"
#define kUserProductPriceUpdatedTime @"userProductPriceUpdatedTime"


#define kChatMessageSentFirstTime           @"firstChatMessageSent"
#define kIsFirstMatchNotified               @"checkIfFirstMatchNotified"

#define MIME_TYPE_TEXT                     @"text/plain"
#define MIME_TYPE_IMAGE_PNG                @"image/png"
#define MIME_TYPE_IMAGE_JPEG               @"image/jpeg"
#define MIME_TYPE_APPLICATION_JSON         @"application/json"

#define kLocationUpdatedTimestamp            @"locationOptionTimeUpdate"


#define kTimeOutTime                        900             //30
#define kChatAPITimeOutTime                 55

//#define kGoogleAPIKey                   @"AIzaSyCw8a9d-aQGjyVM2FLt0AabOpl69Cn0ymc"

#define kStickerText                        @"Sticker"
#define kImageText                          @"Image"
#define kOldTimeStamp                       @"1382313600000"
#define kOldTimeStamp_Question              @"1382313650000"
#define kOldTimeStamp_Answer                @"1382313700000"


/**
 *  Intent screen
 */
#define kIntentTitleKey                                                             @"intentTitle"
#define kIntentTypeKey                                                              @"intentType"
#define kIsIntentSelected                                                           @"isIntentSelected"
#define kGenderForIntentKey                                                         @"genderForIntent"

#define kNodeRadius                         20
#define kBubbleScaleUpTime                  0.05
#define kBubbleScaleDownTime                0.05
#define kMaximumNumberOfTagsAllowed         12

#define kAllTagsKey                                                                 @"allTags"
#define kPopularTagsKey                                                             @"popularTags"
#define kSelectedTagsKey                                                            @"selectedTags"
#define kTagsModelKey                                                               @"TagsModel"
#define kUserTagsKey                                                                @"userTags"
#define kColorCode_Tags_Key                                                         @"colorCode"
#define kMinAllowedTagsBubbleCount                                                  @"minAllowedTagsBubbleCount"
#define kMaxAllowedTagsBubbleCount                                                  @"maxAllowedTagsBubbleCount"

#define kMaxTagsAllowedCount                                                        @"maxTagsAllowedCount"
#define kMinTagsAllowedCount                                                        @"minTagsAllowedCount"

#define kTagsIdKey                                                                  @"tagId"
#define kTagsNameKey                                                                @"name"
#define kFormattedTagsNameKey                                                       @"formattedName"
#define kTagsName                                                                   @"name"
#define kTagsColorCodeKey                                                           @"tagColorCode"
#define kTagTypeValue                                                               @"WOO_TAG"
#define kAppleStoreUrl         @"https://apps.apple.com/in/app/woo-the-dating-app-women-love/id885397079"


#define kTypingAreaHeight                                                           110
#define kMaximumNumberOfLinesAllowedForChatNotification                             2
#define kMaximumScaleFactorForChatNotification                                      1
#define kTimeforWhichAppInAppPurchaseNotificationWillBeVisible                      5
#define kPaginationCallPageSize                                                     100


#endif
