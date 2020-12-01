//
//  AboutMeScreenViewController.h
//  Woo_v2
//
//  Created by Deepak Gupta on 5/17/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface AboutMeScreenViewController : BaseViewController{

   __weak   IBOutlet    UITextView      *textViewObj;
   __weak   IBOutlet    UILabel         *lblLimitCount;
   __weak   IBOutlet    UIButton        *btnBack;
    __weak   IBOutlet    UIButton        *btnNext;
    
    __weak   IBOutlet   UILabel          *lblPageNumber;
    
    __weak IBOutlet UILabel *placeholderLbl;
    
    IBOutlet NSLayoutConstraint *limitCountBottomConstraintObj;
    BOOL isOpenedFromWizard;

}

@property(assign, nonatomic)BOOL isOpenedFromWizard;

@property (assign) BOOL     isThisFirstScreenAfterRegistration;

-(IBAction)nextButtonClicked:(id)sender;

-(IBAction)backButtonClicked:(id)sender;


@end
