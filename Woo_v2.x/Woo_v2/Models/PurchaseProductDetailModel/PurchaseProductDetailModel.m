//
//  PurchaseProductDetailModel.m
//  Woo_v2
//
//  Created by Deepak Gupta on 10/7/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "PurchaseProductDetailModel.h"
#import "Woo_v2-Swift.h"

@implementation PurchaseProductDetailModel


+ (PurchaseProductDetailModel *)sharedInstance{
    
    static PurchaseProductDetailModel *sharedInstance = nil;
    if (!sharedInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
            NSData *decodedObject = [userDefault objectForKey: @"PurchaseProductDetailModel"];
            if (decodedObject) {
                sharedInstance = [NSKeyedUnarchiver unarchiveObjectWithData: decodedObject];
            }
            else{
                sharedInstance = [[super allocWithZone:NULL] init];
            }
            /*
            [[NSNotificationCenter defaultCenter] addObserver:sharedInstance
                                                     selector:@selector(appTerminationHandler)
                                                         name:UIApplicationWillResignActiveNotification
                                                       object:nil];
             */
        });
    }
    return sharedInstance;

    
}

+ (id)allocWithZone:(NSZone *)zone {
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    NSData *decodedObject = [userDefault objectForKey: @"PurchaseProductDetailModel"];
    if (decodedObject == nil) {
        return [self sharedInstance];
    }
    else{
        return [super allocWithZone:zone];
    }
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.boostModel forKey:@"boostModel"];
    [encoder encodeObject:self.FreeTrailProductModel forKey:@"FreeTrailProductModel"];
    [encoder encodeObject:self.crushModel forKey:@"crushModel"];
    [encoder encodeObject:self.wooPlusModel forKey:@"wooPlusModel"];
    [encoder encodeObject:self.wooGlobalModel forKey:@"wooGlobalModel"];
    [encoder encodeObject:self.productsLastUpdatedTime forKey:@"productsLastUpdatedTime"];
    [encoder encodeObject:self.userProductPriceUpdatedTime forKey:@"userProductPriceUpdatedTime"];

}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if( self != nil )
    {
        //decode properties, other class vars
        self.boostModel         = [decoder decodeObjectForKey:@"boostModel"];
        self.FreeTrailProductModel = [decoder decodeObjectForKey:@"FreeTrailProductModel"];
        self.crushModel         = [decoder decodeObjectForKey:@"crushModel"];
        self.wooPlusModel       = [decoder decodeObjectForKey:@"wooPlusModel"];
        self.wooGlobalModel       = [decoder decodeObjectForKey:@"wooGlobalModel"];
        self.productsLastUpdatedTime       = [decoder decodeObjectForKey:@"productsLastUpdatedTime"];
        self.userProductPriceUpdatedTime       = [decoder decodeObjectForKey:@"userProductPriceUpdatedTime"];

    }
    return self;
}

#pragma mark - Update Purchase Product Detail Model
- (void)updatePurchaseProductDetailModel:(NSDictionary*)purchaseProductDetailData{
    
    CrushProductModel *crushModel = [[CrushProductModel alloc] init];
    [crushModel addWithData:[purchaseProductDetailData objectForKey:kPurchaseProductCrushDto]];
    
    self.crushModel = crushModel;
    
    BoostProductModel *boostModel = [[BoostProductModel alloc] init];
    [boostModel addWithData:[purchaseProductDetailData objectForKey:kPurchaseProductBoostDto]];
    
    self.boostModel = boostModel;

    WooPlusProductModel *wooPlusModel = [[WooPlusProductModel alloc] init];
    [wooPlusModel addWithData:[purchaseProductDetailData objectForKey:kPurchaseProductWooPlusDto]];
    
    self.wooPlusModel = wooPlusModel;
    
    WooGlobalProductModel *wooGlobalModel = [[WooGlobalProductModel alloc] initWithData:[purchaseProductDetailData objectForKey:kPurchaseProductWooGlobeDto]];

    self.wooGlobalModel = wooGlobalModel;
    
    NSMutableArray *storeIdArray = [NSMutableArray array];
    for (NSDictionary *data in self.wooGlobalModel.wooProductDto){
        if ([data objectForKey:@"i_store"]){
            if ([[data objectForKey:@"i_store"] objectForKey:@"storeProductId"]){
                [storeIdArray addObject:[[data objectForKey:@"i_store"] objectForKey:@"storeProductId"]];
            }
        }
    }
    
    NSSet *productSet = [NSSet setWithArray:storeIdArray];
    [[InAppPurchaseManager sharedIAPManager] getAllProductsFromAppleWithProductIdentifiers:productSet withProductCount:@"0" withCallback:^(BOOL success, BOOL canMakePurchase, NSArray *productsArray) {
        if (success){
            self.wooGlobalModel.skProducts = productsArray;
        }
    }];
    
    self.productsLastUpdatedTime = [NSNumber numberWithLongLong:[[purchaseProductDetailData objectForKey:kProductsLastUpdatedTime] longLongValue]];
    self.userProductPriceUpdatedTime = [NSNumber numberWithLongLong:[[purchaseProductDetailData objectForKey:kUserProductPriceUpdatedTime] longLongValue]];

    
    [self saveModelInUserDefaults];
    
}



-(void) saveModelInUserDefaults{
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:self];
    [userDefault setObject:encodedObject forKey:@"PurchaseProductDetailModel"];
    [userDefault synchronize];
}

- (void)resetModel{
    self.boostModel = nil;
    self.crushModel = nil;
    self.wooPlusModel = nil;
    self.productsLastUpdatedTime = nil;
    self.userProductPriceUpdatedTime = nil;
    self.productType = nil;
    self.FreeTrailProductModel = nil;
}

@end
