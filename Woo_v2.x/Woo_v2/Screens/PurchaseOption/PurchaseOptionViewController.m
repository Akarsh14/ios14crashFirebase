//
//  PurchaseOptionViewController.m
//  Woo_v2
//
//  Created by Deepak Gupta on 12/29/15.
//  Copyright © 2015 Vaibhav Gautam. All rights reserved.
//

#import "PurchaseOptionViewController.h"
#import "PurchaseSelectionCell.h"
#import "InAppPurchaseManager.h"
#import "ProcessingPopupView.h"

@interface PurchaseOptionViewController ()
{
    NSMutableArray *productsFromServerArray;
    NSMutableArray *serverProductsArray;
    NSArray *productsFromAppleArray;
    NSString *productType;
    __weak IBOutlet UIActivityIndicatorView *activityIndicator;
    ProcessingPopupView *processingPopupView;
}
@end

@implementation PurchaseOptionViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [collectionView_obj registerNib:[UINib nibWithNibName:@"PurchaseSelectionCell" bundle:nil] forCellWithReuseIdentifier:@"PurchaseSelectionCell"];
    productsFromServerArray = [[NSMutableArray alloc]init];
    [self settingViewForCrushOrBoost];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    [collectionView_obj setHidden:YES];
    [self performSelector:@selector(AddingViewOnScrollView) withObject:nil afterDelay:0.3f];
    
    // Setting timer for changing the next page of the UIScrollView
//    [NSTimer scheduledTimerWithTimeInterval:3.0f
//                                     target:self
//                                   selector:@selector(changePageAfterTimeInterval)
//                                   userInfo:nil
//                                    repeats:YES];
    
    [self resetTimer];
    
    // Default Selected Index 0
    selectedIndexPath = [NSIndexPath indexPathForItem:0
                                            inSection:0];
    PurchaseSelectionCell *cell =
    (PurchaseSelectionCell *)[collectionView_obj cellForItemAtIndexPath:selectedIndexPath];
    cell.layer.borderWidth = 2.0f;
    
    
    
    if (!self.isCrushLoaded){ // For Boost
        cell.layer.borderColor = kPurchaseOptionBoostCardBorder.CGColor;
        
       // pageControl_obj.currentPageIndicatorTintColor = [UIColor whiteColor];
        
    }
    else {// For Crush
        cell.layer.borderColor = kPurchaseOptionCrushCardBorder.CGColor;
       // pageControl_obj.currentPageIndicatorTintColor = [UIColor whiteColor];
    }
    
    [self getProductsFromServer];
    
    [self settingNavigationBarView];
}

#pragma mark - Reset Timer
- (void) resetTimer{
    [myTimer invalidate];
    myTimer = nil;
    myTimer =     [NSTimer scheduledTimerWithTimeInterval:3.0f
                                                   target:self
                                                 selector:@selector(changePageAfterTimeInterval)
                                                 userInfo:nil
                                                 repeats:YES];
}


- (void) settingNavigationBarView{
    
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    UILabel *navBarLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
    
    if (self.isCrushLoaded)
        navBarLabel.text = NSLocalizedString(@"Get Crushes", nil);
    else
        navBarLabel.text = NSLocalizedString(@"Get Boosted", nil);
    
    navBarLabel.textColor = kHeaderTextRedColor;
    [navBarLabel setFont:kHeaderTextFont];
    [navBarLabel setBackgroundColor:[UIColor clearColor]];
    [navBarLabel sizeToFit];
    [self.navigationItem setTitleView:navBarLabel];

}

- (void)getProductsFromServer
{
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    
    BOOL isNetworkReachable = (reachability.isReachable || reachability.isReachableViaWiFi || reachability.isReachableViaWWAN);
    
    if (!isNetworkReachable) {
        SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"Please check your internet connection",nil));
        return;
    }
    
    if (self.isCrushLoaded) {
        productType = @"CRUSH";
    }
    else{
        productType = @"BOOST";
    }
    NSString *productString = [NSString stringWithFormat:@"%@%@%@/%lld",kBaseURLV1,kGetProductsFromServer,productType,[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue]];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =productString;
    wooRequestObj.time =0;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =getRequest;
    wooRequestObj.numberOfRetries =0;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = getProductsFromServer;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        
        if (requestType == getProductsFromServer) {
            if (!success) {
                return ;
            }
            
            [self getProductsFromAppleForResponse:response];
        }
        
    } shouldReachServerThroughQueue:TRUE];

}

- (void)getProductsFromAppleForResponse:(id)response
{
    serverProductsArray = [[NSMutableArray alloc] initWithArray:response];
    
    for (NSDictionary *productDict in [serverProductsArray mutableCopy]) {
        if ([productDict objectForKey:@"i_store"]) {
            [productsFromServerArray addObject:[[productDict objectForKey:@"i_store"] objectForKey:@"storeProductId"]];
        }
        else{
            [serverProductsArray removeObject:productDict];
        }
    }
    
//    [[InAppPurchaseManager sharedIAPManager] getAllProductsFromAppleWithProductIdentifiers:[NSSet setWithArray:productsFromServerArray] withCallback:^(BOOL success, BOOL canMakePurchase, NSArray *productsArray) {
//        productsFromAppleArray = productsArray;
//        [activityIndicator stopAnimating];
//        [collectionView_obj setHidden:NO];
//        [collectionView_obj reloadData];
//    }];
}

#pragma mark - Setting View For Crush or Boost
- (void) settingViewForCrushOrBoost{
    if (!self.isCrushLoaded) { // For Boost
        [imgView_bg setImage:[UIImage imageNamed:@"boost_bg"]];
    }else{
        
        [imgView_bg setImage:[UIImage imageNamed:@"crush_bg"]];
    }
}


#pragma mark - Change Scroll Page to next after tiome interval
- (void) changePageAfterTimeInterval{
    if (pageControl_obj.currentPage == 2) {
        
        CGFloat x = 3 * scrollView_obj.frame.size.width;
        [UIView animateWithDuration:0.5 animations:^{
            [scrollView_obj setContentOffset:CGPointMake(x, 0) animated:YES];
        }];
        
    }else{
        pageControl_obj.currentPage++;
        
        CGFloat x = pageControl_obj.currentPage * scrollView_obj.frame.size.width;
        [UIView animateWithDuration:0.5 animations:^{
            scrollView_obj.contentOffset = CGPointMake(x, 0);
        }];
    }
}


#pragma mark- Adding Multiple Views on UIScrollView
- (void) AddingViewOnScrollView{
    
    float x_axis = scrollView_obj.frame.size.width;
    float y_axis = 0.0f;
    float width = scrollView_obj.frame.size.width;
    float height = scrollView_obj.frame.size.height;
    
    NSArray *arr_images = nil;
    NSArray *arrMsgText = nil;
    if (self.isCrushLoaded){ // Images for Crush
        arr_images = [NSArray arrayWithObjects:[UIImage imageNamed:@"PurchaseOption_Crushes_message"] , [UIImage imageNamed:@"PurchaseOption_Crushes_shine"], [UIImage imageNamed:@"PurchaseOption_Crushes_crowd"], [UIImage imageNamed:@"PurchaseOption_Crushes_message"], nil];
        
//        arrMsgText =[ NSArray arrayWithObjects:@"Send a message to the ones you really like and increase your chances of getting a match",@"Let your personality shine. Woo her with the right words and drive her Like in your favor",@"Stand out from the crowd and let her know that you really like her", nil];
        
        
        arrMsgText =[NSArray arrayWithObjects:NSLocalizedString(@"Send a message to the ones you really like and increase your chances of getting a match", @"Send a message"), NSLocalizedString(@"Let your personality shine. Woo her with the right words and drive her Like in your favor", @"Let your personality"),NSLocalizedString(@"Stand out from the crowd and let her know that you really like her", @"Stand out"), nil];

        
        
    }
    else{ // Images for Boost
        arr_images = [NSArray arrayWithObjects:[UIImage imageNamed:@"PurchaseOption_boost_crown"] , [UIImage imageNamed:@"PurchaseOption_boost_eye"], [UIImage imageNamed:@"PurchaseOption_boost_rocket"], [UIImage imageNamed:@"PurchaseOption_boost_crown"], nil];
        
  //      arrMsgText =[ NSArray arrayWithObjects:@"Get Priority placement in profile recommendations",@"Get a week's worth of visibility in one day",@"Activate your boost anytime", nil];
        
        arrMsgText =[NSArray arrayWithObjects:NSLocalizedString(@"Get Priority placement in profile recommendations", @"Get Priority placement in profile recommendations"), NSLocalizedString(@"Get a week's worth of visibility in one day", @"Get a week's worth of visibility in one day"),NSLocalizedString(@"Activate your boost anytime", @"Activate your boost anytime"), nil];


    }
    
    for (int number = 0; number < 4; number++) {
        
        // Adding Views on ScrollView
        UIView *view_base = [[UIView alloc]initWithFrame:CGRectMake(x_axis * number, y_axis, width, height)];
        [scrollView_obj addSubview:view_base];
        
        // Adding ImageView
        UIImageView *imgView = nil;
        if (IS_IPHONE_4)
            imgView = [[UIImageView alloc]initWithFrame:CGRectMake((view_base.frame.size.width/2) - 49, y_axis + 10, 98, 98)];
        else
            imgView = [[UIImageView alloc]initWithFrame:CGRectMake((view_base.frame.size.width/2) - 49, y_axis + 55, 98, 98)];
        
        imgView.contentMode =   UIViewContentModeScaleAspectFit;
        [imgView setImage:[arr_images objectAtIndex:number]];
        [view_base addSubview:imgView];
        
        
        // Adding Message Label
        
        UILabel *lbl_message = nil;
        if (IS_IPHONE_4)
            lbl_message = [[UILabel alloc]initWithFrame:CGRectMake(20, imgView.frame.origin.y + imgView.frame.size.height + 0 , view_base.frame.size.width - 40, 60)];
        else
            lbl_message = [[UILabel alloc]initWithFrame:CGRectMake(20, imgView.frame.origin.y + imgView.frame.size.height + 20 , view_base.frame.size.width - 40, 60)];

        lbl_message.textAlignment = NSTextAlignmentCenter;
        [lbl_message setFont:kDiscoverMatchedUserDetailAgeFont];
        lbl_message.numberOfLines = 3;
        
       // lbl_message.text = @"Send a message to the ones you really like and increase your chances of getting a match.";
        
        if (number == 3)
            [lbl_message setText:[arrMsgText objectAtIndex:0]];
        else
            [lbl_message setText:[arrMsgText objectAtIndex:number]];
        
//        lbl_message.textColor = [UIColor blackColor];

        lbl_message.textColor = [UIColor whiteColor];
        [view_base addSubview:lbl_message];
        
    }
    
    [scrollView_obj setContentSize:CGSizeMake(scrollView_obj.frame.size.width*4, 0)];
}


#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat pageWidth = scrollView.frame.size.width; // you need to have a **iVar** with getter for scrollView
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    pageControl_obj.currentPage = page; // you need to have a **iVar** with getter for pageControl
    [self resetTimer];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
    if (scrollView_obj.contentOffset.x == 3 * scrollView_obj.frame.size.width) {
        [scrollView_obj setContentOffset:CGPointMake(0, 0) animated:NO];
        pageControl_obj.currentPage = 0;
        
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView_obj.contentOffset.x == 3 * scrollView_obj.frame.size.width) {
        [scrollView_obj setContentOffset:CGPointMake(0, 0) animated:NO];
        pageControl_obj.currentPage = 0;
    }
}


#pragma mark - Page Change Method For ScrollView
- (IBAction)changePage:(id)sender {
    CGFloat x = pageControl_obj.currentPage * scrollView_obj.frame.size.width;
    [scrollView_obj setContentOffset:CGPointMake(x, 0) animated:YES];
}


#pragma mark -
#pragma mark - UIButton Clicked Event


#pragma Back Button Clicked
- (IBAction)backButtonTapped:(id)sender {
    
    if (self.isViewPushed == YES) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
    [self dismissViewControllerAnimated:YES completion:^{
        if (crushPurchasedBlock) {
            crushPurchasedBlock(FALSE);
        }
    }];
    }
}

#pragma mark - Purchase Option Button Clicked
- (void)purchaseOptionClicked : (NSIndexPath *)index{
    
    int indexValue = (int)index.row;
    NSLog(@"SelectedIndex = %d",indexValue);
    NSDictionary *productDict = [serverProductsArray objectAtIndex:indexValue];
    SKProduct *productToBePurchased;

    for (SKProduct *product in productsFromAppleArray) {
        if ([product.productIdentifier isEqualToString:[[productDict objectForKey:@"i_store"] objectForKey:@"storeProductId"]]) {
            productToBePurchased = product;
        }
    }
    NSString *planId = [productDict objectForKey:@"planId"];
    
    if ([[InAppPurchaseManager sharedIAPManager]isProcessingInApp] == YES) {
        
        UIAlertController *purchaseAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Purchase", nil) message:NSLocalizedString(@"In-App Purchase is already in process", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
        [purchaseAlert addAction:okAction];
        
        [self presentViewController:purchaseAlert animated:true completion:nil];
        
        return;
    }
    
    [self showOrHideProcessingView:YES];

    
    if ([productType isEqualToString:@"BOOST"]){
        [[InAppPurchaseManager sharedIAPManager] purchaseProductWithProduct:productToBePurchased withProductType:InAppPRoductTypeBoost withPlanID:planId andResult:^(BOOL success,id error, BOOL canMakePayment, id serverResponse) {
            
            [self showOrHideProcessingView:NO];
            
            if (canMakePayment == NO) {
                
                UIAlertController *purchaseAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Purchase", nil) message:NSLocalizedString(@"Your In-App Purchase is restricted", nil) preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
                [purchaseAlert addAction:okAction];
                
                [self presentViewController:purchaseAlert animated:true completion:nil];
                
                return;
            }
            if (success) {
                [APP_DELEGATE sendSwrveEventWithEvent:@"Payment.Successful" andScreen:@"Payment"];
                [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"Payment.Successful" forScreenName:@"Payment"];

                BoostModel *boostModel = [BoostModel sharedInstance];
                NSMutableDictionary *boostDict = [[NSMutableDictionary alloc]init];
                [boostDict setObject:(NSDictionary *)[serverResponse objectForKey:@"availableBoost"] forKey:@"availableBoost"];
                [boostDict setObject:(NSDictionary *)[serverResponse objectForKey:@"expiryTime"] forKey:@"expiryTime"];
                [boostDict setObject:(NSDictionary *)[serverResponse objectForKey:@"percentageCompleted"] forKey:@"percentageCompleted"];
                [boostDict setObject:[NSNumber numberWithBool:YES] forKey:@"hasPurchased"];
                
                [boostDict setObject:[NSNumber numberWithBool:boostModel.availableInRegion] forKey:@"availableInRegion"];
                [boostDict setObject:[NSNumber numberWithBool:boostModel.showInLeftMenu] forKey:@"showInLeftMenu"];
                [boostDict setObject:[NSNumber numberWithBool:boostModel.currentlyActive] forKey:@"currentlyActive"];

                [[BoostModel sharedInstance] updateDataWithBoostDictionary:boostDict];
                
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kShouldOpenProfileInEditMode];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kNeedToShowBoostPurchasedView];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kHasPurchasedCrushCurrently];
                [[NSUserDefaults standardUserDefaults] synchronize];

                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self dismissViewControllerAnimated:YES completion:^{
                [[NSNotificationCenter defaultCenter]postNotificationName:kProfileTappedOnLeftPanel object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kReAddFillersNotification
                                                                        object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kRemovePurchaseCardFromCarousal
                                                                        object:kGetBoostedCard];
                }];
            }
            else{
                [APP_DELEGATE sendSwrveEventWithEvent:@"Payment.Failed" andScreen:@"Payment"];
                [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"Payment.Failed" forScreenName:@"Payment"];

            }
        }];

    }
    else{
        [[InAppPurchaseManager sharedIAPManager] purchaseProductWithProduct:productToBePurchased withProductType:InAppPRoductTypeCrush withPlanID:planId andResult:^(BOOL success,id error, BOOL canMakePayment, id serverResponse) {
            [self showOrHideProcessingView:NO];
            if (success) {
                [[CrushModel sharedInstance] setAvailableCrush:[[serverResponse objectForKey:@"availableCrush"] integerValue]];
                [[CrushModel sharedInstance] setExpiryTime:[[serverResponse objectForKey:@"expiryTime"] longLongValue]];
//                [[CrushModel sharedInstance] setHasPurchased:[[serverResponse objectForKey:@"hasPurchased"] boolValue]];
                [[CrushModel sharedInstance] setTotalCrush:[[serverResponse objectForKey:@"totalCrush"] integerValue]];
                
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kShouldOpenProfileInEditMode];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHasPurchasedCrushCurrently];
                [[NSUserDefaults standardUserDefaults] synchronize];

                [self dismissViewControllerAnimated:YES completion:^{
                    if (crushPurchasedBlock) {
                        crushPurchasedBlock(success);
                    }
                    if (!_needToLandOnDiscover) {
                        [[NSNotificationCenter defaultCenter]postNotificationName:kProfileTappedOnLeftPanel object:nil];
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:kReAddFillersNotification
                                                                        object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kRemovePurchaseCardFromCarousal
                                                                        object:kSendCrushCard];
                }];
            }
        }];
    }
    
}

#pragma mark ------------------------------
#pragma mark - UICollectionViewDelegate
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(32, 12, 15, 12);
}

//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
//{
//    return 15;
//}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [productsFromAppleArray count];
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"PurchaseSelectionCell";
    PurchaseSelectionCell *cell = (PurchaseSelectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [cell updateDataOnCellFromDictionay:[serverProductsArray objectAtIndex:indexPath.row]];
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.cornerRadius = 5;
    cell.layer.masksToBounds = YES;
    cell.layer.borderWidth = 1.0f;
    cell.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    if (indexPath == selectedIndexPath) {
        cell.layer.borderWidth = 2.0f;
        if (!self.isCrushLoaded) // For Boost
            cell.layer.borderColor = kPurchaseOptionBoostCardBorder.CGColor;
        else // For Crush
            cell.layer.borderColor = kPurchaseOptionCrushCardBorder.CGColor;

    }
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    
    selectedIndexPath = indexPath;
    [collectionView_obj reloadData];
    [collectionView_obj scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
    
    
    NSString *countStr = [[serverProductsArray objectAtIndex:indexPath.row] valueForKey:@"count"];
    
    if (self.isCrushLoaded) {
        [APP_DELEGATE sendSwrveEventWithEvent:[NSString stringWithFormat:@"Payment.Crush%@",countStr] andScreen:@"Payment"];
        [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:[NSString stringWithFormat:@"Payment.Crush%@",countStr] forScreenName:@"Payment"];
    }else{
        
        [APP_DELEGATE sendSwrveEventWithEvent:[NSString stringWithFormat:@"Payment.Boost%@",countStr] andScreen:@"Payment"];
        [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:[NSString stringWithFormat:@"Payment.Boost%@",countStr] forScreenName:@"Payment"];

    }
    [self purchaseOptionClicked:indexPath];
    
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

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)setCrushPurchasedSuccessfullyBlock:(CrushPurchasedFromServer)block{
    crushPurchasedBlock = block;
}

-(void)showOrHideProcessingView:(BOOL)showOrHide
{
    if (showOrHide == YES) {
        [self.navigationController setNavigationBarHidden:YES];
        NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"ProcessingPopupView"
                                                          owner:self
                                                        options:nil];
        
        processingPopupView = [nibViews firstObject];
        [processingPopupView setTextForPaymentProcessingLabel:NSLocalizedString(@"Processing Payment", nil)];
        [processingPopupView setFrame:APP_DELEGATE.window.bounds];
        [self.view addSubview:processingPopupView];
    }
    else{
        [self.navigationController setNavigationBarHidden:NO];
        if (processingPopupView) {
            [processingPopupView removeFromSuperview];
        }
    }
    
}
@end
