//
//  ConfirmUserViewController.h
//  Woo_v2
//
//  Created by Deepak Gupta on 5/26/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WooLoader.h"

@interface ConfirmUserViewController : UIViewController<CLLocationManagerDelegate>{
    WooLoader  *customLoader;
    
    CLLocationManager       *locationManager;

}

@end
