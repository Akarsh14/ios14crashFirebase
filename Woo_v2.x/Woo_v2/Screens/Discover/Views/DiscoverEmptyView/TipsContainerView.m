//
//  TipsContainerView.m
//  Woo_v2
//
//  Created by Akhil Singh on 11/30/15.
//  Copyright © 2015 Vaibhav Gautam. All rights reserved.
//

#import "TipsContainerView.h"
#import "TipsTableViewCell.h"
#import "WooLoader.h"
#import "AppLaunchApiClass.h"

@interface TipsContainerView()
{
    NSMutableDictionary *tipsDataDictionary;
    WooLoader *customLoader;
}
- (IBAction)closeTipsView:(id)sender;

@end

@implementation TipsContainerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setupViewForData:(NSMutableDictionary *)viewDataDict
{
    self.tipsWebView.opaque = NO;
    self.tipsWebView.backgroundColor = [UIColor clearColor];
    self.tipsDataView.layer.shouldRasterize = YES;
    self.tipsDataView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    self.tipsDataView.layer.masksToBounds = YES;
    self.tipsDataView.layer.cornerRadius = 10.0f;
    
//        tipsDataDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:kTipsData];
//        if (tipsDataDictionary) {
//            self.tipsHeaderLabel.text = [tipsDataDictionary objectForKey:@"header"];
//            [self.tipsWebView loadHTMLString:[tipsDataDictionary objectForKey:@"content"] baseURL:nil];
//        }
    /*
    tipsDataDictionary = [[NSMutableDictionary alloc]init];
    NSMutableArray *tipsDataArray = [[NSMutableArray alloc]init];
    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc]init];
    [dataDict setObject:@"CDE0029" forKey:@"header"];
    [dataDict setObject:@"65% of profile liked have complete work and education info" forKey:@"body"];
    [tipsDataArray addObject:dataDict];
    NSMutableDictionary *dataDict1 = [[NSMutableDictionary alloc]init];
    [dataDict1 setObject:@"CDE0031" forKey:@"header"];
    [dataDict1 setObject:@"CDE0032" forKey:@"body"];
    [tipsDataArray addObject:dataDict1];
    NSMutableDictionary *dataDict2 = [[NSMutableDictionary alloc]init];
    [dataDict2 setObject:@"CDE0033" forKey:@"header"];
    [dataDict2 setObject:@"CDE0034" forKey:@"body"];
    [tipsDataArray addObject:dataDict2];
    NSMutableDictionary *dataDict3 = [[NSMutableDictionary alloc]init];
    [dataDict3 setObject:@"CDE0035" forKey:@"header"];
    [dataDict3 setObject:@"Women tend to express a like more through an answer than by just looking at a profile" forKey:@"body"];
    [tipsDataArray addObject:dataDict3];
    [tipsDataDictionary setObject:tipsDataArray forKey:@"tipsArray"];
    [tipsDataDictionary setObject:@"Boost your visibility" forKey:@"header"];
    [tipsDataDictionary setObject:@"CDE0028" forKey:@"subHeader"];
    
    self.tipsHeaderLabel.text = [tipsDataDictionary objectForKey:@"header"];
    self.tipsSubHeaderLabel.text = [tipsDataDictionary objectForKey:@"subHeader"];
    [self.tipsTableView reloadData];
     */
}

//- (void)loadDataForTipsWebView
//{
//    NSString *linkedInUrl = [NSString stringWithFormat:@"%@/tips?wooId=%@",kBaseURLV1,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
//    WooRequest *wooRequestObj = [[WooRequest alloc]init];
//    wooRequestObj.url =linkedInUrl;
//    wooRequestObj.time =9000;
//    wooRequestObj.requestParams =nil;
//    wooRequestObj.methodType =getRequest;
//    wooRequestObj.numberOfRetries =-10;
//    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
//    wooRequestObj.requestType = getTipsFromServer;
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
//            
//            tipsDataDictionary = response;
//            [[NSUserDefaults standardUserDefaults] setObject:tipsDataDictionary forKey:kTipsData];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                self.tipsHeaderLabel.text = [response objectForKey:@"header"];
//                [self.tipsWebView loadHTMLString:[response objectForKey:@"content"] baseURL:nil];
//                
//            });
//        } shouldReachServerThroughQueue:FALSE];
//    });
//}

- (IBAction)closeTipsContainerView:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:kDismissTips object:nil];
}

#pragma mark UITableViewDatasource and Delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *localTipsArray = [tipsDataDictionary objectForKey:@"tipsArray"];
    return [localTipsArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TipsTableViewCell"];
    if (cell == nil) {
        // Load the top-level objects from the custom cell XIB.
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"TipsTableViewCell" owner:self options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        cell = [topLevelObjects objectAtIndex:0];
    }
    NSMutableArray *localTipsArray = [tipsDataDictionary objectForKey:@"tipsArray"];
    NSMutableDictionary *localDict = [localTipsArray objectAtIndex:indexPath.row];
    TipsTableViewCell *tipsCell = (TipsTableViewCell *)cell;
    tipsCell.headerLabel.text = [localDict objectForKey:@"header"];
    tipsCell.bodyLabel.text = [localDict objectForKey:@"body"];
    
    return cell;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    // Disable user selection
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    // Disable callout
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
}

- (IBAction)closeTipsView:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:kDismissTips object:nil];
}
@end
