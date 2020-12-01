//
//  LoaderView.h
//  Woo_v2
//
//  Created by Umesh Mishra on 13/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoaderView : UIView{
    IBOutlet UIActivityIndicatorView *activityIndicatorObj;
    IBOutlet UILabel *messagLabel;
    __weak IBOutlet UIView *centerView;
}

-(void)setTextOnLabelWithGrayColor:(NSString *)grayText andWithHighlightedText:(NSString *)highlightedText;

@end
