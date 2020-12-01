//
//  ShowMoreCell.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 07/07/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "ShowMoreCell.h"

@implementation ShowMoreCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setDataOnShowMoreCellWithPendingReplies:(int )repliesRemaining{
    
    if (repliesRemaining <= 1) {
        [showMoreLabel setText:[NSString stringWithFormat:@"%d %@",repliesRemaining, NSLocalizedString(@"more reply", nil)]];
    }else{
        [showMoreLabel setText:[NSString stringWithFormat:@"%d %@",repliesRemaining, NSLocalizedString(@"more replies", nil)]];
    }
    
    
}

@end
