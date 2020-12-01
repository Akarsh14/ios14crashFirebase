//
//  ImageAPIClass.m
//  Woo_v2
//
//  Created by Suparno Bose on 17/02/16.
//  Copyright © 2016 Woo. All rights reserved.
//

#import "ImageAPIClass.h"

@implementation ImageAPIClass

+(void)fetchUserImagesWithCompletionBlock:(ImageAPICompletionBlock)block{
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@?wooUserId=%@",kBaseURLV7,kGetWooAlbum,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =urlString;
    wooRequestObj.time =900;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =getRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_AND_UPDATE_CACHE;
    wooRequestObj.requestType = getUserWooAlbum;
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response,
                                                                        NSError *error, int statusCode, kindOfRequest requestType) {
        
        if (requestType == getUserWooAlbum) {
            if (statusCode==401 || statusCode==402 || statusCode==500) {
                block(nil,NO,statusCode);
            }
            block(response,success,statusCode);
        }
    } shouldReachServerThroughQueue:TRUE];
}

+(BOOL)updateUserWooAlbumWithPayloadString:(NSString*)payloadString
                           AndProfilePicId:(NSString*)profilePicID
                        AndCompletionBlock:(ImageAPICompletionBlock)block{
    
    NSLog(@"%@",payloadString);
    
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    if (!reachability.reachable) {
        return NO;
    }
    
    NSString *apiPath = [NSString stringWithFormat:@"%@%@?wooId=%@&profilePicId=%@&requiredYouAreInScreen=true",kBaseURLV7,kUpdateUserAlbum,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],profilePicID];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =apiPath;
    wooRequestObj.time =900;
    wooRequestObj.requestParams =[NSDictionary dictionaryWithObjectsAndKeys:payloadString,@"payload", nil];
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = updateUserWooAlbum;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        if (updateUserWooAlbum) {
            if (statusCode==401 || statusCode==402 || statusCode==500) {
                block(nil,NO,statusCode);
            }
            block(response,success,statusCode);
        }
    }  shouldReachServerThroughQueue:TRUE];
    return YES;
}


+(BOOL)uploadImageToServer:(UIImage *)image AndObjectId:(NSString*)objetId
             WithFakeCheck:(BOOL)ifYES
       WithCompletionBlock:(ImageAPICompletionBlock)block{
    
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    if (!reachability.reachable) {
        
        SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"Please check your internet connection",nil));

        return NO;
    }
    
    /*
    CGSize imageSize = image.size;
    float red = 720.0/imageSize.width;
    CGSize compressedSize = CGSizeMake(imageSize.width*red, imageSize.height*red);
    UIGraphicsBeginImageContext( compressedSize );
    [image drawInRect:CGRectMake(0,0,compressedSize.width,compressedSize.height)];
    UIImage* newCompresssedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
     */
    
    NSData *imageData = UIImagePNGRepresentation(image);
    
    NSLog(@"imageDataAfterCompressed :%lu",(unsigned long)imageData.length);
    
    unsigned long imageLength = imageData.length/1000;
    
    NSData *imageDataAfterCompressed = nil;

    if ((int)imageLength >= 1250){
        imageDataAfterCompressed = UIImageJPEGRepresentation(image, 0.5);
    }
    else if ((int)imageLength < 1250 && (int)imageLength >= 750){
        imageDataAfterCompressed = UIImageJPEGRepresentation(image, 0.35);
    }
    else if ((int)imageLength < 750 && (int)imageLength >= 250){
        imageDataAfterCompressed = UIImageJPEGRepresentation(image, 0.20);
    }
    else{
        imageDataAfterCompressed = imageData;
    }
    
    UIImage *imageFromCompressedData = [UIImage imageWithData:imageDataAfterCompressed];

    
    NSString *uploadImageUrl = [NSString stringWithFormat:@"%@%@?wooId=%@",kBaseURLV3,kUploadPictures,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
    if (objetId && objetId.length>0) {
        uploadImageUrl =  [NSString stringWithFormat:@"%@&replaceObjectId=%@",uploadImageUrl,objetId];
    }
    [[APIQueue sharedAPIQueue] uploadAnyFileOnServer:uploadImageUrl withBinaryDataOfFile:imageDataAfterCompressed withRetryCount:3 withDoYouWantToUseQueue:YES withCachingPolicy:GET_DATA_FROM_URL_ONLY withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        NSLog(@"success : %d",success);
        NSLog(@"response : %@",response);
        NSLog(@"error : %@",error);
        NSLog(@"statusCode : %d",statusCode);
        block(response,success,statusCode);
    } withKindOfRequest:uploadPictureToServer andKindOfFileImage:TRUE];
    
    return YES;
}


+(void)cropImageToServerWithImageData:(NSDictionary *)editedImageData
                    AndAdditionalData:(NSDictionary*)additionalData
                  WithCompletionBlock:(ImageAPICompletionBlock)block {
    int cropX = [[editedImageData objectForKey:@"croppingStartingX"] intValue];
    int cropY = [[editedImageData objectForKey:@"croppingStartingY"] intValue];
    int cropWidth = [[editedImageData objectForKey:@"croppingWidth"] intValue];
    int cropHeight = [[editedImageData objectForKey:@"croppingHeight"] intValue];
    
    NSString *imageUrlKey = nil;
    NSString *imageIdKey = nil;
    
    if ([[additionalData allKeys] containsObject:@"imageID"]) {
        imageIdKey = @"imageID";
    }
    else if ([[additionalData allKeys] containsObject:@"objectId"]){
        imageIdKey = @"objectId";
    }
    
    if ([[additionalData allKeys] containsObject:@"imageURL"]) {
        imageUrlKey = @"imageURL";
    }
    else if ([[additionalData allKeys] containsObject:@"srcBig"]){
        imageUrlKey = @"srcBig";
    }
    
    long long int objectID =[[additionalData objectForKey:imageIdKey] longLongValue] ;
    NSString *imageURL = [APP_Utilities encodeFromPercentEscapeString:[additionalData objectForKey:imageUrlKey]];
    
    NSString *apiPath = [NSString stringWithFormat:@"%@?url=%@&height=%d&width=%d&zoom=1&cropX=%d&cropY=%d&objectId=%lld",kImageCroppingServerURL,imageURL,cropHeight,cropWidth,cropX,cropY,objectID];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =apiPath;
    wooRequestObj.time =900;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =getRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = cropAnImage;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        block(response,success,statusCode);
        
    }  shouldReachServerThroughQueue:TRUE];
}

+(void)getGoogleImageResultForObjectId:(NSString*)objId AndCompletionBlock:(ImageAPICompletionBlock)block{
    NSString *apiPath = [NSString stringWithFormat:@"%@%@?objectId=%@",kBaseURLV7,kImageGoogleCheck,objId];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =apiPath;
    wooRequestObj.time =900;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =getRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = cropAnImage;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        block(response,success,statusCode);
        
    }  shouldReachServerThroughQueue:TRUE];
}


+(void)fetchAlbumsWithCompletionBlock:(ImageAPICompletionBlock)block{
    [APP_Utilities showActivityIndicator];
    
    if (![APP_Utilities reachable]){
        
        [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];


        return;
    }
    NSString *profileDataString = (LoginModel.sharedInstance.isAlternateLogin) ? [NSString stringWithFormat:@"%@%@/full?wooId=%lld&accessToken=%@",kBaseURLV7,kGetUserAlbums,[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue],[[NSUserDefaults standardUserDefaults] objectForKey:kStoredAccessToken]] : [NSString stringWithFormat:@"%@%@/full?wooId=%lld",kBaseURLV7,kGetUserAlbums,[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue]];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =profileDataString;
    wooRequestObj.time =0;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =getRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = getUserFacebookAlbums;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        [APP_Utilities hideActivityIndicator];
        block(response,success,statusCode);
    } shouldReachServerThroughQueue:TRUE];
}

+(void)fetchMoreAlbums:(NSDictionary *)responseDictionary AndCompletionBlock:(ImageAPICompletionBlock)block{
    if ([[responseDictionary objectForKey:@"cursor"] objectForKey:@"after"]) {
        NSString *profileDataString = [NSString stringWithFormat:@"%@%@/full?wooId=%lld&fromOffset=%@",kBaseURLV7,kGetUserAlbums,[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue],[APP_Utilities encodeFromPercentEscapeString:[[responseDictionary objectForKey:@"cursor"] objectForKey:@"after"]]];
        
        WooRequest *wooRequestObj = [[WooRequest alloc]init];
        wooRequestObj.url =profileDataString;
        wooRequestObj.time =0;
        wooRequestObj.requestParams =nil;
        wooRequestObj.methodType =getRequest;
        wooRequestObj.numberOfRetries =3;
        wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
        wooRequestObj.requestType = getUserFacebookAlbums;
        
        [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
            [APP_Utilities hideActivityIndicator];
            block(response,success,statusCode);
        } shouldReachServerThroughQueue:TRUE];
    }
}

+(void)fetchDataFromWebServiceForUserID:(long long int )userID forFacebookAlbum:(NSString *)fbAlbumId
                     AndCompletionBlock:(ImageAPICompletionBlock)block{
    
    
   
    [APP_Utilities showActivityIndicator];
    
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    BOOL isNetworkReachable = (reachability.isReachable || reachability.isReachableViaWiFi || reachability.isReachableViaWWAN);
    if (!isNetworkReachable) {
        SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"Please check your internet connection",nil));
        [APP_Utilities hideActivityIndicator];

        return;
    }

    
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url = (LoginModel.sharedInstance.isAlternateLogin) ? [NSString stringWithFormat:@"%@/user/%@/photos?wooId=%lld&accessToken=%@",kBaseURLV7,fbAlbumId,[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue],[[NSUserDefaults standardUserDefaults] objectForKey:kStoredAccessToken]] : [NSString stringWithFormat:@"%@/user/%@/photos?wooId=%lld",kBaseURLV7,fbAlbumId,[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue]];
    wooRequestObj.time = 90;
    wooRequestObj.requestParams = nil;
    wooRequestObj.methodType = getRequest;
    wooRequestObj.numberOfRetries = 1;
    wooRequestObj.cachePolicy = GET_DATA_FROM_URL_AND_UPDATE_CACHE;
    wooRequestObj.requestType = getUserProfileImage;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        if (requestType == getUserProfileImage) {
            if (statusCode ==401) {
                success = NO;
            }
            block(response,success,statusCode);
        }
    }  shouldReachServerThroughQueue:FALSE];
    
}

+(void)fetchAdditionalDataWithOffset:(NSDictionary *)cursorDictionary forAlbumID:(NSString *)fbAlbumID AndCompletionBlock:(ImageAPICompletionBlock)block{
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url = [NSString stringWithFormat:@"%@/user/%@/photos?wooId=%lld&fromOffset=%@",kBaseURLV7,fbAlbumID,[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue],[cursorDictionary objectForKey:@"after"]];
    wooRequestObj.time = 90;
    wooRequestObj.requestParams = nil;
    wooRequestObj.methodType = getRequest;
    wooRequestObj.numberOfRetries = 1;
    wooRequestObj.cachePolicy = GET_DATA_FROM_URL_AND_UPDATE_CACHE;
    wooRequestObj.requestType = getUserProfileImage;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        if (requestType == getUserProfileImage) {
            if (statusCode ==401) {
                success = NO;
            }
            block(response,success,statusCode);
        }
        
    }  shouldReachServerThroughQueue:FALSE];
}

+(void)deletePhotoForObjectID:(NSString *)objectID AndCompletionBlock:(ImageAPICompletionBlock)block{
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url = [NSString stringWithFormat:@"%@%@?wooId=%@&objectId=%@",kBaseURLV2,kDeletePicture,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],objectID];
    wooRequestObj.time = 90;
    wooRequestObj.requestParams = nil;
    wooRequestObj.methodType = postRequest;
    wooRequestObj.numberOfRetries = 1;
    wooRequestObj.cachePolicy = GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = deleteUserProfileImage;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        if (requestType == deleteUserProfileImage) {
            if (statusCode ==401) {
                success = NO;
            }
            block(response,success,statusCode);
        }
        
    }  shouldReachServerThroughQueue:FALSE];
}


@end
