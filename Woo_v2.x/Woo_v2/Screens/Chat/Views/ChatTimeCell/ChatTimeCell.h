//
//  ChatTimeCell.h
//  Woo
//
//  Created by Umesh Mishra on 07/05/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatTimeCell : UITableViewCell{
    
}

@property(nonatomic, retain)IBOutlet UILabel *chatTimeLabelObj;

-(void)setChatTime:(NSString *)chatTime;

@end
