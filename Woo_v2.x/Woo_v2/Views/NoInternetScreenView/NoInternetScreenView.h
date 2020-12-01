//
//  NoInternetScreenView.h
//  Woo_v2
//
//  Created by Deepak Gupta on 6/15/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WooLoader.h"

@interface NoInternetScreenView : UIView{
    __weak IBOutlet UIView  *viewLoader;

}

- (void)addingWooLoader;

- (IBAction)refreshButtonClicked:(UIButton *)sender;

@property (assign)id delegate;
@property (assign)BOOL showLoader;

@end
