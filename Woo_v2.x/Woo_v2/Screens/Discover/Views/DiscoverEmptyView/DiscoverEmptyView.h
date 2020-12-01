//
//  DiscoverEmptyView.h
//  Woo_v2
//
//  Created by Akhil Singh on 11/20/15.
//  Copyright © 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DiscoverEmptyView : UIView<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UILabel *meantimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *discoverEmptyImageView;
@property (weak, nonatomic) IBOutlet UILabel *body1Label;
@property (weak, nonatomic) IBOutlet UILabel *body2Label;
- (IBAction)CTAButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *ctaButton;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
- (IBAction)infoClicked:(id)sender;

- (IBAction)faqClicked:(id)sender;
- (IBAction)feedbackClicked:(id)sender;
- (IBAction)tipsClicked:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *meantimeHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bodyLabelHeightConstraint;
@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) SEL selectorForCTAButtonTapped;
@property (nonatomic, assign) SEL selectorForTipsButtonTapped;
@property (weak, nonatomic) IBOutlet UIButton *faqButton;
@property (weak, nonatomic) IBOutlet UIButton *talkToUsButton;
@property (weak, nonatomic) IBOutlet UIButton *tipsButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *body2LabelheightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ctaButtonHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *body2LabelVerticalSpacingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *body1LabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *discoverEmptyImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ctaButtonBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ctaButtonTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *ctaButtonIphone4;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ctaButtoniPhone4HeightConstraint;

-(void)setEmptyImage:(UIImage *)emptyImage setHeadingText:(NSString *)headingText setMeantimeText:(NSString *)meantimeText setBody1Text:(NSString *)body1Text setBody2Text:(NSString *)body2Text buttonText:(NSString *)buttonText faqButtonText:(NSString *)faqButtonText feedbackButtonText:(NSString *)feedbackButtonText andVisiblityButtonText:(NSString *)visibiltyText andType:(NSString *)type;
@end
