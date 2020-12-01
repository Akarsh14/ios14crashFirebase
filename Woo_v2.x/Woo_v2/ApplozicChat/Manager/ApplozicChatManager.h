//
//  ApplozicChatManager.h
//  Woo_v2
//
//  Created by Akhil Singh on 19/11/18.
//  Copyright © 2018 Woo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Applozic.h"

@protocol applozicInternalDelegates <NSObject>

-(void)updateAppLozicStatus:(ALMessage *)messageObj;

@end

typedef void (^ApplozicAuthSuccess) (BOOL authenticationSuccess, ApplozicClient *applozicClient);
typedef void (^ApplozicDeAuthSuccess)(BOOL deAuhtenticationSuccess);
typedef void (^ApplozicConnectionEstablished) (BOOL connectionEstablished);
typedef void (^ApplozicChatSend) (BOOL chatSendSuccessFully, ChatMessage* messageObj);
typedef void (^ApplozicDidChangeNotificationBlock)(ALMessage *alMessageObj, ChatMessage *messageObj);
typedef void(^SyncCompletionHandler)(BOOL isSyncCompleted, __nullable id conversation, NSError *error );

@interface ApplozicChatManager : NSObject{
    ApplozicAuthSuccess authBlock;
}

@property (nonatomic, weak) id <applozicInternalDelegates> delegate;

@property(nonatomic, copy) ApplozicConnectionEstablished connectionEstablishedBlock;
@property(nonatomic, copy) ApplozicDidChangeNotificationBlock didChangeNotificationBlock;
@property(nonatomic, retain) ApplozicClient *applozic;



+(ApplozicChatManager *)sharedApplozicChatManager;


-(void)blockUser:(NSString *)UserID;

-(void)unBlockUser:(NSString *)UserID;

/**
 *  Method to connect user from layer. This method will be called to check if user is connected with Layer or not. If connected the control will passed back using the block else Connection will be established and that block will be called
 *
 *  @param layerAuthSuccessBlock block that will be returned with values (True and layerClient object) when connection is successfully established with the layer server or values (False and nil) when connection is not established
 */
-(void)connectUserToApplozicWithClientObject:(ApplozicClient*)applozicClientObject withAppLozicAuthBlock:(ApplozicAuthSuccess)applozicAuthSuccessBlock;

/**
 *  Method to disconnect from the layer server
 *
 *  @param layerDeAuthSuccessBlock block that will be returned with value (True) when connection is successfully disconnected from the layer server or value (False) when connection is not disconnected
 */
-(void)disconnectFromApplozic:(ApplozicDeAuthSuccess)applozicDeAuthSuccessBlock;

/**
 * Method to check if user connected to layer or not. If user is connected the calling class/method will be notified by the block object else user will be connected to layer.
 *
 *  @param layerConnectionEstablishedBlock layerConnectionEstablishedBlock block that will return value(True) if connection is established.
 */
-(void)isUserConnectedToApplozic:(ApplozicConnectionEstablished)applozicConnectionEstablishedBlock;

/**
 *  Method to send message to layer. Message can be text, imageUrl, or stickerName(now not user).
 *
 *  @param chatStr              Chat message string that will be send
 *  @param mimeType             mime type :  it describes whether the message is text, image, sticker
 *  @param pushNotificationText text that will be shown to user in push notification
 *  @param conversationObj      Conversation object : message is part of
 *  @param chatSendCompletion   block to return control after sending the message with values (TRUE, LayerMessageObj) if the text is send successfully or values (False, nil) if message fails
 */
-(void)sendChatToApplozic:(NSString *)toId forMessage:(NSString *)message orImage:(BOOL)isImageSend imageData:(NSDictionary *)imageDict andChatObject:(ChatMessage *)messageObject chatSendToApplozicCompletion:(ApplozicChatSend)chatSendCompletion;

/**
 Method to pass controll to calling class if any chagne request if received from the layer in the layer delegate method  didReceiveLayerObjectsDidChangeNotification
 
 @param didChangeNotificationBlockVal block that will return values (True,LYRMessageObj) if the message is new or values (false,LYRMessageObj) if message if old and only message status is updated.
 */
-(void)setDidChangeApplozicNotificationBlockValue:(ApplozicDidChangeNotificationBlock)didChangeNotificationBlockVal;

- (ALMessage *)createMessageObjectForId:(NSString *)toID forMessage:(NSString *)message isImage:(BOOL)imageSent andImageData:(NSDictionary *)imageDict;
- (void)onMessageReceived:(ALMessage *)alMessage ;
- (void)onMessageDelivered:(ALMessage *)message ;
- (void)onMessageSent:(ALMessage *)alMessage ;
- (void)onUpdateTypingStatus:(NSString *)userId status:(BOOL)status;
- (void)updateUserName;
@end
