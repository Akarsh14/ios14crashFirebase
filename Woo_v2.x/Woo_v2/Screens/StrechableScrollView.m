//
//  StrechableScrollViewController.m
//  Woo_v2
//
//  Created by Suparno Bose on 30/11/15.
//  Copyright © 2015 Woo. All rights reserved.
//

#import "StrechableScrollView.h"
#import "Woo_v2-Swift.h"
#import "ImageGalleryViewCollectionViewCell.h"
#import "SDWebImageManager.h"
#import "SDWebImagePrefetcher.h"


#define kPhotoPending   @"PENDING"

@interface StrechableScrollView ()<UIScrollViewDelegate,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    __strong NSMutableArray *imagesDataArray;
    __weak WooAlbumModel *wooAlbum;
    __strong NSMutableArray *albumArray;
    __strong NSMutableArray *imageViewArray;
    int currentImageIndex;
    
    CAGradientLayer *gradientTop;
    CAGradientLayer *gradientBottom;
    BOOL isComingsFromDiscover;
}
@end

@implementation StrechableScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect rect = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
        [self setupCollectionViewForFrame:rect];
        
        self.backgroundColor = [UIColor clearColor];
        
        _isAllowedToTapNow = true;
        
        //        [self addTapGestureRecognizer];
    }
    return self;
}

- (void)dealloc
{
    imagesDataArray = nil;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    [self setNeedsDisplay];
}

- (void)createAddPageControlNowWithFrame:(CGFloat)pageYAxis WithIndex:(NSInteger)pageIndex
{
    
    if(_pageControlObj==nil){
        _pageControlObj = [[UIPageControl alloc] initWithFrame:CGRectMake(self.frame.size.width/2-100,self.frame.size.height - 55,200,35)];
        _pageControlObj.userInteractionEnabled = NO;
        _pageControlObj.alpha  = 0;
        _pageControlObj.pageIndicatorTintColor = [UIColor whiteColor];
        _pageControlObj.currentPageIndicatorTintColor = kRedTagColor;
        _pageControlObj.currentPage = pageIndex;
        [self addSubview:_pageControlObj];
    }
//        [self bringSubviewToFront:_pageControlObj];
    
    int photoCount = 0;
    if (_isMyProfile == true){
        photoCount = [wooAlbum countOfApprovedPhotos];
    }
    else{
        photoCount = [wooAlbum count];
    }
        if(photoCount>1){
            _pageControlObj.alpha  = 0.0f;
            [_pageControlObj setHidden:YES];
            _pageControlObj.numberOfPages = photoCount;
            [UIView animateWithDuration:1.0f animations:^{
                [_pageControlObj setHidden:NO];
                _pageControlObj.alpha  = 1.0f;
            }];
        }


    if (photoCount > 1) {
        [_pageControlObj setHidden:NO];
        

    }
    else{
        [_pageControlObj setHidden:YES];
    }
}
#pragma mark - Exposed function

-(void)setupCollectionViewForFrame:(CGRect)collectionViewFrame {
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.0f];
    
    _imageGalleryCollectionView = [[UICollectionView alloc] initWithFrame:collectionViewFrame collectionViewLayout:flowLayout];
    
    _imageGalleryCollectionView.delegate = self;
    _imageGalleryCollectionView.dataSource = self;
    _imageGalleryCollectionView.pagingEnabled = YES;
    _imageGalleryCollectionView.autoresizesSubviews = NO;
    _imageGalleryCollectionView.showsHorizontalScrollIndicator = NO;
//    [_imageGalleryCollectionView setPrefetchingEnabled:NO];
    [self addSubview:_imageGalleryCollectionView];
    
//    [imageGalleryCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.mas_top);
//        make.bottom.equalTo(self.mas_bottom);
//        make.left.equalTo(self.mas_left);
//        make.right.equalTo(self.mas_right);
//    }];
    
    [_imageGalleryCollectionView registerClass:[ImageGalleryViewCollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
}

-(NSInteger) getCurrentImageIndex{
    NSLog(@"currentPage=%ld",(long)_pageControlObj.currentPage);
    if (_pageControlObj && _pageControlObj.currentPage > 0) {
        return _pageControlObj.currentPage;
    }
    else{
        return 0;
    }
}

-(NSString *)getCurrentImageUrlString{
    return [albumArray objectAtIndex:currentImageIndex];
}


-(void)setWooAlbum: (WooAlbumModel*) wooAlbumModel fromDiscover:(BOOL)comingfromDiscover
{
    wooAlbum = nil;
    wooAlbum = wooAlbumModel;
    albumArray = nil;
    albumArray = [[NSMutableArray alloc] init];//WithArray:[wooAlbum allImagesUrlWithOutPending]];
    if (_isMyProfile == true){
    for (NSString *url in [wooAlbum allApprovedImagesUrl]) {
        if(![albumArray containsObject:url])
            [albumArray addObject:url];
    }
    }
    else{
        for (NSString *url in [wooAlbum allImagesUrl]) {
            if(![albumArray containsObject:url])
                [albumArray addObject:url];
        }
    }
    //[self fetchAllImages];
    [self addImageToScrollView:comingfromDiscover];
}

-(void)fetchAllImages{
    
    NSLog(@"image array %@",albumArray);
    if (albumArray && [albumArray count] >0) {
        [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:albumArray];
    }
    
}

-(void)changeFrameTo:(CGRect)frame{
    return;
    if(imagesDataArray){
        [self setFrame:CGRectMake(self.frame.origin.x,
                                  frame.origin.y,
                                  self.frame.size.width,
                                  frame.size.height)];
        [_imageGalleryCollectionView setFrame:CGRectMake(_imageGalleryCollectionView.frame.origin.x,
                                        _imageGalleryCollectionView.frame.origin.y,
                                        self.frame.size.width,
                                        frame.size.height)];
        NSInteger  pagenumber= [self getCurrentImageIndex];
        UIImageView *view           = [self getImageViewForIndex:pagenumber];
        if(view){
        [view setFrame:CGRectMake((pagenumber * SCREEN_WIDTH) - (frame.size.width - view.frame.size.width),
                                  view.frame.origin.y,
                                  frame.size.width,
                                  frame.size.height)];
            
            if (!_pageControlObj.hidden) {
                [_pageControlObj setFrame:CGRectMake(0,
                                                     self.frame.size.height - 35,
                                                     self.frame.size.width,
                                                     35)];
            }
            UIImageView *statusView = [[view subviews] lastObject];
            if (statusView) {
                [statusView setFrame:CGRectMake(5, (view.frame.size.height - 20 - 15), 30, 30)];
            }
        }
        [view setNeedsDisplay];
        [view setNeedsLayout];
    }
}

-(NSInteger)imageCount{
    return [imagesDataArray count];
}

-(void)removeShadowLayersFromCurrentImage{
    if (_imageGalleryCollectionView.visibleCells) {
        ImageGalleryViewCollectionViewCell *cell = _imageGalleryCollectionView.visibleCells.firstObject;
        [cell removeShadowLayers];
    }
   
}

#pragma mark - Internal Functions


- (void)addImageToScrollView:(BOOL)isFromDiscover{
    int photoCount = 0;
    if (_isMyProfile == true){
        photoCount = [wooAlbum countOfApprovedPhotos];
    }
    else{
        photoCount = [wooAlbum count];
    }
    _pageControlObj.numberOfPages = photoCount;

    if (photoCount>0) {
        if ([albumArray count]>1) {
           
            
            if(isFromDiscover)
            {
                isComingsFromDiscover = YES;
                id firstItem = [albumArray firstObject];
                id lastItem = [albumArray lastObject];
                NSMutableArray *mutableAlbumArray = [albumArray mutableCopy];
                [mutableAlbumArray insertObject:lastItem atIndex:0];
                [mutableAlbumArray addObject:firstItem];
                albumArray = mutableAlbumArray;
                [_imageGalleryCollectionView reloadData];
                
                [_imageGalleryCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];

            }
            else
            {
                if ([albumArray count] > [_imageGalleryCollectionView numberOfItemsInSection:0])
                {
                    NSMutableArray *arrayOfIndices = [[NSMutableArray alloc]init];
                    NSLog(@"[albumArray count] %lu",(unsigned long)[albumArray count]);
                    for(int i =1 ; i < [albumArray count] ; i++)
                    {
                        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
                        [arrayOfIndices addObject:indexPath];
                    }
                    [_imageGalleryCollectionView numberOfItemsInSection:0];
                    [_imageGalleryCollectionView performBatchUpdates:^{
                        [_imageGalleryCollectionView insertItemsAtIndexPaths:arrayOfIndices];
                        
                    } completion:nil];

                }
            isComingsFromDiscover = NO;
    
            }
        }
        else{
            
            [_imageGalleryCollectionView reloadData];

        }
    }
}

-(void)generateImageViews{
    if (imageViewArray) {
        imageViewArray = nil;
    }
    imageViewArray = [[NSMutableArray alloc] init];
    
    CGFloat imageWidth = self.frame.size.width;
    CGFloat imageHeight = self.frame.size.height;
    
    int photoCount = 0;
    if (_isMyProfile == true){
        photoCount = [wooAlbum countOfApprovedPhotos];
    }
    else{
        photoCount = [wooAlbum count];
    }
    for (int index = 0; index < photoCount; index++)
    {
        AlbumPhoto *photoInfo = nil;

        if (_isMyProfile == true){
            photoInfo = [wooAlbum approvedObjectAtIndex:index];
        }
        else{
            photoInfo = [wooAlbum objectAtIndex:index];
        }
        
        UIImageView *userGalleryImage = [[UIImageView alloc]init];
        [userGalleryImage setBackgroundColor:[UIColor blueColor]];
        userGalleryImage.contentMode = UIViewContentModeScaleAspectFill;
        [userGalleryImage setFrame:CGRectMake(index*imageWidth,
                                              0,
                                              imageWidth,
                                              imageHeight)];
        
        UIImageView *imageStatusView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_upload_photo_pending_big"]];
        [imageStatusView setBackgroundColor:[UIColor clearColor]];
        [imageStatusView setFrame:CGRectMake(5, (userGalleryImage.frame.size.height - 20 - 15), 30, 30)];
        
        if (![photoInfo.status isEqualToString:kPhotoPending]) {
            [imageStatusView setImage:nil];
        }
        [userGalleryImage addSubview:imageStatusView];
        
        userGalleryImage.tag = index;
        
        NSString *urlString = photoInfo.url;
        NSURL *imageURL =[NSURL URLWithString:urlString];
        NSLog(@"@@@>%@",imageURL);
        [userGalleryImage sd_setImageWithURL:imageURL
                            placeholderImage:[UIImage imageNamed:(self.isMale?@"placeholder_male":@"placeholder_female")] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imagURL) {
                                NSLog(@"###>%@ = Error -> %@",imagURL,error.description);
                                UIImage *image_ = image;
                            }];
        
        [imageViewArray addObject:userGalleryImage];

    }
}

/*!
 * @discussion this function returns the Imageview object of a given index
 * @param index index for the UIImageView
 * @return image view at the index given
 */
-(UIImageView*) getImageViewForIndex: (NSInteger) index{
    UIImageView *currentIndexView;
    if ([_imageGalleryCollectionView.subviews count]> 0 && index < [_imageGalleryCollectionView.subviews count]) {
        currentIndexView    = (UIImageView *)[_imageGalleryCollectionView.subviews objectAtIndex:index];
    }
    return currentIndexView;
}

/*!
 * @discussion Adds tap gesture recogniser to the view
 */
- (void) addTapGestureRecognizer{
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    doubleTap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:doubleTap];
}

/*!
 * @discussion Handler function for tap gesture
 * @param tapGestureRecognizer Tap gesture recognizer
 */
-(void) tapHandler:(UIPanGestureRecognizer *)tapGestureRecognizer{
}

- (void)getTappedImageIndexWithBlock:(TapExecutionBlock)block
{
    _tapBlock = block;
}

- (void)updatePaginationIndexWithIndex:(NSInteger)index
{
    if (index == 0) {
        if (_isMyProfile == true){
        _pageControlObj.currentPage = [wooAlbum countOfApprovedPhotos
                                       ] - 1;
        }
        else{
            _pageControlObj.currentPage = [wooAlbum count
                                           ] - 1;
        }
    }
    else if (index == [albumArray count]){
        _pageControlObj.currentPage =  0;
    }
    else{
        _pageControlObj.currentPage = index - 1;
    }
}

#pragma mark - <UIScrollViewDelegate>

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    
//    if(!isComingsFromDiscover)
//    {
//        return;
//    }
    
    if(isComingsFromDiscover)
    {
        static CGFloat lastContentOffsetX = FLT_MIN;
        
        // We can ignore the first time scroll,
        // because it is caused by the call scrollToItemAtIndexPath: in ViewWillAppear
        if (FLT_MIN == lastContentOffsetX) {
            lastContentOffsetX = scrollView.contentOffset.x;
            return;
        }
        
        CGFloat currentOffsetX = scrollView.contentOffset.x;
        CGFloat currentOffsetY = scrollView.contentOffset.y;
        
        CGFloat pageWidth = scrollView.frame.size.width;
        CGFloat offset = pageWidth * (albumArray.count - 2);
        
        // the first page(showing the last item) is visible and user's finger is still scrolling to the right
        if (currentOffsetX < pageWidth && lastContentOffsetX > currentOffsetX) {
            lastContentOffsetX = currentOffsetX + offset;
            scrollView.contentOffset = (CGPoint){lastContentOffsetX, currentOffsetY};
        }
        // the last page (showing the first item) is visible and the user's finger is still scrolling to the left
        else if (currentOffsetX > offset && lastContentOffsetX < currentOffsetX) {
            lastContentOffsetX = currentOffsetX - offset;
            scrollView.contentOffset = (CGPoint){lastContentOffsetX, currentOffsetY};
        } else {
            lastContentOffsetX = currentOffsetX;
        }
    }
    else
    {
        static CGFloat lastContentOffsetX = FLT_MIN;
        
        // We can ignore the first time scroll,
        // because it is caused by the call scrollToItemAtIndexPath: in ViewWillAppear
//        if (FLT_MIN == lastContentOffsetX) {
//            lastContentOffsetX = scrollView.contentOffset.x;
//            return;
//        }
        
        CGFloat currentOffsetX = scrollView.contentOffset.x;
       // CGFloat currentOffsetY = scrollView.contentOffset.y;
        
//        CGFloat pageWidth = scrollView.frame.size.width;
//        CGFloat offset = pageWidth * (albumArray.count - 2);
        
        lastContentOffsetX = currentOffsetX;
       // scrollView.contentOffset = (CGPoint){lastContentOffsetX, currentOffsetY};
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat currentOffsetX = scrollView.contentOffset.x;
    CGFloat pageWidth = scrollView.frame.size.width;
    currentImageIndex = (int)currentOffsetX/pageWidth;
    if(isComingsFromDiscover)
    {
        [self updatePaginationIndexWithIndex:currentImageIndex];
    }
    else
    {
        _pageControlObj.currentPage = currentImageIndex;
    }
}

#pragma mark - collectionView Delegate and Datasource Function

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return [albumArray count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ImageGalleryViewCollectionViewCell *cell = (ImageGalleryViewCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    NSLog(@"indexpath.row %ld",(long)indexPath.row);
    NSString *urlString = [albumArray objectAtIndex:indexPath.row];
    NSLog(@"urlString %@",urlString);

    if (_isUsedInBrandCard == true) {
        cell.profileImageView.contentMode = UIViewContentModeScaleToFill;
    }
    else{
    cell.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    if (indexPath.item == 0){
        if (_firstImage != nil) {
            cell.profileImageView.image = _firstImage;
            cell.isProfileImageAlreadyLoaded = true;
        }
        else{
            cell.isProfileImageAlreadyLoaded = false;
            [cell loadImageWithImageNamed:urlString ForGender:self.isMale];
        }
    }
    else{
        cell.isProfileImageAlreadyLoaded = false;
        [cell loadImageWithImageNamed:urlString ForGender:self.isMale];
 
    }
    
//    if (!gradientTop) {
//        gradientTop = [CAGradientLayer layer];
//    }
//    else{
//        [gradientTop removeFromSuperlayer];
//    }
//    gradientTop.frame = CGRectMake(0, 0,
//                                [UIScreen mainScreen].bounds.size.width,
//                                cell.bounds.size.height/5);
//    gradientTop.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7] CGColor],
//                       (id)[[UIColor clearColor] CGColor], nil];
//    
//    if (!gradientBottom) {
//        gradientBottom = [CAGradientLayer layer];
//    }
//    else{
//        [gradientBottom removeFromSuperlayer];
//    }
//    gradientBottom.frame = CGRectMake(0, cell.bounds.size.height*2/3 - 49,
//                                [UIScreen mainScreen].bounds.size.width,
//                                cell.bounds.size.height/3 + 49);
//    gradientBottom.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor],
//                       (id)[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.9] CGColor], nil];
//    
//    if (_isShownInProfile == true) {
//        [cell.layer addSublayer:gradientTop];
//        [cell.layer addSublayer:gradientBottom];
//    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isAllowedToTapNow == true){
    _tapBlock(indexPath.row);
    }
}

#pragma mark - collectionView FlowDelegate Function

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return _imageGalleryCollectionView.frame.size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

// Layout: Set Edges
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0,0,0,0);  // top, left, bottom, right
}

- (void)registerNib:(UINib *)nib forSupplementaryViewOfKind:(NSString *)kind withReuseIdentifier:(NSString *)identifier{
    
}

@end
