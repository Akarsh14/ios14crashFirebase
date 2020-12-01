//
//  NotificationCell.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 11/07/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationCell : UITableViewCell{
    
    __weak IBOutlet UIImageView *notificationImageView;
    __weak IBOutlet UILabel *notificationText;
    __weak IBOutlet UILabel *notificationDate;
}

-(void)setNotificationDataFromDictionary:(NSDictionary *)data;

@end
