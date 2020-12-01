//
//  ChatRoom.h
//  Woo
//
//  Created by Umesh Mishra on 30/04/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MyMatches.h"


@interface ChatRoom : NSManagedObject

@property(nonatomic, strong)NSDate     * expiryTime;
@property (nonatomic, retain) NSString * chatRoomID;        // it will be the other person ID
@property (nonatomic, retain) NSString * otherUserImageURL;
@property (nonatomic, retain) NSString * otherUserName;
//@property (nonatomic, retain) NSString * otherUserID;       //
@property (nonatomic, retain) NSString * chatSnippet;
@property (nonatomic, retain) NSDate * chatSnippetTime;
@property (nonatomic, retain) NSNumber * isRead;
//@property (nonatomic, retain) NSString * myMatchID;     //
@property (nonatomic, retain) NSDate * chatRoomCreationTime;
@property (nonatomic, retain) NSNumber * isFav;
@property (nonatomic, retain) NSString * source;
//+(void)createChatRoomForChatRoomID:(NSString *)chatRoomID;

@property (nonatomic, retain) NSNumber * isChatSided;
@property(nonatomic, retain) NSNumber *isDel;

//
//
///**
// @author Umesh Mishra
// 
// It will create a chat room for myMatch.
// 
// @param myMatchObj of type MyMatches, it will contain the values needed for a chat room like ohter user's info and myMatch Id that will be required to create a chat room.
// 
// 
// */
//
//+(void)createChatRoomForMyMatch:(MyMatches *)myMatchObj;
//
///**
// @author Umesh Mishra
// 
// It will update the chat snippet for a chat room.
// 
// @param chatRoomID of type NSString, is the ID of the chatRoom.
// 
// @param chatSnippet of type NSString, message that will be visible on chat room view.
// 
// @param chatTime of type NSDate, is the time when chat was created
// 
// @param isRead of type BOOL, tells whether the last chat is red of not.
// 
// 
// */
//
//+(void)updateChatSnippetForChatRoom:(NSString *)chatRoomID
//                    withChatSnippet:(NSString *)chatSnippet
//                          timeStamp:(NSDate *)chatTime
//                          andIsRead:(BOOL)isRead
//                          andSource:(NSString*)source;
//
/////**
//// @author Umesh Mishra
//// 
//// It will update the chat snippet for a chat room that is created for myMatch Id.
//// 
//// @param myMatchID of type NSString, is the ID of the MyMatch , it will be used to get the chat room object.
//// 
//// @param chatSnippet of type NSString, message that will be visible on chat room view.
//// 
//// @param chatTime of type NSDate, is the time when chat was created
//// 
//// @param isRead of type BOOL, tells whether the last chat is red of not.
//// 
//// */
////+(void)updateChatSnippetForMyMatch:(NSString *)myMatchID withChatSnippet:(NSString *)chatSnippet timeStamp:(NSDate *)chatTime andIsRead:(BOOL)isRead;
//
///**
// @author Umesh Mishra
// 
// This method will delete the chat room for the given ID.
// 
// @param chatRoomID of type NSString, is the ID of the chat room.
// 
// 
// */
//+(void)deleteChatRoomWithChatRoomID:(NSString *)chatRoomID;
//
/////**
//// @author Umesh Mishra
//// 
//// This method will delete the chat room for the given myMatchID.
//// 
//// @param myMatchID of type NSString, is the ID of the myMatch which is used to get the chat room object.
//// 
//// */
////+(void)deleteChatRoomForMyMatchID:(NSString *)myMatchID;
//
///**
// @author Umesh Mishra
// 
// This method will returns all the chat rooms.
// 
// @return NSArray, list of chat room.
// */
//
//+(NSArray *)getAllChatRoom;
//
///**
// @author Umesh Mishra
// 
// This method will returns all the chat rooms with unread message status.
// 
// @return NSArray, list of chat room having unread messages.
// 
// */
//
//
///**
// *  This method will return all the "Fav/starred" chat rooms
// *
// *  @return array of Fav/starred chat room
// */
//+(NSArray *)getAllFavChatRoom;
//
//+(NSArray *)getAllUnreadMessage;
//
/////**
//// @author Umesh Mishra
//// 
//// This method will return the chat room object for given user id.
//// 
//// @param otherUserID of type NSString, is the ID of the other user.
//// 
//// @return ChatRoom object if exists for the given otherUserID or returns nil
//// 
//// */
////+(ChatRoom *)getChatRoomForOtherUser:(NSString *)otherUserID;
//
//
///**
// *  This method will just return a simple number which will be the count of total number of chatroos with unread messages
// *
// *  @return total unread messages
// */
//+(int )getCountOfUnreadChatrooms;
//
///**
// @author Umesh Mishra
// 
// This method will return the chat room object for given chatRoomID.
// 
// @param chatRoomID of type NSString, is the ID of the chat room.
// 
// @return ChatRoom object if exists for the given chatRoomID or returns nil
// 
// */
//+(ChatRoom *)getChatRoomForChatRoomID:(NSString *)chatRoomID;
//
/////**
//// @author Umesh Mishra
//// 
//// This method will return the chat room object for given myMatchID.
//// 
//// @param myMatchID of type NSString, is the ID of the my mathes that will be used to get chat room.
//// 
//// @return ChatRoom object if exists for the given myMatchID or returns nil
//// 
//// */
////+(ChatRoom *)getChatRoomForMyMatch:(NSString *)myMatchID;
//
//+(void)updateChatSnippetForAllChatRooms;
//
//+(void)updateChatSnippetForChatRoomID:(NSString *)chatRoomID;
//
///**
// *  @author Umesh Mishra
//    This method will delete all the chat room for the user.
// */
//+(void)deleteAllChatRooms;
//
//+(void)updateMatchedUserDetailsForMatchedUserID:(NSString *)userID withName:(NSString *)userName andProfilePic:(NSString *)profileURL;
//
//+(void)resetChatSnippetOfChatRoom:(NSString *)chatRoomID;
//
//
///**
// *  @author Vaibhav Gautam
// *  This mehhod will toggle the Fav status of chat roomObj
// *
// *  @param chatRoomID chatroom object for which the fav status is to be toggled
// */
//+(void)changeFavStatusOfChatRoomForChatRoomID:(NSString *)chatRoomID;
//
//+(void)checkIfChatRoomExistsForIncomingMessage:(LYRMessage *)messageObj withCompletionBlock:(void(^)(BOOL chatRoomExists))completionBlock;


@end
