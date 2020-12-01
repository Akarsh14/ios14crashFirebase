//
//  MatchedThroughCell.m
//  Woo_v2
//
//  Created by Umesh Mishraji on 15/01/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "MatchedThroughCell.h"

@implementation MatchedThroughCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellTextAccrodingToMatchType:(NSString *)matchSource{
    if ([matchSource isEqualToString:kSourceBoost]) {
        matchThroughLb.text = NSLocalizedString(@"You matched through Boost", nil);
    }
    else if (([matchSource isEqualToString:kSourceCrush])){
        matchThroughLb.text = NSLocalizedString(@"You matched through Crush", nil);
    }
}

@end
