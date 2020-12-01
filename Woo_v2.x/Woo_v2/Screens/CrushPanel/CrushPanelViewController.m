//
//  CrushPanelViewController.m
//  Woo_v2
//
//  Created by Deepak Gupta on 1/15/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "CrushPanelViewController.h"
#import "WooAPIClass.h"
#import "ProfileAPIClass.h"
#import "Woo_v2-Swift.h"
#import "LoginModel.h"
#import "CrushModel.h"
#import "BoostModel.h"
#import "BoostProductsAPICalss.h"
#import "AppLaunchModel.h"
#import "CrushCell.h"

typedef void (^SuccesBlock)(BOOL successValue, NSDictionary *responseValue, int statusCodeValue);


@interface CrushPanelViewController ()<CrushCellButtonTappedDelegate>
{
    __weak IBOutlet NSLayoutConstraint *activityIndicatorTopConstraint;
    __weak IBOutlet NSLayoutConstraint *crushesTableViewTopConstraint;
    __weak IBOutlet UIBarButtonItem *backButton;
    __weak IBOutlet UITableView *crushesTableView;
    __weak IBOutlet UIImageView *profileImageView;
    __weak IBOutlet UILabel *headerLabel;
    BOOL isLikeCallOnGoing;
    NSString *crushText;
}

@end

@implementation CrushPanelViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Swrve Event
    [APP_DELEGATE sendSwrveEventWithEvent:@"3-MeSection.Me_CrushSection.MCS_Landing" andScreen:@"Me_CrushSection"];
    
    crushesTableView.contentInset = UIEdgeInsetsMake(44,0,0,0);
    crushesTableView.backgroundColor = [UIColor clearColor];
    [self.view setBackgroundColor:[UIColorHelper colorWithRGBA:@"#F6F6F6"]];
    [self createEmptyView];
    [self updateDataOnViewFromDB];
    [self setDataOnNavBar];
    currentlySelectedSection = -1;
    
    btnViewNoCrush =   [APP_Utilities addingShadowOnButton:btnViewNoCrush];
    
    //Observer Added to dismiss when another Vc needs to be presented from notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backBtnTapped) name:kDismissPresentedViewController object:nil];
    if (!viewedCrushProfileIdArray) {
        viewedCrushProfileIdArray = [[NSMutableArray alloc] init];
    }
    if ([viewedCrushProfileIdArray count] > 0) {
        [viewedCrushProfileIdArray removeAllObjects];
    }
    [self getDataForCrushesFromServer];
    [self addEmptyScreenUserImageView];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDismissPresentedViewController object:nil];
}



-(void)getDataForCrushesFromServer{
    [self updateDataOnViewFromDB];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - More Info Clicked

-(IBAction)btnMoreInfoClicked:(id)sender{
    
    if (![APP_Utilities reachable]){
        
        [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];
        
        return;
    }
    
    __weak CrushPanelViewController *weakSelf = self;
    if ([[[DiscoverProfileCollection sharedInstance] myProfileData].gender isEqualToString:@"MALE"])
    {
        if ([[CrushModel sharedInstance] availableCrush] > 0)
        {
            // Crush Avaibale
            [self.navigationController popViewControllerAnimated:YES];
            [[[WooScreenManager sharedInstance] oHomeViewController] moveToTab:1];
        }
        else if ([[BoostModel sharedInstance] availableBoost] <= 0 && ![[BoostModel sharedInstance] currentlyActive])
        {
            // Boost not available
            UIWindow *window = [[[UIApplication sharedApplication] delegate ] window];
            PurchasePopup *popupObj = [[[NSBundle mainBundle] loadNibNamed:@"PurchasePopup" owner:window.rootViewController options:NULL] firstObject];
            [popupObj loadPopupOnWindowWithProductToBePurchased:PurchaseTypeBoost];
            [popupObj setPurchasedHandler:^(BOOL success) {
                [weakSelf getDataForCrushesFromServer];
            }];
            
            [popupObj setPurchaseDismissedHandler:^(PurchaseType screenType,NSDictionary *dropoffDTO,id modelObject)
             {
                 DropOffPurchasePopup *dropOffPurchaseObj = [[[NSBundle mainBundle] loadNibNamed:@"DropOffPurchasePopup" owner:window.rootViewController options:NULL] firstObject];
                 [dropOffPurchaseObj loadPopupOnWindowWithProductToBePurchased:screenType andProductDTO:dropoffDTO andModelObj:modelObject];
                 [dropOffPurchaseObj setPurchasedHandler:^(BOOL purchased)
                  {
                      dispatch_async(dispatch_get_main_queue(), ^{
                          
                          [self getDataForCrushesFromServer];
                      });
                  }];
             }];
        }
        else if ([[BoostModel sharedInstance] availableBoost] > 0 && ![[BoostModel sharedInstance] currentlyActive])
        {
            // Boost Available  & is InActive
            if (![APP_Utilities reachable]){
                
                [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];
                
                return;
            }

            activityIndicatorView.hidden = FALSE;
            [self.view bringSubviewToFront:activityIndicatorView];
            [self performSelector:@selector(addingWooLoader) withObject:nil afterDelay:0.1];

            
            [BoostProductsAPICalss activateBoostForWooID:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] withCompletionBlock:^(BOOL success, id responseObj, int statusCode) {
                self->activityIndicatorView.hidden = TRUE;
                if (success)
                    [weakSelf getDataForCrushesFromServer];
                
            }];
        }
        else if ([[BoostModel sharedInstance] availableBoost] >= 0 && [[BoostModel sharedInstance] currentlyActive])
        {
            
            if ([[CrushModel sharedInstance] availableCrush] == 0) // Crush unavaibale
            {
                UIWindow *window = [[[UIApplication sharedApplication] delegate ] window];
                PurchasePopup *popupObj = [[[NSBundle mainBundle] loadNibNamed:@"PurchasePopup" owner:window.rootViewController options:NULL] firstObject];
                [popupObj loadPopupOnWindowWithProductToBePurchased:PurchaseTypeCrush];
                [popupObj setPurchasedHandler:^(BOOL success) {
                    [self getDataForCrushesFromServer];
                }];
                [popupObj setPurchaseDismissedHandler:^(PurchaseType screenType,NSDictionary *dropoffDTO,id modelObject)
                 {
                     DropOffPurchasePopup *dropOffPurchaseObj = [[[NSBundle mainBundle] loadNibNamed:@"DropOffPurchasePopup" owner:window.rootViewController options:NULL] firstObject];
                     [dropOffPurchaseObj loadPopupOnWindowWithProductToBePurchased:screenType andProductDTO:dropoffDTO andModelObj:modelObject];
                     [dropOffPurchaseObj setPurchasedHandler:^(BOOL purchased)
                      {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              
                              [self getDataForCrushesFromServer];
                          });
                      }];
                 }];
            }
            else
            {
                // Boost Available  & Active
                UIWindow *window = [[[UIApplication sharedApplication] delegate ] window];
                PurchasePopup *popupObj = [[[NSBundle mainBundle] loadNibNamed:@"PurchasePopup" owner:window.rootViewController options:NULL] firstObject];
                [popupObj loadPopupOnWindowWithProductToBePurchased:PurchaseTypeCrush];
                [popupObj setPurchasedHandler:^(BOOL success) {
                    [self getDataForCrushesFromServer];
                }];
                [popupObj setPurchaseDismissedHandler:^(PurchaseType screenType,NSDictionary *dropoffDTO,id modelObject)
                 {
                     DropOffPurchasePopup *dropOffPurchaseObj = [[[NSBundle mainBundle] loadNibNamed:@"DropOffPurchasePopup" owner:window.rootViewController options:NULL] firstObject];
                     [dropOffPurchaseObj loadPopupOnWindowWithProductToBePurchased:screenType andProductDTO:dropoffDTO andModelObj:modelObject];
                     [dropOffPurchaseObj setPurchasedHandler:^(BOOL purchased)
                      {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              
                              [self getDataForCrushesFromServer];
                          });
                      }];
                 }];
            }

        }
    }
    else{
        if ([[CrushModel sharedInstance] availableCrush] == 0) // Crush unavaibale
        {
            UIWindow *window = [[[UIApplication sharedApplication] delegate ] window];
            PurchasePopup *popupObj = [[[NSBundle mainBundle] loadNibNamed:@"PurchasePopup" owner:window.rootViewController options:NULL] firstObject];
            [popupObj loadPopupOnWindowWithProductToBePurchased:PurchaseTypeCrush];
            [popupObj setPurchasedHandler:^(BOOL success) {
                [self getDataForCrushesFromServer];
            }];
            [popupObj setPurchaseDismissedHandler:^(PurchaseType screenType,NSDictionary *dropoffDTO,id modelObject)
             {
                 DropOffPurchasePopup *dropOffPurchaseObj = [[[NSBundle mainBundle] loadNibNamed:@"DropOffPurchasePopup" owner:window.rootViewController options:NULL] firstObject];
                 [dropOffPurchaseObj loadPopupOnWindowWithProductToBePurchased:screenType andProductDTO:dropoffDTO andModelObj:modelObject];
                 [dropOffPurchaseObj setPurchasedHandler:^(BOOL purchased)
                  {
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [self getDataForCrushesFromServer];
                      });
                  }];
             }];
        }
        else
        {
            // Boost Available  & Active
            UIWindow *window = [[[UIApplication sharedApplication] delegate ] window];
            PurchasePopup *popupObj = [[[NSBundle mainBundle] loadNibNamed:@"PurchasePopup" owner:window.rootViewController options:NULL] firstObject];
            [popupObj loadPopupOnWindowWithProductToBePurchased:PurchaseTypeCrush];
            [popupObj setPurchasedHandler:^(BOOL success) {
                [self getDataForCrushesFromServer];
            }];
            [popupObj setPurchaseDismissedHandler:^(PurchaseType screenType,NSDictionary *dropoffDTO,id modelObject)
             {
                 DropOffPurchasePopup *dropOffPurchaseObj = [[[NSBundle mainBundle] loadNibNamed:@"DropOffPurchasePopup" owner:window.rootViewController options:NULL] firstObject];
                 [dropOffPurchaseObj loadPopupOnWindowWithProductToBePurchased:screenType andProductDTO:dropoffDTO andModelObj:modelObject];
                 [dropOffPurchaseObj setPurchasedHandler:^(BOOL purchased)
                  {
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [self getDataForCrushesFromServer];
                      });
                  }];
             }];
        }
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:kPushFromCrushToDetailProfileView])
    {
        ProfileCardModel *modelObj = (ProfileCardModel *)profileCardModel;
        ProfileDeckDetailViewController *vc = (ProfileDeckDetailViewController *)segue.destinationViewController;
        [vc setProfileData:modelObj];
        [vc setParentvalueforCrush];
        [vc setDismissHandlerObjC: ^(NSString * strValue, NSString *crushValue, ProfileCardModel *userProfile) {
            self->isLikeCallOnGoing = false;
            self->crushText = crushValue;
            self->profileCardModel = userProfile;
                if ([strValue isEqualToString:@"Like"]) {
                    [self likeUser:^(BOOL isCompleted) {
                        [self likePassCallBack:self->currentlySelectedProfile withIsBoosted:FALSE];
                    }];
                }else {
                    [self updateDataOnViewFromDB];
                }
            self->currentlySelectedSection = -1;
            self->currentlySelectedProfile = nil;
        }];
        [vc setIsViewPushed:TRUE];
        
    }
    else if ([segue.identifier isEqual:kPushToChatFromCrushPanel]){
        NewChatViewController *chatViewControllerObj = (NewChatViewController*)segue.destinationViewController;
        MyMatches *model = (MyMatches*)sender;
        chatViewControllerObj.myMatchesData = model;
        chatViewControllerObj.isAutomaticallyPushedFromChat = FALSE;
        chatViewControllerObj.parentView = DetailProfileViewParentCrush;
    }
}

- (void)likeUser:(BackgroundThreadCompletionHandler)completionHandler
{
    ProfileActionManager *actionManager = [[ProfileActionManager alloc] init];
    [actionManager setReloadHandlerObjC:^{
        [self updateDataOnViewFromDB];
        completionHandler(true);
    }];
    [actionManager setPerformSegueHandlerObjC:^(MyMatches *matchObject){
        if ([[Utilities sharedUtility] isChatRoomPresentInNavigationController:self.navigationController] == false) {
            if([AppLaunchModel sharedInstance].isChatEnabled == false){
                [[WooScreenManager sharedInstance].oHomeViewController moveToTab:2];
            }else{
            [self performSegueWithIdentifier:kPushToChatFromCrushPanel sender:matchObject];
            }
        }
    }];
    [actionManager setCurrentViewTypeWithType:4];
    [actionManager setCurrentProfileTypeWithType:5];
    [actionManager likeForObjectiveCWithUserObject:currentlySelectedProfile];
}

-(void) dislikeUser:(BackgroundThreadCompletionHandler)completionHandler{
    
    ProfileActionManager *actionManager = [[ProfileActionManager alloc] init];
    
    [actionManager setReloadHandlerObjC:^{
        [self updateDataOnViewFromDB];
        completionHandler(true);
    }];
    
    [actionManager setCurrentViewTypeWithType:4];
    [actionManager setCurrentProfileTypeWithType:5];
    [actionManager dislikeForObjectiveCWithUserObject:currentlySelectedProfile];
}
- (void)showSnackBarWithText:(NSString *)text{
    MDSnackbar *snackBarObj = [[MDSnackbar alloc] initWithText:text actionTitle:@"" duration:2.0];
    [snackBarObj setMultiline:true];
    [snackBarObj show];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [[WooScreenManager sharedInstance]  hideHomeViewTabBar:YES isAnimated:YES];
[AppLaunchModel sharedInstance].isNewDataPresentInCrushSection = FALSE;
}

- (void)viewDidLayoutSubviews{
    CGFloat safeAreaTop = [[Utilities sharedUtility] getSafeAreaForTop:true andBottom:false];
    crushesTableViewTopConstraint.constant = 0;
    activityIndicatorTopConstraint.constant = safeAreaTop;
}

- (void)backBtnTapped{
   if ([viewedCrushProfileIdArray count] > 0) {
        [MeApiClass syncProfileViews:viewedCrushProfileIdArray withCompletionBlock:^(BOOL success, id response) {
            NSLog(@"success :%d",success);
        }];
    }
    if (self.navigationController != nil)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
        [self dismissViewControllerAnimated:true completion:nil];
}


-(void)updateDataOnViewFromDB{

    _totalSectionArray = [CrushesDashboard getDisctintGroupsForCrushes];
    _dictCrushData =  [CrushesDashboard getGroupedCrushesDataAccordingToTheGroups];

    if ([_totalSectionArray count]> 0 && [[_dictCrushData allKeys] count] > 0)
    {
        [crushesTableView setHidden:NO];
        [meSectionEmptyViewObj setHidden:YES];
        [crushesTableView reloadData];
        
    }else
    {
        [crushesTableView setHidden:YES];
        [meSectionEmptyViewObj setHidden:NO];
        [self settingNoCrushView];
    }
}



- (void)settingNoCrushView{
    
    [btnViewNoCrush setHidden:NO];
    [viewNoCrushTitle setText:NSLocalizedString(@"Future Crushes will show here", @"Future Crushes will show here")];
    
    if ([[[DiscoverProfileCollection sharedInstance] myProfileData].gender isEqualToString:@"MALE"])
    {
        if ([[CrushModel sharedInstance] availableCrush] > 0)
        { // Crush Avaibale
            
            [viewNoCrushDesc setText:[AppLaunchModel sharedInstance].sendCrushText];
            [viewNoCrushDesc setText:NSLocalizedString(@"Crushes can be sent only to the ones you really like. Match with the ones you like back.",nil)];
            [btnViewNoCrush setTitle:NSLocalizedString(@"DISCOVER PROFILES", nil) forState:UIControlStateNormal];
            
            [meSectionEmptyViewObj setEmptyScreenDetailWithTitle:NSLocalizedString(@"Your future Crush will show here", nil) sellingMessage:[AppLaunchModel sharedInstance].sendCrushText actionButtonTitle:NSLocalizedString(@"DISCOVER PROFILES",nil) showBoostIcon:[BoostModel sharedInstance].currentlyActive isUserMale:[APP_Utilities isGenderMale:DiscoverProfileCollection.sharedInstance.myProfileData.gender]];
            [meSectionEmptyViewObj showActionButtonWithShowActionButton:TRUE];
            
            
        }
        else if ([[BoostModel sharedInstance] availableBoost] <= 0 && ![[BoostModel sharedInstance] currentlyActive])
        { // Boost not available
            [viewNoCrushDesc setText:[AppLaunchModel sharedInstance].boostCrushReceivedText];
            [btnViewNoCrush setTitle:NSLocalizedString(@"BOOST ME NOW", @"BOOST ME NOW") forState:UIControlStateNormal];
            
            [meSectionEmptyViewObj setEmptyScreenDetailWithTitle:NSLocalizedString(@"Future Crushes will show here", @"Future Crushes will show here") sellingMessage:[AppLaunchModel sharedInstance].boostCrushReceivedText actionButtonTitle:NSLocalizedString(@"BOOST ME NOW", @"BOOST ME NOW") showBoostIcon:[BoostModel sharedInstance].currentlyActive isUserMale:[APP_Utilities isGenderMale:DiscoverProfileCollection.sharedInstance.myProfileData.gender]];
            [meSectionEmptyViewObj showActionButtonWithShowActionButton:TRUE];
            
        }
        else if ([[BoostModel sharedInstance] availableBoost] > 0 && ![[BoostModel sharedInstance] currentlyActive])
        { // Boost Available  & is InActive
            [viewNoCrushDesc setText:NSLocalizedString(@"In the meantime… \nGet discovered by more people", @"You have not received")];
            [btnViewNoCrush setTitle:NSLocalizedString(@"ACTIVATE A BOOST", @"ACTIVATE A BOOST") forState:UIControlStateNormal];
            
            [meSectionEmptyViewObj setEmptyScreenDetailWithTitle:NSLocalizedString(@"Future Crushes will show here", @"Future Crushes will show here") sellingMessage:NSLocalizedString(@"In the meantime… \nGet discovered by more people", @"You have not received") actionButtonTitle:NSLocalizedString(@"ACTIVATE A BOOST", @"ACTIVATE A BOOST") showBoostIcon:[BoostModel sharedInstance].currentlyActive isUserMale:[APP_Utilities isGenderMale:DiscoverProfileCollection.sharedInstance.myProfileData.gender]];
            [meSectionEmptyViewObj showActionButtonWithShowActionButton:TRUE];
            
        }
        else if ([[BoostModel sharedInstance] availableBoost] >= 0 && [[BoostModel sharedInstance] currentlyActive])
        {
            if ([[CrushModel sharedInstance] availableCrush] == 0)
            {
                // Crushes not Avaibale
                [viewNoCrushDesc setText:NSLocalizedString(@"Don't miss out. Make the first move and send a Crush.", @"Don't miss out. Make the first move and send a Crush.")];
                [btnViewNoCrush setTitle:NSLocalizedString(@"BUY CRUSHES", @"BUY CRUSHES") forState:UIControlStateNormal];
                [meSectionEmptyViewObj setEmptyScreenDetailWithTitle:NSLocalizedString(@"Future Crushes will show here", @"Future Crushes will show here") sellingMessage:NSLocalizedString(@"Don't miss out. Make the first move and send a crush.", @"Don't miss out. Make the first move and send a crush.") actionButtonTitle:NSLocalizedString(@"BUY CRUSHES", @"BUY CRUSHES") showBoostIcon:[BoostModel sharedInstance].currentlyActive isUserMale:[APP_Utilities isGenderMale:DiscoverProfileCollection.sharedInstance.myProfileData.gender]];
                [meSectionEmptyViewObj showActionButtonWithShowActionButton:TRUE];
            }
            else
            {
                // Boost Available  & Active
                [viewNoCrushDesc setText:NSLocalizedString(@"Crushes can be sent only to the ones you really like. Match with the ones you like back.", nil)];
                [btnViewNoCrush setHidden:YES];
                [meSectionEmptyViewObj setEmptyScreenDetailWithTitle:NSLocalizedString(@"Your future Crush will show here",nil) sellingMessage:NSLocalizedString(@"Crushes can be sent only to the ones you really like. Match with the ones you like back.", nil) actionButtonTitle:NSLocalizedString(@"", @"") showBoostIcon:[BoostModel sharedInstance].currentlyActive isUserMale:[APP_Utilities isGenderMale:DiscoverProfileCollection.sharedInstance.myProfileData.gender]];
                [meSectionEmptyViewObj showActionButtonWithShowActionButton:FALSE];
            }
        }
    }
    else{
        if ([[CrushModel sharedInstance] availableCrush] == 0)
        {
            // Crushes not Avaibale
            [viewNoCrushDesc setText:NSLocalizedString(@"Don't miss out. Make the first move and send a Crush.", @"Don't miss out. Make the first move and send a Crush.")];
            [btnViewNoCrush setTitle:NSLocalizedString(@"BUY CRUSHES", @"BUY CRUSHES") forState:UIControlStateNormal];
            [meSectionEmptyViewObj setEmptyScreenDetailWithTitle:NSLocalizedString(@"Future Crushes will show here", @"Future Crushes will show here") sellingMessage:NSLocalizedString(@"Don't miss out. Make the first move and send a crush.", @"Don't miss out. Make the first move and send a crush.") actionButtonTitle:NSLocalizedString(@"BUY CRUSHES", @"BUY CRUSHES") showBoostIcon:NO isUserMale:[APP_Utilities isGenderMale:DiscoverProfileCollection.sharedInstance.myProfileData.gender]];
            [meSectionEmptyViewObj showActionButtonWithShowActionButton:TRUE];
        }
        else
        {
            // Boost Available  & Active
            [viewNoCrushDesc setText:NSLocalizedString(@"Crushes can be sent only to the ones you really like. Match with the ones you like back.", nil)];
            [btnViewNoCrush setHidden:YES];
            [meSectionEmptyViewObj setEmptyScreenDetailWithTitle:NSLocalizedString(@"Your future Crush will show here", nil) sellingMessage:NSLocalizedString(@"Crushes can be sent only to the ones you really like. Match with the ones you like back.",nil) actionButtonTitle:NSLocalizedString(@"", @"") showBoostIcon:[BoostModel sharedInstance].currentlyActive isUserMale:[APP_Utilities isGenderMale:DiscoverProfileCollection.sharedInstance.myProfileData.gender]];
            [meSectionEmptyViewObj showActionButtonWithShowActionButton:FALSE];
        }
    }
    
}


-(void)setDataOnNavBar{
    [self.navigationController setNavigationBarHidden:YES];
    CGFloat safeAreaTop = [[Utilities sharedUtility] getSafeAreaForTop:true andBottom:false];
    UIView *viewTop = [[UIView alloc]init];
    (IS_IPHONE_X || IS_IPHONE_XS_MAX) ? (viewTop.frame = CGRectMake(0, 0, SCREEN_WIDTH, 64)) : (viewTop.frame = CGRectMake(0, 0 + safeAreaTop, SCREEN_WIDTH, 64));
    [viewTop setBackgroundColor:[UIColor colorWithRed:117.0f/255.0f green:196.0f/255.0f blue:219.0f/255.0f alpha:1.0]];
    [self.view addSubview:viewTop];
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack addTarget:self action:@selector(backBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [btnBack setImage:[UIImage imageNamed:@"ic_arrow_back"] forState:UIControlStateNormal];
    [btnBack setFrame: CGRectMake(0, 24, 40, 40)];
    [viewTop addSubview:btnBack];
    
    UILabel *lblCrush = [[UILabel alloc] initWithFrame:CGRectMake(50, 32, (SCREEN_WIDTH - 100), 24)];
    [lblCrush setText:NSLocalizedString(@"Crush Received", @"Crush Received")];
    [lblCrush setTextColor:[UIColor whiteColor]];
    [lblCrush setFont:[UIFont fontWithName:@"Lato-Medium" size:17.0f]];
    [lblCrush setTextAlignment:NSTextAlignmentCenter];
    [viewTop addSubview:lblCrush];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    //return 2;
    
    if ([_dictCrushData.allKeys count] > 0)
        return self.totalSectionArray.count;
    else
        return 0;

}

#pragma mark - TableView DataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    if (section == 0)
//        return [crushesDataArray count];
//    else
//        return [crushesDataArrayWhileBoosted count];

    if ([_dictCrushData.allKeys count] > 0){
        
        
        int sectionInReverse = (int)_totalSectionArray.count - ((int)section + 1);

        NSString *sectionKey = [_totalSectionArray objectAtIndex:sectionInReverse];

//        NSString *sectionKey = [_totalSectionArray objectAtIndex:section];
        NSArray *arrCount = [_dictCrushData objectForKey:sectionKey];
        return [arrCount count];
    }
    
    return 0;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CrushesDashboard *tempObj = nil;


    int indexValue = (int)_totalSectionArray.count - ((int)indexPath.section + 1);
    tempObj = [[_dictCrushData objectForKey:[_totalSectionArray objectAtIndex:indexValue]] objectAtIndex:indexPath.row];

   // tempObj = [[_dictCrushData objectForKey:[_totalSectionArray objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    
        CGFloat height = 0.0f;
        if (tempObj) {
            height = [APP_Utilities getHeightForText:tempObj.crushMessage forFont:[UIFont fontWithName:@"Lato-Bold" size:16] widthOfLabel:(SCREEN_WIDTH-70)];
        }
        height = height + 110;
        return height;
    
  //  return 120;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
  return 50;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *viewHeader = nil;
    
    CrushesDashboard *crush = nil;
    
    
    int sectionInReverseOrder = (int)_totalSectionArray.count - ((int)section + 1);
   
    NSString *strKey = [_totalSectionArray objectAtIndex:sectionInReverseOrder];
    
    NSArray *arrCrush = [_dictCrushData objectForKey:strKey];
    if ([arrCrush count] > 0) {
        crush = [arrCrush objectAtIndex:0];
    }
    
    if ([crush.isActorBoosted boolValue]) { // While Boosted
        
        viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
        [viewHeader setBackgroundColor:[UIColorHelper colorWithRGBA:@"#F6F6F6"]];
        
        // Adding image
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 20, 24, 24)];
        [imgView setImage:[UIImage imageNamed:@"ic_me_boost_red"]];
        [viewHeader addSubview:imgView];
        
        // Adding While Boosted Label
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frame.origin.x + imgView.frame.size.width + 5, 15, 280, 30)];
        [lbl setTextColor:[UIColorHelper colorFromRGB:@"#909090" withAlpha:1.0]];
        [lbl setText:NSLocalizedString(@"Crush(s) received while boosted.", @"Crush(s) received while boosted.")];
        [lbl setFont:[UIFont fontWithName:@"Lato-Regular" size:14.0f]];
        [viewHeader addSubview:lbl];
        

    }else{ // While non
        
        viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
        [viewHeader setBackgroundColor:[UIColorHelper colorWithRGBA:@"#F6F6F6"]];
        
        // Adding image
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 20, 24, 24)];
        [imgView setImage:[UIImage imageNamed:@""]];
        [viewHeader addSubview:imgView];
        
        // Adding While Boosted Label
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frame.origin.x + imgView.frame.size.width + 5, 20, 280, 30)];
        [lbl setTextColor:[UIColorHelper colorFromRGB:@"#909090" withAlpha:1.0]];
        [lbl setText:NSLocalizedString(@"Crushes received, like back to chat.", @"Crushes received, like back to chat.")];
        [lbl setFont:[UIFont fontWithName:@"Lato-Regular" size:14.0f]];
        [viewHeader addSubview:lbl];

        
    }
     return viewHeader;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString *CellIdentifier = @"CrushCell";
    CrushCell *cell = (CrushCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell){
        cell = [[CrushCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell.contentView setBackgroundColor:[UIColorHelper colorWithRGBA:@"#F6F6F6"]];
    [cell setBackgroundColor:[UIColorHelper colorWithRGBA:@"#F6F6F6"]];
    NSLog(@"INDEX PATH ROW = %ld",(long)indexPath.row);

    if (!_totalSectionArray || _totalSectionArray.count <=0) {
        return cell;
    }
    int sectionInReverseOrder = (int)_totalSectionArray.count - ((int)indexPath.section + 1);

    CrushesDashboard *crushDetail = [[_dictCrushData objectForKey:[_totalSectionArray objectAtIndex:sectionInReverseOrder]] objectAtIndex:indexPath.row];

    [cell setDataOnCellFromObj:crushDetail];
    
    if (crushDetail.userID != nil && ![viewedCrushProfileIdArray containsObject:crushDetail.userID]) {
        [viewedCrushProfileIdArray addObject:crushDetail.userID];
    }
    
    [cell setCrushCellButtonTappedDelegate:self];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![APP_Utilities reachable]){
        
        [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];

        return;
    }

    // Swrve Event
    [APP_DELEGATE sendSwrveEventWithEvent:@"3-MeSection.Me_CrushSection.MCS_UserTile_Tap" andScreen:@"Me_CrushSection"];

    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"CrushDashBoard.Profile" forScreenName:@"CrushDashBoard"];
    currentlySelectedSection = (int)indexPath.section;

    int sectionInReverseOrder = (int)_totalSectionArray.count - ((int)indexPath.section + 1);
    CrushesDashboard *crush = [[_dictCrushData objectForKey:[_totalSectionArray objectAtIndex:sectionInReverseOrder]] objectAtIndex:indexPath.row];
    [self viewProfileTapped:crush withIsBoosted:[crush.isActorBoosted boolValue]];
    
   }

#pragma mark - CrushCellButtonTappedDelegate methods

- (void)likeButtonTappedWithCrushValue:(CrushesDashboard *)crushValue
{
    isLikeCallOnGoing = false;
    crushText = crushValue.crushMessage;
    currentlySelectedProfile = crushValue;
  
    [[Utilities sharedUtility] sendFirebaseEventWithScreenName:@"" withEventName:@"MS_Crush_Like"];
    [self likeUser:^(BOOL isCompleted) {
        [self likePassCallBack:crushValue withIsBoosted:FALSE];
    }];
    /*
    ProfileCardModel *fetchedProfile = [[DiscoverProfileCollection sharedInstance] getProfileCardForWooID:[crushValue userID]];
    
    if (fetchedProfile.wooId == nil)
    {
        activityIndicatorView.hidden = FALSE;
        [self.view bringSubviewToFront:activityIndicatorView];
        
        [self performSelector:@selector(addingWooLoader) withObject:nil afterDelay:0.1];
        
        [ProfileAPIClass fetchDataForUserWithUserID:[[crushValue userID] longLongValue]withCompletionBlock:^(id response, BOOL success, int statusCode) {
            
            self->activityIndicatorView.hidden = TRUE;
            
            if (statusCode == 401) {
                [self handleErrorForResponseCode:401];
                return ;
            }
            
            if (statusCode == 0) {
                
                [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];
                
                return;
                
            }
            
            if (success) {
                self->profileCardModel = [[ProfileCardModel alloc] initWithUserInfoDto:response wooId:[crushValue userID]];
                [[Utilities sharedUtility] sendFirebaseEventWithScreenName:@"" withEventName:@"MS_Crush_Like"];
                [self likeUser:^(BOOL isCompleted) {
                    [self likePassCallBack:crushValue withIsBoosted:FALSE];
                }];
            }
        }];
    }
    else{
        profileCardModel = fetchedProfile;
        
        
    }
     */
}

- (void)dislikeButtonTappedWithCrushValue:(CrushesDashboard *)crushValue
{
    isLikeCallOnGoing = false;
    crushText = crushValue.crushMessage;
    currentlySelectedProfile = crushValue;
    
    [[Utilities sharedUtility] sendFirebaseEventWithScreenName:@"" withEventName:@"MS_Crush_Skip"];
    [self dislikeUser:^(BOOL isCompleted) {
        [self likePassCallBack:crushValue withIsBoosted:FALSE];
    }];
    /*
    ProfileCardModel *fetchedProfile = [[DiscoverProfileCollection sharedInstance] getProfileCardForWooID:[crushValue userID]];
    
    if (fetchedProfile.wooId == nil)
    {
        activityIndicatorView.hidden = FALSE;
        [self.view bringSubviewToFront:activityIndicatorView];
        
        [self performSelector:@selector(addingWooLoader) withObject:nil afterDelay:0.1];
        
        [ProfileAPIClass fetchDataForUserWithUserID:[[crushValue userID] longLongValue]withCompletionBlock:^(id response, BOOL success, int statusCode) {
            
            self->activityIndicatorView.hidden = TRUE;
            
            if (statusCode == 401) {
                [self handleErrorForResponseCode:401];
                return ;
            }
            
            if (statusCode == 0) {
                
                [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];
                
                return;
                
            }
            
            if (success) {
                self->profileCardModel = [[ProfileCardModel alloc] initWithUserInfoDto:response wooId:[crushValue userID]];
                [[Utilities sharedUtility] sendFirebaseEventWithScreenName:@"" withEventName:@"MS_Crush_Skip"];
                [self dislikeUser:^(BOOL isCompleted) {
                    [self likePassCallBack:crushValue withIsBoosted:FALSE];
                }];
            }
        }];
    }
    else{
        profileCardModel = fetchedProfile;
        
        
    }
     */
}

#pragma mark - Adding Woo Loader
- (void)addingWooLoader{
    
    WooLoader  *customLoader = [[WooLoader alloc]initWithFrame:activityIndicatorView.frame];
    
    [customLoader startAnimationOnView:activityIndicatorView WithBackGround:NO];
    
}



-(void)viewProfileTapped:(CrushesDashboard *)data withIsBoosted:(BOOL)isBoosted{
    
    currentlySelectedProfile = data;
    
    ProfileCardModel *fetchedProfile = [[DiscoverProfileCollection sharedInstance] getProfileCardForWooID:[data userID]];
    
    if (fetchedProfile.wooId == nil) {
        activityIndicatorView.hidden = FALSE;
        [self.view bringSubviewToFront:activityIndicatorView];
        
        [self performSelector:@selector(addingWooLoader) withObject:nil afterDelay:0.1];

        [ProfileAPIClass fetchDataForUserWithUserID:[[data userID] longLongValue]withCompletionBlock:^(id response, BOOL success, int statusCode) {
            
            self->activityIndicatorView.hidden = TRUE;
            
            if (statusCode == 401) {
                [self handleErrorForResponseCode:401];
                return ;
            }
            
            if (statusCode == 0) {
                
                [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];
                
                return;
                
            }
            
            if (success) {
                
                [CrushesDashboard markCrushAsRead:data withCompletionHandler:^(BOOL isUpdationCompleted) {
                    [self->crushesTableView reloadData];
                    if ([response isKindOfClass:[NSDictionary class]]) {
                        self->profileCardModel = [[ProfileCardModel alloc] initWithUserInfoDto:response wooId:[data userID]];
                        [[DiscoverProfileCollection sharedInstance] addProfileCard:self->profileCardModel];
                        [self performSegueWithIdentifier:kPushFromCrushToDetailProfileView sender:nil];
                    }
                }];
                
            }
        }];
    }
    else{
        profileCardModel = fetchedProfile;
        [self performSegueWithIdentifier:kPushFromCrushToDetailProfileView sender:nil];
    }
}


- (void)likePassCallBack:(CrushesDashboard *)crushObj withIsBoosted:(BOOL)isBoosted{
    [APP_Utilities deleteMatchUserFromAppExceptMatchBox:crushObj.userID shouldDeleteFromAnswer:YES withCompletionHandler:^(BOOL isDeletionCompleted) {
            //// BHAI EK LINE HAI CODE KI UNCOMMENTED
            /**********************************/
                [self updateDataOnViewFromDB];
            /**********************************/
    }];
}

-(void)addEmptyScreenUserImageView{
    if (!matchedUserViewObj) {
        NSString *rightUserImage = @"";
        if (DiscoverProfileCollection.sharedInstance.myProfileData != nil) {
            if ((DiscoverProfileCollection.sharedInstance.myProfileData.wooAlbum != nil) &&
                ([DiscoverProfileCollection.sharedInstance.myProfileData.wooAlbum count] > 0)) {
                rightUserImage = [NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(kCircularImageSize),IMAGE_SIZE_FOR_POINTS(kCircularImageSize),[APP_Utilities encodeFromPercentEscapeString:DiscoverProfileCollection.sharedInstance.myProfileData.wooAlbum.profilePicUrl]];
            }
        }
        
        matchedUserViewObj = [[MatchedUsersImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 120)];
        matchedUserViewObj.backgroundColor = [UIColor clearColor];
        [matchedUserViewObj setLeftUserImage:@"ic_me_crush_big" getFromUrl:FALSE andRightUserImage:rightUserImage getFromURl:TRUE];
        [emptyScreenUserImageView addSubview:matchedUserViewObj];
    }
 
    
    
}
-(void)createEmptyView{
    if (!meSectionEmptyViewObj) {
        meSectionEmptyViewObj = [[MeSectionEmptyView alloc] initWithFrame:self.view.bounds];
    }
    meSectionEmptyViewObj.backgroundColor = [UIColor clearColor];
    meSectionEmptyViewObj.hidden = TRUE;
    [self.view addSubview:meSectionEmptyViewObj];
    
    __weak CrushPanelViewController *crush = self;
    [meSectionEmptyViewObj setActionBtnTappedBlock:^(BOOL btnTapped){
        [crush btnMoreInfoClicked:nil];
    }];
}



@end
