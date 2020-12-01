//
//  TemplateCrushCell.h
//  Woo_v2
//
//  Created by Umesh Mishraji on 11/01/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TemplateCrushCell : UITableViewCell{
    
    __weak IBOutlet UILabel *templateCrushStr;
    __weak IBOutlet UIImageView *selectedCrushImageViewObj;
    __weak IBOutlet UILabel *upperSeperatedLine;
}

-(void)setTextOnCell:(NSString *)cellText setIfTheCellIsSelected:(BOOL)isCellSelected;

-(void)isFirstCellOfTheTable:(BOOL)isFirstCell;

@end
