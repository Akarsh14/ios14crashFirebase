//
//  ProfileAPIClass.h
//  Woo_v2
//
//  Created by Suparno Bose on 04/02/16.
//  Copyright © 2016 Woo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^FetchUserDataCompletionBlock)(id,BOOL,int);

@interface ProfileAPIClass : NSObject

+(void)updateMyProfileDataForUserWithPayload:(NSString*)payloadString
                             AndProfilePicID:(NSString*)profilePicID
                          AndCompletionBlock:(FetchUserDataCompletionBlock)block;

+(void)fetchDataForUserWithUserID:(long long int)targetID
              withCompletionBlock:(FetchUserDataCompletionBlock)block;

@end
