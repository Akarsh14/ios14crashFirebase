//
//  FreeTrailProductModel.m
//  Woo_v2
//
//  Created by Harish kuramsetty on 07/08/19.
//  Copyright © 2019 Woo. All rights reserved.
//

#import "FreeTrailProductModel.h"

@implementation FreeTrailProductModel

- (void)addWithData:(NSString *)planId storeProductId:(NSString *)storeProdcutId{
    
    NSMutableArray *storeIdArray = [NSMutableArray array];
    [storeIdArray addObject:storeProdcutId];
    
    NSSet *productSet = [NSSet setWithArray:storeIdArray];
    [[InAppPurchaseManager sharedIAPManager] getAllProductsFromAppleWithProductIdentifiers:productSet withProductCount:@"0" withCallback:^(BOOL success, BOOL canMakePurchase, NSArray *productsArray) {
        if (success){
            self.skProducts = productsArray;
        }
    }];
}

- (SKProduct *)getProductToBePurchased:(NSString *)storeId{
    for (SKProduct *product in self.skProducts){
        if ([[product productIdentifier] isEqualToString:storeId]){
            return product;
        }
    }
    return nil;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.storeProductId forKey:@"storeProductId"];
    [encoder encodeObject:self.skProducts forKey:@"skProducts"];
    
    
    [encoder encodeObject:self.planId forKey:@"planId"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if( self != nil )
    {
        //decode properties, other class vars
        self.planId         = [decoder decodeObjectForKey:@"planId"];
        self.storeProductId         = [decoder decodeObjectForKey:@"storeProductId"];
        self.skProducts = [decoder decodeObjectForKey:@"skProducts"];
        
    }
    return self;
}


@end
