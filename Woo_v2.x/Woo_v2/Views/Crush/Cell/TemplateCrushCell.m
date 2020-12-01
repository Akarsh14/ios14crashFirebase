//
//  TemplateCrushCell.m
//  Woo_v2
//
//  Created by Umesh Mishraji on 11/01/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "TemplateCrushCell.h"

@implementation TemplateCrushCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setTextOnCell:(NSString *)cellText setIfTheCellIsSelected:(BOOL)isCellSelected{
    NSString *cellTextWithinvertedComma = [NSString stringWithFormat:@"“%@”",cellText];
    templateCrushStr.text = cellTextWithinvertedComma;
//    NSLog(@"cell text :%@",cellText);
    if (isCellSelected) {
        self.backgroundColor = [UIColor colorWithRed:229.0f/255.0f green:221.0f/255.0f blue:249.0f/255.0f alpha:1];
        selectedCrushImageViewObj.alpha = 1;
    }
    else{
        self.backgroundColor = [UIColor whiteColor];
        selectedCrushImageViewObj.alpha = 0;
    }
}

-(void)isFirstCellOfTheTable:(BOOL)isFirstCell{
    upperSeperatedLine.hidden = TRUE;
//    isFirstCell?(upperSeperatedLine.hidden = FALSE):(upperSeperatedLine.hidden = TRUE);
}

@end
