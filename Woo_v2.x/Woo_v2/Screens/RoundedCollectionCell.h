//
//  RoundedCollectionCell.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 02/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Woo_v2-Swift.h"

@interface RoundedCollectionCell : UICollectionViewCell{
    
    __weak IBOutlet UIImageView *circularImage;
    __weak IBOutlet UILabel *descriptionLabel;
    
    NSDictionary *collectionCellData;
}

-(void)setDataOnCollectionCellFromDict:(MutualFriendModel *)data;
@end
