//
//  MessageConversationView.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 13/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "MessageConversationView.h"

@implementation MessageConversationView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    //check if memory is allocated to self
    if (self) {
        NSArray *viewArrayFromXib = [[NSBundle mainBundle] loadNibNamed:@"MessageConversationView" owner:self options:nil];
        UIView *viewObj = [viewArrayFromXib objectAtIndex:0];
        viewObj.frame = self.bounds;
        [self addSubview:viewObj];
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)cancelButtonTapped:(id)sender {

    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"TapCross" forScreenName:@"IntroReply"];
    if (_isOpenedFromDiscover) {
        [APP_DELEGATE sendSwrveEventWithEvent:@"IntroOverlay.Cross" andScreen:@"IntroOverlay"];
    }else{
        [APP_DELEGATE sendSwrveEventWithEvent:@"DirectMsgReplyDetailedPV.TapCross" andScreen:@"IntroOverlay"];
//        [[Swrve sharedInstance] event:@"DirectMsgReplyDetailedPV.TapCross"];
    }
    
    [self removeFromSuperview];
}

- (IBAction)likeButtonTapped:(id)sender {
    
    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"TapHeart" forScreenName:@"IntroReply"];
    if (_isOpenedFromDiscover) {
        [APP_DELEGATE sendSwrveEventWithEvent:@"IntroOverlay.Heart" andScreen:@"IntroOverlay"];
    }else{
//        [[Swrve sharedInstance] event:@"DirectMsgReplyDetailedPV.TapHeart"];
        [APP_DELEGATE sendSwrveEventWithEvent:@"DirectMsgReplyDetailedPV.TapHeart" andScreen:@"IntroOverlay"];
    }
    
    if ([_delegate respondsToSelector:_selectorForCreateMAtchTapped]) {
        [_delegate performSelector:_selectorForCreateMAtchTapped withObject:nil];
    }
    [self removeFromSuperview];
}
@end
