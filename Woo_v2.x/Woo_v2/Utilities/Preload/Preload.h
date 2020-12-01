//
//  Preload.h
//  Woo
//
//  Created by Vaibhav Gautam on 24/03/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Preload : NSObject{
    
}
/**
 *  This method will be used to create shared instance of the class.
 *
 *  @return shared object of class "Preload"
 */
+(Preload *)sharedPreload;

/**
 *  This method will prefetch images for confirm profile screen when fake profile check is being performed.
 *
 *  @param imagesArray array of image URLs
 */
-(void)preloadImagesOfConfirmProfileForArray:(NSArray *)imagesArray;

/**
 *  This method will be used to prefetch the images for photo selection view
 *
 *  @param imagesArray array or image URLs
 */
-(void)preloadImagesOfPhotoSelectionViewFromArray:(NSArray *)imagesArray;

/**
 *  This method will be used to prefetch the images for discover screen recommendation
 *
 *  @param discoverArray array of objects of RecommendedUsers class
 */
-(void)preloadImagesOfDiscoverScreenFromAray:(NSArray *)discoverArray;


/**
 *  This method will prefetch images of mutual friends if they exists for any friend
 *
 *  @param dataArray array or image URLs
 */
-(void)preloadImageOfMutualFriendsFromArray:(NSArray *)dataArray;

@end
