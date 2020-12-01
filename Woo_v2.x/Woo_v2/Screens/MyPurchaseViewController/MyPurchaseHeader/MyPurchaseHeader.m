//
//  MyPurchaseHeader.m
//  Woo_v2
//
//  Created by Deepak Gupta on 7/12/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "MyPurchaseHeader.h"

@implementation MyPurchaseHeader

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


#pragma mark - Setting data on UI from NSArray
-(void)setDataOnMyPurchaseHeader : (NSArray *)arrData withButtonTappedCallBack:(ButtonTappedCallbackForMyPurchaseHeader)callBack{
    
    
    _buttonTappedCallback = callBack;
    arrDataValue = arrData;
    
    [collectionViewPurchaseHeader registerNib:[UINib nibWithNibName:@"MyPurchaseHeaderCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"MyPurchaseHeaderCollectionViewCell"];

    collectionViewPurchaseHeader.dataSource = self;
    collectionViewPurchaseHeader.delegate = self;
    [collectionViewPurchaseHeader reloadData];
}



#pragma mark - UICollectionView Delegate
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(2, 15, 0, 2);
}

//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
//{
//    return 15;
//}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [arrDataValue count];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    
    return 5.0;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"MyPurchaseHeaderCollectionViewCell";
    MyPurchaseHeaderCollectionViewCell *cell = (MyPurchaseHeaderCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [cell setDataOnCellForHeaderView:[arrDataValue objectAtIndex:indexPath.row] withButtonTappedCallBack:^(NSString *purchaseType, BOOL isExpired) {
        
        _buttonTappedCallback(purchaseType , isExpired);
        
    }];
    
    return cell;
}


@end
