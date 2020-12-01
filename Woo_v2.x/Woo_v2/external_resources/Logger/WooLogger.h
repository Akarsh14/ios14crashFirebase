//
//  WooLogger.h
//  Woo
//
//  Created by Lokesh Sehgal on 30/04/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WooLogger : NSObject
{
    NSMutableArray *allLogs;
    
    BOOL isSaveOrReadInProgress;
}
+(WooLogger *) sharedWooLogger;

-(void)addLoggerInformationForURL:(NSString *)url startTime:(long long)loggingStartTime endTime:(long long)loggingEndTime;

-(void)removeLoggerFile;

@end
