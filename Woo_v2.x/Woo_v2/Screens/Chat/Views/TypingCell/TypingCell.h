//
//  TypingCell.h
//  Woo
//
//  Created by Umesh Mishra on 01/04/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TypingCell : UITableViewCell{
    IBOutlet UIImageView *typingImageView;
    IBOutlet UIView *containerView;
}

-(void)animateImage;
@end
