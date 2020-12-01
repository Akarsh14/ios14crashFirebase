//
//  LikedByMeAPIClass.h
//  Woo_v2
//
//  Created by Harish Kuramsetty on 11/18/19.
//  Copyright © 2019 Woo. All rights reserved.
//



#import <Foundation/Foundation.h>

/// Block with id type Response  and BOOL seccess as a parameter
typedef void (^LikedByMeProfileCompletionBlock)(id,BOOL);
static BOOL isfetchingLikedByMeDataFromServer = false;


@interface LikedByMeAPIClass : NSObject

/*!
 * @discussion Method make the server call to get the Visitors List
 * @param apiPageLength limit for the list
 * @param block completion block for the api call
 */
//+(void)getLikedByMeProfilesFromServerWithLimit:(NSInteger)apiPageLength AndCompletionBlock:(LikedByMeProfileCompletionBlock)block;
+(void)getLikedByMeProfilesFromServerWithLimit:(NSInteger)apiPageLength withTime:(NSString *)timeString  withPaginationToken:(NSString *)paginationTokenStr withIndexValue:(int)indexValue; // AndCompletionBlock:(LikedByMeProfileCompletionBlock)block;

/*!
 * @discussion response of the boost dto is handled inside this method
 * @param response NSString type
 */
+(void)handleLikedMeResponse:(id)response;


+(void)setIsfetchingLikedByMeDataFromServerValue:(BOOL)value;
+(BOOL)getIsfetchingLikedByMeDataFromServerValue;

@end
