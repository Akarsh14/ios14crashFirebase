//
//  MessageCustomActivity.m
//  Woo
//
//  Created by Vaibhav Gautam on 18/08/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "MessageCustomActivity.h"

@implementation MessageCustomActivity


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
    return [UIImage imageNamed:@"sms.png"];
    //    }
}

- (NSString *)activityTitle {
    return NSLocalizedStringFromTable(@"Message", NSStringFromClass([self class]), nil);
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
    NSLog(@"in prepare method");
}



- (void)performActivity
{
    [self activityDidFinish:YES];
    [self performSelector:@selector(postNotificationForMessage) withObject:nil afterDelay:0.5];
}

-(void)postNotificationForMessage{
    [APP_DELEGATE sendSwrveEventWithEvent:@"InviteFriends.Message" andScreen:@"InviteFriends"];
    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"SMS" forScreenName:@"Invite"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForSendMessage object:nil];
}

- (void)activityDidFinish:(BOOL)completed{
    
}


@end
