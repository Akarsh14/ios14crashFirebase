//
//  ImagePrecache.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 18/04/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "ImagePrecache.h"

@implementation ImagePrecache


+ (id)sharedPreCache {
    static ImagePrecache *sharedPrecacheObj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPrecacheObj = [[self alloc] init];
    });
    return sharedPrecacheObj;
}


-(void)downloadFilesFromURLArray:(NSArray *)imageURLArray{
    

    for (id image in imageURLArray) {
     
        if ([image isKindOfClass:[NSURL class]] ) {
            
            [self downloadFileFromURL:(NSURL *)image];
            
        }else if ([image isKindOfClass:[NSString class]]){
            
            [self downloadFileFromURL:[NSURL URLWithString:(NSString *)image]];
            
        }
    }
}


-(void)downloadFileFromURL:(NSURL *)imageURL{
    
    CGFloat imageWidth = SCREEN_WIDTH;
    CGFloat imageHeight = (SCREEN_WIDTH *0.8);
    
    SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];
    
    NSURL *ImageCroppedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(imageWidth),IMAGE_SIZE_FOR_POINTS(imageHeight),[APP_Utilities encodeFromPercentEscapeString:[imageURL absoluteString]]]];
    
        [downloader downloadImageWithURL:ImageCroppedUrl options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//            nothing to do here
        } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
//            nothing to do here too
        }];
}

@end
