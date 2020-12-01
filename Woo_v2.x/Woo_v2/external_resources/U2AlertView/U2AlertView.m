//
//  U2AlertView.m
//  U2AlertView
//
//  Created by Vaibhav Gautam on 25/02/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "U2AlertView.h"
#define kLeftButtonTag 99991
#define kRightButtonTag 99992
#define kBottomViewTag 99993

@interface U2AlertView ()
{
    NSDictionary *properties;
}

@end

@implementation U2AlertView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    topYPositionForView = 2.0;

    if (self) {
        // Initialization code
        NSArray *nibArray = [[NSBundle mainBundle]loadNibNamed:@"U2AlertView" owner:self options:nil];
        
        properties = nil;
        
        [self addSubview:[nibArray lastObject]];
        [self setFrame:[UIScreen mainScreen].bounds];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardAppearedOnTappingOnView) name:kNotifityU2AlertKeyBoardAppeared object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardDismissedOnTappingOnView) name:kNotifityU2AlertKeyBoardDismissed object:nil];
    }
    
    
    //    [self setBackgroundColor:[UIColor whiteColor]];
    return self;
}

-(void)keyBoardDismissedOnTappingOnView{
    [UIView animateWithDuration:0.3 animations:^{
        centreAlertView.center = self.center;
    } completion:^(BOOL finished) {
        nil;
    }];
    
}
-(void)keyBoardAppearedOnTappingOnView{
    int overLappingViewHeight = ((centreAlertView.frame.origin.y + centreAlertView.frame.size.height) - (APP_DELEGATE.window.frame.size.height - 216)) + 10;
    CGRect newFrame = centreAlertView.frame;
    newFrame.origin.y -= overLappingViewHeight;
    [UIView animateWithDuration:0.3 animations:^{
        centreAlertView.frame = newFrame;
    } completion:^(BOOL finished) {
        nil;
    }];
    
}


-(void)createBlurredBackground{
    return; // added return because blur was not working perfectly
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
        
        [self setAlpha:0.f];
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        blurEffectView.frame = self.bounds;
        [self addSubview:blurEffectView];
        [self bringSubviewToFront:centreAlertView];
    }
}
#pragma mark - U2AlertView creation methods -

-(void)alertWithHeaderText:(NSString *)headerText description:(NSString *)descriptionText leftButtonText:(NSString *)leftButtonText andRightButtonText:(NSString *)rightButtonText{
//    if (alertViewController) {
//        [alertViewController dismissViewControllerAnimated:alertViewController completion:nil];
//        alertViewController = nil;
//    }
//    alertViewController = [UIAlertController alertControllerWithTitle:headerText message:descriptionText preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *leftButtonAction = [UIAlertAction actionWithTitle:leftButtonText style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        if (_block) {
//            
//            // Passing 0 for first button
//            if (alertOptionalData)
//                _block(0 , alertOptionalData);
//            else
//                _block(0 , nil);
//            
//        }
//    }];
//    UIAlertAction *rightButtonAction = [UIAlertAction actionWithTitle:rightButtonText style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        if (_block) {
//            
//            // Passing 1 for second button
//            if (alertOptionalData)
//                _block(1 , alertOptionalData);
//            else
//                _block(1 , nil);
//            
//        }
//    }];
//    
//    [alertViewController addAction:leftButtonAction];
//    [alertViewController addAction:rightButtonAction];
    
    
    
    
    
    
    
    [self createBlurredBackground];
    if ([self isValidString:headerText]) {
        UILabel *header = [self setTextOnHeader:headerText];
        if (properties) {
            NSDictionary *headerDict = [properties objectForKey:@"header"];
            UIFont *headerFont = [headerDict objectForKey:@"font"];
            UIColor *headerTextColor = [headerDict objectForKey:@"color"];
            [header setFont:headerFont];
            [header setTextColor:headerTextColor];
        }
        [centreAlertView addSubview:header];
        topYPositionForView += header.frame.size.height;
        topYPositionForView += kCustomAlertSpacing;
        
        if ([descriptionText length]>0) {
            UIView *lineView = [self createHorizontalLine];
            [lineView setFrame:CGRectMake(lineView.frame.origin.x, topYPositionForView+1, lineView.frame.size.width, lineView.frame.size.height)];
            [centreAlertView addSubview:lineView];
            topYPositionForView = topYPositionForView + 2;
        }
    }
    
    if ([self isValidString:descriptionText]) {
        UILabel *descriptionArea = [self createDescriptionLabelForText:descriptionText];
        if (properties) {
            UIFont *descriptionFont = [[properties objectForKey:@"description"] objectForKey:@"font"];
            UIColor *descriptionTextColor = [[properties objectForKey:@"description"] objectForKey:@"color"];
            [descriptionArea setFont:descriptionFont];
            [descriptionArea setTextColor:descriptionTextColor];
        }
        
        topYPositionForView+=descriptionArea.frame.size.height;
        [centreAlertView addSubview:descriptionArea];
        topYPositionForView+= kCustomAlertSpacing+5;
        
    }
    
    if (([self isValidString:leftButtonText] && ![self isValidString:rightButtonText]) || (![self isValidString:leftButtonText] && [self isValidString:rightButtonText])) {
        
        NSString *str = ([self isValidString:leftButtonText]?leftButtonText:rightButtonText);
        UIView *bottomView = [self createSingleButtonViewForText:str];
        topYPositionForView+= bottomView.frame.size.height;
        [centreAlertView addSubview:bottomView];
        topYPositionForView+=kCustomAlertSpacing;
        
    }else if ([self isValidString:leftButtonText] && [self isValidString:rightButtonText]){
        
        UIView *bottomView = [self create2ButtonViewWithFirstButtonText:leftButtonText andSecondButtonText:rightButtonText];
        topYPositionForView+= bottomView.frame.size.height;
        [centreAlertView addSubview:bottomView];
        topYPositionForView+=kCustomAlertSpacing;
        
    }
    
    [centreAlertView setFrame:CGRectMake(centreAlertView.frame.origin.x, centreAlertView.frame.origin.y, centreAlertView.frame.size.width, topYPositionForView)];
    
    [self roundCornersOfView:centreAlertView];
}

-(void)alertWithHeaderText:(NSString *)headerText descriptionView:(UIView *)centreView withLeftButtonText:(NSString *)leftButtonText andRightButtonText:(NSString *)rightButtonText{
    
    [self createBlurredBackground];
    
    if ([self isValidString:headerText]) {
        UILabel *header = [self setTextOnHeader:headerText];
        [centreAlertView addSubview:header];
        topYPositionForView += header.frame.size.height;
        topYPositionForView += kCustomAlertSpacing;
        if (centreView) {
            UIView *lineView = [self createHorizontalLine];
            [lineView setFrame:CGRectMake(lineView.frame.origin.x, topYPositionForView+1, lineView.frame.size.width, lineView.frame.size.height)];
            [centreAlertView addSubview:lineView];
            topYPositionForView = topYPositionForView + 2;
        }
    }
    
    if (centreView) {
        
        _descriptionView = centreView;
        
        if ((kWidthOfAlertView/2)-(centreView.frame.size.width/2) < 0) {
            [centreView setFrame:CGRectMake(kCustomLeftRightSpacing, topYPositionForView, centreView.frame.size.width, centreView.frame.size.height)];
        }else{
            [centreView setFrame:CGRectMake((kWidthOfAlertView/2)-(centreView.frame.size.width/2), topYPositionForView, centreView.frame.size.width, centreView.frame.size.height)];
        }
        
        UIView *descriptionArea = centreView;
        topYPositionForView+=descriptionArea.frame.size.height;
        [centreAlertView addSubview:descriptionArea];
        topYPositionForView+= kCustomAlertSpacing;
        
    }
    
    if (([self isValidString:leftButtonText] && ![self isValidString:rightButtonText]) || (![self isValidString:leftButtonText] && [self isValidString:rightButtonText])) {
        
        NSString *str = ([self isValidString:leftButtonText]?leftButtonText:rightButtonText);
        UIView *bottomView = [self createSingleButtonViewForText:str];
        topYPositionForView+= bottomView.frame.size.height;
        [centreAlertView addSubview:bottomView];
        topYPositionForView+=kCustomAlertSpacing;
        
    }else if ([self isValidString:leftButtonText] && [self isValidString:rightButtonText]){
        
        UIView *bottomView = [self create2ButtonViewWithFirstButtonText:leftButtonText andSecondButtonText:rightButtonText];
        topYPositionForView+= bottomView.frame.size.height;
        [centreAlertView addSubview:bottomView];
        topYPositionForView+=kCustomAlertSpacing;
        
    }
    
    [centreAlertView setFrame:CGRectMake(centreAlertView.frame.origin.x, centreAlertView.frame.origin.y, centreAlertView.frame.size.width, topYPositionForView)];
    [self roundCornersOfView:centreAlertView];
    
}


-(void)alertWithHeaderText:(NSString *)headerText description:(NSString *)descriptionText leftButton:(UIImage *)leftButton andRightButton:(UIImage *)rightButton{
    
    [self createBlurredBackground];
    
    if ([self isValidString:headerText]) {
        UILabel *header = [self setTextOnHeader:headerText];
        [centreAlertView addSubview:header];
        topYPositionForView += header.frame.size.height;
        topYPositionForView += kCustomAlertSpacing;
        if ([descriptionText length]>0) {
            UIView *lineView = [self createHorizontalLine];
            [lineView setFrame:CGRectMake(lineView.frame.origin.x, topYPositionForView+1, lineView.frame.size.width, lineView.frame.size.height)];
            [centreAlertView addSubview:lineView];
            topYPositionForView = topYPositionForView + 2;
        }
    }
    
    if ([self isValidString:descriptionText]) {
        UILabel *descriptionArea = [self createDescriptionLabelForText:descriptionText];
        topYPositionForView+=descriptionArea.frame.size.height;
        [centreAlertView addSubview:descriptionArea];
        topYPositionForView+= kCustomAlertSpacing;
        
    }
    
    if ((leftButton && !rightButton) || (!leftButton && rightButton)) {
        
        UIImage *image = (leftButton?leftButton:rightButton);
        UIView *bottomView = [self createSingleButtonViewWithImageButtonFromImage:image];
        topYPositionForView+= bottomView.frame.size.height;
        [centreAlertView addSubview:bottomView];
        topYPositionForView+=kCustomAlertSpacing;
        
    }else if (leftButton && rightButton){
        
        UIView *bottomView = [self create2ButtonViewWithFirstButtonImage:leftButton andSecondButtonImage:rightButton];
        topYPositionForView+= bottomView.frame.size.height;
        [centreAlertView addSubview:bottomView];
        topYPositionForView+=kCustomAlertSpacing;
    }
    
    [centreAlertView setFrame:CGRectMake(centreAlertView.frame.origin.x, centreAlertView.frame.origin.y, centreAlertView.frame.size.width, topYPositionForView)];
    [self roundCornersOfView:centreAlertView];
    
    
    
}

-(void)alertWithHeaderText:(NSString *)headerText descriptionView:(UIView *)centreView leftButton:(UIImage *)leftButton andRightButton:(UIImage *)rightButton{
    
    [self createBlurredBackground];
    
    if ([self isValidString:headerText]) {
        UILabel *header = [self setTextOnHeader:[NSString stringWithFormat:@"Introducing %@",headerText]];
        [centreAlertView addSubview:header];
        topYPositionForView += header.frame.size.height;
        topYPositionForView += kCustomAlertSpacing;
        if (centreView) {
            UIView *lineView = [self createHorizontalLine];
            [lineView setFrame:CGRectMake(lineView.frame.origin.x, topYPositionForView+1, lineView.frame.size.width, lineView.frame.size.height)];
            [centreAlertView addSubview:lineView];
            topYPositionForView = topYPositionForView + 2;
        }
    }
    
    if (centreView) {
        
        _descriptionView = centreView;
        
        if ((kWidthOfAlertView/2)-(centreView.frame.size.width/2) < 0) {
            [centreView setFrame:CGRectMake(kCustomLeftRightSpacing, topYPositionForView, centreView.frame.size.width, centreView.frame.size.height)];
        }else{
            [centreView setFrame:CGRectMake((kWidthOfAlertView/2)-(centreView.frame.size.width/2), topYPositionForView, centreView.frame.size.width, centreView.frame.size.height)];
        }
        
        UIView *descriptionArea = centreView;
        topYPositionForView+=descriptionArea.frame.size.height;
        [centreAlertView addSubview:descriptionArea];
        topYPositionForView+= kCustomAlertSpacing;
        
    }
    
    if ((leftButton && !rightButton) || (!leftButton && rightButton)) {
        
        
        UIImage *image = (leftButton?leftButton:rightButton);
        UIView *bottomView = [self createSingleButtonViewWithImageButtonFromImage:image];
        topYPositionForView+= bottomView.frame.size.height;
        [centreAlertView addSubview:bottomView];
        topYPositionForView+=kCustomAlertSpacing;
        
    }else if (leftButton && rightButton){
        
        UIView *bottomView = [self create2ButtonViewWithFirstButtonImage:leftButton andSecondButtonImage:rightButton];
        topYPositionForView+= bottomView.frame.size.height;
        [centreAlertView addSubview:bottomView];
        topYPositionForView+=kCustomAlertSpacing;
    }
    
    [centreAlertView setFrame:CGRectMake(centreAlertView.frame.origin.x, centreAlertView.frame.origin.y, centreAlertView.frame.size.width, topYPositionForView)];
    [self roundCornersOfView:centreAlertView];
    
}

-(void)show{
    [self alignViewInCentre];
    
    
    [[[[UIApplication sharedApplication] windows] objectAtIndex:0] addSubview:self];
    
    centreAlertView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    
    [self setAlpha:0.0f];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        
        [UIView animateWithDuration:kAlertAnimationTime delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:2 options:0 animations:^{
            centreAlertView.transform = CGAffineTransformIdentity;
            [self setAlpha:1.0f];
        } completion:^(BOOL finished) {
            // do something once the animation finishes, put it here
        }];
    }else{
        [UIView animateWithDuration:kAlertAnimationTime delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            centreAlertView.transform = CGAffineTransformIdentity;
            [self setAlpha:1.0f];
        } completion:^(BOOL finished){
            // do something once the animation finishes, put it here
        }];
    }
    
}

#pragma mark - Methods for creating small custom views -

-(UILabel *)setTextOnHeader:(NSString *)headerText{
    UILabel *headerTextLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, kCustomAlertSpacing, kWidthOfAlertView, kHeightOfHeaderBackground)];
    [headerTextLabel setText:headerText];
    [headerTextLabel setBackgroundColor:kAlertHeaderBackgroundColor];
    [headerTextLabel setTextColor:kHeaderTextColor];
    
    [headerTextLabel setFont:kAlertHeaderFont];
    [headerTextLabel setTextAlignment:NSTextAlignmentCenter];
    [self makeTopCornersOfViewRounded:headerTextLabel];
    return headerTextLabel;
}

-(UIView *)createSingleButtonViewWithImageButtonFromImage:(UIImage *)imageObj{
    
    UIView *bottomButtonView = [[UIView alloc]init];
    [bottomButtonView setFrame:CGRectMake(kCustomLeftRightSpacing, topYPositionForView, kWidthOfAlertView-(kCustomLeftRightSpacing*2), 44)];
    [bottomButtonView setBackgroundColor:[UIColor clearColor]];
    
    [bottomButtonView addSubview:[self createHorizontalLine]];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setFrame:CGRectMake(0, 1, kWidthOfAlertView-(kCustomLeftRightSpacing*2), 44)];
    [button setImage:imageObj forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(firstButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [button setUserInteractionEnabled:YES];
    
    [bottomButtonView addSubview:button];
    return bottomButtonView;
    
}


-(UIView *)create2ButtonViewWithFirstButtonImage:(UIImage *)firstButtonImage andSecondButtonImage:(UIImage *)secondButtonImage{
    
    UIView *bottomButtonView = [[UIView alloc]init];
    [bottomButtonView setFrame:CGRectMake(kCustomLeftRightSpacing, topYPositionForView, kWidthOfAlertView-(kCustomLeftRightSpacing*2), 44)];
    [bottomButtonView setBackgroundColor:[UIColor clearColor]];
    
    [bottomButtonView addSubview:[self createHorizontalLine]];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setBackgroundColor:[UIColor clearColor]];
    [leftButton setFrame:CGRectMake(kCustomLeftRightSpacing, 1, (kWidthOfAlertView/2)-kCustomLeftRightSpacing, 44)];
    [leftButton setImage:firstButtonImage forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(firstButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setUserInteractionEnabled:YES];
    
    [bottomButtonView addSubview:leftButton];
    
    [bottomButtonView addSubview:[self createVerticalLine]];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setBackgroundColor:[UIColor clearColor]];
    [rightButton setFrame:CGRectMake((kWidthOfAlertView/2)+2, 1, (kWidthOfAlertView/2)-kCustomLeftRightSpacing, 44)];
    [rightButton setImage:secondButtonImage forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(secondButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setUserInteractionEnabled:YES];
    
    [bottomButtonView addSubview:rightButton];
    return bottomButtonView;
    
}

-(UIView *)createHorizontalLine{
    UIView *hLine = [[UIView alloc]init];
    [hLine setFrame:CGRectMake(0, 0, kWidthOfAlertView, 1)];
    [hLine setBackgroundColor:kSeparatorLinesColor];
    return hLine;
}

-(UIView *)createVerticalLine{
    UIView *vLine = [[UIView alloc]init];
    [vLine setFrame:CGRectMake((kWidthOfAlertView/2)-kCustomLeftRightSpacing, 1, 1, 43)];
    [vLine setBackgroundColor:kSeparatorLinesColor];
    return vLine;
}

-(UIView *)createSingleButtonViewForText:(NSString *)buttonText{
    
    UIView *bottomButtonView = [[UIView alloc]init];
    [bottomButtonView setFrame:CGRectMake(0, topYPositionForView, kWidthOfAlertView-(kCustomLeftRightSpacing*2), 44)];
    [bottomButtonView setBackgroundColor:[UIColor clearColor]];
    [bottomButtonView addSubview:[self createHorizontalLine]];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setFrame:CGRectMake(0, 1, kWidthOfAlertView-(kCustomLeftRightSpacing*2), 44)];
    [button setTitle:buttonText forState:UIControlStateNormal];
    [button setTitleColor:kButtonTextRedColor forState:UIControlStateNormal];
    button.titleLabel.font = kRightButtonFont;
    [button addTarget:self action:@selector(firstButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [button setUserInteractionEnabled:YES];
    
    [bottomButtonView addSubview:button];
    return bottomButtonView;
}

-(UIView *)create2ButtonViewWithFirstButtonText:(NSString *)firstButtonText andSecondButtonText:(NSString *)secondButtonText{
    
    UIView *bottomButtonView = [[UIView alloc]init];
    [bottomButtonView setFrame:CGRectMake(0, topYPositionForView, kWidthOfAlertView-(kCustomLeftRightSpacing*2), 44)];
    [bottomButtonView setBackgroundColor:[UIColor clearColor]];
    bottomButtonView.tag = kBottomViewTag;
    
    [bottomButtonView addSubview:[self createHorizontalLine]];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [leftButton setBackgroundColor:[UIColor clearColor]];
    [leftButton setFrame:CGRectMake(0, 1, (kWidthOfAlertView/2)-kCustomLeftRightSpacing, 44)];
    [leftButton setTitle:firstButtonText forState:UIControlStateNormal];
    [leftButton setTitleColor:kButtonTextRedColor forState:UIControlStateNormal];
    leftButton.titleLabel.font = kLeftButtonFont;
    [leftButton addTarget:self action:@selector(firstButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setUserInteractionEnabled:YES];
    leftButton.tag = kLeftButtonTag;
    
    [bottomButtonView addSubview:leftButton];
    
    [bottomButtonView addSubview:[self createVerticalLine]];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [rightButton setBackgroundColor:[UIColor clearColor]];
    [rightButton setFrame:CGRectMake((kWidthOfAlertView/2)-(kCustomLeftRightSpacing+2), 1, (kWidthOfAlertView/2)-kCustomLeftRightSpacing, 44)];
    [rightButton setTitle:secondButtonText forState:UIControlStateNormal];
    [rightButton setTitleColor:kButtonTextRedColor forState:UIControlStateNormal];
    rightButton.titleLabel.font = kRightButtonFont;
    [rightButton addTarget:self action:@selector(secondButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setUserInteractionEnabled:YES];
    rightButton.tag = kRightButtonTag;
    
    [bottomButtonView addSubview:rightButton];
    
    if (properties) {
        UIFont *buttonFont = [[properties objectForKey:@"button"] objectForKey:@"font"];
        [leftButton.titleLabel setFont:buttonFont];
        [rightButton.titleLabel setFont:buttonFont];
    }
    
    return bottomButtonView;
    
}

-(UILabel *)createDescriptionLabelForText:(NSString *)text{
    UILabel *descriptionLabel = [[UILabel alloc]init];
    
    float heightOfFrame = ceilf([self getHeightForText:text forFont:kAlertViewDescriptionTextFont]+40);
    [descriptionLabel setText:text];
    [descriptionLabel setBackgroundColor:kAlertBackgroundColor];
    [descriptionLabel setFont:kAlertViewDescriptionTextFont];
    [descriptionLabel setTextAlignment:NSTextAlignmentCenter];
    [descriptionLabel setTextColor:kAlertViewDescriptionTextColor];
    [descriptionLabel setFrame:CGRectMake(kCustomLeftRightSpacing, topYPositionForView, kWidthOfAlertView-(kCustomLeftRightSpacing*2), heightOfFrame)];
    [descriptionLabel setNumberOfLines:0];
    //    descriptionLabel.layer.borderColor = [[UIColor whiteColor]CGColor];
    //    descriptionLabel.layer.borderWidth = 2.0f;
    //    [descriptionLabel sizeToFit];
    return descriptionLabel;
}


#pragma mark - Set Button Block
-(void)setU2AlertActionBlockForButton:(U2AlertActionBlock)block{
    _block = block;
}


#pragma mark - Helper methods -

-(void)firstButtonTapped{
    
    
    if (_block) {
    
    // Passing 0 for first button
    if (alertOptionalData)
        _block(0 , alertOptionalData);
    else
        _block(0 , nil);
    
    }
    
    [self removeCenterViewWithAnimation];

    
  /*
    if (alertOptionalData) {
        if ([_delegate respondsToSelector:_selectorOnAlertButtonTapped]) {
            [_delegate performSelector:_selectorOnAlertButtonTapped withObject:@"0" withObject:alertOptionalData];
        }
    }else{
        if ([_delegate respondsToSelector:_selectorOnAlertButtonTapped]) {
            [_delegate performSelector:_selectorOnAlertButtonTapped withObject:@"0"];
        }
    }
    
    if (!_keepViewOnButtonTap) {
        
        centreAlertView.transform = CGAffineTransformIdentity;
        
        [UIView animateWithDuration:kAlertAnimationTime delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            centreAlertView.transform = CGAffineTransformMakeScale(0.01, 0.01);
            [self setAlpha:0.0f];
        } completion:^(BOOL finished){
            [self removeFromSuperview];
        }];
        
    }
    */
    
}

#pragma mark Remove Center View with Animation
- (void)removeCenterViewWithAnimation{
    
    if (!_keepViewOnButtonTap) {

    centreAlertView.transform = CGAffineTransformIdentity;
    
    [UIView animateWithDuration:kAlertAnimationTime delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        centreAlertView.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [self setAlpha:0.0f];
    } completion:^(BOOL finished){
        [self removeFromSuperview];
        
    }];
    
    }
}


-(void)secondButtonTapped{
    
    
    
    if (_block) {

    // Passing 1 for second button
    if (alertOptionalData)
        _block(1 , alertOptionalData);
    else
        _block(1 , nil);
    
    }
    
    [self removeCenterViewWithAnimation];
    
  /*
    if (alertOptionalData) {
        if ([_delegate respondsToSelector:_selectorOnAlertButtonTapped]) {
            [_delegate performSelector:_selectorOnAlertButtonTapped withObject:@"1" withObject:alertOptionalData];
        }
    }else{
        if ([_delegate respondsToSelector:_selectorOnAlertButtonTapped]) {
            [_delegate performSelector:_selectorOnAlertButtonTapped withObject:@"1"];
        }
    }
    
    if (!_keepViewOnButtonTap) {
        //        [self removeFromSuperview];
        centreAlertView.transform = CGAffineTransformIdentity;
        
        [UIView animateWithDuration:kAlertAnimationTime delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            centreAlertView.transform = CGAffineTransformMakeScale(0.01, 0.01);
            [self setAlpha:0.0f];
        } completion:^(BOOL finished){
            [self removeFromSuperview];
        }];
    }
   
   */
    
}


-(void)alignViewInCentre{
    
    [centreAlertView setFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width/2-(kWidthOfAlertView/2), [[UIScreen mainScreen] bounds].size.height/2-(centreAlertView.frame.size.height/2), kWidthOfAlertView, centreAlertView.frame.size.height)];
    
}

-(void)makeTopCornersOfViewRounded:(UIView *)viewObj{
    
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:viewObj.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake((SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")?kCornerRadiusForRoundedViewsIniOS9:kCornerRadiusForRoundedViews), (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")?kCornerRadiusForRoundedViewsIniOS9:kCornerRadiusForRoundedViews))];
    
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    
    viewObj.layer.mask = shape;
    
}

-(void)roundCornersOfView:(UIView *)viewObj{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        viewObj.layer.cornerRadius = kCornerRadiusForRoundedViewsIniOS9;
    }else{
        viewObj.layer.cornerRadius = kCornerRadiusForRoundedViews;
    }
    
}

-(float)getHeightForText:(NSString *)text forFont:(UIFont *)font{
    CGSize constraint = CGSizeMake(kWidthOfAlertView-((kCustomLeftRightSpacing*2)+10), MAXFLOAT);
    CGRect textRect = [text boundingRectWithSize:constraint
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:font}
                                         context:nil];
    return textRect.size.height;
}


-(BOOL)isValidString:(NSString *)string{
    if ([string length] == 0 || string == nil) {
        return NO;
    }
    return YES;
}

-(void)setContainerData:(id)dataDict{
    
    alertOptionalData = dataDict;
}

-(void)enableRightButton{
    UIView *bottomViewObj = [centreAlertView viewWithTag:kBottomViewTag];
    UIButton *butObj = (UIButton *)[bottomViewObj viewWithTag:kRightButtonTag];
    butObj.alpha = 1.0;
    [butObj setEnabled:TRUE];
}
-(void)DisableRightButton{
    UIView *bottomViewObj = [centreAlertView viewWithTag:kBottomViewTag];
    UIButton *butObj = (UIButton *)[bottomViewObj viewWithTag:kRightButtonTag];
    butObj.alpha = 0.5;
    [butObj setEnabled:FALSE];
}

-(void)setPropertiesForElementsOfAlertView:(NSDictionary *)elementProperties
{
    properties = elementProperties;
    
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotifityU2AlertKeyBoardAppeared object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotifityU2AlertKeyBoardDismissed object:nil];
}
@end
