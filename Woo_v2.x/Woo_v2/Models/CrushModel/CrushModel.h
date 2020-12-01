//
//  CrushModel.h
//  Woo_v2
//
//  Created by Suparno Bose on 12/01/16.
//  Copyright © 2016 Woo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CrushModel : NSObject

@property (nonatomic) NSInteger             availableCrush;
@property (nonatomic) BOOL                  availableInRegion;
@property (nonatomic) long long int         expiryTime;
//@property (nonatomic) BOOL                  hasPurchased;
@property (nonatomic) BOOL                  showInLeftMenu;
@property (nonatomic) NSInteger             totalCrush;
@property (nonatomic) long long int         crushMessagesUpdatedTime;
@property (nonatomic) NSInteger             crushMsgCharsLimit;
@property (nonatomic) BOOL                  hasEverPurchased;

@property(nonatomic, strong) NSArray *templateQuestionArray;

+ (CrushModel *)sharedInstance;

- (void)updateDataWithCrushDictionary:(NSDictionary*) crushDics;

- (BOOL)checkIfUserNeedsToPurchase;

- (void)resetModel;

@end
