//
//  BoostCrushAPI.h
//  Woo_v2
//
//  Created by Suparno Bose on 25/01/16.
//  Copyright © 2016 Woo. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Block with id type Response as a parameter
typedef void (^CrushCompletionBlock)(id);
static BOOL isfetchingCrushDataFromServer = false;
@class TargetQuestionModel;

@interface CrushAPIClass : NSObject

/*!
 * @discussion Method make the server call to get the Matches List
 * @param apiPageLength limit for the list
 * @param block completion block for the api call
 */
+(void)getCrushesFromServerWithLimit:(NSInteger)apiPageLength withTime:(NSString *)timeString  withPaginationToken:(NSString *)paginationTokenStr withIndexValue:(int)indexValue AndCompletionBlock:(CrushCompletionBlock)block;

+(void)likeAnAnswer:(TargetQuestionModel *)question successBlock:(CrushCompletionBlock)block;

+(void)getTemplateCrushFromServer;

+(void)deleteMatchWithMatchID:(MyMatches *)matchObj withCommentForUnmatch:(NSString *)comment successBlock:(DeletionCompletionHandler)block;

+(BOOL)getIsfetchingCrushDataFromServerValue;
+(void)setIsfetchingCrushDataFromServerValue:(BOOL)value;

@end
