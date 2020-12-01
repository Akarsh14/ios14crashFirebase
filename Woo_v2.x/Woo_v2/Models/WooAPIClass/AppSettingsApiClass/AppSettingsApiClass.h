//
//  AppSettingsApiClass.h
//  Woo_v2
//
//  Created by Akhil Singh on 23/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

typedef void (^AppSettingsApiCompletionBlock)(BOOL,id,int);

#import <Foundation/Foundation.h>

@interface AppSettingsApiClass : NSObject

+(void)sendFeedbackToServer:(NSString *)feedBackString andNumberOfStars:(int)stars
                   andEmail:(NSString*)mail
             andPhoneNumber:(NSString*)phoneNumber
        WithCompletionBlock:(AppSettingsApiCompletionBlock)block;
+ (void)logoutUserWithCompletionBlock:(AppSettingsApiCompletionBlock)block;
+ (void)disableUserWithCompletionBlock:(AppSettingsApiCompletionBlock)block;
+ (void)deleteUserWithUserComment:(NSString *)comment withEmail:(NSString *)email andPhoneNumber:(NSString *)phoneNumber andDeleteFeedback:(BOOL)feedback WithCompletionBlock:(AppSettingsApiCompletionBlock)block;
//+ (void)sendontactDetails:(nsstring *)phoneNumber and

@end
