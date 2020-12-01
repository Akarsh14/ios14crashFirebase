//
//  PhoneVerifyApiClass.h
//  Woo_v2
//
//  Created by Akhil Singh on 06/06/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CountryDtoModel.h"

typedef void (^PhoneVerifyApiCompletionBlock)(BOOL, id, int);

@interface PhoneVerifyApiClass : NSObject

+(void)generateOTPForMobileNumber:(NSString *)phoneNumber andCountryDto:(CountryDtoModel *)countryDto withCompletionBlock:(PhoneVerifyApiCompletionBlock)block;
+(void)verifyOTPForMobileNumber:(NSString *)accessToken OTP:(NSString *)otpCode andCountryDto:(CountryDtoModel *)countryDto withCompletionBlock:(PhoneVerifyApiCompletionBlock)block;
+(void)verifyPhoneForAccessToken:(NSString *)accessToken Request:(BOOL)FromTrueCaller trueCallerParameters:(id)TruecallerParameters withCompletionBlock:(PhoneVerifyApiCompletionBlock)block;
@end
