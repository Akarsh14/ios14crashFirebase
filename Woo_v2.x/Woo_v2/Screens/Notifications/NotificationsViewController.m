//
//  NotificationsViewController.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 29/05/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "NotificationsViewController.h"
#import "NotificationCell.h"
#import "NewChatViewController.h"


@interface NotificationsViewController ()

@end

@implementation NotificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self fetchNotifications];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationsFetchedSuccessfully object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(populateNotificationDataAndReload) name:kNotificationsFetchedSuccessfully object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPushToChatScreen object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushToChatScreenForMatchId:) name:kOpenChatRoomFromTopNotification object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dimissTheScreen) name:kDismissTheScreenNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChatsTapped object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dimissTheScreen) name:kChatsTapped object:nil];
    
}

-(void)dimissTheScreen{
    
    //    [self.navigationController popToRootViewControllerAnimated:NO];
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)pushToChatScreenForMatchId:(NSNotification *)notificationObj{
    NSString *matchId = notificationObj.object;
    MyMatches *matchObj = [MyMatches getMatchDetailForMatchID:matchId];
    NewChatViewController *newChatViewControllerObj = [self.storyboard instantiateViewControllerWithIdentifier:@"NewChatViewController"];
    [newChatViewControllerObj setMyMatchesData:matchObj];
    [self.navigationController pushViewController:newChatViewControllerObj animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
    if (SYSTEM_VERSION_EQUAL_TO(@"9.0")) {
        CGRect rect = self.navigationController.navigationBar.frame;
        float y = rect.size.height + rect.origin.y;
        notificationTableView.contentInset = UIEdgeInsetsMake(y ,0,0,0);
    }
    

    UILabel *navBarLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
    navBarLabel.text = NSLocalizedString(@"Notifications", nil);
    navBarLabel.textColor = kHeaderTextRedColor;
    [navBarLabel setFont:kHeaderTextFont];
    [navBarLabel setBackgroundColor:[UIColor clearColor]];
    [navBarLabel sizeToFit];
    [self.navigationItem setTitleView:navBarLabel];

    [self populateNotificationDataAndReload];

    if ([notificationsDataArray count] <1) {
        [self addNoNotificationView];
    }
    
    
    
    
}



-(void)addNoNotificationView{
    
    
    if (noNotifObj) {
        [noNotifObj removeFromSuperview];
    }
    
    noNotifObj = [[NoNotificationView alloc]initWithFrame:self.view.frame];
    [notificationTableView addSubview:noNotifObj];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
//        do nothing
    }];
}

//-(void)fetchNotifications{
//
//    [APP_DELEGATE fetchNewNotifications];
//}


-(void)populateNotificationDataAndReload{
    if (!notificationsDataArray) {
        notificationsDataArray = [[NSMutableArray alloc]init];
    }
    [notificationsDataArray removeAllObjects];
    notificationsDataArray = [APP_DELEGATE.notificationsDataArray mutableCopy];
    [notificationTableView reloadData];
}

#pragma mark - Table View Method
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [notificationsDataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self createCellForData:[notificationsDataArray objectAtIndex:indexPath.row]];
}


-(NotificationCell *)createCellForData:(NSDictionary *)dataDict{
    
    static NSString *CellIdentifier = @"NotificationCell";
    NotificationCell *cell = (NotificationCell *)[notificationTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell){
        cell = [[NotificationCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell setNotificationDataFromDictionary:dataDict];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *selectedNotification = [notificationsDataArray objectAtIndex:indexPath.row];
    U2AlertView *notificationAlert = [[U2AlertView alloc]init];
    
    [self informServerAboutReadingNotification:selectedNotification];
    
    if ([[selectedNotification objectForKey:@"notificationType"] isEqualToString:@"APP"]) {
//        code for opening screen
        
        [notificationAlert setContainerData:selectedNotification];
        
        [notificationAlert setU2AlertActionBlockForButton:^(int tagValue , id data){
            NSLog(@"%d",tagValue);
            
//            if (tagValue == 1){
//                if (data && [data isKindOfClass:[NSDictionary class]])
//                    [self openScreenFromNotificationWithData:data];
//            }
        }];
        
        
        [notificationAlert alertWithHeaderText:NSLocalizedString(@"Woo", nil) description:[selectedNotification objectForKey:@"notificationText"] leftButtonText:NSLocalizedString(@"Cancel", nil) andRightButtonText:NSLocalizedString(@"Open", nil)];
        [notificationAlert show];
        
    }else if ([[selectedNotification objectForKey:@"notificationType"] isEqualToString:@"WEB"]) {

//        code for opening website
        
        [notificationAlert setContainerData:selectedNotification];
        
        [notificationAlert setU2AlertActionBlockForButton:^(int tagValue , id data){
            NSLog(@"%d",tagValue);
            
            if (tagValue == 1){
                if (data && [data isKindOfClass:[NSDictionary class]])
                    [self openURLNotificaionButtonTapped:(NSDictionary *)data];
            }
            
        }];
        
        [notificationAlert alertWithHeaderText:NSLocalizedString(@"Woo", nil) description:[selectedNotification objectForKey:@"notificationText"] leftButtonText:NSLocalizedString(@"Cancel", nil) andRightButtonText:NSLocalizedString(@"Open", nil)];
        [notificationAlert show];
        
    }else{
        
        [notificationAlert setContainerData:selectedNotification];
        [notificationAlert alertWithHeaderText:nil description:[selectedNotification objectForKey:@"notificationText"] leftButtonText:NSLocalizedString(@"CMP00356", nil) andRightButtonText:nil];
        [notificationAlert show];
//        code for just showing the text in alert
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReadByUser object:nil];
}


-(void)informServerAboutReadingNotification:(NSDictionary *)notficationDictionary{
    
    NSMutableArray *allNotificationsArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dict in  APP_DELEGATE.notificationsDataArray) {
        
        if ([notficationDictionary isEqualToDictionary:dict]) {
            
            NSMutableDictionary *tempDict = [dict mutableCopy];
            [tempDict setObject:@"1" forKey:@"read"];
            [allNotificationsArray addObject:tempDict];
        }else{
            [allNotificationsArray addObject:dict];
        }
    }
    
    if (APP_DELEGATE.notificationsDataArray && [APP_DELEGATE.notificationsDataArray count] > 0) {
        
        [APP_DELEGATE.notificationsDataArray removeAllObjects];
        
    }
    
    APP_DELEGATE.notificationsDataArray = allNotificationsArray;
    notificationsDataArray = APP_DELEGATE.notificationsDataArray;
    
    [notificationTableView reloadData];
        
    NSString *notificationURL = [NSString stringWithFormat:@"%@%@/%d/status?isRead=true&wooId=%lld",kBaseURLV1,kCustomNotificationUpdate, [[notficationDictionary objectForKey:@"id"] intValue],[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue]];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =notificationURL;
    wooRequestObj.time =0;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =getRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = updateNotificationStatus;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        if (requestType == updateNotificationStatus && statusCode == 200) {
            
        }
        
    } shouldReachServerThroughQueue:TRUE];
    
    
}


-(void)openURLNotificaionButtonTapped:(NSDictionary *)notificationData{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[notificationData objectForKey:@"redirection"]]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[notificationData objectForKey:@"redirection"]]];
    }
}


//-(void)openScreenFromNotificationWithData:(NSDictionary *)notificationData{
//        
//        if ([APP_Utilities getNotificationTypeFor:[notificationData objectForKey:@"redirection"]] != notifications) {
//            [self dismissViewControllerAnimated:YES completion:nil];
//        }
//        [self performSelector:@selector(raiseScreenChangeNotificationForNotificationType:) withObject:notificationData afterDelay:0.50f];
//    
//}


//-(void)raiseScreenChangeNotificationForNotificationType:(NSDictionary *)notificationData{
//    
//    NotificationType notificationTypeObj = [APP_Utilities getNotificationTypeFor:[notificationData objectForKey:@"redirection"]];
//    
//    switch (notificationTypeObj) {
//        case myProfile: {
//            [[NSNotificationCenter defaultCenter]postNotificationName:kProfileTappedOnLeftPanel object:nil];
//            break;
//        }
//        case discover: {
////            it is aready dismissed
//            break;
//        }
//        case matches: {
//            [[NSNotificationCenter defaultCenter] postNotificationName:kPushToMatchesNotification object:nil];
//            break;
//        }
//        case questions: {
////            
//            break;
//        }
//        case notifications: {
////            we are already on this screen, so do nothing here
//            break;
//        }
//        case inviteFriends: {
////            this flow is not applicable for us
//            break;
//        }
//        case settings: {
//            [[NSNotificationCenter defaultCenter]postNotificationName:kSettingsTappedOnLeftPanel object:nil];
//
//            break;
//        }
//        case purchases: {
//            [[NSNotificationCenter defaultCenter]postNotificationName:kPurchasesTappedOnLeftPanel object:nil];
//            break;
//        }
//        case custom: {
////            <#statement#>
//            break;
//        }
//        case unknown: {
////            <#statement#>
//            break;
//        }
//        default: {
//            break;
//        }
//    }
//}

#pragma mark - Notificaiton Refresh & update methods

@end
