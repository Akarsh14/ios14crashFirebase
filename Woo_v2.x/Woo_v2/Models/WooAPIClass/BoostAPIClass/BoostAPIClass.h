//
//  BoostAPIClass.h
//  Woo_v2
//
//  Created by Suparno Bose on 25/01/16.
//  Copyright © 2016 Woo. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Block with id type Response  and BOOL seccess as a parameter
typedef void (^BoostCompletionBlock)(id,BOOL);
static BOOL isfetchingVisitorDataFromServer = false;
@interface BoostAPIClass : NSObject

/*!
 * @discussion Method make the server call to get the Visitors List
 * @param apiPageLength limit for the list
 * @param block completion block for the api call
 */
//+(void)getVisitorsFromServerWithLimit:(NSInteger)apiPageLength AndCompletionBlock:(BoostCompletionBlock)block;
+(void)getVisitorsFromServerWithLimit:(NSInteger)apiPageLength withTime:(NSString *)timeString  withPaginationToken:(NSString *)paginationTokenStr withIndexValue:(int)indexValue AndCompletionBlock:(BoostCompletionBlock)block;

/*!
 * @discussion response of the boost dto is handled inside this method
 * @param response NSString type
 */
+(void)handleBoostResponse:(id)response;

+(BOOL)getIsfetchingVisitorDataFromServerValue;
+(void)setIsfetchingVisitorDataFromServerValue:(BOOL)value;
@end
