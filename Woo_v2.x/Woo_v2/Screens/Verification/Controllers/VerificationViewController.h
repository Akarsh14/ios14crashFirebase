//
//  VerificationViewController.h
//  Woo
//
//  Created by Vaibhav Gautam on 11/02/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

/**
 @author : Umesh Mishra
 
 This class will verify if logged in user is fake or not.
 It will also send location and device token to server. 
 
 */

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ErrorPopUpView.h"
@class VerificationView;

@interface VerificationViewController : BaseViewController<CLLocationManagerDelegate>{
    NSTimer *timerObj;
    CLLocationManager *locationManager;
    BOOL isLocationCallMade;
    VerificationState currentVerificationState;
    VerificationView *verificationViewObj;
    float progressedValue;
    UserVerificationState userVerificationState;
    BOOL isSendToConfirmScreenCallMade;
    BOOL isNoInternetShownWhenProgressWasStillInProgress;
    //Added by Umesh on 02 Septemeber to show new text on fake screen.
    NSString *fakeHeaderString, *fakeTextString;
    VerificationErrorType verificationError;
    ErrorPopUpView *errorPopUpViewObj;
    
    BOOL pauseProgressOfView;
    
    BOOL testBool;
    BOOL isFakeResponseRecievedFromServer;
    BOOL isUserDetailRecievedFromServer;
    BOOL moveToLoginScreenAutomaticallyIfUserIsFake;
}
/**
 @author : Lokesh Sehgal
 Response of Login
 
 */
@property (retain,nonatomic) id responseObj;

/**
 @author : Lokesh Sehgal
 Response of Fake
 
*/
@property(nonatomic, strong)NSMutableArray *userImages;


/**
  @author : Umesh Mishra
 Method to update the progress bar value.
 @param progressValue new value of the progress bar
 */
-(void)updateProgressBarValue:(float)progressValue;
/**
 @author : Lokesh Sehgal
 Method to push user to confirm profile screen
*/

-(void)pushToConfirmProfileScreen;

/**
  @author : Umesh Mishra
 Method to get the last verification state, state where the user left if the verification was not complete
 */
-(void)getVerificationState;
/**
  @author : Umesh Mishra
 Method to update the verification state.
 @param currentVerificationStateVal of VerificationState() type, new state that will be stored
 */
-(void)updateVerificationState:(VerificationState)currentVerificationStateVal;
/**
 @author : Umesh Mishra
 Method to get user current location of the user 
 */
-(void)getUserCurrentLocation;
/**
  @author : Umesh Mishra
 Method to send user current location to server
 */
-(void)makeLocationCallToServer:(CLLocation *)location;
/**
  @author : Umesh Mishra
 Method to send deviceToken to server
 */
-(void)makePushNotificationCallToServer;
/**
  @author : Umesh Mishra
 method to save fake user flag. If user is not valid or fake, save a bool value
 @param userID : wooID of registered user
 @param isValid of type Bool, TRUE : if user is valid FALSE : if user is fake
 */
-(void)saveFakeUserFlag:(NSString *)userID isUserValid:(UserVerificationState)userState;

/**
 @author : Umesh Mishra
 method to get user's last verification state if no state is available return UnverifiedUser state
 @param userID : wooID of registered user
 @return UserVerificationState
 */
-(UserVerificationState )getUserVerificationStateForUser:(NSString *)userID;
/**
  @author : Umesh Mishra
 Method to check if user is fake.
 @param userID of logged in user
 @return Return True if user fake else False
  */
-(BOOL)isUserFake:(NSString *)userID withGender:(NSString *)genderVal andDob:(NSString *)dobVal;


/**
 @author : Umesh Mishra
Method to show message and progress based on current verificationstate.
 It will send user to ConfirmProfile view if current state is LocationCallDoneState
 */

-(void)showViewAccordingToCurrentVarificationState;

/**
 @author  :Umesh Mishra
 Method to create time to automatically update the progress bar, till the given maximum value. This method will invalidate previous timer,if any, and create a new one.
 @param maxProgressValue of type flaot maximum progress value of progressBar.
 */

-(void)startAutoupdateTimeWithMaxProgressValue:(float)maxProgressValue;

-(void)changeImageAndTextOnScreenForProgressState:(NSInteger)progressState;

-(void)downloadProfileImagesInbackground:(NSArray *)imageArray;

-(void)invalidateAutoUpdateTimer;

/**
 @author : Umesh Mishra
 @date : 02 September, 2014
 Method to show differnet message to fake user with the reason why the user is fake. The header and message is provided by server. if no header and message is provided by server then show the default message.
 It will user two gloabal value fakeHeaderString, fakeTextString. 
 */
-(void)setFakeScreenText;

///**
// *  Method to set the verification Error type from the fake call response
// *
// *  @param responseDict Response from fake call response.
// */
//-(void)getErrorCodeForVerification:(NSDictionary *)responseDict;

/**
 *  @author : Umesh Mishra  
    Method to show Gender and Date of birht pop up if needed. If gender is missing only gender pop will be visible, if dob is missing only dob pop will appear if both are missing than a view with view for both will be visible. Nothing will happen if no gender and dob error is present. 
 */
-(void)showAgeAndGenderPopupIfNeededAndPauseProgressView;

/**
 *  Method to show alert giving user to select his/her gender;
 */
-(void)showSelectGenderAlert;

-(void)showSelectDOBAlert;

-(void)showSelectGenderAndDOBAlert;

-(void)initialiseErrorPopView;

-(void)popToLoginViewControllerWithAnimation;




@end
