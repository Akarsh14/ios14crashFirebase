//
//  UEnumConstant.h
//  Woo
//
//  Created by Umesh Mishra on 14/02/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#ifndef Woo_UEnumConstant_h
#define Woo_UEnumConstant_h

typedef enum{
    likedMe,
    SkippedMe,
    VisitorMe
} ProfileType;

typedef enum {
    UserFakenessVerifyingState,
    UserFakenessVerifiedState,
    PushNotificationCallDoneState,
    LocationCallDoneState,
    VerificationComplete
}VerificationState;

typedef enum{
    UnverifiedUser,
    VerifiedUser,
    FakeUser
}UserVerificationState;


typedef NS_ENUM(NSInteger, UserSubtitleType){
    UserSubtitleTypeWorkPlace,
    UserSubtitleTypeWorkArea,
    UserSubtitleTypeEducation,
    UserSubtitleTypeNotAvailable
};

typedef NS_ENUM(NSInteger, UserProfileCellType){
    UserProfileCellTypeName,
    UserProfileCellTypeVoiceIntro,
    UserProfileCellTypeProfileCompleteness,
    UserProfileCellTypeIntroMessageHeader,
    UserProfileCellTypeBasicHeader,
    UserProfileCellTypeHomeTown,
    UserProfileCellTypeReligion,
    UserProfileCellTypeRelationship,
    UserProfileCellTypePhone,
    UserProfileCellTypeWorkExperienceHeader,
    UserProfileCellTypeWorkExperience,
    UserProfileCellTypeEducationHeader,
    UserProfileCellTypeEducationHistory,
    UserProfileCellTypeLikesHeader,
    UserProfileCellTypeLikes,
    UserProfileCellTypeWorkAs,
    UserProfileCellTypeWorkAt,
    UserProfileCellTypeWorkArea,
    UserProfileCellTypeStudied,
    UserProfileCellTypeCommonFriendsHeader,
    UserProfileCellTypeCommonFriends,
    UserProfileCellTypeFriends,
    UserProfileCellTypePersonalityHeader,
    UserProfileCellTypePersonalityCell,
    UserProfileCellTypeLifestyleHeader,
    UserProfileCellTypeLifestyleSmoking,
    UserProfileCellTypeLifestyleDrinking,
    UserProfileCellTypeLifestyleFood,
    UserProfileCellTypePassionHeader,
    UserProfileCellTypePassionDetails,
    UserProfileCellTypeMessageFromUser,
    UserProfileCellTypePowerUp,
    UserProfileCellTypePowerUpHeader
};


typedef NS_ENUM(NSInteger, EditUserProfileCellType){
    EditUserProfileCellTypeName,
    EditUserProfileCellTypeReligion,
    EditUserProfileCellTypePhone,
    EditUserProfileCellTypeHeight,
    EditUserProfileCellTypeRelationship,
    EditUserProfileCellTypeWorkArea,
    EditUserProfileCellTypeLineFirst,
    EditUserProfileCellTypeVoiceIntro,
    EditUserProfileCellTypeLinkedin,
    EditUserProfileCellTypeFacebook,
    EditUserProfileCellTypeAboutMeHeader,
    EditUserProfileCellTypePersonality,
    EditUserProfileCellTypeLifestyle,
    EditUserProfileCellTypePassions
};


//typedef enum{
//    WorkPlace,
//    WorkArea,
//    Education
//}userSubtitleType;
/**
 TimeRemainingForNextMatchesShowTimer and InviteFriends are not error but is used to handle scenarios
 */
typedef enum{
    UnknowError = -1,
    NoInternetError = 0,
    LocationServiceUnavailableError,
    UserWasNotAskedForLocationPermissionsError,
    AppCurrentlyUnavailableInCityError,
    NoNotificationPermissionError,
    MatchesNotAvailableError,
    TimeRemainingForNextMatchesError,
    ProfileIncompleteError,
    NarrowPreferencesError,
    TimeRemainingForNextMatchesShowTimer,
    InviteFriends,
    ScreenBetweenLaunches,
    ProfileIsHidden,
    ProfileHiddenMakeDiscoverCall,
    PhoneNotVerified,
    NoError,
    IncompleteFacebookPermission
    
}WooDiscoverErrors;

typedef enum{
    UnknowFiler = -1,
    ComingSoonFiler = 0,
    NoNotificationfiler,
    LocationServicesUnavailableFiler,
    PhoneVerifyFiler,
    GetBoostedFiler,
    LinkedInFiler,
    NarrowPreferncesFiler,
    GetCrushesFiler,
    AboutMetagsFiler,
    VoiceIntroFiler,
    AddMorePicsFiler,
    ProfileCompletenessFiler,
    InviteFriendsFiler,
    ThatsAllForNowfiler,
}WooDiscoverFilerScreens;


typedef enum{
    getRequest,
    postRequest,
    deleteRequest
} methodType;

typedef enum {
    GET_DATA_FROM_CACHE_ONLY,
    GET_DATA_FROM_URL_ONLY,
    GET_DATA_FROM_URL_IF_FAIL_GET_DATA_FROM_CACHE,
    GET_DATA_FROM_URL_AND_UPDATE_CACHE
}AFNetworkingCachingPolicy;

typedef enum{
    AudioTypePlayOnly,
    AudioTypePlayAndRecord
}AudioType;


typedef enum{
    getDiscoverScreenData=1,
    getUserProfileImage,
    deleteUserProfileImage,
    sendUserProfileImagesToServer,
    getMyProfileData,
    getUserProfileData,
    updateUserProfileData,
    getFriendsProfileData,
    registerUserToServer,
    sendUserDeviceIdToSever,
    getUserWooAlbum,
    updateUserWooAlbum,
    likeOrDislikeAProfile,
    flagAProfile,
    likeAProfile,
    dislikeAProfile,
    uploadAFileToSever,
    downloadAFileFromServer,
    sendUserLocationToServer,
    checkWooFakeUser,
    askIntroductionFromWOOFriend,
    getAllNotifications,
    updateNotificationStatus,
    getHiddenNotificationData,
    phase3AskCallMade,
    fetchAllMatches,
    deleteAMatch,
    logoutUser,
    deleteUser,
    userFeedback,
    getPurchaseDataFromServer,
    getPurchaseHistoryFromServer,
    makeRedeemCallToServer,
    getAboutMeTagsFromServer,
    makePurchaseCallToServer,
    makeFbSyncCallToServer,
    makeNotificationDeleteCallToServer,
    makeNotificationReadCallToServer,
    makeAppLaunchCallToServer,
    sendSoundPreferenceToServer,
    cropAnImage,
    verifyAnImage,
    foneVerifyValidateNumber,
    getFoneVerificationConfiguration,
    foneVerifyStatusCheck,
    foneVerifySendSmsToVerify,
    saveVerifiedNumberOnServer,
    getWooTokenAPI,
    getUserWooAlbumTest,
    checkRecieversChatServer,
    authenticateLayerWithServer,
    uploadPictureToServer,
    getUserFacebookAlbums,
    sendDirectMessage,
    getTemplateQuestions,
    postAnswer,
    getUserProfileTagsData,
    restoreQuestions,
    deleteQuestion,
    updateAnswers,
    markAnswerAsRead,
    markAsnwerAsDeleted,
    reportAnAnswer,
    fetchOlderAnswers,
    getStickersFromServer,
    verifyInviteCode,
    sendSwrveUserIDToServer,
    sendLinkedInAccessTokenToServer,
    getTipsFromServer,
    getProductsFromServer,
    brandCardPass,
    brandCardClick,
    postInAppDataToServer,
    postInAppDataToServerForRenew,
    getTemplateCrush,
    activatingBoost,
    getCrushDashboardData,
    getBoostDashboardData,
    likeProfileFromCrushDashboard,
    dislikeProfileFromCrushDashboard,
    getLatLongForSpecificLocationFromGoogle,
    getLocationFromGoogle,
    getLocationOptionsFromServer,
    googleImageResult,
    getAppConfigFromServer,
    sendInviteFriend,
    getInviteFriend,
    getInviteCampaign,
    sendAboutMeTextToServer,
    updateAgeGenderToServer,
    postAnswerToServer,
    sendLoginErrorFeedbackToServer,
    startScreenDoneCallToServer,
    getTagsFromServerAPI,
    postTagsToServerAPI,
    getPrductsFromServer,
    getLikedMeDashboardData,
    getSkippedProfileDashboardData,
    getLikedByMeDashboardData,
    getNotificationPreferences,
    updateNotificationPreferences,
    makeProductPopupEventCall,
    getPurchaseProductDetailFromServer,
    sendFCMTokenToServer,
    getChannelKeyFromSever,
    pushVoIPAPN,
    trackVoIPInvite,
    getWooQuestions,
}kindOfRequest;


typedef enum {
    MUST_GO_THROUGH_QUEUE,
    MUST_REACH_SERVER_GO_THROUGH_QUEUE_POST_CALLS,
    MUST_RECIEVE_DATA_GO_THROUGH_QUEUE,
    DO_NOT_BOTHER_ABOUT_REACHING_TO_SERVER,
}ThroughQueueTypes;

typedef enum {
    TextOnly,
    ImageHeaderAndText
}NotificateViewType;


typedef enum {
    HEADER_TYPE_NONE = 0,
    HEADER_TYPE_WORK = 1,
    HEADER_TYPE_EDUCATION = 2,
    HEADER_TYPE_POWERUP = 3,
}HEADER_TYPE;


typedef NS_ENUM(NSInteger, NotificationType){
    unknown,
    discoverScreen,
    meSectionLanding,
    visitorSection,
    likedMeSection,
    crushReceivedSection,
    skippedProfileSection,
    myQuestionsSection,
    matchBoxSection,
    myPurchasesSection,
    boostPurchaseSection,
    crushPurchaseSection,
    wooplusPurchaseSection,
    wooGlobePurchaseSection,
    inviteScreenLandingSection,
    editProfilePurchaseSection,
    chatBoxLanding,
    discoverSettingsSection,
    appSettingsSection,
    appStoreLandingSection,
    inAppBrowserSection,
    referFriend,
    tagBubbleLanding,
    incomingVisitorLanding,
    voipInviteLanding,
    matchRemoved,
    contentguidelines,
    feedback
};

typedef enum{
    TEXT=1,
    IMAGE,
    AUDIO,
    INTRODUCTION,       //For developer user, it will user to save the intro message in chat to solve load more issue       added by Umesh
    HEADERTIMESTAMP,           //For developer user, it will user to show time stamp in between chats  aaded by Umesh
    TYPING,
    IMAGE_SEND_BY_USER,
    QUESTION,
    ANSWER,
    MATCHED_THROUGH_CELL,
    TYPING_AREA_CELL,
    CRUSH_MESSAGE
    
}messageType;


typedef enum {
    COLOR1=1,
    COLOR2,
    COLOR3,
    COLOR4,
    COLOR5,
    COLOR6
}PurchaseColorCode ;

typedef enum
{
    PASS_HEADER = 5,
    PASS_STICKER,
    PASS_HEADER_TIMER
    
}PassCellTypes;


typedef enum {
    MESSAGE_PENDING = 1,
    MESSAGE_SEND,
    MESSAGE_DELIVERED,
    MESSAGE_RECOVED
}MessageDeliveryStatus;

typedef enum {
    VERIFICATION_ERROR_NONE = 0,
    VERIFICATION_ERROR_PROFILE_NOT_VERIFIED_ON_FB = 1,
    VERIFICATION_ERROR_GENDER_MISSING,
    VERIFICATION_ERROR_RELATIONSHIP_NOT_ALLOWED,
    VERIFICATION_ERROR_DOB_MISSING,
    VERIFICATION_ERROR_UNDER_AGE,
    VERIFICATION_ERROR_DOB_AND_GENDER_MISSING,
    VERIFICATION_ERROR_LESS_FRIEND_ON_FB,
    VERIFICATION_ERROR_NEW_USER_ON_FB,
    VERIFICATION_ERROR_RELATIONSHIP_NOT_ALLOWED_MARRIED,
    VERIFICATION_ERROR_INVALID_USER_PROFILE = 10,
    VERIFICATION_ERROR_RELATIONSHIP_NOT_ALLOWED_OTHERS
}VerificationErrorType;


typedef NS_ENUM(NSInteger, SettingSwitchCellType){
    SettingSwitchCellTypeChat,
    SettingSwitchCellTypeAlert
};

typedef NS_ENUM(NSInteger, ScreenOpenNotificationType){
    ScreenOpenNotificationTypeMyProfile,
    ScreenOpenNotificationTypeDiscover,
    ScreenOpenNotificationTypeMatchbox,
    ScreenOpenNotificationTypeQuestions,
    ScreenOpenNotificationTypeNotificaions,
    ScreenOpenNotificationTypeInvite,
    ScreenOpenNotificationTypeSettings,
    ScreenOpenNotificationTypePurchases,
    ScreenOpenNotificationTypeUnknown
};


typedef NS_ENUM(NSInteger, SettingCellType){
    SettingCellLocationHeader,
    SettingCellLocation,
    SettingCellDiscoveryPrefHeader,
    SettingCellDescoveryPref,
    SettingCellLocationPref,
    SettingCellSoundsHeader,
    SettingCellChat,
    SettingCellAlert,
    SettingCellProfile,
    SettingCellShowProfilePref,
    SettingCellSocialHeader,
    SettingCellFacebook,
    SettingCellTwitter,
    SettingCellBigFooter
};


typedef enum{
    NO_GENDER_SELECTED = 0,
    FEMALE = 1,
    MALE = 2
}GenderOptions;

typedef enum {
    POPULARITY_NONE,
    POPULARITY_LOW,
    POPULARITY_MEDIUM,
    POPULARITY_HIGH,
    
}PopularityScore;

typedef enum {
    NOTHING_PURCHASED,
    CRUSH_PURCHASEDBOOST_NOTPURCHASED,
    BOOST_ACTIVECRUSH_PURCHASED,
    BOOST_NOTACTIVECRUSH_PURCHASED,
    BOOST_ACTIVECRUSH_NOTPURCHASED,
    BOOST_NOTACTIVECRUSH_NOTPURCHASED
    
    
}PowerUpOptions;

typedef enum {
    
    BOOST_AVAILABLE_BOOST_ACTIVATED_VISITOR_AVILABLE,
    BOOST_AVAILABLE_BOOST_ACTIVATED_VISITOR_NOT_AVILABLE,
    BOOST_AVAILABLE_BOOST_NOT_ACTIVATED_VISITOR_AVILABLE,
    BOOST_AVAILABLE_BOOST_NOT_ACTIVATED_VISITOR_NOT_AVILABLE,
    BOOST_NOT_AVAILABLE_VISITOR_AVILABLE,
    BOOST_NOT_AVAILABLE_VISITOR_NOT_AVILABLE
}BoostVisitorOptions;


//typedef enum {
//    DISCOVER,           //tag search allowed and bottom bar visible
//    MATCHBOX,           //tag search not allowed and bottom bar not visible
//    ANSWERS,            //tag search not allowed and bottom bar not visible
//    VISITOR,            //tag search not allowed and bottom bar visible
//    CRUSH,              //tag search not allowed and bottom bar visible
//    QUESTIONCARD,       //tag search not allowed and bottom bar not visible
//    CHAT                //tag search not allowed and bottom bar not visible
//}DetailProfileViewParent;

typedef NS_ENUM(NSInteger, DetailProfileViewParent) {
    DetailProfileViewParentDiscover,        //tag search allowed and bottom bar visible
    DetailProfileViewParentMyProfile,       //tag search allowed and bottom bar not visible
    DetailProfileViewParentVisitor,         //tag search not allowed and bottom bar visible
    DetailProfileViewParentCrush,           //tag search not allowed and bottom bar visible
    DetailProfileViewParentAnswers,         //tag search not allowed and bottom bar not visible
    DetailProfileViewParentQuestionCard,    //tag search not allowed, bottom bar visible, dislike disabled
    DetailProfileViewParentChat,            //tag search allowed and bottom bar not visible
    DetailProfileViewParentLikedMe,
    DetailProfileViewParentTagSearch,
    DetailProfileViewParentSkippedProfile,
    DetailProfileViewParentHomeView,
    DetailProfileViewParentMatchboxView,
    DetailProfileViewParentDetailProfile,
    DetailProfileViewParentPurchase,
    DetailProfileViewParentSettings
    
};




typedef enum{
    INTENT_TYPE_LOVE_OF_MY_LIFE = 0,
    INTENT_TYPE_FRIEND,
    INTENT_TYPE_CASUAL,
    INTENT_TYPE_NONE
    
}IntentType;

typedef enum{
    GENDER_PREFERENCE_NONE = 0,
    GENDER_PREFERENCE_MALE = 1<<0,
    GENDER_PREFERENCE_FEMALE = 1<<1 ,
    GENDER_PREFERENCE_BOTH = 1<<2
}GenderPreference;

typedef enum{
    SELECTED_GENDER_PREFERENCE_NONE = 0,
    SELECTED_GENDER_PREFERENCE_MALE = 1,
    SELECTED_GENDER_PREFERENCE_FEMALE = 2,
    SELECTED_GENDER_PREFERENCE_BOTH = 3
}SelectedGenderPreference;



typedef enum{
    ON_BOARDING_PAGE_NUMBER_NONE = 0,
    ON_BOARDING_PAGE_NUMBER_ONE = 1,
    ON_BOARDING_PAGE_NUMBER_TWO = 2,
    ON_BOARDING_PAGE_NUMBER_THREE = 3,
    ON_BOARDING_PAGE_NUMBER_FOUR = 4,
    ON_BOARDING_PAGE_NUMBER_FIVE = 5,
}OnboardingPageNumber;


typedef enum{
    MATCHED_USER_STATUS_NONE = 1,
    MATCHED_USER_STATUS_RETRY,
    MATCHED_USER_STATUS_ESTABLISHING_CONNECTION,
    MATCHED_USER_STATUS_CONNECTED_TO_LAYER
}MatchedUserStatus;

//typedef enum {
//    BatchId
//};


typedef enum{
    PURCHASE_PRODUCT_CAROUSAL_TYPE_TEXT = 0,
    PURCHASE_PRODUCT_CAROUSAL_TYPE_IMAGE = 1,
    PURCHASE_PRODUCT_CAROUSAL_TYPE_HYBRID = 2,
}PurchaseProductCarousalType;



#endif
