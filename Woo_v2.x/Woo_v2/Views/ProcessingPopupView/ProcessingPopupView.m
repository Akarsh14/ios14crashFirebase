//
//  ProcessingPopupView.m
//  Woo_v2
//
//  Created by Akhil Singh on 1/20/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "ProcessingPopupView.h"

@interface ProcessingPopupView ()
{
    __weak IBOutlet UIView *blackView;
    __weak IBOutlet UIView *paymentProcessingView;
    __weak IBOutlet UIView *paymentIndicatorContainerView;
    __weak IBOutlet UILabel *processingPaymentLabel;
}

@end

@implementation ProcessingPopupView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
    // Drawing code
}
*/

- (void)addProcessingIndicatorView
{
    /*
    TJSpinner *circularSpinner = [[TJSpinner alloc] initWithSpinnerType:kTJSpinnerTypeActivityIndicator];
    [circularSpinner setColor:[UIColor blackColor]];
    [circularSpinner setInnerRadius:15];
    [circularSpinner setOuterRadius:35];
    [circularSpinner setStrokeWidth:6];
    [circularSpinner setNumberOfStrokes:8];
    [circularSpinner setPatternLineCap:kCGLineCapRound];
    [circularSpinner setPatternStyle:TJActivityIndicatorPatternStyleSolid];
    [circularSpinner startAnimating];
    circularSpinner.hidesWhenStopped = NO;
//    circularSpinner.radius = 10;
//    circularSpinner.pathColor = [UIColor whiteColor];
//    circularSpinner.fillColor = [UIColor redColor];
//    circularSpinner.thickness = 7;
    [circularSpinner setBounds:CGRectMake(0,0 , [circularSpinner frame].size.width, [circularSpinner frame].size.height)];
    [circularSpinner setCenter:CGPointMake(17,17)];
    [paymentIndicatorContainerView addSubview:circularSpinner];
     */
}

- (void)setTextForPaymentProcessingLabel:(NSString *)processingtext
{
    [processingPaymentLabel setText:processingtext];
    [self addProcessingIndicatorView];
}

@end
