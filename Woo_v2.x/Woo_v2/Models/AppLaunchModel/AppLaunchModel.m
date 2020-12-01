//
//  AppLaunchModel.m
//  Woo_v2
//
//  Created by Suparno Bose on 19/02/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "AppLaunchModel.h"
#import "Woo_v2-Swift.h"
#import "CountryDtoModel.h"

#define kStickerPrefix @"sticker"

@implementation AppLaunchModel
static AppLaunchModel *sharedInstance = nil;
//+ (AppLaunchModel *)sharedInstance {
//    
//    if (!sharedInstance) {
//        static dispatch_once_t onceToken;
//        dispatch_once(&onceToken, ^{
//            static dispatch_once_t onceToken;
//            dispatch_once(&onceToken, ^{
//                NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
//                NSData *decodedObject = [userDefault objectForKey: @"AppLaunchModel"];
//                if (decodedObject) {
//                    sharedInstance = [NSKeyedUnarchiver unarchiveObjectWithData: decodedObject];
//                }
//                else{
//                    sharedInstance = [[super allocWithZone:NULL] init];
//                }
//                
//                if (!sharedInstance.leftPanelSuggestions) {
//                    sharedInstance.leftPanelSuggestions = [[NSMutableArray alloc] init];
//                }
//                
//                if (!sharedInstance.leftPanelAdsText) {
//                    sharedInstance.leftPanelAdsText = [[NSMutableDictionary alloc] init];
//                }
//                
//                [[NSNotificationCenter defaultCenter] addObserver:sharedInstance
//                                                         selector:@selector(appTerminationHandler)
//                                                             name:UIApplicationWillResignActiveNotification
//                                                           object:nil];
//            });
//        });
//    }
//    return sharedInstance;
//}


+ (AppLaunchModel *)sharedInstance {
    @synchronized(self){
    if (!sharedInstance) {
                NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
                NSData *decodedObject = [userDefault objectForKey: @"AppLaunchModel"];
                if (decodedObject) {
                    sharedInstance = [NSKeyedUnarchiver unarchiveObjectWithData: decodedObject];
                }
                else{
                    sharedInstance = [[super allocWithZone:NULL] init];
                }
                if (!sharedInstance.leftPanelSuggestions) {
                    sharedInstance.leftPanelSuggestions = [[NSMutableArray alloc] init];
                }
                if (!sharedInstance.leftPanelAdsText) {
                    sharedInstance.leftPanelAdsText = [[NSMutableDictionary alloc] init];
                }
                if (!sharedInstance.countryDtoArray) {
                    sharedInstance.countryDtoArray = [[NSMutableArray alloc] init];
                }
                if (!sharedInstance.profileWidgetsArray) {
                    sharedInstance.profileWidgetsArray = [[NSMutableArray alloc] init];
                }
                [[NSNotificationCenter defaultCenter] addObserver:sharedInstance
                                                         selector:@selector(appTerminationHandler)
                                                             name:UIApplicationWillResignActiveNotification
                                                           object:nil];
    }
        return sharedInstance;
        }
}


+ (id)allocWithZone:(NSZone *)zone {
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    NSData *decodedObject = [userDefault objectForKey: @"AppLaunchModel"];
    if (decodedObject == nil) {
        return [self sharedInstance];
    }
    else{
        return [super allocWithZone:zone];
    }
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    //Encode properties, other class variables, etc
    [encoder encodeObject:[NSNumber numberWithBool:self.isCallingEnabled] forKey:@"isCallingEnabled"];
    [encoder encodeObject:[NSNumber numberWithBool:self.isVoiceCallingOnForIOS]  forKey:@"isVoiceCallingOnForIOS"];
    [encoder encodeObject:[NSNumber numberWithBool:self.voiceCallingPopUpEnabled] forKey:@"voiceCallingPopUpEnabled"];
    [encoder encodeObject:self.invitationCampaignDesc forKey:@"invitationCampaignDesc"];
    [encoder encodeObject:self.tagsIconBaseURL forKey:@"tagsIconBaseURL"];
    [encoder encodeObject:[NSNumber numberWithBool:self.cameraOption] forKey:@"cameraOption"];
    [encoder encodeObject:[NSNumber numberWithBool:self.fbAlbumEnable] forKey:@"fbAlbumEnable"];
    [encoder encodeObject:[NSNumber numberWithBool:self.phoneAlbumEnable] forKey:@"phoneAlbumEnable"];
    [encoder encodeObject:[NSNumber numberWithBool:self.inviteBlockerEnableDisable] forKey:@"inviteBlockerEnableDisable"];
    [encoder encodeObject:[NSNumber numberWithBool:self.inviteOnlyEnabled] forKey:@"inviteOnlyEnabled"];
    [encoder encodeObject:[NSNumber numberWithBool:self.linkedInEnable] forKey:@"linkedInEnable"];
    [encoder encodeObject:[NSNumber numberWithBool:self.isChatEnabled] forKey:@"isChatEnabled"];
    [encoder encodeObject:[NSNumber numberWithBool:self.noMatchesYet] forKey:@"noMatchesYet"];
    [encoder encodeObject:[NSNumber numberWithBool:self.qafeatureEnabled] forKey:@"qafeatureEnabled"];
    [encoder encodeObject:[NSNumber numberWithBool:self.swrveStatus] forKey:@"swrveStatus"];
    //show Full Payment
    [encoder encodeObject:[NSNumber numberWithBool:self.disableFP] forKey:@"disableFP"];
    [encoder encodeObject:[NSNumber numberWithInteger:self.gpsTimeout] forKey:@"gpsTimeout"];
    [encoder encodeObject:[NSNumber numberWithInteger:self.maxResultAllowedForSuccessImageCheckOnGoogle] forKey:@"maxResultAllowedForSuccessImageCheckOnGoogle"];
    [encoder encodeObject:[NSNumber numberWithInteger:self.qaAnswerCharLimit] forKey:@"qaAnswerCharLimit"];
    [encoder encodeObject:[NSNumber numberWithInteger:self.qaAnswerLimit] forKey:@"qaAnswerLimit"];
    [encoder encodeObject:[NSNumber numberWithInteger:self.qaQuestionCharLimit] forKey:@"qaQuestionCharLimit"];
    [encoder encodeObject:[NSNumber numberWithInteger:self.qaQuestionLimit] forKey:kQuestionsLimit];
    [encoder encodeObject:[NSNumber numberWithInteger:self.questionsAskedToday] forKey:@"questionsAskedToday"];
    [encoder encodeObject:[NSNumber numberWithUnsignedLongLong:self.answersUpdateTime] forKey:@"answerLastUpdatedTime"];
    [encoder encodeObject:[NSNumber numberWithInteger:self.totalButton] forKey:@"totalButton"];
    [encoder encodeObject:[NSNumber numberWithInteger:self.stickersStartRange] forKey:@"stickersStartRange"];
    [encoder encodeObject:[NSNumber numberWithInteger:self.stickersEndRange] forKey:@"stickersEndRange"];
    
    [encoder encodeObject:[NSNumber numberWithUnsignedLongLong:self.locationOptionTimeUpdate] forKey:@"locationOptionTimeUpdate"];
    
    [encoder encodeObject:[NSNumber numberWithUnsignedLongLong:self.mainFacePercentageThreshold] forKey:@"mainFacePercentageThreshold"];
    [encoder encodeObject:[NSNumber numberWithUnsignedLongLong:self.profileOptionsUpdatedTime] forKey:@"profileOptionsUpdatedTime"];
    [encoder encodeObject:[NSNumber numberWithUnsignedLongLong:self.countryDtoLastUpdatedTime] forKey:@"countryDtoLastUpdatedTime"];
    [encoder encodeObject:[NSNumber numberWithUnsignedLongLong:self.tipsUpdatedTime] forKey:@"tipsUpdatedTime"];
    [encoder encodeObject:[NSNumber numberWithUnsignedLongLong:self.customNotificationUpdateTime] forKey:@"customNotificationUpdateTime"];
    [encoder encodeObject:[NSNumber numberWithUnsignedLongLong:self.lastMatchUpdateTime] forKey:@"lastMatchUpdateTime"];
    [encoder encodeObject:[NSNumber numberWithUnsignedLongLong:self.userProductPriceUpdatedTime] forKey:@"userProductPriceUpdatedTime"];

    
    [encoder encodeObject:[NSNumber numberWithFloat:self.qualityScore] forKey:@"qualityScore"];
    
    [encoder encodeObject:self.createdTime forKey:@"createdTime"];
    
    [encoder encodeObject:[NSNumber numberWithInteger:self.deleteSkippedProfilesDays]  forKey:kDeleteSkippedProfilesDays];
    [encoder encodeObject:[NSNumber numberWithInteger:self.deleteProfilesOtherThanSkippedDays] forKey:kDeleteProfilesOtherThanSkippedDays];
    
    [encoder encodeObject:[NSNumber numberWithInteger:self.meSectionProfileExpiryDays] forKey:kMeSectionProfileExpiryDays];
    [encoder encodeObject:[NSNumber numberWithInteger:self.meSectionExpiredProfilesDaysThreshold] forKey:kMeSectionExpiredProfilesDaysThreshold];
    [encoder encodeObject:[NSNumber numberWithInteger:self.meSectionProfileExpiryDaysThreshold] forKey:kMeSectionProfileExpiryDaysThreshold];
    
    [encoder encodeObject:self.faqUrl forKey:@"faqUrl"];
    [encoder encodeObject:self.TermsUrl forKey:kTermsConditionUrl];
    [encoder encodeObject:self.privacyUrl forKey:kPrivacyUrl];
    
    [encoder encodeObject:self.appVersion forKey:@"appVersion"];
    [encoder encodeObject:self.inviteShareUrl forKey:@"inviteShareUrl"];
    [encoder encodeObject:self.messaging_SERVER forKey:@"messaging_SERVER"];
    [encoder encodeObject:self.upgradeText forKey:@"upgradeText"];
    [encoder encodeObject:[NSNumber numberWithInteger:self.maxLikeToShowLikeMeter] forKey:@"maxLikeToShowLikeMeter"];
//    [encoder encodeObject:[NSNumber numberWithInteger:50] forKey:@"maxLikeToShowLikeMeter"];
    [encoder encodeObject:[NSNumber numberWithInteger:self.likeCount] forKey:@"likeCount"];
//    [encoder encodeObject:[NSNumber numberWithInteger:50] forKey:@"likeCount"];
  //  [encoder encodeObject:self.botImageUrl forKey:kStartScreenImageUrl];
    [encoder encodeObject:[NSNumber numberWithInteger:self.numberOfTimesVisitorLaunched] forKey:@"numberOfTimesVisitorLaunched"];
    [encoder encodeObject:[NSNumber numberWithInteger:self.numberOfTimesLikedMeLaunched] forKey:@"numberOfTimesLikedMeLaunched"];
    [encoder encodeObject:[NSNumber numberWithInteger:self.numberOfTimesAboutMeLaunched] forKey:@"numberOfTimesAboutMeLaunched"];
    [encoder encodeObject:[NSNumber numberWithBool:self.matchNotification] forKey:@"matchNotification"];
    [encoder encodeObject:[NSNumber numberWithBool:self.crushNotification] forKey:@"crushNotification"];
    [encoder encodeObject:[NSNumber numberWithBool:self.questionNotification] forKey:@"questionNotification"];
    [encoder encodeObject:[NSNumber numberWithBool:self.soundNotification] forKey:@"soundNotification"];
    [encoder encodeObject:[NSNumber numberWithBool:self.needToMakeUpdateNotificationPreferencesCall] forKey:@"needToMakeUpdateNotificationPreferencesCall"];
    
    //Bool added to check if new data is entered me section
    [encoder encodeObject:[NSNumber numberWithBool:self.isNewDataPresentInSkippedSection] forKey:@"isNewDataPresentInSkippedSection"];
    [encoder encodeObject:[NSNumber numberWithBool:self.isNewDataPresentInLikedByMeSection] forKey:@"isNewDataPresentInLikedByMeSection"];
    [encoder encodeObject:[NSNumber numberWithBool:self.isNewDataPresentInLikedMESection] forKey:@"isNewDataPresentInLikedMESection"];
    [encoder encodeObject:[NSNumber numberWithBool:self.isNewDataPresentInVisitorSection] forKey:@"isNewDataPresentInVisitorSection"];
    [encoder encodeObject:[NSNumber numberWithBool:self.isNewDataPresentInCrushSection] forKey:@"isNewDataPresentInCrushSection"];
    [encoder encodeObject:[NSNumber numberWithBool:self.isNewDataPresentMyQuestionSection] forKey:@"isNewDataPresentMyQuestionSection"];
    [encoder encodeObject:[NSNumber numberWithBool:self.isWooPlusPurchasedToBeShown] forKey:@"isWooPlusPurchasedToBeShown"];
    //tags search key
    [encoder encodeObject:[NSNumber numberWithBool:self.showSearchViewInTagSearch] forKey:@"showSearchViewInTagSearch"];
    
//    NSLog(@"Encoded Values %@ %@",[NSNumber numberWithBool:self.isNewDataPresentInSkippedSection],[NSNumber numberWithBool:self.isNewDataPresentInLikedMESection]);
    
    [encoder encodeObject:self.boostText forKey:@"inAppPurchaseText"];
    
    [encoder encodeObject:self.profileCompletnessText forKey:@"profileCompletnessText"];
    [encoder encodeObject:self.addPhotosText forKey:@"addPhotosText"];
    [encoder encodeObject:self.addTagsText forKey:@"addTagsText"];
    [encoder encodeObject:self.addPersonalQuoteText forKey:@"addPersonalQuoteText"];

    [encoder encodeObject:self.activateBoostText forKey:@"activateBoostText"];
    [encoder encodeObject:self.crushPurchaseText forKey:@"crushPurchaseText"];
    [encoder encodeObject:self.discoverMoreProfileText forKey:@"discoverMoreProfileText"];
    [encoder encodeObject:self.sendCrushText forKey:@"sendCrushText"];
    [encoder encodeObject:self.subscriptionLikedMeText forKey:@"subscriptionLikedMeText"];
    [encoder encodeObject:self.subscriptionSkippedProfileText forKey:@"subscriptionSkippedProfileText"];
    [encoder encodeObject:self.subscriptionVisitorText forKey:@"subscriptionVisitorText"];
    [encoder encodeObject:self.boostVisitorText forKey:@"boostVisitorText"];
    [encoder encodeObject:self.boostVisitorsLockedText forKey:@"boostVisitorsLockedText"];
    [encoder encodeObject:self.boostLikedMeText forKey:@"boostLikedMeText"];
    [encoder encodeObject:self.boostCrushReceivedText forKey:@"boostCrushReceivedText"];
    [encoder encodeObject:self.boostMatchboxText forKey:@"boostMatchboxText"];
    
//    [encoder encodeObject:self.subscriptionText forKey:@"subscriptionText"];

    if (self.leftPanelSuggestions) {
        [encoder encodeObject:self.leftPanelSuggestions forKey:@"leftPanelSuggestions"];
    }
    
    if (self.leftPanelAdsText) {
        [encoder encodeObject:self.leftPanelAdsText forKey:@"leftPanelAdsText"];
    }
    if (self.countryDtoArray) {
        [encoder encodeObject:self.countryDtoArray forKey:@"countryDtoArray"];
    }
    
    if (self.profileWidgetsArray) {
        [encoder encodeObject:self.profileWidgetsArray forKey:@"profileWidgetsArray"];
    }
    
    if (self.analyzeProfileDto){
        [encoder encodeObject:self.analyzeProfileDto forKey:@"analyzeProfileDto"];
    }
    
    [encoder encodeObject:[NSNumber numberWithInteger:self.profileCompletenessScoreThreshold] forKey:@"profileCompletenessScoreThreshold"];
    [encoder encodeObject:[NSNumber numberWithInteger:self.profileCompletenessFallbackThreshold] forKey:@"profileCompletenessFallbackThreshold"];
    [encoder encodeObject:[NSNumber numberWithInteger:self.opacityLevelLockedProfile] forKey:@"opacityLevelLockedProfile"];

    
    [encoder encodeObject:self.wooCreditsScreenText forKey:@"wooCreditsScreenText"];
    
    [encoder encodeObject:[NSNumber numberWithBool:self.showCongratulationsScreenOnDelete] forKey:@"showCongratulationsScreenOnDelete"];
    
    [encoder encodeObject:[NSNumber numberWithInt:self.wooQuestionLimit] forKey:@"wooQuestionLimit"];
    [encoder encodeObject:[NSNumber numberWithInt:self.wooAnswerCharLimit] forKey:@"wooAnswerCharLimit"];
    [encoder encodeObject:[NSNumber numberWithUnsignedLongLong:self.wooQuestionLastUpdatedTime] forKey:@"wooQuestionLastUpdatedTime"];
    [encoder encodeObject:[NSNumber numberWithUnsignedLongLong:self.wooQuestionLastUpdatedTime] forKey:@"wooQuestionLastUpdatedTime"];
    if (self.templateQuestionsArray){
        [encoder encodeObject:self.templateQuestionsArray forKey:@"templateQuestionsArray"];
    }

}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if( self != nil )
    {
        //decode properties, other class vars
        self.isCallingEnabled           = [[decoder decodeObjectForKey:@"isCallingEnabled"] boolValue];
        self.showSearchViewInTagSearch = [[decoder decodeObjectForKey:@"showSearchViewInTagSearch"] boolValue];
        self.isVoiceCallingOnForIOS     = [[decoder decodeObjectForKey:@"isVoiceCallingOnForIOS"] boolValue];
        self.voiceCallingPopUpEnabled   = [[decoder decodeObjectForKey:@"voiceCallingPopUpEnabled"] boolValue];
        self.invitationCampaignDesc     = [decoder decodeObjectForKey:@"invitationCampaignDesc"];
        self.tagsIconBaseURL     = [decoder decodeObjectForKey:@"tagsIconBaseURL"];
        self.cameraOption               = [[decoder decodeObjectForKey:@"cameraOption"] boolValue];
        self.fbAlbumEnable              = [[decoder decodeObjectForKey:@"fbAlbumEnable"] boolValue];
        self.phoneAlbumEnable           = [[decoder decodeObjectForKey:@"phoneAlbumEnable"] boolValue];
        self.inviteBlockerEnableDisable = [[decoder decodeObjectForKey:@"inviteBlockerEnableDisable"] boolValue];
        self.inviteOnlyEnabled          = [[decoder decodeObjectForKey:@"inviteOnlyEnabled"] boolValue];
        self.linkedInEnable             = [[decoder decodeObjectForKey:@"linkedInEnable"] boolValue];
        self.isChatEnabled = [[decoder decodeObjectForKey:@"isChatEnabled"] boolValue];
        self.noMatchesYet               = [[decoder decodeObjectForKey:@"noMatchesYet"] boolValue];
        self.qafeatureEnabled           = [[decoder decodeObjectForKey:@"qafeatureEnabled"] boolValue];
        self.swrveStatus                = [[decoder decodeObjectForKey:@"swrveStatus"] boolValue];
        
        //show Full Payment
        self.disableFP                = [[decoder decodeObjectForKey:@"disableFP"] boolValue];
        self.gpsTimeout                 = [[decoder decodeObjectForKey:@"gpsTimeout"] integerValue];
        self.maxResultAllowedForSuccessImageCheckOnGoogle        = [[decoder decodeObjectForKey:@"maxResultAllowedForSuccessImageCheckOnGoogle"] integerValue];
        self.qaAnswerCharLimit          = [[decoder decodeObjectForKey:@"qaAnswerCharLimit"] integerValue];
        self.qaAnswerLimit              = [[decoder decodeObjectForKey:@"qaAnswerLimit"] integerValue];
        self.qaQuestionCharLimit        = [[decoder decodeObjectForKey:@"qaQuestionCharLimit"] integerValue];
        self.qaQuestionLimit            = [[decoder decodeObjectForKey:kQuestionsLimit] integerValue];
//        self.answersUpdateTime;         = [[decoder decodeObjectForKey:@"latestAnsTime"] unsignedLongLongValue];
        self.questionsAskedToday        = [[decoder decodeObjectForKey:@"questionsAskedToday"] integerValue];
        self.totalButton                = [[decoder decodeObjectForKey:@"totalButton"] integerValue];
        self.stickersStartRange         = [[decoder decodeObjectForKey:@"stickersStartRange"] integerValue];
        self.stickersEndRange           = [[decoder decodeObjectForKey:@"stickersEndRange"] integerValue];
        
        self.answersUpdateTime          = [[decoder decodeObjectForKey:@"answerLastUpdatedTime"] unsignedLongLongValue];
        self.locationOptionTimeUpdate   = [[decoder decodeObjectForKey:@"locationOptionTimeUpdate"] unsignedLongLongValue];
        self.mainFacePercentageThreshold   = [[decoder decodeObjectForKey:@"mainFacePercentageThreshold"] unsignedLongLongValue];
        
        self.profileOptionsUpdatedTime  = [[decoder decodeObjectForKey:@"profileOptionsUpdatedTime"] unsignedLongLongValue];
        self.countryDtoLastUpdatedTime  = [[decoder decodeObjectForKey:@"countryDtoLastUpdatedTime"] unsignedLongLongValue];
        self.tipsUpdatedTime            = [[decoder decodeObjectForKey:@"tipsUpdatedTime"] unsignedLongLongValue];
        self.lastMatchUpdateTime        = [[decoder decodeObjectForKey:@"lastMatchUpdateTime"] unsignedLongLongValue];
        self.userProductPriceUpdatedTime        = [[decoder decodeObjectForKey:@"userProductPriceUpdatedTime"] unsignedLongLongValue];

        if ([decoder decodeObjectForKey:@"customNotificationUpdateTime"]) {
            self.customNotificationUpdateTime = [[decoder decodeObjectForKey:@"customNotificationUpdateTime"] unsignedLongLongValue];
        }
        else{
            self.customNotificationUpdateTime = 0;
        }
        
        
        self.qualityScore               = [[decoder decodeObjectForKey:@"qualityScore"] floatValue];
        
        self.createdTime                = [decoder decodeObjectForKey:@"createdTime"];
        
        self.deleteSkippedProfilesDays                = [[decoder decodeObjectForKey:kDeleteSkippedProfilesDays] integerValue];
        self.deleteProfilesOtherThanSkippedDays       = [[decoder decodeObjectForKey:kDeleteProfilesOtherThanSkippedDays] integerValue];
        
        self.meSectionProfileExpiryDays               = [[decoder decodeObjectForKey:kMeSectionProfileExpiryDays] integerValue];
        self.meSectionExpiredProfilesDaysThreshold               = [[decoder decodeObjectForKey:kMeSectionExpiredProfilesDaysThreshold] integerValue];
        self.meSectionProfileExpiryDaysThreshold      = [[decoder decodeObjectForKey:kMeSectionProfileExpiryDaysThreshold] integerValue];
        
        self.faqUrl                     = [decoder decodeObjectForKey:@"faqUrl"];
        self.TermsUrl                     = [decoder decodeObjectForKey:kTermsConditionUrl];
        self.privacyUrl                   = [decoder decodeObjectForKey:kPrivacyUrl];
        
        self.appVersion                 = [decoder decodeObjectForKey:@"appVersion"];
        self.inviteShareUrl             = [decoder decodeObjectForKey:@"inviteShareUrl"];
        self.messaging_SERVER           = [decoder decodeObjectForKey:@"messaging_SERVER"];
        self.upgradeText                = [decoder decodeObjectForKey:@"upgradeText"];
        
        self.maxLikeToShowLikeMeter     = [[decoder decodeObjectForKey:@"maxLikeToShowLikeMeter"] integerValue];
        self.likeCount                  = [[decoder decodeObjectForKey:@"likeCount"] integerValue];
//        self.botImageUrl                = [decoder decodeObjectForKey:kStartScreenImageUrl];
        self.numberOfTimesVisitorLaunched = [[decoder decodeObjectForKey:@"numberOfTimesVisitorLaunched"] integerValue];
        self.numberOfTimesLikedMeLaunched = [[decoder decodeObjectForKey:@"numberOfTimesLikedMeLaunched"] integerValue];
        self.numberOfTimesAboutMeLaunched = [[decoder decodeObjectForKey:@"numberOfTimesAboutMeLaunched"] integerValue];

        self.matchNotification = [decoder decodeObjectForKey:@"matchNotification"];
        self.crushNotification = [decoder decodeObjectForKey:@"crushNotification"];
        self.questionNotification = [decoder decodeObjectForKey:@"questionNotification"];
        self.soundNotification = [decoder decodeObjectForKey:@"soundNotification"];
        _needToMakeUpdateNotificationPreferencesCall = [decoder decodeObjectForKey:@"needToMakeUpdateNotificationPreferencesCall"];
        
        self.isNewDataPresentInLikedByMeSection = [[decoder decodeObjectForKey:@"isNewDataPresentInLikedByMeSection"] boolValue];
        self.isNewDataPresentInSkippedSection = [[decoder decodeObjectForKey:@"isNewDataPresentInSkippedSection"] boolValue];
        self.isNewDataPresentInLikedMESection = [[decoder decodeObjectForKey:@"isNewDataPresentInLikedMESection"] boolValue];
        self.isNewDataPresentInVisitorSection = [[decoder decodeObjectForKey:@"isNewDataPresentInVisitorSection"] boolValue];
        self.isNewDataPresentInCrushSection = [[decoder decodeObjectForKey:@"isNewDataPresentInCrushSection"] boolValue];
        self.isNewDataPresentMyQuestionSection = [[decoder decodeObjectForKey:@"isNewDataPresentMyQuestionSection"] boolValue];
        self.isWooPlusPurchasedToBeShown = [[decoder decodeObjectForKey:@"isWooPlusPurchasedToBeShown"] boolValue];
        
        self.boostText = [decoder decodeObjectForKey:@"inAppPurchaseText"];
        self.profileCompletnessText = [decoder decodeObjectForKey:@"profileCompletnessText"];
        
        self.addPhotosText = [decoder decodeObjectForKey:@"addPhotosText"];
        self.addTagsText = [decoder decodeObjectForKey:@"addTagsText"];
        self.addPersonalQuoteText = [decoder decodeObjectForKey:@"addPersonalQuoteText"];
        
        self.activateBoostText = [decoder decodeObjectForKey:@"activateBoostText"];
        self.crushPurchaseText = [decoder decodeObjectForKey:@"crushPurchaseText"];
        self.discoverMoreProfileText = [decoder decodeObjectForKey:@"discoverMoreProfileText"];
        self.sendCrushText = [decoder decodeObjectForKey:@"sendCrushText"];
        self.subscriptionLikedMeText = [decoder decodeObjectForKey:@"subscriptionLikedMeText"];
        self.subscriptionSkippedProfileText = [decoder decodeObjectForKey:@"subscriptionSkippedProfileText"];
        self.subscriptionVisitorText = [decoder decodeObjectForKey:@"subscriptionVisitorText"];
        self.boostVisitorText = [decoder decodeObjectForKey:@"boostVisitorText"];
        self.boostVisitorsLockedText =  [decoder decodeObjectForKey:@"boostVisitorsLockedText"];

        self.boostLikedMeText = [decoder decodeObjectForKey:@"boostLikedMeText"];
        
        self.boostCrushReceivedText = [decoder decodeObjectForKey:@"boostCrushReceivedText"];
        self.boostMatchboxText = [decoder decodeObjectForKey:@"boostMatchboxText"];
//        self.subscriptionText = [decoder decodeObjectForKey:@"subscriptionText"];

        
        if ([decoder decodeObjectForKey:@"leftPanelSuggestions"]) {
            self.leftPanelSuggestions = [decoder decodeObjectForKey:@"leftPanelSuggestions"];
        }
        
        if ([decoder decodeObjectForKey:@"leftPanelAdsText"]) {
            self.leftPanelAdsText = [decoder decodeObjectForKey:@"leftPanelAdsText"];
        }
        
        if ([decoder decodeObjectForKey:@"countryDtoArray"]) {
            self.countryDtoArray = [decoder decodeObjectForKey:@"countryDtoArray"];
        }
        
        if ([decoder decodeObjectForKey:@"profileWidgetsArray"]) {
            self.profileWidgetsArray = [decoder decodeObjectForKey:@"profileWidgetsArray"];
        }
        
        if ([decoder decodeObjectForKey:@"analyzeProfileDto"]) {
            self.analyzeProfileDto = [decoder decodeObjectForKey:@"analyzeProfileDto"];
        }
        self.profileCompletenessScoreThreshold = [[decoder decodeObjectForKey:@"profileCompletenessScoreThreshold"] integerValue];
        self.profileCompletenessFallbackThreshold = [[decoder decodeObjectForKey:@"profileCompletenessFallbackThreshold"] integerValue];
        self.opacityLevelLockedProfile = [[decoder decodeObjectForKey:@"opacityLevelLockedProfile"] integerValue];
        self.wooCreditsScreenText = [decoder decodeObjectForKey:@"wooCreditsScreenText"];
        
        self.showCongratulationsScreenOnDelete = [decoder decodeObjectForKey:@"showCongratulationsScreenOnDelete"];
        
        self.wooQuestionLimit = [[decoder decodeObjectForKey:@"wooQuestionLimit"] intValue];
        self.wooAnswerCharLimit = [[decoder decodeObjectForKey:@"wooAnswerCharLimit"] intValue];
        self.wooQuestionLastUpdatedTime  = [[decoder decodeObjectForKey:@"wooQuestionLastUpdatedTime"] unsignedLongLongValue];
        if ([decoder decodeObjectForKey:@"templateQuestionsArray"]){
            self.templateQuestionsArray = [decoder decodeObjectForKey:@"templateQuestionsArray"];
        }

    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMeSection" object:nil];
//    [[[WooScreenManager sharedInstance] oHomeViewController] checkAndshowUnreadBadgeOnAboutMeIcon];
    return self;
}

-(void) appTerminationHandler{
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:self];
    [userDefault setObject:encodedObject forKey:@"AppLaunchModel"];
    [userDefault synchronize];
}

-(void)updateModelWithData:(NSDictionary*)data{
  
    //kisVoiceCallingOnForIOS
    if ([data objectForKey:@"mainFacePercentageThreshold"])
    {
        NSNumber *minimumThreshold = (NSNumber *)[data objectForKey:@"mainFacePercentageThreshold"];
        self.mainFacePercentageThreshold = [minimumThreshold longLongValue];
    }
    else
    {
        self.mainFacePercentageThreshold = 5;
    }
    
    if ([data objectForKey:kisVoiceCallingOnForIOS] && [[data objectForKey:kisVoiceCallingOnForIOS] boolValue] == YES)
    {
        _isVoiceCallingOnForIOS = [[data objectForKey:kisVoiceCallingOnForIOS] boolValue];
    }
    else
    {
        _isVoiceCallingOnForIOS = NO;
    }
    
    if([data objectForKey:@"showSearchViewInTagSearch"] && [[data objectForKey:@"showSearchViewInTagSearch"] boolValue] == YES )
    {
        _showSearchViewInTagSearch = YES;
    }
    else
    {
        _showSearchViewInTagSearch = NO;
    }

    if ([data objectForKey:@"showCongratulationsScreenOnDelete"] && [[data objectForKey:@"showCongratulationsScreenOnDelete"] boolValue] == true){
        _showCongratulationsScreenOnDelete = true;
    }
    else{
        _showCongratulationsScreenOnDelete = false;
    }
    
    ///Calling enabled for user

    if ([data objectForKey:kCallingEnabled] && [[data objectForKey:kCallingEnabled] boolValue] == YES)
    {
        _isCallingEnabled = [[data objectForKey:kCallingEnabled] boolValue];
    }
    else
    {
        _isCallingEnabled = NO;
    }
    
    if ([data objectForKey:@"isFreeTrialOnDeleteActive"] && [[data objectForKey:@"isFreeTrialOnDeleteActive"] boolValue] == YES)
    {
        _isFreeTrialOnDeleteActive = [[data objectForKey:@"isFreeTrialOnDeleteActive"] boolValue];
    }
    else
    {
        _isFreeTrialOnDeleteActive = NO;
    }
    
    
    
    
    //show Full Payment
    if ([data objectForKey:kDisableFP] && [[data objectForKey:kDisableFP] boolValue] == YES)
    {
        _disableFP = YES;
    }
    else
    {
        _disableFP = NO;
    }
    
    
    if ([data objectForKey:@"userDayStatus"])
    {
        _userDayStatus = [data objectForKey:@"userDayStatus"];
    }
    else
    {
        _userDayStatus = @"";
    }
    
    if ([data objectForKey:@"tagsIconBaseURL"])
    {
        _tagsIconBaseURL = [data objectForKey:@"tagsIconBaseURL"];
    }
    else
    {
        _tagsIconBaseURL = @"";
    }
    
//    if ([data objectForKey:kvoiceCallingPopUpEnabled] && [[data objectForKey:kvoiceCallingPopUpEnabled] boolValue] == YES)
//    {
//
//        _voiceCallingPopUpEnabled = [[data objectForKey:kvoiceCallingPopUpEnabled] boolValue];
//    }
//    else
//    {
        _voiceCallingPopUpEnabled = NO;
//    }
    
    
//    _isCallingEnabled = YES;
    if ([data objectForKey:@"onboardingDateTime"]){
        NSString *onboardingTimeInMillSeconds = [data objectForKey:@"onboardingDateTime"];
        
        NSDate *serverDate = [NSDate dateWithTimeIntervalSince1970:(onboardingTimeInMillSeconds.doubleValue / 1000.0)];
        NSDate *currentDate = [NSDate date];
        
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                            fromDate:serverDate
                                                              toDate:currentDate
                                                             options:0];
        _wooUserCurrentDayOnApp = (int)[components day];
    }
    else{
        _wooUserCurrentDayOnApp = -1;
    }
    
    _isPurchaseKeyAvailable = false;

    if ([data objectForKey:@"isPaidUser"]){
        _isPaidUser = [[data objectForKey:@"isPaidUser"] boolValue];
        _isPurchaseKeyAvailable = true;
    }
    
    if ([data objectForKey:kShowLocationToggle] && [[data objectForKey:kShowLocationToggle] boolValue] == true)
    {
        
        _showLocationToggle = true;
    }
    else
    {
        _showLocationToggle = false;
    }


    if ([data objectForKey:@"hasEverPurchased"]){
        _hasEverPurchased = [[data objectForKey:@"hasEverPurchased"] boolValue];
        _isPurchaseKeyAvailable = true;
    }
    
    if ([data objectForKey:@"opacityLevelLockedProfile"]){
        _opacityLevelLockedProfile = [[data objectForKey:@"opacityLevelLockedProfile"] integerValue];
    }
    else{
        _opacityLevelLockedProfile = 16;
    }

    
    if ([data objectForKey:kFaqUrl] && [[data objectForKey:kFaqUrl] length]>0) {
        _faqUrl             = [NSURL URLWithString:[data objectForKey:kFaqUrl]];
    }
    
    if ([data objectForKey:kTermsConditionUrl] && [[data objectForKey:kTermsConditionUrl] length]>0) {
        _TermsUrl             = [NSURL URLWithString:[data objectForKey:kTermsConditionUrl]];
    }
    
    if ([data objectForKey:kPrivacyUrl] && [[data objectForKey:kPrivacyUrl] length]>0) {
        _privacyUrl             = [NSURL URLWithString:[data objectForKey:kPrivacyUrl]];
    }
    
    
    if ([data objectForKey:kPrivacyUrl])
            _privacyUrl = [data objectForKey:kPrivacyUrl];

    
    _gpsTimeout = [[data objectForKey:kGpsTimeout] integerValue];
    
     [self updateInvitePropertiesWithData:data];
    
    _noMatchesYet           = [[data objectForKey:kNoMatchesYet] boolValue];
        
    NSDictionary *photoUploadOptions = [data objectForKey:kPhotoUploadOptions];
    if (photoUploadOptions) {
        _cameraOption       = [[photoUploadOptions objectForKey:kIsCameraEnable] boolValue];
        _fbAlbumEnable      = [[photoUploadOptions objectForKey:kIsFacebookEnable] boolValue];
        _phoneAlbumEnable   = [[photoUploadOptions objectForKey:kIsGalleryEnable] boolValue];
    }
    
    
    NSDictionary *featureDTO = [data objectForKey:@"wooFeatureDto"];
        if(featureDTO){
            _isChatEnabled   = [[featureDTO objectForKey:@"isChatEnabled"] boolValue];
        }else{
            _isChatEnabled = YES;
        }
    

    _messaging_SERVER = [data objectForKey:@"messaging_SERVER"];
    
    [self updateQnAPropertiesWithData:data];
    
    if ([data objectForKey:kQualityScore]) {
        _qualityScore       = [[data objectForKey:kQualityScore] floatValue];
    }
    
    _stickersStartRange     = [[data objectForKey:@"stickersStartRange"] integerValue];
    
    _stickersEndRange       = [[data objectForKey:@"stickersEndRange"] integerValue];
    
    _linkedInEnable         = ([[data objectForKey:kLinkedInEnabled] intValue] == 1)?YES:NO;
    
    
    
    _maxResultAllowedForSuccessImageCheckOnGoogle = [[data objectForKey:kMaxResultAllowedForSuccessImageCheckOnGoogle] integerValue];
    
    _customNotificationUpdateTime = [[data objectForKey:@"customNotificationUpdateTime"] longLongValue];
    
    _swrveStatus = [[data objectForKey:kSwrveStatus] boolValue];
    
    _upgradeText = [data objectForKey:kUpgradeText];
    
    _answersUpdateTime = [[data objectForKey:kLatestAnswerTimestampKey] unsignedLongLongValue];
    
    _userProductPriceUpdatedTime = [[data objectForKey:kUserProductPriceUpdatedTime] unsignedLongLongValue];
    
//    _lastMatchUpdateTime = [[data objectForKey:@"lastMatchUpdateTime"] unsignedLongLongValue];
    
    NSDate *createDate = [NSDate dateWithTimeIntervalSince1970:[[data objectForKey:kCreatedTime] longLongValue]/1000];
    _createdTime = createDate;
    
    _deleteProfilesOtherThanSkippedDays = [[data objectForKey:kDeleteProfilesOtherThanSkippedDays] integerValue];
    _deleteSkippedProfilesDays = [[data objectForKey:kDeleteSkippedProfilesDays] integerValue];
    
    if ([[data allKeys] containsObject:kMeSectionProfileExpiryDays]) {
        _meSectionProfileExpiryDays = [[data objectForKey:kMeSectionProfileExpiryDays] integerValue];
    }
    else{
        _meSectionProfileExpiryDays = -1;
    }
    
    if ([[data allKeys] containsObject:kMeSectionExpiredProfilesDaysThreshold]) {
        _meSectionExpiredProfilesDaysThreshold = [[data objectForKey:kMeSectionExpiredProfilesDaysThreshold] integerValue];
    }
    else{
        _meSectionExpiredProfilesDaysThreshold = -1;
    }
    
    if ([[data allKeys] containsObject:kMeSectionProfileExpiryDaysThreshold]) {
        _meSectionProfileExpiryDaysThreshold = [[data objectForKey:kMeSectionProfileExpiryDaysThreshold] integerValue];
    }
    else{
        _meSectionProfileExpiryDaysThreshold = -1;
    }
    
    if ([data objectForKey:kMaxLikeToShowLikeMeter]) {
        self.maxLikeToShowLikeMeter     = [[data objectForKey:kMaxLikeToShowLikeMeter] integerValue];
    }
    else{
        self.maxLikeToShowLikeMeter     = 50;
    }

    self.likeCount                  = [[data objectForKey:kLikeGivenToday] integerValue];
    
    //self.maxLikeToShowLikeMeter     = 3;
    
//    self.likeCount                  = 0;
    _isWooPlusPurchasedToBeShown = [[data objectForKey:@"isWooPlusPurchasedToBeShown"] boolValue];
    
    if ([data objectForKey:@"wooQuestionLimit"]) {
        self.wooQuestionLimit     = [[data objectForKey:@"wooQuestionLimit"] intValue];
    }
    else{
        self.wooQuestionLimit = 3;
    }
    
    if ([data objectForKey:@"wooAnswerCharLimit"]) {
        self.wooAnswerCharLimit     = [[data objectForKey:@"wooAnswerCharLimit"] intValue];
    }
    else{
        self.wooAnswerCharLimit = 300;
    }
    
    if ([data objectForKey:@"wooQuestionLastUpdatedTime"]) {
        self.wooQuestionLastUpdatedTime     = [[data objectForKey:@"wooQuestionLastUpdatedTime"] unsignedLongLongValue];
    }
    else{
        self.wooQuestionLastUpdatedTime = 0;
    }
    
    [self appTerminationHandler];
    
}

-(void) updateQnAPropertiesWithData:(NSDictionary*)data{
    _qaAnswerCharLimit      = [[data objectForKey:kAnswerCharacterLimit] integerValue];
    
    _qaAnswerLimit          = [[data objectForKey:kAnswersLimit] integerValue];
    
    _qaQuestionCharLimit    = [[data objectForKey:kQuestionCharacterLimit] integerValue];
    
    _qaQuestionLimit        = [[data objectForKey:kQuestionsLimit] integerValue];
    
    _questionsAskedToday    = [[data objectForKey:kQuestionsAskedToday] integerValue];
}

-(void) updateInvitePropertiesWithData:(NSDictionary*)data{
    
    _inviteOnlyEnabled          = [[data objectForKey:kEnableInvite] boolValue];
    
    _inviteBlockerEnableDisable = [[data objectForKey:kInviteBlockerEnableDisable] boolValue];
        
    if ([[APP_Utilities validString:[data objectForKey:kInviteShareUrl]] length]>0) {
        _inviteShareUrl         = [data objectForKey:kInviteShareUrl];
    }
}

- (void)updateNotificationsWithData:(NSDictionary *)data{
    self.matchNotification = [[data objectForKey:@"matchNotification"] boolValue];
    self.crushNotification = [[data objectForKey:@"crushNotification"] boolValue];
    self.questionNotification = [[data objectForKey:@"questionNotification"] boolValue];
    self.soundNotification = [[data objectForKey:@"soundAlerts"] boolValue];
}

- (void)updateCountryDtoArrayWithData:(NSArray *)countryDto{
    [self.countryDtoArray removeAllObjects];
    for (NSDictionary *countryDict in countryDto) {
        CountryDtoModel *countryDtoObject = [[CountryDtoModel alloc] init];
        [countryDtoObject updateDataWithCountryDtoDictionary:countryDict];
        if (countryDtoObject.countryCode.length > 0){
        [self.countryDtoArray addObject:countryDtoObject];
        }
    }
}

-(NSArray*)stickersArray{
    NSMutableArray *arrayOfSticker = [[NSMutableArray alloc] init];
    for (NSInteger counter = _stickersStartRange; counter <= _stickersEndRange; counter++) {
        [arrayOfSticker addObject:[NSString stringWithFormat:@"%@_%ld.png",kStickerPrefix,(long)counter]];
    }
    return [arrayOfSticker copy];
}

- (void)updateTemplateQuestionsArrayFromData:(NSArray *)questionArray{
    NSMutableArray *arrayOfQuestions = [[NSMutableArray alloc] init];
    for (NSDictionary *questionObject in questionArray){
        //TargetQuestionModel *targetQuestionModel = [[TargetQuestionModel alloc] initWithData:questionObject];
        [arrayOfQuestions addObject:questionObject];
    }
    self.templateQuestionsArray = arrayOfQuestions;
    [self appTerminationHandler];
}

-(void)updateBotImageUrl:(NSURL *)imageUrlString{
   // self.botImageUrl = imageUrlString;
}

- (void)resetSharedInstance {
    @synchronized(self){
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationWillResignActiveNotification
                                                      object:nil];
        sharedInstance = nil;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"AppLaunchModel"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
}

@end
