//
//  PhoneVerifyApiClass.m
//  Woo_v2
//
//  Created by Akhil Singh on 06/06/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

#import "PhoneVerifyApiClass.h"

@implementation PhoneVerifyApiClass

+(void)generateOTPForMobileNumber:(NSString *)phoneNumber andCountryDto:(CountryDtoModel *)countryDto withCompletionBlock:(PhoneVerifyApiCompletionBlock)block{
    NSString *generateOtpUrl = [NSString stringWithFormat:@"%@/foneverify/generateOtp",kBaseURLV4];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    NSString *countryCode = [@"+" stringByAppendingFormat:@"%@", countryDto.countryCode];
    [parameters setValue:[countryCode stringByAppendingFormat:@"%@", phoneNumber] forKey:@"phoneNumber"];
    [parameters setValue:countryDto.countryCode forKey:@"countryCode"];
    
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =generateOtpUrl;
    wooRequestObj.time =0;
    wooRequestObj.requestParams =parameters;
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries =0;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = likeOrDislikeAProfile;
    wooRequestObj.isJsonContentType = true;

    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        block(success, response, statusCode);
        
    }shouldReachServerThroughQueue:FALSE];

}

+(void)verifyOTPForMobileNumber:(NSString *)accessToken OTP:(NSString *)otpCode andCountryDto:(CountryDtoModel *)countryDto withCompletionBlock:(PhoneVerifyApiCompletionBlock)block{
    
   NSString *generateOtpUrl = [NSString stringWithFormat:@"%@/foneverify/verify/otp",kBaseURLV4];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:accessToken forKey:@"accessToken"];
    [parameters setValue:otpCode forKey:@"otp"];
    
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =generateOtpUrl;
    wooRequestObj.time =0;
    wooRequestObj.requestParams =parameters;
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries =0;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = likeOrDislikeAProfile;
    wooRequestObj.isJsonContentType = true;

    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        block(success, response, statusCode);
        
    }shouldReachServerThroughQueue:FALSE];
    
}

+(void)verifyPhoneForAccessToken:(NSString *)accessToken Request:(BOOL)FromTrueCaller trueCallerParameters:(id)TruecallerParameters withCompletionBlock:(PhoneVerifyApiCompletionBlock)block{
    
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId];
    
    if ([[APP_Utilities validString:userID] length] == 0){
        return;
    }
    
    NSString *verifyPhoneUrl = @"";
    if(FromTrueCaller){
      verifyPhoneUrl = [NSString stringWithFormat:@"%@%@?wooId=%@",kBaseURLV3,kVerifyPhoneNumber,userID];
    }else{
     verifyPhoneUrl = [NSString stringWithFormat:@"%@%@?wooId=%@&access_token=%@",kBaseURLV3,kVerifyPhoneNumber,userID,accessToken];
    
    }
    //    NSLog(@"likeAProfileURL :%@",likeAProfileURL);
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =verifyPhoneUrl;
    wooRequestObj.time =0;
    wooRequestObj.requestParams = (FromTrueCaller) ? TruecallerParameters : nil;
    wooRequestObj.methodType = postRequest;
    wooRequestObj.numberOfRetries =0;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = likeOrDislikeAProfile;
    wooRequestObj.isJsonContentType = true;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        if (statusCode == 200){
        [[DiscoverProfileCollection sharedInstance] updateMyProfileData:response];
        }
        block(success, response, statusCode);
        
    }shouldReachServerThroughQueue:FALSE];
    
}



@end
