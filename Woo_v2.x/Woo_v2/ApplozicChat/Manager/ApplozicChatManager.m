//
//  ApplozicChatManager.m
//  Woo_v2
//
//  Created by Akhil Singh on 19/11/18.
//  Copyright © 2018 Woo. All rights reserved.
//

#import "ApplozicChatManager.h"
#import "AppLaunchModel.h"
#import "ApplozicChatHelperClass.h"


@interface ApplozicChatManager()<ApplozicUpdatesDelegate>
@end

@implementation ApplozicChatManager

#pragma mark - Singleton Object

SINGLETON_FOR_CLASS(ApplozicChatManager)

#pragma mark - Authenticate and Deauthenticate from layer

-(void)connectUserToApplozicWithClientObject:(ApplozicClient*)applozicClientObject withAppLozicAuthBlock:(ApplozicAuthSuccess)applozicAuthSuccessBlock{
    authBlock = applozicAuthSuccessBlock;
    
    if([ALUserDefaultsHandler isLoggedIn]){
        _applozic   = APP_DELEGATE.applozic;
        return;
    }
    if (applozicClientObject && ([LoginModel sharedInstance].appLozicUserId && [LoginModel sharedInstance].appLozicToken)) {
        _applozic = APP_DELEGATE.applozic;
        //Login user now
        
        ALUser *alUser = [[ALUser alloc] init];
        [alUser setUserId:[[LoginModel sharedInstance]appLozicUserId]]; //NOTE : +,*,? are not allowed chars in userId.
        [alUser setDisplayName:[[LoginModel sharedInstance]firstName]];
        [alUser setPassword:[[LoginModel sharedInstance]appLozicToken]];
        
        //Saving the details
        [ALUserDefaultsHandler setUserId:alUser.userId];
        [ALUserDefaultsHandler setDisplayName:alUser.displayName];
        
        //Registering or Loging in the User
        ALChatManager * chatManager = [[ALChatManager alloc] initWithApplicationKey:kAppId_Applozic];
        
        [chatManager connectUserWithCompletion:alUser completion:^(ALRegistrationResponse * response, NSError * error) {
            if(error){
                if (self->_connectionEstablishedBlock) {
                    self->_connectionEstablishedBlock(FALSE);
                    self->_connectionEstablishedBlock = nil;
                }
            }else{
                [APP_DELEGATE.applozic subscribeToConversation];
                [APP_DELEGATE.applozic subscribeToTypingStatusForOneToOne];
               // [self updateDeviceTokenOnApplozicServer:APP_DELEGATE.applozic];
                applozicAuthSuccessBlock(TRUE,APP_DELEGATE.applozic);
                if (self->_connectionEstablishedBlock) {
                    self->_connectionEstablishedBlock(TRUE);
                    self->_connectionEstablishedBlock = nil;
                }
            }
            
        }];
    }
    else{
       applozicAuthSuccessBlock(false, APP_DELEGATE.applozic);
    }
}

-(void)disconnectFromApplozic:(ApplozicDeAuthSuccess)applozicDeAuthSuccessBlock{
    
    ALRegisterUserClientService *registerUserClientService = [[ALRegisterUserClientService alloc] init];
    [registerUserClientService logoutWithCompletionHandler:^(ALAPIResponse *response, NSError *error) {
        if(!error && [response.status isEqualToString:@"success"])
        {
            NSLog(@"AppLozic Logout success");
            applozicDeAuthSuccessBlock(true);
            ApplozicClient *clientObj = APP_DELEGATE.applozic;
            clientObj= nil;
        }
        else
        {
            applozicDeAuthSuccessBlock(false);
        }
    }];
}

-(void)isUserConnectedToApplozic:(ApplozicConnectionEstablished)applozicConnectionEstablishedBlock{
    _connectionEstablishedBlock = applozicConnectionEstablishedBlock;
    if (ALUserDefaultsHandler.isLoggedIn && _connectionEstablishedBlock) {
            _connectionEstablishedBlock(TRUE);
            _connectionEstablishedBlock = nil;
        }
        else
        {
            [self connectUserToApplozicWithClientObject:APP_DELEGATE.applozic withAppLozicAuthBlock:^(BOOL authenticationSuccess, ApplozicClient * _Nonnull applozicClient) {
                if (self.connectionEstablishedBlock){
                    self.connectionEstablishedBlock(TRUE);
                    self.connectionEstablishedBlock = nil;
                }
            }];
        }
}

#pragma mark - Updating User token on Applozic server

-(void)updateDeviceTokenOnApplozicServer:(ApplozicClient *)clientObj{
    if (clientObj) {
        NSData *devTokenData= [[NSUserDefaults standardUserDefaults] objectForKey:kDeviceToken];
        NSString * deviceTokenString;
        
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13.0")){

            // if we are working with xcode 11
            // if not, then please comment this code
                NSUInteger length = devTokenData.length;
                const unsigned char *buffer = devTokenData.bytes;
                NSMutableString *devTokenForIos13  = [NSMutableString stringWithCapacity:(length * 2)];
                for (int i = 0; i < length; ++i) {
                    [devTokenForIos13 appendFormat:@"%02x", buffer[i]];
                }
                NSLog(@" devtoken in hexString%@",devTokenForIos13);
                deviceTokenString = devTokenForIos13;
            
        }else{
            
            deviceTokenString = [[[[devTokenData description]
            stringByReplacingOccurrencesOfString: @"<" withString: @""]
            stringByReplacingOccurrencesOfString: @">" withString: @""]
            stringByReplacingOccurrencesOfString: @" " withString: @""];
        }
        
        
        if (![[ALUserDefaultsHandler getApnDeviceToken] isEqualToString:deviceTokenString]) {
            ALRegisterUserClientService *registerUserClientService = [[ALRegisterUserClientService alloc] init];
            [registerUserClientService updateApnDeviceTokenWithCompletion
             :deviceTokenString withCompletion:^(ALRegistrationResponse
                                              *rResponse, NSError *error) {
                 
                 NSLog(@"Registration response%@", rResponse);

                 if (error) {
                     NSLog(@"%@",error);
                 }
                 else{
                    NSLog(@"Push device token success");
                 }
             }];
        }
    }
}

-(void)setDidChangeApplozicNotificationBlockValue:(ApplozicDidChangeNotificationBlock)didChangeNotificationBlockVal{
    _didChangeNotificationBlock = didChangeNotificationBlockVal;
}

#pragma mark - Sending chat to Applozic.
-(void)sendChatToApplozic:(NSString *)toId forMessage:(NSString *)message orImage:(BOOL)isImageSend imageData:(NSDictionary *)imageDict andChatObject:(ChatMessage *)messageObject chatSendToApplozicCompletion:(ApplozicChatSend)chatSendCompletion{
    
    ALMessage *alMessage = [ALMessage build:^(ALMessageBuilder * alMessageBuilder) {
        alMessageBuilder.to = toId;
        if (isImageSend){
            alMessageBuilder.message = @"sent you an image";
        }
        else{
            alMessageBuilder.message = message; //Pass message text here
        }
        alMessageBuilder.metadata = [self createMetaDataTosendToApplozic:imageDict];
    
    }];

    //Adding time interval
    if (alMessage == nil){
        alMessage.to = toId;
        if (isImageSend){
            alMessage.message = @"sent you an image";
        }
        else{
            alMessage.message = message; //Pass message text here
        }
        alMessage.metadata = [self createMetaDataTosendToApplozic:imageDict];
    }
    NSTimeInterval currentDate = [[NSDate date] timeIntervalSince1970]*1000;
    NSNumber *dateInNumber = [NSNumber numberWithLongLong:currentDate];
    alMessage.createdAtTime = dateInNumber;
    alMessage.status = [NSNumber numberWithInt:0];
    
    //Inserting the Chat in DB
    if (isImageSend == NO){
    [APPLOZIC_HELPER insertApplozicChatFromToLocalDB:alMessage ifSenderIsMe:true withCompletionHandler:^(ChatMessage *chatMessageObj) {
        chatSendCompletion(YES,chatMessageObj);
    }];
    }
    
    [APP_DELEGATE sendSwrveEventWithEvent:@"3-Matchbox.Chatbox.MC_SendTextMessage" andScreen:@"Chatbox" ];
    
    //Sending the message
    [APP_DELEGATE.applozic sendTextMessage:alMessage withCompletion:^(ALMessage *message, NSError *error) {
        if(!error){
            if (isImageSend == YES){
                if (messageObject){
                    [ChatMessage updateLayerIdOfChatMessageWithLayerId:[alMessage.metadata objectForKey:@"CreatedTime"] andDeliveryStatus:alMessage.status forChatObject:messageObject withUpdationHandler:^(ChatMessage *chatMessageObj) {
                        [self->_delegate updateAppLozicStatus:message];
                    }];
                }
            }
            else{
                ChatMessage *chatMessage = [ChatMessage getChatMessageForLayerMessageId:[alMessage.metadata objectForKey:@"CreatedTime"]];
                if (chatMessage){
                [ChatMessage updateChatMessageObject:chatMessage withStatus:alMessage.status withUpdationHandler:^(ChatMessage *chatMessageObj) {
                    chatSendCompletion(YES,chatMessageObj);
                }];
                }
                else{
                [APPLOZIC_HELPER updateApplozicChatFromToLocalDB:message ifSenderIsMe:true withCompletionHandler:^(ChatMessage *chatMessageObj) {
                    chatSendCompletion(YES,chatMessageObj);
                }];
                }
            }
        }
    }];
}

- (ALMessage *)createMessageObjectForId:(NSString *)toID forMessage:(NSString *)message isImage:(BOOL)imageSent andImageData:(NSDictionary *)imageDict{
    ALMessage *alMessage = [ALMessage build:^(ALMessageBuilder * alMessageBuilder) {
        alMessageBuilder.to = toID; //Pass userId to whom you want to send a message
        if (imageSent){
            alMessageBuilder.message = @"sent you an image";
        }
        else{
            alMessageBuilder.message = message; //Pass message text here
        }
        alMessageBuilder.metadata = [self createMetaDataTosendToApplozic:imageDict];
        
        
    }];
    alMessage.status = [NSNumber numberWithInt:0];
    
    return alMessage;
}

- (NSMutableDictionary *)createMetaDataTosendToApplozic:(NSDictionary *)imageDict{
    
    NSMutableDictionary *metaDict;
    if (imageDict != nil){
        metaDict = [[NSMutableDictionary alloc] initWithDictionary:imageDict];
        [metaDict setObject:@"IMAGE" forKey:@"type"];
    }
    else{
        metaDict = [[NSMutableDictionary alloc] init];
        [metaDict setObject:@"TEXT" forKey:@"type"];

    }
    NSTimeInterval currentDate = [[NSDate date] timeIntervalSince1970]*1000;
//    NSNumber *dateInNumber = [NSNumber numberWithLongLong:currentDate];
    NSString *createdTime = [NSString stringWithFormat:@"%.0f",currentDate];
    [metaDict setValue:createdTime  forKey:@"CreatedTime"];
    return metaDict;
}

-(void)blockUser:(NSString *)UserID{
    [[ALUserService sharedInstance] blockUser:UserID withCompletionHandler:^(NSError *error, BOOL userBlock) {
    }];
}

-(void)unBlockUser:(NSString *)UserID{
    [[ALUserService sharedInstance] unblockUser:UserID withCompletionHandler:^(NSError *error, BOOL userUnblock) {
    }];
}


#pragma mark Applozic delegates

- (void)conversationReadByCurrentUser:(NSString *)userId withGroupId:(NSNumber *)groupId {

}

- (void)onAllMessagesRead:(NSString *)userId {
}

- (void)onChannelUpdated:(ALChannel *)channel {
    
}

- (void)onConversationDelete:(NSString *)userId withGroupId:(NSNumber *)groupId {
    
}

- (void)onMessageDeleted:(NSString *)messageKey {
    
}

- (void)onMessageDelivered:(ALMessage *)message {
    [_delegate updateAppLozicStatus:message];
}

- (void)onMessageDeliveredAndRead:(ALMessage *)message withUserId:(NSString *)userId {
    NSLog(@" onMessageDeliveredAndRead %@", message);
}

- (void)onMessageReceived:(ALMessage *)alMessage {
 
    NSLog(@"metaData=%@",alMessage.metadata);
    [MyMatches checkIfChatRoomExistsForIncomingMessageFromApplozic:alMessage.to withCompletionBlock:^(BOOL chatRoomExists){
        if (chatRoomExists) {
            ChatMessage *message = [ChatMessage getChatMessageForLayerMessageId:[alMessage.metadata objectForKey:@"CreatedTime"]];
            if (message){
                if (self->_didChangeNotificationBlock) {
                    self->_didChangeNotificationBlock(alMessage, message);
                }
            }
            else{
                [APPLOZIC_HELPER insertApplozicChatFromToLocalDB:alMessage ifSenderIsMe:false  withCompletionHandler:^(ChatMessage *chatMessageObj) {
                    if (self->_didChangeNotificationBlock) {
                        self->_didChangeNotificationBlock(alMessage, chatMessageObj);
                    }
                }];
            }
        }
        else{
            [APP_DELEGATE getMyMatchesForTimestamp:[AppLaunchModel sharedInstance].lastMatchUpdateTime withCompletion:^(BOOL matchFetched) {
                if (matchFetched){
                [MyMatches checkIfChatRoomExistsForIncomingMessageFromApplozic:alMessage.to withCompletionBlock:^(BOOL chatRoomExists) {
                    ChatMessage *message = [ChatMessage getChatMessageForLayerMessageId:[alMessage.metadata objectForKey:@"CreatedTime"]];
                    if (message){
                        if (self->_didChangeNotificationBlock) {
                            self->_didChangeNotificationBlock(alMessage, message);
                        }
                    }
                    else{
                        [APPLOZIC_HELPER insertApplozicChatFromToLocalDB:alMessage ifSenderIsMe:false  withCompletionHandler:^(ChatMessage *chatMessageObj) {
                            if (self->_didChangeNotificationBlock) {
                                self->_didChangeNotificationBlock(alMessage, chatMessageObj);
                            }
                        }];
                    }
                }];
                }
            }];
        }
    }];
    
}

- (void)onMessageSent:(ALMessage *)alMessage {
    NSLog(@"you sent to this %@ to %@", alMessage.to, alMessage.message);
}

- (void)onMqttConnected {
    APP_DELEGATE.isConnectedToApplozic = YES;
    [APP_DELEGATE.applozic subscribeToTypingStatusForOneToOne];
    [APP_DELEGATE.applozic subscribeToConversation];
}

- (void)onMqttConnectionClosed {
    APP_DELEGATE.isConnectedToApplozic = NO;
   // [_applozic unSubscribeToTypingStatusForOneToOne];
    //[_applozic unsubscribeToConversation];
}

- (void)onUpdateLastSeenAtStatus:(ALUserDetail *)alUserDetail {
    
}

- (void)onUpdateTypingStatus:(NSString *)userId status:(BOOL)status {
    if(!APP_DELEGATE.currentActiveChatRoomId && [APP_DELEGATE.currentActiveChatRoomId length] <= 0 )
    {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kBroadcastTypingIndicatorChangeEventNotificationApplozic object:
     [[NSDictionary alloc] initWithObjectsAndKeys:
      [NSNumber numberWithBool:status],kParticipantIdKey,userId,ktypingTargetIdKey,nil]];
}

- (void)onUserBlockedOrUnBlocked:(NSString *)userId andBlockFlag:(BOOL)flag {
    
}

- (void)onUserDetailsUpdate:(ALUserDetail *)userDetail {
    
}

- (void)onUserMuteStatus:(ALUserDetail *)userDetail {
    
}

- (void)updateUserName{
    if ([LoginModel sharedInstance].firstName != nil){
    ALUserService *userService = [ALUserService new];
    [userService updateUserDisplayName:[LoginModel sharedInstance].firstName andUserImage:@"" userStatus:@"" withCompletion:^(id theJson, NSError *error) {
        
    }];
    }
}


@end
