//
//  WooPlusModel.h
//  Woo_v2
//
//  Created by Deepak Gupta on 7/13/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WooPlusModel : NSObject

@property (nonatomic) BOOL                  availableInRegion;
@property (nonatomic) BOOL                  isExpired;
@property (nonatomic , strong) NSString     *subscriptionId;
@property (nonatomic) BOOL                  hasEverPurchased;

@property (nonatomic) BOOL              showExpiryEnabledForVisitors;
@property (nonatomic) BOOL              maskingEnabledForVisitors;
@property (nonatomic) BOOL              showExpiryEnabledForLikedMe;
@property (nonatomic) BOOL              maskingEnabledForLikedMe;
@property (nonatomic) BOOL              showExpiryEnabledForSkippedProfiles;
@property (nonatomic) BOOL              maskingEnabledForSkippedProfiles;

- (void)updateDataWithWooPlusDictionary:(NSDictionary*)wooPlusDict;
+ (WooPlusModel *)sharedInstance;
@end
