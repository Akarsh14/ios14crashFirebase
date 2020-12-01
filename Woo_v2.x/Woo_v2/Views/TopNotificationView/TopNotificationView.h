//
//  TopNotificationView.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 27/07/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopNotificationView : UIWindow{
    
    __weak IBOutlet UIImageView *userImageView;
    __weak IBOutlet UILabel *notificationText;
    
    NSString *matchedID;

}

-(void)presentMatchNotificationWithText:(NSString *)textToDisplay andImageURL:(NSURL *)imageURL forMatchID:(NSString *)matchID;

- (IBAction)removeNotification:(id)sender;
- (IBAction)pushToChat:(id)sender;

@end
