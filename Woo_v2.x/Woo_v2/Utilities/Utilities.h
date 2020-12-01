//
//  Utilities.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 18/05/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#import "UConstant.h"
#import "LoaderView.h"
#import "ChatImageCell.h"
#import "SenderImageCell.h"
#import "ChatMessage.h"
#import "DACircularProgressView.h"
#import "UEnumConstant.h"
#import "WooLoader.h"
#import "Mixpanel/Mixpanel.h"


@class UserProfileModel;
@class EditProfileProgressbar;
@class NewChatViewController;

@interface Utilities : NSObject{
    UIView *backgroundView;
    
    UIActivityIndicatorView *activityIndicatorObj;
    LoaderView *loaderViewObj;
    WooLoader *customLoader;
    
    
}

typedef void(^DeletionCompletionHandler)(BOOL isDeletionCompleted);
typedef void(^ImageCompletionHandler)(BOOL completed);
typedef void(^LayerDeAuthenticationSuccessHandler)(BOOL isDeauthenticationCompleted);

#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)

+ (id)sharedUtility;

-(UserProfileModel*)myprofile;

-(UIBarButtonItem *)createLeftButtonViewOnNavBar:(SEL)selectorForButtonTapped withDelegate:(id)delegate;

/**
 @author : Lokesh Sehgal
 Method to check whether the string is null or not, if it is then convert it to empty
 @param : error due to which login is failed, error is an object of class NSError
 */
- (NSString *)validString:(NSString *)string;

/**
 *  <#Description#>
 *
 *  @param feedbackStr <#feedbackStr description#>
 *
 *  @return <#return value description#>
 */
- (NSString*) encodeFromPercentEscapeString:(NSString*)feedbackStr;



-(NSString *)getURLDecodedStringFromString:(NSString *)encodedString;

/**
 @author Umesh
 Method to get date from the given timestamp
 @param timeStamp of type long long type.
 @return date obj after converting timeStamp into NSDate
 */
-(NSDate *)returnDateFromTimeStamp:(long long)timeStamp;

/**
 *  <#Description#>
 *
 *  @param notificationTypeString <#notificationTypeString description#>
 *
 *  @return <#return value description#>
 */
-(NotificationType )getNotificationTypeFor:(NSString *)notificationTypeString;

/**
 *  <#Description#>
 *
 *  @param typeOfNotif <#typeOfNotif description#>
 *
 *  @return <#return value description#>
 */
-(NSString *)getAddidtionalDataKeyForNotificationType:(NotificationType )typeOfNotif;
-(void)colorStatusBar:(UIColor *)colorStatusBar;

/**
 Method to show activilty view on window
 */
-(void)showActivityIndicator;
/**
 Method to hide activilty view from window
 */
-(void)hideActivityIndicator;

-(int)getImageSizeForPoints:(int)pointSize;

/**
 *  Method to check if gender is male or female.
 *
 *  @param gender : String gender value of a user
 *
 *  @return TRUE if gender value is male else return false. 
 */
-(BOOL)isGenderMale:(NSString *)gender;

/**
 *  Method to get document directory path
 *
 *  @return document directory path in string type
 */
- (NSString *)applicationDocumentsDirectory;

/**
 *  Method to get cache directory path
 *
 *  @return cache directory path in string type
 */
- (NSString *)applicationCacheDirectory;

/**
 *  Method to show alert view. Alert view will be a custome view.
 *
 *  @param alertTitle   Alert title that will be shown on the alert
 *  @param alertMessage A message that will shown to user on the alert.
 *  @param delegate     delegate to the class where control needs to passed if any button of the alert is tapped. It will nil if control should not be passed anywhere.
 */
- (void)displayAlertWithTitle:(NSString *)alertTitle message:(NSString *)alertMessage withDelegate:(id)delegate;
/**
 *  Method to show alert view. Alert view will be a custome view.
 *
 *  @param alertTitle          Alert title that will be shown on the alert
 *  @param alertMessage        A message that will shown to user on the alert.
 *  @param delegate            delegate to the class where control needs to passed if any button of the alert is tapped. It will nil if control should not be passed anywhere.
 *  @param selectorOnButtonTap selector which should be called when any button on the alert is tapped. The controll will transfered to the Class specified by the "delegate", in the method specified by the selector.
 */
//- (void)displayAlertWithTitle:(NSString *)alertTitle message:(NSString *)alertMessage withDelegate:(id)delegate andSelectorForButtonTap:(SEL)selectorOnButtonTap;

/**
 *  This method will check if any fb permission is missing from the set of permission required by the app.
 *
 *  @return TRUE is retured if any permission is missing else FALSE will be returned.
 */
-(BOOL)isFacebookPermissionMissing;

/**
 *  Method to get iOS version of the device.
 *
 *  @return current iOS version of the system in decimal value.
 */
-(float )returnOSVersion;

/**
 *  Method to push notification permission from user.
 */
-(void)getPushNotificationPermission;


/**
 @author : Umesh Mishra
 Method to perform fade in animation on the given view
 @param : view that needs to fade in. viewObj is an object of UIView class
 */
-(void)fadeInView:(UIView *)viewObj;

/**
 @author : Umesh Mishra
 Method to perform fade out animation on the given view and remove it when animation is complete
 @param : view that needs to fade out. viewObj is an object of UIView class
 */
-(void)fadeOutAndRemoveView:(UIView *)viewObj;


/**
 @author Umesh Mishra
 Method rounded top left and top right corner of a view.
 @param viewObj of type UIView. View on which operation needs to be performed
 */
-(void)makeTopCornersOfViewRounded:(UIView *)viewObj;

-(void)makeBottomCornersOfViewRounded:(UIView *)viewObj;

-(void)makeBottomCornersOfViewRounded:(UIView *)viewObj withRadiud:(float)raiudVal;

/**
 @author Umesh Mishra
 Method to get height for string for given font .
 @param text of type NSString, for which height needs to be calculated
 @param font of type UIFont, font that will be used on text.
 */
-(float)getHeightForText:(NSString *)text forFont:(UIFont *)font widthOfLabel:(float )width;


/**
 *  @author Vaibhav Gautam
 *
 *  @param tappedButton buton which is tapped
 *
 *  @return a dictionary which can be used to identify tag type, tag id and tag text.
 */
-(NSDictionary *)createTappedTagDataDictForButton:(UIButton *)tappedButton;

/**
 *  Give scale animation to an object
 *
 *  @param viewObj view to be scaled
 */
-(void)scaleUpAnimationOnView:(id)viewObj withNumberOfTimes:(int)repeatCount;



/**
 *  This metod will animate anyview to scale up and back animation for duration provided
 *
 *  @param viewObj                      view to be animated
 *  @param repeatCount                  number of times view to be animated
 *  @param animationDuration            duration of animation
 */
-(void)scaleUpAnimationOnView:(id)viewObj withNumberOfTimes:(int)repeatCount withTimeDuration:(CGFloat )animationDuration;


/**
 *  Method to show toast on on No internet connection
 
 */
-(void)showNoInternetAvailableToast;

/**
 *  Method to show loader view on screen. (Discover view loader screen.)
 *
 *  @param grayText        Text that will not be highlighted
 *  @param highlightedText Text that should be highlighted
 */
-(void)showLoaderViewWithText:(NSString *)grayText andHighlightedText:(NSString *)highlightedText onView:(UIView *)viewObj;

/**
 *  This method will show a toast on top of everything
 *
 *  @param text text to be displayed in toast
 */
-(void) showToastWithText:(NSString *)text;

/**
 *  Method to remove loader view from the screen. 
 */
-(void)hideLoaderView;

/**
 @author Umesh
 Method to rename file present at given path with new name.
 
 @param filePath of type NSString. Its the path where file that is to be renamed should be present.
 
 @param newFilePath of type NSString. Path of renamed file.
 
 @return BOOL value. Returns TRUE if file exists at given path else returns FALSE.
 */

-(BOOL)renameFilePresentAtPath:(NSString *)filePath withNewFilePath:(NSString *)newFilePath;


/**
 *  Method to get date time string from the given time string for the given date format
 *
 *  @param timeInterVal        time interval that needs to be changed date time string
 *  @param dateFormattingStrng date formatter in which the date time string should be returned from the
 *
 *  @return date time string that will be returned after formatting timeInterVal into format dateFormattingStrng
*/
-(NSString *)getDateStringForTimeInterval:(long long)timeInterVal withDateFormatting:(NSString *)dateFormattingStrng;


-(BOOL)isLocationServicesDisabled;

-(BOOL)isDayChangedFromTheDate:(NSDate *)lastDateVal;

-(BOOL)reachable;

-(void)openURLForURLString:(NSString *)URLString;


-(BOOL)deleteFileAtPath:(NSString *)filePath;

-(BOOL)checkIfFileExistsAtPath:(NSString *)filePath;

-(NSString *)filePathAfterAppendingDocumentDirectoryPathToGivenFileName:(NSString *)fileName;

-(NSString *)getAudioPathForFileName:(NSString *)fileName;

-(BOOL)canAskMoreQuestions;

//-(void)checkAndUpdateUserProfilesTagsOptions;

- (NSString*) convertDictionaryToString:(NSMutableDictionary*) dict;


-(void)uploadPicAndShowProgressForCell:(SenderImageCell *)chatImageCellObj withCircularProgressView:(EditProfileProgressbar *)progressViewObj forChatMessage:(ChatMessage *)chatMessageObj;

-(NSString *)returnDateStringOfTimestamp:(NSDate *)convertedDate;

-(BOOL)isIndianUser;

//-(ScreenOpenNotificationType )getScreenToBeOpenedFromNotificationString:(NSString *)redirectionString;

-(NSMutableArray *)getArrayAfterFiltering:(NSArray *)arrayToBeFiltered forKey:(NSString *)keyVal andForValue:(NSString *)value;

-(NSString *)getBadgeTextForMatchboxButton;

-(NSString *)getDateStringForDate:(NSDate *)dateVal forDateFormate:(NSString *)dateFromate;

-(BOOL)isitAniPhone5;

-(BOOL)isitAniPhone4;

- (NSString *)decodeFromPercentEscapingString:(NSString *)stringToDecode;

-(BOOL)checkIfPushNotificationIsEnabled;

-(NSDictionary *)convertStringToDictionary:(NSString *)jsonString;

-(UIImage *)getSameGenderPlaceholder;
-(UIImage *)getOppositeGenderPlaceholder;

-(BOOL)isUserAlreadyMyMatche:(NSString *)userWooId;


-(NSMutableArray *)getArrayAfterFiltering:(NSArray *)arrayToBeFiltered forKey:(NSString *)keyVal andForTagTypeKey:(NSString *)tagTaypeKey andForTagDetail:(NSDictionary *)tagDetail;

-(void)deleteAudioFolder;
-(void)deleteImageFolder;
-(void)deleteImageAndAudioFolder;

- (void)removeToast;

-(BOOL)isValidEmail:(NSString *)checkString;

-(NSString *)createHashedTokenForTimestamp:(NSString *)timestamp;


-(void)makeSilentLoginCallToFetchWooSecurityToken;

-(void)updatePendingFavListWithMatchID:(NSString *)favMatchID;

-(void)updatePendingUnFavListWithMatchID:(NSString *)unFavMatchID;

/**
 *  Calculating UILabel Width & Height From Text

 *
 *  @param lbl passing UILabel Object
 *
 *  @return Returning Height & Width
 */
-(CGSize)getTextWidthHeight : (id)lbl;


/**
 *  Checking whether key exist in NSDictionary
 *
 *  @param dict    NSDictionary
 *  @param str_key key value
 *
 *  @return return Yes if key exist.
 */
-(BOOL)isKeyExist:(NSDictionary *)dict withKey : (NSString *)str_key;

/**
 *  method to get first part of message that is displayed on loader view when user is performing tag search
 *
 *  @param tagType    NSString type of tag(provided by server for all tag) that was searched by the user
 *
 *  @return return NSString for the first part of the msg that is displayed when user performs tag search
 */
-(NSString *)getFirstMessageOnLoaderScreenForTagType:(NSString *)tagType;

/**
 *  method to get first of message that is displared on leaser view when user performs a tag search and no profile is found.
 *
 *  @param tagType    NSString type of tag(provided by server for all tag) that was searched by the user
 *
 *  @return return NSString for the first part of the msg that is displayed when user performs tag search
 */
-(NSString *)getNoMorePeopleTextForTagType:(NSString *)tagType;


/**
 *  method to delete a matched user profile from recommendation, visitor, crush and answer if required. Basically that user should be delete from the app except for match screen. (Namo nisan uda d0)
 *
 *  @param userId  NSString type woo id of matched user.
 */
//-(void)deleteMatchUserFromAppExceptMatchBox:(NSString *)userId shouldDeleteFromAnswer:(BOOL)isdelete;
//-(void)deleteMatchUserFromAppExceptMatchBoxWithoutReload:(NSString *)userId shouldDeleteFromAnswer:(BOOL)isdelete;
-(void)deleteMatchUserFromAppExceptMatchBox:(NSString *)userId shouldDeleteFromAnswer:(BOOL)isdelete withCompletionHandler:(DeletionCompletionHandler __nullable)completionHandler;

-(void)deleteMatchUserFromAppExceptMatchBoxWithoutReload:(NSString *)userId shouldDeleteFromAnswer:(BOOL)isdelete withCompletionHandler:(DeletionCompletionHandler __nullable)completionHandler;
/*!
 * @discussion Method to detect faces in in given image
 * @param image UIImage provided
 * @return if face detected
 */
-(BOOL)detectFacesInImage:(UIImage*)image;

/**
 *  This method will check if the phone is jailbroken or not
 
 *
 *  @return yes or no if the phone is jailbroken
 */
-(BOOL)isJailbroken;

/**
 *  method to get string value for the selected gender on the intent screen
 *
 * @param genderPreference selected gender preference value from enum
 *
 * return NSString value for the gender type (MALE, FEMALE, BOTH)
 */

-(NSString *)getGenderStringForGenderType:(SelectedGenderPreference)genderPreference;

/**
 *  method to get string for the selected intent type
 *
 *  @param intentType selected intent type value from enum
 *
 *  @return NSString value for the intent type (FRIENDS,LOVE,CASUAL)
 */
-(NSString *)getIntentTypeStringForSelectedIntent:(IntentType)intentType;

/**
 *  Method to get the enum value for the selected gender value for the genderString
 *
 *  @param genderString string value, it can be male, female or both
 *
 *  @return value of type SelectedGenderPreference(ENUM) for the genderString it can one of the value from the enum
 */
-(SelectedGenderPreference)getGenderPreference:(NSString *)genderString;

/**
 *  Method to get the enum value for the selected intent value for the favIntentString
 *
 *  @param favIntentString string value, it can be love, casual or friend
 *
 *  @return value of type IntentType(ENUM) for the favIntentString it can one of the value from the enum
 */
-(IntentType)getIntentType:(NSString *)favIntentString;

/**
 *  method to get UIColor color value for a hex color value
 *
 *  @param hexStr hex string that needs to be converted into color
 *  @param alpha  alpha of the color
 *
 *  @return UIColor value that is obtained for the hex value and alpha value
 */
- (UIColor *)getUIColorObjectFromHexString:(NSString *)hexStr alpha:(CGFloat)alpha;

-(void)deleteAccount_Temp:(LayerDeAuthenticationSuccessHandler _Nullable )layerDeAuthSuccessBlock;

- (void)sendFirebaseEventWithScreenName:(NSString *_Nullable)screenName withEventName:(NSString *_Nullable)eventName;
- (void)sendPurchasedFirebaseEventwithEventName:(NSString *_Nullable)eventName andPurchaseData:(NSDictionary *)purchaseDict;
- (void)sendSwrveEventWithScreenName:(NSString *_Nullable)screenName withEventName:(NSString *_Nullable)eventName;
- (void)sendMixPanelEventWithName:(NSString *_Nullable)eventName;

/**
 * Method to add Snack Bar
 *
 *
 *
 */
- (void)addingNoInternetSnackBarWithText:(NSString *)text withActionTitle:(NSString *)actionTitle withDuration:(double)duration;

/**
 * Method to load discover section
 *
 *
 *
 */

- (void) sendToDiscover;


/**
 *  method to get Feet & inches in String
 *
 *  @param it will take some value for which it has to convert into feet & inches
 *
 *  @return feet & inches with the format as (2'11") in String format
 */
- (NSString*)getfeetAndInches:(float)centimeter;


/**
 *  method to get centimeter in String
 *
 *  @param it will take Feet inches value with the format as 2'11"
 *
 *  @return centimeter in NSString
 */

- (NSString *)getCentimeterFromFeetInches:(NSString *)theMeasure;

- (void)deAuthenticateLayerAndResetDatabase;

-(BOOL)showUnreadViewOnMeSection;

-(void)sendFCMPushTokenToServer;

-(NSInteger)getBadgeCountforMeSection;
-(NSInteger)getTotalBadgeCount;

- (void)showInviteActivityOnViewController:(UIViewController *)viewController;

- (UIImage *)getImageFromView:(UIView *)view;

-(NSDate *)dateAfterSubtractingDaysInCurrentDate:(int)numberOfDays;

- (NSString *)substringToIndex:(int)indexValue withString:(NSString *)strValue;

-(BOOL )shouldWeShowRatingPopup;

-(NSString *)getDeviceLanguageString;

-(NSString *)getDeviceLocaleCode;

- (UIButton *)addingShadowOnButton:(UIButton *)btn;

-(BOOL)isViewControllerPresented:(id )controller;

- (BOOL)stringContainsEmoji:(NSString *)string;

-(void)precacheCarouselDataWithData:(NSArray *)carouselArray circleImage:(NSString *)circle  backgroundImage:(NSArray *)bgImageArray andBaseURL:(NSString *)baseURL;

-(void)precacheDiscoverImagesWithData:(NSArray *)discoverArray;

-(void)precacheImagesWithData:(NSArray *)imageArray withCompletionHandler:(ImageCompletionHandler __nullable)completionHandler;

- (void)downloadMatchImageForImageUrl:(NSURL *)imageUrl;

-(BOOL)isChatRoomPresentInNavigationController:(UINavigationController *)navController;

-(NSString *)getCurrentlyActiveChatRoomId;

-(NewChatViewController *)getCurrentlyActiveChatRoomObj:(UINavigationController *)navController;


/**
 *  method to check if given string start with vowel of not (it will check for a, e, i, o, u)
 *
 *  @param stringToBechecked string that needs to be checked
 *
 *  @return true or false, true if first char is vowel otherwise false
 */

-(BOOL)checkIfStringStartsWithVowelOfNot:(NSString *)stringToBeChecked;
//-(void)test;
- (void)deleteImagesFromCacheForProfile:(NSArray *)profileCardImages;

-(BOOL)checkIfNeedToShowLoaderInMatchbox;

-(UIView *)blurView:(UIView *)view;

-(void)showVoiceCallIntroductionPopup;

-(int)checkMicrophonePermission;

- (CGFloat)getSafeAreaForTop:(BOOL)top andBottom:(BOOL)bottom;

- (NSDictionary *)getOnboardingPageNumberAndTotalNumberOfPages;

- (void)increaseOnBoardingPageNumber;

- (void)decreaseOnBoardingPageNumber;

-(void)logPurchaseEventOnFacebook:(NSString*)currency withParameters:(NSDictionary*)parameters withPurchaseAmount:(double)purchaseAmount;

- (NSString *)getMonthStringFromIntegerValue:(NSInteger)monthInInteger;

@end

