//
//  FreeTrailModel.m
//  Woo_v2
//
//  Created by Harish kuramsetty on 30/07/19.
//  Copyright © 2019 Woo. All rights reserved.
//

#import "FreeTrailModel.h"

@implementation FreeTrailModel

+ (FreeTrailModel *)sharedInstance{
    static FreeTrailModel *sharedInstance = nil;
    if (!sharedInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
            NSData *decodedObject = [userDefault objectForKey: @"FreeTrailModel"];
            if (decodedObject) {
                sharedInstance = [NSKeyedUnarchiver unarchiveObjectWithData: decodedObject];
            }
            else{
                sharedInstance = [[super allocWithZone:NULL] init];
            }
            [[NSNotificationCenter defaultCenter] addObserver:sharedInstance
                                                     selector:@selector(appTerminationHandler)
                                                         name:UIApplicationWillResignActiveNotification
                                                       object:nil];
        });
    }
    return sharedInstance;
}


- (id)init{
    self = [super init];
    if (self){
       
    }
    return self;
}

+ (id)allocWithZone:(NSZone *)zone {
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    NSData *decodedObject = [userDefault objectForKey: @"FreeTrailModel"];
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
    [encoder encodeObject:[NSNumber numberWithUnsignedLongLong:self.offerId] forKey:@"offerId"];
    [encoder encodeObject:self.offerType forKey:@"offerType"];
    [encoder encodeObject:[NSNumber numberWithUnsignedLongLong:self.noOfDays]forKey:@"noOfDays"];
     [encoder encodeObject:[NSNumber numberWithBool:self.isSubscribeType] forKey:@"isSubscribeType"];
    [encoder encodeObject:self.planId forKey:@"planId"];
    [encoder encodeObject:self.productName forKey:@"productName"];
     [encoder encodeObject:[NSNumber numberWithUnsignedLongLong:self.validityTime] forKey:@"validityTime"];
    [encoder encodeObject:[NSNumber numberWithUnsignedLongLong:self.price] forKey:@"price"];
    [encoder encodeObject:self.pricePerUnit forKey:@"pricePerUnit"];
    [encoder encodeObject:self.priceUnit forKey:@"priceUnit"];
    [encoder encodeObject:[NSNumber numberWithUnsignedLongLong:self.count] forKey:@"count"];
    [encoder encodeObject:self.discount forKey:@"discount"];
    [encoder encodeObject:self.productNamePerUnit forKey:@"productNamePerUnit"];
    [encoder encodeObject:self.storeProductId forKey:@"storeProductId"];

}


- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if( self != nil )
    {
        //decode properties, other class vars
        self.noOfDays     = [[decoder decodeObjectForKey:@"noOfDays"] intValue];
        self.offerType     = [decoder decodeObjectForKey:@"offerType"] ;
        self.offerId     = [[decoder decodeObjectForKey:@"offerId"]intValue] ;
        self.isSubscribeType         = [[decoder decodeObjectForKey:@"isSubscribeType"] boolValue];
        self.planId         = [decoder decodeObjectForKey:@"planId"];
        self.productName     = [decoder decodeObjectForKey:@"productName"] ;
        self.validityTime     = [[decoder decodeObjectForKey:@"validityTime"] longLongValue];
         self.price     = [[decoder decodeObjectForKey:@"price"] intValue];
          self.pricePerUnit     = [decoder decodeObjectForKey:@"pricePerUnit"] ;
          self.priceUnit     = [decoder decodeObjectForKey:@"priceUnit"] ;
         self.count     = [[decoder decodeObjectForKey:@"count"] intValue];
        self.discount     = [decoder decodeObjectForKey:@"discount"] ;
        self.productNamePerUnit     = [decoder decodeObjectForKey:@"productNamePerUnit"] ;
        self.storeProductId = [decoder decodeObjectForKey:@"storeProductId"];
    }
    return self;
}


-(void) appTerminationHandler{
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:self];
    [userDefault setObject:encodedObject forKey:@"FreeTrailModel"];
    [userDefault synchronize];
}

- (void)updateDataWithOfferDtoDictionary:(NSDictionary*) productDto{
    
    if (productDto.count  == 0){
        self.noOfDays = 0;
        self.offerType = @"";
        self.offerId = 0;
        self.isSubscribeType = false;
        self.planId = @"";
        self.productName = @"";
        self.validityTime = 0;
        self.price = 0;
        self.pricePerUnit = @"";
        self.priceUnit = @"";
        self.productNamePerUnit = @"";
        self.count = 0;
        self.storeProductId = @"";
    }else{
    
   if ([productDto valueForKey:@"noOfDays"]) {
        self.noOfDays = [[productDto valueForKey:@"noOfDays"]intValue];
    }
    
    if ([productDto valueForKey:@"offerType"]) {
        self.offerType = [productDto valueForKey:@"offerType"];
    }
    
    if ([productDto valueForKey:@"offerId"]) {
        self.offerId = [[productDto valueForKey:@"offerId"]intValue];
    }
    
    NSDictionary *OfferDtoDict = [productDto valueForKey:@"wooProductDto"];
    
    
    if ([OfferDtoDict valueForKey:@"isSubscribeType"]) {
        self.isSubscribeType = [[OfferDtoDict valueForKey:@"isSubscribeType"]boolValue];
    }
    
    if ([OfferDtoDict valueForKey:@"planId"]) {
        self.planId = [OfferDtoDict valueForKey:@"planId"];
    }
    
    if ([OfferDtoDict valueForKey:@"productName"]) {
        self.productName = [OfferDtoDict valueForKey:@"productName"];
    }
    
    if ([OfferDtoDict valueForKey:@"validityTime"]) {
        self.validityTime = [[OfferDtoDict valueForKey:@"validityTime"] longLongValue] ;
    }
    
    if ([OfferDtoDict valueForKey:@"price"]) {
        self.price = [[OfferDtoDict valueForKey:@"price"] intValue];
    }
    
    if ([OfferDtoDict valueForKey:@"pricePerUnit"]) {
        self.pricePerUnit = [OfferDtoDict valueForKey:@"pricePerUnit"];
    }
    
    if ([OfferDtoDict valueForKey:@"priceUnit"]) {
        self.priceUnit = [OfferDtoDict valueForKey:@"priceUnit"];
    }
    
    if ([OfferDtoDict valueForKey:@"discount"]) {
        self.discount = [OfferDtoDict valueForKey:@"discount"];
    }
    
    if ([OfferDtoDict valueForKey:@"productNamePerUnit"]) {
        self.productNamePerUnit = [OfferDtoDict valueForKey:@"productNamePerUnit"];
    }
    
   if ([OfferDtoDict valueForKey:@"count"]) {
        self.count = [[OfferDtoDict valueForKey:@"count"] intValue];
    }
    
    if ([OfferDtoDict valueForKey:@"i_store"]) {
        NSDictionary *storeValue = [OfferDtoDict valueForKey:@"i_store"];
        if([storeValue valueForKey:@"storeProductId"]){
           self.storeProductId = [storeValue valueForKey:@"storeProductId"];
        }
    }
    
    NSMutableArray *storeIdArray = [NSMutableArray array];
    [storeIdArray addObject:self.storeProductId];
    
    NSSet *productSet = [NSSet setWithArray:storeIdArray];
    [[InAppPurchaseManager sharedIAPManager] getAllProductsFromAppleWithProductIdentifiers:productSet withProductCount:@"0" withCallback:^(BOOL success, BOOL canMakePurchase, NSArray *productsArray) {
        if (success){
            self.skProducts = productsArray;
        }
    }];
    }
    
    [self appTerminationHandler];

}






-(void)resetModel{
    self.isSubscribeType  = false;
    self.planId = @"";
    self.productName = @"";
    self.storeProductId = @"";
    self.priceUnit = 0;
    self.noOfDays = 0;
}

@end
