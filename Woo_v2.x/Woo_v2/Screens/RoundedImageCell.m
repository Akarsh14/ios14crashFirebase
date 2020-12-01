//
//  RoundedImageCell.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 01/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "RoundedImageCell.h"
#import "RoundedCollectionCell.h"


@implementation RoundedImageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
//        [cellCollectionView setDelegate:self];
//        [cellCollectionView setDataSource:self];
//
//        [cellCollectionView registerClass:[self class] forCellWithReuseIdentifier:@"RoundedCollectionCell"];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [cellDataArray count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView
//                  layout:(UICollectionViewLayout*)collectionViewLayout
//  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    return CGSizeMake(40, 74);
//}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"RoundedCollectionCell";
    
    RoundedCollectionCell *cell = (RoundedCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];

    [cell setDataOnCollectionCellFromDict:[cellDataArray objectAtIndex:indexPath.row]];
    
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 14.0;
}


-(void)setDataOnCellWithImagesDictionary:(NSArray *)dataArray{
    if (!dataArray) {
        return;
    }
    cellDataArray = [dataArray mutableCopy];
    [cellCollectionView reloadData];
}
@end