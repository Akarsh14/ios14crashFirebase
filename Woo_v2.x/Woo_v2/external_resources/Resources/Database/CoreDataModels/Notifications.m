//
//  Notifications.m
//  Woo
//
//  Created by Vaibhav Gautam on 11/04/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "Notifications.h"


@implementation Notifications

@dynamic additionData;
@dynamic isRead;
@dynamic notificationDate;
@dynamic notificationId;
@dynamic notificationImage;
@dynamic notificationText;
@dynamic notificationType;
@dynamic pivotId;



/*



+(NSMutableArray *)getAllNotificationsFromLocalDB{
    
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [STORE newPrivateContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Notifications" inManagedObjectContext:managedObjectContext];
    // code for sorting starts here
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setFetchBatchSize:20];
    
    
//    -----------added by vaibhav for making sure matches are not visible to user ------
    NSPredicate *wherePredicate = [NSPredicate predicateWithFormat:@"notificationType <> 2"];
    [request setPredicate:wherePredicate];
//    --------------------
    
    NSSortDescriptor *dateSortingDescriptior = [[NSSortDescriptor alloc]initWithKey:@"notificationDate" ascending:NO];
    
    
    NSArray *sortDescriptorArray = [NSArray arrayWithObjects:dateSortingDescriptior, nil];
    [request setSortDescriptors:sortDescriptorArray];
    // code for sorting ends here
    NSArray *notificationsArray = [managedObjectContext executeFetchRequest:request error:&error];
    return (NSMutableArray*) ([notificationsArray count]>0 ? notificationsArray : nil );
}


+(int)numberOfUnreadNotificationsInPanel{
    int unreadNotification = 0;
    
    NSMutableArray *notificationsArray = [Notifications getAllNotificationsFromLocalDB];
    
    for (Notifications *notificationData in notificationsArray) {
        if ([notificationData.isRead boolValue]!= true) {
            unreadNotification++;
        }
    }
    return unreadNotification;
}

+(Notifications *)getNotificationForNotificationID:(NSString *)notificationID{
    NSManagedObjectContext *managedObjectContext = [STORE newPrivateContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Notifications" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(notificationId==%@)", notificationID];
    
    [request setPredicate:predicateObj];
    
    NSError *error = nil;
    
    NSArray *notificationsArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    
    Notifications *notificationsObject = nil;
    if (notificationsArray && [notificationsArray count]>0) {
        notificationsObject = (Notifications *)[notificationsArray objectAtIndex:0];
    }
    return notificationsObject;
}

+(Notifications *)getNotificationForPivotID:(NSString *)pivotID{
    
    NSManagedObjectContext *managedObjectContext = [STORE newPrivateContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Notifications" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(pivotId==%@)", pivotID];
    
    [request setPredicate:predicateObj];
    
    NSError *error = nil;
    
    NSArray *notificationsArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    
    Notifications *notificationsObject = nil;
    if (notificationsArray && [notificationsArray count]>0) {
        notificationsObject = (Notifications *)[notificationsArray objectAtIndex:0];
    }
    return notificationsObject;
}

+(void)removeNotificationForNotificationId:(int)notifId{
    
    NSManagedObjectContext *managedObjectContext = [STORE newPrivateContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Notifications" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(notificationId==%@)",[NSString stringWithFormat:@"%d",notifId]];
    
    [request setPredicate:predicateObj];
    
    NSError *error = nil;
    
    NSArray *matchedUserArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    for (int indexX = 0; indexX < [matchedUserArray count]; indexX++) {
        Notifications *notifObj = [matchedUserArray objectAtIndex:indexX];
        [managedObjectContext deleteObject:notifObj];
    }
    
    [STORE savePrivateContext];
    
    [STORE saveContext];
}

+(void)removeNotificationFopPivotId:(NSString *)pivotId{
    
    NSManagedObjectContext *managedObjectContext = [STORE newPrivateContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Notifications" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(pivotId==%@)",[NSString stringWithFormat:@"%@",pivotId]];
    
    [request setPredicate:predicateObj];
    
    NSError *error = nil;
    
    NSArray *matchedUserArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    for (int indexX = 0; indexX < [matchedUserArray count]; indexX++) {
        Notifications *notifObj = [matchedUserArray objectAtIndex:indexX];
        [managedObjectContext deleteObject:notifObj];
    }
    
    [STORE savePrivateContext];
    
    [STORE saveContext];
    
}


+(void)saveNotificationsLocallyFromData:(NSMutableArray *)notificationArray{
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsUserBlacklisted]) {
        return;
    }
    
    NSManagedObjectContext *privateContext = [STORE newPrivateContext];
    
    NSMutableArray *myMatchedUserArray = [[NSMutableArray alloc] init];
    
    if ([notificationArray count] > 0) {
        
        for (NSMutableDictionary *notificationDictionary in notificationArray) {
            
//            if ([[notificationDictionary objectForKey:@"type"] isEqualToString:@"ITS_A_MATCH"]) {
////                continue;
//            }
            
            Notifications *notificationObj = [Notifications getNotificationForNotificationID:[notificationDictionary objectForKey:@"id"]];
            
            if(!notificationObj){
                
                notificationObj = (Notifications *)[NSEntityDescription insertNewObjectForEntityForName:@"Notifications" inManagedObjectContext:privateContext];
            }
            [notificationObj setNotificationId:[NSString stringWithFormat:@"%d",[[notificationDictionary objectForKey:@"id"] intValue]]];
            
            [notificationObj setNotificationImage:[notificationDictionary objectForKey:@"picture"]];
            
            [notificationObj setNotificationType:[NSNumber numberWithInt:[APP_Utilities getNotificationTypeFor:[notificationDictionary objectForKey:@"type"]]]];
            
            [notificationObj setNotificationDate:[APP_Utilities returnDateFromTimeStamp:[[notificationDictionary objectForKey:@"createdTime"] longLongValue]]];
            
            [notificationObj setNotificationText:[APP_Utilities validString:[notificationDictionary objectForKey:@"title"]]];
            
            if([[notificationDictionary objectForKey:@"notificationStatus"] isEqualToString:@"UNREAD"]){
                [notificationObj setIsRead:[NSNumber numberWithBool:NO]];
            }else{
                [notificationObj setIsRead:[NSNumber numberWithBool:YES]];
            }
            
            
            NSDictionary *objectObj = (NSDictionary *)[notificationDictionary objectForKey:[APP_Utilities getAddidtionalDataKeyForNotificationType:[APP_Utilities getNotificationTypeFor:[notificationDictionary objectForKey:@"type"]]]];
            
            
            //add my matches data here ---- Umesh
            
//            if ((([APP_Utilities getNotificationTypeFor:[notificationDictionary objectForKey:@"type"]] == introduceMe) || ([APP_Utilities getNotificationTypeFor:[notificationDictionary objectForKey:@"type"]] == introduced)) && ([notificationDictionary objectForKey:@"type"])) {
//                
//                NSString *targetId = ([[[notificationDictionary objectForKey:@"recommendationData"] objectForKey:@"recommendationId"] isKindOfClass:[NSString class]]?[[notificationDictionary objectForKey:@"recommendationData"] objectForKey:@"recommendationId"]:[NSString stringWithFormat:@"%@",[[notificationDictionary objectForKey:@"recommendationData"] objectForKey:@"recommendationId"]]);
//                
//                [notificationObj setPivotId:targetId];
//                
//            }
//            else if (([APP_Utilities getNotificationTypeFor:[notificationDictionary objectForKey:@"type"]] == iAmMatched)){
//                
//                NSString *matchId = ([[[notificationDictionary objectForKey:@"matchEventDto"] objectForKey:@"matchId"] isKindOfClass:[NSString class]]?[[notificationDictionary objectForKey:@"matchEventDto"] objectForKey:@"matchId"]:[NSString stringWithFormat:@"%@",[[notificationDictionary objectForKey:@"matchEventDto"] objectForKey:@"matchId"]]);
//                
//                [notificationObj setPivotId:matchId];
//                [myMatchedUserArray addObject:objectObj];
//            }
//            
//            else if (([APP_Utilities getNotificationTypeFor:[notificationDictionary objectForKey:@"type"]] == iAmMatched) && objectObj) {
//                
//                [myMatchedUserArray addObject:objectObj];
//                
//            }
            
            [notificationObj setAdditionData:objectObj];
        }
        //        check and add my matched user data into db
        if ([myMatchedUserArray count]>0) {
            [MyMatches insertDataInMyMatchesFromArray:myMatchedUserArray withChatInsertionSuccess:^(BOOL insertionSuccess) {
                
            }];
        }
        
    }
}

+(void)deleteAllNotification{
    NSManagedObjectContext *managedObj = [STORE newPrivateContext];
    NSArray *notificationArray = [self getAllNotificationsFromLocalDB];
    if (notificationArray && [notificationArray count]>0) {
        for (Notifications *notificationObj in notificationArray) {
            [managedObj deleteObject:notificationObj];
        }
    }
    [STORE savePrivateContext];
    [STORE saveContext];
}
*/
@end
