//
//  WhatsappShareActivity.m
//  ARSpeechActivityDemo
//
//  Created by Vaibhav Gautam on 13/08/14.
//  Copyright (c) 2014 Alex Rupérez. All rights reserved.
//

#import "WhatsappShareActivity.h"

@implementation WhatsappShareActivity

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
        return [UIImage imageNamed:@"WhatsAppGrey.png"];
//    }
}

- (NSString *)activityTitle {
    return NSLocalizedStringFromTable(@"WhatsApp", NSStringFromClass([self class]), nil);
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
//    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Click_on_Invite_through_Whatsapp forScreenName:@"IF"];
}


- (void)performActivity
{
    
    [self activityDidFinish:YES];
    [self performSelector:@selector(sendWhatsappMessage) withObject:nil afterDelay:0.3];

}

-(void)sendWhatsappMessage{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForWhatsappSend object:nil];
    
    //Changed text from hard coded text to text provided by server.
    NSURL *whatsappURL = [NSURL URLWithString:[NSString stringWithFormat:@"whatsapp://send?text=%@",[APP_Utilities encodeFromPercentEscapeString:NSLocalizedString(@"Text for whatsapp", nil)]]];
    if ([AppLaunchModel sharedInstance].inviteOnlyEnabled) {
        whatsappURL = [NSURL URLWithString:[NSString stringWithFormat:@"whatsapp://send?text=%@",[APP_Utilities encodeFromPercentEscapeString:[AppLaunchModel sharedInstance].inviteShareUrl]]];
    }
    
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
        [APP_DELEGATE sendSwrveEventWithEvent:@"InviteFriends.Whatsapp" andScreen:@"InviteFriends"];
        [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"Whatsapp" forScreenName:@"Invite"];
        [[UIApplication sharedApplication] openURL: whatsappURL];
    }else{
        SHOW_TOAST_WITH_TEXT(@"WhatsApp not available");
    }
}

- (void)activityDidFinish:(BOOL)completed{
    
}


/**
 * Language detection taken from Eric Wolfe's contribution to Hark https://github.com/kgn/Hark
 */


@end
