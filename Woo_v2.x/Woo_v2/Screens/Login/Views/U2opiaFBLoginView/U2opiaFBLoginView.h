//
//  U2opiaFBLoginView.h
//  Woo
//
//  Created by Umesh Mishra on 13/02/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

/**
 @author : Umesh Mishra
 
 Class to handle FBLogin flow using FBLoginView class.
 It will be used in LoginViewController class.
 It will show Login button if the user is not logged in or current session is no more valid.
 It contain the delegate methods of FBLoginView to handle all the login scenario and error that can appear.
 
 
 */

@class U2AlertView;

@interface U2opiaFBLoginView : UIView<FBLoginViewDelegate>{
    
    BOOL sendNotification;
    
    BOOL hasErrorOccuredAlready;
    
    UIButton *loginButtonObj;
    
    UIActivityIndicatorView *activityIndicatorViewObj;
    
    BOOL isAskingForExtendedPermissions;
    
    NSString *userFacebookId;
    NSString *userFacebookName;
    
    U2AlertView *showLoginALert;
    
}

+(U2opiaFBLoginView *) sharedU2opiaFBLoginView;

@property(nonatomic, assign)BOOL doesLoginFailed;
@property(nonatomic, assign)BOOL isPresentedForFBSync;

/**
 @author : Lokesh Sehgal
 Method to Perform Logout operation
 */
-(void)doLogoutOperation;

/**
 @author : Lokesh Sehgal
 Method to check Whether we are getting an OK from FB in response - if some error has occured then handle it
 */
-(void)fetchMeForCheckingWhetherTokenIsExpired:(void (^)(bool isValid))block ;

/**
 @author : Umesh Mishra
 Method to add FBLogin view.
 */
-(void)addLoginButton;
/**
 @author : Umesh Mishra
 Method to handle error that can appear while logging to facebook and show alert accordinglly.
 * This method can also be used to perform some action when an error occure.
 @param : error due to which login is failed, error is an object of class NSError
 */
-(void)handleAuthError:(NSError *)error;
/**
 @author : Umesh Mishra
 Method to get extra read permission from the user/facebook.
 It will check if session already have the asked permission, if not than it will get the new permission otherwise will not do anything.
 @param : readpermissions array.
 */
-(void)getReadPermissions:(NSArray *)readPermissions withBlock:(void (^)(bool isValid))block;
/**
 @author : Umesh Mishra
 Method to get publish permission from the user/facebook.
 It will check if session already have the asked permission, if not than it will get the new permission otherwise will not do anything.
 @param : publishPermissions array.
 */
-(void)getPublishPermissions:(NSArray *)publishPermissions withBlock:(void (^)(bool isValid))block;

/**
 @author : Umesh Mishra
 Method to print current state of session.
 This method is used get the state and should be deleted when of no use.
 */
-(void)printFbsession:(FBSession *)sessionObj;

-(void)getErrorCodeAndSubcodeForError:(NSError *)errorObj code:(int *)pcode
                              subcode:(int *)psubcode;

-(void)addActivityIndicator;
-(void)hideActivityIndicator;
-(UIButton *)getLoginButtonReference;
-(NSArray*)fetchReadPermissions;
-(NSArray*)fetchExtendedPermissions;
-(void)removeAllObserver;
-(void)loginWithoutShowingUI;
-(void)showAuthorizeFacebookPermissionAlert;

-(void)facebookPermissionALertTapped;

@end

