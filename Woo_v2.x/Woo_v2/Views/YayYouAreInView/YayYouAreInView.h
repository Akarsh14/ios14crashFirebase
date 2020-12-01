//
//  YayYouAreInView.h
//  Woo_v2
//
//  Created by Umesh Mishra on 08/09/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

//typedef void (^APICompletionBlock)(BOOL success, id response, NSError *error,int statusCode, kindOfRequest requestType);

typedef void (^ViewDismissedBlock)(BOOL isviewDismissed);

#import <UIKit/UIKit.h>

@interface YayYouAreInView : UIView{
    __weak IBOutlet UILabel *headerLbl;
    __weak IBOutlet UILabel *messageLbl;
    __weak IBOutlet UIActivityIndicatorView *loaderObj;
    __weak IBOutlet UIImageView *userPhoto;
    __weak IBOutlet UIImageView *userPhotoForVariant1;
    __weak IBOutlet UIImageView *userPhotoForVariant2;
    __weak IBOutlet UIView *centerContainerViewObj;
    __weak IBOutlet UIView *userInfoViewOvj;
    
    //Containts outlets
    __weak IBOutlet NSLayoutConstraint *companyNameHeightOutlet;
    __weak IBOutlet NSLayoutConstraint *instituteNameHegihtOultet;
    __weak IBOutlet NSLayoutConstraint *educationInfoHeightOutlet;
    __weak IBOutlet NSLayoutConstraint *educationTopValueOutlet;
//    __weak IBOutlet NSLayoutConstraint *containerViewRatioOutlet;
    
    __weak IBOutlet UIView *workInfoMissingViewObj;
    __weak IBOutlet UIView *educationInfoMissingObj;
    
    
    __weak IBOutlet UIView *educationInfoView;
    
    
    //Variant B view detials
    
    __weak IBOutlet UILabel *userNameLbl;
    __weak IBOutlet UILabel *maleFrndCountLbl;
    __weak IBOutlet UILabel *femaleFrndCountLbl;
    __weak IBOutlet UILabel *mutualFrndOnFbMsgLbl;
    __weak IBOutlet UIView *frndCounterViewObj;
    
    
    
    
    //Variant C view details
    __weak IBOutlet UILabel *userNameAgeLbl;
    __weak IBOutlet UILabel *userLocationLbl;
    __weak IBOutlet UILabel *imageCounterLbl;
    
    
    
    //variant c details
    __weak IBOutlet UIButton *workPlaceBtn;
    __weak IBOutlet UILabel *designationLbl;
    __weak IBOutlet UIButton *instituteNameBtn;
    __weak IBOutlet UILabel *degreLbl;
    __weak IBOutlet UILabel *likesLbl;
    
    __weak IBOutlet UILabel *lblLikesTitle;

    
    ViewDismissedBlock viewDismissBlock;
    
    
    __weak IBOutlet NSLayoutConstraint *distanceBetweenCardAndHeader;
    __weak IBOutlet NSLayoutConstraint *distanceBetweenCardAndGetStarted;
    __weak IBOutlet NSLayoutConstraint *heightOfGetStartedBtn_v2;
    
    __weak IBOutlet NSLayoutConstraint *distanceBetweenCardAndHeader_v3;
    __weak IBOutlet NSLayoutConstraint *distanceBetweenCardAndEditProfile_v3;
    __weak IBOutlet NSLayoutConstraint *distanceBetweenCardAndGetStarted_v3;
    __weak IBOutlet NSLayoutConstraint *heightOfGetStartedBtn_v3;
    __weak IBOutlet NSLayoutConstraint *heightOfEditProfileBtn_v3;
    
    
    __weak IBOutlet UIView *likesViewObj;
    
    
}

-(IBAction)editProfileButtonTapped:(id)sender;
-(IBAction)getStartedButtonTapped:(id)sender;
-(IBAction)infoButtonTapped:(id)sender;

@property(nonatomic, weak) id delegate;
@property(nonatomic, assign) SEL selectorForViewFading;
@property(nonatomic, assign) BOOL autoDismissView;

-(void)presentViewDuration:(float )animationDuration onView:(UIView *)presentingView;
-(void)presentViewDuration:(float )animationDuration onView:(UIView *)presentingView withDismissBlock:(ViewDismissedBlock)dismissBlock;

-(IBAction)syncWithLinkedInButtonTapped:(id)sender;

//Method to load nib according to the variant type. value of variant type can be 0, 1, 2
-(id)initWithFrame:(CGRect)frame andVariantType:(int)variantType;

@end
