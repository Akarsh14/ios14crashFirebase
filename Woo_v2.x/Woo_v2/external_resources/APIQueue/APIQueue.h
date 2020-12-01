//
//  APIQueue.h
//  Woo
//
//  Created by Lokesh Sehgal on 19/02/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFHTTPRequestOperationManager.h"

#import <CoreTelephony/CTCarrier.h>

#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "UStack.h"

#import "WooRequest.h"


#import "AFHTTPRequestOperationManager.h"

#import "AFURLSessionManager.h"

#import <CoreTelephony/CTCarrier.h>

#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "WooRequest.h"

#import "WooLogger.h"

@interface APIQueue : NSObject
{
    // Add something here if needed
    
    UStack *workingQueue;
    
    UStack *pendingQueue;
    
    UStack *failedQueue;
    
    UStack *imageUploadQueue;
    
    int maxWorkingQueueCount;
    
    int sizeOfPendingQueue;
    
    AFHTTPRequestOperationManager *httpRequestOperationManagerObj;
    
    CTTelephonyNetworkInfo *telephonyInfo;
    
    NSMutableArray *downloadTaskArray;
    BOOL isDownloadingFileInProgress;
    
    AFURLSessionManager *manager;
    NSProgress *mainProgressObj;
    
    
}

typedef void (^APICompletionBlock)(BOOL success, id response, NSError *error,int statusCode, kindOfRequest requestType);
typedef void (^ProgressBlock)(NSUInteger __unused bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite);

@property(nonatomic, assign)ProgressBlock downloadProgressBlockObj;

#pragma mark shared instance of API Queue

/**
 @author : Lokesh Sehgal
 This method will return the shared instance of the API Queue
 */

+(APIQueue *) sharedAPIQueue;

/**
 @author : Lokesh Sehgal
 This method will upload any file on server
 @param : URL - Url for the request,
 time - time to cache the response
 params - Request parameters if needed in any call (POST Generally)
 kindOfRequest - Is it a get/post/delete request
 numberOfRetries - Number of retries before returning back the callback
 useQueue - Is there any need to use the queue.
 cachingPolicyToBeUsedForCall - Cachiny policy to be used for the call (GET_DATA_FROM_CACHE_ONLY, GET_DATA_FROM_URL_ONLY, GET_DATA_FROM_URL_IF_FAIL_GET_DATA_FROM_CACHE,GET_DATA_FROM_URL_AND_UPDATE_CACHE)
 callback - This will return the callback - success/failure.
 */
-(void)uploadAnyFileOnServer:(NSString *)URLincludingTheUserId withBinaryDataOfFile:(NSData*)binaryData withRetryCount:(NSInteger)numberOfRetries withDoYouWantToUseQueue:(BOOL)useQueue withCachingPolicy:(AFNetworkingCachingPolicy)cachingPolicyToBeUsedForCall withCallback:(APICompletionBlock)callback withKindOfRequest:(kindOfRequest)requestType andKindOfFileImage:(BOOL)isImage;


-(void)uploadAnyFileOnServer:(NSString *)URLincludingTheUserId withBinaryDataOfFile:(NSData*)binaryData withRetryCount:(NSInteger)numberOfRetries withDoYouWantToUseQueue:(BOOL)useQueue withCachingPolicy:(AFNetworkingCachingPolicy)cachingPolicyToBeUsedForCall withCallback:(APICompletionBlock)callback withKindOfRequest:(kindOfRequest)requestType andKindOfFileImage:(BOOL)isImage withProgress:(ProgressBlock)progress andImageTemporaryName:(NSString *)imageName;
/**
 @author : Lokesh Sehgal
 This method will upload any file on server
 @param :URL - url of the file
 */
-(void)downloadFileFromURL:(NSString*)url forClass:(id)delegate;

-(void)downloadFileFromURL:(NSString*)url withProgress:(ProgressBlock)progress;

/**
 @author : Lokesh Sehgal
 This method will initialize the important elements for the queue
*/
-(void)initializeEverythingRelatedToQueues;

/**
 @author : Lokesh Sehgal
 This method will listen to the change in the Edge,3G,4G Network
 */
-(void)addObserverToListenToAChangeIn3GNetwork;

/**
 @author : Lokesh Sehgal
 This method will update the number of requests on the basis of network availability at the moment
 */
-(void)updateMaxRequestCounterOnTheBasisOfNetwork;

/**
 @author : Lokesh Sehgal
 This method will update the number of requests on the basis of network availability at the moment
 */
-(void)autoHandleAllTheOperationsHere;

/**
 @author : Lokesh Sehgal
This method will start monitering the network changes
 */
-(void)startMoniteringNetworkingFluctuations;

/**
 @author : Lokesh Sehgal
 This is a sample method for making a request
 */
-(void)sampleMethodForRequestResponse;

/**
 @author : Lokesh Sehgal
 This is for adding a request to the queue
 */
-(void) addRequestToQueue:(WooRequest*)requestObject withShouldReachServer:(BOOL)shouldReachServer;

/**
 @author : Lokesh Sehgal
 This is for making a request through the queue
 */
-(void)makeRequest:(WooRequest*)requestObj withCallback:(APICompletionBlock)callback shouldReachServerThroughQueue:(BOOL)shouldReachServer;

/**
 @author : Lokesh Sehgal
 This is for reading back the API Request from Disk
 */
-(WooRequest*)readBackTheAPIRequestFromDisk;

/**
 @author : Lokesh Sehgal
 Get the directory path for all the requests
 */
-(NSString*)getDirectoryPathForAllTheRequests;

/**
 @author : Lokesh Sehgal
 Persist the API Request On Disk
 */
-(void)persistTheAPIRequestOnDisk:(WooRequest*)wooRequestObj;


-(void)removeFailedRequestFile;


-(AFHTTPRequestOperation *)getUploadOpertaionIfExistForUrl:(NSString *)urlString andImageName:(NSString *)imageName;


//-(void)downloadImageUsingQueue:()

@end
