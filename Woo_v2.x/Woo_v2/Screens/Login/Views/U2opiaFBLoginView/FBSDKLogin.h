//
//  FBSDKLogin.h
//  Woo_v2
//
//  Created by Deepak Gupta on 5/16/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

typedef void (^FBSDKLoginBlock)(NSString *accessToken , NSError *err , BOOL missingPermission);
typedef void (^FbLoginButtonClicked)(_Bool isButtonTapped);
@interface FBSDKLogin : UIView{
    FBSDKLoginBlock _block;
}
+(FBSDKLogin *) sharedManagerFBSDKLogin;
- (void)fbLoginButtonClicked:(FbLoginButtonClicked)block;

/**
 @author : Deepak Gupta
 
 @desc : This method is used to logout from the facebook.
 
 @param :
 */
- (void)logOutUserFromFacebook;

/**
 @author : Deepak Gupta
 
 @desc : This method is used to show the facebook login button
 
 @param : Takes title of the facebook button
 */
- (void)showLoginButtonWithTitle : (NSString *)title;

-(void)loginButtonClicked;

- (void)setCompletionBlock : (FBSDKLoginBlock) block;

- (void)showLoader;

- (void)hideLoader;

-(void)removeAllObserver;


-(BOOL)checkIfPermissionMissing;

-(void)getLoginPermissionFromFacebook;

-(void)getReadPermissions:(NSArray *)readPermissions onParentViewController:(UIViewController *)parentViewController withBlock:(void (^)(bool isValid))block;

-(NSArray*)fetchReadPermissions;

@end
