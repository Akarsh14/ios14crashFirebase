//
//  FacebookAlbumCollectionViewCell.h
//  Woo_v2
//
//  Created by Deepak Gupta on 6/1/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FacebookAlbumCollectionViewCell : UICollectionViewCell{
    
    __weak IBOutlet UIImageView     *imgViewCover;
    __weak IBOutlet UILabel         *lblAlbumName;
    
    __weak IBOutlet UIView          *viewBottom;

    
}

-(void)updateDataOnCellFromDictionay:(NSDictionary *)dataDict withBottomViewVisible : (BOOL)isVisible withWidth:(int)width withHeight:(int)height;

@end
