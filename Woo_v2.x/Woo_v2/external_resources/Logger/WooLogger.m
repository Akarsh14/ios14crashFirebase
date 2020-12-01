//
//  WooLogger.m
//  Woo
//
//  Created by Lokesh Sehgal on 30/04/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "WooLogger.h"

@implementation WooLogger

static dispatch_queue_t background_API_Loggin_Queue() {
    static dispatch_queue_t api_logging;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        api_logging = dispatch_queue_create("com.u2opiamobile.woo.api_logging", DISPATCH_QUEUE_CONCURRENT );
    });
    
    return api_logging;
}

WooLogger *wooLoggerObject = nil;

+(WooLogger *) sharedWooLogger
{
	if(nil == wooLoggerObject)
	{
		wooLoggerObject = [[WooLogger alloc] init];
        
        [[WooLogger sharedWooLogger] initializeWooLoggingOptions];
	}
    
	return wooLoggerObject;
}

-(void)initializeWooLoggingOptions{
    if(!allLogs){
        allLogs = [[NSMutableArray alloc] init];
    }
    [self checkIfFileExistsOrCreateOne];

    dispatch_sync(background_API_Loggin_Queue(), ^{
        [self getLogFileContents];        
    });
    
    [self performSelector:@selector(uploadLoggerFileOnServer) withObject:nil afterDelay:60.0f];
    
}

-(void)addLoggerInformationForURL:(NSString *)url startTime:(long long)loggingStartTime endTime:(long long)loggingEndTime{

    dispatch_sync(background_API_Loggin_Queue(), ^{

        @synchronized (allLogs){
        
            int indexOfLog = 0;
            
            BOOL isThereANeedToAddALog = TRUE;
            
            for(NSString *log in allLogs){

                NSArray *logInfo = [log componentsSeparatedByString:@"|"];

                if([[logInfo objectAtIndex:0] hasPrefix:url]){
                    
                    NSString *updatedLog = @"";
                    
                    if(loggingEndTime>0){
                        updatedLog = [NSString stringWithFormat:@"%@|%@|%lld",url,[logInfo objectAtIndex:1],loggingEndTime];
                        [allLogs replaceObjectAtIndex:indexOfLog withObject:updatedLog];
                        isThereANeedToAddALog = FALSE;
                        break;
                    }

                    if(loggingStartTime>0){
                        updatedLog = [NSString stringWithFormat:@"%@|%lld|0",url,loggingStartTime];
                        [allLogs replaceObjectAtIndex:indexOfLog withObject:updatedLog];
                        isThereANeedToAddALog = FALSE;
                        break;
                    }
                }
                
                indexOfLog++;
            }
            
            if(isThereANeedToAddALog){
                [allLogs addObject:[NSString stringWithFormat:@"%@|%lld|0",url,loggingStartTime]];
            }
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(syncTheFileAndArray) object:nil];
            
            [self performSelector:@selector(syncTheFileAndArray) withObject:nil afterDelay:30.0f];
                
        }
    });
}

-(void)syncTheFileAndArray{

    if(!isSaveOrReadInProgress){

        isSaveOrReadInProgress = TRUE;
        
        [self performSelector:@selector(saveContentsToTheFile) withObject:nil afterDelay:1.0f];
        
        [self performSelector:@selector(getLogFileContents) withObject:nil afterDelay:3.0f];
        
//        [self performSelector:@selector(uploadLoggerFileOnServer) withObject:nil afterDelay:10.0f];
    }
}

-(NSString*)getDirectoryPathForRequests{
    
    NSString *cacheDirectory = [APP_Utilities applicationCacheDirectory];

    NSString *userWooID = [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId];

    NSString *appFile = @"";
    
    if(([[APP_Utilities validString:userWooID] length]>0)){
        
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        
        format.dateFormat = @"dd-MM-yyyy";
        
        appFile = [cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"woo_%@_%@.txt",userWooID,[format stringFromDate:[NSDate date]]]];
    }
    
    return appFile;
}

-(void)checkIfFileExistsOrCreateOne{

    dispatch_sync(background_API_Loggin_Queue(), ^{

        if(![[self getDirectoryPathForRequests] isEqualToString:@""]){
            if(![[NSFileManager defaultManager] fileExistsAtPath:[self getDirectoryPathForRequests]]){
                [[NSFileManager defaultManager] createFileAtPath:[self getDirectoryPathForRequests] contents:nil attributes:nil];
            }
        }
        
    });
}

-(void)saveContentsToTheFile{
    
    if(![[self getDirectoryPathForRequests] isEqualToString:@""]){
     
        if( [allLogs count] >0 ){

            @synchronized (allLogs){
            
                [self checkIfFileExistsOrCreateOne];
                
                NSString *logsNeedToBeSaved =[allLogs componentsJoinedByString:@"\n"];
            
                [logsNeedToBeSaved writeToFile:[self getDirectoryPathForRequests] atomically:YES encoding:NSUTF8StringEncoding error:nil];
             
            }
        }
    }
}

-(void)getLogFileContents{

    if(![[self getDirectoryPathForRequests] isEqualToString:@""]){

        [self checkIfFileExistsOrCreateOne];
        
        NSString *contents = [NSString stringWithContentsOfFile:[self getDirectoryPathForRequests] encoding:NSUTF8StringEncoding error:nil];
        
        if([allLogs count]>0){
            [allLogs removeAllObjects];
        }

        [allLogs addObjectsFromArray:[contents componentsSeparatedByString:@"\n"]];
        
        isSaveOrReadInProgress = FALSE;
            
    }
}

-(void)removeLoggerFile{

    dispatch_sync(background_API_Loggin_Queue(), ^{
        
        if(![[self getDirectoryPathForRequests] isEqualToString:@""]){
            
            isSaveOrReadInProgress = FALSE;
            
            if([[NSFileManager defaultManager] fileExistsAtPath:[self getDirectoryPathForRequests]]){
                [[NSFileManager defaultManager] removeItemAtPath:[self getDirectoryPathForRequests] error:nil];
            }
        }
        
    });

}

-(void)uploadLoggerFileOnServer{

    dispatch_sync(background_API_Loggin_Queue(), ^{
        
        NSString *URLincludingTheUserId = [NSString stringWithFormat:@"%@%@",kBaseURLV1,kUploadLoggingFile];
        
        AFHTTPRequestOperationManager  *httpRequestOperationManagerObj = [AFHTTPRequestOperationManager manager];
        
        NSData *binaryData = [NSData dataWithContentsOfFile:[self getDirectoryPathForRequests]];
        
        if(binaryData==nil){

            isSaveOrReadInProgress = FALSE;
            
            return ;
        }

        NSString *userWooID = [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId];
        
        [httpRequestOperationManagerObj POST:URLincludingTheUserId parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            // Change the mime type from here = http://reference.sitepoint.com/html/mime-types-full and replace according to your need

            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            
            format.dateFormat = @"dd-MM-yyyy";

            [formData appendPartWithFileData:binaryData name:@"file" fileName:[NSString stringWithFormat:@"woo_%@_%@.txt",userWooID,[format stringFromDate:[NSDate date]]] mimeType:@"multipart/form-data"];
            
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [self removeLoggerFile];
            
            [self checkIfFileExistsOrCreateOne];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            NSLog(@"erorr %@",error);
        } caching:GET_DATA_FROM_URL_ONLY andNumberOfRetries:1];
            
    });
}
@end
