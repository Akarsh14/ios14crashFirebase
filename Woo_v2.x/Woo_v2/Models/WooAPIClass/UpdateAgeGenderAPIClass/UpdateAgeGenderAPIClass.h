//
//  UpdateAgeGenderAPIClass.h
//  Woo_v2
//
//  Created by Deepak Gupta on 6/7/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^UpdateAgeGenderCompletionBlock)(id,BOOL);

@interface UpdateAgeGenderAPIClass : NSObject

+(void)updateAgeGenderWithUserId:(NSString *)userId withAge:(NSString *)age withGender:(NSString *)gender withCompletionBlock:(UpdateAgeGenderCompletionBlock)block;

@end
