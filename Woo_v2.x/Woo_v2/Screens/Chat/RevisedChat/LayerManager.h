////
////  LayerManager.h
////  Woo_v2
////
////  Created by Umesh Mishraji on 20/04/16.
////  Copyright © 2016 Vaibhav Gautam. All rights reserved.
////
//
//#import <UIKit/UIKit.h>
//#import "LayerAuthenticationHelper.h"
////#import <LayerKit/LayerKit.h>
//
//
//static LYRClient *layerClient;
//
//typedef void (^LayerConnectionEstablished) (BOOL connectionEstablished);
//typedef void (^LayerChatSend) (BOOL chatSendSuccessFully, LYRMessage* layerMessageObj);
//typedef void (^LayerDidChangeNotificationBlock)(BOOL newMsgAvailable, LYRMessage *layerMessageObj);
//typedef void(^SyncCompletionHandler)(BOOL isSyncCompleted, __nullable id conversation, NSError *error );
//
//
//
//@interface LayerManager : UIViewController<LYRClientDelegate>{
//    
//    LayerAuthSuccess authBlock;
//    
//}
//
//@property(nonatomic, copy) LayerConnectionEstablished connectionEstablishedBlock;
//@property(nonatomic, copy) LayerDidChangeNotificationBlock didChangeNotificationBlock;
//
//
//
//+(LayerManager *)sharedLayerManager;
//
//
//
///**
// *  Method to connect user from layer. This method will be called to check if user is connected with Layer or not. If connected the control will passed back using the block else Connection will be established and that block will be called
// *
// *  @param layerAuthSuccessBlock block that will be returned with values (True and layerClient object) when connection is successfully established with the layer server or values (False and nil) when connection is not established
// */
//-(void)connectUserToLayer:(LayerAuthSuccess)layerAuthSuccessBlock;
//
///**
// *  Method to disconnect from the layer server
// *
// *  @param layerDeAuthSuccessBlock block that will be returned with value (True) when connection is successfully disconnected from the layer server or value (False) when connection is not disconnected
// */
//-(void)disconnectFromLayer:(LayerDeAuthSuccess)layerDeAuthSuccessBlock;
//
///**
// * Method to check if user connected to layer or not. If user is connected the calling class/method will be notified by the block object else user will be connected to layer.
// *
// *  @param layerConnectionEstablishedBlock layerConnectionEstablishedBlock block that will return value(True) if connection is established.
// */
//-(void)isUserConnectedToLayer:(LayerConnectionEstablished)layerConnectionEstablishedBlock;
//
///**
// *  Method to send message to layer. Message can be text, imageUrl, or stickerName(now not user).
// *
// *  @param chatStr              Chat message string that will be send
// *  @param mimeType             mime type :  it describes whether the message is text, image, sticker
// *  @param pushNotificationText text that will be shown to user in push notification
// *  @param conversationObj      Conversation object : message is part of
// *  @param chatSendCompletion   block to return control after sending the message with values (TRUE, LayerMessageObj) if the text is send successfully or values (False, nil) if message fails
// */
//-(void)sendChatToLayer:(NSString *)chatStr ForMimeType:(NSString *)mimeType  withPushText:(NSString *)pushNotificationText forConversation:(LYRConversation *)conversationObj isRequesterFlagged:(BOOL)isFlagged chatSendToLayerCompletion:(LayerChatSend)chatSendCompletion;
//
///**
// *  Method to get layer conversation object.
// *
// *  @param conversationId conversation id from the mymatches object provided by server
// *
// *  @return LYRConversation Object for the conversation or nil
// */
//-(void)getConversationObjectForLayerConversationId:(NSString *)conversationId withCompletionHandler:(SyncCompletionHandler)syncCompletion;
//
///**
//    Method to pass controll to calling class if any chagne request if received from the layer in the layer delegate method  didReceiveLayerObjectsDidChangeNotification
//
// @param didChangeNotificationBlockVal block that will return values (True,LYRMessageObj) if the message is new or values (false,LYRMessageObj) if message if old and only message status is updated.
// */
//-(void)setDidChangeNotificationBlockValue:(LayerDidChangeNotificationBlock)didChangeNotificationBlockVal;
//
//
///**
// *  Method to get layer Message object.
// *
// *  @param messageId message id for which object is required
// *
// *  @return messageId Object for the Message or nil
// */
//-(LYRMessage *)getMessageObjectForLayerConversationId:(NSString *)messageId;
//
//@end
