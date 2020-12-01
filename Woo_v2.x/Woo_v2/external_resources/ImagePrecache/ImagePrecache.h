//
//  ImagePrecache.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 18/04/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImagePrecache : NSObject{
    
}



+ (id)sharedPreCache;

/**
 *  This method will download all the images provided in the URL
 *
 *  @param imageURLArray This array will contain URLs to be downloaded
 */
-(void)downloadFilesFromURLArray:(NSArray *)imageURLArray;

/**
 *  This method will download and cache a single imagr from URL
 *
 *  @param imageURL This method will download a single image from the URL
 */
-(void)downloadFileFromURL:(NSURL *)imageURL;


@end
