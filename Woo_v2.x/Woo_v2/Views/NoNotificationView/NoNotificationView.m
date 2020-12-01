//
//  NoNotificationView.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 24/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "NoNotificationView.h"

@implementation NoNotificationView


-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        //getting array of views from the xib
        NSArray *viewArrayFromXib = [[NSBundle mainBundle] loadNibNamed:@"NoNotificationView" owner:self options:nil];
        UIView *viewObj = [viewArrayFromXib firstObject];
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

@end
