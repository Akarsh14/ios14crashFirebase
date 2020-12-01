//
//  NotificationManager.h
//  Woo_v2
//
//  Created by Deepak Gupta on 4/13/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Store.h"
#import "LayerManager.h"
#import "U2AlertView.h"

@interface NotificationManager : NSObject{
    U2AlertView *pushAlertView;
    Store *store;
    
}

@property (assign) BOOL shouldShowTopNotification;
@property (nonatomic, retain) NSString *showTopNotioficationForMatchId;


/**
 *  Make a call to this method once Notification has been received.
 *  @param Notification name from where it is received whether it is from APNS or from DeepLinking ,  UIApplication Object , userInfo dictionary.
 */
- (void) openScreenForNotificationName : (NSString *)notifName  WithApplication : (UIApplication *)application withNotificationData : (NSDictionary *)userInfo;

@end
