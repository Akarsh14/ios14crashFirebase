//
//  RoundedImageCell.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 01/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoundedImageCell : UITableViewCell<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>{
    
    __weak IBOutlet UICollectionView *cellCollectionView;
    
    NSMutableArray *cellDataArray;
}

-(void)setDataOnCellWithImagesDictionary:(NSArray *)dataArray;
@end
