//
//  MyPurchaseViewController.m
//  Woo_v2
//
//  Created by Deepak Gupta on 7/12/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "MyPurchaseViewController.h"
#import "Woo_v2-Swift.h"
#import "PurchaseProductDetailModel.h"
#import "WooGlobeModel.h"

@interface MyPurchaseViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *myPurchaseViewTopConstraint;

@end

@implementation MyPurchaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDismissTheScreenNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissTheScreen) name:kDismissTheScreenNotification object:nil];

    //Swrve Event
    [APP_DELEGATE sendSwrveEventWithEvent:@"3-MyPurchases.Purchased_Section.MP_Landing" andScreen:@"Purchased_Section"];
  

}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self setDataOnNavBar];
    
    
    [[Utilities sharedUtility]colorStatusBar:[UIColor colorWithRed:0.28 green:0.57 blue:0.98 alpha:1.0]];
    
    //CGFloat safeAreaTop = [[Utilities sharedUtility] getSafeAreaForTop:true andBottom:false];
    _myPurchaseViewTopConstraint.constant = 44;
     NSInteger currentTimeStamp = [[NSDate date] timeIntervalSince1970];
    
    // For Boost
    
    NSString *boostCount = [NSString stringWithFormat:@"%ld",(long)[BoostModel sharedInstance].availableBoost];
    BOOL isBoostPurchased =        [BoostModel sharedInstance].availableBoost > 0 ? true: false;
    NSInteger BoostExpiry =        [BoostModel sharedInstance].expiryTime;
    BOOL isBoostExpired = BoostExpiry > currentTimeStamp ? TRUE : FALSE;

    

    // For Crush
    NSString *crushCount = [NSString stringWithFormat:@"%ld",(long)[CrushModel sharedInstance].availableCrush];
    BOOL isCrushPurchased =        ([CrushModel sharedInstance].availableCrush > 0 ?YES:NO);
    NSInteger crushExpiry =        [CrushModel sharedInstance].expiryTime;
    BOOL isCrushExpired = crushExpiry > currentTimeStamp ? TRUE : FALSE;
    
    
    // For WooPlus
    BOOL isWooPlusAvailableInRegion = [[WooPlusModel sharedInstance] availableInRegion];
    BOOL isWooPlusExpired = [[WooPlusModel sharedInstance] isExpired];
    
    
    viewHeader = [[[NSBundle mainBundle] loadNibNamed:@"MyPurchaseHeader" owner:nil options:nil] objectAtIndex:0];
    
    if (isWooPlusAvailableInRegion && isWooPlusExpired){
        arrData = [[NSMutableArray alloc] initWithObjects:
                   [NSDictionary dictionaryWithObjectsAndKeys:[MyPurchaseTemplate sharedInstance].boostProductType,kPurchaseType,[NSNumber numberWithBool:isBoostPurchased],kIsPurchased ,[NSNumber numberWithBool:isBoostExpired], kIsActive,boostCount, kPurchaseCount,[MyPurchaseTemplate sharedInstance].boostContent , kMyPurchaseContent , [MyPurchaseTemplate sharedInstance].boostTitle , kMyPurchaseTitle,  nil],
                   
                   [NSDictionary dictionaryWithObjectsAndKeys:[MyPurchaseTemplate sharedInstance].crushProductType,kPurchaseType,[NSNumber numberWithBool:isCrushPurchased],kIsPurchased ,[NSNumber numberWithBool:isCrushExpired], kIsActive, crushCount, kPurchaseCount, [MyPurchaseTemplate sharedInstance].crushContent , kMyPurchaseContent , [MyPurchaseTemplate sharedInstance].crushTitle , kMyPurchaseTitle, nil],
                   
                   [NSDictionary dictionaryWithObjectsAndKeys:[MyPurchaseTemplate sharedInstance].wooPlusProductType,kPurchaseType,[NSNumber numberWithBool:isWooPlusExpired],kIsPurchased ,[NSNumber numberWithBool:isWooPlusExpired], kIsActive, @"", kPurchaseCount, [MyPurchaseTemplate sharedInstance].wooPlusContent , kMyPurchaseContent , [MyPurchaseTemplate sharedInstance].wooPlusTitle , kMyPurchaseTitle, nil],
                   
                   nil];
    }
    else{
        arrData = [[NSMutableArray alloc] initWithObjects:
                   [NSDictionary dictionaryWithObjectsAndKeys:kPurchaseTypeBoost,kPurchaseType,[NSNumber numberWithBool:isBoostPurchased],kIsPurchased ,[NSNumber numberWithBool:isBoostExpired], kIsActive,boostCount, kPurchaseCount, [MyPurchaseTemplate sharedInstance].boostContent , kMyPurchaseContent , [MyPurchaseTemplate sharedInstance].boostTitle , kMyPurchaseTitle, nil],
                   
                   [NSDictionary dictionaryWithObjectsAndKeys:kPurchaseTypeCrush,kPurchaseType,[NSNumber numberWithBool:isCrushPurchased],kIsPurchased ,[NSNumber numberWithBool:isCrushExpired], kIsActive, crushCount, kPurchaseCount, [MyPurchaseTemplate sharedInstance].crushContent , kMyPurchaseContent , [MyPurchaseTemplate sharedInstance].crushTitle , kMyPurchaseTitle, nil],
                   nil];
    }
    if ([WooGlobeModel sharedInstance].isExpired && [WooGlobeModel sharedInstance].isAvailableInRegion) {
//        [arrData addObject:[NSDictionary dictionaryWithObjectsAndKeys:[MyPurchaseTemplate sharedInstance].wooGlobeProductType,kPurchaseType,
//                            [NSNumber numberWithBool:isWooPlusExpired],kIsPurchased ,
//                            [NSNumber numberWithBool:isWooPlusExpired], kIsActive,
//                            @"", kPurchaseCount,
//                            [MyPurchaseTemplate sharedInstance].wooGlobeContent , kMyPurchaseContent ,
//                            [MyPurchaseTemplate sharedInstance].wooGlobeTitle , kMyPurchaseTitle, nil]];
        [arrData insertObject:[NSDictionary dictionaryWithObjectsAndKeys:[MyPurchaseTemplate sharedInstance].wooGlobeProductType,kPurchaseType,
                               [NSNumber numberWithBool:[WooGlobeModel sharedInstance].isExpired],kIsPurchased ,
                               [NSNumber numberWithBool:[WooGlobeModel sharedInstance].isExpired], kIsActive,
                               @"", kPurchaseCount,
                               [MyPurchaseTemplate sharedInstance].wooGlobeContent , kMyPurchaseContent ,
                               [MyPurchaseTemplate sharedInstance].wooGlobeTitle , kMyPurchaseTitle, nil] atIndex:0];
    }
    
    if([[[[DiscoverProfileCollection sharedInstance] myProfileData]gender] isEqualToString:@"FEMALE"] )
    {
        [arrData removeObject:[NSDictionary dictionaryWithObjectsAndKeys:[MyPurchaseTemplate sharedInstance].boostProductType,kPurchaseType,[NSNumber numberWithBool:isBoostPurchased],kIsPurchased ,[NSNumber numberWithBool:isBoostExpired], kIsActive,boostCount, kPurchaseCount,[MyPurchaseTemplate sharedInstance].boostContent , kMyPurchaseContent , [MyPurchaseTemplate sharedInstance].boostTitle , kMyPurchaseTitle,  nil]];
        
        [arrData removeObject:[NSDictionary dictionaryWithObjectsAndKeys:[MyPurchaseTemplate sharedInstance].wooGlobeProductType,kPurchaseType,
                               [NSNumber numberWithBool:[WooGlobeModel sharedInstance].isExpired],kIsPurchased ,
                               [NSNumber numberWithBool:[WooGlobeModel sharedInstance].isExpired], kIsActive,
                               @"", kPurchaseCount,
                               [MyPurchaseTemplate sharedInstance].wooGlobeContent , kMyPurchaseContent ,
                               [MyPurchaseTemplate sharedInstance].wooGlobeTitle , kMyPurchaseTitle, nil]];

    }
    [self createHeaderViewData];

    NSLog(@"%@",arrData);
    
    [tblViewObj reloadData];
    
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDismissTheScreenNotification object:nil];

}
-(void)dismissTheScreen
{
    
    if (self.navigationController != nil)
        [self.navigationController popViewControllerAnimated:YES];//        [self.navigationController dismissViewControllerAnimated:YES completion:^{
//        }];
    else
        [self dismissViewControllerAnimated:YES completion:nil];
}


- (void) createHeaderViewData{
    
    arrDataHeader = [[NSMutableArray alloc] init];

    NSInteger currentTimeStamp = [[NSDate date] timeIntervalSince1970];

    
    NSString *boostCount = [NSString stringWithFormat:@"%ld",(long)[BoostModel sharedInstance].availableBoost];
    BOOL isBoostPurchased = false;
    
    NSInteger BoostExpiry =        [BoostModel sharedInstance].expiryTime;
    BOOL isBoostExpired = BoostExpiry > currentTimeStamp ? TRUE : FALSE;

    
    if ([BoostModel sharedInstance].availableBoost >= 1) {
        isBoostPurchased = YES;
    }else if([BoostModel sharedInstance].availableBoost < 1){
        if ([BoostModel sharedInstance].currentlyActive != true) {
            isBoostPurchased = NO;
        }else{
            isBoostPurchased = YES;
        }
    }
    
    
    // For Crush
    NSString *crushCount = [NSString stringWithFormat:@"%ld",(long)[CrushModel sharedInstance].availableCrush];
    BOOL isCrushPurchased =        ([CrushModel sharedInstance].availableCrush > 0 ?YES:NO);
    //NSInteger crushExpiry =        [CrushModel sharedInstance].expiryTime;
   // BOOL isCrushExpired = crushExpiry < currentTimeStamp ? TRUE : FALSE;
    
    // For WooPlus
    //BOOL isWooPlusAvailableInRegion = [[WooPlusModel sharedInstance] availableInRegion];
    
    BOOL isWooPlusPurchased = ![[WooPlusModel sharedInstance] isExpired];

    BOOL isWooGlobePurchased = ![[WooGlobeModel sharedInstance] isExpired];
    
    
    if (isWooGlobePurchased && [[[[DiscoverProfileCollection sharedInstance] myProfileData]gender] isEqualToString:@"MALE"]) {
            [arrDataHeader addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                      @"WOOGLOBE", @"type",
                                      [MyPurchaseTemplate sharedInstance].wooGlobeProductType,kPurchaseType,
                                      [NSNumber numberWithBool:isWooGlobePurchased],kIsPurchased ,
                                      [NSNumber numberWithBool:isWooGlobePurchased], kIsActive,
                                      boostCount, kPurchaseCount,
                                      [MyPurchaseTemplate sharedInstance].wooGlobeContent , kMyPurchaseContent ,
                                      [MyPurchaseTemplate sharedInstance].wooGlobeTitle , kMyPurchaseTitle,  nil]];
    }
    if (isBoostPurchased && [[[[DiscoverProfileCollection sharedInstance] myProfileData]gender] isEqualToString:@"MALE"]) {
        [arrDataHeader addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                  @"BOOST", @"type",
                                  [MyPurchaseTemplate sharedInstance].boostProductType,kPurchaseType,[NSNumber numberWithBool:isBoostPurchased],kIsPurchased ,[NSNumber numberWithBool:isBoostExpired], kIsActive,boostCount, kPurchaseCount,[MyPurchaseTemplate sharedInstance].boostContent , kMyPurchaseContent , [MyPurchaseTemplate sharedInstance].boostTitle , kMyPurchaseTitle,  nil]];
    }
    if (isCrushPurchased) {
        [arrDataHeader addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                  @"CRUSH", @"type",
                                  [MyPurchaseTemplate sharedInstance].crushProductType,kPurchaseType,[NSNumber numberWithBool:isCrushPurchased],kIsPurchased ,[NSNumber numberWithBool:YES], kIsActive, crushCount, kPurchaseCount, [MyPurchaseTemplate sharedInstance].crushContent , kMyPurchaseContent , [MyPurchaseTemplate sharedInstance].crushTitle , kMyPurchaseTitle, nil]];
    }
    if (isWooPlusPurchased) {
        if ([[AppLaunchModel sharedInstance] isWooPlusPurchasedToBeShown]) {
        [arrDataHeader addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                  @"WOOPLUS", @"type",
                                  [MyPurchaseTemplate sharedInstance].wooPlusProductType,kPurchaseType,[NSNumber numberWithBool:isWooPlusPurchased],kIsPurchased ,[NSNumber numberWithBool:isWooPlusPurchased], kIsActive, @"", kPurchaseCount, [MyPurchaseTemplate sharedInstance].wooPlusContent , kMyPurchaseContent , [MyPurchaseTemplate sharedInstance].wooPlusTitle , kMyPurchaseTitle, nil]];
        }
    }
    
    if (!isWooGlobePurchased && [[[[DiscoverProfileCollection sharedInstance] myProfileData]gender] isEqualToString:@"MALE"]) {
        [arrDataHeader addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                  @"WOOGLOBE", @"type",
                                  [MyPurchaseTemplate sharedInstance].wooGlobeProductType,kPurchaseType,
                                  [NSNumber numberWithBool:isWooGlobePurchased],kIsPurchased ,
                                  [NSNumber numberWithBool:isWooGlobePurchased], kIsActive,
                                  boostCount, kPurchaseCount,
                                  [MyPurchaseTemplate sharedInstance].wooGlobeContent , kMyPurchaseContent ,
                                  [MyPurchaseTemplate sharedInstance].wooGlobeTitle , kMyPurchaseTitle,  nil]];
    }
    if (!isBoostPurchased && [[[[DiscoverProfileCollection sharedInstance] myProfileData]gender] isEqualToString:@"MALE"]) {
        [arrDataHeader addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                  @"BOOST", @"type",
                                  [MyPurchaseTemplate sharedInstance].boostProductType,kPurchaseType,[NSNumber numberWithBool:isBoostPurchased],kIsPurchased ,[NSNumber numberWithBool:isBoostExpired], kIsActive,boostCount, kPurchaseCount,[MyPurchaseTemplate sharedInstance].boostContent , kMyPurchaseContent , [MyPurchaseTemplate sharedInstance].boostTitle , kMyPurchaseTitle,  nil]];
    }
    if (!isCrushPurchased) {
        [arrDataHeader addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                  @"CRUSH", @"type",
                                  [MyPurchaseTemplate sharedInstance].crushProductType,kPurchaseType,[NSNumber numberWithBool:isCrushPurchased],kIsPurchased ,[NSNumber numberWithBool:NO], kIsActive, crushCount, kPurchaseCount, [MyPurchaseTemplate sharedInstance].crushContent , kMyPurchaseContent , [MyPurchaseTemplate sharedInstance].crushTitle , kMyPurchaseTitle, nil]];
    }
    if (!isWooPlusPurchased) {
        [arrDataHeader addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                  @"WOOPLUS", @"type",
                                  [MyPurchaseTemplate sharedInstance].wooPlusProductType,kPurchaseType,[NSNumber numberWithBool:isWooPlusPurchased],kIsPurchased ,[NSNumber numberWithBool:isWooPlusPurchased], kIsActive, @"", kPurchaseCount, [MyPurchaseTemplate sharedInstance].wooPlusContent , kMyPurchaseContent , [MyPurchaseTemplate sharedInstance].wooPlusTitle , kMyPurchaseTitle, nil]];
    }
}


-(void)setDataOnNavBar{
    
    
    [self.navigationController setNavigationBarHidden:YES];
    
    CGFloat safeAreaTop = [[Utilities sharedUtility] getSafeAreaForTop:true andBottom:false];
    
    if (IS_IPHONE_X || IS_IPHONE_XS_MAX ){
        safeAreaTop = 0;
    }
    UIView *viewTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0 + safeAreaTop, SCREEN_WIDTH+8, 64)];
    [viewTop setBackgroundColor:[UIColor colorWithRed:0.28 green:0.57 blue:0.98 alpha:1.0]];
    
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack addTarget:self action:@selector(backBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [btnBack setImage:[UIImage imageNamed:@"ic_arrow_back"] forState:UIControlStateNormal];
    [btnBack setFrame: CGRectMake(0, 15, 50, 50)];
    [viewTop addSubview:btnBack];
    
    
    
    UILabel *lblCrush = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 75 + 20, 25, 150, 30)];
    [lblCrush setText:NSLocalizedString(@"My Purchases", @"Purchases")];
    [lblCrush setTextColor:[UIColor whiteColor]];
    [lblCrush setFont:[UIFont fontWithName:@"Lato-Medium" size:17.0f]];
    [lblCrush setTextAlignment:NSTextAlignmentLeft];
    [viewTop addSubview:lblCrush];
    
    [self.view addSubview:viewTop];
    
}


- (void)backBtnTapped{
    
    if (self.navigationController != nil)
    {
        [self.navigationController popViewControllerAnimated:YES];
        [[WooScreenManager sharedInstance] hideHomeViewTabBar:NO isAnimated:YES];
//completion:^{}];
    }
    else
        [self dismissViewControllerAnimated:YES completion:nil];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - TableView DataSource methods

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{

    __weak typeof(self) weakSelf = self;
    UIView *headerView = nil;
    if (section == 0){
     
        __weak MyPurchaseViewController *purchase = self;
        [viewHeader setDataOnMyPurchaseHeader:arrDataHeader withButtonTappedCallBack:^(NSString *purchaseType , BOOL isEpired) {
            UIWindow *window = [[[UIApplication sharedApplication] delegate ] window];
            PurchasePopup *popupObj = [[[NSBundle mainBundle] loadNibNamed:@"PurchasePopup" owner:window.rootViewController options:NULL] firstObject];
            popupObj.purchaseShownOnViewController = purchase;
            if (isEpired) {
                
                if (![APP_Utilities reachable]){
                    
                    [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];
                    return;
                }

                
                if ([purchaseType isEqualToString:kPurchaseTypeBoost]) {
                    popupObj.initiatedView = @"Store_boost_icontap";
                    [[Utilities sharedUtility] sendMixPanelEventWithName:@"Store_boost_icontap"];
                    [popupObj loadPopupOnWindowWithProductToBePurchased:PurchaseTypeBoost];
                    //[APP_DELEGATE sendSwrveEventWithEvent:@"3-MyPurchases.Store_Section.MyPur_Store_Boost_Tap" andScreen:@"Store_Section"];

                }else if ([purchaseType isEqualToString:kPurchaseTypeCrush]){
                    popupObj.initiatedView = @"Store_crush_icontap";
                    [[Utilities sharedUtility] sendMixPanelEventWithName:@"Store_crush_icontap"];
                    [popupObj loadPopupOnWindowWithProductToBePurchased:PurchaseTypeCrush];
                   // [APP_DELEGATE sendSwrveEventWithEvent:@"3-MyPurchases.Store_Section.MyPur_Store_Crush_Tap" andScreen:@"Store_Section"];

                }else if ([purchaseType isEqualToString:kPurchaseTypeWooPlus]){
                    popupObj.purchaseShownOnViewController = purchase;
                    popupObj.initiatedView = @"Store_WP_icontap";
                    [[Utilities sharedUtility] sendMixPanelEventWithName:@"Store_WP_icontap"];
                    [popupObj loadPopupOnWindowWithProductToBePurchased:PurchaseTypeWooPlus];
                    [APP_DELEGATE sendSwrveEventWithEvent:@"3-MyPurchases.Store_Section.MyPur_Store_WooPlus_Tap" andScreen:@"Store_Section"];
                }
                else if ([purchaseType isEqualToString:kPurchaseTypeWooGlobe]){
                    [popupObj loadPopupOnWindowWithProductToBePurchased:PurchaseTypeWooGlobe];
                    [APP_DELEGATE sendSwrveEventWithEvent:@"3-MyPurchases.Store_Section.MyPur_Store_WooGlobe_Tap" andScreen:@"Store_Section"];
                }
                
                [popupObj setPurchasedHandler:^(BOOL purchased) {
                    if (purchased == true) {
//                        [self dismissViewControllerAnimated:TRUE completion:^{
                            if (popupObj.screenType == PurchaseTypeWooGlobe) {
                                //Globe ki handling
                                [WooGlobeModel sharedInstance].isExpired = FALSE;
                                [WooGlobeModel sharedInstance].wooGlobleOption = TRUE;
                                [WooGlobeModel sharedInstance].locationOption = TRUE;
                                [WooGlobeModel sharedInstance].ethnicityOption = TRUE;
                                [WooGlobeModel sharedInstance].religionOption = TRUE;
                                [DiscoverProfileCollection sharedInstance].needToMakeDiscoverCallAsPreferencesHasBeenChanged = TRUE;
                                [purchase.navigationController popViewControllerAnimated:NO];
                                [[WooScreenManager sharedInstance].oHomeViewController openMyPreferenceWithShowWooGlobePop:TRUE];
                            }
                            else
                            {
                                [purchase.navigationController popViewControllerAnimated:YES];
                            }
                        }
                    //];
                    //}
                }];
                
               
                [popupObj setPurchaseDismissedHandler:^(PurchaseType screenType,NSDictionary *dropoffDTO,id modelObject)
                 {
                     DropOffPurchasePopup *dropOffPurchaseObj = [[[NSBundle mainBundle] loadNibNamed:@"DropOffPurchasePopup" owner:window.rootViewController options:NULL] firstObject];
                     [dropOffPurchaseObj loadPopupOnWindowWithProductToBePurchased:screenType andProductDTO:dropoffDTO andModelObj:modelObject];
                     [dropOffPurchaseObj setPurchasedHandler:^(BOOL purchased)
                      {
                          dispatch_async(dispatch_get_main_queue(), ^{
//                              [self dismissViewControllerAnimated:TRUE completion:^{
                              
                                  if (purchased == true) {
                                      if (dropOffPurchaseObj.screenType == PurchaseTypeWooGlobe) {
                                          //Globe ki handling
                                          [WooGlobeModel sharedInstance].isExpired = FALSE;
                                          [WooGlobeModel sharedInstance].wooGlobleOption = TRUE;
                                          [WooGlobeModel sharedInstance].locationOption = TRUE;
                                          [WooGlobeModel sharedInstance].ethnicityOption = TRUE;
                                          [WooGlobeModel sharedInstance].religionOption = TRUE;
                                          [DiscoverProfileCollection sharedInstance].needToMakeDiscoverCallAsPreferencesHasBeenChanged = TRUE;
                                          [purchase.navigationController popViewControllerAnimated:NO];
                                          [[WooScreenManager sharedInstance].oHomeViewController openMyPreferenceWithShowWooGlobePop:TRUE];
                                      }
                                      else
                                      {
                                          [purchase.navigationController popViewControllerAnimated:YES];
                                      }
                                  }
//                              }];
                          });
                          
                      }];
                 }];


                
            }else{
                
                if ([purchaseType isEqualToString:kPurchaseTypeBoost]) { // Go to Left Menu
                    
                    [weakSelf.navigationController dismissViewControllerAnimated:YES completion:^{
                        
                        [[WooScreenManager sharedInstance].oHomeViewController moveToTab:0];

                    }];
                    

                }else if ([purchaseType isEqualToString:kPurchaseTypeCrush]){ // Go to discover
                    
                    [weakSelf.navigationController dismissViewControllerAnimated:YES completion:^{
                        
                        [[WooScreenManager sharedInstance].oHomeViewController moveToTab:1];
                        
                    }];
                    
                }else if ([purchaseType isEqualToString:kPurchaseTypeWooPlus]){
                    
                    [weakSelf.navigationController dismissViewControllerAnimated:YES completion:^{
                        
                        [[WooScreenManager sharedInstance].oHomeViewController moveToTab:0];

                    }];
                }else if ([purchaseType isEqualToString:kPurchaseTypeWooGlobe]){
                    
                    [weakSelf.navigationController dismissViewControllerAnimated:YES completion:^{
                        
//                        [[WooScreenManager sharedInstance].oHomeViewController moveToTab:1];
                        [[WooScreenManager sharedInstance].oHomeViewController openMyPreferenceWithShowWooGlobePop:TRUE];
                        
                    }];
                }
                
                
            }
            NSLog(@"PURCHASE TYPE CLICKED = %@",purchaseType);;
            
        }];
        return viewHeader;
    }
    else{
        headerView = [[UIView alloc]init];
        headerView.backgroundColor = [UIColor clearColor];
        return headerView;
    }
    return nil;

}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    if (section == 0)
        return 170;
    else
        return 10;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return [arrData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  
     return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString *CellIdentifier = @"MyPurchaseCell";
    
    MyPurchaseCell *cell = (MyPurchaseCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell){
        cell = [[MyPurchaseCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    [cell setDataOnCellFromObj:[arrData objectAtIndex:indexPath.section]];
    NSLog(@"INDEX PATH ROW = %ld",(long)indexPath.row);
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    
    if (![APP_Utilities reachable]){
        
        [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];
        
        
        return;
    }
    
//    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
//                          [[arrData objectAtIndex:indexPath.section] objectForKey:kPurchaseType] , kPurchaseType,
//
//                          nil];

    UIWindow *window = [[[UIApplication sharedApplication] delegate ] window];
    PurchasePopup *popupObj = [[[NSBundle mainBundle] loadNibNamed:@"PurchasePopup" owner:window.rootViewController options:NULL] firstObject];
    
    NSLog(@"%@", [[PurchaseProductDetailModel sharedInstance] boostModel].wooProductDto);
   // BOOL isLargeCell = ([[PurchaseProductDetailModel sharedInstance] boostModel].wooProductDto.count > 3 ? YES : NO);
    
    if ([[[arrData objectAtIndex:indexPath.section] objectForKey:kPurchaseType] isEqualToString:@"BOOST"]) {
        
        popupObj.initiatedView = @"Store_boost_tap";
        [[Utilities sharedUtility] sendMixPanelEventWithName:@"Store_boost_tap"];
        [popupObj loadPopupOnWindowWithProductToBePurchased:PurchaseTypeBoost];
        
    }else if ([[[arrData objectAtIndex:indexPath.section] objectForKey:kPurchaseType] isEqualToString:@"CRUSH"]){
        
        popupObj.initiatedView = @"Store_crush_tap";
        [[Utilities sharedUtility] sendMixPanelEventWithName:@"Store_crush_tap"];
        [popupObj loadPopupOnWindowWithProductToBePurchased:PurchaseTypeCrush];
        
    }else if ([[[arrData objectAtIndex:indexPath.section] objectForKey:kPurchaseType] isEqualToString:@"WOOPLUS"]){
        popupObj.purchaseShownOnViewController = self;
        popupObj.initiatedView = @"Store_WP_tap";
        [[Utilities sharedUtility] sendMixPanelEventWithName:@"Store_WP_tap"];
        [popupObj loadPopupOnWindowWithProductToBePurchased:PurchaseTypeWooPlus];
    }
    else if ([[[arrData objectAtIndex:indexPath.section] objectForKey:kPurchaseType] isEqualToString:@"WOOGLOBE"]){
        if ([WooGlobeModel sharedInstance].isExpired) {
            [popupObj loadPopupOnWindowWithProductToBePurchased:PurchaseTypeWooGlobe];
            
        }
        else{
            [self dismissViewControllerAnimated:FALSE completion:^{
//                [[WooScreenManager sharedInstance].oHomeViewController openMyPreference];
                [[WooScreenManager sharedInstance].oHomeViewController openMyPreferenceWithShowWooGlobePop:FALSE];
            }];
            
//            UIStoryboard *storyBoardObj = [UIStoryboard storyboardWithName:@"Woo_3" bundle:nil];
//            MyPreferencesViewController *myPreferenceViewController = [storyBoardObj instantiateViewControllerWithIdentifier:@"MyPreferencesViewControllerID"];
//            [self dismissViewControllerAnimated:NO completion:^{
//                <#code#>
//            }]
        }
        
        
    }
    __weak MyPurchaseViewController *purchase = self;
    [popupObj setPurchasedHandler:^(BOOL purchased) {
        if (purchased == true) {
//            [self dismissViewControllerAnimated:TRUE completion:^{
                if (popupObj.screenType == PurchaseTypeWooGlobe) {
                    //Globe ki handling
                    [WooGlobeModel sharedInstance].isExpired = FALSE;
                    [WooGlobeModel sharedInstance].wooGlobleOption = TRUE;
                    [WooGlobeModel sharedInstance].locationOption = TRUE;
                    [WooGlobeModel sharedInstance].ethnicityOption = TRUE;
                    [WooGlobeModel sharedInstance].religionOption = TRUE;
                    [DiscoverProfileCollection sharedInstance].needToMakeDiscoverCallAsPreferencesHasBeenChanged = TRUE;
                    [purchase.navigationController popViewControllerAnimated:NO];
                    [[WooScreenManager sharedInstance].oHomeViewController openMyPreferenceWithShowWooGlobePop:TRUE];
                }
                else
                {
                    [purchase.navigationController popViewControllerAnimated:YES];
                }
//            }];
        }
    }];
    
    [popupObj setPurchaseDismissedHandler:^(PurchaseType screenType,NSDictionary *dropoffDTO,id modelObject)
     {
         DropOffPurchasePopup *dropOffPurchaseObj = [[[NSBundle mainBundle] loadNibNamed:@"DropOffPurchasePopup" owner:window.rootViewController options:NULL] firstObject];
         [dropOffPurchaseObj loadPopupOnWindowWithProductToBePurchased:screenType andProductDTO:dropoffDTO andModelObj:modelObject];
         [dropOffPurchaseObj setPurchasedHandler:^(BOOL purchased)
          {
              dispatch_async(dispatch_get_main_queue(), ^{
                  if (purchased == true) {
//                      [self dismissViewControllerAnimated:TRUE completion:^{

                          if (dropOffPurchaseObj.screenType == PurchaseTypeWooGlobe) {
                              //Globe ki handling
                              [WooGlobeModel sharedInstance].isExpired = FALSE;
                              [WooGlobeModel sharedInstance].wooGlobleOption = TRUE;
                              [WooGlobeModel sharedInstance].locationOption = TRUE;
                              [WooGlobeModel sharedInstance].ethnicityOption = TRUE;
                              [WooGlobeModel sharedInstance].religionOption = TRUE;
                              [DiscoverProfileCollection sharedInstance].needToMakeDiscoverCallAsPreferencesHasBeenChanged = TRUE;
                              [purchase.navigationController popViewControllerAnimated:NO];
                              [[WooScreenManager sharedInstance].oHomeViewController openMyPreferenceWithShowWooGlobePop:TRUE];
                          }
                          else
                          {
                              [purchase.navigationController popViewControllerAnimated:YES];
                          }
//                      }];
                  }
              });
              
          }];
         
     }];


    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
