//
//  NSObject+UCaching.h
//  AFNetworkingWithCache
//
//  Created by Vaibhav Gautam on 02/07/13.
//  Copyright (c) 2013 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "Reachability.h"


#define CACHE_DURATION 604800

@interface NSObject (UCaching)

/**
 Selected Caching policy
 Added by Vaibhav Gautam
 */
//@property(nonatomic, copy) NSString* cachePolicyInUse;


-(NSString *) getCachedDataForRequest:(NSURLRequest *)reqObj withValidCacheTimeInterval:(long long)timeInterval;

-(void) removeCachedDataForURL:(NSURL *)urlObj;

-(void) flushCachedData;

-(BOOL) checkIfCachedDataExistsForURL:(NSURLRequest *)urlObj;

-(void) setExpiryTimeForCache:(NSURL *)urlObj;

-(void) setCachedDataForURL:(NSURL *)urlObj;

-(void)cacheJSONToDisk:(id)jsonResponse forURL:(NSURL *)url;

-(void)clearJSONCache;

//-(void)setCachePolicy:(AFNetworkingCachingPolicy)policy;

-(BOOL)reachable;
@end
