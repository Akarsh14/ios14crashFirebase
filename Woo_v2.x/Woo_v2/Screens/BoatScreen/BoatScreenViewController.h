//
//  BoatScreenViewController.h
//  Woo_v2
//
//  Created by Deepak Gupta on 5/19/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BoatScreenViewController : BaseViewController{
    
    IBOutlet  __weak  UIImageView   *imgView;
    IBOutlet  __weak  UILabel       *titleLabel;
    IBOutlet  __weak  UILabel       *body;
    IBOutlet  __weak  UILabel       *footer;
    IBOutlet  __weak  UIButton      *buttonBottom;
    
    IBOutlet  __weak  UILabel       *titleMiddleView;
    
    NSArray        *arrFbAlbum;
}

-(IBAction)startButtonClicked:(id)sender;

@end
