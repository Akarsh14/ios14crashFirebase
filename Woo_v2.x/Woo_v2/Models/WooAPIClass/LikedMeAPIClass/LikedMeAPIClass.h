//
//  LikedMeAPIClass.h
//  Woo_v2
//
//  Created by Suparno Bose on 25/01/16.
//  Copyright © 2016 Woo. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Block with id type Response  and BOOL seccess as a parameter
typedef void (^LikedMeCompletionBlock)(id,BOOL);
static BOOL isfetchingLikedMeDataFromServer = false;
@interface LikedMeAPIClass : NSObject{
    
}

/*!
 * @discussion Method make the server call to get the Visitors List
 * @param apiPageLength limit for the list
 * @param block completion block for the api call
 */
//+(void)getLikedMeProfilesFromServerWithLimit:(NSInteger)apiPageLength AndCompletionBlock:(LikedMeCompletionBlock)block;

+(void)getLikedMeProfilesFromServerWithLimit:(NSInteger)apiPageLength withTime:(NSString *)timeString withPaginationToken:(NSString *)paginationTokenStr withIndexValue:(int)indexValue AndCompletionBlock:(LikedMeCompletionBlock)block;

/*!
 * @discussion response of the boost dto is handled inside this method
 * @param response NSString type
 */
+(void)handleLikedMeResponse:(id)response;

+(BOOL)getIsfetchingLikedMeDataFromServerValue;
+(void)setIsfetchingLikedMeDataFromServerValue:(BOOL)value;

@end
