//
//  NewChatMessages.m
//  Woo
//
//  Created by Umesh Mishra on 07/08/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "NewChatMessages.h"


@implementation NewChatMessages

@dynamic chatMessageCreatedTime;
@dynamic chatRoomID;
@dynamic clientMessageID;
@dynamic isDelivered;
@dynamic message;
@dynamic messageReceiverID;
@dynamic messageSenderID;
@dynamic messageType;
@dynamic serverMessageID;
@dynamic chatID;

//
//
//
//+(void)insertMessageIntoDatabase:(NSDictionary *)chatDetails{
//    
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsUserBlacklisted]) {
//        return;
//    }
//    
//    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
//    
//    __block NSError *error = nil;
//    
//        NSDate *dateObj = [NSDate date];
//        
//        NSTimeInterval currentDate = [dateObj timeIntervalSince1970]*1000;
//        
//        if (chatDetails) {
//            
//            ChatMessage *chatMessageObj = [self getChatMessageWithServerMessageID:[NSNumber numberWithLongLong:[[chatDetails valueForKey:kServerMessageID] longLongValue]] andClientID:[NSNumber numberWithLongLong:[[chatDetails valueForKey:kChatMessageIDKey] longLongValue]] andMessageSenderID:[NSString stringWithFormat:@"%@",[chatDetails valueForKey:kMessageSenderIDKey]] andMessageReceiverID:[NSString stringWithFormat:@"%@",[chatDetails valueForKey:kMessageReceiverID]]];
//            
//            if (!chatMessageObj) {
//                chatMessageObj = (ChatMessage *)[NSEntityDescription insertNewObjectForEntityForName:@"ChatMessage" inManagedObjectContext:privateManagedObjectContext ];
//            }
//            
//            
//            if ([chatDetails objectForKey:kChatMessageIDKey]) {
//                [chatMessageObj setClientMessageID:[NSNumber numberWithLongLong:[[chatDetails objectForKey:kChatMessageIDKey] longLongValue]]];
//            }
//            else{
//                [chatMessageObj setClientMessageID:[NSNumber numberWithLongLong:currentDate]];
//            }
//            [chatMessageObj setChatRoomID:[NSString stringWithFormat:@"%@",[chatDetails objectForKey:kChatRoomIDKey]]];
//            [chatMessageObj setMessageType:[NSNumber numberWithInt:[[chatDetails objectForKey:kMessageTypeKey] intValue]]];
//            [chatMessageObj setMessage:[chatDetails objectForKey:kMessageKey]];
//            [chatMessageObj setIsDelivered:[NSNumber numberWithBool:[[chatDetails objectForKey:kIsDeliveredKey] boolValue]]];
//            [chatMessageObj setMessageSenderID:[NSString stringWithFormat:@"%@",[chatDetails objectForKey:kMessageSenderIDKey]]];
//            [chatMessageObj setServerMessageID:[NSNumber numberWithLongLong:[[chatDetails objectForKey:kServerMessageID] longLongValue]]];
//            [chatMessageObj setMessageReceiverID:[NSString stringWithFormat:@"%@",[chatDetails objectForKey:kMessageReceiverID]]];
//            
//            if ([chatDetails objectForKey:kChatMessageCreatedTime]) {
//                if ([[chatDetails objectForKey:kChatMessageCreatedTime] longLongValue]>[[NSDate date] timeIntervalSince1970]) {
//                    [chatMessageObj setChatMessageCreatedTime:[NSNumber numberWithLongLong:currentDate]];
//                }
//                else{
//                    [chatMessageObj setChatMessageCreatedTime:[NSNumber numberWithLongLong:[[chatDetails objectForKey:kChatMessageCreatedTime] longLongValue]]];
//                }
//                
//            }
//            else{
//                [chatMessageObj setChatMessageCreatedTime:[NSNumber numberWithLongLong:currentDate]];
//            }
//            
//            [privateManagedObjectContext performBlock:^{
//                
//                if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
//                    // Replace this implementation with code to handle the error appropriately.
//                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//                    //abort();
//                }
//                else{
//                    // Saving data on parent context and then informing back
//                    [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
//                        
//                        [self updateCrationTimeOfIntroMessageForChatRoom:[chatDetails objectForKey:kChatRoomIDKey]];
//                        
//                    }];
//                    
//                }
//                
//            }];
//        }
//        
//    
//}
//
//
//+(void)insertMessagesIntoDatabase:(NSArray *)chatDetailArray{
//    
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsUserBlacklisted]) {
//        return;
//    }
//    
//    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
//    
//    __block NSError *error = nil;
//    
//        [privateManagedObjectContext performBlock:^{
//            
//            if (chatDetailArray && [chatDetailArray count]>0) {
//
//                for (NSDictionary *chatDetails in chatDetailArray) {
//                
//                    if (chatDetails && [chatDetails objectForKey:kChatMessageIDKey] && [[chatDetails objectForKey:kChatMessageIDKey] length]>0) {
//                    
//                        ChatMessage *chatMessageObj = [self getChatMessageWithServerMessageID:[NSNumber numberWithLongLong:[[chatDetails valueForKey:kServerMessageID] longLongValue]] andClientID:[NSNumber numberWithLongLong:[[chatDetails valueForKey:kChatMessageIDKey] longLongValue]] andMessageSenderID:[NSString stringWithFormat:@"%@",[chatDetails valueForKey:kMessageSenderIDKey]] andMessageReceiverID:[NSString stringWithFormat:@"%@",[chatDetails valueForKey:kMessageReceiverID]]];
//                        
//                        if (!chatMessageObj) {
//                            chatMessageObj = (ChatMessage *)[NSEntityDescription insertNewObjectForEntityForName:@"ChatMessage" inManagedObjectContext:privateManagedObjectContext ];
//                        }
//                        
//                        [chatMessageObj setClientMessageID:[NSNumber numberWithLongLong:[[chatDetails objectForKey:kChatMessageIDKey] longLongValue]]];
//                        [chatMessageObj setChatRoomID:[NSString stringWithFormat:@"%@",[chatDetails objectForKey:kChatRoomIDKey]]];
//                        
//                        [chatMessageObj setMessageType:[NSNumber numberWithInt:[[chatDetails objectForKey:kMessageTypeKey] intValue]]];
//                        [chatMessageObj setMessage:[chatDetails objectForKey:kMessageKey]];
//                        [chatMessageObj setIsDelivered:[NSNumber numberWithBool:[[chatDetails objectForKey:kIsDeliveredKey] boolValue]]];
//                        [chatMessageObj setMessageSenderID:[NSString stringWithFormat:@"%@",[chatDetails objectForKey:kMessageSenderIDKey]]];
//                        [chatMessageObj setServerMessageID:[NSNumber numberWithLongLong:[[chatDetails objectForKey:kServerMessageID] longLongValue]]];
//                        [chatMessageObj setMessageReceiverID:[NSString stringWithFormat:@"%@",[chatDetails objectForKey:kMessageReceiverID]]];
//                        
//                        NSDate *dateObj = [NSDate date];
//                        NSTimeInterval currentDate = [dateObj timeIntervalSince1970]*1000;
//                        
//                        if ([[chatDetails objectForKey:kChatMessageCreatedTime] longLongValue]>[[NSDate date] timeIntervalSince1970]) {
//                            [chatMessageObj setChatMessageCreatedTime:[NSNumber numberWithLongLong:currentDate]];
//                        }
//                        else{
//                            [chatMessageObj setChatMessageCreatedTime:[NSNumber numberWithLongLong:[[chatDetails objectForKey:kChatMessageCreatedTime] longLongValue]]];
//                        }
//                        
//                        [self updateCrationTimeOfIntroMessageForChatRoom:[NSString stringWithFormat:@"%@",[chatDetails objectForKey:kChatRoomIDKey]]];
//                        
//                        [MyMatches updateChatSnippetForChatRoomID:[NSString stringWithFormat:@"%@",[chatDetails objectForKey:kChatRoomIDKey]]];
//                    }
//                    
//                }
//                
//                
//                if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
//                    // Replace this implementation with code to handle the error appropriately.
//                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//                    //abort();
//                }
//                else{
//                    // Saving data on parent context and then informing back
//                    [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
//                        
//                    }];
//                    
//                }
//            }
//        }];
//    
//
//}
//
//
//+(void)deleteMessagesForChatRoom:(NSString *)chatRoomID{
//    
//    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
//    
//    __block NSError *error = nil;
//   
//    [privateManagedObjectContext performBlock:^{
//    
//        NSArray *chatMessageArray = [self getAllMessageForChatRoom:chatRoomID];
//        
//        if (chatMessageArray && [chatMessageArray count]>0) {
//           
//            for (ChatMessage *chatMessageObj in chatMessageArray) {
//            
//                if (chatMessageObj) {
//                    [privateManagedObjectContext deleteObject:chatMessageObj];
//                }
//                
//            }
//            
//            if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
//                // Replace this implementation with code to handle the error appropriately.
//                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//                //abort();
//            }
//            else{
//                // Saving data on parent context and then informing back
//                [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
//                    
//                    // Do Nothing
//                }];
//            }
//        }
//
//    }];
//}
//
//+(NSArray *)getAllMessage{
//    NSManagedObjectContext *managedObjectContext = [APP_DELEGATE.store childPrivateManagedObjectContext];
//    
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext];
//    
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    
//    [request setEntity:entityDescription];
//    NSError *error = nil;
//    
//    NSArray *chatMessageArray = [managedObjectContext executeFetchRequest:request error:&error];
//    if (chatMessageArray && [chatMessageArray count]>0) {
//        return chatMessageArray;
//    }
//    return nil;
//}
//+(NSArray *)getAllMessageForChatRoom:(NSString *)chatRoomID{
//    
//    NSManagedObjectContext *managedObjectContext = [APP_DELEGATE.store childPrivateManagedObjectContext];
//    
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext];
//    
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    
//    [request setEntity:entityDescription];
//    
//    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(chatRoomID==%@)", chatRoomID];
//    
//    [request setPredicate:predicateObj];
//    
//    NSSortDescriptor *serverTimeSorting = [[NSSortDescriptor alloc] initWithKey:@"chatMessageCreatedTime" ascending:YES];
//    [request setSortDescriptors:[NSArray arrayWithObject:serverTimeSorting]];
//    
//    NSError *error = nil;
//    
//    NSArray *chatMessageArray = [managedObjectContext executeFetchRequest:request error:&error];
//    if (chatMessageArray && [chatMessageArray count]>0) {
//        return chatMessageArray;
//    }
//    return nil;
//    
//}
//+(void)updateDeliveryStatusOfChatMessage:(NSString *)chatMessageID withDeliveryStatus:(BOOL)isDelivered andServerMessageID:(NSNumber *)serverMessageID withMsgDeliveryTime:(NSString *)msgServerCreatedTime{
//   
//    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
//    
//    __block NSError *error = nil;
//  
//    [privateManagedObjectContext performBlock:^{
//        
//        ChatMessage *chatMessageObj = [self getChatMessageWithChatMessageID:[NSNumber numberWithLongLong:[chatMessageID longLongValue]]];
//
//        if (chatMessageObj) {
//        
//            [chatMessageObj setIsDelivered:[NSNumber numberWithBool:isDelivered]];
//            
//            [chatMessageObj setServerMessageID:serverMessageID];
//            
//            NSDate *dateObj = [NSDate date];
//           
//            NSTimeInterval currentDate = [dateObj timeIntervalSince1970]*1000;
//            
//            if ([msgServerCreatedTime longLongValue]>[[NSDate date] timeIntervalSince1970]) {
//                [chatMessageObj setChatMessageCreatedTime:[NSNumber numberWithLongLong:currentDate]];
//            }
//            else{
//                [chatMessageObj setChatMessageCreatedTime:[NSNumber numberWithLongLong:[msgServerCreatedTime longLongValue]]];
//            }
//            
//            if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
//                // Replace this implementation with code to handle the error appropriately.
//                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//                //abort();
//            }
//            else{
//                // Saving data on parent context and then informing back
//                [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
//                    
//                    // Do Nothing
//                    
//                }];
//            }
//        }
//    }];
//}
//
//+(ChatMessage *)getChatMessageWithChatMessageID:(NSNumber *)chatMessageID{
//
//    NSManagedObjectContext *managedObjectContext = [APP_DELEGATE.store childPrivateManagedObjectContext];
//    
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext];
//    
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    
//    [request setEntity:entityDescription];
//    
//    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(clientMessageID==%@)", chatMessageID];
//    
//    [request setPredicate:predicateObj];
//    
//    NSError *error = nil;
//    
//    NSArray *chatMessageArray = [managedObjectContext executeFetchRequest:request error:&error];
//    
//    ChatMessage *chatMessageObj = nil;
//    if (chatMessageArray && [chatMessageArray count]>0) {
//        chatMessageObj = (ChatMessage *)[chatMessageArray objectAtIndex:0];
//    }
//    return chatMessageObj;
//}
//+(ChatMessage *)getChatMessageWithServerMessageID:(NSNumber *)serverMessageId andClientID:(NSNumber *)clientID andMessageSenderID:(NSString *)messageSenderID andMessageReceiverID:(NSString *)messageReceiverID{
//    
//    if ([serverMessageId longLongValue] <1) {
//        return nil;
//    }
//    
//    NSManagedObjectContext *managedObjectContext = [APP_DELEGATE.store childPrivateManagedObjectContext];
//    
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext];
//    
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    
//    [request setEntity:entityDescription];
//    
//    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"((serverMessageID==%@) AND (clientMessageID==%@) AND (messageSenderID==%@) AND (messageReceiverID==%@))", serverMessageId,clientID,messageSenderID,messageReceiverID];
//    
//    [request setPredicate:predicateObj];
//    
//    NSError *error = nil;
//    
//    NSArray *chatMessageArray = [managedObjectContext executeFetchRequest:request error:&error];
//    
//    ChatMessage *chatMessageObj = nil;
//    if (chatMessageArray && [chatMessageArray count]>0) {
//        chatMessageObj = (ChatMessage *)[chatMessageArray objectAtIndex:0];
//    }
//    return chatMessageObj;
//}
//
//+(NSNumber *)getLatestServerID{
//    
//    NSManagedObjectContext *managedObjectContext = [APP_DELEGATE.store childPrivateManagedObjectContext];
//    
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext];
//    
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    
//    [request setEntity:entityDescription];
//    
//    NSSortDescriptor *serverTimeSorting = [[NSSortDescriptor alloc] initWithKey:@"serverMessageID" ascending:NO];
//    [request setSortDescriptors:[NSArray arrayWithObject:serverTimeSorting]];
//    
//    NSPredicate *getUndeliveredMsg = [NSPredicate predicateWithFormat:@"(messageSenderID !=%@)",[[NSUserDefaults standardUserDefaults] valueForKey:kWooUserId]];
//    
//    [request setPredicate:getUndeliveredMsg];
//    
//    [request setFetchLimit:1];
//    
//    NSError *error = nil;
//    
//    NSArray *chatMessageArray = [managedObjectContext executeFetchRequest:request error:&error];
//    
//    if (chatMessageArray && [chatMessageArray count]>0) {
//        ChatMessage *chatMessageObj = (ChatMessage *)[chatMessageArray objectAtIndex:0];
//        return chatMessageObj.serverMessageID;
//    }
//    return nil;
//}
//
//+(NSArray *)getAllUndeliveredMessges{
//
//    NSManagedObjectContext *managedObjectContext = [APP_DELEGATE.store childPrivateManagedObjectContext];
//    
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext];
//    
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    
//    [request setEntity:entityDescription];
//    
//    NSPredicate *getUndeliveredMsg = [NSPredicate predicateWithFormat:@"((isDelivered==%@) AND (messageType !=%@) AND (messageSenderID ==%@))", [NSNumber numberWithBool:FALSE],[NSNumber numberWithInt:4],[[NSUserDefaults standardUserDefaults] valueForKey:kWooUserId]];
//    
//    [request setPredicate:getUndeliveredMsg];
//    
//    NSSortDescriptor *serverTimeSorting = [[NSSortDescriptor alloc] initWithKey:@"chatMessageCreatedTime" ascending:YES];
//    [request setSortDescriptors:[NSArray arrayWithObject:serverTimeSorting]];
//    
//    NSError *error = nil;
//    
//    NSArray *chatMessageArray = [managedObjectContext executeFetchRequest:request error:&error];
//    
//    if (chatMessageArray && [chatMessageArray count]>0) {
//        return chatMessageArray;
//    }
//    return nil;
//}
//
//+(NSArray *)getAllMessageForChatRoom:(NSString *)chatRoomID WithLimit:(NSInteger)chatLimit{
//    NSManagedObjectContext *managedObjectContext = [APP_DELEGATE.store childPrivateManagedObjectContext];
//    
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext];
//    
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    
//    [request setEntity:entityDescription];
//    
//    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(chatRoomID==%@)", chatRoomID];
//    
//    [request setPredicate:predicateObj];
//    NSError *error = nil;
//    
//    NSInteger count = [managedObjectContext countForFetchRequest:request /*the one you have above but without limit */ error:&error];
//    
//    NSUInteger size = chatLimit;
//
//    count -= size;
//    
//    [request setFetchOffset:count>0?count:0];
//    
//    [request setFetchLimit:size];
//    
//    NSArray *chatMessageArray = [managedObjectContext executeFetchRequest:request error:&error];
//    if (chatMessageArray && [chatMessageArray count]>0) {
//        return chatMessageArray;
//    }
//    return nil;
//}
//
//+(NSArray *)getAllMessageForChatRoom:(NSString *)chatRoomID WithIndex:(NSInteger)currentIndex{
//    NSManagedObjectContext *managedObjectContext = [APP_DELEGATE.store childPrivateManagedObjectContext];
//    
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext];
//    
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    
//    [request setEntity:entityDescription];
//    
//    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(chatRoomID==%@)", chatRoomID];
//    
//    [request setPredicate:predicateObj];
//    
//    NSSortDescriptor *clientTimeSorting = [[NSSortDescriptor alloc] initWithKey:@"chatMessageCreatedTime" ascending:NO];
//    [request setSortDescriptors:[NSArray arrayWithObject:clientTimeSorting]];
//    
//    [request setFetchLimit:20];
//    [request setFetchOffset:currentIndex*20];
//    
//    NSError *error = nil;
//    
//    NSArray *chatMessageArray = [managedObjectContext executeFetchRequest:request error:&error];
//    if (chatMessageArray && [chatMessageArray count]>0) {
//        return chatMessageArray;
//    }
//    return nil;
//}
//
//+(BOOL)isMoreDataAvailableForChatRoom:(NSString *)chatRoomID WithIndex:(NSInteger)currentIndex{
//    NSManagedObjectContext *managedObjectContext = [APP_DELEGATE.store childPrivateManagedObjectContext];
//    
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext];
//    
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    
//    [request setEntity:entityDescription];
//    
//    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(chatRoomID==%@)", chatRoomID];
//    
//    [request setPredicate:predicateObj];
//    
//    NSSortDescriptor *clientTimeSorting = [[NSSortDescriptor alloc] initWithKey:@"chatMessageCreatedTime" ascending:NO];
//    [request setSortDescriptors:[NSArray arrayWithObject:clientTimeSorting]];
//    
//    [request setFetchLimit:kNumberOfMessageToBeShownAtATime];
//    [request setFetchOffset:(currentIndex+1)*kNumberOfMessageToBeShownAtATime];
//    
//    NSError *error = nil;
//    
//    NSArray *chatMessageArray = [managedObjectContext executeFetchRequest:request error:&error];
//    if (chatMessageArray && [chatMessageArray count]>0) {
//        return TRUE;
//    }
//    return FALSE;
//}
//
//+(ChatMessage *)getLastMessageForChatRoom:(NSString *)chatRoomID{
//    
//    NSManagedObjectContext *managedObjectContext = [APP_DELEGATE.store childPrivateManagedObjectContext];
//    
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext];
//    
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    
//    [request setEntity:entityDescription];
//    
//    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(chatRoomID==%@)", chatRoomID];
//    
//    [request setPredicate:predicateObj];
//    
//    NSSortDescriptor *clientTimeSorting = [[NSSortDescriptor alloc] initWithKey:@"chatMessageCreatedTime" ascending:YES];
//    [request setSortDescriptors:[NSArray arrayWithObject:clientTimeSorting]];
//
//    NSError *error = nil;
//    
//    NSArray *chatMessageArray = [managedObjectContext executeFetchRequest:request error:&error];
//    if (chatMessageArray && [chatMessageArray count]>0) {
//        return [chatMessageArray lastObject];
//    }
//    return nil;
//}
//+(void)updateCrationTimeOfIntroMessageForChatRoom:(NSString *)chatRoomID{
//
//    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
//    
//    __block NSError *error = nil;
//    
//    [privateManagedObjectContext performBlock:^{
//        
//        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:privateManagedObjectContext];
//        
//        NSFetchRequest *request = [[NSFetchRequest alloc] init];
//        
//        [request setEntity:entityDescription];
//        
//        NSArray *messagesArray = [self getAllMessageForChatRoom:chatRoomID];
//        
//        NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"((chatRoomID==%@)AND(messageType==%@))", chatRoomID,[NSNumber numberWithInt:INTRODUCTION]];
//        
//        NSSortDescriptor *clientTimeSorting = [[NSSortDescriptor alloc] initWithKey:@"chatMessageCreatedTime" ascending:YES];
//        
//        messagesArray = [messagesArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:clientTimeSorting]];
//        
//        ChatMessage *chatMessageObj = [messagesArray objectAtIndex:0];
//        
//        [request setPredicate:predicateObj];
//        
//        NSArray *messageArray = [privateManagedObjectContext executeFetchRequest:request error:&error];
//        
//        if (messageArray && [messageArray count]>0) {
//
//            ChatMessage *introMessageObj = [messageArray objectAtIndex:0];
//            
//            if ([introMessageObj.messageType intValue]!=[chatMessageObj.messageType intValue]) {
//            
//                if ([chatMessageObj.chatMessageCreatedTime longLongValue]<[introMessageObj.chatMessageCreatedTime longLongValue]) {
//                
//                    [introMessageObj setChatMessageCreatedTime:[NSNumber numberWithLongLong:([chatMessageObj.chatMessageCreatedTime longLongValue]-2000)]];
//                    
//                    if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
//                        // Replace this implementation with code to handle the error appropriately.
//                        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//                        //abort();
//                    }
//                    else{
//                        // Saving data on parent context and then informing back
//                        [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
//                            
//                            // Do Nothing
//                            
//                        }];
//                    }
//                }
//            }
//        }
//    }];
//}
//
//+(long long)getTheMaximumCreatedTimeForAChatRoom:(NSString *)chatRoomID{
//    long long maximumTime = 0.0;
//    ChatMessage *chatMessageObj = [self getLastMessageForChatRoom:chatRoomID];
//    
//    maximumTime = [chatMessageObj.chatMessageCreatedTime longLongValue];
//    
//    return maximumTime;
//}
//
//+(NSArray *)getAllMessageForChatRoomAfterChat:(ChatMessage *)chatObj forChatRoom:(NSString *)chatRoomID{
//    NSManagedObjectContext *managedObjectContext = [APP_DELEGATE.store childPrivateManagedObjectContext];
//    
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext];
//    
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    
//    [request setEntity:entityDescription];
//    
//    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"((chatRoomID==%@) && (chatMessageCreatedTime >%@))", chatRoomID,chatObj.chatMessageCreatedTime];
//    
//    [request setPredicate:predicateObj];
//
//    NSError *error = nil;
//    
//    NSArray *chatMessageArray = [managedObjectContext executeFetchRequest:request error:&error];
//    if (chatMessageArray && [chatMessageArray count]>0) {
//        return chatMessageArray;
//    }
//    return nil;
//}
//
//
@end
