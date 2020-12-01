//
//  APIQueue.m
//  Woo
//
//  Created by Lokesh Sehgal on 19/02/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "APIQueue.h"
#import "NSObject+UCaching.h"


@interface APIQueue(Private)

/**
 Jai Bajrang Bali
 Jai Sai Ram
 @author : Lokesh Sehgal
 This method will return the response for a URL
 @param : URL - Url for the request,
 time - time to cache the response
 params - Request parameters if needed in any call (POST Generally)
 kindOfRequest - Is it a get/post/delete request
 numberOfRetries - Number of retries before returning back the callback
 useQueue - Is there any need to use the queue.
 cachingPolicyToBeUsedForCall - Cachiny policy to be used for the call (GET_DATA_FROM_CACHE_ONLY, GET_DATA_FROM_URL_ONLY, GET_DATA_FROM_URL_IF_FAIL_GET_DATA_FROM_CACHE,GET_DATA_FROM_URL_AND_UPDATE_CACHE)
 callback - This will return the callback - success/failure.
 */


- (void)getServerResponseForUrl:(NSString *)url withTimeToCache:(long long)time withRequestParams:(NSDictionary*)params withRequestMethod:(methodType)kindOfRequest withRetryCount:(NSInteger)numberOfRetries withDoYouWantToUseQueue:(BOOL)useQueue withCachingPolicy:(AFNetworkingCachingPolicy)cachingPolicyToBeUsedForCall withCallback:(APICompletionBlock)callback withKindOfRequest:(kindOfRequest)requestType withWooRequestObject:(WooRequest*)wooRequestObj;

@end

@implementation APIQueue

static dispatch_queue_t background_API_Persistance_handling_Queue() {
    static dispatch_queue_t api_persistance_handling_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        api_persistance_handling_queue = dispatch_queue_create("com.u2opiamobile.woo.backgroundPersistance", DISPATCH_QUEUE_CONCURRENT );
    });
    
    return api_persistance_handling_queue;
}

void(^getServerResponseForUrlCallback)(BOOL success, id response, NSError *error,int statusCode, kindOfRequest requestType);

APIQueue *apiQueueSharedInstanceObj = nil;

#pragma mark shared instance of API Queue

+(APIQueue *) sharedAPIQueue
{
	if(nil == apiQueueSharedInstanceObj)
	{
		apiQueueSharedInstanceObj = [[APIQueue alloc] init];
        
        [[APIQueue sharedAPIQueue] initializeEverythingRelatedToQueues];
	}
    
	return apiQueueSharedInstanceObj;
}

-(void)initializeEverythingRelatedToQueues{
    if(!workingQueue)
        workingQueue = [[UStack alloc] init];

    if(!pendingQueue)
        pendingQueue = [[UStack alloc] init];
    
    if(!failedQueue)
        failedQueue = [[UStack alloc] init];
    
    if (!imageUploadQueue) {
        imageUploadQueue = [[UStack alloc] init];
    }
    
    if (!downloadTaskArray) {
        downloadTaskArray = [[NSMutableArray alloc] init];
    }
    
    maxWorkingQueueCount = 5;
    
    sizeOfPendingQueue = 20;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(internetConnectionStatusChanged:) name:kInternetConnectionStatusChanged object:nil];
    
    [self addObserverToListenToAChangeIn3GNetwork];
    
    httpRequestOperationManagerObj = [AFHTTPRequestOperationManager manager];

    telephonyInfo = [CTTelephonyNetworkInfo new];
//    [self fetchMobileNetworkInformation];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeInNetworkConnection) name:@"ChangeInNotificationState" object:nil];
    
    // Do this after the launch's 30 Seconds
    
    double delayInSeconds = 30.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, background_API_Persistance_handling_Queue(), ^(void){
        [self addPersistedRequestsFromDiskToQueue];
    });
    
    if(isLoggingEnabled)
        [WooLogger sharedWooLogger];
}

-(void)downloadFileFromURL:(NSString*)url withProgress:(ProgressBlock)progress{
    NSLog(@"url :%@",url);
    
    NSURL *cacheDirectoryPath = [NSURL fileURLWithPath:[APP_Utilities applicationCacheDirectory]];
    NSString *filePath = [cacheDirectoryPath URLByAppendingPathComponent:[NSString stringWithFormat:@"audio/%@",[[url componentsSeparatedByString:@"/"] lastObject]]].absoluteString;
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        AFURLConnectionOperation *operation =   [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
        
        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            NSLog(@"bytesRead :%lu",(unsigned long)bytesRead);
            NSLog(@"totalBytesRead :%lld",totalBytesRead);
            NSLog(@"totalBytesExpectedToRead : %lld",totalBytesExpectedToRead);
            progress(bytesRead, totalBytesRead, totalBytesExpectedToRead);
            
        }];
        
        [operation setCompletionBlock:^{
            NSLog(@"downloadComplete!");
            [[NSNotificationCenter defaultCenter] postNotificationName:kFileDownloaded object:url];
            
        }];
        [operation start];
    }
}

-(void)downloadFileFromURL:(NSString*)url forClass:(id)delegate{
    
    
    if (!isDownloadingFileInProgress) {
        isDownloadingFileInProgress = TRUE;
        if (![downloadTaskArray containsObject:@{kDownloadURL:url,kDownloadClass:delegate}]) {
            [downloadTaskArray addObject:@{kDownloadURL:url,kDownloadClass:delegate}];
        }
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        
        NSURL *URL = [NSURL URLWithString:url];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        NSProgress *progressObj; //= [NSProgress progressWithTotalUnitCount:0];
        NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:&progressObj destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            
            NSURL *cacheDirectoryPath = [NSURL fileURLWithPath:[APP_Utilities applicationCacheDirectory]];
            
            return [cacheDirectoryPath URLByAppendingPathComponent:[NSString stringWithFormat:@"audio/%@",[response suggestedFilename]]];
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            if ([downloadTaskArray containsObject:@{kDownloadURL:url,kDownloadClass:delegate}]) {
                [downloadTaskArray removeObject:@{kDownloadURL:url,kDownloadClass:delegate}];
            }
            isDownloadingFileInProgress = FALSE;
            if ([downloadTaskArray count]>0) {
                NSDictionary *fileDetail = [downloadTaskArray firstObject];
                [self downloadFileFromURL:[fileDetail objectForKey:kDownloadURL] forClass:[fileDetail objectForKey:kDownloadClass]];
            }
            
//            [progressObj removeObserver:delegate forKeyPath:@"fractionCompleted"];
            [progressObj removeObserver:delegate forKeyPath:@"fractionCompleted" context:NULL];
            [[NSNotificationCenter defaultCenter] postNotificationName:kFileDownloaded object:url];
            
            
        }];
        [downloadTask resume];
        if (progressObj) {
            [progressObj addObserver:delegate forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:NULL];
        }
    }
    else{
        if (![downloadTaskArray containsObject:@{kDownloadURL:url,kDownloadClass:delegate}]) {
            [downloadTaskArray addObject:@{kDownloadURL:url,kDownloadClass:delegate}];
        }
    }
    
    
   
    
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"fractionCompleted"]) {
        NSProgress *progress = (NSProgress *)object;
        NSLog(@"Progress… %f", progress.fractionCompleted);
    }
//    else {
//        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
//    }
}

-(void)uploadAnyFileOnServer:(NSString *)URLincludingTheUserId withBinaryDataOfFile:(NSData*)binaryData withRetryCount:(NSInteger)numberOfRetries withDoYouWantToUseQueue:(BOOL)useQueue withCachingPolicy:(AFNetworkingCachingPolicy)cachingPolicyToBeUsedForCall withCallback:(APICompletionBlock)callback withKindOfRequest:(kindOfRequest)requestType andKindOfFileImage:(BOOL)isImage{
  
    getServerResponseForUrlCallback = callback;

    int numRetry = --numberOfRetries;

    [httpRequestOperationManagerObj POST:URLincludingTheUserId parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        // Change the mime type from here = http://reference.sitepoint.com/html/mime-types-full and replace according to your need
        if (isImage) {
            [formData appendPartWithFileData:binaryData name:@"fileToUpload" fileName:kTempImageName mimeType:@"image/jpeg"];
        }
        else{
            [formData appendPartWithFileData:binaryData name:@"file" fileName:kTempAudioFileName mimeType:@"audio/AMR"];
        }
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        getServerResponseForUrlCallback(YES,responseObject,nil,operation.response.statusCode, requestType);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        if(numberOfRetries<0){
            
            // Error
            getServerResponseForUrlCallback(NO,nil,error,operation.response.statusCode,requestType);
    
        }else{

            [self uploadAnyFileOnServer:URLincludingTheUserId withBinaryDataOfFile:binaryData withRetryCount:numRetry withDoYouWantToUseQueue:useQueue withCachingPolicy:cachingPolicyToBeUsedForCall withCallback:callback withKindOfRequest:requestType andKindOfFileImage:isImage];

        }
    } caching:cachingPolicyToBeUsedForCall andNumberOfRetries:numberOfRetries];
    
}

-(void)uploadAnyFileOnServer:(NSString *)URLincludingTheUserId withBinaryDataOfFile:(NSData*)binaryData withRetryCount:(NSInteger)numberOfRetries withDoYouWantToUseQueue:(BOOL)useQueue withCachingPolicy:(AFNetworkingCachingPolicy)cachingPolicyToBeUsedForCall withCallback:(APICompletionBlock)callback withKindOfRequest:(kindOfRequest)requestType andKindOfFileImage:(BOOL)isImage withProgress:(ProgressBlock)progress andImageTemporaryName:(NSString *)imageName{
    
    getServerResponseForUrlCallback = callback;
    
    // Comment it out later
    //    URLincludingTheUserId = [NSString stringWithFormat:@"http://54.245.228.232:8080/woo/api/v1/user/uploadfile/?wooUserId=43"];
    AFHTTPRequestOperation *opObj = [self getUploadOpertaionIfExistForUrl:URLincludingTheUserId andImageName:imageName];
    if (opObj) {
        [opObj setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                            long long totalBytesWritten,
                                            long long totalBytesExpectedToWrite) {
            NSLog(@"Wrote---Purani---->>>>> %lld/%lld", totalBytesWritten, totalBytesExpectedToWrite);
            progress(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
        }];
    }
    else{
        
        
        //    NSData *imageData = UIImageJPEGRepresentation( [UIImage imageNamed:@"placeholder.png"], 0.5);
        
        int numRetry = --numberOfRetries;
        
        //    httpRequestOperationManagerObj.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        [httpRequestOperationManagerObj POST:URLincludingTheUserId parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            // Change the mime type from here = http://reference.sitepoint.com/html/mime-types-full and replace according to your need
            if (isImage) {
                [formData appendPartWithFileData:binaryData name:@"fileToUpload" fileName:kTempImageName mimeType:@"image/jpeg"];
            }
            else{
                [formData appendPartWithFileData:binaryData name:@"file" fileName:kTempAudioFileName mimeType:@"audio/AMR"];
            }
            
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [imageUploadQueue removeElement:operation];
            getServerResponseForUrlCallback(YES,responseObject,nil,operation.response.statusCode, requestType);
            //        [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
            //                                            long long totalBytesWritten,
            //                                            long long totalBytesExpectedToWrite) {
            //            NSLog(@"Wrote %lld/%lld", totalBytesWritten, totalBytesExpectedToWrite);
            //        }];
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [imageUploadQueue removeElement:operation];
            if(numberOfRetries<0){
                
                // Error
                getServerResponseForUrlCallback(NO,nil,error,operation.response.statusCode,requestType);
                
            }else{
                [self uploadAnyFileOnServer:URLincludingTheUserId withBinaryDataOfFile:binaryData withRetryCount:numRetry withDoYouWantToUseQueue:useQueue withCachingPolicy:cachingPolicyToBeUsedForCall withCallback:callback withKindOfRequest:requestType andKindOfFileImage:isImage withProgress:progress andImageTemporaryName:imageName];
                
            }
        } caching:cachingPolicyToBeUsedForCall andNumberOfRetries:numberOfRetries withProgress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            NSLog(@"Wrote########## %lld/%lld", totalBytesWritten, totalBytesExpectedToWrite);
            progress(bytesWritten,totalBytesWritten, totalBytesExpectedToWrite);
        } withOperation:^(AFHTTPRequestOperation *operation) {
            if ([imageName length]>0) {
                [operation setOperationStringTag:imageName];
            }
            [imageUploadQueue push:operation];
            NSLog(@"operation :%@",operation);
        }];
        
    }
    
    
    
}


- (void)getServerResponseForUrl:(NSString *)url withTimeToCache:(long long)time withRequestParams:(NSDictionary*)params withRequestMethod:(methodType)kindOfRequest withRetryCount:(NSInteger)numberOfRetries withDoYouWantToUseQueue:(BOOL)shouldReachServer withCachingPolicy:(AFNetworkingCachingPolicy)cachingPolicyToBeUsedForCall withCallback:(APICompletionBlock)callback withKindOfRequest:(kindOfRequest)requestType withWooRequestObject:(WooRequest*)wooRequestObj
{
//    getServerResponseForUrlCallback = callback;
    if(isLoggingEnabled)
        [[WooLogger sharedWooLogger] addLoggerInformationForURL:wooRequestObj.url startTime:[[NSDate date] timeIntervalSince1970] endTime:0];

    
    switch (kindOfRequest) {
        case getRequest:
        {
            
            int numRetry = --numberOfRetries;
                        
            if(wooRequestObj.isJsonContentType){
                [httpRequestOperationManagerObj setRequestSerializer:[AFJSONRequestSerializer serializer]];
            }else{
                [httpRequestOperationManagerObj setRequestSerializer:[AFHTTPRequestSerializer serializer]];
            }
            
            [httpRequestOperationManagerObj GET:wooRequestObj.url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                // Success
                if(wooRequestObj.requestType==requestType){
                    if(callback!=nil)
                        callback(YES,responseObject,nil,operation.response.statusCode,requestType);
                }
                
//                NSLog(@"\n\n\n -------GET--API Response :  %@------ operation.response.statusCode : %d------url   :%@",responseObject,operation.response.statusCode,url);
                // Commented by Lokesh
//                [workingQueue removeElement:wooRequestObj];
                
                    [self removeRequest:wooRequestObj];

                if(shouldReachServer)
                    [self removeRequestFromDisk:wooRequestObj];

                if(isLoggingEnabled)
                   [[WooLogger sharedWooLogger] addLoggerInformationForURL:wooRequestObj.url startTime:0 endTime:[[NSDate date] timeIntervalSince1970]];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                if(numberOfRetries<0){
                    
                    // Error
                    if(wooRequestObj.requestType==requestType){
                        if(callback!=nil)
                            callback(NO,nil,error,operation.response.statusCode,requestType);
                    }

//                    [workingQueue removeElement:wooRequestObj];
//                    NSLog(@"operation.response.statusCode %d",operation.response.statusCode);
                    if(operation.response.statusCode==408 || operation.response.statusCode==0){
                        if(numberOfRetries!=kDoNotPutMeInFailedQueue)
                            [self addToFailedQueue:wooRequestObj];
                    }else{
                        // Commented by Lokesh
                        //                [workingQueue removeElement:wooRequestObj];
                        
                        [self removeRequest:wooRequestObj];
                    }
                    
                }else{
                    
                     [self getServerResponseForUrl:wooRequestObj.url withTimeToCache:time withRequestParams:params withRequestMethod:kindOfRequest withRetryCount:numRetry withDoYouWantToUseQueue:shouldReachServer withCachingPolicy:cachingPolicyToBeUsedForCall withCallback:callback withKindOfRequest:requestType withWooRequestObject:wooRequestObj];
                }

                    if(isLoggingEnabled)
                        [[WooLogger sharedWooLogger] addLoggerInformationForURL:wooRequestObj.url startTime:0 endTime:[[NSDate date] timeIntervalSince1970]];
                
            } caching:cachingPolicyToBeUsedForCall andNumberOfRetries:numberOfRetries];
        }
            break;
        case postRequest:{
            
            int numRetry = --numberOfRetries;
            
            if(wooRequestObj.isJsonContentType){
                [httpRequestOperationManagerObj setRequestSerializer:[AFJSONRequestSerializer serializer]];
            }else{
                [httpRequestOperationManagerObj setRequestSerializer:[AFHTTPRequestSerializer serializer]];
            }
            
            [httpRequestOperationManagerObj POST:wooRequestObj.url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {

                // Success

                if(wooRequestObj.requestType==requestType){
                        if(callback!=nil)
                            callback(YES,responseObject,nil,operation.response.statusCode,requestType);
                }
//                NSLog(@"\n\n\n -------POST--API Response :  %@------ operation.response.statusCode : %d------url   :%@",responseObject,operation.response.statusCode,url);
                
                // Commented by Lokesh
                //                [workingQueue removeElement:wooRequestObj];
                
                [self removeRequest:wooRequestObj];
                
                
                if(shouldReachServer)
                    [self removeRequestFromDisk:wooRequestObj];

                if(isLoggingEnabled)
                    [[WooLogger sharedWooLogger] addLoggerInformationForURL:wooRequestObj.url startTime:0 endTime:[[NSDate date] timeIntervalSince1970]];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                if(numberOfRetries<0){
                    
                    // Error
                    if(wooRequestObj.requestType==requestType){
                        if(callback!=nil)
                            callback(NO,nil,error,operation.response.statusCode,requestType);
                    }
                    
//                    [workingQueue removeElement:wooRequestObj];
                    
                    if(operation.response.statusCode==408 || operation.response.statusCode==0){
                        if(numberOfRetries!=kDoNotPutMeInFailedQueue)
                            [self addToFailedQueue:wooRequestObj];
                    }else{
                        // Commented by Lokesh
                        //                [workingQueue removeElement:wooRequestObj];
                        
                        [self removeRequest:wooRequestObj];
                        
                    }
                    
                    
                }else{
                    [self getServerResponseForUrl:wooRequestObj.url withTimeToCache:time withRequestParams:params withRequestMethod:kindOfRequest withRetryCount:numRetry withDoYouWantToUseQueue:shouldReachServer withCachingPolicy:cachingPolicyToBeUsedForCall withCallback:callback withKindOfRequest:requestType withWooRequestObject:wooRequestObj];
                }

                if(isLoggingEnabled)
                    [[WooLogger sharedWooLogger] addLoggerInformationForURL:wooRequestObj.url startTime:0 endTime:[[NSDate date] timeIntervalSince1970]];
                
            } caching:cachingPolicyToBeUsedForCall andNumberOfRetries:numberOfRetries];
        }
            break;
        case deleteRequest:{
            
            int numRetry = --numberOfRetries;
            
            [httpRequestOperationManagerObj DELETE:wooRequestObj.url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                // Success
                if(wooRequestObj.requestType==requestType)
                    callback(YES,responseObject,nil,operation.response.statusCode,requestType);
                
//                [workingQueue removeElement:wooRequestObj];
                
                // Commented by Lokesh
                //                [workingQueue removeElement:wooRequestObj];
                
                [self removeRequest:wooRequestObj];
                
//                NSLog(@"\n\n\n -------DELETE--API Response :  %@------ operation.response.statusCode : %d------url   :%@",responseObject,operation.response.statusCode,url);
                
                if(shouldReachServer)
                    [self removeRequestFromDisk:wooRequestObj];

                if(isLoggingEnabled)
                    [[WooLogger sharedWooLogger] addLoggerInformationForURL:wooRequestObj.url startTime:0 endTime:[[NSDate date] timeIntervalSince1970]];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                if(numberOfRetries<0){
                    
                    // Error
                    if(wooRequestObj.requestType==requestType)
                        callback(NO,nil,error,operation.response.statusCode,requestType);
                    
//                    [workingQueue removeElement:wooRequestObj];
                    
                    if(operation.response.statusCode==408 || operation.response.statusCode==0){
                        if(numberOfRetries!=kDoNotPutMeInFailedQueue)
                            [self addToFailedQueue:wooRequestObj];
                    }else{
                        // Commented by Lokesh
                        //                [workingQueue removeElement:wooRequestObj];
                        
                        [self removeRequest:wooRequestObj];
                    }
                    
                    
                }else{
                    [self getServerResponseForUrl:wooRequestObj.url withTimeToCache:time withRequestParams:params withRequestMethod:kindOfRequest withRetryCount:numRetry withDoYouWantToUseQueue:shouldReachServer withCachingPolicy:cachingPolicyToBeUsedForCall withCallback:callback withKindOfRequest:requestType withWooRequestObject:wooRequestObj];
                }

                if(isLoggingEnabled)
                    [[WooLogger sharedWooLogger] addLoggerInformationForURL:wooRequestObj.url startTime:0 endTime:[[NSDate date] timeIntervalSince1970]];
                
            } caching:cachingPolicyToBeUsedForCall andNumberOfRetries:numberOfRetries];
        }
            break;
        default:
            break;
    }
}

-(void) addToFailedQueue:(WooRequest*) requestObj{

    @synchronized (failedQueue){
        
            BOOL existsInFailedQueue = FALSE;
        
            for(int indx=0;indx<failedQueue.count;indx++){

                WooRequest *wooRequestObj = [failedQueue getElement:indx];
                
                if([wooRequestObj.url isEqualToString:requestObj.url]){
                    existsInFailedQueue = TRUE;
                    break;
                }
            }
            
            if(!existsInFailedQueue){
            
         //       [failedQueue push:requestObj]; // Commented because Boat screen was coming twice
                
            }

            [workingQueue removeElement:requestObj];

        }
}

-(void) doProcessFailedQueue{
    // Handle failure of network here
    if([failedQueue count]>0){
        for(int indx = 0 ;indx<failedQueue.count;indx++){
            WooRequest *request =  [failedQueue getElement:indx];
            if(request.numberOfRetries!=kDoNotPutMeInFailedQueue){
                [self addRequestToQueue:request withShouldReachServer:TRUE];
            }
        }
        [failedQueue clear];
    }else if([pendingQueue count]>0){
        
            WooRequest *request =  [pendingQueue firstElement];
            [pendingQueue removeElement:request];
            if(request.numberOfRetries!=kDoNotPutMeInFailedQueue){
                [self addRequestToQueue:request withShouldReachServer:TRUE];
            }

    }
}

-(void)autoHandleAllTheOperationsHere{

//    if([workingQueue count]>0){
//        [workingQueue removeAllObjects];
//    }
//
//    [workingQueue addObjectsFromArray:[[httpRequestOperationManagerObj.operationQueue.operations reverseObjectEnumerator] allObjects]];
//    
//    for(AFHTTPRequestOperation *requestOperationObj in workingQueue){
//
//        if(workingQueue.count<=maxWorkingQueueCount){
//            if([requestOperationObj isPaused]){
//                [requestOperationObj resume];
//            }else{
//                [requestOperationObj start];
//            }
//        }else{
//            [requestOperationObj pause];
//        }
//    }

//    NSLog(@"Queue Count After Every Request ==== %d",workingQueue.count);
}

-(void)internetConnectionStatusChanged:(NSNotification*)notif{
    
    int internetStatus = 0;
    
    internetStatus = [notif.object intValue];
    
    [self startMoniteringNetworkingFluctuations:internetStatus];
    
}

-(void)startMoniteringNetworkingFluctuations:(AFNetworkReachabilityStatus)status{
    
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:{
                
//                    NSLog(@"No Internet Connection =");

//                    [ALToastView toastInView:APP_DELEGATE.window withText:@"No internet connection.>"];
                
                    // Handle low network issues here
                    
//                    if([pendingQueue count]>0){
//                        [pendingQueue removeAllObjects];
//                    }
                
//                    [pendingQueue addObjectsFromArray:[[workingQueue reverseObjectEnumerator] allObjects]];
                
                     [self flushFailedQueueAndAddToWQ];
                }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:{
//                    NSLog(@"Reachable via WIFI 9");
                
                    maxWorkingQueueCount = 5;
                
         //           [self doProcessFailedQueue]; // Commented because Boat screen was coming twice
                
                    // Handle low network issues here
//                
//                    if([pendingQueue count]>0){
//                        [pendingQueue removeAllObjects];
//                    }
                
//                    [pendingQueue addObjectsFromArray:[[workingQueue reverseObjectEnumerator] allObjects]];
//                
//                    for(AFHTTPRequestOperation *pendingRequestOperation in pendingQueue)
//                    {
//                        if(![workingQueue containsObject:pendingRequestOperation]){
//                            // check whether working queue contains this object - else add it to the queue
//                            [workingQueue addObject:pendingRequestOperation];
//                        }
//                    }
//
//                    [self autoHandleAllTheOperationsHere];
                }
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:{

                //    [self doProcessFailedQueue]; // Commented because Boat screen was coming twice
                
                    [self updateMaxRequestCounterOnTheBasisOfNetwork];
                
//                    NSLog(@"Reachable via 3G");
                
//                    [self autoHandleAllTheOperationsHere];
                
                }
                break;
            default:
                {
//                    NSLog(@"Unknown status here");
                }
                break;
        }
    
}

-(void)addObserverToListenToAChangeIn3GNetwork{
    
    [NSNotificationCenter.defaultCenter addObserverForName: CTRadioAccessTechnologyDidChangeNotification
                                                    object: nil
                                                     queue: nil
                                                usingBlock: ^ (NSNotification * note)
     {
         
         AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
         
         if(reachability.reachableViaWWAN)
            [self updateMaxRequestCounterOnTheBasisOfNetwork];
     }];
}

-(void)updateMaxRequestCounterOnTheBasisOfNetwork{
    // Setup the Network Info and create a CTCarrier object
//    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
//
/* Additional information regarding Network Connected to
    // Get carrier name
//    NSString *carrierName = [carrier carrierName];
//    if (carrierName != nil)
//        NSLog(@"Carrier: %@", carrierName);
//
    // Get mobile country code
//    NSString *mcc = [carrier mobileCountryCode];
//    if (mcc != nil)
//        NSLog(@"Mobile Country Code (MCC): %@", mcc);

    // Get mobile network code
//    NSString *mnc = [carrier mobileNetworkCode];
//    if (mnc != nil)
//        NSLog(@"Mobile Network Code (MNC): %@", mnc);
 
*/

    
    /// Assuming 2G
    if([telephonyInfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS] || [telephonyInfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge] || [telephonyInfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyWCDMA]){
        maxWorkingQueueCount = 2;
    }else if([telephonyInfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSDPA] || [telephonyInfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSUPA] || [telephonyInfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMA1x]  || [telephonyInfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMA1x] ){
        maxWorkingQueueCount = 5;
    }
    else if([telephonyInfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0] || [telephonyInfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA] || [telephonyInfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB] || [telephonyInfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyeHRPD] || [telephonyInfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]){
        maxWorkingQueueCount = 10;
    }
}

-(void)sampleMethodForRequestResponse{
    
//    NSString *urlString = [NSString stringWithFormat:@"%@%@?wooUserId=%@",kBaseURLV1,kGetWooAlbum,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
//    
//    [[APIQueue sharedAPIQueue] getServerResponseForUrl:urlString withTimeToCache:900 withRequestParams:nil withRequestMethod:getRequest withRetryCount:3 withDoYouWantToUseQueue:YES withCachingPolicy:GET_DATA_FROM_URL_ONLY withCallback:^(BOOL success, id response, NSError *error, int statusCode,) {
//        
//        if (success)
//        {
//            // Use your response NSDictionary object
//            
//            NSLog(@"success %@",response);
//        }
//        else
//        {
//            // Display you error NSError object
//        }
//    }];
}

-(void)makeRequest:(WooRequest*)requestObj withCallback:(APICompletionBlock)callback shouldReachServerThroughQueue:(BOOL)shouldReachServer{
  
    
//    NSLog(@"requestObj url %@",requestObj.url);

    NSString *requestURL =requestObj.url;
//    wooId=(null)
    if ([requestURL rangeOfString:@"wooUserId=(null)"].location != NSNotFound || [requestURL rangeOfString:@"targetId=(null)"].location != NSNotFound || [requestURL rangeOfString:@"wooId=(null)"].location != NSNotFound) {
        
        // RETURN AND DO NOT PROCEED WITH REQUEST ANYMORE
        
        return;
    }

    requestObj.callback = callback;
    
    if(requestObj.cachePolicy==GET_DATA_FROM_CACHE_ONLY){
        NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:requestURL]];
        id responseObject = [self getCachedDataForRequest:urlRequest withValidCacheTimeInterval:CACHE_DURATION];
        
        callback(YES,responseObject,nil,200,requestObj.requestType);
        
    }else{
        [self addRequestToQueue:requestObj withShouldReachServer:shouldReachServer];
    }
}


-(void) addRequestToQueue:(WooRequest*)requestObject withShouldReachServer:(BOOL)shouldReachServer{
    
    @synchronized(workingQueue){
        
        if (!requestObject) {
            return;
        }
        
        BOOL existsInWorkingQueue = FALSE;
        
        for(int indx=0;indx<workingQueue.count;indx++){
            
            WooRequest *wooRequestObj = [workingQueue getElement:indx];
            
            if([wooRequestObj.url isEqualToString:requestObject.url]){
                existsInWorkingQueue = TRUE;
                break;
            }
        }
        
//        NSLog(@"URL exists in queue : %@",existsInWorkingQueue?requestObject.url:@"Nhi hai");
        
        if(!existsInWorkingQueue){
        
            if([workingQueue count]<=maxWorkingQueueCount){
                
                if (requestObject.numberOfRetries > 0) {
                    [workingQueue push:requestObject];
                }
                    if(shouldReachServer)
                        [self persistTheAPIRequestOnDisk:requestObject];
                
//                NSLog(@"sidha call maar di hai");
                    [self getServerResponseForUrl:requestObject.url withTimeToCache:requestObject.time withRequestParams:requestObject.requestParams withRequestMethod:requestObject.methodType withRetryCount:requestObject.numberOfRetries withDoYouWantToUseQueue:shouldReachServer withCachingPolicy:requestObject.cachePolicy withCallback:requestObject.callback withKindOfRequest:requestObject.requestType withWooRequestObject:requestObject];

        //            [self makeRequest:requestObject withCallback:requestObject.callback];
            }else{
                if(![pendingQueue contains:requestObject]){

                    WooRequest *addRequestToPending = [workingQueue lastObject];
                    
                    [workingQueue removeElement:[workingQueue lastObject]];
                    
//                    NSLog(@"queue me add kar diya hai");
                    
                    [self addRequestToQueue:requestObject withShouldReachServer:shouldReachServer];
                    
                    [pendingQueue push:addRequestToPending];
                }
            }
        }
    }
}


-(void) removeRequest:(WooRequest*) requestObj{
    
    if([workingQueue contains:requestObj])
        [workingQueue removeElement:requestObj];
    
    if([pendingQueue count]>0){
        WooRequest *wooRequestObj = [pendingQueue firstElement];
        [pendingQueue removeElement:wooRequestObj];
        [self addRequestToQueue:wooRequestObj withShouldReachServer:TRUE];
    }else if([failedQueue count]>0){
        WooRequest *wooRequestObj = [failedQueue firstElement];
        [failedQueue removeElement:wooRequestObj];
        [self addRequestToQueue:wooRequestObj withShouldReachServer:TRUE];
    }
}

-(void) addRequestsToFailedQueue
{
    // Handle failure of network here
    if([failedQueue count]>0){
        for(int index =0 ;index<[failedQueue count];index++){
            WooRequest *request =  [pendingQueue getElement:index];
                if(request!=nil)
                    [self addRequestToQueue:request withShouldReachServer:TRUE];
        }
        
        [failedQueue clear];
    }
}

-(void) flushFailedQueueAndAddToWQ{

    // Handle failure of network here
    
    if([workingQueue count]>0){

        for(int index =0 ;index<[workingQueue count];index++){
            
            WooRequest *wooObj  = [workingQueue getElement:index];
        
            if(wooObj.numberOfRetries!=kDoNotPutMeInFailedQueue){
                if(![failedQueue contains:wooObj]){
                   // [failedQueue push:(wooObj)]; // Commented because Boat screen was coming twice
                }
            }
        
        }
        
        [workingQueue clear];
    }
}

-(void)removeRequestFromDisk:(WooRequest*)wooRequestObj{
/*
    dispatch_sync(background_API_Persistance_handling_Queue(), ^{
    
        NSMutableArray *wooRequests = [NSKeyedUnarchiver unarchiveObjectWithFile:[self getDirectoryPathForAllTheRequests]];
        
        if(wooRequests==nil){
            return;
        }

        BOOL hasChangesMade = FALSE;
        
        NSMutableArray *tempArray = (NSMutableArray*)[NSArray arrayWithArray:wooRequests];
        
        for(WooRequest *requestObj in tempArray){
            if([wooRequestObj.url isEqualToString:requestObj.url]){
                [wooRequests removeObject:requestObj];
                hasChangesMade = TRUE;
            }
        }
        
        if(hasChangesMade){
            [NSKeyedArchiver archiveRootObject:wooRequests toFile:[self getDirectoryPathForAllTheRequests]];
        }
    });
 */
}

-(NSString*)getDirectoryPathForAllTheRequests{

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"woofailed.txt"];
    
    return appFile;
}

-(void)persistTheAPIRequestOnDisk:(WooRequest*)wooRequestObj{
    /*
    if(wooRequestObj.methodType==postRequest){
        
        dispatch_sync(background_API_Persistance_handling_Queue(), ^{

            double delayInSeconds = 30.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, background_API_Persistance_handling_Queue(), ^(void){
                [self addPersistedRequestsFromDiskToQueue];
            });
            NSMutableArray *wooRequests = [NSKeyedUnarchiver unarchiveObjectWithFile:[self getDirectoryPathForAllTheRequests]];

            BOOL containsTheRequestOnDisk = FALSE;
            
            if(wooRequests!=nil){
                for(WooRequest *requestObj in wooRequests){
                    if([wooRequestObj.url isEqualToString:requestObj.url]){
                        containsTheRequestOnDisk = TRUE;
                        break;
                    }
                }
            }
            
            if(!containsTheRequestOnDisk){
                
                if(wooRequests==nil){
                    wooRequests = [NSMutableArray array];
                }
                
                [wooRequests addObject:wooRequestObj];
                [NSKeyedArchiver archiveRootObject:wooRequests toFile:[self getDirectoryPathForAllTheRequests]];
            }

        });
        
    }
*/
}

-(void)addPersistedRequestsFromDiskToQueue{
/*
    NSMutableArray *wooRequests = [NSKeyedUnarchiver unarchiveObjectWithFile:[self getDirectoryPathForAllTheRequests]];
    
    for(WooRequest *wooRequestObj in wooRequests){
        [self addRequestToQueue:wooRequestObj withShouldReachServer:TRUE];
    }
 */
}

-(void)removeFailedRequestFile{
    /*
    dispatch_sync(background_API_Persistance_handling_Queue(), ^{
        
        if(![[self getDirectoryPathForAllTheRequests] isEqualToString:@""]){
            
//            isSaveOrReadInProgress = FALSE;
            
            if([[NSFileManager defaultManager] fileExistsAtPath:[self getDirectoryPathForAllTheRequests]]){
                [[NSFileManager defaultManager] removeItemAtPath:[self getDirectoryPathForAllTheRequests] error:nil];
            }
        }
        
    });
    */
}

//-(void)isRequestExists:(NSString *)wooRequestURL{
//    for(int index =0 ;index<[failedQueue count];index++){
//        
//        WooRequest *wooObj  = [failedQueue getElement:index];
//        
//        if([wooObj.url isEqualToString:wooRequestURL]){
//            [self addRequestToQueue:wooObj withShouldReachServer:TRUE];
//            break;
//        }                
//    }
//}


//Added by Umesh to remove crash "cfnotificationcenter is calling out to an observer" on 11 August 2014
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(AFHTTPRequestOperation *)getUploadOpertaionIfExistForUrl:(NSString *)urlString andImageName:(NSString *)imageName{
    AFHTTPRequestOperation *opObjForGivenUrl = nil;
    for (int indexX = 0; indexX < imageUploadQueue.count; indexX++) {
        AFHTTPRequestOperation *opObj = [imageUploadQueue getElement:indexX];
        if ([opObj.request.URL.absoluteString isEqualToString:urlString] && [opObj.operationStringTag isEqualToString:imageName]) {
            NSLog(@"Operation Mila");
            opObjForGivenUrl = opObj;
            break;
        }
    }
    return opObjForGivenUrl;
}

@end
