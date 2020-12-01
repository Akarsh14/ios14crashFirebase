//
//  TagScreenAPIClass.m
//  Woo_v2
//
//  Created by Umesh Mishraji on 30/06/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "TagScreenAPIClass.h"

@implementation TagScreenAPIClass


+(void)getTagsDataFromServer:(void(^)(BOOL success, int statusCode, id response))successBlock{
    NSString *url = nil;
//    NSString *hardCodedWooIdForTags = @"3436548";
    url = [NSString stringWithFormat:@"%@%@?wooId=%lld",kBaseURLV1,kGetTagsFromServerAPI,[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue]];
//    url = [NSString stringWithFormat:@"%@%@?wooId=%@",kBaseURLV1,kGetTagsFromServerAPI,hardCodedWooIdForTags];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =url;
    wooRequestObj.time =900;
    wooRequestObj.requestParams = nil;
    wooRequestObj.methodType =getRequest;
    wooRequestObj.numberOfRetries =10;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = getTagsFromServerAPI;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        if (requestType == getTagsFromServerAPI) {
            successBlock(success, statusCode, response);
        }
    } shouldReachServerThroughQueue:TRUE];
}

+(void)postTagsDataToServerWithTagsArray:(NSArray *)tagsArray withType:(NSString *)type andSuccessBlock:(void(^)(BOOL success, int statusCode, id response))successBlock{
    
    NSString *apiName;
    if ([type isEqualToString:@"TAGS"]){
        apiName = kGetTagsFromServerAPI;
    }
    else if ([type isEqualToString:@"RelationShip"]){
        apiName = kPostRelationshipTagsToServerAPI;
    }
    else{
        apiName = kPostZodiacTagToServerAPI;
    }
    
    if ([tagsArray count]>0) {
        NSString *url = nil;
        url = [NSString stringWithFormat:@"%@%@?wooId=%lld",kBaseURLV2,apiName,[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue]];
        NSMutableArray *tagsIdArray = [[NSMutableArray alloc] init];

        for (NSDictionary *tagDetail in tagsArray) {
            
            [tagsIdArray addObject:[tagDetail objectForKey:kTagsIdKey]];
        }
        
        NSDictionary *params = @{@"selectedTags":tagsIdArray};

        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
        
        [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        [manager setRequestSerializer:requestSerializer];
        
        [manager  POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            successBlock(TRUE, (int)operation.response.statusCode, responseObject);
            
            NSLog(@"operation.response.statusCode :%ld",(long)operation.response.statusCode);
            [operation.response valueForKey:@"statusCode"];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            successBlock(FALSE, 0, nil);
            
        } caching:GET_DATA_FROM_URL_ONLY andNumberOfRetries:3];
 
        
    }
    else{
        successBlock(FALSE, 0, nil);
    }
    
}

@end
