//
//  AppLaunchApiClass.h
//  Woo_v2
//
//  Created by Akhil Singh on 27/04/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^getNotificationConfigurationAPICompletionBlock)(BOOL);

@interface AppLaunchApiClass : NSObject

+ (id)sharedManager;

+(void)initialiseSellingMessage;

/**
 *  AppSyncCall for getting app sync options like ProfileOptions,Tips and Crush templates
 *
 *  @param appConfigDict response of AppLaunch call
 *  @param block         to update the view when data arrives
 */
- (void)makeAppSyncCallForAppConfigOptions:(NSDictionary *)appConfigDict;

- (void)makeAppSyncCallForSidePanelTips;

- (void)getNotificationConfigOptionsWithCompletionBlock:(getNotificationConfigurationAPICompletionBlock _Nullable) block;

- (void)updateNotificationConfigOptions;

- (void)getWooQuestions:(long long int) wooQuestionUpdatedTime;

@end
