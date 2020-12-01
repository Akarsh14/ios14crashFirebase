//
//  PurchasePopupScrollableView.m
//  Woo_v2
//
//  Created by Akhil Singh on 12/10/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "PurchasePopupScrollableView.h"
#import "ScrollableCollectionViewCell.h"
#import "PurchaseProductDetailModel.h"

@interface PurchasePopupScrollableView()<UIScrollViewDelegate,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>{
    int currentImageIndex;
    int currentType;
    id currentModelObject;
    int pagenumber;
    BOOL firstTimeDone;
}

@property(nonatomic, strong) UICollectionView *dataCollectionView;
@property(nonatomic, strong) UIPageControl *pageControlObj;
@property(nonatomic, strong) NSArray *dataArray;
@property(nonatomic, strong) NSArray *carousalArray;
@property(nonatomic, strong) NSTimer *autoScrollTimer;
@end

@implementation PurchasePopupScrollableView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect rect = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
        [self setupCollectionViewForFrame:rect];
        
        self.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    [self setNeedsDisplay];
}

- (void)createAddPageControlNowWithFrame:(CGFloat)pageYAxis WithIndex:(NSInteger)pageIndex
{
    if(_pageControlObj == nil)
    {
    _pageControlObj = [[UIPageControl alloc] initWithFrame:CGRectMake(0,
                                                                      self.frame.size.height - 35,
                                                                      self.frame.size.width,
                                                                      35)];
    _pageControlObj.userInteractionEnabled = NO;
    _pageControlObj.pageIndicatorTintColor = [UIColor whiteColor];
    _pageControlObj.currentPageIndicatorTintColor = kRedTagColor;
    _pageControlObj.numberOfPages = [_carousalArray count];
    _pageControlObj.currentPage = currentImageIndex-1;
    [self addSubview:_pageControlObj];
    [self bringSubviewToFront:_pageControlObj];
    }
    
    if ([_carousalArray count] > 1) {
        [_pageControlObj setHidden:NO];
    }
    else{
        [_pageControlObj setHidden:YES];
    }
}

-(void)changePageControlTint:(UIColor*)color
{
    if(_pageControlObj)
    {
        _pageControlObj.currentPageIndicatorTintColor = color;
    }
}
-(void)resetPageNumberForPageControl
{
    _pageControlObj.frame   = CGRectMake(0,self.frame.size.height - 35, self.frame.size.width,35);
    _pageControlObj.currentPage = currentImageIndex-1;
}

-(void)setupCollectionViewForFrame:(CGRect)collectionViewFrame {
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.0f];
    
    _dataCollectionView = [[UICollectionView alloc] initWithFrame:collectionViewFrame collectionViewLayout:flowLayout];
    _dataCollectionView.backgroundColor = [UIColor clearColor];
    _dataCollectionView.delegate = self;
    _dataCollectionView.dataSource = self;
    _dataCollectionView.pagingEnabled = YES;
    _dataCollectionView.autoresizesSubviews = NO;
    _dataCollectionView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_dataCollectionView];
    
    //    [imageGalleryCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.equalTo(self.mas_top);
    //        make.bottom.equalTo(self.mas_bottom);
    //        make.left.equalTo(self.mas_left);
    //        make.right.equalTo(self.mas_right);
    //    }];
    
    [_dataCollectionView registerClass:[ScrollableCollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
}

- (void)setupDataWithModel:(id)modelObject ForType:(int)type withIndex:(int)index{
    
    
    currentType = type;
    currentModelObject = modelObject;
    currentImageIndex = index;
    switch (type) {
        case 1:
            if ([[(BoostProductModel *)modelObject carousalType] isEqualToString:@"IMAGE"]) {
                _carousalArray = [(BoostProductModel *)modelObject backGroundImages];
            }
            else if ([[(BoostProductModel *)modelObject carousalType] isEqualToString:@"TEXT"] || [[(BoostProductModel *)modelObject carousalType] isEqualToString:@"HYBRID"]){
                _carousalArray = [(BoostProductModel *)modelObject carousals];
            }
            else{
                _carousalArray = nil;
            }
            break;
        case 2:
            if ([[(CrushProductModel *)modelObject carousalType] isEqualToString:@"IMAGE"]) {
                _carousalArray = [(CrushProductModel *)modelObject backGroundImages];
            }
            else if ([[(CrushProductModel *)modelObject carousalType] isEqualToString:@"TEXT"] || [[(CrushProductModel *)modelObject carousalType] isEqualToString:@"HYBRID"]){
                _carousalArray = [(CrushProductModel *)modelObject carousals];
            }
            else{
                _carousalArray = nil;
            }
            break;
        case 3:
            if ([[(WooPlusProductModel *)modelObject carousalType] isEqualToString:@"IMAGE"]) {
                _carousalArray = [(WooPlusProductModel *)modelObject backGroundImages];
            }
            else if ([[(WooPlusProductModel *)modelObject carousalType] isEqualToString:@"TEXT"] || [[(WooPlusProductModel *)modelObject carousalType] isEqualToString:@"HYBRID"]){
                _carousalArray = [(WooPlusProductModel *)modelObject carousals];
            }
            else{
                _carousalArray = nil;
            }
            break;
        case 4:
            if ([[(WooGlobalProductModel *)modelObject carousalType] isEqualToString:@"IMAGE"]) {
                _carousalArray = [(WooGlobalProductModel *)modelObject backGroundImages];
            }
            else if ([[(WooGlobalProductModel *)modelObject carousalType] isEqualToString:@"TEXT"] || [[(WooGlobalProductModel *)modelObject carousalType] isEqualToString:@"HYBRID"]){
                _carousalArray = [(WooGlobalProductModel *)modelObject carousals];
            }
            else{
                _carousalArray = nil;
            }
            break;
        default:
                _carousalArray = nil;
            break;
    }
    
    _pageControlObj.numberOfPages = [_carousalArray count];
    _dataArray = [NSArray arrayWithArray:_carousalArray];

    if ([_dataArray count]>0) {
        if ([_dataArray count]>1) {
            id firstItem = [_dataArray firstObject];
            id lastItem = [_dataArray lastObject];
            NSMutableArray *mutableAlbumArray = [_dataArray mutableCopy];
            [mutableAlbumArray insertObject:lastItem atIndex:0];
            [mutableAlbumArray addObject:firstItem];
            _dataArray = mutableAlbumArray;
            [_dataCollectionView reloadData];
            [_dataCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        }
        else{
            [_dataCollectionView reloadData];
            
        }
        
        if (_autoScrollTimer != nil) {
            [_autoScrollTimer invalidate];
            _autoScrollTimer = nil;
        }
        
        NSLog(@"currentImageIndex=%d",currentImageIndex);
        [_dataCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:currentImageIndex inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionLeft
                                            animated:NO];
        firstTimeDone = false;
        _autoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(autoScrollCaruosal) userInfo:nil repeats:true];
    }
}

- (void)autoScrollCaruosal{
   
    firstTimeDone = true;
    pagenumber = currentImageIndex+1;
    if (pagenumber == [_dataArray count]) {
        pagenumber = 2;
        [_dataCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionLeft
                                            animated:NO];
    }
    [_dataCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:pagenumber inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionLeft
                                        animated:YES];
        pagenumber++;
}

- (void)updatePaginationIndexWithIndex:(NSInteger)index
{
    NSLog(@"Purchase Pop is called");

    if (index == 0) {
        _pageControlObj.currentPage = [_dataArray count] - 1;
    }
    else if (index == [_dataArray count]){
        _pageControlObj.currentPage =  0;
    }
    else{
        _pageControlObj.currentPage = index - 1;
    }
}

#pragma mark - <UIScrollViewDelegate>

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (firstTimeDone == false) {
        return;
    }
    
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
    CGFloat offset = pageWidth * (_dataArray.count - 2);
    
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
    
    currentImageIndex = (int)currentOffsetX/pageWidth;
    [self updatePaginationIndexWithIndex:currentImageIndex];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (firstTimeDone == false) {
        return;
    }
    
    CGFloat currentOffsetX = scrollView.contentOffset.x;
    CGFloat pageWidth = scrollView.frame.size.width;
    currentImageIndex = (int)currentOffsetX/pageWidth;
    [self updatePaginationIndexWithIndex:currentImageIndex];
}

#pragma mark - collectionView Delegate and Datasource Function

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return [_dataArray count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ScrollableCollectionViewCell *cell = (ScrollableCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    NSString *imageName;
    NSString *baseUrlName;
    NSDictionary *textDict;
    NSString *carousalType;
    
    switch (currentType) {
        case 1:
            if ([[(BoostProductModel *)currentModelObject carousalType] isEqualToString:@"IMAGE"]) {
                baseUrlName = [(BoostProductModel *)currentModelObject baseImageUrl];
                imageName = [_dataArray objectAtIndex:indexPath.row];
                carousalType = [(BoostProductModel *)currentModelObject carousalType];
            }
            else if ([[(BoostProductModel *)currentModelObject carousalType] isEqualToString:@"TEXT"] || [[(BoostProductModel *)currentModelObject carousalType] isEqualToString:@"HYBRID"]){
                baseUrlName = [(BoostProductModel *)currentModelObject baseImageUrl];
                textDict = [_dataArray objectAtIndex:indexPath.row];
                carousalType = [(BoostProductModel *)currentModelObject carousalType];
            }
            break;
        case 2:
            if ([[(CrushProductModel *)currentModelObject carousalType] isEqualToString:@"IMAGE"]) {
                _dataArray = [(CrushProductModel *)currentModelObject backGroundImages];
                baseUrlName = [(CrushProductModel *)currentModelObject baseImageUrl];
                imageName = [_dataArray objectAtIndex:indexPath.row];
                carousalType = [(CrushProductModel *)currentModelObject carousalType];
            }
            else if ([[(CrushProductModel *)currentModelObject carousalType] isEqualToString:@"TEXT"] || [[(CrushProductModel *)currentModelObject carousalType] isEqualToString:@"HYBRID"]){
                baseUrlName = [(CrushProductModel *)currentModelObject baseImageUrl];
                textDict = [_dataArray objectAtIndex:indexPath.row];
                carousalType = [(CrushProductModel *)currentModelObject carousalType];
            }
            break;
        case 3:
            if ([[(WooPlusProductModel *)currentModelObject carousalType] isEqualToString:@"IMAGE"]) {
                baseUrlName = [(WooPlusProductModel *)currentModelObject baseImageUrl];
                imageName = [_dataArray objectAtIndex:indexPath.row];
                carousalType = [(WooPlusProductModel *)currentModelObject carousalType];
            }
            else if ([[(WooPlusProductModel *)currentModelObject carousalType] isEqualToString:@"TEXT"] || [[(WooPlusProductModel *)currentModelObject carousalType] isEqualToString:@"HYBRID"]){
                baseUrlName = [(WooPlusProductModel *)currentModelObject baseImageUrl];
                textDict = [_dataArray objectAtIndex:indexPath.row];
                carousalType = [(WooPlusProductModel *)currentModelObject carousalType];
            }
            break;
        case 4:
            if ([[(WooGlobalProductModel *)currentModelObject carousalType] isEqualToString:@"IMAGE"]) {
                baseUrlName = [(WooGlobalProductModel *)currentModelObject baseImageUrl];
                imageName = [_dataArray objectAtIndex:indexPath.row];
                carousalType = [(WooGlobalProductModel *)currentModelObject carousalType];
            }
            else if ([[(WooGlobalProductModel *)currentModelObject carousalType] isEqualToString:@"TEXT"] || [[(WooGlobalProductModel *)currentModelObject carousalType] isEqualToString:@"HYBRID"]){
                baseUrlName = [(WooGlobalProductModel *)currentModelObject baseImageUrl];
                textDict = [_dataArray objectAtIndex:indexPath.row];
                carousalType = [(WooGlobalProductModel *)currentModelObject carousalType];
            }
            break;
        default:
            _dataArray = nil;
            break;
    }

    [cell loadViewForType:carousalType withImage:imageName orTextData:textDict baseImageUrlName:baseUrlName andCurrentType:currentType];
    
    return cell;
}

#pragma mark - collectionView FlowDelegate Function

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return _dataCollectionView.frame.size;
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

-(void) removeFromSuperview{
    
    if (_autoScrollTimer) {
        [_autoScrollTimer invalidate];
        _autoScrollTimer = nil;
    }
    
    [super removeFromSuperview];
}

@end
