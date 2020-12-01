//
//  FaqViewController.m
//  Woo_v2
//
//  Created by Akhil Singh on 11/30/15.
//  Copyright © 2015 Vaibhav Gautam. All rights reserved.
//

#import "FaqViewController.h"

@interface FaqViewController ()

@property (retain, nonatomic) NSURL *faqUrl;

@end

@implementation FaqViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([AppLaunchModel sharedInstance].faqUrl) {
        self.faqUrl = [AppLaunchModel sharedInstance].faqUrl;
    }
    else{
        self.faqUrl = [NSURL URLWithString:@"http://www.getwoo.at/faq.html"];
    }
    [super viewWillAppear:animated];
    [self.faqWebView loadRequest:[NSURLRequest requestWithURL:_faqUrl]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)doneClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
