//
//  LayerChatHelperClass.h
//  Woo
//
//  Created by Umesh Mishra on 31/03/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Utilities.h"
typedef void (^ImageUploadProgress) (float progressVal);
typedef void (^ImageUploadSuccessBlock) (BOOL imageUploadedSuccess);

@interface LayerChatHelperClass : NSObject


+(LayerChatHelperClass *)sharedLayerChatHelperClass;


//-(void)insertLayerChatFromToLocalDB:(LYRMessage *)messageObj withCompletionHandler:(ChatInsertionCompletionHandler)chatCompletion;

//-(void)updateLayerChatFromToLocalDB:(LYRMessage *)messageObj withCompletionHandler:(ChatUpdationCompletionHandler)chatCompletion;


-(void)insertImageIntoLocalDb:(NSDictionary *)imageChatDetail forChatRoom:(NSString *)chatRoomId withMatchedUserId:(NSString*)messageReceiverID withCompletionHandler:(ChatInsertionCompletionHandler)chatCompletion;

-(void)insertChatMessageIntoLocalDb:(NSString *)chatMsg forChatRoom:(NSString *)chatRoomId withMatchedUserId:(NSString*)messageSenderID withCompletionHandler:(ChatInsertionCompletionHandler)chatCompletion;

-(void)uploadPicAndShowProgressForCell:(SenderImageCell *)chatImageCellObj withCircularProgressView:(EditProfileProgressbar *)progressViewObj forChatMessage:(ChatMessage *)chatMessageObj isSenderFlagged:(BOOL)isFlagged;

//-(void)uploadImageForChatMessage:(ChatMessage *)chatMessageObj withProgressBlock:(ImageUploadProgress)progressBlock withImageUploadSuccessBlock:(ImageUploadSuccessBlock)imageUploadSuccessBlock;


@end
