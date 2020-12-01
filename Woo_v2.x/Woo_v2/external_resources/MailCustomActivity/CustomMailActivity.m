//
//  CustomMailActivity.m
//  Woo
//
//  Created by Vaibhav Gautam on 18/08/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "CustomMailActivity.h"

@implementation CustomMailActivity

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryAction;
}

- (NSString *)activityType
{
    return NSStringFromClass([self class]);
}

- (UIImage *)activityImage {
    
    //    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    //        return [UIImage imageNamed:[@"whatsApp" stringByAppendingString:@"-iPad"]];
    //    } else {
    return [UIImage imageNamed:@"mail.png"];
    //    }
}

- (NSString *)activityTitle {
    return NSLocalizedStringFromTable(@"Mail", NSStringFromClass([self class]), nil);
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    for (id activityItem in activityItems) {
        if ([activityItem isKindOfClass:[NSString class]]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
//    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Click_on_Invite_through_Email forScreenName:@"IF"];
}



- (void)performActivity
{
    [self activityDidFinish:YES];
    [self performSelector:@selector(postNotificationForMail) withObject:nil afterDelay:0.5];
}

-(void)postNotificationForMail{

    [APP_DELEGATE sendSwrveEventWithEvent:@"InviteFriends.Email" andScreen:@"InviteFriends"];
    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"Email" forScreenName:@"Invite"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForSendMail object:nil];
}

- (void)activityDidFinish:(BOOL)completed{
    
}


@end
