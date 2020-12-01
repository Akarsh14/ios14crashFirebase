//
//  ChatRoom.m
//  Woo
//
//  Created by Umesh Mishra on 30/04/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "ChatRoom.h"
#import "Store.h"
#import "ChatMessage.h"
#import "MyMatches.h"


#define BOOST @"BOOST"
#define CRUSH @"CRUSH"

@implementation ChatRoom

@dynamic chatRoomID;
@dynamic otherUserImageURL;
@dynamic otherUserName;
//@dynamic otherUserID;
@dynamic chatSnippet;
@dynamic chatSnippetTime;
@dynamic isRead;
//@dynamic myMatchID;
@dynamic chatRoomCreationTime;
@dynamic isChatSided;
@dynamic isDel;
@dynamic source;
@dynamic expiryTime;
@dynamic isFav;

//
//
////+(void)createChatRoomForChatRoomID:(NSString *)chatRoomID{
////
////    
////}
//
//+(void)createChatRoomForMyMatch:(MyMatches *)myMatchObj{
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsUserBlacklisted]) {
//        return;
//    }
//    NSManagedObjectContext *privateContext = [STORE newPrivateContext];
//    
//    if (myMatchObj && [myMatchObj.matchId length]>0) {
//        
//        ChatRoom *chatRoomObj = [self getChatRoomForChatRoomID:myMatchObj.matchedUserId];
//        if (!chatRoomObj) {
//            chatRoomObj = (ChatRoom *)[NSEntityDescription insertNewObjectForEntityForName:@"ChatRoom" inManagedObjectContext:privateContext ];
//            //        $$$$$$$ UMESH CHAT ROOM ME ENTRY DAAL LE
//            
//            
//            NSLog(@">>>>> %f",[NSDate timeIntervalSinceReferenceDate]);
//            NSString *chatSnippetString = @"";
//            
//            [ChatMessage insertMessageIntoDatabase:[[NSDictionary alloc]initWithObjectsAndKeys:
//                                                    [NSNumber numberWithInt:INTRODUCTION],kMessageTypeKey,
//                                                    myMatchObj.matchedUserId,kChatRoomIDKey,
//                                                    [NSString stringWithFormat:@"%lld",[kOldTimeStamp longLongValue]],kChatMessageCreatedTime,
//                                                    nil]];
////                                                     kMessageTypeKey:[NSNumber numberWithInt:INTRODUCTION],
////                                                     kChatRoomIDKey:myMatchObj.matchedUserId,
////                                                     kChatMessageCreatedTime :[NSString stringWithFormat:@"%lld",[kOldTimeStamp longLongValue]]
////                                                     }];
//            
//            if ([myMatchObj.source isEqualToString:CRUSH] || [myMatchObj.source isEqualToString:BOOST]) {
//                [ChatMessage insertMessageIntoDatabase:[[NSDictionary alloc]initWithObjectsAndKeys:
//                                                        [NSNumber numberWithInt:MATCHED_THROUGH_CELL],kMessageTypeKey,
//                                                          myMatchObj.matchedUserId,kChatRoomIDKey,
//                                                          [NSString stringWithFormat:@"%lld",([kOldTimeStamp longLongValue]+1000)],kChatMessageCreatedTime,
//                                                          nil]];
////                                                         @{kMessageTypeKey:[NSNumber numberWithInt:MATCHED_THROUGH_CELL],
////                                                         kChatRoomIDKey:myMatchObj.matchedUserId,
////                                                         kChatMessageCreatedTime :[NSString stringWithFormat:@"%lld",([kOldTimeStamp longLongValue]+1000)]
////                                                         }];
//            }
//            
//            if (myMatchObj.matchedQuestion && [APP_Utilities validString:myMatchObj.matchedQuestion] > 0) {
//                if ([APP_Utilities isGenderMale:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserGender]]) {
//                    [ChatMessage insertMessageIntoDatabase:[[NSDictionary alloc]initWithObjectsAndKeys:
//                                                            [NSNumber numberWithInt:QUESTION],kMessageTypeKey,
//                                                            myMatchObj.matchedUserId,kChatRoomIDKey,
//                                                            [NSString stringWithFormat:@"%lld",([kOldTimeStamp_Question longLongValue])],kChatMessageCreatedTime,
//                                                            myMatchObj.matchedUserId,kMessageSenderIDKey,
//                                                            [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],kMessageReceiverID,
//                                                            myMatchObj.matchedQuestion,kMessageKey,
//                                                            nil]];
//                                                            
////                                                            @{
////                                                             kMessageTypeKey:[NSNumber numberWithInt:QUESTION],
////                                                             kChatRoomIDKey:myMatchObj.matchedUserId,
////                                                             kChatMessageCreatedTime :[NSString stringWithFormat:@"%lld",([kOldTimeStamp_Question longLongValue])],
////                                                             kMessageSenderIDKey : myMatchObj.matchedUserId,
////                                                             kMessageReceiverID : [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],
////                                                             kMessageKey : myMatchObj.matchedQuestion
////                                                             }];
//                }
//                else{
//                    [ChatMessage insertMessageIntoDatabase: [[NSDictionary alloc]initWithObjectsAndKeys:
//                                                             [NSNumber numberWithInt:QUESTION],kMessageTypeKey,
//                                                             myMatchObj.matchedUserId,kChatRoomIDKey,
//                                                             [NSString stringWithFormat:@"%lld",([kOldTimeStamp_Question longLongValue])],kChatMessageCreatedTime,
//                                                             myMatchObj.matchedUserId,kMessageReceiverID,
//                                                             [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],kMessageSenderIDKey,
//                                                             myMatchObj.matchedQuestion,kMessageKey,
//                                                             nil]];
////                                                            @{
////                                                             kMessageTypeKey:[NSNumber numberWithInt:QUESTION],
////                                                             kChatRoomIDKey:myMatchObj.matchedUserId,
////                                                             kChatMessageCreatedTime :[NSString stringWithFormat:@"%lld",([kOldTimeStamp_Question longLongValue])],
////                                                             kMessageReceiverID : myMatchObj.matchedUserId,
////                                                             kMessageSenderIDKey : [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],
////                                                             kMessageKey : myMatchObj.matchedQuestion
////                                                             }];
//                }
//            }
//            
//            if (myMatchObj.matchedAnswer && [APP_Utilities validString:myMatchObj.matchedAnswer] > 0) {
//                chatSnippetString = myMatchObj.matchedAnswer;
//                if ([APP_Utilities isGenderMale:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserGender]]) {
//                    [ChatMessage insertMessageIntoDatabase:[[NSDictionary alloc]initWithObjectsAndKeys:
//                                                            [NSNumber numberWithInt:ANSWER],kMessageTypeKey,
//                                                            myMatchObj.matchedUserId,kChatRoomIDKey,
//                                                            [NSString stringWithFormat:@"%lld",([kOldTimeStamp_Answer longLongValue])],kChatMessageCreatedTime,
//                                                            myMatchObj.matchedUserId,kMessageReceiverID,
//                                                            [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],kMessageSenderIDKey,
//                                                            myMatchObj.matchedAnswer,kMessageKey,
//                                                            nil]];
////                                                            @{
////                                                             kMessageTypeKey:[NSNumber numberWithInt:ANSWER],
////                                                             kChatRoomIDKey:myMatchObj.matchedUserId,
////                                                             kChatMessageCreatedTime :[NSString stringWithFormat:@"%lld",([kOldTimeStamp_Answer longLongValue])],
////                                                             kMessageReceiverID : myMatchObj.matchedUserId,
////                                                             kMessageSenderIDKey : [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],
////                                                             kMessageKey : myMatchObj.matchedAnswer
////                                                             }];
//                }
//                else{
//                    [ChatMessage insertMessageIntoDatabase:[[NSDictionary alloc]initWithObjectsAndKeys:
//                                                            [NSNumber numberWithInt:ANSWER],kMessageTypeKey,
//                                                            myMatchObj.matchedUserId,kChatRoomIDKey,
//                                                            [NSString stringWithFormat:@"%lld",([kOldTimeStamp_Answer longLongValue])],kChatMessageCreatedTime,
//                                                            myMatchObj.matchedUserId,kMessageSenderIDKey,
//                                                            [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],kMessageReceiverID,
//                                                            myMatchObj.matchedAnswer,kMessageKey,
//                                                            nil]];
////                                                        @{
////                                                             kMessageTypeKey:[NSNumber numberWithInt:ANSWER],
////                                                             kChatRoomIDKey:myMatchObj.matchedUserId,
////                                                             kChatMessageCreatedTime :[NSString stringWithFormat:@"%lld",([kOldTimeStamp_Answer longLongValue])],
////                                                             kMessageSenderIDKey : myMatchObj.matchedUserId,
////                                                             kMessageReceiverID : [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],
////                                                             kMessageKey : myMatchObj.matchedAnswer
////                                                             }];
//                }
//            }
//            NSDateFormatter *dateFormatFromServer = [[NSDateFormatter alloc]init];
//            [dateFormatFromServer setDateFormat:@"dd/MM/yyyy"];
//            
//            NSDate *localDate = myMatchObj.matchedOn;
//            
//            NSString *dateString = [NSString stringWithFormat:NSLocalizedString(@"Matched on: %@",nil),[dateFormatFromServer stringFromDate:localDate]];
//            [chatRoomObj setChatSnippet:dateString];
//            
//            [chatRoomObj setChatRoomCreationTime:myMatchObj.matchedOn];
//            
//            
//            if ([chatSnippetString length]>0) {
//                [chatRoomObj setChatSnippet:chatSnippetString];
//            }
//            
//            
//            if ([[NSUserDefaults standardUserDefaults] objectForKey:kHasFetchedMatchesAlready]) {
//                [chatRoomObj setIsRead:[NSNumber numberWithInt:0]];
//            }else{
//                [chatRoomObj setIsRead:[NSNumber numberWithInt:1]];
//            }
//            
//            [chatRoomObj setChatSnippetTime:myMatchObj.matchedOn];
//            [chatRoomObj setChatRoomID:myMatchObj.matchedUserId];   //changes to matchedUserId after discussing Lokesh
//            
//            [chatRoomObj setOtherUserName:myMatchObj.matchUserName];
//            [chatRoomObj setOtherUserImageURL:myMatchObj.matchUserPic];
//            [chatRoomObj setIsFav:myMatchObj.isFav];
//            
//            [chatRoomObj setSource:myMatchObj.source];
//            
//            if ([myMatchObj.isDel boolValue] == TRUE)
//                [chatRoomObj setIsDel:[NSNumber numberWithBool:YES]];
//            else
//                [chatRoomObj setIsDel:[NSNumber numberWithBool:NO]];
//            
//            // Adding Expiry Time
//            if  ([[APP_Utilities validString:[NSString stringWithFormat:@"%@",myMatchObj.expiryTime]] length]>0)
//                [chatRoomObj setExpiryTime:myMatchObj.expiryTime];
//        }else{ // For updating ChatRoom Obj
//            
//            if ([myMatchObj.isDel boolValue] == TRUE)
//                [chatRoomObj setIsDel:[NSNumber numberWithBool:YES]];
//            else
//                [chatRoomObj setIsDel:[NSNumber numberWithBool:NO]];
//        }
//        
////        [chatRoomObj setMyMatchID:myMatchObj.matchId];
//        
//        
//    }
//    [STORE savePrivateContext];
//    [STORE saveContext];
//}
//
//
//+(void)updateChatSnippetForChatRoom:(NSString *)chatRoomID
//                    withChatSnippet:(NSString *)chatSnippet
//                          timeStamp:(NSDate *)chatTime
//                          andIsRead:(BOOL)isRead
//                          andSource:(NSString*)source{
//    
//    NSString *chatRoomIdString = [NSString stringWithFormat:@"%lld",[chatRoomID longLongValue]];
//    if (chatRoomIdString && [chatRoomIdString length]>0) {
//        ChatRoom *chatRoomObj = [self getChatRoomForChatRoomID:chatRoomIdString];
//        ChatMessage *chatMessageObj = [ChatMessage getLastMessageForChatRoom:chatRoomIdString];
//        if (chatRoomObj) {
//            if (chatMessageObj) {
//                
//                if (([chatMessageObj.messageType intValue] == INTRODUCTION)) {
//                    NSLog(@"do nothing");
//                }
//                else{
//                    if (([chatMessageObj.messageType intValue] == TEXT)  || ([chatMessageObj.messageType intValue] == QUESTION) || ([chatMessageObj.messageType intValue] == ANSWER)) {
//                        [chatRoomObj setChatSnippet:chatMessageObj.message];
//                    }
//                    else if ([chatMessageObj.messageType intValue] == IMAGE_SEND_BY_USER){
//                        [chatRoomObj setChatSnippet:@"Image"];
//                    }
//                    else if ([chatMessageObj.messageType intValue] == IMAGE){
//                        [chatRoomObj setChatSnippet:@"Sticker"];
//                    }
//                    //                [chatRoomObj setChatSnippet:chatMessageObj.message];
//                    
//                }
//                [chatRoomObj setChatSnippetTime:[NSDate dateWithTimeIntervalSince1970:([chatMessageObj.chatMessageCreatedTime longLongValue]/1000)]];
//                [chatRoomObj setIsRead:[NSNumber numberWithBool:isRead]];
//                
//            }
//            else{
//                [chatRoomObj setChatSnippet:chatSnippet];
//                [chatRoomObj setChatSnippetTime:chatTime];
//                [chatRoomObj setIsRead:[NSNumber numberWithBool:isRead]];
//            }
//            
//            if (source) {
//                [chatRoomObj setSource:source];
//            }
//            else{
//                [chatRoomObj setSource:@""];
//            }
//            
//            //NSString *notificationString;
//            if ([chatMessageObj.messageType intValue] == IMAGE) {
//             //   notificationString = [NSString stringWithFormat:@"%@: Sticker",chatRoomObj.otherUserName];
//            }
//            else if ([chatMessageObj.messageType intValue] == IMAGE_SEND_BY_USER){
//              //  notificationString = [NSString stringWithFormat:@"%@: Image",chatRoomObj.otherUserName];
//            }
//            else{
//              //  notificationString = [NSString stringWithFormat:@"%@: %@",chatRoomObj.otherUserName, chatRoomObj.chatSnippet];
//            }
//            [[NSNotificationCenter defaultCenter] postNotificationName:kChatRoomChatSnippetUpdated object:nil];
//        }
//    }
//    
//    [STORE savePrivateContext];
//    [STORE saveContext];
//}
//
////+(void)updateChatSnippetForMyMatch:(NSString *)myMatchID withChatSnippet:(NSString *)chatSnippet timeStamp:(NSDate *)chatTime andIsRead:(BOOL)isRead{
////    if (myMatchID && [myMatchID length]>0) {
////        ChatRoom *chatRoomObj = [self getChatRoomForMyMatch:myMatchID];
////        if (chatRoomObj) {
////            [chatRoomObj setChatSnippet:chatSnippet];
////            [chatRoomObj setChatSnippetTime:chatTime];
////            [chatRoomObj setIsRead:[NSNumber numberWithBool:isRead]];
////        }
////    }
////    
////    [STORE savePrivateContext];
////    [STORE saveContext];
////}
//
//+(void)deleteChatRoomWithChatRoomID:(NSString *)chatRoomID{
//    NSManagedObjectContext *privateContext = [STORE newPrivateContext];
//    if (chatRoomID && [chatRoomID length]>0) {
//        ChatRoom *chatRoomObj = [self getChatRoomForChatRoomID:chatRoomID];
//        if (chatRoomObj) {
//            [privateContext deleteObject:chatRoomObj];
//            [ChatMessage deleteMessagesForChatRoom:chatRoomObj.chatRoomID];
//        }
//    }
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:kChatRoomDeleted object:chatRoomID];
//    [[NSNotificationCenter defaultCenter] postNotificationName:kChatCellTapped object:nil];
//    [STORE savePrivateContext];
//    [STORE saveContext];
//}
//
//
////+(void)deleteChatRoomForMyMatchID:(NSString *)myMatchID{
////    NSManagedObjectContext *privateContext = [STORE newPrivateContext];
////    if (myMatchID && [myMatchID length]>0) {
////        ChatRoom *chatRoomObj = [self getChatRoomForMyMatch:myMatchID];
////        if (chatRoomObj) {
////            
////            
////            [ChatMessage deleteMessagesForChatRoom:chatRoomObj.chatRoomID];
////            [privateContext deleteObject:chatRoomObj];
////        }
////    }
////    
////    [STORE savePrivateContext];
////    [STORE saveContext];
////}
//
//+(NSArray *)getAllFavChatRoom{
//    NSManagedObjectContext *managedObjectContext = [APP_DELEGATE.store newPrivateContext];
//    
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatRoom" inManagedObjectContext:managedObjectContext];
//    
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    
//    [request setEntity:entityDescription];
//    NSError *error = nil;
//    
//    
//    // code for sorting starts here
//    NSSortDescriptor *dateSortingDescriptior = [[NSSortDescriptor alloc]initWithKey:@"chatSnippetTime" ascending:NO];
//    
//    NSArray *sortDescriptorArray = [NSArray arrayWithObjects:dateSortingDescriptior, nil];
//    
//    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(isFav==%@)", [NSNumber numberWithBool:YES]];
//
//    [request setPredicate:predicateObj];
//    
//    [request setSortDescriptors:sortDescriptorArray];
//    // code for sorting ends here
//    
//    NSArray *chatRoomArray = [managedObjectContext executeFetchRequest:request error:&error];
//    
//    
//    if (chatRoomArray && [chatRoomArray count]>0) {
//        return chatRoomArray;
//    }
//    return nil;
//}
//
//
//
//+(NSArray *)getAllChatRoom{
//    NSManagedObjectContext *managedObjectContext = [APP_DELEGATE.store newPrivateContext];
//    
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatRoom" inManagedObjectContext:managedObjectContext];
//    
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    
//    [request setEntity:entityDescription];
//    NSError *error = nil;
//    
//    
//    // code for sorting starts here
//    NSSortDescriptor *dateSortingDescriptior = [[NSSortDescriptor alloc]initWithKey:@"chatSnippetTime" ascending:NO];
//    
//    NSArray *sortDescriptorArray = [NSArray arrayWithObjects:dateSortingDescriptior, nil];
//    [request setSortDescriptors:sortDescriptorArray];
//    // code for sorting ends here
//    
//    NSArray *chatRoomArray = [managedObjectContext executeFetchRequest:request error:&error];
//    
//    
//    if (chatRoomArray && [chatRoomArray count]>0) {
//        return chatRoomArray;
//    }
//    return nil;
//}
//
//+(NSArray *)getAllUnreadMessage{
//    
//    NSManagedObjectContext *managedObjectContext = [APP_DELEGATE.store newPrivateContext];
//    
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatRoom" inManagedObjectContext:managedObjectContext];
//    
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    
//    [request setEntity:entityDescription];
//    
//    
//    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(isRead==%@)", [NSNumber numberWithBool:FALSE]];
//    
//    [request setPredicate:predicateObj];
//    
//    NSError *error = nil;
//    
//    NSArray *chatRoomArray = [managedObjectContext executeFetchRequest:request error:&error];
//    
//    if (chatRoomArray && [chatRoomArray count]>0) {
//        return chatRoomArray;
//    }
//    return nil;
//}
//
//+(int )getCountOfUnreadChatrooms{
//    return [[self getAllUnreadMessage] count];
//}
//
////+(ChatRoom *)getChatRoomForOtherUser:(NSString *)otherUserID{
////    NSManagedObjectContext *managedObjectContext = [APP_DELEGATE.store newPrivateContext];
////    
////    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatRoom" inManagedObjectContext:managedObjectContext];
////    
////    NSFetchRequest *request = [[NSFetchRequest alloc] init];
////    
////    [request setEntity:entityDescription];
////    
////    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(otherUserID==%@)", otherUserID];
////    
////    [request setPredicate:predicateObj];
////    
////    NSError *error = nil;
////    
////    NSArray *chatRoomArray = [managedObjectContext executeFetchRequest:request error:&error];
////    
////    ChatRoom *chatRoomObj = nil;
////    if (chatRoomArray && [chatRoomArray count]>0) {
////        chatRoomObj = (ChatRoom *)[chatRoomArray objectAtIndex:0];
////    }
////    return chatRoomObj;
////}
//
//+(ChatRoom *)getChatRoomForChatRoomID:(NSString *)chatRoomID{
//    NSManagedObjectContext *managedObjectContext = [APP_DELEGATE.store newPrivateContext];
//    
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatRoom" inManagedObjectContext:managedObjectContext];
//    
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    
//    [request setEntity:entityDescription];
//    
//    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(chatRoomID==%@)", chatRoomID];
//    
//    [request setPredicate:predicateObj];
//    
//    NSError *error = nil;
//    
//    NSArray *chatRoomArray = [managedObjectContext executeFetchRequest:request error:&error];
//    
//    ChatRoom *chatRoomObj = nil;
//    if (chatRoomArray && [chatRoomArray count]>0) {
//        chatRoomObj = (ChatRoom *)[chatRoomArray objectAtIndex:0];
//    }
//    return chatRoomObj;
//}
//
////+(ChatRoom *)getChatRoomForMyMatch:(NSString *)myMatchID{
////    NSManagedObjectContext *managedObjectContext = [APP_DELEGATE.store newPrivateContext];
////    
////    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatRoom" inManagedObjectContext:managedObjectContext];
////    
////    NSFetchRequest *request = [[NSFetchRequest alloc] init];
////    
////    [request setEntity:entityDescription];
////    
////    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(myMatchID==%@)", myMatchID];
////    
////    [request setPredicate:predicateObj];
////    
////    NSError *error = nil;
////    
////    NSArray *chatRoomArray = [managedObjectContext executeFetchRequest:request error:&error];
////    
////    ChatRoom *chatRoomObj = nil;
////    if (chatRoomArray && [chatRoomArray count]>0) {
////        chatRoomObj = (ChatRoom *)[chatRoomArray objectAtIndex:0];
////    }
////    return chatRoomObj;
////}
//
//
//+(void)updateChatSnippetForAllChatRooms{
//    NSArray *chatRoomArray = [self getAllChatRoom];
//    
//    for (ChatRoom *chatRoomObj in chatRoomArray) {
//        ChatMessage *chatMessageObj = [ChatMessage getLastMessageForChatRoom:chatRoomObj.chatRoomID];
//        if (chatMessageObj) {
//            if (chatMessageObj) {
//               // NSString *chatSnippetText = nil;
//                if ([chatMessageObj.messageType intValue] == TEXT) {
//                  //  chatSnippetText = chatMessageObj.message;
//                }
//                else if ([chatMessageObj.messageType intValue] == IMAGE){
//                  //  chatSnippetText = @"Sticker";
//                }
//                else{
//                 //   chatSnippetText = chatMessageObj.message;;
//                }
//               // float timeInSeconds = ([chatMessageObj.chatMessageCreatedTime longLongValue]/1000);
//               // NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInSeconds];
////                if ([chatSnippetText length]>0) {
////                    if ([APP_DELEGATE.currentActiveChatRoomId isEqualToString:chatRoomObj.chatRoomID]) {
////                        [self updateChatSnippetForChatRoom:chatRoomObj.chatRoomID withChatSnippet:chatSnippetText timeStamp:date andIsRead:TRUE];
////                    }
////                    else{
////                        [self updateChatSnippetForChatRoom:chatRoomObj.chatRoomID withChatSnippet:chatSnippetText timeStamp:date andIsRead:FALSE];
////                    }
////                }
//                
//            }
//        }
//    }
//}
//
//+(void)updateChatSnippetForChatRoomID:(NSString *)chatRoomID{
////
////    
////    NSLog(@"in >>>>> updateChatSnippetForChatRoomID-ChatRoomID");
////        ChatMessage *chatMessageObj = [ChatMessage getLastMessageForChatRoom:chatRoomID];
////        if (chatMessageObj) {
////            if (chatMessageObj) {
////               // NSString *chatSnippetText = nil;
////                if ([chatMessageObj.messageType intValue] == TEXT) {
////                   // chatSnippetText = chatMessageObj.message;
////                }
////                else if ([chatMessageObj.messageType intValue] == IMAGE){
////                   // chatSnippetText = @"Sticker";
////                }
////                else{
////                   // chatSnippetText = chatMessageObj.message;;
////                }
////              //  double timeInSeconds = ([chatMessageObj.chatMessageCreatedTime longLongValue]/1000.0);
//////                if ([chatSnippetText length]>0) {
//////                    if ([APP_DELEGATE.currentActiveChatRoomId isEqualToString:chatRoomID]) {
//////                        [self updateChatSnippetForChatRoom:chatRoomID withChatSnippet:chatSnippetText timeStamp:date andIsRead:TRUE];
//////                    }
//////                    else{
//////                        [self updateChatSnippetForChatRoom:chatRoomID withChatSnippet:chatSnippetText timeStamp:date andIsRead:FALSE];
//////                    }
//////                }
////                
////            }
////        }
//
//}
//
//
//+(void)deleteAllChatRooms{
//    NSManagedObjectContext *managedObj = [STORE newPrivateContext];
//    
//    NSArray *allChatRooms = [self getAllChatRoom];
//    
//    if (allChatRooms && [allChatRooms count]>0) {
//        for (ChatRoom *chatroomObj in allChatRooms) {
//            [managedObj deleteObject:chatroomObj];
//        }
//    }
//    [STORE savePrivateContext];
//    [STORE saveContext];
//}
//
//+(void)updateMatchedUserDetailsForMatchedUserID:(NSString *)userID withName:(NSString *)userName andProfilePic:(NSString *)profileURL
//{
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsUserBlacklisted]) {
//        return;
//    }
//    if (userID && [userID length]<1) {
//        return;
//    }
////    NSManagedObjectContext *privateContext = [STORE newPrivateContext];
//    ChatRoom *chatRoomObj = [self getChatRoomForChatRoomID:userID];
//    
//    if (!chatRoomObj) {
//        return;
//    }
//    
//    if (userName && [userName length]>1 && ![userName isEqualToString:@"(null)"]) {
//        [chatRoomObj setOtherUserName:userName];
//    }
//    if (profileURL && [profileURL length]>1 && ![profileURL isEqualToString:@"(null)"]) {
//        [chatRoomObj setOtherUserImageURL:profileURL];
//    }
//    
//    
//    // Removed by Lokesh - It was creating a chat room on the basis of my matched Id
//    //          [ChatRoom createChatRoomForMyMatch:matchedUser];
//    
//    [STORE savePrivateContext];
//    [STORE saveContext];
//}
//
//+(void)resetChatSnippetOfChatRoom:(NSString *)chatRoomID{
//    
//    MyMatches *matchObj = [MyMatches getMatchDetailForMatchedUSerID:chatRoomID];
//    ChatRoom *chatRoomObj = [self getChatRoomForChatRoomID:chatRoomID];
//    if (chatRoomObj) {
//        NSDate *localDate = matchObj.matchedOn;
//        
//        NSDateFormatter *dateFormatFromServer = [[NSDateFormatter alloc]init];
//        [dateFormatFromServer setDateFormat:@"dd/MM/yyyy"];
//        
//        NSString *dateString = [NSString stringWithFormat:NSLocalizedString(@"Matched on: %@",nil),[dateFormatFromServer stringFromDate:localDate]];
//        [chatRoomObj setChatSnippet:dateString];
////        [chatRoomObj setChatSnippetTime:nil];
//    }
//    [STORE savePrivateContext];
//    [STORE saveContext];
//    
//}
//
//+(void)changeFavStatusOfChatRoomForChatRoomID:(NSString *)chatRoomID{
//    
//    ChatRoom *chatRoomObj = [self getChatRoomForChatRoomID:chatRoomID];
//    
//    if (!chatRoomObj) {
//        return;
//    }
//    
//    MyMatches *matchObj = [MyMatches getMatchDetailForMatchedUSerID:chatRoomID];
//    
//    if ([chatRoomObj.isFav boolValue] == YES) {
//        chatRoomObj.isFav = [NSNumber numberWithBool:NO];
//        [APP_Utilities updatePendingUnFavListWithMatchID:matchObj.matchId];
//    }else{
//        chatRoomObj.isFav = [NSNumber numberWithBool:YES];
//        [APP_Utilities updatePendingFavListWithMatchID:matchObj.matchId];
//    }
//    
//    [STORE savePrivateContext];
//    [STORE saveContext];
//    
//}
//
//+(void)checkIfChatRoomExistsForIncomingMessage:(LYRMessage *)messageObj withCompletionBlock:(void(^)(BOOL chatRoomExists))completionBlock{
//    BOOL chatRoomExist = FALSE;
//    if (messageObj && ([messageObj.conversation.participants count] > 1)) {
//        NSString *chatRoomID;
//        for (LYRIdentity *userInfo in messageObj.conversation.participants) {
//            if (![userInfo.userID isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]]) {
//                chatRoomID = userInfo.userID;
//                break;
//            }
//        }
//        if ([self getChatRoomForChatRoomID:chatRoomID]) {
//            chatRoomExist = TRUE;
//        }
//    }
//    completionBlock(chatRoomExist);
//}

@end
