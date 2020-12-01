//
//  ImageGalleryController.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 09/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageGalleryController : UIViewController<UIScrollViewDelegate>{
    
    __weak IBOutlet UIScrollView *galleryScroller;
    __weak IBOutlet UIPageControl *pageControlObj;
    __weak IBOutlet UIView *bottomProfileInformationView;
    
    NSMutableArray *imagesDataArray;
}

@property(nonatomic, assign) NSInteger currentIndex;
@property(nonatomic, assign) BOOL needToShowFullImages;
@property(nonatomic, assign) BOOL isMale;
@property(nonatomic, assign) BOOL isAppeared;
@property(nonatomic, assign) BOOL isProfileInformationNeeded;

-(IBAction)backButtonTapped:(id)sender;

-(void)createGalleryWithImagesFromArray:(NSMutableArray *)imagesArray;

-(void)setCurrentImageIndex:(NSInteger) index;

@end
