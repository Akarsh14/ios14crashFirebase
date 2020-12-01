//
//  ApplozicChatHelperClass.h
//  Woo_v2
//
//  Created by Akhil Singh on 14/11/18.
//  Copyright © 2018 Woo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Utilities.h"
#import "Applozic.h"

typedef void (^ImageUploadProgress) (float progressVal);
typedef void (^ImageUploadSuccessBlock) (BOOL imageUploadedSuccess);

NS_ASSUME_NONNULL_BEGIN

@interface ApplozicChatHelperClass : NSObject

+(ApplozicChatHelperClass *)sharedApplozicChatHelperClass;

-(void)insertApplozicChatFromToLocalDB:(ALMessage *)messageObj ifSenderIsMe:(BOOL)isSenderMe withCompletionHandler:(ChatInsertionCompletionHandler)chatCompletion;

-(void)updateApplozicChatFromToLocalDB:(ALMessage *)messageObj ifSenderIsMe:(BOOL)isSenderMe withCompletionHandler:(ChatUpdationCompletionHandler)chatCompletion;

-(void)insertImageIntoLocalDb:(NSDictionary *)imageChatDetail forChatRoom:(NSString *)chatRoomId withMatchedUser:(MyMatches*)matchesObject withCompletionHandler:(ChatInsertionCompletionHandler)chatCompletion;

-(void)insertChatMessageIntoLocalDb:(NSString *)chatMsg forChatRoom:(NSString *)chatRoomId withMatchedUserId:(NSString*)messageSenderID withCompletionHandler:(ChatInsertionCompletionHandler)chatCompletion;

-(void)uploadPicAndShowProgressForCell:(SenderImageCell *)chatImageCellObj withCircularProgressView:(EditProfileProgressbar *)progressViewObj forChatMessage:(ChatMessage *)chatMessageObj isSenderFlagged:(BOOL)isFlagged;

@end

NS_ASSUME_NONNULL_END
