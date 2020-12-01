//
//  PushNoAnimationSegue.m
//  Woo_v2
//
//  Created by Deepak Gupta on 9/22/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "PushNoAnimationSegue.h"

@implementation PushNoAnimationSegue

- (void)perform {
    
    [self.sourceViewController.navigationController pushViewController:self.destinationViewController animated:YES];
}
@end
