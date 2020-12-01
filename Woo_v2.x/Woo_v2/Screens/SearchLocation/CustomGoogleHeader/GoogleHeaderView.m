//
//  GoogleHeaderView.m
//  Woo_v2
//
//  Created by Deepak Gupta on 2/26/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "GoogleHeaderView.h"

@implementation GoogleHeaderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(void)setMyCurrentLocationActionBlockForButton:(myCurrentLocationActionBlock)block{
    
    _block = block;
}

- (IBAction)myCurrentLocationClicked:(id)sender{
    
    _block();
}
@end
