//
//  ReportUserCell.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 09/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "ReportUserCell.h"

@implementation ReportUserCell

- (void)awakeFromNib {
    // Initialization code

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:NO animated:animated];

    // Configure the view for the selected state
}


-(void)setTextOnCellWithText:(NSString *)textForCell setImageAsSelected:(BOOL )isSelected{
    if (isSelected) {
        [selectionImage setImage:[UIImage imageNamed:@"ic_radio_on"]];
    }else{
        [selectionImage setImage:[UIImage imageNamed:@"ic_radio_off"]];
    }
    
    [reportReasonText setText:textForCell];
}

@end
