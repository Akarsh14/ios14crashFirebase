//
//  PresentNoAnimationSegue.m
//  Woo_v2
//
//  Created by Deepak Gupta on 9/22/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "PresentNoAnimationSegue.h"

@implementation PresentNoAnimationSegue

- (void)perform {
    
    [self.sourceViewController.navigationController presentViewController:self.destinationViewController animated:NO completion:^{
        
    }];
}

@end
