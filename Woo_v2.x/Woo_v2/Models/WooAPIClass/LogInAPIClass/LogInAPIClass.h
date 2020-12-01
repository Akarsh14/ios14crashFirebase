//
//  LogInAPIClass.h
//  Woo_v2
//
//  Created by Suparno Bose on 4/26/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Block with id type Response as a parameter
typedef void (^LogInCallCompletionBlock)(BOOL,id,int,BOOL);
typedef void (^RegistrationCallCompletionBlock)(BOOL,id,int,BOOL);

@interface LogInAPIClass : NSObject

+(BOOL)isUserFake:(NSString *)userID withGender:(NSString *)genderVal
           andDob:(NSString *)dobVal AndCompletionBlock:(LogInCallCompletionBlock)block;

+(void)handleErrorForResponseCode:(int)responseCode;


+(void)makeLoginCallToServerWithUserId:(NSString *)fbId
                       withAccessToken:(NSString *)accessToken
                          withLocation:(CLLocation *)location
                              withAge : (NSString *)age
                           withGender : (NSString *)gender
                             viaLogin :(NSString *)type
                            AnyTRUECALLERdata:(id)truecallerParameter
                   withCompletionBlock:(LogInCallCompletionBlock)block;


+(void)makeRegistrationCallwithCompletionBlock:(RegistrationCallCompletionBlock)block;
@end
