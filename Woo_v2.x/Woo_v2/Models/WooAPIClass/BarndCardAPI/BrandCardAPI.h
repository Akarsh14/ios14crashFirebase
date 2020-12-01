//
//  BrandCardAPI.h
//  Woo_v2
//
//  Created by Suparno Bose on 30/06/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BrandCardAPI : NSObject

+ (void) updateBrandCardPassStatusOnServer : (NSString *)clickPass And: (NSString *) cardId;

+ (void) updateSelectionCardPassStatusOnServer : (NSString *)subCardType And: (NSString *) cardId AndSelectedValues : (NSArray*) selectedValues;

+ (void) updateSelectionCardPassStatusOnServer : (NSString *)subCardType And: (NSString *) cardId AndSelectedValues : (NSArray*) selectedValues withCompletionHandler:(void(^)(BOOL success, NSArray *ethnicityResponse))block;

@end
