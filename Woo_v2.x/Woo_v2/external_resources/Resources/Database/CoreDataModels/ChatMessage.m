//
//  ChatMessage.m
//  Woo
//
//  Created by Umesh Mishra on 30/04/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "ChatMessage.h"
#import "ChatRoom.h"
#import "TopChatView.h"

@implementation ChatMessage

@dynamic clientMessageID;
@dynamic chatRoomID;
@dynamic messageType;
@dynamic message;
@dynamic isDelivered;
@dynamic messageSenderID;
@dynamic serverMessageID;
@dynamic messageReceiverID;
@dynamic chatMessageCreatedTime;
@dynamic chatDeliveryStatus;
@dynamic layerMessageID;
@dynamic ifchatImageIsItUploaded;
@dynamic imageSize;


+(void)insertNewChatMessageIntoDatabase:(NSDictionary *)chatDetails withCompletionHandler:(ChatInsertionCompletionHandler)completionHandler{
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsUserBlacklisted]) {
        completionHandler(nil);
    }
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block ChatMessage *chatMessageObj = nil;
    
    [privateManagedObjectContext performBlock:^{
        
        ChatMessage *introMessage = [self getIntroMessageForTheChatRoom:[NSString stringWithFormat:@"%@",[chatDetails objectForKey:kChatRoomIDKey]]];
        
        if (([[chatDetails objectForKey:kMessageTypeKey] intValue] != INTRODUCTION) && ([introMessage.chatMessageCreatedTime longLongValue] > [[chatDetails objectForKey:kChatMessageCreatedTime] longLongValue])) {
            
            completionHandler(nil);
        }
        
        NSDate *dateObj = [NSDate date];
        
        NSTimeInterval currentDate = [dateObj timeIntervalSince1970]*1000;
        
        if (chatDetails) {
            chatMessageObj = [self getChatMessageWithServerMessageID:[NSNumber numberWithLongLong:[[chatDetails valueForKey:kServerMessageID] longLongValue]] andClientID:[NSNumber numberWithLongLong:[[chatDetails valueForKey:kChatMessageIDKey] longLongValue]] andMessageSenderID:[NSString stringWithFormat:@"%@",[chatDetails valueForKey:kMessageSenderIDKey]] andMessageReceiverID:[NSString stringWithFormat:@"%@",[chatDetails valueForKey:kMessageReceiverID]]];
            
            if (!chatMessageObj) {
                chatMessageObj = (ChatMessage *)[NSEntityDescription insertNewObjectForEntityForName:@"ChatMessage" inManagedObjectContext:privateManagedObjectContext ];
            }
            
            
            if ([chatDetails objectForKey:kChatMessageIDKey]) {
                [chatMessageObj setClientMessageID:[NSNumber numberWithLongLong:[[chatDetails objectForKey:kChatMessageIDKey] longLongValue]]];
            }
            else{
                [chatMessageObj setClientMessageID:[NSNumber numberWithLongLong:currentDate]];
            }
            [chatMessageObj setChatRoomID:[NSString stringWithFormat:@"%@",[chatDetails objectForKey:kChatRoomIDKey]]];
            [chatMessageObj setMessageType:[NSNumber numberWithInt:[[chatDetails objectForKey:kMessageTypeKey] intValue]]];
            [chatMessageObj setMessage:[chatDetails objectForKey:kMessageKey]];
            [chatMessageObj setIsDelivered:[NSNumber numberWithBool:[[chatDetails objectForKey:kIsDeliveredKey] boolValue]]];
            [chatMessageObj setMessageSenderID:[NSString stringWithFormat:@"%@",[chatDetails objectForKey:kMessageSenderIDKey]]];
            [chatMessageObj setServerMessageID:[NSNumber numberWithLongLong:[[chatDetails objectForKey:kServerMessageID] longLongValue]]];
            [chatMessageObj setMessageReceiverID:[NSString stringWithFormat:@"%@",[chatDetails objectForKey:kMessageReceiverID]]];
            
            if ([chatDetails objectForKey:kChatMessageCreatedTime]) {
                
                if ([[chatDetails objectForKey:kChatMessageCreatedTime] longLongValue]>currentDate) {
                    [chatMessageObj setChatMessageCreatedTime:[NSNumber numberWithLongLong:currentDate]];
                }
                else{
                    if ([[chatDetails objectForKey:kChatMessageCreatedTime] isKindOfClass:[NSNumber class]]) {
                        [chatMessageObj setChatMessageCreatedTime:[chatDetails objectForKey:kChatMessageCreatedTime]];
                    }
                    else{
                        NSDecimalNumber *decimalNumber = [NSDecimalNumber decimalNumberWithString:[chatDetails objectForKey:kChatMessageCreatedTime]];
                        long long longLongNumber = [[decimalNumber description] longLongValue];
                        [chatMessageObj setChatMessageCreatedTime:[NSNumber numberWithLongLong:longLongNumber]];
                    }
                }
                
            }
            else{
                [chatMessageObj setChatMessageCreatedTime:[NSNumber numberWithLongLong:currentDate]];
            }
        }
       
        if (([[chatDetails objectForKey:kMessageTypeKey] intValue] == INTRODUCTION)) {
            if ([[self getAllMessageForChatRoom:chatMessageObj.chatRoomID] count] < 1) {
                [self insertNewChatMessageIntoDatabase:chatDetails withCompletionHandler:^(ChatMessage *chatMessageObj) {
                    // CHECK FOR THIS RECURSIVE CODE IN CHAT MESSAGE
                    [self insertionMessage:chatDetails withCompletionHandler:completionHandler withPrivateObject:privateManagedObjectContext withIntroMessage:introMessage withChatMessage:chatMessageObj];
                }];
            }else{
                [self insertionMessage:chatDetails withCompletionHandler:completionHandler withPrivateObject:privateManagedObjectContext withIntroMessage:introMessage withChatMessage:chatMessageObj];
            }
        }else{
            [self insertionMessage:chatDetails withCompletionHandler:completionHandler withPrivateObject:privateManagedObjectContext withIntroMessage:introMessage withChatMessage:chatMessageObj];
        }
        
        
    }];
    
}

+(void)insertionMessage:(NSDictionary *)chatDetails withCompletionHandler:(ChatInsertionCompletionHandler)completionHandler withPrivateObject:(NSManagedObjectContext*)privateManagedObjectContext withIntroMessage:(ChatMessage *)introMessage withChatMessage:(ChatMessage *)chatMessageObj {
    
    NSError *error = nil;
    
    if (([[chatDetails objectForKey:kMessageTypeKey] intValue] == QUESTION) || ([[chatDetails objectForKey:kMessageTypeKey] intValue] == ANSWER)) {
        long diffrence = ([[chatDetails objectForKey:kMessageTypeKey] intValue] == QUESTION) ? 2000 : 4000;
        if (!introMessage) {
            introMessage = [self getIntroMessageForTheChatRoom:[NSString stringWithFormat:@"%@",[chatDetails objectForKey:kChatRoomIDKey]]];
        }
        if ([introMessage.chatMessageCreatedTime longLongValue] > [chatMessageObj.chatMessageCreatedTime longLongValue]) {
            chatMessageObj.chatMessageCreatedTime = [NSNumber numberWithLongLong:[introMessage.chatMessageCreatedTime longLongValue]+ diffrence] ;
        }
    }
    
    
    if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //abort();
    }
    else{
        // Saving data on parent context and then informing back
        [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
            
            if(completionHandler)
                completionHandler(chatMessageObj);
            
        }];
    }

}

+(ChatMessage *)getIntroMessageForTheChatRoom:(NSString *)chatRoomId{
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(chatRoomID==%@)AND(messageType ==%@)", chatRoomId,[NSNumber numberWithInt:INTRODUCTION]];
    
    [request setPredicate:predicateObj];
    
    NSError *error = nil;
    
    NSArray *chatMessageArray = [managedObjectContext executeFetchRequest:request error:&error];
    if (chatMessageArray && [chatMessageArray count]>0) {
        return [chatMessageArray firstObject];
    }
    return nil;
}

+(void)insertMessagesIntoDatabase:(NSArray *)chatDetailArray{
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsUserBlacklisted]) {
        return;
    }
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    
    [privateManagedObjectContext performBlock:^{
        
        if (chatDetailArray && [chatDetailArray count]>0) {

            for (NSDictionary *chatDetails in chatDetailArray) {
            
                if (chatDetails && [chatDetails objectForKey:kChatMessageIDKey] && [[chatDetails objectForKey:kChatMessageIDKey] length]>0) {
                    
                    ChatMessage *introMessage = [self getIntroMessageForTheChatRoom:[NSString stringWithFormat:@"%@",[chatDetails objectForKey:kChatRoomIDKey]]];
                    
                    if (([[chatDetails objectForKey:kMessageTypeKey] intValue] != INTRODUCTION) && ([introMessage.chatMessageCreatedTime longLongValue] > [[chatDetails objectForKey:kChatMessageCreatedTime] longLongValue])) {
                        continue;
                    }
                    
                    ChatMessage *chatMessageObj = [self getChatMessageWithServerMessageID:[NSNumber numberWithLongLong:[[chatDetails valueForKey:kServerMessageID] longLongValue]] andClientID:[NSNumber numberWithLongLong:[[chatDetails valueForKey:kChatMessageIDKey] longLongValue]] andMessageSenderID:[NSString stringWithFormat:@"%@",[chatDetails valueForKey:kMessageSenderIDKey]] andMessageReceiverID:[NSString stringWithFormat:@"%@",[chatDetails valueForKey:kMessageReceiverID]]];
                    
                    if (!chatMessageObj) {
                        chatMessageObj = (ChatMessage *)[NSEntityDescription insertNewObjectForEntityForName:@"ChatMessage" inManagedObjectContext:privateManagedObjectContext ];
                    }
                    [chatMessageObj setClientMessageID:[NSNumber numberWithLongLong:[[chatDetails objectForKey:kChatMessageIDKey] longLongValue]]];
                    [chatMessageObj setChatRoomID:[NSString stringWithFormat:@"%@",[chatDetails objectForKey:kChatRoomIDKey]]];
                    
                    [chatMessageObj setMessageType:[NSNumber numberWithInt:[[chatDetails objectForKey:kMessageTypeKey] intValue]]];
                    [chatMessageObj setMessage:[chatDetails objectForKey:kMessageKey]];
                    [chatMessageObj setIsDelivered:[NSNumber numberWithBool:[[chatDetails objectForKey:kIsDeliveredKey] boolValue]]];
                    [chatMessageObj setMessageSenderID:[NSString stringWithFormat:@"%@",[chatDetails objectForKey:kMessageSenderIDKey]]];
                    [chatMessageObj setServerMessageID:[NSNumber numberWithLongLong:[[chatDetails objectForKey:kServerMessageID] longLongValue]]];
                    [chatMessageObj setMessageReceiverID:[NSString stringWithFormat:@"%@",[chatDetails objectForKey:kMessageReceiverID]]];
                    [chatMessageObj setImageSize:[NSString stringWithFormat:@"%@",[chatDetails objectForKey:kImageSize]]];
                    
                    NSDate *dateObj = [NSDate date];
                    NSTimeInterval currentDate = [dateObj timeIntervalSince1970]*1000;
                    
                    long long chatMsgTime = [[chatDetails objectForKey:kChatMessageCreatedTime] longLongValue];

                    if (chatMsgTime>currentDate) {
                        
                        [chatMessageObj setChatMessageCreatedTime:[NSNumber numberWithLongLong:currentDate]];
                    }
                    else{
                        [chatMessageObj setChatMessageCreatedTime:[NSNumber numberWithLongLong:[[chatDetails objectForKey:kChatMessageCreatedTime] longLongValue]]];
                    }
                    
                   // [MyMatches updateChatSnippetForChatRoomID:[NSString stringWithFormat:@"%@",[chatDetails objectForKey:kChatRoomIDKey]]];
                }
                
            }
        }

        if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
        else{
            // Saving data on parent context and then informing back
            [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                
                // Do Nothing
                
            }];
        }
        
    }];
    
    
    
}


+(void)deleteMessagesForChatRoom:(NSString *)chatRoomID{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    
    [privateManagedObjectContext performBlock:^{
    
        NSArray *chatMessageArray = [self getAllMessageForChatRoom:chatRoomID];
        
        if (chatMessageArray && [chatMessageArray count]>0) {
            for (ChatMessage *chatMessageObj in chatMessageArray) {
                if (chatMessageObj) {
                    [privateManagedObjectContext deleteObject:chatMessageObj];
                }
            }
        }
        
        if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
        else{
            // Saving data on parent context and then informing back
            [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                
                // Do Nothing
                
            }];
        }
        
    }];
    
}

+(NSArray *)getAllMessage{
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    NSError *error = nil;
    
    NSArray *chatMessageArray = [managedObjectContext executeFetchRequest:request error:&error];
    if (chatMessageArray && [chatMessageArray count]>0) {
        return chatMessageArray;
    }
    return nil;
}
+(NSArray *)getAllMessageForChatRoom:(NSString *)chatRoomID{
    
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(chatRoomID==%@)", chatRoomID];
    
    [request setPredicate:predicateObj];
    
    NSSortDescriptor *serverTimeSorting = [[NSSortDescriptor alloc] initWithKey:@"chatMessageCreatedTime" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:serverTimeSorting]];
    
    NSError *error = nil;
    
    NSArray *chatMessageArray = [managedObjectContext executeFetchRequest:request error:&error];
    if (chatMessageArray && [chatMessageArray count]>0) {
        return chatMessageArray;
    }
    return nil;
    
}
+(void)updateDeliveryStatusOfChatMessage:(NSString *)chatMessageID withDeliveryStatus:(BOOL)isDelivered andServerMessageID:(NSNumber *)serverMessageID withMsgDeliveryTime:(NSString *)msgServerCreatedTime{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    
    [privateManagedObjectContext performBlock:^{
    
        ChatMessage *chatMessageObj = [self getChatMessageWithChatMessageID:[NSNumber numberWithLongLong:[chatMessageID longLongValue]]];
        //    ChatMessage *chatMessageObj = [self getChatMessageWithServerMessageID:[NSNumber numberWithLongLong:[serverMessageID longLongValue]]];
        if (chatMessageObj) {
            [chatMessageObj setIsDelivered:[NSNumber numberWithBool:isDelivered]];
            [chatMessageObj setServerMessageID:serverMessageID];
            
            NSDate *dateObj = [NSDate date];
            NSTimeInterval currentDate = [dateObj timeIntervalSince1970]*1000;
            
            if ([msgServerCreatedTime longLongValue]>[[NSDate date] timeIntervalSince1970]) {
                [chatMessageObj setChatMessageCreatedTime:[NSNumber numberWithLongLong:currentDate]];
            }
            else{
                [chatMessageObj setChatMessageCreatedTime:[NSNumber numberWithLongLong:[msgServerCreatedTime longLongValue]]];
            }
            
            
        }
        
        if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
        else{
            // Saving data on parent context and then informing back
            [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                
                // Do Nothing
                
            }];
        }
        
    }];
}

+(ChatMessage *)getChatMessageWithChatMessageID:(NSNumber *)chatMessageID{
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(clientMessageID==%@)", chatMessageID];
    
    [request setPredicate:predicateObj];
    
    NSError *error = nil;
    
    NSArray *chatMessageArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    ChatMessage *chatMessageObj = nil;
    if (chatMessageArray && [chatMessageArray count]>0) {
        chatMessageObj = (ChatMessage *)[chatMessageArray objectAtIndex:0];
    }
    return chatMessageObj;
}
+(ChatMessage *)getChatMessageWithServerMessageID:(NSNumber *)serverMessageId andClientID:(NSNumber *)clientID andMessageSenderID:(NSString *)messageSenderID andMessageReceiverID:(NSString *)messageReceiverID{
    
    if ([serverMessageId longLongValue] <1) {
        return nil;
    }
    
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"((serverMessageID==%@) AND (clientMessageID==%@) AND (messageSenderID==%@) AND (messageReceiverID==%@))", serverMessageId,clientID,messageSenderID,messageReceiverID];
    
    [request setPredicate:predicateObj];
    
    NSError *error = nil;
    
    NSArray *chatMessageArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    ChatMessage *chatMessageObj = nil;
    if (chatMessageArray && [chatMessageArray count]>0) {
        chatMessageObj = (ChatMessage *)[chatMessageArray objectAtIndex:0];
    }
    return chatMessageObj;
}

+(NSNumber *)getLatestServerID{
    
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSSortDescriptor *serverTimeSorting = [[NSSortDescriptor alloc] initWithKey:@"serverMessageID" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:serverTimeSorting]];
    
    NSPredicate *getUndeliveredMsg = [NSPredicate predicateWithFormat:@"(messageSenderID !=%@)",[[NSUserDefaults standardUserDefaults] valueForKey:kWooUserId]];
    
    [request setPredicate:getUndeliveredMsg];
    
    [request setFetchLimit:1];
    
    NSError *error = nil;
    
    NSArray *chatMessageArray = [managedObjectContext executeFetchRequest:request error:&error];
    if (chatMessageArray && [chatMessageArray count]>0) {
        ChatMessage *chatMessageObj = (ChatMessage *)[chatMessageArray objectAtIndex:0];
        return chatMessageObj.serverMessageID;
    }
    return nil;
}

+(NSArray *)getAllUndeliveredMessges{

    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *getUndeliveredMsg = [NSPredicate predicateWithFormat:@"((isDelivered==%@) AND ((messageType !=%@) OR (messageType !=%@) OR (messageType !=%@)) AND (messageSenderID ==%@))", [NSNumber numberWithBool:FALSE],[NSNumber numberWithInt:INTRODUCTION],[NSNumber numberWithInt:QUESTION],[NSNumber numberWithInt:ANSWER],[[NSUserDefaults standardUserDefaults] valueForKey:kWooUserId]];
    
    [request setPredicate:getUndeliveredMsg];
    
    NSSortDescriptor *serverTimeSorting = [[NSSortDescriptor alloc] initWithKey:@"chatMessageCreatedTime" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:serverTimeSorting]];
    
    NSError *error = nil;
    
    NSArray *chatMessageArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (chatMessageArray && [chatMessageArray count]>0) {
        return chatMessageArray;
    }
    return nil;
}

+(NSArray *)getAllMessageForChatRoom:(NSString *)chatRoomID WithLimit:(NSInteger)chatLimit{
    
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(chatRoomID==%@)", chatRoomID];
    
    [request setPredicate:predicateObj];
    NSError *error = nil;
    
    NSInteger count = [managedObjectContext countForFetchRequest:request /*the one you have above but without limit */ error:&error];
    
    NSUInteger size = chatLimit;
    count -= size;
    [request setFetchOffset:count>0?count:0];
    [request setFetchLimit:size];

    NSSortDescriptor *clientTimeSorting = [[NSSortDescriptor alloc] initWithKey:@"chatMessageCreatedTime" ascending:YES];
    
    [request setSortDescriptors:[NSArray arrayWithObject:clientTimeSorting]];
 
    NSArray *chatMessageArray = [managedObjectContext executeFetchRequest:request error:&error];
    if (chatMessageArray && [chatMessageArray count]>0) {
        return chatMessageArray;
    }
    else{
        
    }
    return nil;
}

+(NSArray *)getAllMessageForChatRoom:(NSString *)chatRoomID WithIndex:(NSInteger)currentIndex{
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(chatRoomID==%@)", chatRoomID];
    
    [request setPredicate:predicateObj];
    
    NSSortDescriptor *clientTimeSorting = [[NSSortDescriptor alloc] initWithKey:@"chatMessageCreatedTime" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:clientTimeSorting]];
    
    [request setFetchLimit:20];
    [request setFetchOffset:currentIndex*20];
    
    NSError *error = nil;
    
    NSArray *chatMessageArray = [managedObjectContext executeFetchRequest:request error:&error];
    if (chatMessageArray && [chatMessageArray count]>0) {
        return chatMessageArray;
    }
    return nil;
}

+(BOOL)isMoreDataAvailableForChatRoom:(NSString *)chatRoomID WithIndex:(NSInteger)currentIndex{
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(chatRoomID==%@)", chatRoomID];
    
    [request setPredicate:predicateObj];
    
    [request setFetchLimit:kNumberOfMessageToBeShownAtATime];
    
    [request setFetchOffset:(currentIndex+1)*kNumberOfMessageToBeShownAtATime];
    
    NSError *error = nil;
    
    NSArray *chatMessageArray = [managedObjectContext executeFetchRequest:request error:&error];
    if (chatMessageArray && [chatMessageArray count]>0) {
        return TRUE;
    }
    return FALSE;
}

+(ChatMessage *)getLastMessageForChatRoom:(NSString *)chatRoomID{
    
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];

    
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        [request setEntity:entityDescription];
        
        NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(chatRoomID==%@)", chatRoomID];
        
        [request setPredicate:predicateObj];
        
        NSSortDescriptor *clientTimeSorting = [[NSSortDescriptor alloc] initWithKey:@"chatMessageCreatedTime" ascending:YES];
        [request setSortDescriptors:[NSArray arrayWithObject:clientTimeSorting]];
        
        NSError *error = nil;
        
        NSArray *chatMessageArray = [managedObjectContext executeFetchRequest:request error:&error];

        if (chatMessageArray && [chatMessageArray count]>0) {
            return [chatMessageArray lastObject];
        }
    
    return nil;
}
+(void)updateCrationTimeOfIntroMessageForChatRoom:(NSString *)chatRoomID{

}

+(long long)getTheMaximumCreatedTimeForAChatRoom:(NSString *)chatRoomID{
    long long maximumTime = 0.0;
    ChatMessage *chatMessageObj = [self getLastMessageForChatRoom:chatRoomID];
    
    maximumTime = [chatMessageObj.chatMessageCreatedTime longLongValue];
    
    return maximumTime;
}

+(NSArray *)getAllMessageForChatRoomAfterChat:(ChatMessage *)chatObj forChatRoom:(NSString *)chatRoomID{
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"((chatRoomID==%@) && (chatMessageCreatedTime >%@))", chatRoomID,chatObj.chatMessageCreatedTime];
    
    [request setPredicate:predicateObj];
    
    NSError *error = nil;
    
    NSArray *chatMessageArray = [managedObjectContext executeFetchRequest:request error:&error];
    if (chatMessageArray && [chatMessageArray count]>0) {
        return chatMessageArray;
    }
    return nil;
}

+(NSArray *)getAllMessageForChatRoomAfterChat_New:(NSInteger )maxNumberOfChat forChatRoom:(NSString *)chatRoomID{
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSError *error = nil;
 
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(chatRoomID==%@)", chatRoomID];
    [request setPredicate:predicateObj];
    
    NSInteger count = [managedObjectContext countForFetchRequest:request /*the one you have above but without limit */ error:&error];
    
    NSUInteger size = 20;
    count -= size;
    [request setFetchOffset:count>0?count:0];
    [request setFetchLimit:size];
    
    NSArray *chatMessageArray = [managedObjectContext executeFetchRequest:request error:&error];
    if (chatMessageArray && [chatMessageArray count]>0) {
        return chatMessageArray;
    }
    return nil;
}



+(NSArray *)getAllMessageForChatRoomExceptIntoductionMessage:(NSString *)chatRoomId{
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"((chatRoomID==%@)AND((messageType!=%@) AND (messageType!=%@) AND (messageType!=%@)AND (messageType!=%@)))", chatRoomId,[NSNumber numberWithInt:INTRODUCTION],[NSNumber numberWithInt:QUESTION],[NSNumber numberWithInt:ANSWER],[NSNumber numberWithInt:MATCHED_THROUGH_CELL]];

    [request setPredicate:predicateObj];
    
    NSSortDescriptor *serverTimeSorting = [[NSSortDescriptor alloc] initWithKey:@"chatMessageCreatedTime" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:serverTimeSorting]];
    
    NSError *error = nil;
    
    NSArray *chatMessageArray = [managedObjectContext executeFetchRequest:request error:&error];
    if (chatMessageArray && [chatMessageArray count]>0) {
        return chatMessageArray;
    }
    return nil;
}

+(void)deleteAllChats{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
   
    [privateManagedObjectContext performBlock:^{
        
        NSArray *allChatArray = [self getAllMessage];
        if (allChatArray && [allChatArray count]>0) {
            for (ChatMessage *chatObj in allChatArray) {
                [privateManagedObjectContext deleteObject:chatObj];
            }
        }
        
        if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
        else{
            // Saving data on parent context and then informing back
            [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                
                // Do Nothing
                
            }];
        }
        
    }];
 

}

+(void)deleteAllChatForChatRoomExceptIntroMessage:(NSString *)chatRoomID withCompletionHandler:(ChatDeletionCompletionHandler)completionHandler{
   
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
   
    [privateManagedObjectContext performBlock:^{
        
        NSArray *chatMessageArray = [self getAllMessageForChatRoomExceptIntoductionMessage:chatRoomID];
        if (chatMessageArray && [chatMessageArray count]>0) {
            for (ChatMessage *chatMessageObj in chatMessageArray) {
                if (chatMessageObj) {
                    [privateManagedObjectContext deleteObject:chatMessageObj];
                }
            }
        }
        
        if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
        else{
            // Saving data on parent context and then informing back
            [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                
                completionHandler(TRUE);
                
            }];
        }
        
    }];
 
}

+(void)insertNewChatMessageIntoDatabaseFromLayer:(NSDictionary *)chatDetails forMatchDetail:(MyMatches *)matchDetail andAlsoMarkChatRoomAsRead:(BOOL)shouldMakeChatRoomRead  withCompletionHandler:(ChatInsertionCompletionHandler)completionHandler {
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsUserBlacklisted]) {
        completionHandler(nil);
    }
    
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    [privateManagedObjectContext performBlock:^{
        
        ChatMessage *chatMessageObj = nil;
        
        BOOL sendNotificationToShowMessagePreviewInStatusBar = FALSE;
        NSDate *dateObj = [NSDate date];
        NSTimeInterval currentDate = [dateObj timeIntervalSince1970]*1000;
        
        //    NSLog(@"Inserting a message>>C>>>: :%@",chatDetails);
        if (chatDetails) {
            //Nikal intro
//            if([[chatDetails objectForKey:kMessageTypeKey] intValue] != INTRODUCTION)
//            {
//                completionHandler(nil);
//            }
//            ChatMessage *introMessage = [self getIntroMessageForTheChatRoom:[NSString stringWithFormat:@"%@",[chatDetails objectForKey:kChatRoomIDKey]]];
//            // agar aaya hua mesg intor nahi hai and intro ka creation time is greater than apne message ka time
//            if (([[chatDetails objectForKey:kMessageTypeKey] intValue] != INTRODUCTION) && ([introMessage.chatMessageCreatedTime longLongValue] > [[chatDetails objectForKey:kChatMessageCreatedTime] longLongValue])) {
//                completionHandler(nil);
//            }
            
            NSLog(@"chatDetails");
            
            if ([[APP_Utilities validString:[chatDetails objectForKey:kChatMessageLayerID]] length] > 0 ) {
                chatMessageObj = [self getChatMessageForLayerMessageId:[chatDetails objectForKey:kChatMessageLayerID]];
            }
            else{
                chatMessageObj = [self getChatMessageWithLayerMessage:chatDetails];
            }
            if (!chatMessageObj) {
                chatMessageObj = (ChatMessage *)[NSEntityDescription insertNewObjectForEntityForName:@"ChatMessage" inManagedObjectContext:privateManagedObjectContext ];
                sendNotificationToShowMessagePreviewInStatusBar = TRUE;
            }

            if ([chatDetails objectForKey:kChatMessageIDKey]) {
                [chatMessageObj setClientMessageID:[NSNumber numberWithLongLong:[[chatDetails objectForKey:kChatMessageIDKey] longLongValue]]];
            }
            else{
                [chatMessageObj setClientMessageID:[NSNumber numberWithLongLong:currentDate]];
            }
            [chatMessageObj setChatRoomID:[NSString stringWithFormat:@"%@",[chatDetails objectForKey:kChatRoomIDKey]]];
            [chatMessageObj setMessageType:[NSNumber numberWithInt:[[chatDetails objectForKey:kMessageTypeKey] intValue]]];
            [chatMessageObj setMessage:[chatDetails objectForKey:kMessageKey]];
            [chatMessageObj setIsDelivered:[NSNumber numberWithBool:[[chatDetails objectForKey:kIsDeliveredKey] boolValue]]];
            [chatMessageObj setMessageSenderID:[NSString stringWithFormat:@"%@",[chatDetails objectForKey:kMessageSenderIDKey]]];
            [chatMessageObj setServerMessageID:[NSNumber numberWithLongLong:[[chatDetails objectForKey:kServerMessageID] longLongValue]]];
            [chatMessageObj setMessageReceiverID:[NSString stringWithFormat:@"%@",[chatDetails objectForKey:kMessageReceiverID]]];
            [chatMessageObj setChatDeliveryStatus:[NSNumber numberWithLongLong:[[chatDetails objectForKey:kChatMessageDeliveryLayerStatus] longLongValue]]];
            if ([chatDetails objectForKey:kChatMessageLayerID] == nil){
                NSTimeInterval currentDate = [[NSDate date] timeIntervalSince1970]*1000;
                NSString *createdTime = [NSString stringWithFormat:@"%.0f",currentDate];
                [chatMessageObj setLayerMessageID:createdTime];
            }else{
                [chatMessageObj setLayerMessageID:[chatDetails objectForKey:kChatMessageLayerID]];
            }
            
           NSLog(@"chatDetails aage ka");
            [chatMessageObj setImageSize:[NSString stringWithFormat:@"%@",[chatDetails objectForKey:kImageSize]]];
            
            if ([chatDetails objectForKey:kChatMessageCreatedTime]) {
                
                //changed the comparison to fix the timestamp issue. On Sept 2014 by Umesh
                if ([[chatDetails objectForKey:kChatMessageCreatedTime] longLongValue]>currentDate) {
                    [chatMessageObj setChatMessageCreatedTime:[NSNumber numberWithLongLong:currentDate]];
                }
                else{
                    [chatMessageObj setChatMessageCreatedTime:[NSNumber numberWithLongLong:[[chatDetails objectForKey:kChatMessageCreatedTime] longLongValue]]];
                }
                
            }
            else{
                [chatMessageObj setChatMessageCreatedTime:[NSNumber numberWithLongLong:currentDate]];
            }

            ///update chat room
            NSString *chatSnippetText = nil;
            if ([[chatDetails objectForKey:kMessageTypeKey] intValue] == TEXT) {
                chatSnippetText = [chatDetails objectForKey:kMessageKey];
            }
            else if ([[chatDetails objectForKey:kMessageTypeKey] intValue] == IMAGE_SEND_BY_USER){
                chatSnippetText = @"Image";
            }
            else if ([[chatDetails objectForKey:kMessageTypeKey] intValue] == IMAGE){
                chatSnippetText = @"Sticker";
            }
            else{
                chatSnippetText = [chatDetails objectForKey:kMessageKey];
            }
            
            NSLog(@"enter here to check applozic new message");
            double timeInSeconds = ([chatMessageObj.chatMessageCreatedTime longLongValue]/1000.0);
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInSeconds];
            
            // 
            [MyMatches updateChatSnippetForChatRoom:[chatDetails objectForKey:kChatRoomIDKey] withChatSnippet:chatSnippetText forMatchDetail:matchDetail timeStamp:date andIsRead:shouldMakeChatRoomRead andSource:[chatDetails objectForKey:kMatchSource] withBackgroundCompletion:^(BOOL isUpdationCompleted, MyMatches *matchDetailObj) {
                if(isUpdationCompleted)
                {
                    NSLog(@"enter here to check applozic new message  1");
                    [self updatingChatSnippetInTheDatabase:privateManagedObjectContext forMatchDetail:matchDetailObj withCompletionHandler:completionHandler withShowMessageInStatusBar:sendNotificationToShowMessagePreviewInStatusBar withChatDetails:chatDetails withChatMessage:chatMessageObj];
                    
                    NSLog(@"enter here to check applozic new message 5");
                }
            }];
        }else{
            if(completionHandler)
                completionHandler(chatMessageObj);
            
        }
    }];
}

+(void)updatingChatSnippetInTheDatabase:(NSManagedObjectContext *)privateManagedObjectContext forMatchDetail:(MyMatches*)matchedUser withCompletionHandler:(ChatInsertionCompletionHandler)completionHandler withShowMessageInStatusBar:(BOOL)sendNotificationToShowMessagePreviewInStatusBar withChatDetails:(NSDictionary *)chatDetails withChatMessage:(ChatMessage *)chatMessageObj{
    
    __block NSError *error = nil;
    
    NSLog(@"enter here to check applozic new message 2");
    
    if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //abort();
    }
    else{
        // Saving data on parent context and then informing back
        [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
            
            if(completionHandler)
                completionHandler(chatMessageObj);
            
            NSLog(@"enter here to check applozic new message 2 ");
            if (matchedUser &&[[APP_Utilities validString:matchedUser.matchUserName] length] > 0) {
                BOOL showTopNotification = TRUE;
                if ([[NSUserDefaults standardUserDefaults] objectForKey:kWooLoggedInTime]) {
                    NSTimeInterval messageSentTime = [[chatDetails objectForKey:kChatMessageCreatedTime] longLongValue];
                    NSTimeInterval loggedInTime = [(NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:kWooLoggedInTime] timeIntervalSince1970]* 1000;
                    if (loggedInTime > messageSentTime) {
                        showTopNotification = FALSE;
                    }
                }
                
                NSLog(@"enter here to check applozic new message 3");
                //
                if ((![APP_DELEGATE.currentActiveChatRoomId isEqualToString:[chatDetails objectForKey:kChatRoomIDKey]]) && showTopNotification){
                    if(matchedUser.isTargetFlagged.boolValue == false)
                    {
                        NSString *message = [chatDetails objectForKey:kMessageKey];
                        
                        if ([message containsString:@"uploadedPhoto"] && [[chatDetails objectForKey:@"messageType"] intValue] == 7){
                            message = @"sent you an image";
                        }
                        
                        [APP_DELEGATE showNewChatMessageFromTop:message headerText:matchedUser.matchUserName withImageURL:matchedUser.matchUserPic withMatchId:matchedUser.matchId];
                        
                    }
                }
                //Works only the first time
                if (![[NSUserDefaults standardUserDefaults] boolForKey:kTopNotificationForOldMessageShow]) {
                    if (!showTopNotification) {
                        [APP_DELEGATE showNewChatMessageFromTop:@"You have received new messages from your matches! Tap to see them now." headerText:@"" withImageURL:@"" withMatchId:@""];
                        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kTopNotificationForOldMessageShow];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                }
            }
        }];
    }
}

//+(void)insertNewImageMessageIntoDatabaseFromLayer:(NSDictionary *)chatDetails forMatchDetail:(MyMatches *)matchDetail andAlsoMarkChatRoomAsRead:(BOOL)shouldMakeChatRoomRead  withMimeType : (LYRMessagePart *)messagePart withCompletionHandler:(ChatInsertionCompletionHandler)completionHandler
//{
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsUserBlacklisted]) {
//        completionHandler(nil);
//    }
//
//    __block ChatMessage *chatMessageObj = nil;
//
//    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
//
//
//    [privateManagedObjectContext performBlock:^{
//
//        BOOL sendNotificationToShowMessagePreviewInStatusBar = FALSE;
//
//        NSDate *dateObj = [NSDate date];
//
//        NSTimeInterval currentDate = [dateObj timeIntervalSince1970]*1000;
//
//        if (chatDetails) {
//
//            ChatMessage *introMessage = [self getIntroMessageForTheChatRoom:[NSString stringWithFormat:@"%@",[chatDetails objectForKey:kChatRoomIDKey]]];
//
//            if (([[chatDetails objectForKey:kMessageTypeKey] intValue] != INTRODUCTION) && ([introMessage.chatMessageCreatedTime longLongValue] > [[chatDetails objectForKey:kChatMessageCreatedTime] longLongValue])) {
//                completionHandler(nil);
//            }
//
//            if ([[APP_Utilities validString:[chatDetails objectForKey:kChatMessageLayerID]] length] > 0 ) {
//                chatMessageObj = [self getChatMessageForLayerMessageId:[chatDetails objectForKey:kChatMessageLayerID]];
//            }
//            else{
//                chatMessageObj = [self getChatMessageWithClientID:[NSNumber numberWithLongLong:[[chatDetails valueForKey:kChatMessageIDKey] longLongValue]] andMessageSenderID:[NSString stringWithFormat:@"%@",[chatDetails valueForKey:kMessageSenderIDKey]] andMessageReceiverID:[NSString stringWithFormat:@"%@",[chatDetails valueForKey:kMessageReceiverID]]];
//            }
//
//
//            if (!chatMessageObj) {
//                chatMessageObj = (ChatMessage *)[NSEntityDescription insertNewObjectForEntityForName:@"ChatMessage" inManagedObjectContext:privateManagedObjectContext ];
//                sendNotificationToShowMessagePreviewInStatusBar = TRUE;
//            }
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
//            [chatMessageObj setChatDeliveryStatus:[NSNumber numberWithLongLong:[[chatDetails objectForKey:kChatMessageDeliveryLayerStatus] longLongValue]]];
//
//            [chatMessageObj setLayerMessageID:[chatDetails objectForKey:kChatMessageLayerID]];
//            [chatMessageObj setImageSize:[NSString stringWithFormat:@"%@",[chatDetails objectForKey:kImageSize]]];
//
//            if ([chatDetails objectForKey:kChatMessageCreatedTime]) {
//                //changed the comparison to fix the timestamp issue. On Sept 2014 by Umesh
//                if ([[chatDetails objectForKey:kChatMessageCreatedTime] longLongValue]>currentDate) {
//                    [chatMessageObj setChatMessageCreatedTime:[NSNumber numberWithLongLong:currentDate]];
//                }
//                else{
//                    [chatMessageObj setChatMessageCreatedTime:[NSNumber numberWithLongLong:[[chatDetails objectForKey:kChatMessageCreatedTime] longLongValue]]];
//                }
//            }
//            else{
//                [chatMessageObj setChatMessageCreatedTime:[NSNumber numberWithLongLong:currentDate]];
//            }
//
//            ///update chat room
//            NSString *chatSnippetText = nil;
//            if ([[chatDetails objectForKey:kMessageTypeKey] intValue] == TEXT) {
//                chatSnippetText = [chatDetails objectForKey:kMessageKey];
//            }
//            else if ([[chatDetails objectForKey:kMessageTypeKey] intValue] == IMAGE_SEND_BY_USER){
//                chatSnippetText = @"Image";
//            }
//            else if ([[chatDetails objectForKey:kMessageTypeKey] intValue] == IMAGE){
//                chatSnippetText = @"Sticker";
//            }
//            else{
//                chatSnippetText = [chatDetails objectForKey:kMessageKey];
//            }
//
//            double timeInSeconds = ([chatMessageObj.chatMessageCreatedTime longLongValue]/1000.0);
//            NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInSeconds];
//
//            [MyMatches updateChatSnippetForChatRoom:[chatDetails objectForKey:kChatRoomIDKey] withChatSnippet:chatSnippetText forMatchDetail:matchDetail timeStamp:date andIsRead:shouldMakeChatRoomRead andSource:[chatDetails objectForKey:kMatchSource] withBackgroundCompletion:^(BOOL isUpdationCompleted, MyMatches *matchDetail) {
//
//                [self updateMessageInDatabase:privateManagedObjectContext forMatchDetail:matchDetail withCompletionHandler:completionHandler withShowMessageInStatusBar:sendNotificationToShowMessagePreviewInStatusBar withChatDetails:chatDetails withChatMessage:chatMessageObj withMimeType:messagePart];
//            }];
//        }else{
//            if(completionHandler)
//                completionHandler(chatMessageObj);
//        }
//
//
//    }];
//
//}

+(void)updateChatMessagesForChatRoomId:(NSString*)oldChatRoomId withNewChatRoomId:(NSString*)chatRoomId withUpdationHandler:(ChatModificationCompletionHandler)completionHandler
{
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    
    [privateManagedObjectContext performBlock:^{
   
    NSArray *chatMessageArray = [self getAllMessageForChatRoom:oldChatRoomId];
    
        if (chatMessageArray && [chatMessageArray count]>0) {
            for (ChatMessage *chatMessageObj in chatMessageArray)
            {
                chatMessageObj.chatRoomID = chatRoomId;
            }
        }
        else
        {
            completionHandler(YES);
        }
        if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
        else{
            // Saving data on parent context and then informing back
            [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                    if(completionHandler)
                    {
                        completionHandler(YES);
                    }
                }];
            }
         }];
    }

//+(void)updateMessageInDatabase:(NSManagedObjectContext *)privateManagedObjectContext forMatchDetail:(MyMatches*)matchedUser withCompletionHandler:(ChatInsertionCompletionHandler)completionHandler withShowMessageInStatusBar:(BOOL)sendNotificationToShowMessagePreviewInStatusBar withChatDetails:(NSDictionary *)chatDetails withChatMessage:(ChatMessage *)chatMessageObj withMimeType : (LYRMessagePart *)messagePart{
//
//    __block NSError *error = nil;
//
//    if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
//        // Replace this implementation with code to handle the error appropriately.
//        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        //abort();
//    }
//    else{
//        // Saving data on parent context and then informing back
//        [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
//            if(completionHandler)
//                completionHandler(chatMessageObj);
//
//            if (matchedUser &&[[APP_Utilities validString:matchedUser.matchUserName] length] > 0 && matchedUser.matchedUserId  && [chatMessageObj.messageSenderID isEqualToString:matchedUser.matchedUserId]) {
//
//                if (![APP_DELEGATE.currentActiveChatRoomId isEqualToString:[chatDetails objectForKey:kChatRoomIDKey]]  && matchedUser.isTargetFlagged.boolValue == false){
//
//                    if (messagePart != nil){
//                    if ([messagePart.MIMEType isEqualToString:MIME_TYPE_IMAGE_PNG])
//                        [APP_DELEGATE showNewChatMessageFromTop:[NSString stringWithFormat:@"%@: %@",matchedUser.matchUserName,@"Sticker"] headerText:matchedUser.matchUserName withImageURL:matchedUser.matchUserPic withMatchId:matchedUser.matchId];
//                    else
//                        [APP_DELEGATE showNewChatMessageFromTop:[NSString stringWithFormat:@"%@: %@",matchedUser.matchUserName,@"Image"] headerText:matchedUser.matchUserName withImageURL:matchedUser.matchUserPic withMatchId:matchedUser.matchId];
//                    }
//                    else{
//                        if ([[chatDetails objectForKey:kMessageTypeKey] intValue] == IMAGE_SEND_BY_USER){
//                            [APP_DELEGATE showNewChatMessageFromTop:[NSString stringWithFormat:@"%@: %@",matchedUser.matchUserName,@"Image"] headerText:matchedUser.matchUserName withImageURL:matchedUser.matchUserPic withMatchId:matchedUser.matchId];
//                        }
//                    }
//
//                }
//            }
//
//        }];
//    }
//}

+(void)updateMessageIntoDatabaseFromLayer:(NSDictionary *)chatDetails andAlsoMarkChatRoomAsRead:(BOOL)shouldMakeChatRoomRead withUpdationHandler:(ChatUpdationCompletionHandler)completionHandler{
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsUserBlacklisted]) {
        completionHandler(nil);
    }
    
    __block ChatMessage *chatMessageObj = nil;
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    
    [privateManagedObjectContext performBlock:^{
        
        BOOL sendNotificationToShowMessagePreviewInStatusBar = FALSE;
        
        NSDate *dateObj = [NSDate date];
        
        NSTimeInterval currentDate = [dateObj timeIntervalSince1970]*1000;
        
        if (chatDetails) {
            
            ChatMessage *introMessage = [self getIntroMessageForTheChatRoom:[NSString stringWithFormat:@"%@",[chatDetails objectForKey:kChatRoomIDKey]]];
            
            if (([[chatDetails objectForKey:kMessageTypeKey] intValue] != INTRODUCTION) && ([introMessage.chatMessageCreatedTime longLongValue] > [[chatDetails objectForKey:kChatMessageCreatedTime] longLongValue])) {
                completionHandler(nil);
            }
            
            chatMessageObj = [self getChatMessageWithLayerMessage:chatDetails];
            
            if (!chatMessageObj) {
                //Returning as this method is to update status of chat only not to insert a new one.
                completionHandler(nil);
            }
            if ([chatDetails objectForKey:kChatMessageIDKey]) {
                [chatMessageObj setClientMessageID:[NSNumber numberWithLongLong:[[chatDetails objectForKey:kChatMessageIDKey] longLongValue]]];
            }
            else{
                //[chatMessageObj setClientMessageID:[NSNumber numberWithLongLong:currentDate]];
            }
            [chatMessageObj setChatRoomID:[NSString stringWithFormat:@"%@",[chatDetails objectForKey:kChatRoomIDKey]]];
            [chatMessageObj setMessageType:[NSNumber numberWithInt:[[chatDetails objectForKey:kMessageTypeKey] intValue]]];
            [chatMessageObj setMessage:[chatDetails objectForKey:kMessageKey]];
            [chatMessageObj setIsDelivered:[NSNumber numberWithBool:[[chatDetails objectForKey:kIsDeliveredKey] boolValue]]];
            [chatMessageObj setMessageSenderID:[NSString stringWithFormat:@"%@",[chatDetails objectForKey:kMessageSenderIDKey]]];
            [chatMessageObj setServerMessageID:[NSNumber numberWithLongLong:[[chatDetails objectForKey:kServerMessageID] longLongValue]]];
            [chatMessageObj setMessageReceiverID:[NSString stringWithFormat:@"%@",[chatDetails objectForKey:kMessageReceiverID]]];
            [chatMessageObj setChatDeliveryStatus:[NSNumber numberWithLongLong:[[chatDetails objectForKey:kChatMessageDeliveryLayerStatus] longLongValue]]];
           // NSLog(@"[NSNumber numberWithLongLong:[[chatDetails objectForKey:kChatMessageDeliveryLayerStatus] longLongValue]] >>>>>>> %@ for messageObjText %@",[NSNumber numberWithLongLong:[[chatDetails objectForKey:kChatMessageDeliveryLayerStatus] longLongValue]],[chatDetails objectForKey:kMessageKey]);

            if ([chatDetails objectForKey:kChatMessageLayerID] == nil){
                NSTimeInterval currentDate = [[NSDate date] timeIntervalSince1970]*1000;
                NSNumber *dateInNumber = [NSNumber numberWithLongLong:currentDate];
                NSString *createdTime = [NSString stringWithFormat:@"%.0f",[dateInNumber longLongValue]];
                [chatMessageObj setLayerMessageID:createdTime];
            }else{
                [chatMessageObj setLayerMessageID:[chatDetails objectForKey:kChatMessageLayerID]];
            }
            
            [chatMessageObj setImageSize:[NSString stringWithFormat:@"%@",[chatDetails objectForKey:kImageSize]]];
            
            if ([chatDetails objectForKey:kChatMessageCreatedTime]) {
                
                //changed the comparison to fix the timestamp issue. On Sept 2014 by Umesh
                if ([[chatDetails objectForKey:kChatMessageCreatedTime] longLongValue]>currentDate) {
                    [chatMessageObj setChatMessageCreatedTime:[NSNumber numberWithLongLong:currentDate]];
                }
                else{
                    [chatMessageObj setChatMessageCreatedTime:[NSNumber numberWithLongLong:[[chatDetails objectForKey:kChatMessageCreatedTime] longLongValue]]];
                }
                
            }
            else{
                [chatMessageObj setChatMessageCreatedTime:[NSNumber numberWithLongLong:currentDate]];
            }
            
        }
        
        if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
        else{
            // Saving data on parent context and then informing back
            [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                if(completionHandler)
                    completionHandler(chatMessageObj);
            }];
        }
        
    }];
}

+(void)updateChatMessageObject:(ChatMessage *)chatMessageObject withChatMessageId:(NSString *)messageId withUpdationHandler:(ChatUpdationCompletionHandler)completionHandler{
    
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    [chatMessageObject setChatRoomID:messageId];
        if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
        else{
            // Saving data on parent context and then informing back
            [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                
            }];
        }
}

+(void)updateChatMessageObject:(ChatMessage *)chatMessageObject withStatus:(NSNumber *)messageStatus withUpdationHandler:(ChatUpdationCompletionHandler)completionHandler{
    
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    [chatMessageObject setChatDeliveryStatus:messageStatus];
    if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //abort();
    }
    else{
        // Saving data on parent context and then informing back
        [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
            completionHandler(chatMessageObject);
        }];
    }
}


+(ChatMessage *)getChatMessageWithLayerMessage:(NSDictionary *)chatDetails{

    if ([[chatDetails valueForKey:kChatMessageLayerID] length] <1) {
        return nil;
    }
    
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"((layerMessageID==%@) AND  (messageSenderID==%@) AND (messageReceiverID==%@))", [chatDetails valueForKey:kChatMessageLayerID],[NSString stringWithFormat:@"%@",[chatDetails valueForKey:kMessageSenderIDKey]],[NSString stringWithFormat:@"%@",[chatDetails valueForKey:kMessageReceiverID]]];
    
    [request setPredicate:predicateObj];
    
    NSError *error = nil;
    
    NSArray *chatMessageArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    ChatMessage *chatMessageObj = nil;
    if (chatMessageArray && [chatMessageArray count]>0) {
        chatMessageObj = (ChatMessage *)[chatMessageArray objectAtIndex:0];
    }
    return chatMessageObj;
}

+(NSNumber *)getTheCreationTimeOfLastDeliveredMessageIfAnyForChatRoom:(NSString *)chatRoomID{
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSSortDescriptor *serverTimeSorting = [[NSSortDescriptor alloc] initWithKey:@"chatMessageCreatedTime" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:serverTimeSorting]];
    [request setFetchLimit:1];
    
    NSError *error = nil;
    NSArray *chatMessageArray = [managedObjectContext executeFetchRequest:request error:&error];
    ChatMessage *lastChatMessage = nil;
    if ([chatMessageArray count]>0) {
        lastChatMessage = [chatMessageArray objectAtIndex:0];
    }
    
    if (lastChatMessage && [[APP_Utilities validString:lastChatMessage.layerMessageID] length]>0) {
        return lastChatMessage.chatMessageCreatedTime;
    }
    return nil;
    
}

+(void)checkAndInsertIntroMessageForAChatRommIfDoesNotExist:(NSString *)chatRoomID{
    /// CODE REMOVED BY LOKESH
}


+(void)updateDeliveryStatusOfImage:(NSNumber *)chatMessageId withChatMessage:(NSString *)imageUrl{
 
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    
    [privateManagedObjectContext performBlock:^{
        
        ChatMessage *chatMessageObj = [self getChatMessageWithChatMessageID:chatMessageId];
        if (chatMessageObj) {
            [chatMessageObj setIfchatImageIsItUploaded:[NSNumber numberWithBool:TRUE]];
            [chatMessageObj setMessage:imageUrl];
        }
        if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
        else{
            // Saving data on parent context and then informing back
            [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                
                // Do Nothing
                
            }];
        }
        
    }];
    

}

+(void)updateImageSizeOfImageChat:(float)imageSize forChatId:(NSNumber *)chatMessageId withUpdationHandler:(ChatModificationCompletionHandler)completionHandler{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    
    [privateManagedObjectContext performBlock:^{
  
        ChatMessage *chatMessageObj = [self getChatMessageWithChatMessageID:chatMessageId];
        if (chatMessageObj) {
            [chatMessageObj setImageSize:[NSString stringWithFormat:@"%d",(int)imageSize]];
        }
        
        if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
        else{
            // Saving data on parent context and then informing back
            [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                
                if(completionHandler){
                    completionHandler(TRUE);
                }
                
            }];
        }
        
    }];
}

+(void)updateDeliveryStatusOfImage:(NSNumber *)chatMessageId withUpdationHandler:(ChatModificationCompletionHandler)completionHandler{
   
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    
    [privateManagedObjectContext performBlock:^{
        
        ChatMessage *chatMessageObj = [self getChatMessageWithChatMessageID:chatMessageId];
        if (chatMessageObj) {
            [chatMessageObj setIfchatImageIsItUploaded:[NSNumber numberWithBool:TRUE]];
        }
        
        if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
        else{
            // Saving data on parent context and then informing back
            [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                
                if(completionHandler){
                    completionHandler(isCompleted);
                }
                
            }];
        }
        
    }];
    
}

+(ChatMessage *)getChatMessageWithClientID:(NSNumber *)clientID andMessageSenderID:(NSString *)messageSenderID andMessageReceiverID:(NSString *)messageReceiverID{
    if ([clientID longLongValue] <1) {
        return nil;
    }
    
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"((clientMessageID==%@) AND (messageSenderID==%@) AND (messageReceiverID==%@))",clientID,messageSenderID,messageReceiverID];
    
    [request setPredicate:predicateObj];
    
    NSError *error = nil;
    
    NSArray *chatMessageArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    ChatMessage *chatMessageObj = nil;
    if (chatMessageArray && [chatMessageArray count]>0) {
        chatMessageObj = (ChatMessage *)[chatMessageArray objectAtIndex:0];
    }
    return chatMessageObj;
}

+(void)updateLayerIdOfChatMessageWithLayerId:(NSString *)layerId andDeliveryStatus:(NSNumber *)deliveryStatus forChatObject:(ChatMessage *)chatObj withUpdationHandler:(ChatUpdationCompletionHandler)completionHandler{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    [privateManagedObjectContext performBlock:^{

        if (chatObj) {
            [chatObj setChatDeliveryStatus:deliveryStatus];
            [chatObj setIfchatImageIsItUploaded:[NSNumber numberWithInt:1]];
            [chatObj setLayerMessageID:layerId];
        }

        if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
        else{
            // Saving data on parent context and then informing back
            [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                
                if (completionHandler){
                    completionHandler(chatObj);
                }
                // Do Nothing
                
            }];
        }
        
    }];

}

+(ChatMessage *)getChatMessageForLayerMessageId:(NSString *)layerChatId{
    if ([layerChatId length] < 1) {
        return nil;
    }
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(layerMessageID==%@)",layerChatId];
    
    [request setPredicate:predicateObj];
    
    NSError *error = nil;
    
    NSArray *chatMessageArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    ChatMessage *chatMessageObj = nil;
    if (chatMessageArray && [chatMessageArray count]>0) {
        chatMessageObj = (ChatMessage *)[chatMessageArray objectAtIndex:0];
    }
    return chatMessageObj;
}

+(ChatMessage *)getMessageForChatRoom:(NSString *)chatRoomId ofMessageType:(int)messageType{
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(chatRoomID==%@)AND(messageType ==%@)", chatRoomId,[NSNumber numberWithInt:messageType]];
    
    [request setPredicate:predicateObj];
    
    NSError *error = nil;
    
    NSArray *chatMessageArray = [managedObjectContext executeFetchRequest:request error:&error];
    if (chatMessageArray && [chatMessageArray count]>0) {
        return [chatMessageArray firstObject];
    }
    return nil;
}


@end
