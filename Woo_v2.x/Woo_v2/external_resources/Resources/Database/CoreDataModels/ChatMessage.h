//
//  ChatMessage.h
//  Woo
//
//  Created by Umesh Mishra on 30/04/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

//#import <LayerKit/LayerKit.h>
#import "MyMatches.h"

@interface ChatMessage : NSManagedObject


//Changed Name from chatMessageID>>clientMessageID and its dataType also to NSDate
@property (nonatomic, retain) NSNumber * clientMessageID;
@property (nonatomic, retain) NSString * chatRoomID;
@property (nonatomic, retain) NSNumber * messageType;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSNumber * isDelivered;
@property (nonatomic, retain) NSString * messageSenderID;
@property (nonatomic, retain) NSNumber * serverMessageID;        //sender's ID, it can be user or other user
@property (nonatomic, retain) NSString * messageReceiverID;         //reciver's ID, it can be user or other user
@property (nonatomic, retain) NSNumber *chatMessageCreatedTime;       //chat creation time

@property (nonatomic, retain) NSNumber *chatDeliveryStatus;            //Chat delivery ID which is used to give the status of the chat from layer
@property (nonatomic, retain) NSString *layerMessageID;                 //layer message Id which will be used to get messages from layer chat. 
@property (nonatomic, retain) NSNumber * ifchatImageIsItUploaded;

@property (nonatomic, retain) NSString * imageSize;

// Server ID

typedef void(^ChatInsertionCompletionHandler)(ChatMessage *chatMessageObj);

typedef void(^ChatUpdationCompletionHandler)(ChatMessage *chatMessageObj);

typedef void(^ChatDeletionCompletionHandler)(BOOL success);

typedef void(^ChatModificationCompletionHandler)(BOOL success);

/**
 @author Umesh Mishra
 
 It will inserts a single chat Message detail into database. It assumes that every data will be available in chatDetails dictionary.

 
 @param chatDetails of type NSDictionary, It will and should have all the details required to add a chat in the database.
 
 */

//+(ChatMessage *)insertMessageIntoDatabase:(NSDictionary *)chatDetails;// withInsertionCompletionBlock:(chatMessageInsertionCompletionBlock)chatInsertionCompletion;

+(void)insertNewChatMessageIntoDatabase:(NSDictionary *)chatDetails withCompletionHandler:(ChatInsertionCompletionHandler)completionHandler;
/**
 @author Umesh Mishra
 
 It will inserts multiple chat Message detail into database. 
 
 @param chatDetailArray of type NSArray, it is an array of chatMessage details dictionary.
 
 */
+(void)insertMessagesIntoDatabase:(NSArray *)chatDetailArray;

//+(void)deleteMessageFromDatabase:(NSDictionary *)chatDetails;


/**
 @author Umesh Mishra
 
 This method will delete all the chat messages for a chat room.

 
 @param chatRoomID of type NSString, is the id of the chat room to whose messages needs to be deleted.
 
 */
+(void)deleteMessagesForChatRoom:(NSString *)chatRoomID;

/**
 @author Umesh Mishra
 
 This method will returns all the chat messages.
 
@return NSArray of all the chats or return nil if no chat is available.
 
 */
+(NSArray *)getAllMessage;

/**
 @author Umesh Mishra
 
 This method will returns all the chat messages for a chat room.
 
 @return NSArray of all the chats or return nil if no chat is available for a chat room.
 
 */
+(NSArray *)getAllMessageForChatRoom:(NSString *)chatRoomID;

/**
 @author Umesh Mishra
 
 It will return ChatMessage object if present, for the given chatMessageID
 
 @param chatMessageID of type NSString, is the ID of the chat. 
 
 @return ChatMessage object if exists or returns nil
 
 */

+(ChatMessage *)getChatMessageWithChatMessageID:(NSNumber *)chatMessageID;
+(ChatMessage *)getChatMessageWithServerMessageID:(NSNumber *)serverMessageId andClientID:(NSNumber *)clientID andMessageSenderID:(NSString *)messageSenderID andMessageReceiverID:(NSString *)messageReceiverID;

/**
 @author Umesh Mishra
 
 This method will update the delivery status of the message to TRUE when it will be successfully delivered to server.
 
 
 @param chatMessageID of type NSString, is the ID of the chat message. 
 
 @param isDelivered of type BOOL, is the delivery status of the message. TRUE if delivered to server successfully, else FALSE.
 
 **** This method will be used by Lokesh ****
 
 */

+(void)updateDeliveryStatusOfChatMessage:(NSString *)chatMessageID withDeliveryStatus:(BOOL)isDelivered andServerMessageID:(NSNumber *)serverMessageID withMsgDeliveryTime:(NSString *)msgServerCreatedTime;

+(void)updateChatMessageObject:(ChatMessage *)chatMessageObject withStatus:(NSNumber *)messageStatus withUpdationHandler:(ChatUpdationCompletionHandler)completionHandler;

//+(NSArray *)getAllUnreadMessage;
//+(NSArray *)getAllUnreadMessageForChatRoom:(NSString *)chatRoomID;

//get latest server id

/**
 @author Umesh Mishra
 
 This method will retrun latest server id from DB.
 
 @return NSString, is the latest serverID.
 
 **** This method will be used by Lokesh ****
 
 */
+(NSNumber *)getLatestServerID;
/**
 @author Umesh Mishra
 
 This method will all undelivered messges from DB.
 
 @return NSArray, is the list of undelivered messges.
 
 **** This method will be used by Lokesh ****
 
 */
+(NSArray *)getAllUndeliveredMessges;
/**
 @author Umesh Mishra
 
 This method will returns number of chat messages for a chat room that are specified by chatLimit.
 
 @return NSArray of all the chats or return nil if no chat is available for a chat room.
 
 */
+(NSArray *)getAllMessageForChatRoom:(NSString *)chatRoomID WithLimit:(NSInteger)chatLimit;

+(NSArray *)getAllMessageForChatRoom:(NSString *)chatRoomID WithIndex:(NSInteger)currentIndex;
+(BOOL)isMoreDataAvailableForChatRoom:(NSString *)chatRoomID WithIndex:(NSInteger)currentIndex;
+(ChatMessage *)getLastMessageForChatRoom:(NSString *)chatRoomID;

+(void)updateCrationTimeOfIntroMessageForChatRoom:(NSString *)chatRoomID;

+(long long)getTheMaximumCreatedTimeForAChatRoom:(NSString *)chatRoomID;

+(NSArray *)getAllMessageForChatRoomAfterChat:(ChatMessage *)chatObj forChatRoom:(NSString *)chatRoomID;

+(NSArray *)getAllMessageForChatRoomAfterChat_New:(NSInteger )maxNumberOfChat forChatRoom:(NSString *)chatRoomID;


/**
 @author Umesh Mishra   
 This method will return all the message of a chat room except for the Introduction message. 
 @params : chatRoomId - of type NSSting, is the chat room Id of the chat room whose message are required
 @return : it returns an Array of chats if present otherwise returns nil
 */

+(NSArray *)getAllMessageForChatRoomExceptIntoductionMessage:(NSString *)chatRoomId;

/**
 *  @author Umesh Mishra
    @date   Oct 07, 2014
    This method will delete all the chat for all chat rooms.
 */

+(void)deleteAllChats;

+(void)deleteAllChatForChatRoomExceptIntroMessage:(NSString *)chatRoomID withCompletionHandler:(ChatDeletionCompletionHandler)completionHandler;;


//+(ChatMessage *)insertMessageIntoDatabaseFromLayer:(NSDictionary *)chatDetails andAlsoMarkChatRoomAsRead:(BOOL)shouldMakeChatRoomRead;
+(void)insertNewChatMessageIntoDatabaseFromLayer:(NSDictionary *)chatDetails forMatchDetail:(MyMatches *)matchDetail andAlsoMarkChatRoomAsRead:(BOOL)shouldMakeChatRoomRead  withCompletionHandler:(ChatInsertionCompletionHandler)completionHandler;
//+(void)insertNewImageMessageIntoDatabaseFromLayer:(NSDictionary *)chatDetails forMatchDetail:(MyMatches *)matchDetail andAlsoMarkChatRoomAsRead:(BOOL)shouldMakeChatRoomRead  withMimeType : (LYRMessagePart *)messagePart withCompletionHandler:(ChatInsertionCompletionHandler)completionHandler;

+(void)updateMessageIntoDatabaseFromLayer:(NSDictionary *)chatDetails andAlsoMarkChatRoomAsRead:(BOOL)shouldMakeChatRoomRead withUpdationHandler:(ChatUpdationCompletionHandler)completionHandler;

+(ChatMessage *)getChatMessageWithLayerMessage:(NSDictionary *)chatDetails;

+(ChatMessage *)getChatMessageWithClientID:(NSNumber *)clientID andMessageSenderID:(NSString *)messageSenderID andMessageReceiverID:(NSString *)messageReceiverID;


+(NSNumber *)getTheCreationTimeOfLastDeliveredMessageIfAnyForChatRoom:(NSString *)chatRoomID;

+(void)checkAndInsertIntroMessageForAChatRommIfDoesNotExist:(NSString *)chatRoomID;

+(void)updateDeliveryStatusOfImage:(NSNumber *)chatMessageId withChatMessage:(NSString *)imageUrl;

+(void)updateDeliveryStatusOfImage:(NSNumber *)chatMessageId withUpdationHandler:(ChatModificationCompletionHandler)completionHandler;

//+(ChatMessage *)insertImageMessageIntoDatabaseFromLayer:(NSDictionary *)chatDetails andAlsoMarkChatRoomAsRead:(BOOL)shouldMakeChatRoomRead  withMimeType : (LYRMessagePart *)messagePart;

+(void)updateImageSizeOfImageChat:(float)imageSize forChatId:(NSNumber *)chatMessageId withUpdationHandler:(ChatModificationCompletionHandler)completionHandler;

+(void)updateLayerIdOfChatMessageWithLayerId:(NSString *)layerId andDeliveryStatus:(NSNumber *)deliveryStatus forChatObject:(ChatMessage *)chatObj withUpdationHandler:(ChatUpdationCompletionHandler)completionHandler;

+(ChatMessage *)getChatMessageForLayerMessageId:(NSString *)layerChatId;

+(ChatMessage *)getIntroMessageForTheChatRoom:(NSString *)chatRoomId;

+(ChatMessage *)getMessageForChatRoom:(NSString *)chatRoomId ofMessageType:(int)messageType;
+(void)updateChatMessagesForChatRoomId:(NSString*)oldChatRoomId withNewChatRoomId:(NSString*)chatRoomId withUpdationHandler:(ChatModificationCompletionHandler)completionHandler;

@end
