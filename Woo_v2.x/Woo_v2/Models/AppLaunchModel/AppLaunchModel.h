//
//  AppLaunchModel.h
//  Woo_v2
//
//  Created by Suparno Bose on 19/02/16.
//  Copyright © 2016 Woo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppLaunchModel : NSObject
/// if cameraOption is enabled for image upload
@property BOOL cameraOption;
/// if fbAlbumOption is enabled for image upload
@property BOOL fbAlbumEnable;
/// if phoneAlbumOption is enabled for image upload
@property BOOL phoneAlbumEnable;

@property BOOL inviteBlockerEnableDisable;
/// if inviteOnlyEnabled friendInvitation is activated and available in left menue
@property BOOL inviteOnlyEnabled;
/// if linkedInEnable is enabled sync with linkedIn is available
@property BOOL linkedInEnable;
@property BOOL isChatEnabled;
/// if if boost is not purchased and no match available then is false
@property BOOL noMatchesYet;

@property BOOL isCallingEnabled;
@property BOOL isFreeTrialOnDeleteActive;

@property BOOL isVoiceCallingOnForIOS;

@property BOOL qafeatureEnabled;

@property BOOL swrveStatus;

@property NSInteger gpsTimeout;

@property NSInteger maxResultAllowedForSuccessImageCheckOnGoogle;

@property NSInteger qaAnswerCharLimit;

@property NSInteger qaAnswerLimit;

@property NSInteger qaQuestionCharLimit;

@property NSInteger qaQuestionLimit;

@property long long int answersUpdateTime;

@property NSInteger questionsAskedToday;

@property NSInteger stickersStartRange;

@property NSInteger stickersEndRange;

@property NSInteger totalButton;

@property (strong) NSString* appVersion;

@property (strong) NSString *inviteShareUrl;

@property (strong) NSString* messaging_SERVER;

@property (strong) NSString* upgradeText;

@property int long long locationOptionTimeUpdate;

@property long long int  mainFacePercentageThreshold;

@property int long long profileOptionsUpdatedTime;

@property int long long countryDtoLastUpdatedTime;

@property int long long tipsUpdatedTime;

@property int long long customNotificationUpdateTime;

@property int long long lastMatchUpdateTime;

@property int long long wooQuestionLimit;
@property NSInteger wooAnswerCharLimit;
@property int long long wooQuestionLastUpdatedTime;

//Price point based on categories
@property int long long userProductPriceUpdatedTime;

@property (strong) NSDate* createdTime;

@property NSInteger deleteProfilesOtherThanSkippedDays;

@property NSInteger deleteSkippedProfilesDays;

@property NSInteger meSectionExpiredProfilesDaysThreshold;

@property NSInteger meSectionProfileExpiryDays;

@property NSInteger meSectionProfileExpiryDaysThreshold;

@property int long long sellingMessageUpdatedTime;

@property int long long profileWidgetsUpdatedTime;

@property int wooUserCurrentDayOnApp;

@property BOOL isPaidUser;

@property BOOL hasEverPurchased;

@property BOOL isPurchaseKeyAvailable;

@property BOOL isWooPlusPurchasedToBeShown;

//show Full Payment
@property BOOL disableFP;

@property (strong) NSURL *faqUrl;
@property (strong) NSURL *TermsUrl;
@property (strong) NSURL *privacyUrl;

@property BOOL matchNotification;
@property BOOL crushNotification;
@property BOOL questionNotification;
@property BOOL soundNotification;

@property BOOL needToMakeUpdateNotificationPreferencesCall;

//UserQuestionsArray
@property(nonatomic, retain) NSArray *templateQuestionsArray;

//Bool added to check if new data is entered me section
@property BOOL isNewDataPresentInSkippedSection;
@property BOOL isNewDataPresentInLikedByMeSection;
@property BOOL isNewDataPresentInLikedMESection;
@property BOOL isNewDataPresentInVisitorSection;
@property BOOL isNewDataPresentInCrushSection;
@property BOOL isNewDataPresentMyQuestionSection;

@property BOOL showSearchViewInTagSearch;

@property(nonatomic,strong) NSString *invitationCampaignDesc;

@property(nonatomic,strong) NSString *tagsIconBaseURL;

@property (assign) BOOL showLocationToggle;

@property (nonatomic, assign) BOOL showCongratulationsScreenOnDelete;

@property BOOL voiceCallingPopUpEnabled;

@property CGFloat qualityScore;


@property (strong) NSDate* createDate;

@property NSInteger likeCount;

@property NSInteger maxLikeToShowLikeMeter;

//@property (strong) NSURL *botImageUrl;

@property NSInteger numberOfTimesVisitorLaunched;               // it will a even or odd number, If number increses by 10 it will be reset 1

@property NSInteger numberOfTimesLikedMeLaunched;               // it will a even or odd number, If number increses by 10 it will be reset 1

@property NSInteger numberOfTimesProfileCompletenessInLikedMeLaunched;               // it will a even or odd number, If number increses by 10 it will be reset 1


@property NSInteger numberOfTimesAboutMeLaunched;               // it will a even or odd number, If number increses by 10 it will be reset 1

@property NSInteger numberOfTimesSkippedProfileLaunched;        // it will a even or odd number, If number increses by 10 it will be reset 1

@property NSInteger numberOfTimesLikedByMeProfileLaunched;        // it will a even or odd number, If number increses by 10 it will be reset 1

@property NSInteger profileCompletenessScoreThreshold;

@property NSInteger profileCompletenessFallbackThreshold;

@property NSInteger opacityLevelLockedProfile;

//boostText, profileCompletnessText, subscriptionText > these three text will come from server and user will save them and will show in visitor, like me, skipped profile and crush section when needed. 
@property (strong) NSString* boostText;                         // from server it will come as inAppPurchaseText, it is the boost text

@property (strong) NSString* profileCompletnessText;            // from server profileCompletnessText

@property (strong) NSString* addPhotosText;                     // from server profileCompletnessText

@property (strong) NSString* addTagsText;                       // from server profileCompletnessText

@property (strong) NSString* addPersonalQuoteText;              // from server profileCompletnessText

//@property (strong) NSString* subscriptionText;                  // from server  subscriptionText

@property (strong) NSString* activateBoostText;                 // from server activateBoost

@property (strong) NSString* crushPurchaseText;                 // from server crushPurchaseText

@property (strong) NSString* discoverMoreProfileText;           // from server discoverProfile

@property (strong) NSString* sendCrushText;                     // from server sendCrushText

@property (strong) NSString* subscriptionLikedMeText;           // Woo Plus text for liked me screen

@property (strong) NSString* subscriptionSkippedProfileText;    // Woo Plus text for Skipped Profile screen

@property (strong) NSString* subscriptionVisitorText;           // Woo Plus text for Visitor screen

@property (strong) NSString* boostVisitorText;                  // Boost text for Visitor screen
@property (strong) NSString* boostVisitorsLockedText;                  // Boost text for Visitor screen

@property (strong) NSString* boostLikedMeText;                  // Boost text for Liked Me screen

@property (strong) NSString* boostCrushReceivedText;            // Boost text for Crush recieved screen

@property (strong) NSString* boostMatchboxText;                 // Boost text for Matchbox screen

@property (strong) NSString* userDayStatus;

@property (strong) NSString* wooCreditsScreenText;

@property (strong) NSMutableArray *leftPanelSuggestions;

@property (strong) NSMutableDictionary *leftPanelAdsText;

@property (strong) NSMutableArray *countryDtoArray;

@property (strong) NSMutableArray *profileWidgetsArray;

@property (strong) NSDictionary *analyzeProfileDto;

/*!
 * @discussion method to get the shared Instance of the Class
 * @return AppLaunchModel shared instance Object
 */
+ (AppLaunchModel *)sharedInstance;
/*!
 * @discussion Updates the shared instance properties with given data
 * @param data Dictionary type of data with appLaunch Info
 */
- (void)updateModelWithData:(NSDictionary*)data;
/*!
 * @discussion returns the Sticker name array for Woo chat
 * @return sticker array if the form of NSArray
 */
- (NSArray*)stickersArray;

- (void)updateCountryDtoArrayWithData:(NSArray *)countryDto;

- (void)updateBotImageUrl:(NSURL *)imageUrlString;

- (void)updateTemplateQuestionsArrayFromData:(NSArray *)questionArray;

- (void)resetSharedInstance;
@end
