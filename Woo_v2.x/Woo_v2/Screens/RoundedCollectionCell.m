//
//  RoundedCollectionCell.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 02/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "RoundedCollectionCell.h"

@implementation RoundedCollectionCell


-(void)setDataOnCollectionCellFromDict:(MutualFriendModel *)data{
    [self.contentView layoutIfNeeded];
    [circularImage sd_setImageWithURL:[NSURL URLWithString:data.url] placeholderImage:[UIImage imageNamed:@"male_placeholder_bigger"]];
    
     [descriptionLabel setText:data.name];
}

@end
