//
//  AppDelegate.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 18/05/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Store.h"
#import "U2AlertView.h"
//#import <LayerKit/LayerKit.h>
#import <AppsFlyerLib/AppsFlyerTracker.h>
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import <AdSupport/AdSupport.h>
#import "Woo_v2-Swift.h"
#import "NotificationManager/NotificationManager.h"
#import "InAppPurchaseManager.h"
#import "Firebase.h"
#import <PushKit/PushKit.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import "ALReachability.h"

@class ApplozicClient;
@class ALRegisterUserClientService;
@interface AppDelegate : UIResponder <UIApplicationDelegate,UITextViewDelegate , SKRequestDelegate, SKPaymentTransactionObserver,PKPushRegistryDelegate, NSURLConnectionDelegate>{
    U2AlertView *upgradeAlert;
    U2AlertView *pushAlertView;
    NotificationManager     *notifManager;
    BOOL shouldShowTopNotification;
    NSString *showTopNotioficationForMatchId;
    UITextView *feedbackTextviewObj;
    UILabel *placeholderLabel;
    UIView *containerView;
    UILabel *charaterLimitLbl;
    U2AlertView *feedbackAlertViewObj;
    int totalMatches;
    int totalUnreadAnswers;
    
    BOOL isFetchingMatchDataFromServer;
    BOOL isFetchingMatchDataFromServerForChat;
    NSString *fcmPushToken;
    NSString *firebasePhoneAuthenticationfromWhichScreen;
    NSString *refreshedToken;
}

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain) Store *store;

//@property (nonatomic, retain) LYRClient *layerClient;

//@property (nonatomic, retain) LYRConversation *conversation;
//@property (nonatomic, retain) LYRQueryController *queryController;

@property (nonatomic ,retain) NSString *ComingToPurchaseFromTypeOfView;
//@property (nonatomic, retain) SwrveConfig *swreConfigObj;

@property (nonatomic, strong) NSMutableArray *notificationsDataArray;

@property(nonatomic,strong) UserProfileModel  *oMyProfileModel;

@property(nonatomic, strong) NSString *networkInUse;

/**
 *  Id of the chat room that is currently visible, if any.
 */
@property (nonatomic, retain)NSString *currentActiveChatRoomId;

@property (assign) OnboardingPageNumber     onBaordingPageNumber;
@property (assign) int                      totalOnboardingPages;
@property (assign) BOOL                     isConnectedToApplozic;
@property(nonatomic, retain) ApplozicClient *applozic;
@property(nonatomic, retain) ALRegisterUserClientService *registerUserClientService;

//Core telephony 
@property (nonatomic, strong) CTCallCenter* callCenter;

@property(strong) ALReachability * internetConnectionReach;

/**
 method to get appDelegate instance
 @return Returns instance of AppDelegate
 */
+(AppDelegate *)appDelegate;

//- (void)saveContext;
//- (NSURL *)applicationDocumentsDirectory;

-(NSString *)getAudioPathForFileName:(NSString *)fileName;

/**
 *  Method to create audio folder to save user voice intro. Method will be created in cache folder.
 */
-(void)createAudioFolderIfNotExists;

-(void)clearUserDefaultsObjects;

-(void)reinitialiseUserDefaultAndDatabase;
-(void)reInitialiseUserDefault;

//-(void)fetchNewNotifications;

-(void)makeAppsflyerFirstMatchCall;

-(void)makeAppsflyerFakeUserCall;


-(void)sendEventToGoogleAnalyticsForEvent:(NSString *)evenct forScreenName:(NSString *)screenCode;

-(void)updateQuestionAnswersOnUI;

-(void)getUpdatedAnswers;

-(void)sendFirebaseEvent:(NSString *)event andScreen:(NSString *)screen;

-(void)sendPurchasedFirebaseEvent:(NSString *)event ForPurchaseData:(NSDictionary *)purchaseDict;

-(void)sendFirebaseEvent:(NSString *)event andScreen:(NSString *)screen andAdditionalFields:(NSMutableDictionary*)fieldsDictionary;

-(void)sendSwrveEventWithEvent:(NSString *)event andScreen:(NSString *)screen;

-(void)sendSwrveUserIDToServer:(NSString *)swrveUserId;

-(void)checkForInviteCodeInPushNotification:(NSDictionary *)launchOptionsDict andIsApplicationInForeground:(BOOL)isAppInForeground;

-(void)clearTemporarySettingsDefault;

-(void)clearProfileVisibiltyDefault;

-(void)checkIfMaxDistanceExists;

-(void)sendEventOnFirebaseWithEventDetails:(NSString*)eventName withUserProperties:(NSDictionary *)userProperties;

-(void)sendUserPropertyDetailsOnFirebasewithKeyName:(NSString*)keyName withKeyValue:(NSString*)keyValue;

-(void)checkIfUpgradePopupIsToBeShownForVersion:(NSString *)versionString andUpgradeText:(NSString *)upgradeText;

-(void)connectToLayer;

-(void)connectToApplozic;

- (void)getMessagesFromApplozic;

- (void)showNewChatMessageFromTop : (NSString *)message;
    
- (void)showNewChatMessageFromTop : (NSString *)message headerText:(NSString *)headerTxt withImageURL:(NSString *)imageUrl withMatchId:(NSString *)matchId;

-(void)getMyMatchesForTimestamp:(long long int)timestamp andUpdateTimeAfterDataInsertionWith:(long long int)newTimeStamp;

-(void)getMyMatchesForRefreshMatchesTimestamp:(unsigned int long long)timestamp withCompletion:(void (^)(BOOL matchFetched))completionBlock;

-(void)getMyMatchesForTimestamp:(unsigned int long long)timestamp withCompletion:(void (^)(BOOL matchFetched))completionBlock;

-(void)sendDeviceTokedToServer:(NSData *)devTokenData andPushKitToken:(NSData *)voipTokenData;

/**
 *  This method will tell the current type of network in use
 *
 *  @return string containing network type
 */
-(NSString *)getCurrentConnectednetwork;

-(void)migrateDataOnUpdate;
//-(void)test;
-(BOOL)getIsFetchingMatchDataFromServerValue;
-(void)sendFCMPushTokenToServer;
-(void)registerForVOIPPush;
-(void)logEventOnFacebook:(NSString*)logEvent;
-(void)showVoiceCallIntroductionPopup;

-(void)trackVoIPInvites;

//
-(void)createImageFolderIfNotExists;
-(void)disconnectFromFCM;
- (void)connectToFCM;


@end
