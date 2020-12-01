//
//  TipsContainerView.h
//  Woo_v2
//
//  Created by Akhil Singh on 11/30/15.
//  Copyright © 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TipsContainerView : UIView<UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *tipsHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipsSubHeaderLabel;
@property (weak, nonatomic) IBOutlet UITableView *tipsTableView;
- (IBAction)closeTipsContainerView:(id)sender;
- (void)setupViewForData:(NSMutableDictionary *)viewDataDict;
@property (weak, nonatomic) IBOutlet UIView *tipsDataView;
@property (weak, nonatomic) IBOutlet UIWebView *tipsWebView;

@end
