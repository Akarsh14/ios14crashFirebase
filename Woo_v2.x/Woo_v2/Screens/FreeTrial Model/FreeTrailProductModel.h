//
//  FreeTrailProductModel.h
//  Woo_v2
//
//  Created by Harish kuramsetty on 07/08/19.
//  Copyright © 2019 Woo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FreeTrailProductModel : NSObject

@property (nonatomic, strong) NSArray                                   *skProducts;
@property(nonatomic, strong)NSString *storeProductId;
@property(nonatomic, strong)NSString *planId;

- (void)addWithData:(NSString *)dictData storeProductId:(NSString *)storeProdcutId;
- (SKProduct *)getProductToBePurchased:(NSString *)storeId;

@end

NS_ASSUME_NONNULL_END
