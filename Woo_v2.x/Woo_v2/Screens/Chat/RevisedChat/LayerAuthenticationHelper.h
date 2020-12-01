////
////  LayerAuthenticationHelper.h
////  Woo_v2
////
////  Created by Umesh Mishraji on 20/04/16.
////  Copyright © 2016 Vaibhav Gautam. All rights reserved.
////
//
//#import <UIKit/UIKit.h>
////#import <LayerKit/LayerKit.h>
//
//typedef void (^LayerAuthSuccess) (BOOL authenticationSuccess, LYRClient *layerClient);
//typedef void (^LayerDeAuthSuccess)(BOOL deAuhtenticationSuccess);
//
//@interface LayerAuthenticationHelper : UIViewController{
//    LYRClient *layerClient;
//    
//}
//
//+(LayerAuthenticationHelper *)sharedLayerAuthenticationHelper;
//
//
///**
// method to authenticate and connect to layer. If authenticated from different user. If will deauthenticate and authenticate with new user id.
//
// @param userID userId : in this case Wooid of user.
// @param layerClientObj layerCleintObj created by LayerManager. isConnected status of layerCleint obj is false
// @param completion block to pass control to calling class that return values(TRUE, nil) if authentication is successful otherwise returns(FALSE, ErrorObj) if fails
// */
//-(void)authenticateLayerWithUserID:(NSString *)userID layerClient:(LYRClient *)layerClientObj completion:(void (^)(BOOL success, NSError * error))completion;
//
//
///**
// Method that request token from layer server and when received provide it to Woo server.
//
// @param userID WooId
// @param completion block to pass the control back to calling method or class that return values(TRUE, nil) if authentication is successful otherwise returns(FALSE, ErrorObj) if fails
// */
//- (void)authenticationTokenWithUserId:(NSString *)userID completion:(void (^)(BOOL success, NSError* error))completion;
//
//
///**
// method to reAuthenticate layer client object and create conenction with layer, if authentication faces any error from layer.
//
// @param nonce nonce provided by Layer
// @param completion completion block that return values(TRUE, nil) if reauthentication is successful otherwise returns(FALSE, ErrorObj) if fails
// */
//-(void)reauthenticateUserWithNonceToken:(NSString *)nonce completion:(void (^)(BOOL success, NSError * error))completion;
//
//
///**
// Method to De-Authenticate user from layer. this method is called when user logs out from the app.
//
// @param layerDeAuthSuccessBlock completion. To pass control to calling method/class with value(TRUE/FALSE) depending upon whether deauthrisation was successful.
// */
//-(void)deAuthenticateUserOnLayer:(LayerDeAuthSuccess)layerDeAuthSuccessBlock;
//
//@end
