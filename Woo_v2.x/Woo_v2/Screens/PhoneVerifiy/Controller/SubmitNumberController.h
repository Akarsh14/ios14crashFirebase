//
//  SubmitNumberController.h
//  Woo
//
//  Created by Umesh Mishra on 27/10/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityIndicatorWithTextAndTimer.h"
@class WooLoader;

@interface SubmitNumberController : UIViewController<UITextFieldDelegate>{
    
    __weak IBOutlet UILabel *headingMessageLabelObj;
    __weak IBOutlet UITextField *numberTextFieldObj;
    __weak IBOutlet UIImageView *flagImageViewObj;
    __weak IBOutlet UILabel *countryCodeLabelObj;
    __weak IBOutlet UIButton *submitButtonObj;
    __weak IBOutlet UILabel *warningMessageLabel;
    __weak IBOutlet UILabel *textFieldBackgroundLabalObj;
    __weak IBOutlet UIView *activityIndicatorBackgroundViewObj;
//    __weak IBOutlet UIActivityIndicatorView *activityIndicatorViewObj;
    __weak IBOutlet UIView *phoneLabelBackground;
//    ActivityIndicatorWithTextAndTimer *activityObj;
    int foneVerificationFlowValue;
    
    __weak IBOutlet UILabel *titleLbl;
    
    __weak IBOutlet UIView *wooLoaderContainerViewObj;
    
    WooLoader *customLoader;
    void (^PhoneVerificatonBlock)(BOOL isSuccess, NSString *phoneNumberVerified);
}

/**
 @author Umesh Mishra
 String property to store flag url of the country app is used in. Flag is visible in view.
 */
@property(nonatomic, retain)NSString *flagImageUrlString;
/**
 @author Umesh Mishra
 String property to store country code of the country app is used in. It is visible before the number text field.
 */
@property(nonatomic, retain)NSString *countryCode;
/**
 @author Umesh Mishra
 String property to store country code string of the country app is used in. It is used in fone verify call..
 */
@property(nonatomic, retain)NSString *countryCodeString;

/**
 @author Umesh Mishra
 @date : Feb 18, 2015
 String property to store phone number length that is allowed in country. It is used to validate the length of the phone number entered by user.
 */
@property(nonatomic, strong)NSString *phoneDigitCount;


/**
 @author Umesh Mishra
 Method to confirm the mobile number entered by the user. If number length is less than 10 it will show an error alert to enter correct mobile number. If the number lenght is valid it will show an alert to confirm the mobile number, user can either confirm it or can edit number. if user confrims the number it will make a call to fone verify server wil the entered number. 
 @param Button that is tapped. In this case it the submit button that is visible on the screen.
 */
-(IBAction)submitButtonTapped:(id)sender;

/**
 @author Umesh Mishra
 Method to initialise the view. Setting font,background color , text color of label and other element on the view.
 */
-(void)initialiseView;

/**
 @author Umesh Mishra
 This method will send a get call to the fone verify server with the number entered by the user. fone verify server will return a mobile number on which the user has to call to verifiy his/her number. The app will push to new view if the number is assined to the user otherwise an error will be shown to user.
 */
-(void)makeFoneVerifyCall;
/**
 @author Umesh Mishra
Method to push to call to confirm number VC.
 */
-(void)PushToAlmostThereScreenWithMobieNumber:(NSString *)mobileNumber countryCode:(NSString *)countryCode verificationId:(NSString *)verficationId withAssignedID:(NSString *)assignedId andAllowSmsVerification:(BOOL)isSmsVerificationAllowed withTimeOutTime:(NSNumber *)timeout;
/**
 @author Umesh Mishra
 Method to push to next view according to the setting flow that was returned by the server on method call 'getFoneVerfiyConfigurationFromServer'.
 */
-(void)pushtoNextViewWithMobieNumber:(NSString *)mobileNumber countryCode:(NSString *)countryCode verificationId:(NSString *)verficationId andWithAssignedID:(NSString *)assignedId withTimeOutTime:(NSNumber *)timeout;

/**
 @author Umesh Mishra
 Method to push to sms verification of mobile number on fone verify server VC.
 */
-(void)pushToSmsVerificationScreenWithMobileNumber:(NSString *)mobileNumber andCountryCode:(NSString *)countryCode withTimeOutTime:(NSNumber *)timeout;
/**
 @author Umesh Mishra
 Method to get fone verify flow's configuration from the fone verify server. It tell the client if the flow will contain call verification, sms verification or both. 
 
 */
-(void)getFoneVerfiyConfigurationFromServer;

/**
 @author Umesh Mishra
 Method to enable or disable submit button.
 @param isEnable of type BOOL that tell the method to enable/disable submit button
 */
-(void)enableSubmitButton:(BOOL)isEnable;
/**
 @author Umesh Mishra
 Method to enable or disable submit button and mobile number text field.
 @param isEnable of type BOOL that tell the method to enable/disable submit button
 */
-(void)enableNumberTextField:(BOOL)isEnable;

/**
 *  Method to perform action when back button is tapped
 *
 *  @param sender Button object that is tapped
 */
-(IBAction)backButtonTapped:(id)sender;

-(void)isPhoneVerifySuccess:(void(^)(BOOL isSuccess, NSString *phoneNumberVerified))verificationBlock;

@end
