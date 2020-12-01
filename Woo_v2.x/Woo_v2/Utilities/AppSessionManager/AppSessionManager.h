//
//  AppSessionManager.h
//  Woo_v2
//
//  Created by Suparno Bose on 03/12/15.
//  Copyright © 2015 Woo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppSessionManager : NSObject

@property BOOL isNotificationCallMade;

@property BOOL isCrushCallMade;

@property BOOL isVisitorCallMade;

@property NSString *refreshedToken;
/*!
 * @discussion This method return the shared instance of the AppSessionManager
 * @return AppSessionManager object
 */
+ (id)sharedManager;

/*!
 * @discussion This app performs the activities on fresh app launch
 */
- (void)launchedFreshApp;

/*!
 * @discussion This method makes the app launch call to the server
 */
- (void)makeAppLaunchCallToServer;

/*!
 * @discussion This method gets the Visitor List from the server
 */
- (void)getVisitorFromServer;

/*!
 * @discussion This method gets the Crush List from the server
 */
- (void)getCrushFromServer;


- (void)makeAppLaunchCallToWhenConnectionResumes;


-(void)removeObserverForInternetChange;

- (void)getPurchaseProductDetailFromServer;

//- (void)getCookieFromRefferalUrl;

@end
