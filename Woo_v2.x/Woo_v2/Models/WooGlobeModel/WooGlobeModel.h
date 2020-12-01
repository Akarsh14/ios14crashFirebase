//
//  WooGlobeModel.h
//  Woo_v2
//
//  Created by Akhil Singh on 17/11/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WooGlobeModel : NSObject

@property (nonatomic, strong) NSString          *wooGlobeLocationCity;
@property (nonatomic, strong) NSString          *wooGlobeLocationState;
@property (nonatomic, assign) BOOL              locationOption;
@property (nonatomic, assign) BOOL              ethnicityOption;
@property (nonatomic, strong) NSArray           *ethnicityArray;
@property (nonatomic, assign) BOOL              religionOption;
@property (nonatomic, strong) NSArray           *religionArray;
@property (nonatomic, assign) BOOL              isExpired;
@property (nonatomic, assign) BOOL              isAvailableInRegion;
@property (nonatomic, assign) BOOL              wooGlobleOption;
@property (nonatomic, assign) BOOL              hasEverPurchased;
@property (nonatomic, strong) NSDictionary      *wooGlobeLocationDictionary;

//bool to stop values from updating from app luanch call, if woo globe purchase is started.
@property (nonatomic, assign) BOOL wooGlobePurchaseStarted;

+ (WooGlobeModel *)sharedInstance;

- (void)updateDataWithWooGlobeDictionary:(NSDictionary*) wooGlobeDict;
-(void)updateWooGlobeAvailibilityData:(NSDictionary *)wooGlobeDetail;

- (void)resetModel;

-(void)setEthnicityArrayValue:(NSArray *)newEthnicityArray;

@end
