//
//  PermissionTableViewCell.h
//  Woo
//
//  Created by Umesh Mishra on 20/02/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PermissionTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

-(void)setMessageText:(NSMutableAttributedString *)text;
-(void)setHeightOfLabel:(float)height;

@end
