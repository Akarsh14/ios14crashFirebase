//
//  LoginLoadingViewController.h
//  Woo_v2
//
//  Created by Deepak Gupta on 6/14/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WooLoader.h"
@class LoginLoadingViewController;

@protocol LoginLoadingDelegate <NSObject>
- (void)gettingResponseFromLoginAPI : (BOOL)success withResponse:(id)response withStatusCode:(int) statusCode withAccessToken:(NSString *)accessToken withLoginLoadingReference:(LoginLoadingViewController *)loginLoading withUserChangedStatus:(BOOL)userChanged;
@end


@interface LoginLoadingViewController : UIViewController{
        
    __weak IBOutlet UIView      *viewLoader;
    
    WooLoader                   *customLoader;
    
    NSTimer                     *myTimer;
}

@property (nonatomic , strong)NSString      *fbId;
@property (nonatomic , strong)NSString      *accessToken;
@property (nonatomic , strong)NSDictionary      *TruecallerParameters;
@property (nonatomic , strong)NSString      *loginVia;
@property (nonatomic , strong)CLLocation    *location;
@property (nonatomic, assign) id<LoginLoadingDelegate> delegate;


@end
