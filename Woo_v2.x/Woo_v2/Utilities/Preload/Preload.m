//
//  Preload.m
//  Woo
//
//  Created by Vaibhav Gautam on 24/03/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "Preload.h"
//#import "RecommendedUsers.h"
#import "SDWebImagePrefetcher.h"

@implementation Preload


SINGLETON_FOR_CLASS(Preload)


-(void)preloadImagesOfConfirmProfileForArray:(NSArray *)imagesArray{
    NSMutableArray *imageURLs = [[NSMutableArray alloc]init];
    
    if (imagesArray && [imagesArray count]>0) {
        for (NSDictionary *imageData in imagesArray) {
            
            NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(250),IMAGE_SIZE_FOR_POINTS(303), [APP_Utilities encodeFromPercentEscapeString:[imageData objectForKey:kBigImageSourceKey]]]];
            
            NSURL *imageURLProfile = [NSURL URLWithString:[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(320),IMAGE_SIZE_FOR_POINTS(255),[APP_Utilities encodeFromPercentEscapeString:[imageData objectForKey:kBigImageSourceKey]]]];
            
            [imageURLs addObject:imageURL];
            [imageURLs addObject:imageURLProfile];
        }
        
        [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:imageURLs];

    }
}


-(void)preloadImagesOfPhotoSelectionViewFromArray:(NSArray *)imagesArray{
    
    NSMutableArray *imageURLs = [[NSMutableArray alloc]init];

    for(NSMutableDictionary *dict in imagesArray) {
        
        NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(108),IMAGE_SIZE_FOR_POINTS(108), [APP_Utilities encodeFromPercentEscapeString:[dict objectForKey:kBigImageSourceKey]]]];
        
        [imageURLs addObject:imageURL];
    }
    
    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:imageURLs];
}



-(void)preloadImagesOfDiscoverScreenFromAray:(NSArray *)discoverArray{

    NSMutableArray *imageURLs = [[NSMutableArray alloc]init];

    for (id discoverData in discoverArray) {
        
        NSURL *dicoverImageURL = nil;
        NSURL *profileImageURL = nil;
        
        if ([discoverData isKindOfClass:[RecommendedUsers class]]) {
            RecommendedUsers *recommendedUserObj = (RecommendedUsers *)discoverData;

            dicoverImageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(250),IMAGE_SIZE_FOR_POINTS(303), [APP_Utilities encodeFromPercentEscapeString:recommendedUserObj.profilePicURL]]];
            
            profileImageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(320),IMAGE_SIZE_FOR_POINTS(255), [APP_Utilities encodeFromPercentEscapeString:recommendedUserObj.profilePicURL]]];
            

            
        }
        else{
            NSDictionary *discoverDict = (NSDictionary *)discoverData;
            dicoverImageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(250),IMAGE_SIZE_FOR_POINTS(303), [APP_Utilities encodeFromPercentEscapeString:[[discoverDict objectForKey:@"profilePic"] objectForKey:kBigImageSourceKey]]]];
            
            profileImageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(320),IMAGE_SIZE_FOR_POINTS(255), [APP_Utilities encodeFromPercentEscapeString:[[discoverDict objectForKey:@"profilePic"] objectForKey:kBigImageSourceKey]]]];
        }
        
        [imageURLs addObject:dicoverImageURL];
        [imageURLs addObject:profileImageURL];

    }
    
    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:imageURLs];
}

-(void)preloadImageOfMutualFriendsFromArray:(NSArray *)dataArray{

    NSMutableArray *imageURLs = [[NSMutableArray alloc]init];

    for (NSMutableDictionary *dataDictionary in dataArray) {
        
        for (int i = 0; i<[(NSMutableArray*)[dataDictionary objectForKey:kMutualFriendsKey] count]; i++) {
            if (i>1)
                break;
            NSURL *picURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(50),IMAGE_SIZE_FOR_POINTS(50), [APP_Utilities encodeFromPercentEscapeString:[[[dataDictionary objectForKey:kMutualFriendsKey] objectAtIndex:i] objectForKey:@"url"]]]];
            
            [imageURLs addObject:picURL];
            
        } // internal for loop ends here
    }// external for loop ends here
    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:imageURLs];
}


@end
