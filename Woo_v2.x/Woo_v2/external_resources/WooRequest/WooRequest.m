//
//  WooRequest.m
//  Woo
//
//  Created by Lokesh Sehgal on 31/03/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "WooRequest.h"

#define kURL @"url"

#define kTime @"time"

#define kRequestParams @"requestParams"

#define kMethodType @"methodType"

#define kNumberOfRetries @"numberOfRetries"

#define kCachePolicy @"cachePolicy"

#define kCallback @"callback"

#define kRequestType @"requestType"

#define kIsJsonContentType @"isJsonContentType"

@implementation WooRequest

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.url forKey:kURL];
    [encoder encodeFloat:self.time forKey:kTime];
    [encoder encodeObject:self.requestParams forKey:kRequestParams];
    [encoder encodeInt:self.methodType forKey:kMethodType];
    [encoder encodeInt:self.numberOfRetries forKey:kNumberOfRetries];
    [encoder encodeInt:self.cachePolicy forKey:kCachePolicy];
//    [encoder encodeObject:self.callback forKey:kCallback];
    [encoder encodeInt:self.requestType forKey:kRequestType];
    [encoder encodeBool:self.isJsonContentType forKey:kIsJsonContentType];
}

- (id)initWithCoder:(NSCoder *)decoder {
//    NSString *url = [decoder decodeObjectForKey:kURL];
//    float time = [decoder decodeFloatForKey:kTime];
//    NSDictionary *requestParams = [decoder decodeObjectForKey:kRequestParams];
//    methodType methodType = [decoder decodeIntForKey:kMethodType];
//    int numberOfRetries = [decoder decodeIntForKey:kNumberOfRetries];
//    AFNetworkingCachingPolicy cachePolicy = [decoder decodeIntForKey:kCachePolicy];
//    APICompletionBlock callback =[decoder decodeObjectForKey:kCallback];
//    kindOfRequest kindOfRequest =[decoder decodeIntForKey:kRequestType];
    if (self = [super init]) {
        self.url = [decoder decodeObjectForKey:kURL];
        self.time = [decoder decodeFloatForKey:kTime];
        self.requestParams = [decoder decodeObjectForKey:kRequestParams];
        self.methodType = [decoder decodeIntForKey:kMethodType];
        self.numberOfRetries = [decoder decodeIntForKey:kNumberOfRetries];
        self.cachePolicy = [decoder decodeIntForKey:kCachePolicy];
//        self.callback =[decoder decodeObjectForKey:kCallback];
        self.requestType =[decoder decodeIntForKey:kRequestType];
        self.isJsonContentType = [decoder decodeBoolForKey:kIsJsonContentType];
    }
    return self;
}

@end
