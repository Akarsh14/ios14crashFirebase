//
//  FaqViewController.h
//  Woo_v2
//
//  Created by Akhil Singh on 11/30/15.
//  Copyright © 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FaqViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIWebView *faqWebView;
- (IBAction)doneClicked:(id)sender;

@end
