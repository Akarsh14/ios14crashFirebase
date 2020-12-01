//
//  StickerView.h
//  Woo
//
//  Created by Vaibhav Gautam on 07/05/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StickerView : UIView<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>{
    
//    __weak IBOutlet UICollectionView *collectionViewObj;
    
    NSMutableArray *stickerDataArray;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewObj;

@property(nonatomic, weak)id delegate;
@property(nonatomic, assign)SEL selectorForStickerTapped;
@property(nonatomic, assign)NSMutableArray *dataArray;
@end
