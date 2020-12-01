//
//  PermissionScreenViewController.h
//  Woo_v2
//
//  Created by Deepak Gupta on 5/17/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "WooLoader.h"

@interface PermissionScreenViewController : BaseViewController<CLLocationManagerDelegate>{
    
    IBOutlet UIView         *viewLoaderBase;
    WooLoader                   *customLoader;

    NSArray                 *arrLocation;
    
    NSTimer     *myTimer;
    

}

@property (nonatomic , strong) NSString         *accessToken;
@property (nonatomic , strong) NSString         *userFBId;
@property( nonatomic, strong)CLLocationManager       *locationManager;
@end
