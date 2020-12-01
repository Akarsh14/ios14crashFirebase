//
//  MyMatches.h
//  Woo
//
//  Created by Vaibhav Gautam on 07/04/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import <CoreData/CoreData.h>
//#import <LayerKit/LayerKit.h>

@interface MyMatches : NSManagedObject{
    
}

@property(nonatomic, strong)NSDate *matchedOn;
@property(nonatomic, strong)NSDate *expiryTime;
@property(nonatomic, strong)NSString *matchedUserId;
@property(nonatomic, strong)NSString *matchId;
@property(nonatomic, strong)NSString *matchIntroText;
@property(nonatomic, strong)NSString *matchOverlayText;
@property(nonatomic, strong)NSString *matchUserName;
@property(nonatomic, strong)NSString *matchUserPic;
@property(nonatomic, strong)  NSString *matchGender;
@property (nonatomic, retain) NSString * layerChatID;
@property (nonatomic, retain) NSData * layerConversationObject;
@property (nonatomic, retain) NSNumber * isMultiMediaMsgAllowed;
@property (nonatomic, retain) NSString * matchedAnswer;
@property (nonatomic, retain) NSString * matchedQuestion;
@property(nonatomic, retain)NSNumber *isFav;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSString * userLocation;
@property (nonatomic, retain) NSString *targetDeviceType;
@property (nonatomic, retain) NSString *targetAppLozicId;
@property (nonatomic, retain) NSString *chatServer;
@property(nonatomic, retain)NSNumber *isDel;

//Added these three properties from the chat room to remove chat room model.
@property (nonatomic, retain) NSString * chatSnippet;
@property (nonatomic, retain) NSDate * chatSnippetTime;
@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSString *chatSnippetUserId;


@property (nonatomic, retain)NSNumber *matchedUserStatus;
@property(nonatomic, retain)NSNumber *isTargetVoiceCallingEnabled;
@property(nonatomic,retain) NSString *agoraChannelKey;

//celebrity check
@property(nonatomic, retain)NSNumber *isTargetACelebrity;

//PFG
// isRequesterFlagged  will be parsed such that it will always contain info if i am flagged
//  isTargetFlagged  will be parsed such that it will always contain info if my match is flagged
@property(nonatomic, retain)NSNumber *isRequesterFlagged;
@property(nonatomic, retain)NSNumber *isTargetFlagged;
@property(nonatomic, retain)NSNumber *locked;

typedef void(^MatchChatSnippetInsertionCompletionBlock)(NSString *chatSnippet);

typedef void(^MatchedUserInsertionCompletionBlock)(BOOL insertionSuccess);
typedef void(^MatchedUserUpdationCompletionHandler)(BOOL isUpdationCompleted);
typedef void(^MatchUpdationCompletionHandler)(BOOL isUpdationCompleted,MyMatches *matchDetail);

typedef void(^MatchedUserDeletionCompletionHandler)(BOOL isUpdationCompleted);

+(MyMatches *)getIntroMessageForWooUserID:(NSString *)wooUserID;
+(void)insertDataInMyMatchesFromArray:(NSArray *)matchesArray withChatInsertionSuccess:(MatchedUserInsertionCompletionBlock)matchUserInsertionBlock;
+(MyMatches *)getMatchDetailForMatchID:(NSString *)matchID;
+(void)deleteMatchForMatchID:(NSString *)matchID;
+(NSMutableArray *)getAllMatches;
+(void)deleteMatchForMatchedUserId:(NSString *)matchedUserId withDeletionCompletionHandler:(MatchedUserDeletionCompletionHandler)updationCompletionHandler;
+(MyMatches *)getMatchDetailForMatchedUSerID:(NSString *)matchedUserId isApplozic:(BOOL)isApplozic;
//+(void)insertDataInMyMatchedFromUserProfile:(ProfileCardModel *)userProfileDetail;
/**
 @author Umesh Mishra
 @date Oct 07, 2014
 *  This method will delete all the matches of the user.
 */
+(void)deleteAllMatchesOfUser;

+(void)updateMatchedUserDetailsForMatchedUserID:(NSString *)userID withName:(NSString *)userName andProfilePic:(NSString *)profileURL withMatchUpdationSuccess:(MatchedUserUpdationCompletionHandler)matchUserInsertionBlock;

//+(void)updateMatchedUserDetailsWithConversationObject:(NSString *)userID withConversationObject:(LYRConversation *)conversationObject;

+(void)updateMatchedUserDetailsWithConversationIdentifier:(NSString *)userID withConversationIdentifier:(NSString*)conversationIdentifier andMultiMediaAllowedState:(BOOL)isMultiMediaAllowed;

//+(LYRConversation*)getConversationObjectForAMatchedUser:(NSString *)userID;

+(void)acknowledgeServerAfterAMatchIsInserted:(MyMatches *)matchObj;

+(MyMatches *)getMatchObjectForLayerConversationId:(NSString *)layerId;

+(void)updateMatchDetails:(MyMatches *)matchedUser withChatSnippet:(NSString*)chatSnippet withChatSnippetTime:(NSDate*)chatSnippetTime withChatUpdationSuccess:(MatchedUserUpdationCompletionHandler)matchUserInsertionBlock;
/**
 *  /
 
 */

+(NSArray *)getAllUnreadMessage;
+(void)resetChatSnippetOfChatRoom:(NSString *)chatRoomID withBackgroundCompletion:(MatchedUserInsertionCompletionBlock)completionBlock;
+(void)updateChatSnippetForChatRoom:(NSString *)chatRoomID  withChatSnippet:(NSString *)chatSnippet   forMatchDetail:(MyMatches *)matchUserObj  timeStamp:(NSDate *)chatTime  andIsRead:(BOOL)isRead andSource:(NSString*)source withBackgroundCompletion:(MatchUpdationCompletionHandler)completionBlock;
+(void)changeFavStatusOfChatRoomForChatRoomID:(NSString *)chatRoomID;
//+(void)checkIfChatRoomExistsForIncomingMessage:(LYRMessage *)messageObj withCompletionBlock:(void(^)(BOOL chatRoomExists))completionBlock;
+(void)checkIfChatRoomExistsForIncomingMessageFromApplozic:(NSString *)userID withCompletionBlock:(void(^)(BOOL chatRoomExists))completionBlock;
+(int )getCountOfUnreadChatrooms;
+(NSArray *)getAllFavChatRoom;
//+(void)updateChatSnippetForChatRoomID:(NSString *)chatRoomID;
/*+(void)createChatRoomForMyMatch:(MyMatches *)myMatchObj withInsertionCompletionBlock:(MatchChatSnippetInsertionCompletionBlock)matchChatSnippetInsertionCompletion;*/
+(void)createChatRoomForMyMatch:(MyMatches *)myMatchObj andWithresponseDict:(NSDictionary *)matchedRespopnse withInsertionCompletionBlock:(MatchChatSnippetInsertionCompletionBlock)matchChatSnippetInsertionCompletion;

//+(void)updateMatchedUserStatus:(int)currentStatus forChatRoomId:(NSString *)chatRoomId;
+(void)updateMatchedUserStatus:(int)currentStatus forChatRoomId:(NSString *)chatRoomId withUpdationCompletionHandler:(MatchedUserUpdationCompletionHandler)updationCompletionHandler;
+(NSMutableArray *)getAllPendingMatched;

+(void)updateMatchedUserDummyStatus:(NSString *)server forID:(NSString *)kdummyID forChatRoomId:(NSString *)chatRoomId withUpdationCompletionHandler:(MatchedUserUpdationCompletionHandler)updationCompletionHandler;

+(void)deleteAllFailedMatchedAfter2HoursWithDeletionCompletionHandler:(MatchedUserDeletionCompletionHandler)completionHandler;
//+(void)addDummyDataToTestDelete;
+(void)updateMatchedUserForIsDeletedWithMatchId:(NSString *)matchId;
+(void)updateMatchedUserDetailsForMatchedUserID:(NSString *)userID withAgoraChannelKey:(NSString *)channelKey withChatUpdationSuccess:(MatchedUserUpdationCompletionHandler)matchUserInsertionBlock;

+(MyMatches *)getMatchObjectForApplozicId:(NSString *)applozicId;
@end
