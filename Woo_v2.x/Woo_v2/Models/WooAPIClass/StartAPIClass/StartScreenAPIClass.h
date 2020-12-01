//
//  StartAPIClass.h
//  Woo_v2
//
//  Created by Deepak Gupta on 6/30/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^StartScreenCompletionBlock)(id,BOOL,int);

@interface StartScreenAPIClass : NSObject


+(void)makeStartScreenCallWithCompletionBlock:(StartScreenCompletionBlock)block;

@end
