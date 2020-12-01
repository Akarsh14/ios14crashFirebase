//
//  ImageAPIClass.h
//  Woo_v2
//
//  Created by Suparno Bose on 17/02/16.
//  Copyright © 2016 Woo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ImageAPICompletionBlock)(id,BOOL,int);

@interface ImageAPIClass : NSObject

+(void)fetchUserImagesWithCompletionBlock:(ImageAPICompletionBlock)block;

+(BOOL)updateUserWooAlbumWithPayloadString:(NSString*)payloadString
                           AndProfilePicId:(NSString*)profilePicID
                        AndCompletionBlock:(ImageAPICompletionBlock)block;

+(BOOL)uploadImageToServer:(UIImage *)image AndObjectId:(NSString*)objetId
             WithFakeCheck:(BOOL)ifYES
       WithCompletionBlock:(ImageAPICompletionBlock)block;

+(void)cropImageToServerWithImageData:(NSDictionary *)editedImageData
                    AndAdditionalData:(NSDictionary*)additionalData
                  WithCompletionBlock:(ImageAPICompletionBlock)block;
+(void)getGoogleImageResultForObjectId:(NSString*)objId AndCompletionBlock:(ImageAPICompletionBlock)block;

+(void)fetchAlbumsWithCompletionBlock:(ImageAPICompletionBlock)block;

+(void)fetchMoreAlbums:(NSDictionary *)responseDictionary AndCompletionBlock:(ImageAPICompletionBlock)block;

+(void)fetchDataFromWebServiceForUserID:(long long int )userID forFacebookAlbum:(NSString *)fbAlbumId
                     AndCompletionBlock:(ImageAPICompletionBlock)block;

+(void)fetchAdditionalDataWithOffset:(NSDictionary *)cursorDictionary forAlbumID:(NSString *)fbAlbumID
                  AndCompletionBlock:(ImageAPICompletionBlock)block;
+(void)deletePhotoForObjectID:(NSString *)objectID AndCompletionBlock:(ImageAPICompletionBlock)block;
@end
