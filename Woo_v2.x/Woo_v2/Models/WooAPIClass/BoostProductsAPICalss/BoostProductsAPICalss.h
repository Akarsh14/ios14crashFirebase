//
//  BoostProductsAPICalss.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 01/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^BoostAPICompletionBlock)(BOOL success, id responseObj, int errorNumber);

typedef void (^ActivateBoostCompletionBlock)(BOOL success, id responseObj, int statusCode);

@interface BoostProductsAPICalss : NSObject


+(void)getProductsFromServerForWooID:(NSString *)wooID withCompletionBlock:(BoostAPICompletionBlock)block withType:(NSString *)productType;


+(void)activateBoostForWooID:(NSString *)wooID withCompletionBlock:(ActivateBoostCompletionBlock) block;

+(void)makePopupEventAPIwithType:(NSString *)productType;

+(void)makeMatchFailureEventCallToServerWithTargetId:(NSString *)tagetId;
@end
