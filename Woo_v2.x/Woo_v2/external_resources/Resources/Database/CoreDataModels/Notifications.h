//
//  Notifications.h
//  Woo
//
//  Created by Vaibhav Gautam on 11/04/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Notifications : NSManagedObject

@property (nonatomic, retain) id additionData;
@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSDate * notificationDate;
@property (nonatomic, retain) NSString * notificationId;
@property (nonatomic, retain) NSString * notificationImage;
@property (nonatomic, retain) NSString * notificationText;
@property (nonatomic, retain) NSNumber * notificationType;
@property (nonatomic, retain) NSString * pivotId;

/*
+(NSMutableArray *)getAllNotificationsFromLocalDB;
+(int)numberOfUnreadNotificationsInPanel;
+(Notifications *)getNotificationForNotificationID:(NSString *)notificationID;
+(Notifications *)getNotificationForPivotID:(NSString *)pivotID;
+(void)removeNotificationForNotificationId:(int)notifId;
+(void)removeNotificationFopPivotId:(NSString *)pivotId;
+(void)saveNotificationsLocallyFromData:(NSMutableArray *)notificationArray;
+(void)deleteAllNotification;
*/
@end
