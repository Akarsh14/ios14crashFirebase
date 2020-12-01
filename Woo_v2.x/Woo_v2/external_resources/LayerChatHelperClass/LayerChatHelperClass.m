//
//  LayerChatHelperClass.m
//  Woo
//
//  Created by Umesh Mishra on 31/03/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "LayerChatHelperClass.h"
#import "LayerManager.h"

@implementation LayerChatHelperClass

SINGLETON_FOR_CLASS(LayerChatHelperClass)

//-(void)insertLayerChatFromToLocalDB:(LYRMessage *)messageObj withCompletionHandler:(ChatInsertionCompletionHandler)chatCompletion{
//
//    if (![[NSUserDefaults standardUserDefaults] boolForKey:kUserAlreadyRegistered] || ([messageObj.parts count] <1) || ([messageObj.conversation.participants count] < 2)) {
//        chatCompletion(nil);
//    }
//
//    LYRMessagePart *messagePartObj = [messageObj.parts.allObjects firstObject];
//
//    NSString *otherPersonWooId = @"";
//
//    for (LYRIdentity *participant in messageObj.conversation.participants) {
//        if (![participant.userID isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]]) {
//            otherPersonWooId = participant.userID;
//        }
//    }
//
//    if (([otherPersonWooId length] < 1) || ([messageObj.sender.userID isEqualToString:otherPersonWooId] && messageObj.isUnread == FALSE)) {
//        chatCompletion(nil);
//    }
//
//    MyMatches *matchedUserDetail = [MyMatches getMatchDetailForMatchedUSerID:otherPersonWooId isApplozic:false];
//
//    //Current message time should be greater than match Creation time
//    if (matchedUserDetail == nil && [matchedUserDetail.matchedOn compare:[NSDate date]] != NSOrderedAscending) {
//        chatCompletion(nil);
//    }
//
//    NSMutableDictionary *chatDetailDictionary = [[NSMutableDictionary alloc] init];
//
//    NSString *msgString = [[NSString alloc] initWithData:messagePartObj.data encoding:NSUTF8StringEncoding];
//    if ([messagePartObj.MIMEType isEqualToString:MIME_TYPE_APPLICATION_JSON]) {             // Message is image message
//        NSDictionary *msgDictionary = [APP_Utilities convertStringToDictionary:msgString];
//        msgString =  [APP_Utilities validString:[msgDictionary objectForKey:@"imageurl"]];                                              // Message is the url of the image, that is received
//        NSString *imageSizeString = [NSString stringWithFormat:@"%lld",[[msgDictionary objectForKey:@"imagesize"] longLongValue]];
//        [chatDetailDictionary setObject:[APP_Utilities validString:imageSizeString] forKey:kImageSize];       // size fo the image that is received from other side
//        if ([msgString length]>0) {
//            //If it is a image message that we have to download a low res image of the same.
//            NSString *lowResImageUrl =[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(5), IMAGE_SIZE_FOR_POINTS(5),msgString];
//            [[SDImageCache sharedImageCache] queryCacheOperationForKey:lowResImageUrl done:^(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType) {
//                if (!image) {
//                    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:lowResImageUrl] options:0 progress:nil completed:nil];
//                }
//            }];
//        }
//    }
//
//    msgString = [APP_Utilities validString:msgString];
//    [chatDetailDictionary setObject:msgString forKey:kMessageKey];
//
//    if ([messagePartObj.MIMEType isEqualToString:MIME_TYPE_APPLICATION_JSON]) {
//        [chatDetailDictionary setObject:[NSNumber numberWithInt:IMAGE_SEND_BY_USER] forKey:kMessageTypeKey];    // This will be called when user will receive image from another user(photo clicked or fetched from gallery)
//    }
//    else if ([messagePartObj.MIMEType isEqualToString:MIME_TYPE_IMAGE_PNG]){
//        [chatDetailDictionary setObject:[NSNumber numberWithInt:IMAGE] forKey:kMessageTypeKey];     // This will be called when user will receive sticker
//    }
//    else{
//        [chatDetailDictionary setObject:[NSNumber numberWithInt:TEXT] forKey:kMessageTypeKey];      // This will be called when user will receive text message
//    }
//    [chatDetailDictionary setObject:messageObj.identifier.lastPathComponent forKeyedSubscript:kChatMessageLayerID];
//
//    NSString *receiverPresonId = @"";
//    for (LYRIdentity *participant in messageObj.conversation.participants) {
//        if (![messageObj.sender.userID isEqualToString:participant.userID]) {
//            receiverPresonId = participant.userID;
//        }
//    }
//
//    [chatDetailDictionary setObject:messageObj.sender.userID forKey:kMessageSenderIDKey];
//    [chatDetailDictionary setObject:receiverPresonId forKey:kMessageReceiverID];
//    [chatDetailDictionary setObject:[NSNumber numberWithInt:[messageObj recipientStatusForUserID:receiverPresonId]] forKey:kChatMessageDeliveryLayerStatus];
//
//
////    if ([messageObj.sender.userID isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]]) {
////        [chatDetailDictionary setObject:receiverPresonId forKey:kChatRoomIDKey];
////    }
////    else{
////        [chatDetailDictionary setObject:messageObj.sender.userID forKey:kChatRoomIDKey];
////    }
//    //Chat room should be match id
//    [chatDetailDictionary setObject:matchedUserDetail.matchId forKey:kChatRoomIDKey];
//
//    NSTimeInterval currentDate = [[NSDate date] timeIntervalSince1970]*1000;
//    if (messageObj.sentAt) {
//        currentDate = [messageObj.sentAt timeIntervalSince1970]*1000;
//    }
//    [chatDetailDictionary setObject:[NSNumber numberWithLongLong:currentDate] forKey:kChatMessageIDKey];
//    [chatDetailDictionary setObject:[NSNumber numberWithLongLong:currentDate] forKey:kChatMessageCreatedTime];
//
//    BOOL markChatRoomAsRead = FALSE;
//    if (([messageObj.sender.userID isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]] || [APP_DELEGATE.currentActiveChatRoomId isEqualToString:[chatDetailDictionary objectForKey:kChatRoomIDKey]]) && [UIApplication sharedApplication].applicationState != UIApplicationStateBackground ) {
//        markChatRoomAsRead = TRUE;
//    }
//    if (markChatRoomAsRead && messageObj.isUnread) {
//        NSError *errorObj;
//        BOOL isReadMarked = [messageObj markAsRead:&errorObj];
//        NSLog(@"Error marking message as read : %@",errorObj);
//
//    }
//
//    if ([messagePartObj.MIMEType isEqualToString:MIME_TYPE_IMAGE_PNG] || [messagePartObj.MIMEType isEqualToString:MIME_TYPE_APPLICATION_JSON])
//        [ChatMessage insertNewImageMessageIntoDatabaseFromLayer:chatDetailDictionary forMatchDetail:matchedUserDetail andAlsoMarkChatRoomAsRead:markChatRoomAsRead withMimeType:messagePartObj withCompletionHandler:chatCompletion];
//    else
//        [ChatMessage insertNewChatMessageIntoDatabaseFromLayer:chatDetailDictionary forMatchDetail:matchedUserDetail andAlsoMarkChatRoomAsRead:markChatRoomAsRead withCompletionHandler:chatCompletion];
//}


//-(void)updateLayerChatFromToLocalDB:(LYRMessage *)messageObj withCompletionHandler:(ChatUpdationCompletionHandler)chatCompletion{
//    if (![[NSUserDefaults standardUserDefaults] boolForKey:kUserAlreadyRegistered] || ([messageObj.parts count] <1) || ([messageObj.conversation.participants count] < 2)) {
//        chatCompletion(nil);
//    }
//    
//    LYRMessagePart *messagePartObj = [messageObj.parts.allObjects firstObject];
//    NSString *otherPersonWooId = @"";
//    
//    for (LYRIdentity *participant in messageObj.conversation.participants) {
//        if (![participant.userID isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]]) {
//            otherPersonWooId = participant.userID;
//        }
//    }
//    
//    if ([otherPersonWooId length] < 1) {
//        chatCompletion(nil);
//    }
//    
//    MyMatches *matchedUserDetail = [MyMatches getMatchDetailForMatchedUSerID:otherPersonWooId isApplozic:false];
//   
//    if (matchedUserDetail.isFault == YES || matchedUserDetail == nil) {
//        chatCompletion(nil);
//    }
//    
//    NSMutableDictionary *chatDetailDictionary = [[NSMutableDictionary alloc] init];
//    NSString *msgString = [[NSString alloc] initWithData:messagePartObj.data encoding:NSUTF8StringEncoding];
//    if ([messagePartObj.MIMEType isEqualToString:MIME_TYPE_APPLICATION_JSON]) {             // Message is image message
//        NSDictionary *msgDictionary = [APP_Utilities convertStringToDictionary:msgString];
//        msgString =  [APP_Utilities validString:[msgDictionary objectForKey:@"imageurl"]];
//        NSString *imageSizeString = [NSString stringWithFormat:@"%lld",[[msgDictionary objectForKey:@"imagesize"] longLongValue]];
//        [chatDetailDictionary setObject:[APP_Utilities validString:imageSizeString] forKey:kImageSize];       // size fo the image that is received from other side
//        if ([msgString length]>0) {
//            //If it is a image message that we have to download a low res image of the same.
//            NSString *lowResImageUrl =[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(5), IMAGE_SIZE_FOR_POINTS(5),msgString];
//            [[SDImageCache sharedImageCache] queryCacheOperationForKey:lowResImageUrl done:^(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType) {
//                if (!image) {
//                    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:lowResImageUrl] options:0 progress:nil completed:nil];
//                }
//            }];
////            [[SDImageCache sharedImageCache] queryDiskCacheForKey:lowResImageUrl done:^(UIImage *image, SDImageCacheType cacheType) {
////                if (!image) {
////                    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:lowResImageUrl] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
////                        nil;
////                    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
////                        //                        [self reloadTableData];
////                        nil;
////                    }];
////                }
////            }];
//        }
//    }
//    
//    msgString = [APP_Utilities validString:msgString];
//    [chatDetailDictionary setObject:msgString forKey:kMessageKey];
//    
//    if ([messagePartObj.MIMEType isEqualToString:MIME_TYPE_APPLICATION_JSON]) {
//        [chatDetailDictionary setObject:[NSNumber numberWithInt:IMAGE_SEND_BY_USER] forKey:kMessageTypeKey];    // This will be called when user will receive image from another user(photo clicked or fetched from gallery)
//    }
//    else if ([messagePartObj.MIMEType isEqualToString:MIME_TYPE_IMAGE_PNG]){
//        [chatDetailDictionary setObject:[NSNumber numberWithInt:IMAGE] forKey:kMessageTypeKey];     // This will be called when user will receive sticker
//    }
//    else{
//        [chatDetailDictionary setObject:[NSNumber numberWithInt:TEXT] forKey:kMessageTypeKey];      // This will be called when user will receive text message
//    }
//    [chatDetailDictionary setObject:messageObj.identifier.lastPathComponent forKeyedSubscript:kChatMessageLayerID];
//    
//    NSString *receiverPresonId = @"";
//    for (LYRIdentity *participant in messageObj.conversation.participants) {
//        if (![messageObj.sender.userID isEqualToString:participant.userID]) {
//            receiverPresonId = participant.userID;
//        }
//    }
//    
//    [chatDetailDictionary setObject:messageObj.sender.userID forKey:kMessageSenderIDKey];
//    [chatDetailDictionary setObject:receiverPresonId forKey:kMessageReceiverID];
//    [chatDetailDictionary setObject:[NSNumber numberWithInt:[messageObj recipientStatusForUserID:receiverPresonId]] forKey:kChatMessageDeliveryLayerStatus];
////    if ([messageObj.sender.userID isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]]) {
////        [chatDetailDictionary setObject:receiverPresonId forKey:kChatRoomIDKey];
////    }
////    else{
////        [chatDetailDictionary setObject:messageObj.sender.userID forKey:kChatRoomIDKey];
////    }
//    if(matchedUserDetail.matchId != nil)
//    {
//        [chatDetailDictionary setObject:matchedUserDetail.matchId forKey:kChatRoomIDKey];
//    }
//    else
//    {
//        // has been added when matchId not available because of fault.
//        chatCompletion(nil);
//    }
//    
//    NSTimeInterval currentDate = [[NSDate date] timeIntervalSince1970]*1000;
//    if (messageObj.sentAt) {
//        currentDate = [messageObj.sentAt timeIntervalSince1970]*1000;
//    }
//    [chatDetailDictionary setObject:[NSNumber numberWithLongLong:currentDate] forKey:kChatMessageCreatedTime];
//    
//    BOOL markChatRoomAsRead = FALSE;
//    if ([messageObj.sender.userID isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]] || [APP_DELEGATE.currentActiveChatRoomId isEqualToString:[chatDetailDictionary objectForKey:kChatRoomIDKey]]) {
//        markChatRoomAsRead = TRUE;
//    }
//    if (markChatRoomAsRead && messageObj.isUnread) {
//        NSError *errorObj;
//        BOOL isReadMarked = [messageObj markAsRead:&errorObj];
//        NSLog(@">>Error marking message as read : %@",errorObj);
//    }
//    return [ChatMessage updateMessageIntoDatabaseFromLayer:chatDetailDictionary andAlsoMarkChatRoomAsRead:markChatRoomAsRead withUpdationHandler:chatCompletion];
//}


-(void)insertImageIntoLocalDb:(NSDictionary *)imageChatDetail forChatRoom:(NSString *)chatRoomId withMatchedUserId:(NSString*)messageReceiverID withCompletionHandler:(ChatInsertionCompletionHandler)chatCompletion{
    NSTimeInterval currentDate = [[NSDate date] timeIntervalSince1970]*1000;
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:[NSNumber numberWithLongLong:currentDate] forKey:kChatMessageIDKey];
    [dictionary setObject:[NSNumber numberWithInt:IMAGE_SEND_BY_USER] forKey:kMessageTypeKey];
    [dictionary setObject:[imageChatDetail objectForKey:@"imagePath"] forKey:kMessageKey];
    [dictionary setObject:[NSNumber numberWithBool:TRUE] forKey:kIsDeliveredKey];
    [dictionary setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] forKey:kMessageSenderIDKey];
    [dictionary setObject:[imageChatDetail objectForKey:@"isImageUploaded"] forKey:kIfchatImageIsItUploaded];

    [dictionary setObject:chatRoomId forKey:kChatRoomIDKey];
    [dictionary setObject:messageReceiverID forKey:kMessageReceiverID];
    [dictionary setObject:[NSNumber numberWithLongLong:currentDate] forKey:kChatMessageCreatedTime];
    return [ChatMessage insertNewChatMessageIntoDatabase:dictionary withCompletionHandler:chatCompletion];
}

-(void)insertChatMessageIntoLocalDb:(NSString *)chatMsg forChatRoom:(NSString *)chatRoomId withMatchedUserId:(NSString*)messageSenderID withCompletionHandler:(ChatInsertionCompletionHandler)chatCompletion{
    NSDate* datetime = [NSDate date];    
    if (chatMsg == nil  && [chatMsg length]<1 ) {
        chatMsg = @"";
    }
    
    NSTimeInterval currentDate = [datetime timeIntervalSince1970]*1000;
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:[NSNumber numberWithLongLong:currentDate] forKey:kChatMessageIDKey];
    [dictionary setObject:[NSNumber numberWithInt:TEXT] forKey:kMessageTypeKey];
    [dictionary setObject:chatMsg forKey:kMessageKey];
    [dictionary setObject:[NSNumber numberWithBool:FALSE] forKey:kIsDeliveredKey];
    [dictionary setObject:messageSenderID forKey:kMessageSenderIDKey];
    [dictionary setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] forKey:kMessageReceiverID];
    [dictionary setObject:chatRoomId forKey:kChatRoomIDKey];
    
    [dictionary setObject:[NSNumber numberWithLongLong:currentDate] forKey:kChatMessageCreatedTime];
    return [ChatMessage insertNewChatMessageIntoDatabase:dictionary withCompletionHandler:chatCompletion];
}

/*
//move all these method to layerChatHelperClass
-(void)uploadImageForChatMessage:(ChatMessage *)chatMessageObj withProgressBlock:(ImageUploadProgress)progressBlock withImageUploadSuccessBlock:(ImageUploadSuccessBlock)imageUploadSuccessBlock{

    if ([[APP_Utilities validString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]] length] < 1) {
        return;
    }
    
    
    if ([chatMessageObj.message rangeOfString:@"wooTempImage"].location != NSNotFound) {
        NSLog(@"lakdsfj");
    }
    if ([chatMessageObj.message rangeOfString:@"wooTempImage"].location != NSNotFound) {
        NSString *cacheDirectory = [NSString stringWithFormat:@"%@/%@",[APP_Utilities applicationCacheDirectory],kSelfieImagesFolderName];
        NSString *getImagePath = [cacheDirectory stringByAppendingPathComponent:chatMessageObj.message];
        UIImage *img = [UIImage imageWithContentsOfFile:getImagePath];
        
        NSString *oldImagePath = [cacheDirectory stringByAppendingPathComponent:chatMessageObj.message];
        
        CGSize imageSize = img.size;
        float red = 720.0/imageSize.width;
        CGSize compressedSize = CGSizeMake(imageSize.width*red, imageSize.height*red);
        UIGraphicsBeginImageContext( compressedSize );
        [img drawInRect:CGRectMake(0,0,compressedSize.width,compressedSize.height)];
        UIImage* newCompresssedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData *imageDataAfterCompressed = UIImageJPEGRepresentation(newCompresssedImage,0);
        
        float imaegSizeVal = imageDataAfterCompressed.length;
        if (imaegSizeVal<1) {
            return;
        }
        
        NSString *uploadImageUrl = [NSString stringWithFormat:@"%@%@?wooId=%@",kBaseURLV1,kUploadPictures,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
        [[APIQueue sharedAPIQueue] uploadAnyFileOnServer:uploadImageUrl
                                    withBinaryDataOfFile:imageDataAfterCompressed
                                          withRetryCount:3
                                 withDoYouWantToUseQueue:YES
                                       withCachingPolicy:GET_DATA_FROM_URL_ONLY
                                            withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
                                                NSLog(@"success : %d",success);
                                                NSLog(@"response : %@",response);
                                                NSLog(@"error : %@",error);
                                                NSLog(@"statusCode : %d",statusCode);
                                                imageUploadSuccessBlock(success);
                                                if(success){
                                                    [ChatMessage updateDeliveryStatusOfImage:chatMessageObj.clientMessageID withChatMessage:[response objectForKey:@"photoUrl"]];
                                                    [ChatMessage updateImageSizeOfImageChat:imaegSizeVal forChatId:chatMessageObj.clientMessageID withUpdationHandler:^(BOOL success) {
                                                        [self sendImage:[response objectForKey:@"photoUrl"] forChatRoom:chatMessageObj.chatRoomID withChatObject:chatMessageObj withImageSize:imaegSizeVal];
                                                        NSString *newImageName = [[[response objectForKey:@"photoUrl"] componentsSeparatedByString:@"/"] lastObject];
                                                        NSString *newImagePath = [cacheDirectory stringByAppendingPathComponent:newImageName];
                                                        [APP_Utilities renameFilePresentAtPath:oldImagePath withNewFilePath:newImagePath];
                                                    }];
                                                }
                                                
                                            } withKindOfRequest:uploadPictureToServer andKindOfFileImage:TRUE withProgress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
                                                float received = (float )totalBytesWritten;
                                                float expected = (float )totalBytesExpectedToWrite;
                                                progressBlock(received/expected);
//                                                [progressViewObj setProgress:(received/expected) animated:YES];
                                            } andImageTemporaryName:chatMessageObj.message];
    }
    else{
        [self sendImage:chatMessageObj.message forChatRoom:chatMessageObj.chatRoomID withChatObject:chatMessageObj withImageSize:[chatMessageObj.imageSize floatValue]];
        progressBlock(1.0);
        imageUploadSuccessBlock(TRUE);
    }
    
    
    //    }
}

*/

//-(void)insertUpdateChat:(ChatMessage *)chatObj forLayerMessage:(LYRMessage *)messageObj{
//    if (chatObj) {
//        NSString *receiverPresonId = @"";
//        for (LYRIdentity *participant in messageObj.conversation.participants) {
//            if (![messageObj.sender.userID isEqualToString:participant.userID]) {
//                receiverPresonId = participant.userID;
//            }
//        }
//        [ChatMessage updateLayerIdOfChatMessageWithLayerId:messageObj.identifier.lastPathComponent andDeliveryStatus:[NSNumber numberWithInt:[messageObj recipientStatusForUserID:receiverPresonId]] forChatObject:chatObj withUpdationHandler:nil];
//    }
//}



//move all these method to layerChatHelperClass
-(void)uploadPicAndShowProgressForCell:(SenderImageCell *)chatImageCellObj withCircularProgressView:(EditProfileProgressbar *)progressViewObj forChatMessage:(ChatMessage *)chatMessageObj isSenderFlagged:(BOOL)isFlagged{
    
    if ([chatMessageObj.message rangeOfString:@"wooTempImage"].location != NSNotFound) {
        NSString *cacheDirectory = [NSString stringWithFormat:@"%@/%@",[APP_Utilities applicationCacheDirectory],kSelfieImagesFolderName];
        NSString *getImagePath = [cacheDirectory stringByAppendingPathComponent:chatMessageObj.message];
        UIImage *img = [UIImage imageWithContentsOfFile:getImagePath];
        
        NSString *oldImagePath = [cacheDirectory stringByAppendingPathComponent:chatMessageObj.message];
        
        CGSize imageSize = img.size;
        float red = 720.0/imageSize.width;
        CGSize compressedSize = CGSizeMake(imageSize.width*red, imageSize.height*red);
        UIGraphicsBeginImageContext( compressedSize );
        [img drawInRect:CGRectMake(0,0,compressedSize.width,compressedSize.height)];
        UIImage* newCompresssedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData *imageDataAfterCompressed = UIImageJPEGRepresentation(newCompresssedImage,0);
        
        float imaegSizeVal = imageDataAfterCompressed.length;
        if (imaegSizeVal<1) {
            return;
        }
        
        NSString *uploadImageUrl = [NSString stringWithFormat:@"%@%@?wooId=%@",kBaseURLV1,kUploadPictures,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
        [[APIQueue sharedAPIQueue] uploadAnyFileOnServer:uploadImageUrl
                                    withBinaryDataOfFile:imageDataAfterCompressed
                                          withRetryCount:3
                                 withDoYouWantToUseQueue:YES
                                       withCachingPolicy:GET_DATA_FROM_URL_ONLY
                                            withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
                                                if(success){
                                                    [ChatMessage updateDeliveryStatusOfImage:chatMessageObj.clientMessageID withChatMessage:[response objectForKey:@"photoUrl"]];
                                                    [ChatMessage updateImageSizeOfImageChat:imaegSizeVal forChatId:chatMessageObj.clientMessageID withUpdationHandler:^(BOOL success) {
                                                        [self sendImage:[response objectForKey:@"photoUrl"] forChatRoom:chatMessageObj.chatRoomID withChatObject:chatMessageObj withImageSize:imaegSizeVal isSenderFlagged:isFlagged];
                                                        NSString *newImageName = [[[response objectForKey:@"photoUrl"] componentsSeparatedByString:@"/"] lastObject];
                                                        NSString *newImagePath = [cacheDirectory stringByAppendingPathComponent:newImageName];
                                                        [APP_Utilities renameFilePresentAtPath:oldImagePath withNewFilePath:newImagePath];
                                                    }];
                                                }
                                                
                                            } withKindOfRequest:uploadPictureToServer andKindOfFileImage:TRUE withProgress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
                                                float received = (float )totalBytesWritten;
                                                float expected = (float )totalBytesExpectedToWrite;
                                                progressViewObj.progressValue = (received/expected)*100;
                                            } andImageTemporaryName:chatMessageObj.message];
    }
    else{
        [self sendImage:chatMessageObj.message forChatRoom:chatMessageObj.chatRoomID withChatObject:chatMessageObj withImageSize:[chatMessageObj.imageSize floatValue] isSenderFlagged:isFlagged];
    }
}


- (void)sendImage:(NSString *)messageText forChatRoom:(NSString *)chatRoomId withChatObject:(ChatMessage *)chatObj withImageSize:(float)imageSize isSenderFlagged:(BOOL) isFlagged{

//    __weak MyMatches *matchObj = [MyMatches getMatchDetailForMatchedUSerID:chatRoomId];
//  [[LayerManager sharedLayerManager] getConversationObjectForLayerConversationId:[MyMatches getMatchDetailForMatchID:chatRoomId].layerChatID withCompletionHandler:^(BOOL isSyncCompleted, id  _Nullable conversation, NSError *error) {
//
//        NSDictionary *msgDict =  [[NSDictionary alloc]initWithObjectsAndKeys:messageText,@"imageurl",@"Image",@"imagetype",chatObj.imageSize,@"imagesize",nil];
//
//        NSString *msgStr = [APP_Utilities convertDictionaryToString:(NSMutableDictionary *)msgDict];
//
//      [[LayerManager sharedLayerManager] sendChatToLayer:msgStr ForMimeType:MIME_TYPE_APPLICATION_JSON withPushText:kImageText forConversation:conversation isRequesterFlagged:isFlagged chatSendToLayerCompletion:^(BOOL chatSendSuccessFully, LYRMessage *layerMessageObj) {
//
//              NSError *error = nil;
//              [conversation sendMessage:layerMessageObj error:&error];
//            if (chatObj) {
//                [self updateLayerIdOfChatObject:chatObj withLayerId:layerMessageObj];
//            }
//
////            [LAYER_HELPER insertLayerChatFromToLocalDB:layerMessageObj withCompletionHandler:^(ChatMessage *chatMessageObj) {
////
////            }];
//        }];
//    }];

   
}



//-(void)updateLayerIdOfChatObject:(ChatMessage *)chatMessageObj withLayerId:(LYRMessage *)layerMessageObj{
//    NSString *receiverPresonId = @"";
//    for (LYRIdentity *participant in layerMessageObj.conversation.participants) {
//        if (![layerMessageObj.sender.userID isEqualToString:participant.userID]) {
//            receiverPresonId = participant.userID;
//        }
//    }
//    [ChatMessage updateLayerIdOfChatMessageWithLayerId:layerMessageObj.identifier.lastPathComponent andDeliveryStatus:[NSNumber numberWithInt:[layerMessageObj recipientStatusForUserID:receiverPresonId]] forChatObject:chatMessageObj withUpdationHandler:nil];
//}



@end
