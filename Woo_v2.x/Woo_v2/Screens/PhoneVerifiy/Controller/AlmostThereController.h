//
//  AlmostThereController.h
//  Woo
//
//  Created by Umesh Mishra on 29/10/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityIndicatorWithTextAndTimer.h"

@interface AlmostThereController : UIViewController{
    
    IBOutlet UILabel *headerTextLabelObj;
    IBOutlet UIButton *verifyNumberButtonObj;
    IBOutlet UIView *activityBackgroundView;
    ActivityIndicatorWithTextAndTimer *activityObj;
    BOOL amIVisibleToUser;
    AFNetworkReachabilityStatus internetStatus;
}

-(IBAction)callToVerifyNumberButtonTapped:(id)sender;

@property (nonatomic, retain)NSString *mobileNumber;
@property (nonatomic, retain)NSString *countryCode;
@property (nonatomic, retain)NSString *countryCodeString;

@property (nonatomic, retain)NSString *verificationID;
@property (nonatomic, retain)NSString *assignedDID;

@property (nonatomic, assign)BOOL isSmsVerficationAllowed;
@property (nonatomic, retain)NSNumber *timeOut;

-(void)initialiseView;
-(void)sendVerifiedMobileDetailsToServer:(NSString *)mobileNumber forWooID:(NSString *)wooId;


@end
