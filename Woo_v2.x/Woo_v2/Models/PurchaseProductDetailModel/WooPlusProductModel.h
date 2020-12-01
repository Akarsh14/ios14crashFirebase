//
//  WooPlusProductModel.h
//  Woo_v2
//
//  Created by Deepak Gupta on 10/7/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface WooPlusProductModel : NSObject

@property (nonatomic , strong) NSArray                                  *backGroundImages;
@property (nonatomic , strong) NSString                                    *baseImageUrl;
@property (nonatomic , strong) NSString                                 *carousalType;
@property (nonatomic , strong) NSString                                 *circleImage;
@property (nonatomic , strong) NSArray                                  *wooProductDto;
@property (nonatomic , strong) NSArray                                  *carousals;
@property (nonatomic , strong) NSNumber                                 *isToShowMostPopular;
@property (nonatomic, strong) NSArray                                   *skProducts;



- (void)addWithData:(NSDictionary *)dictData;
- (SKProduct *)getProductToBePurchased:(NSString *)storeId;

@end
