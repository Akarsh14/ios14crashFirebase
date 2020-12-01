//
//  StickerView.m
//  Woo
//
//  Created by Vaibhav Gautam on 07/05/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "StickerView.h"
#import "StickerCell.h"

@implementation StickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"StickerView" owner:self options:nil];
        UIView *nibView = [nibArray lastObject];
        nibView.frame   = self.bounds;
        
        [self addSubview:nibView];
        
        
        [_collectionViewObj registerClass:[StickerCell class] forCellWithReuseIdentifier:@"StickerCell"];
        [_collectionViewObj setDelegate:self];
//        _collectionViewObj.frame = self.bounds;
        self.backgroundColor = [UIColor colorWithRed:0.76 green:0.76 blue:0.76 alpha:1];
        [self setupCollectionView];
        [self prepareDummeDataArray];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)prepareDummeDataArray{
    
    if (!stickerDataArray) {
        stickerDataArray = [[NSMutableArray alloc]init];
    }
    
    if ([stickerDataArray count] >0) {
        [stickerDataArray removeAllObjects];
    }
    
    NSArray *stickerNmaeArray = [[AppLaunchModel sharedInstance] stickersArray];
    for (int i = 0; i < [stickerNmaeArray count]; i++) {
        
        [stickerDataArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat:@"%d",i],@"stickerID",
                               [stickerNmaeArray objectAtIndex:i],@"stickerURL",
                              nil]];
    }    
}


#pragma mark - CollectionView delegate methods
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [stickerDataArray count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *cellIdentifier = @"StickerCell";
    
    StickerCell *cell = (StickerCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [cell setDataOnCellFromDictionary:[stickerDataArray objectAtIndex:indexPath.row]];
    [cell setDelegate:self];
    [cell setSelectorForStickerTapped:@selector(collectionCellTappedWithData:)];
    return cell;
}

-(void)collectionCellTappedWithData:(id)dataFromCell{

//    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Send_Sticker];
    
    if ([_delegate respondsToSelector:_selectorForStickerTapped]) {
        [_delegate performSelector:_selectorForStickerTapped withObject:dataFromCell];
    }
}


//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
//{
//// top left bottom right
//    return UIEdgeInsetsMake(20, 20, 20, 20);
//}


-(void)setupCollectionView{
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    [flowLayout setItemSize:CGSizeMake(80, 80)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setSectionInset:UIEdgeInsetsMake(19, 19, 19, 19)];
    
    [flowLayout setMinimumLineSpacing:25.0f];
    [_collectionViewObj setCollectionViewLayout:flowLayout];
    [_collectionViewObj setBackgroundColor:[UIColor colorWithRed:0.76 green:0.76 blue:0.76 alpha:1]];
//    [_collectionViewObj setFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.frame.size.height)];
//    [_collectionViewObj setFrame:self.bounds];
}


@end
