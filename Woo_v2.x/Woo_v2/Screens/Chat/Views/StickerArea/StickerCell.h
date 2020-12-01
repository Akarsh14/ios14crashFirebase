//
//  StickerCell.h
//  Woo
//
//  Created by Vaibhav Gautam on 08/05/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StickerCell : UICollectionViewCell{
    
    __weak IBOutlet UIImageView *stickerThumbnail;
    
    UIActivityIndicatorView *activityView;
    
    NSMutableDictionary *cellData;
}

@property(nonatomic, weak)id delegate;
@property(nonatomic, assign)SEL selectorForStickerTapped;

-(void)setDataOnCellFromDictionary:(NSMutableDictionary *)dataDictionary;

- (IBAction)stickerTapped:(id)sender;

@end