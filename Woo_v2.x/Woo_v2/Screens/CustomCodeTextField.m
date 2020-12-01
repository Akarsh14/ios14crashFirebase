//
//  CustomCodeTextField.m
//  Woo_v2
//
//  Created by Akhil Singh on 08/06/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

#import "CustomCodeTextField.h"

@implementation CustomCodeTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)deleteBackward {
    [super deleteBackward];
    
    if ([_myDelegate respondsToSelector:@selector(textFieldDidDelete)]){
        [_myDelegate textFieldDidDelete];
    }
}

@end
