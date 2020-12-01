//
//  StrechableScrollViewController.h
//  Woo_v2
//
//  Created by Suparno Bose on 30/11/15.
//  Copyright © 2015 Woo. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void (^TapExecutionBlock)(NSInteger);

@class WooAlbumModel;

@interface StrechableScrollView : UIView

@property(nonatomic, assign) BOOL isMale;

@property(nonatomic, assign) BOOL isAllowedToTapNow;

@property(nonatomic, assign) BOOL isShownInProfile;

@property(nonatomic, assign) BOOL isMyProfile;

@property(nonatomic, assign) BOOL isUsedInBrandCard;

@property(nonatomic, strong) UIPageControl *pageControlObj;

@property(nonatomic, strong) TapExecutionBlock tapBlock;

@property(nonatomic, strong) UICollectionView *imageGalleryCollectionView;

@property(nonatomic, strong) UIImage *firstImage;

/*!
 * @discussion Add image view to the scrollview
 * @param imageInfoArray array containing image infos
 */
-(instancetype)initWithFrame:(CGRect)frame;

-(void)addImageArray: (NSMutableArray*) imageInfoArray;

-(void)setWooAlbum: (WooAlbumModel*) wooAlbumModel fromDiscover:(BOOL)comingfromDiscover;
/*!
 * @discussion Change the frame of scrollview and the current indexed image
 * @param frame new frame of the scrollView
 */
-(void)changeFrameTo:(CGRect)frame;

/*!
 * @discussion returns the current Selected image Index of scrollView
 * @return currentIndex current Index of scrollview
 */
-(NSInteger)getCurrentImageIndex;

-(NSString *)getCurrentImageUrlString;

- (void)createAddPageControlNowWithFrame:(CGFloat)pageYAxis WithIndex:(NSInteger)pageIndex;
/*!
 * @discussion returns the count of images in scrollView
 * @return count of images
 */
-(NSInteger)imageCount;

- (void)getTappedImageIndexWithBlock:(TapExecutionBlock)block;


- (void)removeShadowLayersFromCurrentImage;
@end
