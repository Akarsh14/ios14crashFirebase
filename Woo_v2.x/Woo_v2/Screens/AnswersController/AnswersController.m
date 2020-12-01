//
//  AnswersController.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 05/07/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "AnswersController.h"
#import "AnswerScreenQuestionCell.h"
#import "MyAnswers.h"
#import "AnswerCell.h"
#import "AnswerExpandedCell.h"
#import "ShowMoreCell.h"
#import "ReportUserView.h"
#import "ToastTypeInfoView.h"
#import "WooHooOverlay.h"
#import "NewChatViewController.h"


@interface AnswersController ()

@end

@implementation AnswersController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    isContentOffsetIsSet = FALSE;
    self.automaticallyAdjustsScrollViewInsets = NO;

}
-(void)updateSelfView{
    [self fetchAllAnswersForQuestionID:[_questionObj.qid longLongValue]];
}


-(void)dimissTheScreen{
    
    [self.navigationController popToRootViewControllerAnimated:NO];
//    [self dismissViewControllerAnimated:NO completion:nil];
}
-(void)removeViewOnTappingNewNotification{
    [self backButtonTapped:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSelfView) name:kAnswersFetched object:nil];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIEdgeInsets inset = UIEdgeInsetsMake(64, 0, 0, 0);
    currentSelectedCell = 0;
    [self createNavigationBarTitleView];
    [self fetchAllAnswersForQuestionID:[_questionObj.qid longLongValue]];

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAnswersFetched object:nil];
}
-(void)createNavigationBarTitleView{
    
    if (self.navigationItem.titleView) {
        [self.navigationItem.titleView removeFromSuperview];
    }
    
    UILabel *navBarLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
    NSLog(@"class of quesiton room :%@",[_questionObj class]);
    NSLog(@"total qid :%@",_questionObj.qid);
    NSLog(@"total ANswer :%@",_questionObj.totalAnswers);
    NSLog(@"total unread :%@",_questionObj.totalUnreadAnswers);
    
    NSLog(@"questionText :%@",_questionObj.questionText);
    NSLog(@"lastUpdateTime :%@",_questionObj.lastUpdateTime);
    navBarLabel.text =[NSString stringWithFormat:@"%@(%d)", NSLocalizedString(@"Answers", nil),[_questionObj.totalAnswers intValue]];
    navBarLabel.textColor = kHeaderTextRedColor;
    [navBarLabel setFont:kHeaderTextFont];
    [navBarLabel setBackgroundColor:[UIColor clearColor]];
    [navBarLabel sizeToFit];
    [self.navigationItem setTitleView:navBarLabel];
}


-(void)checkIfTheirArePendingReplies{
    
    pendingReplies = 0;
    int answersCount = (int)[answersArray count];
    pendingReplies = [_questionObj.totalAnswers intValue] - answersCount;
    
}

-(void)fetchAllAnswersForQuestionID:(long long int)questionID{
    
    if (questionID > 0) {
        if (!answersArray) {
            answersArray = [[NSMutableArray alloc]init];
        }
    }
    [answersArray removeAllObjects];
    
    answersArray = [[MyAnswers getAllAnswerForQuestionWithQuestionID:questionID] mutableCopy];
    
    [self checkIfTheirArePendingReplies];
    [answersTableView reloadData];
    if ([answersArray count]>0) {
       answersTableView.tableFooterView = nil;
    }
    else{
        if (pendingReplies>0) {
            answersTableView.tableFooterView = nil;
        }
        else{
        UILabel *noAnswerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, answersTableView.frame.size.width, 30)];
        noAnswerLabel.text = NSLocalizedString(@"No answers yet?", nil);
        noAnswerLabel.textColor = [UIColor lightGrayColor];
        noAnswerLabel.textAlignment = NSTextAlignmentCenter;
        answersTableView.tableFooterView = noAnswerLabel;
        }
        
    }
    [self createNavigationBarTitleView];
}



// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqual:kPushToProfileFromAnswerSegue]) {
        NSLog(@"sender %@",sender);

    }
    
}

- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    // #TO_BE_ENCODED
    if (indexPath.row == 0) {
        CGFloat labelHeight = [APP_Utilities getHeightForText:[NSString stringWithFormat:@"Q. %@",[_questionObj.questionText stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] forFont:kButtonFont widthOfLabel:(SCREEN_WIDTH-70)];
        
        if ((labelHeight + 42.0f)< 85) {
            return 85;  //initially 70, 15 added for time stamp
        }else{
            return (labelHeight + 42.0f); //initially 27, 15 added for time stamp
        }
    }else{
        
        if (currentSelectedCell == indexPath.row) {
            
            
            if (indexPath.row == [answersArray count] + 2) {
                return 60;
            }
            
            MyAnswers *answerObj = [answersArray objectAtIndex:(indexPath.row -1)];
            // #TO_BE_ENCODED
            CGFloat labelHeight = [APP_Utilities getHeightForText:[answerObj.answerDescription stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forFont:kButtonFont widthOfLabel:(SCREEN_WIDTH-130)];
            
            if (labelHeight <=34 ) {
                
                return 144;
                
            }else{
                
                return labelHeight+130;
                
            }
        }else{
            
            return 82;
            
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (answersArray) {
        if (pendingReplies > 0) {
            return [answersArray count] + 2;
        }
        return [answersArray count] + 1;
    }
    else if (pendingReplies > 0){
        return 2;
    }
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ((indexPath.row == ([answersArray count] + 1)) && pendingReplies) {
        
        static NSString *cellIdentifier = @"ShowMoreCell";
        ShowMoreCell *cell = [answersTableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (!cell){
            cell = (ShowMoreCell *)[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellIdentifier];
        }
        cell.tag = 999;
        
        [cell setDataOnShowMoreCellWithPendingReplies:pendingReplies];
        
        return cell;
    }else if (indexPath.row == 0) {
        static NSString *cellIdentifier = @"AnswerScreenQuestionCell";
        AnswerScreenQuestionCell *cell = [answersTableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (!cell){
            cell = (AnswerScreenQuestionCell *)[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellIdentifier];
        }
        // #TO_BE_ENCODED
        [cell setQuestionOnCellWithQuestionText:[_questionObj.questionText stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        if (_questionObj.questionCreatedTime) {
            [cell setTimestampOnCellWithTimestamp:_questionObj.questionCreatedTime];
        }
        
        
        return cell;
    }else{
        
        if (currentSelectedCell == indexPath.row) {
            
            static NSString *cellIdentifier = @"AnswerExpandedCell";
            AnswerExpandedCell *cell = [answersTableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if (!cell){
                cell = (AnswerExpandedCell *)[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellIdentifier];
            }
            [cell setDataOnCellFromAnswerObject:[answersArray objectAtIndex:(indexPath.row -1)]];
            
            [cell setDelegate:self];
            [cell setSelectorForImageTapped:@selector(PushToProfileForImage:)];
            [cell setSelectorForDeleteTapped:@selector(deleteAnswerForAnswer:)];
            [cell setSelectorForLikeTapped:@selector(likeUserForAnswer:)];
            [cell setSelectorForReportTapped:@selector(reportUserForAnswer:)];
            
            return cell;
        }else{
            
            static NSString *cellIdentifier = @"AnswerCell";
            AnswerCell *cell = [answersTableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if (!cell){
                cell = (AnswerCell *)[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellIdentifier];
            }
            
            [cell setDataOnCellFromAnswerObject:[answersArray objectAtIndex:(indexPath.row -1)]];
            [cell setDelegate:self];
            [cell setSelectorForImageTapped:@selector(PushToProfileForImage:)];
            return cell;
        }
    }
    
    return nil;
}



-(void)PushToProfileForImage:(id)sender{
    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"ViewProfile" forScreenName:@"Answers"];
    [self performSegueWithIdentifier:kPushToProfileFromAnswerSegue sender:sender];
}

-(void)deleteAnswerForAnswer:(MyAnswers * )answerObj{
    
    U2AlertView *alert = [[U2AlertView alloc] init];
    
    [alert setU2AlertActionBlockForButton:^(int tagValue , id data){
        NSLog(@"%d",tagValue);
        
        if (tagValue == 1) {
            [self deleteConfirmationCallback:data];
        }
    }];
    
    [alert setContainerData:answerObj];
    
    [alert alertWithHeaderText:NSLocalizedString(@"Delete?",nil) description:NSLocalizedString(@"\nNot crazy about this answer?\n", nil) leftButtonText:NSLocalizedString(@"No", nil) andRightButtonText:NSLocalizedString(@"Yes", nil)];
    [alert show];
    
}


#pragma mark - Delete Confirmation Callback
-(void)deleteConfirmationCallback:(id)answerData{
 
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    BOOL isNetworkReachable = (reachability.isReachable || reachability.isReachableViaWiFi || reachability.isReachableViaWWAN);
    if (!isNetworkReachable) {
        SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"Please check your internet connection",nil));
        return;
    }
    
    
    [APP_DELEGATE sendSwrveEventWithEvent:@"Answers.DeleteAnswer" andScreen:@"Answers"];
    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"DeleteAnswer" forScreenName:@"Answer"];
    
    MyAnswers *answerObj = (MyAnswers *)answerData;

    if (!answerObj.isRead) {
        [MyQuestions decrementUnreadAnswersForQuestionWithQuestionID:[answerObj.questionId longLongValue] by:1 withCompletionHandler:^(BOOL isCompleted) {
            [self deleteConfirmationBlockWithAnswer:answerObj];
        }] ;
    }
}

-(void)deleteConfirmationBlockWithAnswer:(MyAnswers*)answerObj{
  
    currentSelectedCell = 0;
    
    [MyQuestions decrementTotalAnswersForQuestionID:[answerObj.questionId longLongValue] by:1 withCompletionHandler:^(BOOL isCompleted) {
        
        [MyAnswers deleteAnswerByAnswerId:[answerObj.answerId longLongValue] withCompletionHandler:^(BOOL isDeletionCompleted) {
            
            [self fetchAllAnswersForQuestionID:[_questionObj.qid longLongValue]];
            
        }];
        
    }];
}



-(void)reportUserForAnswer:(MyAnswers *)answerObj{
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        UIAlertController *reportAlertcontroller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction *action) {
                                                             }];
        UIAlertAction *reportAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Report as inappropriate", nil)
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *action) {
                                                                 [self showReportView];
                                                             }];
        
        [reportAlertcontroller addAction:cancelAction];
        [reportAlertcontroller addAction:reportAction];
        
        [reportAlertcontroller.view setTintColor:kHeaderTextRedColor];
        [self presentViewController:reportAlertcontroller animated:YES completion:^{
            [reportAlertcontroller.view setTintColor:kHeaderTextRedColor];
        }];
        
    }else{
        UIActionSheet *reportActionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Report as inappropriate", nil), nil];
        
        [reportActionSheet showInView:self.view];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [self showReportView];
    }
}



-(void)showReportView{
    
    ReportUserView *reportView = [[ReportUserView alloc]initWithFrame:self.view.frame];
    [reportView setDelegate: self];
    [reportView setReportViewType:reportUser];
    [reportView setHeaderForReportViewType:reportUser];
    [reportView setReportingUserFromAnswer:YES];
    [reportView setReportedViewController:self];
    [reportView setSelectorForUserFlagged:@selector(userReportedSuccessfully)];
    [reportView setAnswerObj:[answersArray objectAtIndex:(currentSelectedCell-1)]];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        [APP_DELEGATE.window.rootViewController.view addSubview:reportView];
    }
    else{
        [APP_DELEGATE.window addSubview:reportView];
    }
}

-(void)userReportedSuccessfully{
    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"ReportAnswer" forScreenName:@"Answer"];
    currentSelectedCell = 0;
    
    [self fetchAllAnswersForQuestionID:[_questionObj.qid longLongValue]];
    [self createNavigationBarTitleView];
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserSuccessfullyReported object:nil];
}

-(void)showUserReportedAnimation{
    
    ToastTypeInfoView *toastObj = [[ToastTypeInfoView alloc]initWithFrame:self.view.frame];
    [toastObj setTextOnView:NSLocalizedString(@"User Reported!", nil) withImage:[UIImage imageNamed:@"userReported"]];
    [toastObj presentViewDuration:2.5f onView:APP_DELEGATE.window.rootViewController.view];
    [self backButtonTapped:nil];
}


-(void)likeUserForAnswer:(MyAnswers *)answerObj{
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kIsFirstTimeLikeANswerButtonAlertShown]) {
        U2AlertView *alert = [[U2AlertView alloc] init];
        
        [alert setU2AlertActionBlockForButton:^(int tagValue , id data){
            NSLog(@"%d",tagValue);
            
            if (tagValue == 1) {
                [self matchConfirmationCallback:data];
            }
            
        }];
        
        [alert setContainerData:answerObj];
        
        [alert alertWithHeaderText:@"nil" description:NSLocalizedString(@"Like the answer to carry the conversation forward.", nil) leftButtonText:NSLocalizedString(@"Cancel", nil) andRightButtonText:NSLocalizedString(@"Continue", nil)];
        [alert show];
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kIsFirstTimeLikeANswerButtonAlertShown];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else{
        [self matchConfirmationCallback:answerObj];
    }
    
    
    
}

#pragma mark - Match Confirmation Callback
-(void)matchConfirmationCallback:(MyAnswers *)answerObj{

    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    BOOL isNetworkReachable = (reachability.isReachable || reachability.isReachableViaWiFi || reachability.isReachableViaWWAN);
    if (!isNetworkReachable) {
        SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"Please check your internet connection",nil));
        return;
    }
    
    [APP_DELEGATE sendSwrveEventWithEvent:@"Answers.LikeAnswer" andScreen:@"Answers"];
    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"LikeAnswer" forScreenName:@"Answer"];
    NSString *likeAnswerURL = [NSString stringWithFormat:@"%@/answers/%@/activity?wooId=%@&readActivity=%@&status=%@",kBaseURLV3,answerObj.answerId,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],@"1",@"1"];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =likeAnswerURL;
    wooRequestObj.time =0;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = likeOrDislikeAProfile;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {

        if (statusCode==200) {
            // save data in local database
            [APP_DELEGATE makeAppsflyerFirstMatchCall];
            
            if ([response objectForKey:@"matchEventDto"]) {
                
                if (![MyMatches getMatchDetailForMatchID:[[response objectForKey:@"matchEventDto"] objectForKey:kMatchIDKey]]) {
                    
                    [MyMatches insertDataInMyMatchesFromArray:[NSArray arrayWithObjects:[response objectForKey:@"matchEventDto"], nil] withChatInsertionSuccess:^(BOOL insertionSuccess) {
                        if(insertionSuccess){
                           [self showWooHooOverlayForData:[response objectForKey:@"matchEventDto"]];
                        }
                    }];
                    
                }
            }
            
            [APP_Utilities deleteMatchUserFromAppExceptMatchBox:[NSString stringWithFormat:@"%lld",[answerObj.wooId longLongValue]] shouldDeleteFromAnswer:YES withCompletionHandler:^(BOOL isDeletionCompleted) {

                [MyQuestions decrementTotalAnswersForQuestionID:[answerObj.questionId longLongValue] by:1 withCompletionHandler:^(BOOL isCompleted) {
                    
                    currentSelectedCell = 0;
                    
                    [self fetchAllAnswersForQuestionID:[_questionObj.qid longLongValue]];
                    
                }];
            }];
       
        }
    } shouldReachServerThroughQueue:TRUE];

    currentSelectedCell = 0;
}


-(void)showWooHooOverlayForData:(NSDictionary *)matchResponse{
    WooHooOverlay *overlayObj = [[WooHooOverlay alloc]initWithFrame:self.view.frame];
    
    [overlayObj setDelegate:self];
    [overlayObj setMatchId:[matchResponse objectForKey:kMatchIDKey]];
    [overlayObj setSelectorForOverlayRemoved:@selector(pushToChatViewForMAtchID:)];
    
    NSDictionary *matchDataDictionary = [matchResponse mutableCopy];
    
    NSURL *imageURL;
    
    NSString *targetId = ([[matchDataDictionary objectForKey:kMatchedUserIDKey] isKindOfClass:[NSString class]]?[matchDataDictionary objectForKey:kMatchedUserIDKey]:[NSString stringWithFormat:@"%@",[matchDataDictionary objectForKey:kMatchedUserIDKey]]);
    
    int connectionTime = 10;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kWaitTimeChatStart]) {
        connectionTime = [[[NSUserDefaults standardUserDefaults] objectForKey:kWaitTimeChatStart] intValue];
    }
    
    if ([targetId isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]]) {
        
        imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[matchDataDictionary objectForKey:kRequesterUserPicURLKey]]];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
            [overlayObj presentViewWithImageURL:imageURL timerForConnection:connectionTime nameOfUser:[matchDataDictionary objectForKey:kRequesterNameKey] andTeaserLine:[matchDataDictionary objectForKey:kMatchUserIntroKey] forPresentingView:APP_DELEGATE.window.rootViewController.view];
        }
        else{
            [overlayObj presentViewWithImageURL:imageURL timerForConnection:connectionTime nameOfUser:[matchDataDictionary objectForKey:kRequesterNameKey] andTeaserLine:[matchDataDictionary objectForKey:kMatchUserIntroKey] forPresentingView:APP_DELEGATE.window];
        }
    }
    else{
        imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[matchDataDictionary objectForKey:kMatchUserPicURLKey]]];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
            [overlayObj presentViewWithImageURL:imageURL timerForConnection:connectionTime nameOfUser:[matchDataDictionary objectForKey:kMatchNameKey] andTeaserLine:[matchDataDictionary objectForKey:kMatchUserIntroKey] forPresentingView:APP_DELEGATE.window.rootViewController.view];
        }
        else{
            [overlayObj presentViewWithImageURL:imageURL timerForConnection:connectionTime nameOfUser:[matchDataDictionary objectForKey:kMatchNameKey] andTeaserLine:[matchDataDictionary objectForKey:kMatchUserIntroKey] forPresentingView:APP_DELEGATE.window];
        }
    }
}

-(void)pushToChatViewForMAtchID:(NSString *)matchId{
    NSLog(@"match id :%@",matchId);
    MyMatches *myMatchObj = [MyMatches getMatchDetailForMatchID:matchId];
    NewChatViewController *newChatViewControllerObj = [self.storyboard instantiateViewControllerWithIdentifier:@"NewChatViewController"];
    newChatViewControllerObj.parentView = DetailProfileViewParentAnswers;
    if (myMatchObj) {
        [newChatViewControllerObj setMyMatchesData:myMatchObj];
        [self.navigationController pushViewController:newChatViewControllerObj animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    int tagValue = (int)cell.tag;

    if (indexPath.row == currentSelectedCell && tagValue != 999) {
        currentSelectedCell = 0;
        [answersTableView reloadData];
    }else{
        
        AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
        BOOL isNetworkReachable = (reachability.isReachable || reachability.isReachableViaWiFi || reachability.isReachableViaWWAN);
        if (!isNetworkReachable) {
            SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"Please check your internet connection",nil));
            return;
        }

        [APP_DELEGATE sendSwrveEventWithEvent:@"Answers.TapAnswer" andScreen:@"Answers"];
        [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"TapAnswer" forScreenName:@"Answer"];
        currentSelectedCell = (int)indexPath.row;
                
        if (indexPath.row > 0 && indexPath.row <= [answersArray count]) {
            MyAnswers *answerObj = [answersArray objectAtIndex:(indexPath.row-1)];
            
            if ([answerObj.isRead boolValue]) {
                [self fetchAllAnswersForQuestionID:[_questionObj.qid longLongValue]];
                return;
            }
            
            NSString *readAnswerURL = [NSString stringWithFormat:@"%@%@%lld/activity?readActivity=1&wooId=%lld",kBaseURLV1,kAnswers,[answerObj.answerId longLongValue],[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue]];
            
            WooRequest *wooRequestObj = [[WooRequest alloc]init];
            wooRequestObj.url =readAnswerURL;
            wooRequestObj.time =0;
            wooRequestObj.requestParams =nil;
            wooRequestObj.methodType = postRequest;
            wooRequestObj.numberOfRetries =3;
            wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
            wooRequestObj.requestType = markAnswerAsRead;
            
            [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
                
                if (success && requestType == markAnswerAsRead) {
                    
                }
            } shouldReachServerThroughQueue:TRUE];
            

            [MyQuestions decrementUnreadAnswersForQuestionWithQuestionID:[answerObj.questionId longLongValue] by:1 withCompletionHandler:^(BOOL isCompleted) {
                
                [MyAnswers markAnswerAsReadWithAnswerID:[answerObj.answerId longLongValue] withCompletionHandler:^(BOOL isCompleted) {
                    
                    [self fetchAllAnswersForQuestionID:[_questionObj.qid longLongValue]];
                    
                }];
                
            }];
            
        }else if (indexPath.row == ([answersArray count]+1)){
            currentSelectedCell = 0;
            [self fetchOldHistoricalAnswer];
        }
    }
}

-(void)fetchOldHistoricalAnswer{
    
    
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    BOOL isNetworkReachable = (reachability.isReachable || reachability.isReachableViaWiFi || reachability.isReachableViaWWAN);
    if (!isNetworkReachable) {
        SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"Please check your internet connection",nil));
        return;
    }


    MyAnswers *oldestAnswer = [MyAnswers getOldestAnswerTimestampForQuestion:[_questionObj.qid longLongValue]];
    
    
    NSString *fetchAnswersURL = [NSString stringWithFormat:@"%@%@%lld?wooId=%lld&createdTime=%lld",kBaseURLV1,kAnswers,[_questionObj.qid longLongValue],[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue], ((long long)[oldestAnswer.createdTime timeIntervalSince1970]*1000)];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =fetchAnswersURL;
    wooRequestObj.time =0;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType = getRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = fetchOlderAnswers;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        if (success && requestType == fetchOlderAnswers) {
            
            [MyAnswers insertOrUpdateAnswersFromAnswerArray:[response objectForKey:@"listAnswerDto"] isFetchingNewAnswers:FALSE withCompletionHandler:^(BOOL isInsertionCompleted) {
                
                [self fetchAllAnswersForQuestionID:[_questionObj.qid longLongValue]];
                
            }];
        }
    } shouldReachServerThroughQueue:TRUE];

}
@end
