
//
//  WooPlusProductModel.m
//  Woo_v2
//
//  Created by Deepak Gupta on 10/7/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "WooPlusProductModel.h"

@implementation WooPlusProductModel

- (void)addWithData:(NSDictionary *)dictData{
    
    self.backGroundImages = [dictData objectForKey:kPurchaseProductBackGroundImages];
    
    self.baseImageUrl = [NSString stringWithFormat:@"%@iOS/drawable-@3x/",[dictData objectForKey:kPurchaseProductBaseUrl]];
    
    self.carousalType = [dictData objectForKey:kPurchaseProductCarousalType];
    
    self.circleImage = [dictData objectForKey:kPurchaseProductCircleImage];
    
    self.wooProductDto = [dictData objectForKey:kPurchaseProductWooProductDto];
    
    self.carousals = [dictData objectForKey:kPurchaseProductCarousals];
    
    self.isToShowMostPopular = [dictData objectForKey:kIsToShowMostPopular];

    NSMutableArray *storeIdArray = [NSMutableArray array];
    for (NSDictionary *data in self.wooProductDto){
        if ([data objectForKey:@"i_store"]){
            if ([[data objectForKey:@"i_store"] objectForKey:@"storeProductId"]){
                [storeIdArray addObject:[[data objectForKey:@"i_store"] objectForKey:@"storeProductId"]];
            }
        }
    }
    
    NSSet *productSet = [NSSet setWithArray:storeIdArray];
    [[InAppPurchaseManager sharedIAPManager] getAllProductsFromAppleWithProductIdentifiers:productSet withProductCount:@"0" withCallback:^(BOOL success, BOOL canMakePurchase, NSArray *productsArray) {
        if (success){
            self.skProducts = productsArray;
        }
    }];
    
    [APP_Utilities precacheCarouselDataWithData:self.carousals circleImage:self.circleImage backgroundImage:self.backGroundImages andBaseURL:self.baseImageUrl];
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
    [encoder encodeObject:self.backGroundImages forKey:@"backGroundImages"];
    [encoder encodeObject:self.baseImageUrl forKey:@"baseImageUrl"];
    [encoder encodeObject:self.carousalType forKey:@"carousalType"];
    [encoder encodeObject:self.circleImage forKey:@"circleImage"];
    [encoder encodeObject:self.wooProductDto forKey:@"wooProductDto"];
    [encoder encodeObject:self.carousals forKey:@"carousals"];
    [encoder encodeObject:self.isToShowMostPopular forKey:@"isToShowMostPopular"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if( self != nil )
    {
        //decode properties, other class vars
        self.backGroundImages         = [decoder decodeObjectForKey:@"backGroundImages"];
        self.baseImageUrl         = [decoder decodeObjectForKey:@"baseImageUrl"];
        self.carousalType         = [decoder decodeObjectForKey:@"carousalType"];
        self.circleImage         = [decoder decodeObjectForKey:@"circleImage"];
        self.wooProductDto         = [decoder decodeObjectForKey:@"wooProductDto"];
        self.carousals         = [decoder decodeObjectForKey:@"carousals"];
        self.isToShowMostPopular = [decoder decodeObjectForKey:@"isToShowMostPopular"];

        
    }
    return self;
}


@end
