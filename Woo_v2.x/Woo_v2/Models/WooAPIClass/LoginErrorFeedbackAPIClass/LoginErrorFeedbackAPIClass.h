//
//  LoginErrorFeedbackAPIClass.h
//  Woo_v2
//
//  Created by Deepak Gupta on 6/15/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^LoginErrorFeedbackCompletionBlock)(id,BOOL);

@interface LoginErrorFeedbackAPIClass : NSObject


+(void)submitFeedbackForLoginError:(NSString *)strFeedback  withCompletionBlock:(LoginErrorFeedbackCompletionBlock)block;

@end
