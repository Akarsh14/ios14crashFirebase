//
//  NotificationCell.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 11/07/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "NotificationCell.h"

@implementation NotificationCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setNotificationDataFromDictionary:(NSDictionary *)data{

    NSURL *imageCroppedUrl = [NSURL URLWithString:[data objectForKey:@"imageUrl"]];
    
    [notificationImageView sd_setImageWithURL:imageCroppedUrl placeholderImage:[UIImage imageNamed:@"imageHolder"]];
    [notificationText setText:[APP_Utilities validString:[data objectForKey:@"notificationText"]]];
    
    [notificationDate setText:[APP_Utilities returnDateStringOfTimestamp:[APP_Utilities returnDateFromTimeStamp:[[data  objectForKey:@"createdTime"] longLongValue]]]];
    
    if ([data objectForKey:@"read"] && [[data objectForKey:@"read"] boolValue] == FALSE) {
        [self.contentView setBackgroundColor:kLightestGreyColor];
    }else{
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
    }
}


@end
