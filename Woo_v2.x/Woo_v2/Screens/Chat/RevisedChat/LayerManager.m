// //
////  LayerManager.m
////  Woo_v2
////
////  Created by Umesh Mishraji on 20/04/16.
////  Copyright © 2016 Vaibhav Gautam. All rights reserved.
////
//
//#import "LayerManager.h"
//#import "AppLaunchModel.h"
//#define kAppId_Layer @"layer:///apps/production/8a883a62-b6d1-11e4-856d-47bb5f025de4"
//
//@implementation LayerManager
//
//#pragma mark - Singleton Object
//
//SINGLETON_FOR_CLASS(LayerManager)
//
//#pragma mark - Authenticate and Deauthenticate from layer
//
//-(void)connectUserToLayer:(LayerAuthSuccess)layerAuthSuccessBlock{
//    authBlock = layerAuthSuccessBlock;
//    
//    if (!layerClient) {
//        NSURL *appID = [NSURL URLWithString:kAppId_Layer];
//        LYRClientOptions *clientOptions = [LYRClientOptions new];
//        clientOptions.synchronizationPolicy = LYRClientSynchronizationPolicyUnreadOnly;
//        layerClient = [LYRClient clientWithAppID:appID delegate:self options:clientOptions];
//        if (!layerClient.isConnected) {
//            [layerClient connectWithCompletion:^(BOOL success, NSError * _Nullable error) {
//                if (!success) {
//                    //try to reconnect after some time ==>> still need to implement
//                    if (_connectionEstablishedBlock) {
//                        _connectionEstablishedBlock(FALSE);
//                        _connectionEstablishedBlock = nil;
//                    }
//                }
//                else{
//                    NSString *userIdString = [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId];
//                    if ([[APP_Utilities validString:userIdString] length]>0) {
//                        [[LayerAuthenticationHelper sharedLayerAuthenticationHelper] authenticateLayerWithUserID:userIdString layerClient:layerClient completion:^(BOOL success, NSError *error) {
//                            if (!success) {
//                                NSLog(@"nahi huya authenticate try again");
//                            }
//                            else{
//                                [self updateDeviceTokenOnLayerServer:layerClient];
//                                [self addLayerObservers];
//                                layerAuthSuccessBlock(TRUE, layerClient);
//                                if (_connectionEstablishedBlock) {
//                                    _connectionEstablishedBlock(TRUE);
//                                    _connectionEstablishedBlock = nil;
//                                }
//                            }
//                        }];
//                    }
//                }
//            }];
//        }
//        else{
//            if (layerClient.authenticatedUser && [[APP_Utilities validString:layerClient.authenticatedUser.userID] length] > 0) {
//                [self addLayerObservers];
//                layerAuthSuccessBlock(TRUE, layerClient);
//            }
//            
//        }
//    }
//    else{
//        
//        if (layerClient.authenticatedUser && [[APP_Utilities validString:layerClient.authenticatedUser.userID] length] > 0) {
//            [self addLayerObservers];
//            layerAuthSuccessBlock(TRUE, layerClient);
//        }
//    }
//}
//
//-(void)disconnectFromLayer:(LayerDeAuthSuccess)layerDeAuthSuccessBlock{
//    
//    [[LayerAuthenticationHelper sharedLayerAuthenticationHelper] deAuthenticateUserOnLayer:^(BOOL deAuhtenticationSuccess) {
//        if (deAuhtenticationSuccess) {
//            layerDeAuthSuccessBlock(deAuhtenticationSuccess);
//            layerClient = nil;
//            APP_DELEGATE.layerClient = nil;
//        }
//    }];
//}
//
//-(void)isUserConnectedToLayer:(LayerConnectionEstablished)layerConnectionEstablishedBlock{
//    _connectionEstablishedBlock = layerConnectionEstablishedBlock;
//    if (layerClient) {
//        if (layerClient.isConnected && ([layerClient.authenticatedUser.userID length]>0) && _connectionEstablishedBlock) {
//            _connectionEstablishedBlock(TRUE);
//            _connectionEstablishedBlock = nil;
//        }
//        else
//        {
//            [APP_DELEGATE connectToLayer];
//        }
//            
//    }
//    else{
//        [APP_DELEGATE connectToLayer];
//    }
//}
//
//#pragma mark - Updating User token on layer server
//
//-(void)updateDeviceTokenOnLayerServer:(LYRClient *)layerClientObj{
//    if (layerClientObj) {
//        NSData *deveTokenData= [[NSUserDefaults standardUserDefaults] objectForKey:kDeviceToken];
//        if (deveTokenData) {
//            NSError *errorObj;
//            BOOL success = [layerClient updateRemoteNotificationDeviceToken:deveTokenData error:&errorObj];
//            if (!success) {
//                [self updateDeviceTokenOnLayerServer:layerClientObj];
//            }
//            else{
////                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDeviceToken];
////                [[NSUserDefaults standardUserDefaults] synchronize];
//            }
//        }
//    }
//}
//
//#pragma mark - Observer/methods to get notification on changes on layer server
//
//-(void)addLayerObservers{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:LYRClientObjectsDidChangeNotification object:layerClient];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLayerObjectsDidChangeNotification:) name:LYRClientObjectsDidChangeNotification object:layerClient];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:LYRClientWillBeginSynchronizationNotification object:layerClient];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLayerClientWillBeginSynchronizationNotification:) name:LYRClientWillBeginSynchronizationNotification object:layerClient];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:LYRClientDidFinishSynchronizationNotification object:layerClient];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLayerClientDidFinishSynchronizationNotification:) name:LYRClientDidFinishSynchronizationNotification object:layerClient];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:LYRConversationDidReceiveTypingIndicatorNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveTypingIndicator:) name:LYRConversationDidReceiveTypingIndicatorNotification object:nil];
//}
//
//#pragma mark - Layer change notification hanlder
//
//- (void)didReceiveLayerObjectsDidChangeNotification:(NSNotification *)notification;
//{
//    NSArray *changes = [notification.userInfo objectForKey:LYRClientObjectChangesUserInfoKey];
//    for (LYRObjectChange *change in changes) {
//        
//        // Returns the object for which a change has occurred
//        id changeObject = change.object;
//        
//        if ([changeObject isKindOfClass:[LYRConversation class]]) {
//            // Object is a conversation
//            LYRObjectChangeType changeKey = change.type;
//            switch (changeKey) {
//                case LYRObjectChangeTypeCreate:{//Object was created
//                    NSLog(@"Conversation id Created %@",((LYRConversation *)changeObject).identifier);
//                    NSString *otherPersonWooId = @"";
//                    for (LYRIdentity *participant in ((LYRConversation *)changeObject).participants) {
//                        if (![participant.userID isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]]) {
//                            otherPersonWooId = participant.userID;
//                            break;
//                        }
//                    }
//                    if([APP_DELEGATE.currentActiveChatRoomId containsString:otherPersonWooId])
//                    {
//                        [[NSNotificationCenter defaultCenter] postNotificationName:kNewConversationAvailableNotification object:changeObject];
//                    }
//                    else
//                    {
//                        //Fail safe
//                        //Find conversations not in MyMatches DB and leave them
//                    }
//                }
//                    break;
//                case LYRObjectChangeTypeUpdate:{// Object was updated
//                    NSString *otherPersonWooId = @"";
//                    for (LYRIdentity *participant in ((LYRConversation *)changeObject).participants) {
//                        if (![participant.userID isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]]) {
//                            otherPersonWooId = participant.userID;
//                        }
//                    }
//                    if([APP_DELEGATE.currentActiveChatRoomId containsString:otherPersonWooId])
//                    {
//                        [[NSNotificationCenter defaultCenter] postNotificationName:kNewConversationAvailableNotification object:changeObject];
//                    }
//                    else
//                    {
//                        //Fail safe
//                        //Find conversations not in MyMatches DB and leave them
//                    }
//                }
//                    break;
//                case LYRObjectChangeTypeDelete:
//                    // Object was deleted
//                    break;
//                default:
//                    break;
//            }
//        }
//        if ([changeObject isKindOfClass:[LYRMessage class]]) {
//            // Object is a message
//            NSLog(@"Message aaya");
//            LYRObjectChangeType changeKey = change.type;
//            switch (changeKey) {
//                case LYRObjectChangeTypeCreate:{
//                    LYRMessage *messageObj = changeObject;
//                    if(![messageObj.sender.userID isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]])
//                    {
//                        //this should only be for incoming messages
//                        [MyMatches checkIfChatRoomExistsForIncomingMessage:messageObj withCompletionBlock:^(BOOL chatRoomExists) {
//                            if (chatRoomExists) {
//                                [LAYER_HELPER insertLayerChatFromToLocalDB:messageObj withCompletionHandler:^(ChatMessage *chatMessageObj) {
//                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.03 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                                        
//                                        if (_didChangeNotificationBlock) {
//                                            _didChangeNotificationBlock(TRUE, messageObj);
//                                        }
//                                    });
//                                    
//                                }];
//                            }
//                            else{
//                                [APP_DELEGATE getMyMatchesForTimestamp:[AppLaunchModel sharedInstance].lastMatchUpdateTime withCompletion:^(BOOL matchFetched) {
//                                    [MyMatches checkIfChatRoomExistsForIncomingMessage:messageObj withCompletionBlock:^(BOOL chatRoomExists) {
//                                        [LAYER_HELPER insertLayerChatFromToLocalDB:messageObj withCompletionHandler:^(ChatMessage *chatMessageObj) {
//                                            if (_didChangeNotificationBlock) {
//                                                _didChangeNotificationBlock(TRUE, messageObj);
//                                            }
//                                        }];
//                                    }];
//                                }];
//                            }
//                        }];
//                    }
//                }
//                    break;
//                case LYRObjectChangeTypeUpdate:{
//                    LYRMessage *messageObj = changeObject;
//                    NSLog(@"recipientStatusForUserID>>> %d",[messageObj recipientStatusForUserID:messageObj.sender.userID]);
//                    NSLog(@"messageObj %@",messageObj);
//                    [LAYER_HELPER updateLayerChatFromToLocalDB:messageObj withCompletionHandler:^(ChatMessage *chatMessageObj) {
//                        if (_didChangeNotificationBlock) {
//                            _didChangeNotificationBlock(FALSE, messageObj);
//                        }                        
//                    }];
//                }
//                    break;
//                case LYRObjectChangeTypeDelete:
//                    // Object was deleted
//                    break;
//                default:
//                    break;
//            }
//            
//        }
//    }
//}
//
//#pragma mark - Layer Sync Notification Handler
//
//- (void)didReceiveLayerClientWillBeginSynchronizationNotification:(NSNotification *)notification
//{
//    NSLog(@"notification progress:%@",[notification.userInfo objectForKey:LYRClientSynchronizationProgressUserInfoKey]);
//}
//
//- (void)didReceiveLayerClientDidFinishSynchronizationNotification:(NSNotification *)notification
//{
//    NSLog(@"notification progress finish:%@",[notification.userInfo objectForKey:LYRClientSynchronizationProgressUserInfoKey]);
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"ClientSynchronizationDone" object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:LYRClientWillBeginSynchronizationNotification object:layerClient];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:LYRClientDidFinishSynchronizationNotification object:layerClient];
//    
//}
//
//#pragma mark - Layer Typing notification handler
//
//- (void)didReceiveTypingIndicator:(NSNotification *)notification
//{
//    if(!APP_DELEGATE.currentActiveChatRoomId && [APP_DELEGATE.currentActiveChatRoomId length] <= 0 )
//    {
//        return;
//    }
//    LYRTypingIndicator *typingIndicator = notification.userInfo[LYRTypingIndicatorObjectUserInfoKey];
//    NSString *participantID = typingIndicator.sender.userID;
//    if([APP_DELEGATE.currentActiveChatRoomId containsString:participantID])
//    {
//        if (typingIndicator.action == LYRTypingIndicatorActionBegin) {
//            NSLog(@"%@ is typing... LYRTypingDidBegin",participantID);
//            /*
//            [[NSNotificationCenter defaultCenter] postNotificationName:kBroadcastTypingIndicatorChangeEventNotification object:
//             [[NSDictionary alloc] initWithObjectsAndKeys:
//              typingIndicator,kParticipantIdKey,nil]];
//             */
//
//        } else if (typingIndicator.action == LYRTypingIndicatorActionFinish) {
//            NSLog(@"%@ is NOT typing... LYRTypingDidFinish",participantID);
//            /*
//            [[NSNotificationCenter defaultCenter] postNotificationName:kBroadcastTypingIndicatorChangeEventNotification object:
//             [[NSDictionary alloc] initWithObjectsAndKeys:
//              typingIndicator,kParticipantIdKey,nil]];
//             */
//
//        }
//        else
//        {
//            NSLog(@"%@ is NOT typing...  LYRTypingDidPause",participantID);
//        }
//    }
//}
//
//#pragma mark - Sending chat to layer.
////Method to send chat to layer server. Right now all chat are send as text chat to layer server all the images are uploaded to our server and sticker are stored in the app locally.
//-(void)sendChatToLayer:(NSString *)chatStr ForMimeType:(NSString *)mimeType  withPushText:(NSString *)pushNotificationText forConversation:(LYRConversation *)conversationObj isRequesterFlagged:(BOOL)isFlagged chatSendToLayerCompletion:(LayerChatSend)chatSendCompletion{
//    
//    // Creates a message part with given mime type
//    NSData *messageData = [chatStr dataUsingEncoding:NSUTF8StringEncoding];
//    LYRMessagePart *messagePart = [LYRMessagePart messagePartWithMIMEType:mimeType data:messageData];
//    
//    NSError *error = nil;
//    LYRMessage *message = nil;
//    //Send push for my messages only if I am not flagged.
//    if(isFlagged == NO)
//    {
//        // creating push notification for the receiver
//        NSString *pushMessageText = [NSString  stringWithFormat:@"You received a message from %@",[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserName]];
////        NSString *pushMessageText = [NSString stringWithFormat:@"%@: %@", [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserName], pushNotificationText];
//        LYRPushNotificationConfiguration *configurationObj = [LYRPushNotificationConfiguration new];
//        configurationObj.alert = pushMessageText;
//        configurationObj.sound = @"default";
//        
//        LYRMessageOptions *messageOptionObj = [LYRMessageOptions new];
//        messageOptionObj.pushNotificationConfiguration = configurationObj;
//        message = [layerClient newMessageWithParts:[NSSet setWithObject:messagePart] options:messageOptionObj error:&error];
//    }
//    else
//    {
//        message = [layerClient newMessageWithParts:[NSSet setWithObject:messagePart] options:nil error:&error];
//
//    }    
//    chatSendCompletion(YES, message);
//
//}
//
//-(void)getConversationObjectForLayerConversationId:(NSString *)conversationId withCompletionHandler:(SyncCompletionHandler)syncCompletion {
//    NSURL *conversationIdentifier = [NSURL URLWithString:conversationId];
//    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
//    query.predicate = [LYRPredicate predicateWithProperty:@"identifier" predicateOperator:LYRPredicateOperatorIsEqualTo value:conversationIdentifier];
//    NSError *error = nil;
//    NSOrderedSet *conversations = [layerClient executeQuery:query error:&error];
//    if (error) {
//        // query failed
//        syncCompletion(YES,nil,error);
//    }
//    else
//    {
//        __block LYRConversation *conversation =  [conversations lastObject];
//        if ([conversations count] == 1) {
//            // Push on your Conversation view and you can start chatting
//            syncCompletion(YES,[conversations lastObject],nil);
//        }
//        else if(!conversation)
//        {
//            // The message hasn't been synchronized
//            [layerClient waitForCreationOfObjectWithIdentifier:conversationIdentifier timeout:10.0 completion:^(id  _Nullable object, NSError * _Nullable error) {
//                
//                if (!error)
//                {
//                    if (object) {
//                        conversation = (LYRConversation*)object;
//                        // proceed with object
//                        syncCompletion(YES,object,nil);
//
//                    }
//                }
//                else
//                {
//                    syncCompletion(YES,nil,error);
//                }
//            }];
//         }
//        else{
//            syncCompletion(YES,nil,nil);
//        }
//    }
//}
//
//-(LYRMessage *)getMessageObjectForLayerConversationId:(NSString *)messageId{
//    NSURL *conversationIdentifier = [NSURL URLWithString:messageId];
//    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRMessage class]];
//    query.predicate = [LYRPredicate predicateWithProperty:@"identifier" predicateOperator:LYRPredicateOperatorIsEqualTo value:conversationIdentifier];
//    NSError *error = nil;
//    NSOrderedSet *conversations = [layerClient executeQuery:query error:&error];
//    if ([conversations count] == 1) {
//        // Push on your Conversation view and you can start chatting
//        return [conversations lastObject];
//    }
//    return nil;
//}
//
//
//-(void)setDidChangeNotificationBlockValue:(LayerDidChangeNotificationBlock)didChangeNotificationBlockVal{
//    _didChangeNotificationBlock = didChangeNotificationBlockVal;
//}
//
//- (void)layerClient:(nonnull LYRClient *)client didReceiveAuthenticationChallengeWithNonce:(nonnull NSString *)nonce{
//
//    [[LayerAuthenticationHelper sharedLayerAuthenticationHelper] reauthenticateUserWithNonceToken:nonce completion:^(BOOL success, NSError *error) {
//        if (!success) {
//            NSLog(@"nahi huya authenticate try again");
//        }
//        else{
//            [self updateDeviceTokenOnLayerServer:layerClient];
//            [self addLayerObservers];
//            authBlock(TRUE, layerClient);
//            if (_connectionEstablishedBlock) {
//                _connectionEstablishedBlock(TRUE);
//                _connectionEstablishedBlock = nil;
//            }
//        }
//    }];
//}
//
//
//@end
