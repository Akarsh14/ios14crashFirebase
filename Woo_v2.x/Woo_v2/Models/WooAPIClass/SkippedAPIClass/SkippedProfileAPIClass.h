//
//  SkippedProfileAPIClass.h
//  Woo_v2
//
//  Created by Umesh Mishraji on 30/08/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Block with id type Response  and BOOL seccess as a parameter
typedef void (^SkippedProfileCompletionBlock)(id,BOOL);
static BOOL isfetchingSkippedDataFromServer = false;


@interface SkippedProfileAPIClass : NSObject

/*!
 * @discussion Method make the server call to get the Visitors List
 * @param apiPageLength limit for the list
 * @param block completion block for the api call
 */
//+(void)getSkippedProfilesFromServerWithLimit:(NSInteger)apiPageLength AndCompletionBlock:(SkippedProfileCompletionBlock)block;
+(void)getSkippedProfilesFromServerWithLimit:(NSInteger)apiPageLength withTime:(NSString *)timeString  withPaginationToken:(NSString *)paginationTokenStr withIndexValue:(int)indexValue; // AndCompletionBlock:(SkippedProfileCompletionBlock)block;

/*!
 * @discussion response of the boost dto is handled inside this method
 * @param response NSString type
 */
+(void)handleLikedMeResponse:(id)response;


+(void)setIsfetchingSkippedDataFromServerValue:(BOOL)value;
+(BOOL)getIsfetchingSkippedDataFromServerValue;

@end
