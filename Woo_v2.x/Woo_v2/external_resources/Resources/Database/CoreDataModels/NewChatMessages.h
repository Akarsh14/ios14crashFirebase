//
//  NewChatMessages.h
//  Woo
//
//  Created by Umesh Mishra on 07/08/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MyMatches.h"


@interface NewChatMessages : NSManagedObject

@property (nonatomic, retain) NSNumber * chatMessageCreatedTime;
@property (nonatomic, retain) NSString * chatRoomID;
@property (nonatomic, retain) NSNumber * clientMessageID;
@property (nonatomic, retain) NSNumber * isDelivered;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * messageReceiverID;
@property (nonatomic, retain) NSString * messageSenderID;
@property (nonatomic, retain) NSNumber * messageType;
@property (nonatomic, retain) NSNumber * serverMessageID;
@property (nonatomic, retain) NSNumber * chatID;

//
//
///**
// @author Umesh Mishra
// 
// It will inserts a single chat Message detail into database. It assumes that every data will be available in chatDetails dictionary.
// 
// 
// @param chatDetails of type NSDictionary, It will and should have all the details required to add a chat in the database.
// 
// */
//
//+(void)insertMessageIntoDatabase:(NSDictionary *)chatDetails;
//
///**
// @author Umesh Mishra
// 
// It will inserts multiple chat Message detail into database.
// 
// @param chatDetailArray of type NSArray, it is an array of chatMessage details dictionary.
// 
// */
//+(void)insertMessagesIntoDatabase:(NSArray *)chatDetailArray;
//
////+(void)deleteMessageFromDatabase:(NSDictionary *)chatDetails;
//
//
///**
// @author Umesh Mishra
// 
// This method will delete all the chat messages for a chat room.
// 
// 
// @param chatRoomID of type NSString, is the id of the chat room to whose messages needs to be deleted.
// 
// */
//+(void)deleteMessagesForChatRoom:(NSString *)chatRoomID;
//
///**
// @author Umesh Mishra
// 
// This method will returns all the chat messages.
// 
// @return NSArray of all the chats or return nil if no chat is available.
// 
// */
//+(NSArray *)getAllMessage;
//
///**
// @author Umesh Mishra
// 
// This method will returns all the chat messages for a chat room.
// 
// @return NSArray of all the chats or return nil if no chat is available for a chat room.
// 
// */
//+(NSArray *)getAllMessageForChatRoom:(NSString *)chatRoomID;
//
///**
// @author Umesh Mishra
// 
// It will return ChatMessage object if present, for the given chatMessageID
// 
// @param chatMessageID of type NSString, is the ID of the chat.
// 
// @return ChatMessage object if exists or returns nil
// 
// */
//
//+(ChatMessage *)getChatMessageWithChatMessageID:(NSNumber *)chatMessageID;
//+(ChatMessage *)getChatMessageWithServerMessageID:(NSNumber *)serverMessageId andClientID:(NSNumber *)clientID andMessageSenderID:(NSString *)messageSenderID andMessageReceiverID:(NSString *)messageReceiverID;
//
///**
// @author Umesh Mishra
// 
// This method will update the delivery status of the message to TRUE when it will be successfully delivered to server.
// 
// 
// @param chatMessageID of type NSString, is the ID of the chat message.
// 
// @param isDelivered of type BOOL, is the delivery status of the message. TRUE if delivered to server successfully, else FALSE.
// 
// **** This method will be used by Lokesh ****
// 
// */
//
//+(void)updateDeliveryStatusOfChatMessage:(NSString *)chatMessageID withDeliveryStatus:(BOOL)isDelivered andServerMessageID:(NSNumber *)serverMessageID withMsgDeliveryTime:(NSString *)msgServerCreatedTime;
//
////+(NSArray *)getAllUnreadMessage;
////+(NSArray *)getAllUnreadMessageForChatRoom:(NSString *)chatRoomID;
//
////get latest server id
//
///**
// @author Umesh Mishra
// 
// This method will retrun latest server id from DB.
// 
// @return NSString, is the latest serverID.
// 
// **** This method will be used by Lokesh ****
// 
// */
//+(NSNumber *)getLatestServerID;
///**
// @author Umesh Mishra
// 
// This method will all undelivered messges from DB.
// 
// @return NSArray, is the list of undelivered messges.
// 
// **** This method will be used by Lokesh ****
// 
// */
//+(NSArray *)getAllUndeliveredMessges;
///**
// @author Umesh Mishra
// 
// This method will returns number of chat messages for a chat room that are specified by chatLimit.
// 
// @return NSArray of all the chats or return nil if no chat is available for a chat room.
// 
// */
//+(NSArray *)getAllMessageForChatRoom:(NSString *)chatRoomID WithLimit:(NSInteger)chatLimit;
//
//+(NSArray *)getAllMessageForChatRoom:(NSString *)chatRoomID WithIndex:(NSInteger)currentIndex;
//+(BOOL)isMoreDataAvailableForChatRoom:(NSString *)chatRoomID WithIndex:(NSInteger)currentIndex;
//+(ChatMessage *)getLastMessageForChatRoom:(NSString *)chatRoomID;
//
//+(void)updateCrationTimeOfIntroMessageForChatRoom:(NSString *)chatRoomID;
//
//+(long long)getTheMaximumCreatedTimeForAChatRoom:(NSString *)chatRoomID;
//
//+(NSArray *)getAllMessageForChatRoomAfterChat:(ChatMessage *)chatObj forChatRoom:(NSString *)chatRoomID;
//
@end
