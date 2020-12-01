//
//  WooRequest.h
//  Woo
//
//  Created by Lokesh Sehgal on 31/03/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^APICompletionBlock)(BOOL success, id response, NSError *error,int statusCode, kindOfRequest requestType);

@interface WooRequest : NSObject<NSCoding>
{
	
}

@property (nonatomic,strong) NSString *url;

@property (nonatomic,assign) BOOL isJsonContentType;

@property (nonatomic,assign) long long time;

@property (nonatomic,strong) NSDictionary *requestParams;

@property (nonatomic,assign) methodType methodType;

@property (nonatomic,assign) int numberOfRetries;

@property (nonatomic,assign) AFNetworkingCachingPolicy cachePolicy;

@property (nonatomic,copy) APICompletionBlock callback;

@property (nonatomic,assign) kindOfRequest requestType;

@end

