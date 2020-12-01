//
//  ConnectingView.h
//  Woo_v2
//
//  Created by Umesh Mishraji on 14/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConnectingView : UIView
{
    IBOutlet UIActivityIndicatorView *activityIndicatorObj;
    IBOutlet UILabel *loadingTextLbl;
    IBOutlet NSLayoutConstraint *centerAlignContraint;
    IBOutlet UILabel *bottomLinesLbl;
}


-(void)changeLoadingTextView:(NSString *)newText;
-(void)animateActivityIndicatorView;
-(void)stopAndHideActivityIndicatorView;
-(void)setBackgroundColorOfView:(UIColor *)backgroundColor;
-(void)setLoadingTextColor:(UIColor *)textColor;
-(void)hideBottomLine;

@end
