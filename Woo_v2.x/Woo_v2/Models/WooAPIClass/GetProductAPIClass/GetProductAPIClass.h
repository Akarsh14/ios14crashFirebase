//
//  GetProductAPIClass.h
//  Woo_v2
//
//  Created by Deepak Gupta on 10/7/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PurchaseProductDetailAPICompletionBlock)(BOOL success, id responseObj, int errorNumber);


@interface GetProductAPIClass : NSObject


+(void)getPurchaseProductsDetailFromServerWithCompletionBlock:(PurchaseProductDetailAPICompletionBlock)block;


@end
