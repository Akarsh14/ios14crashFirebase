//
//  MeApiClass.h
//  Woo_v2
//
//  Created by Ankit Batra on 05/04/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^SyncViewsApiCompletionBlock)(BOOL, id);

@interface MeApiClass : NSObject

+(void)syncProfileViews:(NSArray *)selectedViewers withCompletionBlock:(SyncViewsApiCompletionBlock)block;

@end
