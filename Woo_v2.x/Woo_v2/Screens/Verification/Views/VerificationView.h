//
//  VerificationView.h
//  Woo
//
//  Created by Umesh Mishra on 20/02/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LDProgressView.h"

@interface VerificationView : UIView{
    LDProgressView *progressViewObj1;
    
    
    ////////////////New verification outlets
    __weak IBOutlet UIView *secondPhaseView;
    __weak IBOutlet UIView *thirdPhaseView;
    __weak IBOutlet UIView *whiteBandView;
    
    __weak IBOutlet UILabel *verificatinHeaderLabel;
    __weak IBOutlet UIImageView *verificationHeaderImage;
    
}
//Verfication ProgressView
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *headingLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameAppreciationLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topHeightContraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *errorMsgTopLayoutContraint;

-(void)initialiseViewAccordingScreenHeight;
-(void)setProgressValue:(float)progress;
-(void)setImage:(UIImage *)imageObj;
-(void)setHeading:(NSString *)headingText andMessage:(NSString *)messageText;
-(void)hideProgressView;
-(void)hideAppreciationLabel;

//Error Progress View

@property (weak, nonatomic) IBOutlet UIView * errorContainerView;
@property (weak, nonatomic) IBOutlet UIImageView * errorImageView;
@property (weak, nonatomic) IBOutlet UILabel *errorHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstErrorMessageLabel;
//@property (weak, nonatomic) IBOutlet UILabel *secondErrorMessageLabel;

-(void)setErrorHeading:(NSString *)errorHeadingText withFirstMessage:(NSString *)firstMessageString andSecondMessageText:(NSString *)secondMessageString;
-(void)setErrorImage:(UIImage *)errorImage;





-(void)createViewAccordingToNavBarWithNavBarStatus:(BOOL )isNavBarVisible;

-(void)setViewForProgressStateVal:(int)progressState;
-(void)showErrorScreenForErrorVal:(int)errorVal withHeaderText:(NSString *)fakeHeaderText andFakeReasonText:(NSString *)fakeReasonText;
@end
