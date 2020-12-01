//
//  NotificationsViewController.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 29/05/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoNotificationView.h"


@interface NotificationsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>{
    
    NoNotificationView *noNotifObj;
    
    __weak IBOutlet UITableView *notificationTableView;
    
    NSMutableArray *notificationsDataArray;
}
- (IBAction)backButtonTapped:(id)sender;

@end
