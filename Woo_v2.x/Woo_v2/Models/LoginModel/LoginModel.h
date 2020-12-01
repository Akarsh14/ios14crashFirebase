//
//  LoginModel.h
//  Woo_v2
//
//  Created by Deepak Gupta on 5/18/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
 {
 aboutMeInfoDto =     {
 data =         {
 default = 0;
 maxCharLength = 190;
 minCharLength = 60;
 text = Gfvhvj;
 };
 required = 1;
 };
 age = 29;
 birthday = "03/18/1987";
 chatSoundOn = 1;
 confirmed = 0;
 gender = MALE;
 hidden = 0;
 id = 4026700;
 intentDto =     {
 data =         {
 ageDifferenceThreshold = 4;
 default = 1;
 love = FEMALE;
 maxAge = 36;
 minAge = 22;
 };
 required = 1;
 };
 interestedGender = FEMALE;
 locationOptions =     (
 );
 maxDistance = 2147483647;
 onboardingPassed = 1;
 otherSoundOn = 1;
 profileCompletenessScore = 0;
 startScreenDto =     {
 body = "Dummy body Text ..";
 buttonText = "Dummy button Text ..";
 footer = "Dummy footer Text ..";
 imgUrl = "http://cdn.theatlantic.com/assets/media/img/photo/2015/11/images-from-the-2016-sony-world-pho/s01_130921474920553591/main_1200.jpg?1448476701";
 required = 1;
 title = "Dummy Title Text ..";
 };
 userId = 10207286503018419;
 wooToken = "7991ff1e-e365-4ed3-8faf-5ab1812d252a";
 }
 */
@interface LoginModel : NSObject

@property (nonatomic , strong) NSString          *aboutMetext;
@property (nonatomic , strong) NSString          *firstName;
@property (nonatomic , strong) NSString          *lastName;
@property (nonatomic , assign) BOOL              aboutMeRequired;
@property (nonatomic , assign) BOOL              isNewUserNoPicScreenOn;
@property (nonatomic , assign) BOOL              isPhotoScreenGridOn;


@property (nonatomic , assign) BOOL              aboutMeDefault;
@property (nonatomic , assign) int               aboutMeMaxCharLength;
@property (nonatomic , assign) int               aboutMeMinCharLength;

@property (nonatomic , assign) NSInteger               personalQuoteMaxCharLength;
@property (nonatomic , assign) NSInteger               personalQuoteMinCharLength;
@property (nonatomic , strong) NSString               *personalQuoteText;

@property (nonatomic , assign) BOOL              showMyProfileScreen;


@property (nonatomic , assign) BOOL              showNoUserNoPicScreen;
@property (nonatomic , assign) BOOL              showGridScreen;
@property (nonatomic , assign) BOOL              isAlertnativeLoginTypeTrueCaller;
@property (nonatomic , assign) int               age;
@property (nonatomic , strong) NSString          *birthday;
@property (nonatomic , strong) NSString          *profilePicUrl;
@property (nonatomic , assign) BOOL              chatSoundOn;
@property (nonatomic , assign) BOOL              confirmed;
@property (nonatomic , strong) NSString          *gender;
@property (nonatomic , assign) BOOL              hidden;
@property (nonatomic , assign) NSInteger         WooUserId;
@property (nonatomic , assign) BOOL              photoFoundFromFacebook;
@property (nonatomic , assign) BOOL              locationFound;
@property (nonatomic , assign) BOOL              userTagAvailable;
@property (nonatomic , strong) NSString          *wooToken;
@property (nonatomic , assign) BOOL              intentRequired;
@property (nonatomic , assign) int               intentAgeDifferenceThreshold;
@property (nonatomic , assign) BOOL              intentDefault;
//@property (nonatomic , assign) SelectedGenderPreference          genderPreferenceForLove;               //removed intentLove(NSString) as replace it other variable with different data type
//@property (nonatomic , assign) SelectedGenderPreference          genderPreferenceForCasual;
//@property (nonatomic , assign) SelectedGenderPreference          genderPreferenceForFriend;
@property (nonatomic , assign) SelectedGenderPreference genderPreference;
@property (nonatomic , assign) IntentType        favIntent;
@property (nonatomic , assign) int               intentMaxAge;
@property (nonatomic , assign) int               intentMinAge;
@property (nonatomic , assign) int               minimumAgeAllowedInApp;
@property (nonatomic , assign) int               maximumAgeAllowedInApp;
@property (nonatomic , strong) NSString          *interestedGender;

@property (nonatomic , strong) NSString          *city;
@property (nonatomic , strong) NSString          *state;


@property (nonatomic , assign) double            maxDistance;
@property (nonatomic , assign) BOOL              onboardingPassed;
@property (nonatomic , assign) BOOL              isUserRegistered;
@property (nonatomic , assign) BOOL              otherSoundOn;
@property (nonatomic , assign) int               profileCompletenessScore;
@property (nonatomic , assign) int               minPhotoCountForOnboarding;
@property (nonatomic , assign) int               mainFacePercentageThreshold;

@property (nonatomic , strong) NSString          *startScreenBody;
@property (nonatomic , strong) NSString          *startScreenBody1;
@property (nonatomic , strong) NSString          *startScreenBody2;
@property (nonatomic , strong) NSString          *startScreenBody3;
@property (nonatomic , strong) NSString          *startScreenButtonText;
@property (nonatomic , strong) NSString          *startScreenFooter;
@property (nonatomic , strong) NSURL             *startScreenImageUrl;
@property (nonatomic , assign) BOOL              startScreenRequired;
@property (nonatomic , strong) NSString          *startScreenTitle;

@property (nonatomic , strong) NSArray      *locationOptions;
@property (nonatomic , assign) double          locationTimeout;

@property (nonatomic, assign) BOOL isAlternateLogin;
@property (nonatomic, strong) NSString* appLozicUserId;
@property (nonatomic, strong) NSString* appLozicToken;

@property (nonatomic, assign) BOOL isPassedNoUserNoPicScreen;
@property (nonatomic, assign) BOOL userLifestyleTagsAvailable;
@property (nonatomic, assign) BOOL userOtherTagsAvailable;
@property (nonatomic, assign) BOOL userRelationshipTagsAvailable;
@property (nonatomic, assign) BOOL userZodiacTagsAvailable;

@property (nonatomic , strong) NSURL             *botUrl;

@property (nonatomic , assign) int                minTagsAllowedCount;
@property (nonatomic , assign) int                maxTagsAllowedCount;

// Wizard photo and tags threshold
@property (nonatomic , assign) int                tagsCountThresholdForWizard;
@property (nonatomic , assign) int                photoCountThresholdForWizard;

- (void)resetSharedInstance;

+ (LoginModel *)sharedInstance;

/**
 *  Method is to save Login API response.
 *
 *  @param Dictionary.
 */
-(void)updateModelWithData:(NSDictionary*)data andLoginType:(NSString *)loginType;
@end
