//
//  NSObject+UCaching.m
//  AFNetworkingWithCache
//
//  Created by Vaibhav Gautam on 02/07/13.
//  Copyright (c) 2013 Vaibhav Gautam. All rights reserved.
//

#import "NSObject+UCaching.h"
#import "AFNetworking.h"
#import <objc/runtime.h>
#import "Reachability.h"
#import <CommonCrypto/CommonDigest.h>

//NSString * const cachePolicyInUseKey = @"cachePolicyInUseKey";
static char const * const Key = "oKey";

@implementation NSObject (UCaching)
//@dynamic tag;
//
//-(void)setTag:(NSInteger)tag{
//    objc_setAssociatedObject(self, Key, (id)[NSNumber numberWithInt:tag], OBJC_ASSOCIATION_ASSIGN);
//}
//
//-(NSInteger)tag{
//    return (NSInteger)objc_getAssociatedObject(self, Key);
//}

//-(NSString *)cachePolicyInUse{
//    return objc_getAssociatedObject(self, (__bridge const void *)(cachePolicyInUseKey));
//}
//
//
//-(void)setCachePolicyInUse:(NSString *)policyToBeUsed{
//    objc_setAssociatedObject(self, (__bridge const void *)(cachePolicyInUseKey), policyToBeUsed, OBJC_ASSOCIATION_COPY);
//}


-(BOOL) checkIfCachedDataExistsForURL:(NSURLRequest *)urlObj{

    NSFileManager *fileManagerObj =[[NSFileManager alloc]init];
    
    NSArray *documentDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *urlString = [NSString stringWithFormat:@"%@",urlObj.URL];
    
    NSString *urlInMD5 = [self stringToMD5:urlString];
    
    NSString *fullPath = [[documentDirectory lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json",urlInMD5]];
    
    
    if ([fileManagerObj fileExistsAtPath:fullPath]) {
        return YES;
        
//        NSLog(@"cache exists");
    }else{
        return NO;
//        NSLog(@"cache doesnt exists");
    }

}

-(void)cacheJSONToDisk:(id)jsonResponse forURL:(NSURL *)url{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    
    NSError *error;
    if(jsonResponse)
    {
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonResponse
                                                           options:kNilOptions
                                                             error:&error];
        BOOL succeed = [jsonData writeToFile:[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json",[self stringToMD5:[NSString stringWithFormat:@"%@",url]]]] atomically:YES];
        
    //    BOOL succeed = [[NSString stringWithFormat:@"%@",jsonResponse] writeToFile:[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json",[self stringToMD5:[NSString stringWithFormat:@"%@",url]]]]
    //                              atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (!succeed){
            // Handle error here
        }
    }
}

-(NSString *) getCachedDataForRequest:(NSURLRequest *)reqObj withValidCacheTimeInterval:(long long)timeInterval{

    
    if (![self checkIfCachedDataExistsForURL:reqObj]) {
        return NULL;
    }else{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json",[self stringToMD5:[NSString stringWithFormat:@"%@",reqObj.URL]]]];
                
        NSError *err = nil;
        
        NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&err];
        
        NSDate *createdDate = [dict valueForKey:NSFileCreationDate];
        
        long long createdTimeInterval = [createdDate timeIntervalSince1970];
        
        NSDate *currentDate = [NSDate date];
        
        long long currentTimeInterval = [currentDate timeIntervalSince1970];

        NSString *content;
        NSData *contentData;
        long long timeIntervalBewteenCacheDateAndCurrentDate = currentTimeInterval - createdTimeInterval;
        
        if(timeIntervalBewteenCacheDateAndCurrentDate < timeInterval )
        {
            NSError *error;
            contentData = [NSData dataWithContentsOfFile:filePath];
            if(contentData)
            {
                content = [NSJSONSerialization JSONObjectWithData:contentData
                                                           options:kNilOptions
                                                             error:&error];
            }
//            content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
        }
        
        return content;
    }
}


#pragma mark - helper methods -
- (NSString *)stringToMD5:(NSString *)str {
    const char *cstr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, strlen(cstr), result);
    
    NSString *md5String = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",result[0], result[1], result[2], result[3],result[4], result[5], result[6], result[7],result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]];
    
    return md5String;
    
}



-(BOOL)reachable {
//    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
//    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if([[NetworkManager SharedNetworkManager] checkIfInternetConnectionAvailable]) {
        return NO;
    }
    return YES;
}


-(void)clearJSONCache{
    
    NSString *extension = @"json";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        
        if ([[filename pathExtension] isEqualToString:extension]) {
            
            [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];
        }
    }
}

@end
