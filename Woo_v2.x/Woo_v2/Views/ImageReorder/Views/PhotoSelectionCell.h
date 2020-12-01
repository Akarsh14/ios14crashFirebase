//
//  PhotoSelectionCell.h
//  Woo
//
//  Created by Vaibhav Gautam on 14/02/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoSelectionCell : UICollectionViewCell{
    
    __weak IBOutlet UIImageView *cellImage;
    NSMutableDictionary *cellData;
}

@property(nonatomic)id delegate;
@property(nonatomic, assign)SEL selectorOnButtonTapped;

-(void)updateDataOnCellFromDictionay:(NSMutableDictionary *)dataDict;
- (IBAction)imageButtonTapped:(id)sender;

@end
