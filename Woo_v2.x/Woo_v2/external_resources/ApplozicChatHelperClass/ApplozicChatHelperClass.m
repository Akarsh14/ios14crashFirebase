//
//  ApplozicChatHelperClass.m
//  Woo_v2
//
//  Created by Akhil Singh on 14/11/18.
//  Copyright © 2018 Woo. All rights reserved.
//


#import "ApplozicChatHelperClass.h"
#import "ApplozicChatManager.h"

@implementation ApplozicChatHelperClass

SINGLETON_FOR_CLASS(ApplozicChatHelperClass)


-(void)insertApplozicChatFromToLocalDB:(ALMessage *)messageObj ifSenderIsMe:(BOOL)isSenderMe withCompletionHandler:(ChatInsertionCompletionHandler)chatCompletion{
    
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kUserAlreadyRegistered] || (messageObj.message == nil || messageObj.message.length <= 0) || (messageObj.to == nil || messageObj.to.length <= 0)) {
        chatCompletion(nil);
        return;
    }
    
    NSString *otherPersonWooId = @"";
    
    if (![messageObj.to isEqualToString:[LoginModel sharedInstance].appLozicUserId]) {
            otherPersonWooId = messageObj.to;
        }
    else{
        otherPersonWooId = [LoginModel sharedInstance].appLozicUserId;
    }
    
    if (([otherPersonWooId length] < 1)) {
        chatCompletion(nil);
        return;
    }
    
    MyMatches *matchedUserDetail = [MyMatches getMatchDetailForMatchedUSerID:otherPersonWooId isApplozic:true];
    
    //Current message time should be greater than match Creation time
    if (matchedUserDetail == nil && [matchedUserDetail.matchedOn compare:[NSDate date]] != NSOrderedAscending) {
        chatCompletion(nil);
        return;
    }
    
    NSMutableDictionary *chatDetailDictionary = [[NSMutableDictionary alloc] init];
    
    NSString *msgString = [[NSString alloc] initWithData:[messageObj.message dataUsingEncoding:NSUTF8StringEncoding] encoding:NSUTF8StringEncoding];
    msgString = [APP_Utilities validString:msgString];
    if ([messageObj.metadata objectForKey:@"imageurl"]!= nil) {// Message is image message
        [chatDetailDictionary setObject:[NSNumber numberWithInt:1] forKey:kIfchatImageIsItUploaded];
        [chatDetailDictionary setObject:[messageObj.metadata objectForKey:@"imageurl"] forKey:kMessageKey];
        [chatDetailDictionary setObject:[NSNumber numberWithInt:IMAGE_SEND_BY_USER] forKey:kMessageTypeKey];    // This will be called when user will receive image from another user(photo clicked or fetched from gallery)
        NSString *imageUrlString = [messageObj.metadata objectForKey:@"imageurl"];
        NSString *imageSizeString = [NSString stringWithFormat:@"%lld",[[messageObj.metadata objectForKey:@"imagesize"] longLongValue]];
        [chatDetailDictionary setObject:[APP_Utilities validString:imageSizeString] forKey:kImageSize];       // size fo the image that is received from other side
        if ([msgString length]>0) {
            //If it is a image message that we have to download a low res image of the same.
            NSString *lowResImageUrl =[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(5), IMAGE_SIZE_FOR_POINTS(5),imageUrlString];
            [[SDImageCache sharedImageCache] queryCacheOperationForKey:lowResImageUrl done:^(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType) {
                if (!image) {
                    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:lowResImageUrl] options:0 progress:nil completed:nil];
                }
            }];
        }
    }
    else{
        [chatDetailDictionary setObject:[NSNumber numberWithInt:TEXT] forKey:kMessageTypeKey];
        [chatDetailDictionary setObject:msgString forKey:kMessageKey];
// This will be called when user will receive text message
    }
    
    NSString *receiverPresonId = @"";
    NSString *senderPersonId = @"";
    if (isSenderMe){
        receiverPresonId = messageObj.to;
        senderPersonId = LoginModel.sharedInstance.appLozicUserId;
    }
    else{
        receiverPresonId = LoginModel.sharedInstance.appLozicUserId;
        senderPersonId = messageObj.to;
    }
    
    [chatDetailDictionary setObject:senderPersonId forKey:kMessageSenderIDKey];
    [chatDetailDictionary setObject:receiverPresonId forKey:kMessageReceiverID];
    [chatDetailDictionary setObject:[messageObj status] forKey:kChatMessageDeliveryLayerStatus];
    
    if (matchedUserDetail.matchId != nil){
    [chatDetailDictionary setObject:matchedUserDetail.matchId forKey:kChatRoomIDKey];
    }
    
    NSTimeInterval currentDate = [[NSDate date] timeIntervalSince1970]*1000;

    [chatDetailDictionary setObject:messageObj.metadata[@"CreatedTime"] forKeyedSubscript:kChatMessageLayerID];
    [chatDetailDictionary setObject:[NSNumber numberWithLongLong:currentDate] forKey:kChatMessageIDKey];
    [chatDetailDictionary setObject:messageObj.metadata[@"CreatedTime"] forKey:kChatMessageCreatedTime];
    
    BOOL markChatRoomAsRead = FALSE;
    if ([APP_DELEGATE.currentActiveChatRoomId isEqualToString:[chatDetailDictionary objectForKey:kChatRoomIDKey]] && [UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
        markChatRoomAsRead = TRUE;
    }
//    if (markChatRoomAsRead && messageObj.isUnread) {
//        NSError *errorObj;
//        BOOL isReadMarked = [messageObj markAsRead:&errorObj];
//        NSLog(@"Error marking message as read : %@",errorObj);
//
//    }
    
    [ChatMessage insertNewChatMessageIntoDatabaseFromLayer:chatDetailDictionary forMatchDetail:matchedUserDetail andAlsoMarkChatRoomAsRead:markChatRoomAsRead withCompletionHandler:chatCompletion];
    
    NSLog(@"wnter here bababababa");
    
}


-(void)updateApplozicChatFromToLocalDB:(ALMessage *)messageObj ifSenderIsMe:(BOOL)isSenderMe withCompletionHandler:(ChatUpdationCompletionHandler)chatCompletion{
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kUserAlreadyRegistered] || (messageObj.message == nil || messageObj.message.length <= 0) || (messageObj.to == nil || messageObj.to.length <= 0)) {
        chatCompletion(nil);
        return;
    }
    
    NSString *otherPersonWooId = @"";
    
    if (![messageObj.to isEqualToString:[LoginModel sharedInstance].appLozicUserId]) {
        otherPersonWooId = messageObj.to;
    }
    else{
        otherPersonWooId = [LoginModel sharedInstance].appLozicUserId;
    }
    
    if (([otherPersonWooId length] < 1)) {
        chatCompletion(nil);
        return;
    }
    
    MyMatches *matchedUserDetail = [MyMatches getMatchDetailForMatchedUSerID:otherPersonWooId isApplozic:true];
    
    //Current message time should be greater than match Creation time
    if (matchedUserDetail == nil && [matchedUserDetail.matchedOn compare:[NSDate date]] != NSOrderedAscending) {
        chatCompletion(nil);
        return;
    }
    
    NSMutableDictionary *chatDetailDictionary = [[NSMutableDictionary alloc] init];
    
    NSString *msgString = [[NSString alloc] initWithData:[messageObj.message dataUsingEncoding:NSUTF8StringEncoding] encoding:NSUTF8StringEncoding];
    msgString = [APP_Utilities validString:msgString];
    if ([messageObj.metadata objectForKey:@"imageurl"]!= nil) {// Message is image message
        [chatDetailDictionary setObject:[NSNumber numberWithInt:1] forKey:kIfchatImageIsItUploaded];
        [chatDetailDictionary setObject:[messageObj.metadata objectForKey:@"imageurl"] forKey:kMessageKey];
        [chatDetailDictionary setObject:[NSNumber numberWithInt:IMAGE_SEND_BY_USER] forKey:kMessageTypeKey];    // This will be called when user will receive image from another user(photo clicked or fetched from gallery)
        NSString *imageUrlString = [messageObj.metadata objectForKey:@"imageurl"];
        NSString *imageSizeString = [NSString stringWithFormat:@"%lld",[[messageObj.metadata objectForKey:@"imagesize"] longLongValue]];
        [chatDetailDictionary setObject:[APP_Utilities validString:imageSizeString] forKey:kImageSize];       // size fo the image that is received from other side
        if ([msgString length]>0) {
            //If it is a image message that we have to download a low res image of the same.
            NSString *lowResImageUrl =[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(5), IMAGE_SIZE_FOR_POINTS(5),imageUrlString];
            [[SDImageCache sharedImageCache] queryCacheOperationForKey:lowResImageUrl done:^(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType) {
                if (!image) {
                    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:lowResImageUrl] options:0 progress:nil completed:nil];
                }
            }];
        }
    }
    else{
        [chatDetailDictionary setObject:[NSNumber numberWithInt:TEXT] forKey:kMessageTypeKey];
        [chatDetailDictionary setObject:msgString forKey:kMessageKey];
        // This will be called when user will receive text message
    }
    
    NSString *receiverPresonId = @"";
    NSString *senderPersonId = @"";
    if (isSenderMe){
        receiverPresonId = messageObj.to;
        senderPersonId = LoginModel.sharedInstance.appLozicUserId;
    }
    else{
        receiverPresonId = LoginModel.sharedInstance.appLozicUserId;
        senderPersonId = messageObj.to;
    }
    
    if (senderPersonId != nil){
        [chatDetailDictionary setObject:senderPersonId forKey:kMessageSenderIDKey];
    }
    
    if (receiverPresonId != nil){
        [chatDetailDictionary setObject:receiverPresonId forKey:kMessageReceiverID];
    }
    if ([messageObj status] != nil){
        [chatDetailDictionary setObject:[messageObj status] forKey:kChatMessageDeliveryLayerStatus];
    }
    else{
        [chatDetailDictionary setObject:[NSNumber numberWithInt:0] forKey:kChatMessageDeliveryLayerStatus];
    }
    [chatDetailDictionary setObject:messageObj.metadata[@"CreatedTime"] forKeyedSubscript:kChatMessageLayerID];
    NSTimeInterval currentDate = [[NSDate date] timeIntervalSince1970]*1000;
    [chatDetailDictionary setObject:[NSNumber numberWithLongLong:currentDate] forKey:kChatMessageIDKey];
    if (matchedUserDetail.matchId != nil){
        [chatDetailDictionary setObject:matchedUserDetail.matchId forKey:kChatRoomIDKey];
    }
        
    [chatDetailDictionary setObject:[NSNumber numberWithLongLong:currentDate] forKey:kChatMessageCreatedTime];
    
    BOOL markChatRoomAsRead = FALSE;
    if ([APP_DELEGATE.currentActiveChatRoomId isEqualToString:[chatDetailDictionary objectForKey:kChatRoomIDKey]] && [UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
        markChatRoomAsRead = TRUE;
    }
    
//    if (markChatRoomAsRead && messageObj.isUnread) {
//        NSError *errorObj;
//        BOOL isReadMarked = [messageObj markAsRead:&errorObj];
//        NSLog(@">>Error marking message as read : %@",errorObj);
//    }
    
    return [ChatMessage updateMessageIntoDatabaseFromLayer:chatDetailDictionary andAlsoMarkChatRoomAsRead:markChatRoomAsRead withUpdationHandler:chatCompletion];
    
}


-(void)insertImageIntoLocalDb:(NSDictionary *)imageChatDetail forChatRoom:(NSString *)chatRoomId withMatchedUser:(MyMatches*)matchesObject withCompletionHandler:(ChatInsertionCompletionHandler)chatCompletion{
    NSTimeInterval currentDate = [[NSDate date] timeIntervalSince1970]*1000;
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:[NSNumber numberWithLongLong:currentDate] forKey:kChatMessageIDKey];
    [dictionary setObject:[NSNumber numberWithInt:IMAGE_SEND_BY_USER] forKey:kMessageTypeKey];
    [dictionary setObject:[imageChatDetail objectForKey:@"imagePath"] forKey:kMessageKey];
    [dictionary setObject:[NSNumber numberWithBool:TRUE] forKey:kIsDeliveredKey];
    [dictionary setObject:chatRoomId forKey:kMessageSenderIDKey];
    [dictionary setObject:[imageChatDetail objectForKey:@"isImageUploaded"] forKey:kIfchatImageIsItUploaded];
    
    [dictionary setObject:matchesObject.matchId forKey:kChatRoomIDKey];
    [dictionary setObject:matchesObject.targetAppLozicId forKey:kMessageReceiverID];
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

    NSDictionary *msgDict =  [[NSDictionary alloc]initWithObjectsAndKeys:messageText,@"imageurl",@"Image",@"imagetype",chatObj.imageSize,@"imagesize",nil];

    [[ApplozicChatManager sharedApplozicChatManager] sendChatToApplozic:chatObj.messageReceiverID forMessage:messageText orImage:true imageData:msgDict andChatObject:chatObj chatSendToApplozicCompletion:^(BOOL chatSendSuccessFully, ChatMessage *messageObj) {
        //[self updateLayerIdOfChatObject:chatObj withObject:messageObj];
    }];
}

-(void)updateLayerIdOfChatObject:(ChatMessage *)chatMessageObj withObject:(ChatMessage *)fromMessageObj{
    [ChatMessage updateLayerIdOfChatMessageWithLayerId:fromMessageObj.layerMessageID andDeliveryStatus:fromMessageObj.chatDeliveryStatus forChatObject:chatMessageObj withUpdationHandler:nil];
}



@end
