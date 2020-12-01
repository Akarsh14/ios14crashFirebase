//
//  GoogleHeaderView.h
//  Woo_v2
//
//  Created by Deepak Gupta on 2/26/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^myCurrentLocationActionBlock)();

@interface GoogleHeaderView : UIView{
    
    myCurrentLocationActionBlock _block;

}

- (IBAction)myCurrentLocationClicked:(id)sender;

-(void)setMyCurrentLocationActionBlockForButton:(myCurrentLocationActionBlock)block;

@end
