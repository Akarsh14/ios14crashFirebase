//
//  BoostModel.h
//  Woo_v2
//
//  Created by Suparno Bose on 12/01/16.
//  Copyright © 2016 Woo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGBase.h>

@interface BoostModel : NSObject

@property (nonatomic) NSInteger         availableBoost;
@property (nonatomic) BOOL              availableInRegion;
@property (nonatomic) CGFloat           percentageCompleted;
@property (nonatomic) BOOL              showInLeftMenu;
@property (nonatomic) long long int     expiryTime;
@property (nonatomic) BOOL              currentlyActive;
@property (nonatomic) BOOL              hasEverPurchased;
@property (nonatomic) NSArray           *skProducts;

+ (BoostModel *)sharedInstance;

- (void)updateDataWithBoostDictionary:(NSDictionary*) boostDics;

- (BOOL)checkIfUserNeedsToPurchase;

- (void)resetModel;

@end
