//
//  UpdateUserLocationAPIClass.h
//  Woo_v2
//
//  Created by Deepak Gupta on 6/8/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^UpdateUserLocationCompletionBlock)(id,BOOL);

@interface UpdateUserLocationAPIClass : NSObject


+(void)makeLocationCallToServerWithLatitudeWithCompletionBlock:(UpdateUserLocationCompletionBlock)block;


@end
