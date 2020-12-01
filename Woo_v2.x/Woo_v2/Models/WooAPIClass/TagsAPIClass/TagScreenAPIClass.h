//
//  TagScreenAPIClass.h
//  Woo_v2
//
//  Created by Umesh Mishraji on 30/06/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TagScreenAPIClass : NSObject

+(void)getTagsDataFromServer:(void(^)(BOOL success, int statusCode, id response))successBlock;
+(void)postTagsDataToServerWithTagsArray:(NSArray *)tagsArray withType:(NSString *)type andSuccessBlock:(void(^)(BOOL success, int statusCode, id response))successBlock;

@end
