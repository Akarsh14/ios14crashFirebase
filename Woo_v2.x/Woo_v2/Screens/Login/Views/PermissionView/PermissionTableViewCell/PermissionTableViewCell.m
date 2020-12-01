//
//  PermissionTableViewCell.m
//  Woo
//
//  Created by Umesh Mishra on 20/02/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "PermissionTableViewCell.h"

@implementation PermissionTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setMessageText:(NSMutableAttributedString *)text{
    _messageLabel.attributedText = text;
}
-(void)setHeightOfLabel:(float)height{
    
    CGRect labelFrame = _messageLabel.frame;
    labelFrame.size.height = height;
    _messageLabel.frame = labelFrame;
}

@end
