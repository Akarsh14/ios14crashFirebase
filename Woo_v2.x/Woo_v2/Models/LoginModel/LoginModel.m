//
//  LoginModel.m
//  Woo_v2
//
//  Created by Deepak Gupta on 5/18/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "LoginModel.h"
#import "SDWebImageDownloader.h"

@implementation LoginModel

/*
+ (LoginModel *)sharedInstance{
    
    static LoginModel *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[super allocWithZone:NULL] init];
    });
    return sharedManager;

}
*/


static LoginModel *sharedInstance = nil;
+ (LoginModel *)sharedInstance {
    @synchronized(self){
        if (!sharedInstance) {
            
            NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
            NSData *decodedObject = [userDefault objectForKey: @"LoginModel"];
            if (decodedObject) {
                sharedInstance = [NSKeyedUnarchiver unarchiveObjectWithData: decodedObject];
            }
            else{
                sharedInstance = [[super allocWithZone:NULL] init];
            }
            
            [[NSNotificationCenter defaultCenter] addObserver:sharedInstance
                                                     selector:@selector(appTerminationHandler)
                                                         name:UIApplicationWillResignActiveNotification
                                                       object:nil];
            
            
        }
        return sharedInstance;
    }
    
}

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


+ (id)allocWithZone:(NSZone *)zone {
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    NSData *decodedObject = [userDefault objectForKey: @"LoginModel"];
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
    
    [encoder encodeObject:self.personalQuoteText forKey:kAboutMePlaceHolder];
    
    [encoder encodeObject:[NSNumber numberWithDouble:self.locationTimeout] forKey:kLocationTimeOut];
    
    [encoder encodeObject:self.birthday forKey:@"birthday"];
    [encoder encodeObject:self.profilePicUrl forKey:@"profilePicUrl"];
    [encoder encodeObject:self.gender forKey:@"gender"];
    [encoder encodeObject:[NSNumber numberWithInt:self.age] forKey:@"age"];
    [encoder encodeObject:self.firstName forKey:@"firstName"];
    [encoder encodeObject:self.lastName forKey:@"lastName"];
    [encoder encodeObject:[NSNumber numberWithBool:self.chatSoundOn] forKey:@"chatSoundOn"];
    
    [encoder encodeObject:[NSNumber numberWithBool:self.hidden] forKey:@"hidden"];
    
    [encoder encodeObject:[NSNumber numberWithInteger:self.WooUserId] forKey:@"WooUserId"];
    
    [encoder encodeObject:[NSNumber numberWithInt:self.maxTagsAllowedCount] forKey:kMaxTagsAllowedCount];
    [encoder encodeObject:[NSNumber numberWithInt:self.minTagsAllowedCount] forKey:kMinTagsAllowedCount];
    
    [encoder encodeObject:self.wooToken forKey:@"wooToken"];

    [encoder encodeObject:[NSNumber numberWithBool:self.locationFound] forKey:kLocationFound];
    
    
    [encoder encodeObject:[NSNumber numberWithBool:self.intentRequired] forKey:@"intentRequired"];
    [encoder encodeObject:[NSNumber numberWithInt:self.intentAgeDifferenceThreshold] forKey:@"intentAgeDifferenceThreshold"];
    [encoder encodeObject:[NSNumber numberWithBool:self.intentDefault] forKey:@"intentDefault"];
    [encoder encodeObject:[NSNumber numberWithInt:self.intentMaxAge] forKey:@"intentMaxAge"];
    [encoder encodeObject:[NSNumber numberWithInt:self.intentMinAge] forKey:@"intentMinAge"];
    
    [encoder encodeObject:[NSNumber numberWithInt:self.minimumAgeAllowedInApp] forKey:@"minimumAgeAllowedInApp"];
    [encoder encodeObject:[NSNumber numberWithInt:self.maximumAgeAllowedInApp] forKey:@"maximumAgeAllowedInApp"];
    [encoder encodeObject: self.interestedGender forKey:@"interestedGender"];
    [encoder encodeObject:[NSNumber numberWithDouble:self.maxDistance] forKey:@"maxDistance"];
    [encoder encodeObject:[NSNumber numberWithBool:self.onboardingPassed] forKey:@"onboardingPassed"];
    [encoder encodeObject:[NSNumber numberWithBool:self.isUserRegistered] forKey:@"isUserRegistered"];
    [encoder encodeObject:[NSNumber numberWithBool:self.isAlternateLogin] forKey:@"isAlternateLogin"];
    [encoder encodeObject:self.appLozicToken forKey:@"appLozicToken"];
    [encoder encodeObject:self.appLozicUserId forKey:@"appLozicUserId"];
      [encoder encodeObject:[NSNumber numberWithBool:self.isNewUserNoPicScreenOn] forKey:@"isPassedNoUserNoPicScreen"];
    [encoder encodeObject:[NSNumber numberWithBool:self.userRelationshipTagsAvailable] forKey:@"userRelationshipTagsAvailable"];
    [encoder encodeObject:[NSNumber numberWithBool:self.userOtherTagsAvailable] forKey:@"userOtherTagsAvailable"];
    [encoder encodeObject:[NSNumber numberWithBool:self.userZodiacTagsAvailable] forKey:@"userZodiacTagsAvailable"];
    [encoder encodeObject:[NSNumber numberWithBool:self.userLifestyleTagsAvailable] forKey:@"userLifestyleTagsAvailable"];
    [encoder encodeObject:[NSNumber numberWithBool:self.isAlertnativeLoginTypeTrueCaller] forKey:@"isAlertnativeLoginTypeTrueCaller"];

    [encoder encodeObject:[NSNumber numberWithBool:self.isNewUserNoPicScreenOn] forKey:@"isNewUserNoPicScreenOn"];
    
    [encoder encodeObject:[NSNumber numberWithBool:self.isPhotoScreenGridOn] forKey:@"isPhotoScreenGridOn"];
    
    
    [encoder encodeObject:[NSNumber numberWithBool:self.otherSoundOn] forKey:@"otherSoundOn"];
    
    [encoder encodeObject:[NSNumber numberWithInt:self.profileCompletenessScore] forKey:@"profileCompletenessScore"];
    
    [encoder encodeObject:[NSNumber numberWithInt:self.minPhotoCountForOnboarding] forKey:@"minPhotoCountForOnboarding"];
    
    [encoder encodeObject:[NSNumber numberWithInt:self.mainFacePercentageThreshold] forKey:@"mainFacePercentageThreshold"];

    [encoder encodeObject:self.startScreenImageUrl forKey:@"startScreenImageUrl"];
    
    
    [encoder encodeObject:self.locationOptions forKey:@"locationOptions"];
    
    [encoder encodeObject:[NSNumber numberWithInteger:self.personalQuoteMaxCharLength] forKey:@"personalQuoteMaxCharLength"];
    [encoder encodeObject:[NSNumber numberWithInteger:self.personalQuoteMinCharLength] forKey:@"personalQuoteMinCharLength"];
    [encoder encodeObject:self.botUrl forKey:@"iosBotUrl"];

    //On-boarding configurable
    [encoder encodeObject:[NSNumber numberWithBool:self.showMyProfileScreen] forKey:@"showMyProfileScreen"];
    
    [encoder encodeObject:[NSNumber numberWithBool:self.showGridScreen] forKey:@"showGridScreen"];
    [encoder encodeObject:[NSNumber numberWithBool:self.showNoUserNoPicScreen] forKey:@"showNoUserNoPicScreen"];
    
    
    [encoder encodeObject:self.personalQuoteText forKey:@"personalQuoteText"];

    // Wizard photo and tags threshold
    [encoder encodeObject:[NSNumber numberWithInteger:self.photoCountThresholdForWizard] forKey:@"photoCountThresholdForWizard"];
    [encoder encodeObject:[NSNumber numberWithInteger:self.tagsCountThresholdForWizard] forKey:@"tagsCountThresholdForWizard"];


}



- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if( self != nil )
    {
        //decode properties, other class vars
        
        self.personalQuoteText = [decoder decodeObjectForKey:@"personalQuoteText"];
        self.locationTimeout = [[decoder decodeObjectForKey:kLocationTimeOut] doubleValue];
        
        self.birthday               = [decoder decodeObjectForKey:@"birthday"];
        self.profilePicUrl               = [decoder decodeObjectForKey:@"profilePicUrl"];
        self.gender               = [decoder decodeObjectForKey:@"gender"];
        self.age               = [[decoder decodeObjectForKey:@"age"] intValue];
        self.chatSoundOn           = [[decoder decodeObjectForKey:@"chatSoundOn"] boolValue];
        self.firstName = [decoder decodeObjectForKey:@"firstName"];
        self.lastName = [decoder decodeObjectForKey:@"lastName"];
       
        self.hidden        = [[decoder decodeObjectForKey:@"hidden"] boolValue];
        
        self.WooUserId          = [[decoder decodeObjectForKey:@"WooUserId"] integerValue];
        //        self.answersUpdateTime;         = [[decoder decodeObjectForKey:@"latestAnsTime"] unsignedLongLongValue];
        
        self.maxTagsAllowedCount = [[decoder decodeObjectForKey:kMaxTagsAllowedCount] intValue];
        self.minTagsAllowedCount = [[decoder decodeObjectForKey:kMinTagsAllowedCount] intValue];
        
        self.wooToken        = [decoder decodeObjectForKey:@"wooToken"];


        
        self.intentRequired                = [[decoder decodeObjectForKey:@"intentRequired"] boolValue];
        self.intentAgeDifferenceThreshold         = [[decoder decodeObjectForKey:@"intentAgeDifferenceThreshold"] intValue];
        self.intentDefault           = [[decoder decodeObjectForKey:@"intentDefault"] boolValue];
        
        self.intentMaxAge          = [[decoder decodeObjectForKey:@"intentMaxAge"] intValue];
        self.intentMinAge   = [[decoder decodeObjectForKey:@"intentMinAge"] intValue];
        self.minimumAgeAllowedInApp  = [[decoder decodeObjectForKey:@"minimumAgeAllowedInApp"] intValue];
        self.interestedGender            = [decoder decodeObjectForKey:@"interestedGender"];
        self.maxDistance        = [[decoder decodeObjectForKey:@"maxDistance"] doubleValue];
        
        self.onboardingPassed               = [[decoder decodeObjectForKey:@"onboardingPassed"] boolValue];
        self.isUserRegistered               = [[decoder decodeObjectForKey:@"isUserRegistered"] boolValue];
        self.isAlternateLogin               = [[decoder decodeObjectForKey:@"isAlternateLogin"] boolValue];
        self.appLozicUserId        = [decoder decodeObjectForKey:@"appLozicUserId"];
        self.appLozicToken        = [decoder decodeObjectForKey:@"appLozicToken"];
        self.isPassedNoUserNoPicScreen = [[decoder decodeObjectForKey:@"isPassedNoUserNoPicScreen"] boolValue];
        self.userRelationshipTagsAvailable = [[decoder decodeObjectForKey:@"userRelationshipTagsAvailable"] boolValue];
        self.userOtherTagsAvailable = [[decoder decodeObjectForKey:@"userOtherTagsAvailable"] boolValue];
        self.userZodiacTagsAvailable = [[decoder decodeObjectForKey:@"userZodiacTagsAvailable"] boolValue];
        self.userLifestyleTagsAvailable = [[decoder decodeObjectForKey:@"userLifestyleTagsAvailable"] boolValue];
       self.isAlertnativeLoginTypeTrueCaller = [[decoder decodeObjectForKey:@"isAlertnativeLoginTypeTrueCaller"] boolValue];
        
          self.isNewUserNoPicScreenOn               = [[decoder decodeObjectForKey:@"isNewUserNoPicScreenOn"] boolValue];
        
          self.isPhotoScreenGridOn               = [[decoder decodeObjectForKey:@"isPhotoScreenGridOn"] boolValue];
        
        self.otherSoundOn                = [[decoder decodeObjectForKey:@"otherSoundOn"] boolValue];
        
        self.locationFound = [[decoder decodeObjectForKey:kLocationFound] boolValue];
        
        self.profileCompletenessScore    = [[decoder decodeObjectForKey:@"profileCompletenessScore"] intValue];
        
        self.minPhotoCountForOnboarding    = [[decoder decodeObjectForKey:@"minPhotoCountForOnboarding"] intValue];
        
        self.mainFacePercentageThreshold = [[decoder decodeObjectForKey:@"mainFacePercentageThreshold"] intValue];

        NSString *urlString = [decoder decodeObjectForKey:@"startScreenImageUrl"];
        if (urlString) {
            self.startScreenImageUrl             =  [decoder decodeObjectForKey:@"startScreenImageUrl"];
        }else{
            self.startScreenImageUrl = nil;
        }

        self.locationOptions     = [decoder decodeObjectForKey:@"locationOptions"];
        
        
        self.personalQuoteMaxCharLength = [[decoder decodeObjectForKey:@"personalQuoteMaxCharLength"] integerValue];
        self.personalQuoteMinCharLength = [[decoder decodeObjectForKey:@"personalQuoteMinCharLength"] integerValue];
        self.botUrl = [decoder decodeObjectForKey:@"iosBotUrl"];
        
        //On-boarding configurable
        self.showMyProfileScreen           = [[decoder decodeObjectForKey:@"showMyProfileScreen"] boolValue];
        
             self.showGridScreen           = [[decoder decodeObjectForKey:@"showGridScreen"] boolValue];
        
             self.showNoUserNoPicScreen           = [[decoder decodeObjectForKey:@"showNoUserNoPicScreen"] boolValue];
        
        self.isNewUserNoPicScreenOn =  self.showNoUserNoPicScreen;

        // Wizard photo and tags threshold
        self.photoCountThresholdForWizard = [[decoder decodeObjectForKey:@"photoCountThresholdForWizard"] intValue];
        self.tagsCountThresholdForWizard = [[decoder decodeObjectForKey:@"tagsCountThresholdForWizard"] intValue];
    }

    return self;

}







#pragma mark - Update Login API Data
-(void)updateModelWithData:(NSDictionary*)data andLoginType:(NSString *)loginType{

    /**************************** About Me Parsing ***********************/

    if ([[data objectForKey:kAboutMeInfoDto] objectForKey:kRequired]) {
        self.aboutMeRequired = [[[data objectForKey:kAboutMeInfoDto] objectForKey:kRequired] boolValue];
    }
    
    if ([[[data objectForKey:kAboutMeInfoDto] objectForKey:kData] objectForKey:kAboutMePlaceHolder])
        self.aboutMetext = [[[data objectForKey:kAboutMeInfoDto] objectForKey:kData] objectForKey:kAboutMePlaceHolder];
    
    if ([data objectForKey:@"firstName"]){
        self.firstName = [data objectForKey:@"firstName"];
    }
    
    if ([data objectForKey:@"lastName"]){
        self.lastName = [data objectForKey:@"lastName"];
    }
    
    if ([[[data objectForKey:kAboutMeInfoDto] objectForKey:kData] objectForKey:kDefault])
        self.aboutMeDefault = [[[[data objectForKey:kAboutMeInfoDto] objectForKey:kData] objectForKey:kDefault] boolValue];
    
    
        if ([[[data objectForKey:kAboutMeInfoDto] objectForKey:kData] objectForKey:kAboutMeMaxCharLength]) 
            self.personalQuoteMaxCharLength = [[[[data objectForKey:kAboutMeInfoDto] objectForKey:kData] objectForKey:kAboutMeMaxCharLength] intValue];

            if ([[[data objectForKey:kAboutMeInfoDto] objectForKey:kData] objectForKey:kAboutMeMinCharLength])
                self.personalQuoteMinCharLength = [[[[data objectForKey:kAboutMeInfoDto] objectForKey:kData] objectForKey:kAboutMeMinCharLength] intValue];
        
        
    
    if ([[[data objectForKey:kAboutMeInfoDto] objectForKey:kData] objectForKey:kAboutMePlaceHolder])
        self.personalQuoteText = [[[data objectForKey:kAboutMeInfoDto] objectForKey:kData] objectForKey:kAboutMePlaceHolder];

    
    
    /**************************** About Me Parsing ***********************/
    
    
    // For New User No Pic
    if ([data objectForKey:kPhotoFoundFromFacebook]) {
        self.photoFoundFromFacebook = [[data objectForKey:kPhotoFoundFromFacebook] boolValue];
    }
    
    // Location Found or not
    if ([data objectForKey:kLocationFound]) {
        self.locationFound = [[data objectForKey:kLocationFound] boolValue];
    }
    
// For Location TimeOut
    if ([data objectForKey:kLocationTimeOut]) {
        self.locationTimeout = [[data objectForKey:kLocationTimeOut] doubleValue];
    }

    
    
    if ([data objectForKey:kUserTagAvailable]) {
        self.userTagAvailable = [[data objectForKey:kUserTagAvailable] boolValue];
    }
    
    //Manually done
  //  self.userTagAvailable = FALSE;
    
    if ([data objectForKey:kWooToken]) {
        self.wooToken = [data objectForKey:kWooToken];
    }
    
    if ([data objectForKey:kAge])
        self.age = [[data objectForKey:kAge] intValue];
    else
        self.age = 0;
    
    if ([data objectForKey:kBirthday])
        self.birthday = [data objectForKey:kBirthday];
    
    if ([data objectForKey:kProfilePicUrl])
        self.profilePicUrl = [data objectForKey:kProfilePicUrl];
    else{
        self.profilePicUrl = nil;
    }
    
    if ([data objectForKey:kChatSoundOn])
        self.chatSoundOn = [[data objectForKey:kChatSoundOn] boolValue];

    if ([data objectForKey:kOnBoardingPassed])
        self.onboardingPassed = [[data objectForKey:kOnBoardingPassed] boolValue];
    
    if ([data objectForKey:kIsUserRegistered])
        self.isUserRegistered = [[data objectForKey:kIsUserRegistered] boolValue];
    else
        self.isUserRegistered = false;
    
    if ([data objectForKey:kisNewUserNoPicScreenOn])
        self.isNewUserNoPicScreenOn = [[data objectForKey:kisNewUserNoPicScreenOn] boolValue];
    self.isPassedNoUserNoPicScreen = self.isNewUserNoPicScreenOn;
    
    if ([data objectForKey:kisPhotoScreenGridOn])
        self.isPhotoScreenGridOn = [[data objectForKey:kisPhotoScreenGridOn] boolValue];
    
    if ([data objectForKey:kuserRelationshipTagsAvailable])
        self.userRelationshipTagsAvailable = [[data objectForKey:kuserRelationshipTagsAvailable] boolValue];
    
    if ([data objectForKey:kuserZodiacTagsAvailable])
        self.userZodiacTagsAvailable = [[data objectForKey:kuserZodiacTagsAvailable] boolValue];
    
    if ([data objectForKey:kuserOtherTagsAvailable])
        self.userOtherTagsAvailable = [[data objectForKey:kuserOtherTagsAvailable] boolValue];
    
    if ([data objectForKey:kuserLifestyleTagsAvailable])
        self.userLifestyleTagsAvailable = [[data objectForKey:kuserLifestyleTagsAvailable] boolValue];
    
    // Login if user user onborading = 0 then make confirm = 0 because this logic is for previous version user should also see the onboarding.
    if (!self.onboardingPassed) {
        self.confirmed = self.onboardingPassed;
    }else if ([data objectForKey:kConfirmed])
        self.confirmed = [[data objectForKey:kConfirmed] boolValue];
    
    
    
    
    if ([data objectForKey:kGender])
        self.gender = [data objectForKey:kGender];
    else{
        self.gender = @"UNKNOWN";
    }
    
    
    if ([data objectForKey:kisNewUserNoPicScreenOn])
        self.isNewUserNoPicScreenOn = [[data objectForKey:kisNewUserNoPicScreenOn] boolValue];
    
    
    if ([data objectForKey:kisPhotoScreenGridOn])
        self.isPhotoScreenGridOn = [[data objectForKey:kisPhotoScreenGridOn] boolValue];
    
    if ([data objectForKey:kHidden])
        self.hidden = [[data objectForKey:kHidden] boolValue];
    
    
    if ([data objectForKey:kWooUserId])
        self.WooUserId = [[data objectForKey:kWooUserId] intValue];
    
    if ([data objectForKey:kMaxTagsAllowedCount])
        self.maxTagsAllowedCount = [[data objectForKey:kMaxTagsAllowedCount] intValue];

    if ([data objectForKey:kMinTagsAllowedCount])
        self.minTagsAllowedCount = [[data objectForKey:kMinTagsAllowedCount] intValue];

    
    /**************************** Intent Parsing ***********************/

    [self initialiseAllValues];
    
    if ([[data objectForKey:kIntentDto] objectForKey:kRequired])
        self.intentRequired = [[[data objectForKey:kIntentDto] objectForKey:kRequired] boolValue];
    

    if ([[[data objectForKey:kIntentDto] objectForKey:kData] objectForKey:kAgeDifferenceThreshold])
        self.intentAgeDifferenceThreshold = [[[[data objectForKey:kIntentDto] objectForKey:kData] objectForKey:kAgeDifferenceThreshold] intValue];
    
    
    if ([[[data objectForKey:kIntentDto] objectForKey:kData] objectForKey:kDefault])
        self.intentDefault = [[[[data objectForKey:kIntentDto] objectForKey:kData] objectForKey:kDefault] boolValue];

    
    if ([[[data objectForKey:kIntentDto] objectForKey:kData] objectForKey:@"interestedGender"]){
        self.genderPreference = [APP_Utilities getGenderPreference:[[[data objectForKey:kIntentDto] objectForKey:kData] objectForKey:@"interestedGender"]];
        
        [[NSUserDefaults standardUserDefaults] setObject:[[[data objectForKey:kIntentDto] objectForKey:kData] objectForKey:@"interestedGender"] forKey:kGenderPreference];
    }
    
    if ([[[data objectForKey:kIntentDto] objectForKey:kData] objectForKey:kFavIntent])
        self.favIntent = [APP_Utilities getIntentType:[[[data objectForKey:kIntentDto] objectForKey:kData] objectForKey:kFavIntent]] ;
    
   
    if ([[[data objectForKey:kIntentDto] objectForKey:kData] objectForKey:kMaxAge]){
        self.intentMaxAge = [[[[data objectForKey:kIntentDto] objectForKey:kData] objectForKey:kMaxAge] intValue];
        [DiscoverProfileCollection sharedInstance].intentModelObject.maxAge = [NSNumber numberWithInteger:[[[[data objectForKey:kIntentDto] objectForKey:kData] objectForKey:kMaxAge] integerValue]] ;
    }
    
    
    if ([[[data objectForKey:kIntentDto] objectForKey:kData] objectForKey:kMinAge]){
        self.intentMinAge = [[[[data objectForKey:kIntentDto] objectForKey:kData] objectForKey:kMinAge] intValue];
        [DiscoverProfileCollection sharedInstance].intentModelObject.minAge = [NSNumber numberWithInteger:[[[[data objectForKey:kIntentDto] objectForKey:kData] objectForKey:kMinAge] integerValue]];
    }
    
    if ([[[data objectForKey:kIntentDto] objectForKey:kData] objectForKey:kMinAllowedWoo])
        self.minimumAgeAllowedInApp = [[[[data objectForKey:kIntentDto] objectForKey:kData] objectForKey:kMinAllowedWoo] intValue];
    
    if ([[[data objectForKey:kIntentDto] objectForKey:kData] objectForKey:kMaxAllowedWoo])
        self.maximumAgeAllowedInApp = [[[[data objectForKey:kIntentDto] objectForKey:kData] objectForKey:kMaxAllowedWoo] intValue];


    
    /**************************** Intent Parsing ***********************/

    
    if ([data objectForKey:kInterestedGender]){
        self.interestedGender = [data objectForKey:kInterestedGender];
        
        [DiscoverProfileCollection sharedInstance].intentModelObject.interestedGender = self.interestedGender;
    }
    
    if ([data objectForKey:kMaxDistance]){
        self.maxDistance = [[data objectForKey:kMaxDistance] intValue];
        [DiscoverProfileCollection sharedInstance].intentModelObject.maxDistance = [NSNumber numberWithInteger:[[data objectForKey:kMaxDistance] integerValue]];
    }
    
    [[DiscoverProfileCollection sharedInstance] appTerminationHandler];
    
    if ([data objectForKey:kOtherSoundOn])
        self.otherSoundOn = [[data objectForKey:kOtherSoundOn] boolValue];

    if ([data objectForKey:kProfileCompletenessScore])
        self.profileCompletenessScore = [[data objectForKey:kProfileCompletenessScore] intValue];
    
    if ([data objectForKey:@"minPhotoCountForOnboarding"])
        self.minPhotoCountForOnboarding =  [[data objectForKey:@"minPhotoCountForOnboarding"] intValue];
    else
        self.minPhotoCountForOnboarding = 0;

    
    /**************************** Start Screen Parsing ***********************/
    
    if ([data objectForKey:@"mainFacePercentageThreshold"]){
        self.mainFacePercentageThreshold =  [[data objectForKey:@"mainFacePercentageThreshold"] intValue];
    }
    else{
        self.mainFacePercentageThreshold = 5;
    }
    
    if ([[data objectForKey:kStartScreenDto] objectForKey:kStartScreenBody])
        self.startScreenBody = [[data objectForKey:kStartScreenDto] objectForKey:kStartScreenBody];
    
    
    
    if ([[data objectForKey:kStartScreenDto] objectForKey:@"body1"])
        self.startScreenBody1 = [[data objectForKey:kStartScreenDto] objectForKey:@"body1"];
    
    if ([[data objectForKey:kStartScreenDto] objectForKey:@"body2"])
        self.startScreenBody2 = [[data objectForKey:kStartScreenDto] objectForKey:@"body2"];

    if ([[data objectForKey:kStartScreenDto] objectForKey:@"body3"])
        self.startScreenBody3 = [[data objectForKey:kStartScreenDto] objectForKey:@"body3"];

    if ([[data objectForKey:kStartScreenDto] objectForKey:kStartScreenButtonText])
        self.startScreenButtonText = [[data objectForKey:kStartScreenDto] objectForKey:kStartScreenButtonText];

    if ([[data objectForKey:kStartScreenDto] objectForKey:kStartScreenFooter])
        self.startScreenFooter = [[data objectForKey:kStartScreenDto] objectForKey:kStartScreenFooter];
    
    if ([[data objectForKey:kStartScreenDto] objectForKey:kStartScreenImageUrl]){
        self.startScreenImageUrl = [NSURL URLWithString:[[data objectForKey:kStartScreenDto] objectForKey:kStartScreenImageUrl]];
       // [[AppLaunchModel sharedInstance] updateBotImageUrl:self.startScreenImageUrl];
    }
    
    if ([[data objectForKey:kStartScreenDto] objectForKey:kRequired])
        self.startScreenRequired = [[[data objectForKey:kStartScreenDto] objectForKey:kRequired] boolValue];
    
//    if ([[data objectForKey:kStartScreenDto] objectForKey:kStartScreenTitle])
//        self.startScreenTitle = [[data objectForKey:kStartScreenDto] objectForKey:kStartScreenTitle];


    /**************************** Start Screen Parsing ***********************/

    
    
    
    /**************************** Location Option Parsing **********************/

    if ([data objectForKey:kLocationOptions] && [[data objectForKey:kLocationOptions] isKindOfClass:[NSArray class]]){
        self.locationOptions = [data objectForKey:kLocationOptions];
    
        // Saving prediction list in NSUserDefault
        [[NSUserDefaults standardUserDefaults] setObject:self.locationOptions forKey:kLocationOptions];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    /**************************** Location Option Parsing **********************/
    
    if ([data objectForKey:@"iosBotUrl"]) {
        self.botUrl = [NSURL URLWithString:[data objectForKey:@"iosBotUrl"]];
    }

    if ([data objectForKey:@"state"]) {
        self.state = [data objectForKey:@"state"];
    }
    
    if ([data objectForKey:@"city"]) {
        self.city = [data objectForKey:@"city"];
    }
    
    //On-boarding configurable
    
    if ([data objectForKey:kShowMyProfileScreen]) {
        self.showMyProfileScreen = [[data objectForKey:kShowMyProfileScreen] boolValue];
    }
    
    
    
    if ([data objectForKey:kshowGridScreen]) {
        self.showGridScreen = [[data objectForKey:kshowGridScreen] boolValue];
    }
    
    if ([data objectForKey:kshowNoUserNoPicScreen]) {
        self.showNoUserNoPicScreen = [[data objectForKey:kshowNoUserNoPicScreen] boolValue];
    }
    
    
    // Wizard photo and tags threshold
    if ([data objectForKey:ktagsCountThresholdForWizard]){
        self.tagsCountThresholdForWizard = [[data objectForKey:ktagsCountThresholdForWizard] intValue];
    }
    if ([data objectForKey:kphotoCountThresholdForWizard]){
        self.photoCountThresholdForWizard = [[data objectForKey:kphotoCountThresholdForWizard] intValue];
    }
    
    if ([data objectForKey:kappLozicUserId]){
        self.appLozicUserId = [data objectForKey:kappLozicUserId];
    }else{
        self.appLozicUserId = @"";
    }
    
    if ([data objectForKey:kappLozicToken]){
        self.appLozicToken = [data objectForKey:kappLozicToken];
    }else{
        self.appLozicToken = @"";
    }
    
    
    if (loginType.length > 0){
        if([loginType isEqualToString:LoginViaFacebook]) {
            self.isAlternateLogin = NO;
        } else {
            self.isAlternateLogin = YES;
            if ([loginType isEqualToString:LoginViaTrueCaller]){
                self.isAlertnativeLoginTypeTrueCaller = YES;
            }
            else{
                self.isAlertnativeLoginTypeTrueCaller = NO;
            }
        }
    }
    //54321
    
    //self.age = 0;
    //self.gender = @"UNKNOWN";
    //self.showNoUserNoPicScreen = true;
    //self.minPhotoCountForOnboarding = 0;
     [self appTerminationHandler];
}

-(void) appTerminationHandler{
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:self];
    [userDefault setObject:encodedObject forKey:@"LoginModel"];
    [userDefault synchronize];
}


-(void)initialiseAllValues{
    // initialising value with default value
    self.genderPreference = SELECTED_GENDER_PREFERENCE_NONE;
    self.favIntent = INTENT_TYPE_NONE;
    self.intentMinAge = 0;
    self.intentMaxAge = 0;
    self.minimumAgeAllowedInApp = 18;
    self.maximumAgeAllowedInApp = 50;
}


- (void)resetSharedInstance {
    @synchronized(self){
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationWillResignActiveNotification
                                                      object:nil];
        sharedInstance = nil;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"LoginModel"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
}

@end
