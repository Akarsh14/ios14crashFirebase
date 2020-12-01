//
//  FreeTrailModel.h
//  Woo_v2
//
//  Created by Harish kuramsetty on 30/07/19.
//  Copyright © 2019 Woo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InAppPurchaseManager.h"
NS_ASSUME_NONNULL_BEGIN
@interface FreeTrailModel : NSObject
@property (nonatomic, assign) long long int  noOfDays;
@property (nonatomic, strong) NSString  *offerType;
@property (nonatomic, assign) long long int   offerId;
@property (nonatomic, assign) _Bool isSubscribeType;
@property (nonatomic, strong) NSString *planId;
@property (nonatomic, strong) NSString *productName;
@property (nonatomic, assign) long long validityTime;
@property (nonatomic, strong) NSString *validityUnit;
@property (nonatomic, assign) long long int price;
@property (nonatomic, strong) NSString *pricePerUnit;
@property (nonatomic, strong) NSString *priceUnit;
@property (nonatomic, assign) long long int count;
@property (nonatomic, strong) NSString *discount;
@property (nonatomic, assign) NSString *productNamePerUnit;
@property(nonatomic, strong) NSString *storeProductId;
- (void)updateDataWithOfferDtoDictionary:(NSDictionary*) productDto;
@property (nonatomic, strong) NSArray                                   *skProducts;

+ (FreeTrailModel *)sharedInstance;
-(void)resetModel;

@end
NS_ASSUME_NONNULL_END
