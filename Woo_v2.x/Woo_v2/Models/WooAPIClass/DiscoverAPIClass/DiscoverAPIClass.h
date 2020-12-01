//
//  DiscoverAPIClass.h
//  Woo_v2
//
//  Created by Suparno Bose on 26/05/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TagModel;

typedef void (^DiscoverAPICompletionBlock)(BOOL, id, int);

@interface DiscoverAPIClass : NSObject

+(void)fetchDiscoverDataFromServer:(BOOL)paginationEnabled
                             AndPrefrence: (BOOL)isExtended
                        isTagSelected:(BOOL)tagSelected
                AndCompletionBlock:(DiscoverAPICompletionBlock) block;

+ (void)makeLikeCallWithParams:(NSString *)otherPersonWooId andSelectedTag:(NSDictionary *)selectedTag withTagId:( NSString* _Nullable )tagId andTagDTOType:(NSString* _Nullable)tagType AndCompletionBlock:(DiscoverAPICompletionBlock _Nullable ) block;

+ (void)makePassCallWithParams:(NSString *)otherPersonWooId AndCompletionBlock:(DiscoverAPICompletionBlock) block;

+ (void)makePassCallWithParams:(NSString *)otherPersonWooId withSubsource:(NSString *)subsourceString withTagId:( NSString* _Nullable )tagId andTagDTOType:(NSString* _Nullable)tagType  AndCompletionBlock:(DiscoverAPICompletionBlock _Nullable ) block;

+ (void)makeSendCrushCallWithParams:(NSString *)otherPersonWooId andCrushText:(NSString *)crushText AndCompletionBlock:(DiscoverAPICompletionBlock) block;

+(void)fetchDiscoverDataFromServerWithRequestBody:(BOOL)paginationEnabled AndPrefrence: (BOOL)isExtended isTagSelected:(BOOL)tagSelected AndCompletionBlock:(DiscoverAPICompletionBlock _Nullable ) block;

@end
