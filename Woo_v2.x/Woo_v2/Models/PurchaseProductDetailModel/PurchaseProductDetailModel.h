//
//  PurchaseProductDetailModel.h
//  Woo_v2
//
//  Created by Deepak Gupta on 10/7/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CrushProductModel.h"
#import "BoostProductModel.h"
#import "WooPlusProductModel.h"
#import "FreeTrailProductModel.h"

@class WooGlobalProductModel;

@interface PurchaseProductDetailModel : NSObject


+ (PurchaseProductDetailModel *)sharedInstance;

- (void)updatePurchaseProductDetailModel:(NSDictionary*)purchaseProductDetailData;

- (void)resetModel;

 // Boost Model
@property (nonatomic , strong) BoostProductModel                        *boostModel;

// Crush Data
@property (nonatomic , strong) CrushProductModel                        *crushModel;

// WooPlus Data
@property (nonatomic , strong) WooPlusProductModel                       *wooPlusModel;

@property (nonatomic , strong) WooGlobalProductModel                    *wooGlobalModel;

@property (nonatomic , strong) FreeTrailProductModel                    *FreeTrailProductModel;

//Products TimeStamp
@property (nonatomic , strong)NSNumber                             *productsLastUpdatedTime;

@property (nonatomic , strong)NSNumber                             *userProductPriceUpdatedTime;

@property (nonatomic , strong)NSString                             *productType;

@end
