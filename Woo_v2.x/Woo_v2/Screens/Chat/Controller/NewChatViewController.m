//
//  NewChatViewController.m
//  Woo_v2
//
//  Created by Umesh Mishraji on 04/05/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "NewChatViewController.h"
#import "ChatMessage.h"
#import "ChatMessageCell.h"
#import "ChatTimeCell.h"
#import "ChatStickerCell.h"
#import "TypingCell.h"
#import "ToastTypeInfoView.h"
#import "VPImageCropperViewController.h"
#import "ChatImageCell.h"
#import "IQKeyboardManager.h"
#import "ImageGalleryController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MatchedThroughCell.h"
#import "LayerManager.h"
#import "TypingAreaCell.h"
#import "ProfileAPIClass.h"
#import "MatchedUsersImageView.h"
#import "SenderMessageCell.h"
#import "ReceiverMessageCell.h"
#import "CrushMessageCell.h"
#import "AgoraConnectionManager.h"
#import "UIView+SimpleRipple.h"
#import "Applozic.h"
#import "ApplozicChatHelperClass.h"
#import "ApplozicChatManager.h"
// Metadata keys related to navbar color
//static NSString *const LQSBackgroundColorMetadataKey = @"backgroundColor";
//static NSString *const LQSRedBackgroundColorMetadataKeyPath = @"backgroundColor.red";
//static NSString *const LQSBlueBackgroundColorMetadataKeyPath = @"backgroundColor.blue";
//static NSString *const LQSGreenBackgroundColorMetadataKeyPath = @"backgroundColor.green";

@interface NewChatViewController()<ApplozicUpdatesDelegate, applozicInternalDelegates,ChatTextViewDelegate,UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *voiceCallButton;
@property (weak, nonatomic) IBOutlet UIButton *pushToDetailButton;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerTopConstraint;
@property(nonatomic, assign) BOOL isAppLozicUser;
@property(nonatomic, assign) BOOL isUserTyping;
@property (weak, nonatomic) IBOutlet ChatTextView *chatTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatInputAreaHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatInputAreaBottomConstraint;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIView *typingView;
@property (weak, nonatomic) IBOutlet UIView *timestampHeaderView;
@property (weak, nonatomic) IBOutlet UILabel *timestampHeaderLabel;

@end
@implementation NewChatViewController
{
    __weak IBOutlet UIView *rippleOverlayView;
    BOOL isLoggedIntoAgora;
    BOOL hasSeenGlowAnimation;
    BOOL showHeaderTimeStampNow;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    
    // Override point for customization after application launch.
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    showHeaderTimeStampNow = false;
    hasSeenGlowAnimation = NO;
    //applozic
    _isAppLozicUser = ([_myMatchesData.chatServer isEqualToString:kisAppLozicServer]) ? YES : NO;
    [self setupChatTextView];

    //Adding observers removed in dealloc
    // for reloading matchdata and therefore chat view when Matchdata is updated in DPV - viewdidload
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMatchData) name:kMatchDataUpdatedInDPV object:nil];
    // Deletes a match - viewdidload
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(matchDeletedForChatRoomID:) name:kChatRoomDeleted object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];

    //
    [self setupNavigationAndTableViewUI];
    
    //Sets name and image of match on header view
    [self setDataOnHeader];
    
    [_typingView setUserInteractionEnabled:false];
    
    [self checkIfUserIsOnOldChatOrOnLayerAndShowViewAccordingally];
    
    [self setupAgora];
    keyboardHeight = 0;
    
    // initialising char message local modal
    if (!chatMessagesArray) {
        chatMessagesArray = [[NSMutableArray alloc] init];
    }
    //Keeps index count of messages
    currentIndex = 0;
    // entryTimeInChatRoom = [[NSDate date] timeIntervalSince1970]*1000;
    // creationTimeOfMessageWithDeliveredStatusOnLayer = [ChatMessage getTheCreationTimeOfLastDeliveredMessageIfAnyForChatRoom:_myMatchesData.matchedUserId];
    
    //Groups chat messages
    [self returnGroupedChatMessges:[ChatMessage getAllMessageForChatRoom:_myMatchesData.matchId WithLimit:kNumberOfMessageToBeShownAtATime*(1)]];
    [self reloadTableDataForParticularCell:false andScrollToBottom:true andIsMessageAddedOrDeleted:false];
    //    if ([chatArray count] <= 0){
    //        [self returnGroupedChatMessges:[ChatMessage getAllMessageForChatRoom:_myMatchesData.matchedUserId WithLimit:kNumberOfMessageToBeShownAtATime*(1)]];
    //
    //    }
    //Shows load more if more messages available after first fetch
    if ([ChatMessage isMoreDataAvailableForChatRoom:_myMatchesData.matchId WithIndex:currentIndex])
    {
        UIButton *loadMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        loadMoreButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        [loadMoreButton setTitle:NSLocalizedString(@"Load More", nil) forState:UIControlStateNormal];
        [loadMoreButton addTarget:self action:@selector(loadMoreButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        loadMoreButton.titleLabel.font = kVerifyingMessageTextFont;
        
        loadMoreButton.frame = CGRectMake(((SCREEN_WIDTH/2) - 50), 4, 100, 36);
        loadMoreButton.layer.cornerRadius = 3.0;
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
        headerView.backgroundColor = [UIColor clearColor];
        [headerView addSubview:loadMoreButton];
        self.tableView.tableHeaderView = headerView;
    }
    
    // [self.tableView reloadData];
    
    // Looks like dead code - Needs discussion
    //    if (_directMsgStr && [[APP_Utilities validString:_directMsgStr] length]>0) {
    //        [self sendButtonTapped:_directMsgStr];
    //        _directMsgStr = @"";
    //
    
    //Index incremented
    currentIndex++;
    
  
    
    //Added change notif block for any changes that will trigger everytime the user receives any change notification from Layer.
    if (_isAppLozicUser){
        [ApplozicChatManager sharedApplozicChatManager].delegate = self;
        [[ApplozicChatManager sharedApplozicChatManager] setDidChangeApplozicNotificationBlockValue:^(ALMessage *alMessageObj, ChatMessage *messageObj) {
            [self updateTableViewWhenMessageArrivesForNewMessage:YES andOtherUser:alMessageObj.to andchatId:messageObj.layerMessageID];
        }];
    }
//    [[LayerManager sharedLayerManager] setDidChangeNotificationBlockValue:^(BOOL newMsgAvailable, LYRMessage *layerMessageObj) {
//        [self updateTableViewWhenMessageArrivesForNewMessage:newMsgAvailable andOtherUser:layerMessageObj.sender.userID andchatId:layerMessageObj.identifier.lastPathComponent];
//    }];
}

- (void)setupChatTextView{
    _chatTextView.layer.cornerRadius = 17.0;
    _chatTextView.layer.borderWidth = 1.0;
    _chatTextView.layer.borderColor = [UIColorHelper colorFromRGB:@"#DEDEDE" withAlpha:1.0].CGColor;
    [_chatTextView setTextContainerInset:UIEdgeInsetsMake(8, 8, 8, 8)];
    _chatTextView.translatesAutoresizingMaskIntoConstraints = false;
    
    UITapGestureRecognizer *tapgesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler)];
    [self.tableView addGestureRecognizer:tapgesture];
}


- (void)setupAgora{
    //unhide call button if agora is logged in
    if([[AgoraConnectionManager sharedManager] isLogin])
    {
        //Get channel key if empty, so call can be made or received.
        if([self.myMatchesData.agoraChannelKey isEqualToString:@""])
        {
            __weak NewChatViewController *weakSelf = self;
            [self.voiceCallButton setUserInteractionEnabled:NO];
            
            [[AgoraConnectionManager sharedManager] getChannelKeyForMatchId:self.myMatchesData.matchId andCompletionBlock:^(id response, BOOL success) {
                if(success && [response objectForKey:@"agora_channel_key"])
                {
                    // Update in MyMatches
                    [MyMatches updateMatchedUserDetailsForMatchedUserID:self.myMatchesData.matchedUserId withAgoraChannelKey:[response objectForKey:@"agora_channel_key"] withChatUpdationSuccess:^(BOOL isUpdationCompleted)
                     {
                         
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [self.voiceCallButton setHidden:NO];
                             
                             if ([[AppLaunchModel sharedInstance] isCallingEnabled])
                             {
                                 [self.voiceCallButton setSelected:NO];
                                 [self showGlowAnimation];
                             }
                             else
                             {
                                 [self.voiceCallButton setSelected:YES];
                             }
                             
                             
                             weakSelf.myMatchesData = [MyMatches getMatchDetailForMatchedUSerID:self.myMatchesData.matchedUserId isApplozic:false];
                             [weakSelf.voiceCallButton setUserInteractionEnabled:YES];
                         });
                     }];
                }
                else
                {
                    //Error
                }
            }];
        }
        else
        {
            [self.voiceCallButton setHidden:NO];
            if ([[AppLaunchModel sharedInstance] isCallingEnabled])
            {
                [self.voiceCallButton setSelected:NO];
                [self showGlowAnimation];
            }
            else
            {
                [self.voiceCallButton setSelected:YES];
            }
            
            
        }
    }
    else
    {
        [self.voiceCallButton setHidden:YES];
        [[AgoraConnectionManager sharedManager]loginToAgora:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] withCompletionHandler:^(BOOL completed) {
            if (completed){
                dispatch_async(dispatch_get_main_queue(), ^
                               {
                                   [self setAgoraLoggedInStatus];
                               });
            }
        }];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (int) daysBetweenDates: (NSDate *)startDate currentDate: (NSDate *)endDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponent = [calendar components:NSCalendarUnitDay fromDate:startDate toDate:endDate options:0];
    
    int totalDays = (int)dateComponent.day;
    return totalDays;
    
}

- (void)updateTableViewWhenMessageArrivesForNewMessage:(BOOL)newMsgAvailable andOtherUser:(NSString *)otherUserID andchatId:(NSString *)chatID{
    if (newMsgAvailable) {
        NSString *matchUserId = @"";
        if (_isAppLozicUser){
            matchUserId = _myMatchesData.targetAppLozicId;
        }
        else{
            matchUserId = _myMatchesData.matchedUserId;
        }
        if ([otherUserID isEqualToString:matchUserId]) {
            ChatMessage *chatMsgObj = [ChatMessage getChatMessageForLayerMessageId:chatID];
            [self checkAndAddMessageIfNotExistsInchatArray:chatMsgObj alsoAdjustContentSize:FALSE];
        }
    }
    //Doesnot need to reset constraints or scroll to bottom when a message is updated
    //only specific row needs to be refreshed
    else
    {
        if (![otherUserID isEqualToString:_myMatchesData.matchedUserId])
        {
            ChatMessage *chatMsgObj = [ChatMessage getChatMessageForLayerMessageId:chatID];
            NSInteger indexVal = [self isMessage:chatMsgObj existsInArray:chatMessagesArray];
            if(indexVal != -1)
            {
                [chatMessagesArray replaceObjectAtIndex:indexVal withObject:chatMsgObj];
                //[self.tableView reloadData];
                [self reloadTableDataForParticularCell:false andScrollToBottom:false andIsMessageAddedOrDeleted:false];
                //  [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexVal inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    }
}

-(void)updateChatSnippetAndMarkAllAsRead
{
    [MyMatches updateChatSnippetForChatRoom:_myMatchesData.matchId withChatSnippet:_myMatchesData.chatSnippet forMatchDetail:_myMatchesData timeStamp:_myMatchesData.chatSnippetTime andIsRead:TRUE andSource:_myMatchesData.source withBackgroundCompletion:^(BOOL isUpdationCompleted, MyMatches *matchDetail) {
    }];
//    [self markAllMessagesAsRead];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [APP_DELEGATE connectToApplozic];
    [ALUserService setUnreadCountZeroForContactId:_myMatchesData.targetAppLozicId];
    //Adding observer once
    [self addObserverForView];
    [self updateChatSnippetAndMarkAllAsRead];
    //Hiding Nav bar again
    if (self.navigationController) {
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        self.navigationController.navigationBar.hidden = TRUE;
    }
    
    //Hides Tab bar
    [[WooScreenManager sharedInstance] hideHomeViewTabBar:YES isAnimated:YES];
    
    //Keyboard manager Disabled
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:FALSE];
    
    //Has also been done in setDataForHeader
    //    userImage.layer.cornerRadius = 15;
    //    userImage.layer.masksToBounds = TRUE;
    
    //
    //    if (![UIView areAnimationsEnabled]) {
    //        [UIView setAnimationsEnabled:TRUE];
    //    }
    
    //Checks if it needs to be popped
    //But on searching through workspace no trace of shouldMoveToMatchBoxScreen was found
    //    if ([[NSUserDefaults standardUserDefaults] boolForKey:kShouldMoveToMatchBoxScreen]) {
    //        NSLog(@"NewChatVc inside ViewWillAppear");
    //        [self.navigationController popViewControllerAnimated:YES];
    //        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:kShouldMoveToMatchBoxScreen];
    //        [[NSUserDefaults standardUserDefaults] synchronize];
    //        return;
    //    }
    
    //App delegate is informed of the current chat room id for notification landing
    [APP_DELEGATE setCurrentActiveChatRoomId:_myMatchesData.matchId];
    
    //Also done when image picker cancels  or selects pocture and in view did load
    // Typing area setup
    //Keyboard observer added if area isn't nil
    //can be safely added once in setup instead but since the area is setup multiple times that must be removed and readded
    //Keyboard observers already added in Tping Area init
    //    if (area) {
    //        [area addKeyboardNotificationObservers];
    //    }
    
    [[Utilities sharedUtility]colorStatusBar:[UIColor colorWithRed:117.0/255.0 green:219.0/255.0 blue:135.0/255.0 alpha:1.0]];
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:YES];
    NSLog(@"Newchat viewDidAppear");
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
        NSLog(@"Newchat viewDidAppear not in bg");
        [MyMatches updateChatSnippetForChatRoom:_myMatchesData.matchId withChatSnippet:_myMatchesData.chatSnippet forMatchDetail:_myMatchesData timeStamp:_myMatchesData.chatSnippetTime andIsRead:TRUE andSource:_myMatchesData.source withBackgroundCompletion:^(BOOL isUpdationCompleted, MyMatches *matchDetail) {
        }];
    }else{
    }
    
    //Voice calling conditions
    if ([[AppLaunchModel sharedInstance] isCallingEnabled])
    {
        //        if ((![[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenTutorialForVoiceCall"] ||[[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenTutorialForVoiceCall"] == false) && !self.voiceCallButton.isHidden)
        //        {
        //            if ([[[[DiscoverProfileCollection sharedInstance] myProfileData ]gender] isEqualToString:@"FEMALE"])
        //            {
        //                [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"hasSeenTutorialForVoiceCall"];
        //                [[NSUserDefaults standardUserDefaults]synchronize];
        //                [self performSelector:@selector(showCallingTutorialForWomen) withObject:nil afterDelay:0.0];
        //            }
        //        }
        
        if ([[[[DiscoverProfileCollection sharedInstance] myProfileData ]gender] isEqualToString:@"FEMALE"])
        {
            NSArray * tutorialSeenMatchIdArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"VoiceCallingTutorialSeenfor"] mutableCopy];
            if(tutorialSeenMatchIdArray == nil && !self.voiceCallButton.isHidden)
            {
                tutorialSeenMatchIdArray = [[NSMutableArray alloc]init];
                [[NSUserDefaults standardUserDefaults] setObject:[tutorialSeenMatchIdArray arrayByAddingObject:_myMatchesData.matchId] forKey:@"VoiceCallingTutorialSeenfor"];
                [self performSelector:@selector(showCallingTutorialForWomen) withObject:nil afterDelay:0.0];
            }
            else
            {
                if([tutorialSeenMatchIdArray count] < 3 && ![tutorialSeenMatchIdArray containsObject:_myMatchesData.matchId] && !self.voiceCallButton.isHidden)
                {
                    [[NSUserDefaults standardUserDefaults] setObject:[tutorialSeenMatchIdArray arrayByAddingObject:_myMatchesData.matchId] forKey:@"VoiceCallingTutorialSeenfor"];
                    //check if has seen tutorial for this user
                    [self performSelector:@selector(showCallingTutorialForWomen) withObject:nil afterDelay:0.0];
                }
            }
        }
    }
    if(self.openKeyboardForTyping)
    {
        [_typingView setUserInteractionEnabled:true];
        [_chatTextView becomeFirstResponder];
        self.openKeyboardForTyping = NO;
    }
    
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self removeObserverForView];
    
    [_typingView setUserInteractionEnabled:false];
    [self hideconnectingView];
    [self sendNotificationToRemoveTypingIndicator];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

#pragma mark - Silent Push method to remove
-(void)checkIfUnmatched:(NSNotification *)notification
{
    NSLog(@"Inside checkIfUnmatched");
    NSString *matchId =  notification.object;
    
    if([matchId isEqualToString:self.myMatchesData.matchId])
    {
        [_typingView setUserInteractionEnabled:false];
    }
    
}

- (void) setupNavigationAndTableViewUI
{
    [self.navigationController setNavigationBarHidden:true];
    //Hiding and reconfirming that the nav bar is hidden :D
    self.navigationController.navigationBarHidden = TRUE;
    for (UIView *navBar in [UIApplication sharedApplication].keyWindow.rootViewController.view.subviews) {
        if ([navBar isKindOfClass:[UINavigationBar class]]) {
            [navBar setHidden:true];
        }
    }
    
    if (@available(iOS 11, *)) {
        [_headerTopConstraint setConstant:-20];
    }else{
        [_headerTopConstraint setConstant:0];
    }

    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.hidesBackButton = YES;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.showsVerticalScrollIndicator = TRUE;
}


-(void)checkIfUserIsOnOldChatOrOnLayerAndShowViewAccordingally{
    
    if (_isAppLozicUser){
        [self performSelector:@selector(showConnectingView) withObject:nil afterDelay:0.0001];
        [[ApplozicChatManager sharedApplozicChatManager] isUserConnectedToApplozic:^(BOOL connectionEstablished) {
            if (connectionEstablished){
                isUserOnLayerChat = TRUE;
                dispatch_async(dispatch_get_main_queue(), ^{
                    //                                [area activateTypingArea];
                    [_typingView setUserInteractionEnabled:true];
                    if (connectingViewObj) {
                        [self changeLoadingTextToConnected];
                        [self hideconnectingView];
                    }
                    else{
                        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showConnectingView) object:nil];
                        [self changeLoadingTextToConnected];
                    }
                    [self setupLayerNotificationObservers];
                });
            }
            else{
                [[ApplozicChatManager sharedApplozicChatManager] connectUserToApplozicWithClientObject:APP_DELEGATE.applozic withAppLozicAuthBlock:^(BOOL authenticationSuccess, ApplozicClient *applozicClient) {
                    [self checkIfUserIsOnOldChatOrOnLayerAndShowViewAccordingally];
                }];
            }
        }];
        
    }
    else{
//        if (!self.conversation) {
//            [self performSelector:@selector(showConnectingView) withObject:nil afterDelay:0.0001];
//            [_typingView setUserInteractionEnabled:false];
////            [[LayerManager sharedLayerManager] isUserConnectedToLayer:^(BOOL connectionEstablished) {
////                if (connectionEstablished) {
////                    if (!self.conversation) {
////                        ///Adding a block here would bring back conversatio id or error
//////                        [[LayerManager sharedLayerManager] getConversationObjectForLayerConversationId:[MyMatches getMatchDetailForMatchedUSerID:_myMatchesData.matchedUserId isApplozic:false].layerChatID withCompletionHandler:^(BOOL isSyncCompleted, id  _Nullable conversation, NSError *error) {
//////
//////                            if(conversation != nil)
//////                            {
//////                                self.conversation  = (LYRConversation *)conversation;
//////                                [self markAllMessagesAsRead]; //not anymore :D // It is already calling [self init/ialiseConversationObject]
//////                                isUserOnLayerChat = TRUE;
//////                                dispatch_async(dispatch_get_main_queue(), ^{
//////                                    //                                [area activateTypingArea];
//////                                    [_typingView setUserInteractionEnabled:true];
//////                                    if (connectingViewObj) {
//////                                        [self changeLoadingTextToConnected];
//////                                        [self performSelector:@selector(hideconnectingView) withObject:nil afterDelay:2.5];
//////                                    }
//////                                    else{
//////                                        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showConnectingView) object:nil];
//////                                        [self performSelector:@selector(changeLoadingTextToConnected) withObject:nil afterDelay:1.0];
//////                                    }
//////                                    if (_directMsgStr && [[APP_Utilities validString:_directMsgStr] length]>0) {
//////
//////                                        [self sendMessage:_directMsgStr];
//////                                        _directMsgStr = @"";
//////                                    }
//////                                    [self setupLayerNotificationObservers];
//////                                });
//////
//////                            }
//////                            else
//////                            {
//////                                dispatch_async(dispatch_get_main_queue(), ^{
//////
//////                                    [_typingView setUserInteractionEnabled:false];
//////                                    if (connectingViewObj) {
//////                                        [self changeLoadingTextToConnectionNotFound];
//////                                    }
//////                                    else{
//////                                        [self performSelector:@selector(changeLoadingTextToConnectionNotFound) withObject:nil afterDelay:1.0];;
//////                                    }
//////                                });
//////                            }
//////                        }];
////                    }
////                    else
////                    {
////                        // [area activateTypingArea];
////                    }
////                }
////                else{
////                    [self changeLoadingTextToConnectionNotFound];
////                }
////                [self reloadTableData];
////            }];
//        }
    }
}

-(void)changeLoadingTextToConnected{
    if (connectingViewObj) {
        [connectingViewObj changeLoadingTextView:NSLocalizedString(@"Connected", @"")];
        [connectingViewObj setBackgroundColorOfView:[APP_Utilities getUIColorObjectFromHexString:@"#75DB87" alpha:0.35]];
        [connectingViewObj stopAndHideActivityIndicatorView];
        [self performSelector:@selector(hideconnectingView) withObject:nil afterDelay:0.5];
    }
    else{
        [self performSelector:@selector(changeLoadingTextToConnected) withObject:nil afterDelay:0.5];
    }
}

-(void)changeLoadingTextToConnectionNotFound{
    if (connectingViewObj) {
        [connectingViewObj changeLoadingTextView:NSLocalizedString(@"Connection not found", @"")];
        [connectingViewObj setBackgroundColorOfView:[APP_Utilities getUIColorObjectFromHexString:@"#484848" alpha:1.0]];
        [connectingViewObj setLoadingTextColor:[APP_Utilities getUIColorObjectFromHexString:@"#D8D8D8" alpha:1.0]];
        [connectingViewObj stopAndHideActivityIndicatorView];
    }
    else{
        [self performSelector:@selector(changeLoadingTextToConnectionNotFound) withObject:nil afterDelay:0.5];
    }
}

- (void)sendMessageThroughApplozic:(NSString *)text{
    [self sendNotificationToRemoveTypingIndicator];
    
    if([_myMatchesData.targetAppLozicId  isEqual: kDummyApplozicChatID]){
        
        int numberOfDays = [self daysBetweenDates: _myMatchesData.matchedOn
                                      currentDate: [NSDate date]];
        
        if (numberOfDays >= 1 ){
            [MyMatches updateMatchedUserForIsDeletedWithMatchId:_myMatchesData.matchId];
        }
    }
    
    [[ApplozicChatManager sharedApplozicChatManager] sendChatToApplozic:_myMatchesData.targetAppLozicId forMessage:text orImage:false imageData:nil andChatObject:nil chatSendToApplozicCompletion:^(BOOL chatSendSuccessFully, ChatMessage *messageObj) {
        if(chatSendSuccessFully){
            [self checkAndAddMessageIfNotExistsInchatArray:messageObj alsoAdjustContentSize:FALSE];
        }
    }];
}


-(void)updateAppLozicStatus:(ALMessage *)messageObj{
    
    ChatMessage *chatMessage = [ChatMessage getChatMessageForLayerMessageId:[messageObj.metadata objectForKey:@"CreatedTime"]];
    if (chatMessage){
        [ChatMessage updateChatMessageObject:chatMessage withStatus:messageObj.status withUpdationHandler:^(ChatMessage *chatMessageObj) {
            [self checkAndAddMessageIfNotExistsInchatArray:chatMessageObj alsoAdjustContentSize:FALSE];
        }];
    }
    else{
        [APPLOZIC_HELPER updateApplozicChatFromToLocalDB:messageObj ifSenderIsMe:true withCompletionHandler:^(ChatMessage *chatMessageObj) {
            [self checkAndAddMessageIfNotExistsInchatArray:chatMessageObj alsoAdjustContentSize:FALSE];
        }];
    }
}


-(void)updateApplozicMessages:(ChatMessage*)messageObj isChatSendSuccesfully:(BOOL)status{
    if(status){
        [self checkAndAddMessageIfNotExistsInchatArray:messageObj alsoAdjustContentSize:FALSE];
    }
}

-(IBAction)moreButtonTapped:(id)sender{
    [self.view endEditing:true];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        UIAlertController *reportAlertcontroller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil) style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction *action) {
                                                                 NSLog(@"Cancel tapped");
                                                                 [_typingView setUserInteractionEnabled:true];
                                                             }];
        UIAlertAction *clearConversation = [UIAlertAction actionWithTitle:NSLocalizedString(@"Clear Conversation",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Clear Conversation",nil) message:NSLocalizedString(@"You will not be able to see deleted messages again. Are you sure you want to delete this conversation?",nil) preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *leftButtonAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            UIAlertAction *rightButtonAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self deleteAllChatAlertTappedAction];
            }];
            
            [alertViewController addAction:leftButtonAction];
            [alertViewController addAction:rightButtonAction];
            
            [self presentViewController:alertViewController animated:YES completion:nil];
        }];
        
        UIAlertAction *unmatch = [UIAlertAction actionWithTitle:NSLocalizedString(@"Unmatch",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [self showUnmatchOptionstoUserForButtonTapped];
        }];
        
        UIAlertAction *reportAbuse = [UIAlertAction actionWithTitle:NSLocalizedString(@"Block & Report",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [self showReportWarning];
            
        }];
        
        [reportAlertcontroller addAction:cancelAction];
        [reportAlertcontroller addAction:clearConversation];
        [reportAlertcontroller addAction:unmatch];
        [reportAlertcontroller addAction:reportAbuse];
        //        [area setHidden:TRUE];
        [self presentViewController:reportAlertcontroller animated:YES completion:^{
        }];
        
    }else{
        UIActionSheet *reportActionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Clear Conversation",nil),NSLocalizedString(@"Unmatch",nil),NSLocalizedString(@"Report Abuse",nil), nil];
        
        [reportActionSheet showInView:self.view];
        
    }
}

#pragma mark - Delete All Chat Alert Button Tapped

-(void)deleteAllChatAlertTappedAction{
    
    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"ClearConversation" forScreenName:@"Chat"];
    
    [ALMessageService deleteMessageThread:_myMatchesData.targetAppLozicId orChannelKey:nil
                           withCompletion:^(NSString *string, NSError *error) {
                               
                               if(error)
                               {
                                   NSLog(@"Applozic conversation deleted succesfully");
                               }
                               
                               
                               
                           }];
    
    [ChatMessage deleteAllChatForChatRoomExceptIntroMessage:_myMatchesData.matchId withCompletionHandler:^(BOOL success) {
        [MyMatches resetChatSnippetOfChatRoom:_myMatchesData.matchId withBackgroundCompletion:^(BOOL insertionSuccess) {
            if (chatMessagesArray && [chatMessagesArray count]>0) {
                [chatMessagesArray removeAllObjects];
            }
            
            [self returnGroupedChatMessges:[ChatMessage getAllMessageForChatRoom:_myMatchesData.matchId WithLimit:kNumberOfMessageToBeShownAtATime*(1)]];
            //            if ([chatArray count] <= 0){
            //                [self returnGroupedChatMessges:[ChatMessage getAllMessageForChatRoom:_myMatchesData.matchedUserId WithLimit:kNumberOfMessageToBeShownAtATime*(1)]];
            //
            //            }
            //[self.tableView reloadData];
            [self reloadTableDataForParticularCell:false andScrollToBottom:false andIsMessageAddedOrDeleted:false];

            if (![ChatMessage isMoreDataAvailableForChatRoom:_myMatchesData.matchId WithIndex:currentIndex]) {
                self.tableView.tableHeaderView = nil;
            }
        }];
    }];
}

-(void)deleteConfirmationCallback:(MyMatches *)matchedUserObj andCommentForUnmatch:(NSString*)comment{
    
    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"Unmatch" forScreenName:@"Chat"];
    if ([_delegateFromMatch respondsToSelector:_selectorToDeleteRow]) {
        [_delegateFromMatch performSelector:_selectorToDeleteRow withObject:matchedUserObj afterDelay:0.1];
        [self backButtonTapped];
    }
    else{
        [self infromServerAboutDeletionOfAMatchWithMatchID:matchedUserObj withCommentForUnmatch:comment];
    }
}

-(void)infromServerAboutDeletionOfAMatchWithMatchID:(MyMatches *)matchObj withCommentForUnmatch:(NSString *)comment{
    
    [CrushAPIClass deleteMatchWithMatchID:matchObj withCommentForUnmatch:comment successBlock:^(BOOL isDeletionCompleted) {
        if(!isDeletionCompleted)
        {
            NSLog(@"Couldnot Delete match");
        }
    }];
    //leave conversation
    NSError * error = nil;
//    BOOL leaveSync = [self.conversation leave:&error];
//    if(leaveSync == NO && error != nil)
//    {
//        NSLog(@"Error leaving conversation %@",[error localizedDescription]);
//    }
    
    [MyMatches deleteMatchForMatchedUserId:matchObj.matchedUserId withDeletionCompletionHandler:^(BOOL isUpdationCompleted) {
        [ChatMessage deleteMessagesForChatRoom:matchObj.matchId];
        [self backButtonTapped];
    }];
    
}

-(void)setDataOnHeader{
    if (!header) {
        header = [[HeaderTappableArea alloc]init];
    }
    header.userInteractionEnabled = true;
    [header setDelegate:self];
    [header headerTappedBlock:^{
        [self viewProfileTapped];
    }];
    if(_myMatchesData){
        NSString *matchGenderString = @"";
        if (_myMatchesData.matchGender != nil && _myMatchesData.matchGender.length > 0) {
            matchGenderString = _myMatchesData.matchGender;
            
        }
        
        BOOL amIMale = [APP_Utilities isGenderMale:matchGenderString];
        
        [header setDataOnHeaderWithImage:_myMatchesData.matchUserPic andUserFirstName:_myMatchesData.matchUserName withPlaceholderImageName:amIMale?@"placeholder_male":@"placeholder_female"];
    }
    
    if (![_myMatchesData.matchUserPic hasPrefix:kImageCroppingServerURL]){
        
        // let meWidth =
        int width = [[Utilities sharedUtility] getImageSizeForPoints:150];
        int height = width * 3/2;
        NSLog(@"URL %@",[NSString stringWithFormat:@"%@?url=%@&width=%d&height=%d",kImageCroppingServerURL,_myMatchesData.matchUserPic,width,height]);
        [userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?url=%@&width=%d&height=%d",kImageCroppingServerURL,_myMatchesData.matchUserPic,width,height]] placeholderImage:[UIImage imageNamed:@"ic_me_avatar_small"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            userImage.layer.cornerRadius = 15;
            userImage.layer.masksToBounds = TRUE;
        }];
    }
    else{
        [userImage sd_setImageWithURL:[NSURL URLWithString:_myMatchesData.matchUserPic] placeholderImage:[UIImage imageNamed:@"ic_me_avatar_small"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            userImage.layer.cornerRadius = 15;
            userImage.layer.masksToBounds = TRUE;
        }];
    }
    userImage.layer.cornerRadius = 15;
    userImage.layer.masksToBounds = TRUE;
    userNameLbl.text = _myMatchesData.matchUserName;
}

-(void)showWooLoader{
    
    if (!customLoader) {
        customLoader = [[WooLoader alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 64, self.view.frame.size.width, self.view.frame.size.height - 64)];
    }
    [customLoader startAnimationOnView:APP_DELEGATE.window WithBackGround:YES];
    
}

-(void)hideWooLoader{
    
    [customLoader stopAnimation];
}

-(IBAction)showUserDetailButtonTapped:(id)sender{
    [self viewProfileTapped];
}

-(void)viewProfileTapped{
    [_typingView setUserInteractionEnabled:false];
    if (_myMatchesData) {
        ProfileCardModel *fetchedProfile = [[DiscoverProfileCollection sharedInstance] getProfileCardForWooID:_myMatchesData.matchedUserId];
        
        if (fetchedProfile.wooId == nil) {
            fetchedProfile = [[ProfileCardModel alloc] initWithMatchObject:_myMatchesData];
            if (fetchedProfile.wooId == nil) {
                [self showWooLoader];
                [self viewProfileTapped:_myMatchesData withIsBoosted:NO];
            }
            else{
                [self performSegueWithIdentifier:kPushToDetailProfileFromChatRoom sender:fetchedProfile];
            }
        }
        else{
            [self performSegueWithIdentifier:kPushToDetailProfileFromChatRoom sender:fetchedProfile];
        }
    }
}

-(void)viewProfileTapped:(MyMatches *)data withIsBoosted:(BOOL)isBoosted{
    [ProfileAPIClass fetchDataForUserWithUserID:[data.matchedUserId longLongValue]withCompletionBlock:^(id response, BOOL success, int statusCode) {
        
        if (statusCode == 401) {
            return ;
        }
        if (statusCode == 0) {
            [self hideWooLoader];
            [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];
            return;
        }
        if (success) {
            if ([response isKindOfClass:[NSDictionary class]]) {
                if ([APP_DELEGATE.currentActiveChatRoomId length] > 0 && [data.matchId isEqualToString:APP_DELEGATE.currentActiveChatRoomId]) {
                    ProfileCardModel *model = [[ProfileCardModel alloc] initWithUserInfoDto:response];
                    [[DiscoverProfileCollection sharedInstance] addProfileCard:model];
                    [self performSegueWithIdentifier:kPushToDetailProfileFromChatRoom sender:model];
                }
                [self hideWooLoader];
            }
        }
    }];
}

-(void)backButtonTapped{
    NSLog(@"NewChatVc inside backButtonTapped");
    [_typingView setUserInteractionEnabled:false];
    
    if(self.navigationController != nil)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    APP_DELEGATE.currentActiveChatRoomId = @"";
    [self hideWooLoader];
}

-(void)showCallingTutorialForWomen
{
    //[area setHidden:true];
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    __weak NewChatViewController *weakSelf = self;
    VoiceCallIntroForWomenPopup *tutorialView =  [[[NSBundle mainBundle] loadNibNamed:@"VoiceCallIntroForWomenPopup" owner:window.rootViewController options:nil] firstObject];
    CGFloat safeAreaTop = [[Utilities sharedUtility] getSafeAreaForTop:true andBottom:false];
    (IS_IPHONE_X || IS_IPHONE_XS_MAX) ? (tutorialView.frame = CGRectMake(0, 0,self.view.bounds.size.width, self.view.bounds.size.height)) : (tutorialView.frame = CGRectMake(0, safeAreaTop,self.view.bounds.size.width, self.view.bounds.size.height));

    //Hide unhide tutorial view
    if ([[[[DiscoverProfileCollection sharedInstance] myProfileData ]gender] isEqualToString:@"FEMALE"])
    {
        tutorialView.tutorialSeenHandler = ^{
            //            [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"hasSeenTutorialForVoiceCall"];
            //            [[NSUserDefaults standardUserDefaults]synchronize];
            [_typingView setUserInteractionEnabled:true];
        };
        tutorialView.callButtonTappedHandler = ^{
            //            [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"hasSeenTutorialForVoiceCall"];
            //            [[NSUserDefaults standardUserDefaults]synchronize];
            [weakSelf voiceCallButtonTapped:nil];
            [_typingView setUserInteractionEnabled:true];
        };
        [self.view addSubview:tutorialView];
    }
    
}

-(void)showCallingTutorialForMen
{
    __weak NewChatViewController *weakSelf = self;
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    //    NSLog(@"Window subviews %@",window.subviews);
    VoiceCallTutorialOverlay *tutorialView =  [[[NSBundle mainBundle] loadNibNamed:@"VoiceCallTutorialOverlay" owner:window.rootViewController options:nil] firstObject];
    CGFloat safeAreaTop = [[Utilities sharedUtility] getSafeAreaForTop:true andBottom:false];
    (IS_IPHONE_X || IS_IPHONE_XS_MAX) ? (tutorialView.frame = CGRectMake(0, 0,self.view.bounds.size.width, self.view.bounds.size.height)) : (tutorialView.frame = CGRectMake(0, safeAreaTop,self.view.bounds.size.width, self.view.bounds.size.height));

    //Hide unhide tutorial view
    if([[AppLaunchModel sharedInstance] voiceCallingPopUpEnabled])
    {
        [tutorialView.overlayCallButton setSelected:NO];
        [tutorialView.tutorialText setText:[NSString stringWithFormat:NSLocalizedString(@"You have calling power! Ask her when would be a good time to call.", @"You have calling power! Ask her when would be a good time to call.")]];
        tutorialView.tutorialSeenHandler = ^{
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"hasSeenTutorialForVoiceCall"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [_typingView setUserInteractionEnabled:true];
        };
        tutorialView.callButtonTappedHandler = ^{
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"hasSeenTutorialForVoiceCall"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [weakSelf voiceCallButtonTapped:nil];
            [_typingView setUserInteractionEnabled:true];
        };
        
    }
    else{
        [tutorialView.overlayCallButton setSelected:YES];
        [tutorialView.tutorialText setText:[NSString stringWithFormat:NSLocalizedString(@"Call can be initiated by %@ only. Please ask her politely if she's ready to speak to you over call.", @"Call can be initiated by %@ only. Please ask her politely if she's ready to speak to you over call."),self.myMatchesData.matchUserName]];
        tutorialView.tutorialSeenHandler = ^{
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"hasSeenTutorialForVoiceCall"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [_typingView setUserInteractionEnabled:true];
        };
        tutorialView.callButtonTappedHandler = ^{
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"hasSeenTutorialForVoiceCall"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [weakSelf voiceCallButtonTapped:nil];
            [_typingView setUserInteractionEnabled:true];
        };
    }
    if([self.navigationController.topViewController isKindOfClass:[NewChatViewController class]])
    {
        [self.view addSubview:tutorialView];
    }
}

-(void)showInviteViewForMen
{
    __weak NewChatViewController *weakSelf = self;
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    VoiceCallInviteOverlay *inviteView =  [[[NSBundle mainBundle] loadNibNamed:@"VoiceCallInviteOverlay" owner:window.rootViewController options:nil] firstObject];
    CGFloat safeAreaTop = [[Utilities sharedUtility] getSafeAreaForTop:true andBottom:false];
    inviteView.frame = CGRectMake(0, safeAreaTop, self.view.bounds.size.width, self.view.bounds.size.height);
    //Hide unhide tutorial view
    [inviteView.voiceCallButton setSelected:YES];
    if([AppLaunchModel sharedInstance].invitationCampaignDesc && ![[AppLaunchModel sharedInstance].invitationCampaignDesc isEqualToString:@""])
    {
        [inviteView.inviteText setText:[AppLaunchModel sharedInstance].invitationCampaignDesc];
    }
    else
    {
        [inviteView.inviteText setText:NSLocalizedString(@"Get 5 friends to join Woo and enjoy full access to call your matches for a week!", @"Get 5 friends to join Woo and enjoy full access to call your matches for a week!")];
    }
    inviteView.inviteTappedOnOverlayHandler = ^{
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"hasSeenInviteViewForVoiceCall"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        UIStoryboard *storyboard =  [UIStoryboard storyboardWithName:@"Home" bundle:nil];
        // TODO Rename object
        InviteFriendsSwiftViewController *myWebViewViewController =
        [storyboard instantiateViewControllerWithIdentifier:@"InviteCompaignViewControllerID"];
        [self.navigationController pushViewController:myWebViewViewController animated:YES];
    };
    
    inviteView.rightImageView.image = userImage.image;
    NSString *encodedImageUrl = _myMatchesData.matchUserPic;
    [inviteView.rightImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(kCircularImageSize),IMAGE_SIZE_FOR_POINTS(kCircularImageSize), encodedImageUrl]] placeholderImage:[UIImage imageNamed:@"ic_me_avatar_small"] completed:nil];
    
    
    NSString *leftUserImageURL = DiscoverProfileCollection.sharedInstance.myProfileData.wooAlbum.profilePicUrl;
    [inviteView.leftImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(kCircularImageSize),IMAGE_SIZE_FOR_POINTS(kCircularImageSize), leftUserImageURL]] placeholderImage:[UIImage imageNamed:@"ic_me_avatar_small"] completed:nil];
    
    if([self.navigationController.topViewController isKindOfClass:[NewChatViewController class]])
    {
        [window addSubview:inviteView];
    }
}

-(void)setAgoraLoggedInStatus
{
    __weak NewChatViewController *weakSelf = self;
    isLoggedIntoAgora = YES;
    
    // User has now been logged into Agora
    //If calling is enable..get channel key now and then show calling button
    if([[AppLaunchModel sharedInstance] isCallingEnabled])
    {
        [[AgoraConnectionManager sharedManager] getChannelKeyForMatchId:self.myMatchesData.matchId andCompletionBlock:^(id response, BOOL success) {
            if(success && [response objectForKey:@"agora_channel_key"])
            {
                // Update in MyMatches
                [MyMatches updateMatchedUserDetailsForMatchedUserID:self.myMatchesData.matchedUserId withAgoraChannelKey:[response objectForKey:@"agora_channel_key"] withChatUpdationSuccess:^(BOOL isUpdationCompleted)
                 {
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         weakSelf.myMatchesData = [MyMatches getMatchDetailForMatchedUSerID:self.myMatchesData.matchedUserId isApplozic:false];
                         
                         [weakSelf.voiceCallButton setSelected:NO];
                         [weakSelf.voiceCallButton setUserInteractionEnabled:YES];
                         [weakSelf.voiceCallButton setHidden:NO];
                         [weakSelf showGlowAnimation];
                         // [weakSelf addGrowthAnimationForVoiceCallingButton];
                         
                         //hasnot seen tutorial
                         //check how many times the turorial has been shown and if the tutorial has been shown for this match id
                         if ([[[[DiscoverProfileCollection sharedInstance] myProfileData ]gender] isEqualToString:@"FEMALE"])
                         {
                             NSArray * tutorialSeenMatchIdArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"VoiceCallingTutorialSeenfor"] mutableCopy];
                             if(tutorialSeenMatchIdArray == nil)
                             {
                                 tutorialSeenMatchIdArray = [[NSMutableArray alloc]init];
                                 [[NSUserDefaults standardUserDefaults] setObject:[tutorialSeenMatchIdArray arrayByAddingObject:_myMatchesData.matchId] forKey:@"VoiceCallingTutorialSeenfor"];
                                 [weakSelf showCallingTutorialForWomen];
                             }
                             else
                             {
                                 if([tutorialSeenMatchIdArray count] < 3 && ![tutorialSeenMatchIdArray containsObject:_myMatchesData.matchId])
                                 {
                                     [[NSUserDefaults standardUserDefaults] setObject:[tutorialSeenMatchIdArray arrayByAddingObject:_myMatchesData.matchId] forKey:@"VoiceCallingTutorialSeenfor"];
                                     //check if has seen tutorial for this user
                                     [weakSelf showCallingTutorialForWomen];
                                 }
                             }
                         }
                         /*
                          if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenTutorialForVoiceCall"] ||[[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenTutorialForVoiceCall"] == false)
                          {
                          
                          if ([[[[DiscoverProfileCollection sharedInstance] myProfileData ]gender] isEqualToString:@"FEMALE"])
                          {
                          [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"hasSeenTutorialForVoiceCall"];
                          [[NSUserDefaults standardUserDefaults]synchronize];
                          [weakSelf showCallingTutorialForWomen];
                          }
                          }
                          */
                         
                     });
                 }];
            }
            else
            {
                //Error
            }
        }];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.voiceCallButton setUserInteractionEnabled:YES];
            [self.voiceCallButton setSelected:YES];
            [weakSelf.voiceCallButton setHidden:NO];
            // [weakSelf showGlowAnimation];
            // [weakSelf addGrowthAnimationForVoiceCallingButton];
        });
    }
}


-(void)addGrowthAnimationForVoiceCallingButton
{
    CABasicAnimation *popup = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    popup.fromValue =  [NSNumber numberWithInt:0];
    popup.toValue = [NSNumber numberWithInt:1];
    popup.duration = 0.5;
    [self.voiceCallButton.layer addAnimation:popup forKey:@"scaleAnimation"];
}

-(void)removeViewOnTappingNewNotification{
    NSLog(@"NewChatVc inside removeViewOnTappingNewNotification");
    [self backButtonTapped];
}

-(void)addObserverForView{
    
    //for typing area resizing viewWillAppear
    // View will Appear - informs the controller of new conversation available
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newLayerConversationObjectAvailable:) name:kNewConversationAvailableNotification object:nil];
    // View will Appear - informs the controller when agora is logged in
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setAgoraLoggedInStatus) name:KLoggedInToAgora object:nil];
    // View will Appear - informs that match status is set to deleted
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkIfUnmatched:) name:kMatchStatusSetToDeleted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAllChatMessages) name:@"ClientSynchronizationDone" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAllChatMessages) name:kChatRoomMigrationDone object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateChatSnippetAndMarkAllAsRead) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)reloadAllChatMessages
{
    [chatMessagesArray removeAllObjects];
    currentIndex = 0;
    //Groups chat messages
    [self returnGroupedChatMessges:[ChatMessage getAllMessageForChatRoom:_myMatchesData.matchId WithLimit:kNumberOfMessageToBeShownAtATime*(1)]];
    
    //    if ([chatArray count] <= 0){
    //        [self returnGroupedChatMessges:[ChatMessage getAllMessageForChatRoom:_myMatchesData.matchedUserId WithLimit:kNumberOfMessageToBeShownAtATime*(1)]];
    //
    //    }
    //Shows load more if more messages available after first fetch
    if ([ChatMessage isMoreDataAvailableForChatRoom:_myMatchesData.matchId WithIndex:currentIndex])
    {
        UIButton *loadMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        loadMoreButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        [loadMoreButton setTitle:NSLocalizedString(@"Load More", nil) forState:UIControlStateNormal];
        [loadMoreButton addTarget:self action:@selector(loadMoreButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        loadMoreButton.titleLabel.font = kVerifyingMessageTextFont;
        
        loadMoreButton.frame = CGRectMake(((SCREEN_WIDTH/2) - 50), 4, 100, 36);
        loadMoreButton.layer.cornerRadius = 3.0;
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
        headerView.backgroundColor = [UIColor clearColor];
        [headerView addSubview:loadMoreButton];
        self.tableView.tableHeaderView = headerView;
    }
    //[self.tableView reloadData];
    [self reloadTableDataForParticularCell:false andScrollToBottom:false andIsMessageAddedOrDeleted:false];
}

-(void)removeObserverForView{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNewConversationAvailableNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KLoggedInToAgora object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMatchStatusSetToDeleted object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kBroadcastTypingIndicatorChangeEventNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ClientSynchronizationDone" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChatRoomMigrationDone object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    
}

-(void)dealloc{
    //Removing viewDidLoadObservers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChatRoomDeleted object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMatchDataUpdatedInDPV object:nil];
}

-(void)reloadMatchData
{
    _myMatchesData = [MyMatches getMatchDetailForMatchID:_myMatchesData.matchId];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setDataOnHeader];
       // [self.tableView reloadData];
        [self reloadTableDataForParticularCell:false andScrollToBottom:false andIsMessageAddedOrDeleted:false];
    });
    
}
//-(void)newLayerConversationObjectAvailable:(NSNotification *)notificationObj{
////    if (notificationObj != nil){
////        if ([notificationObj.object isKindOfClass:[LYRConversation class]]) {
////            LYRConversation *conversationObj = notificationObj.object;
////            for (LYRIdentity *participarntId in conversationObj.participants) {
////                if ([_myMatchesData.matchedUserId isEqualToString:participarntId.userID]) {
////                    if (!self.conversation) {
////                        ///Adding a block here would bring back conversatio id or error
//////                        [[LayerManager sharedLayerManager] getConversationObjectForLayerConversationId:[MyMatches getMatchDetailForMatchedUSerID:_myMatchesData.matchedUserId isApplozic:false].layerChatID withCompletionHandler:^(BOOL isSyncCompleted, id  _Nullable conversation, NSError *error) {
//////
//////                            if(conversation != nil)
//////                            {
//////                                self.conversation  = (LYRConversation *)conversation;
//////                                [_typingView setUserInteractionEnabled:true];
//////                                [NSNotification cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideconnectingView) object:nil];
//////                                [self performSelector:@selector(hideconnectingView) withObject:nil afterDelay:2.5];
//////                                if (connectingViewObj) {
//////                                    [connectingViewObj changeLoadingTextView:NSLocalizedString(@"Connected", @"")];
//////                                    [connectingViewObj setBackgroundColorOfView:[APP_Utilities getUIColorObjectFromHexString:@"#75DB87" alpha:0.35]];
//////                                }
//////                            }
//////                            else
//////                            {
//////                                [_typingView setUserInteractionEnabled:false];
//////                                if (connectingViewObj) {
//////                                    [connectingViewObj changeLoadingTextView:NSLocalizedString(@"Connection no found", @"")];
//////                                    [connectingViewObj setBackgroundColorOfView:[APP_Utilities getUIColorObjectFromHexString:@"#484848" alpha:1.0]];
//////                                }
//////                                [self performSelector:@selector(hideconnectingView) withObject:nil afterDelay:2.5];
//////                            }
//////                        }];
////                    }
////                }
////            }
////
////        }
////    }
//}

- (void)setupLayerNotificationObservers
{
    if (_isAppLozicUser){
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveTypingIndicatorForApplozic:) name:kBroadcastTypingIndicatorChangeEventNotificationApplozic object:nil];
    }
    else{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveTypingIndicator:) name:kBroadcastTypingIndicatorChangeEventNotification object:nil];
    }
}


#pragma mark - Layer Object Change Notification Handler



- (void)didReceiveTypingIndicator:(NSNotification *)notification
{
//    dispatch_async(dispatch_get_main_queue(), ^{
//
//            LYRTypingIndicator *typingIndicator = notification.object[kParticipantIdKey];
//
//            if (typingIndicator.action == LYRTypingIndicatorActionBegin) {
//                if  (!isUserTyping && ![chatMessagesArray containsObject:@{kMessageTypeKey:[NSNumber numberWithInt:TYPING] }])
//                {
//                    [chatMessagesArray addObject:@{kMessageTypeKey:[NSNumber numberWithInt:TYPING] }];
//                    NSInteger indexOfObj = [chatMessagesArray indexOfObject:@{kMessageTypeKey:[NSNumber numberWithInt:TYPING]}];
//                    //[self.tableView reloadData];
//                    [self reloadTableDataForParticularCell:true andScrollToBottom:true andIsMessageAddedOrDeleted:true];
//
//                    //                [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexOfObj inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//                    float yOffset = self.tableView.contentSize.height - self.tableView.frame.size.height;
//                    if (yOffset < 0) {
//                        yOffset = 0;
//                    }
//                    [self.tableView setContentOffset:CGPointMake(0, yOffset) animated:false];
//                }
//                isUserTyping = TRUE;
//
//            }
//            else if (typingIndicator.action == LYRTypingIndicatorActionFinish){
//                if(isUserTyping && [chatMessagesArray containsObject:@{kMessageTypeKey:[NSNumber numberWithInt:TYPING] }])
//                {
//                    NSInteger indexOfObj = [chatMessagesArray indexOfObject:@{kMessageTypeKey:[NSNumber numberWithInt:TYPING]}];
//                    [chatMessagesArray removeObject:@{kMessageTypeKey:[NSNumber numberWithInt:TYPING] }];
//                    //                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexOfObj inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//                    //[self.tableView reloadData];
//                    [self reloadTableDataForParticularCell:true andScrollToBottom:true andIsMessageAddedOrDeleted:false];
//
//                    float yOffset = self.tableView.contentSize.height - self.tableView.frame.size.height;
//                    if (yOffset < 0) {
//                        yOffset = 0;
//                    }
//                    [self.tableView setContentOffset:CGPointMake(0, yOffset) animated:false];
//                }
//                isUserTyping = FALSE;
//            }
//    });
}

- (void)didReceiveTypingIndicatorForApplozic:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSNumber *isTyping;
        NSString *targetAppLozicID = @"";
        if (notification != nil){
            if (notification.object[kParticipantIdKey] != nil){
                isTyping = notification.object[kParticipantIdKey];
            }
            else{
                isTyping = [NSNumber numberWithBool:false];
            }
            
            if (notification.object[ktypingTargetIdKey] != nil){
                targetAppLozicID = notification.object[ktypingTargetIdKey];
            }
        }
        if (targetAppLozicID.length == 0){
            return;
        }
            NSLog(@"typing...from appLozic %d",isTyping.intValue);
            if (isTyping.boolValue && [targetAppLozicID isEqualToString: self.myMatchesData.targetAppLozicId]){
                if  (!isUserTyping && ![chatMessagesArray containsObject:@{kMessageTypeKey:[NSNumber numberWithInt:TYPING] }])
                {
                    [chatMessagesArray addObject:@{kMessageTypeKey:[NSNumber numberWithInt:TYPING] }];
                    NSInteger indexOfObj = [chatMessagesArray indexOfObject:@{kMessageTypeKey:[NSNumber numberWithInt:TYPING]}];
                    //[self.tableView reloadData];
                    [self reloadTableDataForParticularCell:false andScrollToBottom:true andIsMessageAddedOrDeleted:true];
                    //                [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexOfObj inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    float yOffset = self.tableView.contentSize.height - self.tableView.frame.size.height;
                    if (yOffset < 0) {
                        yOffset = 0;
                    }
                    [self.tableView setContentOffset:CGPointMake(0, yOffset) animated:false];
                }
                isUserTyping = TRUE;
            }
            else{
                if(isUserTyping && [chatMessagesArray containsObject:@{kMessageTypeKey:[NSNumber numberWithInt:TYPING] }])
                {
                    NSInteger indexOfObj = [chatMessagesArray indexOfObject:@{kMessageTypeKey:[NSNumber numberWithInt:TYPING]}];
                    [chatMessagesArray removeObject:@{kMessageTypeKey:[NSNumber numberWithInt:TYPING] }];
                    //                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexOfObj inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    //[self.tableView reloadData];
                    [self reloadTableDataForParticularCell:false andScrollToBottom:true andIsMessageAddedOrDeleted:false];
                    float yOffset = self.tableView.contentSize.height - self.tableView.frame.size.height;
                    if (yOffset < 0) {
                        yOffset = 0;
                    }
                    [self.tableView setContentOffset:CGPointMake(0, yOffset) animated:false];
                }
                isUserTyping = FALSE;
            }
    });
}


-(void)popSilently{
    NSLog(@"NewChatVc inside popSilently");
    
    [self.navigationController popViewControllerAnimated:NO];
    [_typingView setUserInteractionEnabled:false];
}

-(void)matchDeletedForChatRoomID:(NSString *)chatRoomID{
    
    if ([chatRoomID isKindOfClass:[NSString class]]) {
        if ([chatRoomID isEqualToString:_myMatchesData.matchId]) {
            [_typingView setUserInteractionEnabled:false];
        }
    }
    else{
        NSNotification *notificatonObj = (NSNotification *)chatRoomID;
        NSString *usrId = notificatonObj.object;
        if ([usrId isEqualToString:_myMatchesData.matchedUserId]) {
            [_typingView setUserInteractionEnabled:true];
        }
    }
}

- (IBAction)takePhotoFromCamera:(id)sender {
    
    MyMatches *myMatchedObj = [MyMatches getMatchDetailForMatchedUSerID:_myMatchesData.matchedUserId isApplozic:false];
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // do your logic
            [self presentDeviceCameraForUser];
        });
    }
    else if(authStatus == AVAuthorizationStatusDenied){
        UIAlertController *alertObj = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Allow camera access", nil) message:NSLocalizedString(@"Go to Settings -> Privacy -> Camera and turn Woo ON", nil)  preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)  style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CMP00356", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self permissionButtonTapped];
        }];
        [alertObj addAction:cancelAction];
        [alertObj addAction:okAction];
        [self presentViewController:alertObj animated:YES completion:nil];
        // denied
    }
    else if(authStatus == AVAuthorizationStatusRestricted){
        
        UIAlertController *alertObj = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Allow camera access", nil) message:NSLocalizedString(@"Go to Settings -> Privacy -> Camera and turn Woo ON", nil)  preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)  style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CMP00356", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self permissionButtonTapped];
        }];
        [alertObj addAction:cancelAction];
        [alertObj addAction:okAction];
        [self presentViewController:alertObj animated:YES completion:nil];
        // restricted, normally won't happen
    } else if(authStatus == AVAuthorizationStatusNotDetermined)
    {
        // not determined?!
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (granted) {
                    [self presentDeviceCameraForUser];
                }
                else{
                    UIAlertController *alertObj = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Allow camera access", nil) message:NSLocalizedString(@"Go to Settings -> Privacy -> Camera and turn Woo ON", nil)  preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)  style:UIAlertActionStyleCancel handler:nil];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CMP00356", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self permissionButtonTapped];
                    }];
                    [alertObj addAction:cancelAction];
                    [alertObj addAction:okAction];
                    [self presentViewController:alertObj animated:YES completion:nil];
                }
            });
        }];
    }
    else {
        // impossible, unknown authorization status
    }
    
 // code commented for accessgin the gallery and camera on chat
    
//    if ([myMatchedObj.isMultiMediaMsgAllowed boolValue]) {
//
//        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
//        if(authStatus == AVAuthorizationStatusAuthorized) {
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//                // do your logic
//                [self presentDeviceCameraForUser];
//            });
//        }
//        else if(authStatus == AVAuthorizationStatusDenied){
//            UIAlertController *alertObj = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Allow camera access", nil) message:NSLocalizedString(@"Go to Settings -> Privacy -> Camera and turn Woo ON", nil)  preferredStyle:UIAlertControllerStyleAlert];
//            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)  style:UIAlertActionStyleCancel handler:nil];
//            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CMP00356", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                [self permissionButtonTapped];
//            }];
//            [alertObj addAction:cancelAction];
//            [alertObj addAction:okAction];
//            [self presentViewController:alertObj animated:YES completion:nil];
//            // denied
//        }
//        else if(authStatus == AVAuthorizationStatusRestricted){
//
//            UIAlertController *alertObj = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Allow camera access", nil) message:NSLocalizedString(@"Go to Settings -> Privacy -> Camera and turn Woo ON", nil)  preferredStyle:UIAlertControllerStyleAlert];
//            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)  style:UIAlertActionStyleCancel handler:nil];
//            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CMP00356", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                [self permissionButtonTapped];
//            }];
//            [alertObj addAction:cancelAction];
//            [alertObj addAction:okAction];
//            [self presentViewController:alertObj animated:YES completion:nil];
//            // restricted, normally won't happen
//        } else if(authStatus == AVAuthorizationStatusNotDetermined)
//        {
//            // not determined?!
//            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//
//                    if (granted) {
//                        [self presentDeviceCameraForUser];
//                    }
//                    else{
//                        UIAlertController *alertObj = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Allow camera access", nil) message:NSLocalizedString(@"Go to Settings -> Privacy -> Camera and turn Woo ON", nil)  preferredStyle:UIAlertControllerStyleAlert];
//                        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)  style:UIAlertActionStyleCancel handler:nil];
//                        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CMP00356", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                            [self permissionButtonTapped];
//                        }];
//                        [alertObj addAction:cancelAction];
//                        [alertObj addAction:okAction];
//                        [self presentViewController:alertObj animated:YES completion:nil];
//                    }
//                });
//            }];
//        }
//        else {
//            // impossible, unknown authorization status
//        }
//
//    }
//    else{
//        NSString *messageString = [NSString stringWithFormat:@"%@ can't recieve images as they're on older version of Woo.",_myMatchesData.matchUserName];
//        UIAlertController *multimediaAlert = [UIAlertController alertControllerWithTitle:@"Uh oh!" message:messageString  preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CMP00356", nil)  style:UIAlertActionStyleCancel handler:nil];
//        [multimediaAlert addAction:cancelAction];
//        [self presentViewController:multimediaAlert animated:YES completion:nil];
//    }
}

- (IBAction)takePhotoFromGallery:(id)sender {
    //    [area deactivateTypingArea];
    MyMatches *myMatchedObj = [MyMatches getMatchDetailForMatchedUSerID:_myMatchesData.matchedUserId isApplozic:false];
    
    
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    switch (status) {
        case ALAuthorizationStatusDenied:
        case ALAuthorizationStatusRestricted:
        {
            UIAlertController *alertObj = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Allow access to photos", nil) message:NSLocalizedString(@"Go to Settings -> Privacy -> Photos and turn Woo ON", nil)  preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)  style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CMP00356", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self permissionButtonTapped];
            }];
            [alertObj addAction:cancelAction];
            [alertObj addAction:okAction];
            [self presentViewController:alertObj animated:YES completion:nil];
        }
            break;
        case ALAuthorizationStatusNotDetermined:
        case ALAuthorizationStatusAuthorized:{
            [self presentDeviceGalleryforUser];
        }
            
        default:
            break;
    }
    
    // commented for accessing the gallery feature for chat
    
//    if ([myMatchedObj.isMultiMediaMsgAllowed boolValue]) {
//        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
//        switch (status) {
//            case ALAuthorizationStatusDenied:
//            case ALAuthorizationStatusRestricted:
//            {
//                UIAlertController *alertObj = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Allow access to photos", nil) message:NSLocalizedString(@"Go to Settings -> Privacy -> Photos and turn Woo ON", nil)  preferredStyle:UIAlertControllerStyleAlert];
//                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)  style:UIAlertActionStyleCancel handler:nil];
//                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CMP00356", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                    [self permissionButtonTapped];
//                }];
//                [alertObj addAction:cancelAction];
//                [alertObj addAction:okAction];
//                [self presentViewController:alertObj animated:YES completion:nil];
//            }
//                break;
//            case ALAuthorizationStatusNotDetermined:
//            case ALAuthorizationStatusAuthorized:{
//                [self presentDeviceGalleryforUser];
//            }
//
//            default:
//                break;
//        }
//    }
//    else{
//        NSString *messageString = [NSString stringWithFormat:@"%@ can't recieve images as they're on older version of Woo.",_myMatchesData.matchUserName];
//        UIAlertController *multimediaAlert = [UIAlertController alertControllerWithTitle:@"Uh oh!" message:messageString  preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CMP00356", nil)  style:UIAlertActionStyleCancel handler:nil];
//        [multimediaAlert addAction:cancelAction];
//        [self presentViewController:multimediaAlert animated:YES completion:nil];
//    }
}

#pragma mark - Permission Button Tapped
-(void)permissionButtonTapped{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

-(void)userIsTypingSoMakeCallToSoTypingIndicator{
    //This method will be called whenever the user istyping the messages
    
    if(_isAppLozicUser){
        BOOL isIndicatorAlreadyOn = true;
        [[ApplozicChatManager sharedApplozicChatManager].applozic sendTypingStatusForUserId:_myMatchesData.targetAppLozicId orForGroupId:nil withTyping:true];
        isIndicatorAlreadyOn = false;
    }else{
//        if (isUserOnLayerChat) {
////            if (!self.conversation) {
////
////                ///Adding a block here would bring back conversatio id or error
//////                [[LayerManager sharedLayerManager] getConversationObjectForLayerConversationId:[MyMatches getMatchDetailForMatchedUSerID:_myMatchesData.matchedUserId isApplozic:false].layerChatID withCompletionHandler:^(BOOL isSyncCompleted, id  _Nullable conversation, NSError *error) {
//////
//////                    if(conversation != nil)
//////                    {
//////                        self.conversation  = (LYRConversation *)conversation;
//////                        [self.conversation sendTypingIndicator:LYRTypingIndicatorActionBegin];
//////                        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sendNotificationToRemoveTypingIndicator) object:nil];
//////                        [self performSelector:@selector(sendNotificationToRemoveTypingIndicator) withObject:nil afterDelay:1.5];
//////                    }
//////                }];
////            }
//            else
//            {
//                [self.conversation sendTypingIndicator:LYRTypingIndicatorActionBegin];
//                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sendNotificationToRemoveTypingIndicator) object:nil];
//                [self performSelector:@selector(sendNotificationToRemoveTypingIndicator) withObject:nil afterDelay:1.5];
//
//            }
//        }
    }
}


-(void)sendNotificationToRemoveTypingIndicator{
    //AppLozic
    // This method will be called whenever the user is about to remove the typing
    if(_isAppLozicUser){
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[ApplozicChatManager sharedApplozicChatManager].applozic sendTypingStatusForUserId:self->_myMatchesData.targetAppLozicId orForGroupId:nil withTyping:false];
            
        });
        
        
    }else{
        //Layer
////        if (!self.conversation) {
//////            [[LayerManager sharedLayerManager] getConversationObjectForLayerConversationId:[MyMatches getMatchDetailForMatchedUSerID:_myMatchesData.matchedUserId isApplozic:false].layerChatID withCompletionHandler:^(BOOL isSyncCompleted, id  _Nullable conversation, NSError *error) {
//////                if(conversation != nil)
//////                {
//////                    self.conversation  = (LYRConversation *)conversation;
//////                    [self.conversation sendTypingIndicator:LYRTypingIndicatorActionFinish];
//////                }
//////            }];
////        }
//        else
//        {
//            [self.conversation sendTypingIndicator:LYRTypingIndicatorActionFinish];
//        }
    }
}

-(void)stickerButtonTapped:(id)data{
    
    
    if ([chatMessagesArray containsObject:@{kMessageTypeKey:[NSNumber numberWithInt:TYPING]}]) {
        [chatMessagesArray removeObject:@{kMessageTypeKey:[NSNumber numberWithInt:TYPING]}];
    }
    if (isUserOnLayerChat) {
        [self sendSticker:[data objectForKey:@"stickerURL"]];
    }
    
}

-(void)sendImage:(NSDictionary *)ImageDetails withCompletionHandler:(ChatInsertionCompletionHandler)chatCompletion{
    
    if ([chatMessagesArray containsObject:@{kMessageTypeKey:[NSNumber numberWithInt:TYPING]}]) {
        [chatMessagesArray removeObject:@{kMessageTypeKey:[NSNumber numberWithInt:TYPING]}];
    }
    
    if (_isAppLozicUser){
        [[ApplozicChatHelperClass sharedApplozicChatHelperClass] insertImageIntoLocalDb:ImageDetails forChatRoom:[LoginModel sharedInstance].appLozicUserId withMatchedUser:_myMatchesData withCompletionHandler:^(ChatMessage *chatMessageObj) {
            [self checkAndAddMessageIfNotExistsInchatArray:chatMessageObj alsoAdjustContentSize:FALSE];
            if(chatCompletion)
                chatCompletion(chatMessageObj);
        }];
    }
    else{
        [[LayerChatHelperClass sharedLayerChatHelperClass] insertImageIntoLocalDb:ImageDetails forChatRoom:_myMatchesData.matchId withMatchedUserId:_myMatchesData.matchedUserId withCompletionHandler:^(ChatMessage *chatMessageObj) {
            [self checkAndAddMessageIfNotExistsInchatArray:chatMessageObj alsoAdjustContentSize:FALSE];
            if(chatCompletion)
                chatCompletion(chatMessageObj);
        }];
    }
}

-(void)reloadTableData{
    
    //[self.tableView reloadData];
    [self reloadTableDataForParticularCell:false andScrollToBottom:true andIsMessageAddedOrDeleted:false];
}

-(void)keyBoardAppeared{
}

-(void)loadMoreButtonTapped{
    float scrollViewContentHeight = self.tableView.contentSize.height;
    [chatMessagesArray removeAllObjects];
    [self returnGroupedChatMessges:[ChatMessage getAllMessageForChatRoom:_myMatchesData.matchId WithLimit:kNumberOfMessageToBeShownAtATime*(currentIndex+1)]];
    //    if ([chatArray count] <= 0){
    //        [self returnGroupedChatMessges:[ChatMessage getAllMessageForChatRoom:_myMatchesData.matchedUserId WithLimit:kNumberOfMessageToBeShownAtATime*(1)]];
    //
    //    }
    if (![ChatMessage isMoreDataAvailableForChatRoom:_myMatchesData.matchId WithIndex:currentIndex]) {
        self.tableView.tableHeaderView = nil;
    }
    
    //[self.tableView reloadData];
    [self reloadTableDataForParticularCell:false andScrollToBottom:false andIsMessageAddedOrDeleted:false];
    CGSize tableSize = self.tableView.contentSize;
    float minContentHeight = self.view.frame.size.height;
    minContentHeight += _typingView.frame.size.height; //calculating the minimum content size of the table
    if (tableSize.height < minContentHeight) {
        tableSize.height = minContentHeight;
    }else{
        tableSize.height += 50;
    }
    [self.tableView setContentSize:tableSize];
    
    [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height - scrollViewContentHeight) animated:NO];
    currentIndex++;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (chatMessagesArray) {
        return [chatMessagesArray count];
    }
    return 0;
}

-(BOOL)isLastMessageFromDifferentUser:(ChatMessage *)messageDetail{
    BOOL isThisTrue = FALSE;
    if ([messageDetail isKindOfClass:[ChatMessage class]]) {
        if (lastMessageId && ![lastMessageId isEqualToString:messageDetail.messageSenderID]) {
            isThisTrue = TRUE;
        }
    }
    return isThisTrue;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row >= [chatMessagesArray count]) {
        return 0;
    }
    
    int moreHeight = 0;
    ChatMessage *currentChatMessage = [chatMessagesArray objectAtIndex:indexPath.row];
    ChatMessage *nextChatMessage;
    if (indexPath.row < chatMessagesArray.count - 1){
        if ([[chatMessagesArray objectAtIndex:indexPath.row + 1] isKindOfClass:[ChatMessage class]]){
        nextChatMessage = [chatMessagesArray objectAtIndex:indexPath.row + 1];
        }
        else if ([[[chatMessagesArray objectAtIndex:indexPath.row + 1] valueForKey:kMessageTypeKey] intValue] == TYPING){
            moreHeight = 30;
        }
    }
    if (nextChatMessage != nil){
        if ([currentChatMessage isKindOfClass:[ChatMessage class]] && [nextChatMessage isKindOfClass:[ChatMessage class]]){
        if (![currentChatMessage.messageSenderID isEqualToString:nextChatMessage.messageSenderID]){
            moreHeight = 30;
        }
        }
    }
    else{
        if (indexPath.row == chatMessagesArray.count - 1){
            moreHeight = 30;
        }
    }

    /*
    if ([self isLastMessageFromDifferentUser:[chatMessagesArray objectAtIndex:indexPath.row] ]) {
        moreHeight = 33;
    }
    */
    
    if (([[[chatMessagesArray objectAtIndex:indexPath.row] valueForKey:kMessageTypeKey] intValue] == HEADERTIMESTAMP)) {
        return 25 + moreHeight;
    }
    else if ([[[chatMessagesArray objectAtIndex:indexPath.row] valueForKey:kMessageTypeKey] intValue] == INTRODUCTION) {
        return [self getIntroView].frame.size.height+40 + moreHeight;
    }
    else if ([[[chatMessagesArray objectAtIndex:indexPath.row] valueForKey:kMessageTypeKey] intValue] == IMAGE) {
        return 125 + moreHeight;
    }
    else if ([[[chatMessagesArray objectAtIndex:indexPath.row] valueForKey:kMessageTypeKey] intValue] == TYPING){
        return 25 + moreHeight;
    }
    else if ([[[chatMessagesArray objectAtIndex:indexPath.row] valueForKey:kMessageTypeKey] intValue] == IMAGE_SEND_BY_USER){
        return (APP_DELEGATE.window.frame.size.width * 2/3) + 3 + moreHeight;
    }
    else if ([[[chatMessagesArray objectAtIndex:indexPath.row] valueForKey:kMessageTypeKey] intValue] == MATCHED_THROUGH_CELL){
        return 35+moreHeight;
    }
    else if ([[[chatMessagesArray objectAtIndex:indexPath.row] valueForKey:kMessageTypeKey] intValue] == CRUSH_MESSAGE){
        float cellHeight = 0;
        // text
        NSString *messageText = [[chatMessagesArray objectAtIndex:indexPath.row] valueForKey:kMessageKey];
        if ([messageText length]>0) {
            cellHeight = [APP_Utilities getHeightForText:messageText forFont:kChatFont widthOfLabel:(APP_DELEGATE.window.frame.size.width - 105)];
            //reduced the height from 50 to 30. to reduce the padding and the gap between two messages. On 06 April 2015
            return cellHeight + 15 + moreHeight + 40;
            return 35+moreHeight;
        }
        return 35+moreHeight;
    }
    float cellHeight = 0;
    // text
    NSString *messageText = [[chatMessagesArray objectAtIndex:indexPath.row] valueForKey:kMessageKey];
    
    if ([messageText length]>0) {
        // cellHeight = [APP_Utilities getHeightForText:messageText forFont:kChatFont widthOfLabel:(APP_DELEGATE.window.frame.size.width*2/3 - 33 - 5)];
        //reduced the height from 50 to 30. to reduce the padding and the gap between two messages. On 06 April 2015
        int extraHeightForFirstChat = 0;
        if (indexPath.row == 0){
            extraHeightForFirstChat = 10;
        }
        
        if ([[[chatMessagesArray objectAtIndex:indexPath.row] valueForKey:kMessageSenderIDKey] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]]) {
            cellHeight = [APP_Utilities getHeightForText:messageText forFont:kChatFont widthOfLabel:(APP_DELEGATE.window.frame.size.width*2/3 - 33 - 5)];
            return cellHeight + 23 + moreHeight + extraHeightForFirstChat; //30 is top and bottom padding
        }
        else{
            cellHeight = [APP_Utilities getHeightForText:messageText forFont:kChatFont widthOfLabel:(APP_DELEGATE.window.frame.size.width*2/3 - 20)];
            return cellHeight + 23 + moreHeight + extraHeightForFirstChat;
        }
        return cellHeight + 23 + moreHeight + extraHeightForFirstChat;
    }
    //reduced the height from 50 to 30. to reduce the padding and the gap between two messages. On 06 April 2015
    return cellHeight;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if ((indexPath.row >= [chatMessagesArray count]) ||   (![[chatMessagesArray objectAtIndex:indexPath.row] valueForKey:kMessageTypeKey])) {
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    }
    
    if ([[[chatMessagesArray objectAtIndex:indexPath.row] valueForKey:kMessageTypeKey] intValue] == HEADERTIMESTAMP) {
        static NSString *cellIdentifier = @"ChatTimeCell";
        
        ChatTimeCell *cell = (ChatTimeCell *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[ChatTimeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        [cell setChatTime:[[chatMessagesArray objectAtIndex:indexPath.row] valueForKey:kMessageKey]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }
    else if ([[[chatMessagesArray objectAtIndex:indexPath.row] valueForKey:kMessageTypeKey] intValue] == INTRODUCTION){
        
        static NSString *introCellIdentifier = @"IntroCell";
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:introCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:introCellIdentifier];
            
        }
        
        [cell.contentView addSubview:[self getIntroView]];
        return cell;
    }
    else if([[[chatMessagesArray objectAtIndex:indexPath.row] valueForKey:kMessageTypeKey] intValue] == IMAGE){
        static NSString *cellIdentifier = @"ChatStickerCell";
        ChatMessage *chatMsgObj = [chatMessagesArray objectAtIndex:indexPath.row];
        lastMessageId = chatMsgObj.messageSenderID;
        ChatStickerCell *cell = (ChatStickerCell *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[ChatStickerCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        if ([[[chatMessagesArray objectAtIndex:indexPath.row] valueForKey:kMessageSenderIDKey] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]]) {
            [cell alignImageViewToLeft:FALSE];
        }
        else{
            [cell alignImageViewToLeft:TRUE];
        }
        [cell showImage:[[chatMessagesArray objectAtIndex:indexPath.row] valueForKey:kMessageKey]];
        return cell;
    }
    else if([[[chatMessagesArray objectAtIndex:indexPath.row] valueForKey:kMessageTypeKey] intValue] == IMAGE_SEND_BY_USER){
        
        ChatMessage *chatMsgObj = [chatMessagesArray objectAtIndex:indexPath.row];
        lastMessageId = chatMsgObj.messageSenderID;
        NSString *userID = nil;
        if (_isAppLozicUser){
            userID = [LoginModel sharedInstance].appLozicUserId;
        }
        else{
            userID = [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId];
        }
        BOOL isSenderMe = [[[chatMessagesArray objectAtIndex:indexPath.row] valueForKey:kMessageSenderIDKey] isEqualToString:userID];
        
        if (isSenderMe) {
            static NSString *cellIdentifier = @"SenderChatImageCell";
            SenderImageCell *cell = (SenderImageCell *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[SenderImageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            [cell setDelegate:self];
            [cell retryButtonTappedBlock:^(ChatMessage *messageObj) {
                [self imageButtonTapped:messageObj];
            }];
            [cell setImageSendByTheUser:[chatMessagesArray objectAtIndex:indexPath.row] isSendertagged:self.myMatchesData.isRequesterFlagged.boolValue isApplozic:_isAppLozicUser];
            return cell;
            
        }
        else{
            static NSString *cellIdentifier = @"RecieverChatImageCell";
            RecieverImageCell *cell = (RecieverImageCell *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[RecieverImageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            [cell setDelegate:self];
            [cell downloadButtonTappedBlock:^(ChatMessage *messageObj) {
                [self imageButtonTapped:messageObj];
            }];
            [cell setImageRecievedByTheUser:[chatMessagesArray objectAtIndex:indexPath.row]];
            return cell;
        }
    }
    else if ([[[chatMessagesArray objectAtIndex:indexPath.row] valueForKey:kMessageTypeKey] intValue] == MATCHED_THROUGH_CELL){
        static NSString *cellIdentifier = @"matchThroughCell";
        MatchedThroughCell *cell = (MatchedThroughCell *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[MatchedThroughCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        [cell setCellTextAccrodingToMatchType:_myMatchesData.source];
        return cell;
        
    }
    else if ([[[chatMessagesArray objectAtIndex:indexPath.row] valueForKey:kMessageTypeKey] intValue] == TYPING){
        
        static NSString *cellIdentifier = @"typingCell";
        TypingCell *cell = (TypingCell *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
//        if (cell == nil) {
//            cell = [[TypingCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//        }
//        if ([cell respondsToSelector:@selector(animateImage)]) {
//            [cell animateImage];
//            [cell performSelector:@selector(animateImage) withObject:nil afterDelay:0.3];
//
//        }
        return cell;
    } else if ([[[chatMessagesArray objectAtIndex:indexPath.row] valueForKey:kMessageTypeKey] intValue] == TYPING_AREA_CELL){
        
        static NSString *cellIdentifier = @"typingAreaCell";
        TypingAreaCell *cell = (TypingAreaCell *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[TypingAreaCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        return cell;
        
    }
    else if ([[[chatMessagesArray objectAtIndex:indexPath.row] valueForKey:kMessageTypeKey] intValue] == CRUSH_MESSAGE){
        
        static NSString *cellIdentifier = @"CrushMessageCell";
        
        CrushMessageCell *cell = (CrushMessageCell *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[CrushMessageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        ChatMessage *chatMsgObj = [chatMessagesArray objectAtIndex:indexPath.row];
        lastMessageId = chatMsgObj.messageSenderID;
        
        [cell setChatMessageData:[[chatMessagesArray objectAtIndex:indexPath.row] valueForKey:kMessageKey] andIsSender:TRUE andSoWeNeedToChangeYPos:[self isLastMessageFromDifferentUser:chatMsgObj]];
        
        return cell;
        
    }
    else{
        
        NSString *userId = @"";
        if (_isAppLozicUser){
            userId = LoginModel.sharedInstance.appLozicUserId;
        }
        else{
            userId = [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId];
        }
        if ([[[chatMessagesArray objectAtIndex:indexPath.row] valueForKey:kMessageSenderIDKey] isEqualToString:userId] || [[[chatMessagesArray objectAtIndex:indexPath.row] valueForKey:kMessageSenderIDKey] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]]) {
            static NSString *cellIdentifier = @"SenderMessageCell";
            
            SenderMessageCell *cell = (SenderMessageCell *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[SenderMessageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            if (indexPath.row == 0){
                cell.chatBackgroundviewTopConstraint.constant = 13.0;
            }
            else{
                cell.chatBackgroundviewTopConstraint.constant = 3.0;
            }
            
            ChatMessage *chatMsgObj = [chatMessagesArray objectAtIndex:indexPath.row];
            
            NSNumber *messageCreatedTime = [chatMsgObj chatMessageCreatedTime];
            NSString *messageTimeString = messageCreatedTime.stringValue;
            NSTimeInterval _interval=[messageTimeString doubleValue]/1000;
            NSDate *dateOfMessage = [NSDate dateWithTimeIntervalSince1970:_interval];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"hh:mm a"];
            NSLog(@"Time: %@", [formatter stringFromDate:dateOfMessage]);
            [cell.timeLabel setText:[formatter stringFromDate:dateOfMessage]];
            
            lastMessageId = chatMsgObj.messageSenderID;
            
            [cell setChatMessageData:[[chatMessagesArray objectAtIndex:indexPath.row] valueForKey:kMessageKey] andIsSender:TRUE andSoWeNeedToChangeYPos:[self isLastMessageFromDifferentUser:chatMsgObj]];
            [cell showDeliveryIcon:isUserOnLayerChat&&TRUE &&(([[APP_Utilities validString:[[chatMessagesArray objectAtIndex:indexPath.row] valueForKey:kChatMessageLayerID]] length]>0)?TRUE:FALSE)];
            
//            [cell setMessageStatusIcon:[[[chatMessagesArray objectAtIndex:indexPath.row] valueForKey:kChatMessageDeliveryLayerStatus] intValue] applozic:_isAppLozicUser];
            
            return cell;
        }
        else{
            static NSString *cellIdentifier = @"ReceiverMessageCell";
            ReceiverMessageCell *cell = (ReceiverMessageCell *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[ReceiverMessageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            
            if (indexPath.row == 0){
                cell.chatBackgroundViewTopConstraint.constant = 13.0;
            }
            else{
                cell.chatBackgroundViewTopConstraint.constant = 3.0;
            }
            
            ChatMessage *chatMsgObj = [chatMessagesArray objectAtIndex:indexPath.row];
            
            NSNumber *messageCreatedTime = [chatMsgObj chatMessageCreatedTime];
            NSString *messageTimeString = messageCreatedTime.stringValue;
            NSTimeInterval _interval=[messageTimeString doubleValue]/1000;
            NSDate *dateOfMessage = [NSDate dateWithTimeIntervalSince1970:_interval];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"hh:mm a"];
            NSLog(@"Time: %@", [formatter stringFromDate:dateOfMessage]);
            [cell.timeLabel setText:[formatter stringFromDate:dateOfMessage]];
            
            lastMessageId = chatMsgObj.messageSenderID;
            
            [cell setChatMessageData:[[chatMessagesArray objectAtIndex:indexPath.row] valueForKey:kMessageKey] andIsSender:FALSE andSoWeNeedToChangeYPos:[self isLastMessageFromDifferentUser:chatMsgObj]];
            
            NSLog(@"ReceiverMessageCell me ghus gya hai");
            return cell;
            
        }
    }
    
    return nil;
}
-(void)imageButtonTapped:(ChatMessage *)chatMessageDetail{
    if ([chatMessageDetail.messageType intValue] == IMAGE_SEND_BY_USER) {
        UIStoryboard *storyBoardObj = [UIStoryboard storyboardWithName:@"onboarding" bundle:nil];
        ImageGalleryController *imageGalleryObj = [storyBoardObj instantiateViewControllerWithIdentifier:@"ImageGalleryControllerID"];
        [imageGalleryObj setNeedToShowFullImages:TRUE];
        [imageGalleryObj createGalleryWithImagesFromArray:[NSMutableArray arrayWithObject:@{kBigImageSourceKey:chatMessageDetail.message}]];
        [self.navigationController pushViewController:imageGalleryObj animated:YES];
        [[WooScreenManager sharedInstance] hideHomeViewTabBar:TRUE isAnimated:FALSE];
    };
}

-(NSArray *)returnGroupedChatMessges:(NSArray *)ungroupedChatMessages{
    // NSTimeInterval currentTime = ([[NSDate date] timeIntervalSince1970]*1000); //I have added this 2 secs to make the sorting right as I was getting 100000 difference in values.
    
    NSMutableArray *ungroupedChatArray = [[NSMutableArray alloc] initWithArray:ungroupedChatMessages];
    
    ChatMessage *lastMessage = [ungroupedChatArray lastObject];
    //gettign value to start grouping
    NSTimeInterval currentTime = [[lastMessage chatMessageCreatedTime] doubleValue];
    NSTimeInterval startTime = currentTime;
    //time difference
    long long timeDifference = 60000*kTimeIntervalForGroupingMessageInMinutes;
    //iterating through values in ungrouped descending order.
    BOOL doesChatContainAnyLayerMessages = NO;
    if ([ungroupedChatArray count]>0) {
        
        //Add intro only of no layer messages have been exchanged between participants
        
        //        [chatMessagesArray addObject:[ungroupedChatArray lastObject]];
        //        [ungroupedChatArray removeLastObject];
        
        while ([ungroupedChatArray count] > 0) {
            ChatMessage *chatMesgObj = [ungroupedChatArray lastObject];
            if(chatMesgObj.messageType.intValue == TEXT || chatMesgObj.messageType.intValue == IMAGE || chatMesgObj.messageType.intValue == AUDIO || chatMesgObj.messageType.intValue == IMAGE_SEND_BY_USER )
            {
                doesChatContainAnyLayerMessages = YES;
            }
            if (startTime - [chatMesgObj.chatMessageCreatedTime doubleValue] < timeDifference) {
                //Add in array
                [chatMessagesArray insertObject:[ungroupedChatArray lastObject] atIndex:0];
                [ungroupedChatArray removeLastObject];
            }
            else{
                long long numberOfFrameToBeMissed = (startTime - [chatMesgObj.chatMessageCreatedTime doubleValue])/timeDifference;
                /*
                [chatMessagesArray insertObject:@{kMessageKey : [APP_Utilities getDateStringForTimeInterval:((startTime-timeDifference)/1000) withDateFormatting:kTimeFormateForHeaderTimeStamp],
                                                  kMessageTypeKey:[NSNumber numberWithInt:HEADERTIMESTAMP]
                                                  } atIndex:0];
                 */
                
                startTime = startTime - (timeDifference *numberOfFrameToBeMissed);
            }
        }
        
        //see if doesChatContainAnyLayerMessages is true
        //remove intro
        /*
        if(doesChatContainAnyLayerMessages)
        {
            if(chatMessagesArray.count>1){
                ChatMessage *chatMsg = [chatMessagesArray objectAtIndex:0];
                if (chatMsg) {
                    if([[chatMsg valueForKey:kMessageTypeKey] intValue]==INTRODUCTION)
                    {
                        [chatMessagesArray removeObject:chatMsg];
                    }
                }
            }
        }
         */
        
        
        //Intro message
        if(chatMessagesArray.count>1){
            for (ChatMessage *chatMsg in chatMessagesArray){
                if (chatMsg) {
                    if([[chatMsg valueForKey:kMessageTypeKey] intValue]==INTRODUCTION){
                                if ([chatMessagesArray containsObject:chatMsg]) {
                                    [chatMessagesArray removeObject:chatMsg];
                                }
                        break;
                    }
                }
            }
        }
    }
    //ungroupedChatArray = nil;
    return chatMessagesArray;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    __weak NewChatViewController * weakSelf = self;
    if ([segue.identifier isEqual:kPushToDetailProfileFromChatRoom]){
        ProfileCardModel *modelObj = (ProfileCardModel *)sender;
        ProfileDeckDetailViewController *vc = (ProfileDeckDetailViewController *)segue.destinationViewController;
//        [vc setConversation:self.conversation];
        [vc setIsProfileAlreadyLoaded:false];
        [vc setIsActionButtonHidden:TRUE];
        [vc setProfileData:modelObj];
        [vc setIsViewPushed:TRUE];
        [vc showActionButtonContainerView:FALSE];
        [vc setIsActionButtonHidden:TRUE];
        [vc setMyMatchesData:self.myMatchesData];
        if (_parentView == DetailProfileViewParentMatchboxView) {
            [vc setDidCameFromChat:TRUE];
        }
        [[WooScreenManager sharedInstance] hideHomeViewTabBar:TRUE isAnimated:FALSE];
        vc.popToChatFromSendMessagebjC = ^{
            weakSelf.openKeyboardForTyping = YES;
        };
    }
    if ([[segue identifier] isEqualToString:kPushChatRoomToChats])
    {
        
    }
}

-(NSInteger) isMessage:(ChatMessage *)messageObj existsInArray:(NSMutableArray *)chatArray{
    if (isUserOnLayerChat && messageObj.layerMessageID) {
        NSArray *clientIdArray = [chatArray valueForKey:@"layerMessageID"];
        if ([clientIdArray count]>0) {
            if ([clientIdArray containsObject:messageObj.layerMessageID]) {
                NSInteger indexVal = [clientIdArray indexOfObject:messageObj.layerMessageID];
                ChatMessage *sameMessage = [chatArray objectAtIndex:indexVal];
                if ([sameMessage.messageSenderID isEqualToString:messageObj.messageSenderID]) {
                    return indexVal;
                }
                
            }
        }
    }
    else{
        NSArray *clientIdArray = [chatArray valueForKey:@"clientMessageID"];
        if ([clientIdArray count]>0) {
            if ([clientIdArray containsObject:messageObj.clientMessageID]) {
                NSInteger indexVal = [clientIdArray indexOfObject:messageObj.clientMessageID];
                ChatMessage *sameMessage = [chatArray objectAtIndex:indexVal];
                if ([sameMessage.messageSenderID isEqualToString:messageObj.messageSenderID]) {
                    return indexVal;
                }
                
            }
        }
    }
    return -1;
}

-(void)showReportWarning{
    
    
    UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Report %@?", nil),_myMatchesData.matchUserName] message:NSLocalizedString(@"This user will be removed from your matches and messages, and will not be able to contact you again. Continue?",nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *leftButtonAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //        area.hidden = FALSE;
    }];
    UIAlertAction *rightButtonAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showReportOptionstoUserForButtonTapped];
        //        area.hidden = FALSE;
    }];
    
    [alertViewController addAction:leftButtonAction];
    [alertViewController addAction:rightButtonAction];
    
    [self presentViewController:alertViewController animated:YES completion:nil];
    [_typingView setUserInteractionEnabled:false];
}

#pragma mark - Show Report Warning Alert Button Tapped
-(void)showReportOptionstoUserForButtonTapped{
    CGRect reportViewFrame = self.view.frame;
    reportViewFrame.origin.y = self.tableView.contentSize.height - self.view.frame.size.height;
    ReportUserView *reportView = [[ReportUserView alloc]initWithFrame:self.view.bounds];
    [reportView setReportViewType:reportUser];
    [reportView setReportedViewController:self];
    [reportView setHeaderForReportViewType:reportUser];
    [reportView setUserToBeFlagged:_myMatchesData.matchedUserId];
    [reportView setDelegate:self];
    [reportView setIsAlreadMatched:TRUE];
    [reportView setSelectorForUserFlagged:@selector(showUserReportedAnimation)];
    [reportView setSelectorForCancelButtonTapped:@selector(cancelButtonTapped)];
    
    [APP_DELEGATE.window addSubview:reportView];
    
    //Keyboard manager enabled for Report view
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:TRUE];
    self.tableView.scrollEnabled = FALSE;
    
}

-(void)showUnmatchOptionstoUserForButtonTapped{
    CGRect reportViewFrame = self.view.frame;
    reportViewFrame.origin.y = self.tableView.contentSize.height - self.view.frame.size.height;
    ReportUserView *reportView = [[ReportUserView alloc]initWithFrame:self.view.bounds];
    [reportView setReportViewType:reasonsForUnmatch];
    [reportView setReportedViewController:self];
    [reportView setHeaderForReportViewType:reasonsForUnmatch];
    
    
    [reportView setDelegate:self];
    [reportView setReasonsDelegate:self];
    [reportView setSelectorForCancelButtonTapped:@selector(cancelButtonTapped)];
    [APP_DELEGATE.window addSubview:reportView];
    
    //Keyboard manager enabled for Unmatch view
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:TRUE];
    self.tableView.scrollEnabled = FALSE;
    
}

-(void)cancelButtonTapped{
    self.tableView.scrollEnabled = TRUE;
}

-(void)reasonsForUnmatchOrDelete:(NSString *)comment
{
    if(comment == nil){
        comment = @"";
    }
    [self deleteConfirmationCallback:(MyMatches *)_myMatchesData andCommentForUnmatch:comment];
}

-(void)showUserReportedAnimation{
    
    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"Report" forScreenName:@"Chat"];
    /*
    MDSnackbar *snackBarObj = [[MDSnackbar alloc] initWithText:NSLocalizedString(@"User reported",nil) actionTitle:nil duration:2.0f];
    snackBarObj.multiline = TRUE;
    [snackBarObj show];
     */
    
    if ([_delegateFromMatch respondsToSelector:_selectorToDeleteRow]) {
        [_delegateFromMatch performSelector:_selectorToDeleteRow withObject:_myMatchesData afterDelay:0.1];
        [self backButtonTapped];
        NSLog(@"NewChatVc inside removeViewOnTappingNewNotification");
        
    }
    else{
        MyMatches *matchedObject = [MyMatches getMatchDetailForMatchedUSerID:_myMatchesData.matchedUserId isApplozic:false];
        [self infromServerAboutDeletionOfAMatchWithMatchID:matchedObject withCommentForUnmatch:@""];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserHasBeenBlocked object:[NSString stringWithFormat:@"%@",_myMatchesData.matchedUserId]];
    
    //Keyboard manager disabled after Report
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:FALSE];
    [_typingView setUserInteractionEnabled:true];
    self.tableView.scrollEnabled = TRUE;
}

#pragma  Layer Chat
#pragma ====================Start here==================

- (IBAction)sendButtonTapped:(id)sender {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kChatMessageSentFirstTime] && [[NSUserDefaults standardUserDefaults] boolForKey:kChatMessageSentFirstTime] == NO) {
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kChatMessageSentFirstTime];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    NSString *enteredText = [_chatTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (_isAppLozicUser){
        [self sendMessageThroughApplozic:enteredText];
        
    }else{
        //Layer
        if ([chatMessagesArray containsObject:@{kMessageTypeKey:[NSNumber numberWithInt:TYPING] }]) {
            [chatMessagesArray removeObject:@{kMessageTypeKey:[NSNumber numberWithInt:TYPING] }];
        }
        if (isUserOnLayerChat) {
            [self sendMessage:enteredText];
        }
    }
    
    [_sendButton setSelected:false];
    [_chatTextView setText:@""];
}
- (void)sendMessage:(NSString *)messageText{
    // If no conversations exist, create a new conversation object with two participants
    // For the purposes of this Quick Start project, the 3 participants in this conversation are 'Device'  (the authenticated user id), 'Simulator', and 'Dashboard'.
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [APP_DELEGATE sendSwrveEventWithEvent:@"3-Matchbox.Chatbox.MC_SendTextMessage" andScreen:@"Chatbox"];
        
//        [[LayerManager sharedLayerManager] sendChatToLayer:messageText ForMimeType:MIME_TYPE_TEXT withPushText:messageText forConversation:self.conversation isRequesterFlagged:self.myMatchesData.isRequesterFlagged.boolValue chatSendToLayerCompletion:^(BOOL chatSendSuccessFully, LYRMessage *layerMessageObj) {
//            //need to add code to add message from here.
//            //check if the message id received here and message if that is received in Layer sync method is same
//            [LAYER_HELPER insertLayerChatFromToLocalDB:layerMessageObj withCompletionHandler:^(ChatMessage *chatMessageObj) {
//                //
//                [self checkAndAddMessageIfNotExistsInchatArray:chatMessageObj alsoAdjustContentSize:FALSE];
//                // Sends the specified message
//                NSError *error = nil;
//                [self.conversation sendMessage:layerMessageObj error:&error];
//                [self.conversation sendTypingIndicator:LYRTypingIndicatorActionFinish];
//
//            }];
//        }];
    });
    
}

- (void)sendSticker:(NSString *)messageText{
    
    //  [APP_DELEGATE sendSwrveEventWithEvent:@"Chat.Sticker" andScreen:@"Chat"];
    [APP_DELEGATE sendSwrveEventWithEvent:@"3-Matchbox.Chatbox.MC_SendMultiMediaMessage" andScreen:@"Chatbox"];
    
    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"SendSticker" forScreenName:@"Chat"];
    //    if (!self.conversation) {
    //        [self initialiseConversationObject];
    //        if (!self.conversation) {
    //            //NSLog(@"New Conversation creation failed.");
    //        }
    //    }
    
//    if (!self.conversation) {
//        ///Adding a block here would bring back conversatio id or error
////        [[LayerManager sharedLayerManager] getConversationObjectForLayerConversationId:[MyMatches getMatchDetailForMatchedUSerID:_myMatchesData.matchedUserId isApplozic:false].layerChatID withCompletionHandler:^(BOOL isSyncCompleted, id  _Nullable conversation, NSError *error) {
////
////            if(conversation != nil)
////            {
////                self.conversation  = (LYRConversation *)conversation;
////
////                [[LayerManager sharedLayerManager] sendChatToLayer:messageText ForMimeType:MIME_TYPE_IMAGE_PNG withPushText:kStickerText forConversation:self.conversation isRequesterFlagged:self.myMatchesData.isRequesterFlagged.boolValue chatSendToLayerCompletion:^(BOOL chatSendSuccessFully, LYRMessage *layerMessageObj) {
////                }];
////            }
////
////        }];
//    }
//    else
//    {
////        [[LayerManager sharedLayerManager] sendChatToLayer:messageText ForMimeType:MIME_TYPE_IMAGE_PNG withPushText:kStickerText forConversation:self.conversation isRequesterFlagged:self.myMatchesData.isRequesterFlagged.boolValue chatSendToLayerCompletion:^(BOOL chatSendSuccessFully, LYRMessage *layerMessageObj) {
////        }];
//    }
    
}

//-(void)markAllMessagesAsRead{
//
//    NSError *error = nil;
//    //   if(![self.conversation markAllMessagesAsRead:&error])
//    //   {
//    //       NSLog(@"Message Read Status error %@",error);
////    //   }
////    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRMessage class]];
////    LYRPredicate *conversationPredicate = [LYRPredicate predicateWithProperty:@"conversation" predicateOperator:LYRPredicateOperatorIsEqualTo value:self.conversation];
////    LYRPredicate *unreadPredicate = [LYRPredicate predicateWithProperty:@"isUnread" predicateOperator:LYRPredicateOperatorIsEqualTo value:@(YES)];
//    //    LYRPredicate *userPredicate = [LYRPredicate predicateWithProperty:@"sender.userID" predicateOperator:LYRPredicateOperatorIsNotEqualTo value:self.myMatchesData.matchedUserId];
//    query.predicate = [LYRCompoundPredicate compoundPredicateWithType:LYRCompoundPredicateTypeAnd subpredicates:@[conversationPredicate, unreadPredicate]];//, userPredicate]];
//
//    NSOrderedSet *messages = [APP_DELEGATE.layerClient executeQuery:query error:&error];
//    for (LYRMessage *msg in messages) {
//        [msg markAsRead:&error];
//    }
//    if (!error) {
//        //        NSLog(@"%@ - messages in conversation", messages);
//    } else {
//        NSLog(@"Query failed with error %@", error);
//    }
//}


//-(void)insertLayerChatIntoLocalDB:(LYRMessage *)messageObj{
//    if (!messageObj) {
//        return;
//    }
//    [[LayerChatHelperClass sharedLayerChatHelperClass] insertLayerChatFromToLocalDB:messageObj withCompletionHandler:^(ChatMessage *chatMessageObj) {
//        [self checkAndAddMessageIfNotExistsInchatArray:chatMessageObj alsoAdjustContentSize:FALSE];
//    }];
//
//}
//-(void)updateLayerChatIntoLocalDB:(LYRMessage *)messageObj{
//    if (!messageObj) {
//        return;
//    }
//    [[LayerChatHelperClass sharedLayerChatHelperClass] updateLayerChatFromToLocalDB:messageObj withCompletionHandler:^(ChatMessage *chatMessageObj) {
//        if(chatMessageObj){
//            [self checkAndAddMessageIfNotExistsInchatArray:chatMessageObj alsoAdjustContentSize:FALSE];
//        }
//    }];
//}


-(void)checkAndAddMessageIfNotExistsInchatArray:(ChatMessage *)chatObj alsoAdjustContentSize:(BOOL)adjustContentSize{
    
    if ([self isMessage:chatObj existsInArray:chatMessagesArray] == -1) {
        //check if array contains any messsages of INTRO type
        ChatMessage *chatMesgObj = chatMessagesArray.firstObject;
        if([[chatMesgObj valueForKey:kMessageTypeKey] intValue] == INTRODUCTION)
        {
            [chatMessagesArray removeObjectAtIndex:0];
        }
        
        if (chatObj) {
            
            [chatMessagesArray addObject:chatObj];
            //            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[chatMessagesArray count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationMiddle];
           // [self.tableView reloadData];
            [self reloadTableDataForParticularCell:true andScrollToBottom:true andIsMessageAddedOrDeleted:true];
            
        }
    }
    else{
        if ([chatMessagesArray containsObject:chatObj]) {
            NSInteger indexVal = [chatMessagesArray indexOfObject:chatObj];
            [chatMessagesArray replaceObjectAtIndex:indexVal withObject:chatObj];
                        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexVal inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            //[self.tableView reloadData];
            //[self reloadTableDataForParticularCell:false andScrollToBottom:false andIsMessageAddedOrDeleted:false];
            
        }
    }
    if (isUserTyping) {
        if (![chatMessagesArray containsObject:@{kMessageTypeKey:[NSNumber numberWithInt:TYPING]}]) {
            [chatMessagesArray addObject:@{kMessageTypeKey:[NSNumber numberWithInt:TYPING]}];
        }
        else{
            if ([chatMessagesArray containsObject:@{kMessageTypeKey:[NSNumber numberWithInt:TYPING]}]) {
                [chatMessagesArray removeObject:@{kMessageTypeKey:[NSNumber numberWithInt:TYPING]}];
            }
            [chatMessagesArray addObject:@{kMessageTypeKey:[NSNumber numberWithInt:TYPING]}];
        }
        [self reloadTableDataForParticularCell:true andScrollToBottom:true andIsMessageAddedOrDeleted:true];
       // [self.tableView reloadData];
    }
}

- (void)reloadTableDataForParticularCell:(BOOL)reloadSection andScrollToBottom:(BOOL)shouldScrollToBottom andIsMessageAddedOrDeleted:(BOOL)added{
    //Scroll to bottom
    
    NSInteger chatMessagesCount = [chatMessagesArray count];
    if(chatMessagesCount > 0)
    {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow: (chatMessagesCount - 1) inSection:0];
        if (reloadSection){
        //[self.tableView beginUpdates];
        NSArray *arr = [NSArray arrayWithObject:indexPath];
            if (added){
                if (chatMessagesCount > 1){
                    if ([[[chatMessagesArray objectAtIndex:indexPath.row] valueForKey:kMessageTypeKey] intValue] == TYPING){
                        [self.tableView reloadData];
                    }
                    else{
                        ChatMessage *currentChatMessage = [chatMessagesArray objectAtIndex:indexPath.row];
                        ChatMessage *lastChatMessage = [chatMessagesArray objectAtIndex:indexPath.row - 1];
                            if ([currentChatMessage isKindOfClass:[ChatMessage class]] && [lastChatMessage isKindOfClass:[ChatMessage class]]){
                                if ([currentChatMessage.messageSenderID isEqualToString:lastChatMessage.messageSenderID]){
                                    [self.tableView insertRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationNone];
                                }
                                else{
                                    [self.tableView reloadData];
                                }
                            }
                            else{
                                [self.tableView reloadData];
                            }
                    }
                }
                else{
                    [self.tableView reloadData];
                }
            }
            else{
                [self.tableView deleteRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationNone];
            }
        //[self.tableView endUpdates];
        }
        else{
            [self.tableView reloadData];
        }
        if (shouldScrollToBottom){
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }
}

-(void)initialiseConversationObject{
//    if (!self.conversation) {
//
//        ///Adding a block here would bring back conversatio id or error
////        [[LayerManager sharedLayerManager] getConversationObjectForLayerConversationId:[MyMatches getMatchDetailForMatchedUSerID:_myMatchesData.matchedUserId isApplozic:false].layerChatID withCompletionHandler:^(BOOL isSyncCompleted, id  _Nullable conversation, NSError *error) {
////
////            if(conversation != nil)
////            {
////                self.conversation  = (LYRConversation *)conversation;
////            }
////        }];
//    }
}

#pragma ===================End here===============
#pragma Layer Chat
-(UIView *)getIntroView{
    
    float xPos = 20;
    MyMatches *myMathcesObj = [MyMatches getIntroMessageForWooUserID:_myMatchesData.matchedUserId];
    if (!introView) {
        introView = [[UIView alloc] initWithFrame:CGRectMake(xPos, 20, SCREEN_WIDTH-40, 80)];
        
        introView.backgroundColor = [UIColor clearColor];
        
        
        int Ypos = 15;
        
        UILabel *matchedWithLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, Ypos, introView.frame.size.width - 20, 25)];
        matchedWithLbl.font = [UIFont fontWithName:@"Lato-Regular" size:18];
        matchedWithLbl.textColor = [APP_Utilities getUIColorObjectFromHexString:@"#72778A" alpha:1.0];
        matchedWithLbl.text = [NSString stringWithFormat:@"You matched with %@", _myMatchesData.matchUserName];
        matchedWithLbl.textAlignment = NSTextAlignmentCenter;
        [introView addSubview:matchedWithLbl];
        
        
        Ypos = Ypos + 30;
        
        UILabel *matchedTimeLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, Ypos, introView.frame.size.width - 20, 20)];
        matchedTimeLbl.textAlignment = NSTextAlignmentCenter;
        matchedTimeLbl.font = [UIFont fontWithName:@"Lato-Regular" size:14];
        matchedTimeLbl.textColor = [APP_Utilities getUIColorObjectFromHexString:@"#72778A" alpha:1.0];
        matchedTimeLbl.text = [NSString stringWithFormat:@"(%@ ago)", [APP_Utilities returnDateStringOfTimestamp:_myMatchesData.matchedOn]];
        [introView addSubview:matchedTimeLbl];
        
        Ypos = Ypos + 25;
        
        //float change = SCREEN_WIDTH/320;
        
        
        float width = 200;
        float height = 120;
        xPos = (introView.frame.size.width - width)/2;
        NSString *rightUserImageURL;
        //= myMathcesObj.matchUserPic;
        
        if (![myMathcesObj.matchUserPic hasPrefix:kImageCroppingServerURL])
        {
            int mewidth = [[Utilities sharedUtility] getImageSizeForPoints:150];
            int meheight = mewidth * 3/2;
            rightUserImageURL = [NSString stringWithFormat:@"%@?url=%@&width=%d&height=%d",kImageCroppingServerURL,myMathcesObj.matchUserPic,mewidth,meheight];
        }
        else{
            rightUserImageURL = myMathcesObj.matchUserPic;
        }
        
        
        NSString *leftUserImageURL = DiscoverProfileCollection.sharedInstance.myProfileData.wooAlbum.profilePicUrl;
        
        if(![leftUserImageURL hasPrefix:kImageCroppingServerURL])
        {
            int mewidth = [[Utilities sharedUtility] getImageSizeForPoints:150];
            int meheight = mewidth * 3/2;
            
            leftUserImageURL = [NSString stringWithFormat:@"%@?url=%@&width=%d&height=%d",kImageCroppingServerURL,[APP_Utilities encodeFromPercentEscapeString:DiscoverProfileCollection.sharedInstance.myProfileData.wooAlbum.profilePicUrl],mewidth,meheight];
        }
        else
        {
            leftUserImageURL = [APP_Utilities encodeFromPercentEscapeString:DiscoverProfileCollection.sharedInstance.myProfileData.wooAlbum.profilePicUrl];
        }
        
        MatchedUsersImageView *matchedUserViewObj = [[MatchedUsersImageView alloc] initWithFrame:CGRectMake(xPos, Ypos, width, height)];
        [matchedUserViewObj setLeftUserImage:leftUserImageURL getFromUrl:TRUE andRightUserImage:rightUserImageURL getFromURl:TRUE];
        [introView addSubview:matchedUserViewObj];
        Ypos = Ypos + height+20;
        
        NSString *introText = myMathcesObj.matchIntroText;
        if ([introText length]<1) {
            introText = @"";
        }
        
        float labelHeight = [APP_Utilities getHeightForText:introText forFont:[UIFont fontWithName:@"Lato-Medium" size:18] widthOfLabel:200];
        UILabel *matchedIntroText = [[UILabel alloc] initWithFrame:CGRectMake(25, Ypos, introView.frame.size.width-50, labelHeight)];
        matchedIntroText.textColor = [APP_Utilities getUIColorObjectFromHexString:@"#373A43" alpha:1.0];
        matchedIntroText.font = [UIFont fontWithName:@"Lato-Medium" size:18];
        matchedIntroText.text = introText;
        matchedIntroText.numberOfLines = 0;
        matchedIntroText.textAlignment = NSTextAlignmentCenter;
        Ypos = Ypos + labelHeight;
        [introView addSubview:matchedIntroText];
        
        Ypos = Ypos + 20;
        
        float tipsWidth = 150;
        float tipsHeight = 30;
        float tipsXpos = (introView.frame.size.width - tipsWidth)/2;
        
        UIButton *tipsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        tipsButton.frame = CGRectMake(tipsXpos, Ypos, tipsWidth, tipsHeight);
        [tipsButton setImage:[UIImage imageNamed:@"ic_chat_info"] forState:UIControlStateNormal];
        [tipsButton setTitle:NSLocalizedString(@"  Safe Match Tips",nil) forState:UIControlStateNormal];
        [tipsButton setBackgroundColor:[[Utilities sharedUtility] getUIColorObjectFromHexString:@"#F6FBF7" alpha:1.0]];
        [tipsButton setTitleColor:[[Utilities sharedUtility] getUIColorObjectFromHexString:@"#FA4849" alpha:1.0] forState:UIControlStateNormal];
        tipsButton.layer.borderColor = [[Utilities sharedUtility] getUIColorObjectFromHexString:@"#FA4849" alpha:1.0].CGColor;
        tipsButton.layer.borderWidth = 2.0f;
        [tipsButton.titleLabel setFont:[UIFont fontWithName:@"Lato-Medium" size:14]];
        [tipsButton addTarget:self action:@selector(showPostMatchTipsView) forControlEvents:UIControlEventTouchUpInside];
        [introView addSubview:tipsButton];
        CGRect viewFrame = introView.frame;
        viewFrame.size.height = Ypos + 30;
        introView.frame = viewFrame;
        
    }
    return introView;
}

- (void)showPostMatchTipsView{
    
    [[Utilities sharedUtility] sendFirebaseEventWithScreenName:@"" withEventName:@"Chatbox_Safetips_tap"];
    PostMatchTipsView *matchtips = [PostMatchTipsView showView];
    [matchtips setViewRemovedHandler:^{
    }];
    [self.view endEditing:true];
}

- (IBAction)backButtonTapped:(id)sender{
    
    NSLog(@"NewChatVc inside backButtonTapped1");
    
    [_typingView setUserInteractionEnabled:false];
    
    //    if (_parentView == DetailProfileViewParentCrush ) {
    //        [self dismissViewControllerAnimated:YES completion:nil];
    ////        [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:0] animated:YES];
    //    }else{
    //        if (_isAutomaticallyPushedFromChat) {
    //            [self dismissViewControllerAnimated:YES completion:nil];
    //        }else{
    [self.navigationController popViewControllerAnimated:YES];
    //        }
    //    }
    APP_DELEGATE.currentActiveChatRoomId = @"";
    [self hideWooLoader];
    
}
-(void)presentDeviceCameraForUser{
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    [self presentViewController:picker animated:YES completion:NULL];
}
-(void)presentDeviceGalleryforUser{
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:TRUE completion:^{
            NSLog(@"present ho gaya hai");
        }];
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [_typingView setUserInteractionEnabled:true];

    UIImage *chosenImage;
    if (picker.allowsEditing) {
        chosenImage = info[UIImagePickerControllerEditedImage];
    }
    else{
        chosenImage = info[UIImagePickerControllerOriginalImage];
    }
    [self saveImageTemporarilyAndUploadItToSever:chosenImage];
    
    
    
    [APP_DELEGATE sendSwrveEventWithEvent:@"3-Matchbox.Chatbox.MC_SendMultiMediaMessage" andScreen:@"Chatbox"];
    
    
    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        //      [APP_DELEGATE sendSwrveEventWithEvent:@"Chat.GalleryPic" andScreen:@"Chat"];
        [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"SendGalleryPic" forScreenName:@"Chat"];
    }
    else{
        //    [APP_DELEGATE sendSwrveEventWithEvent:@"Chat.CameraPic" andScreen:@"Chat"];
        [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"SendCameraPic" forScreenName:@"Chat"];
    }
    // [self uploadImageToServer:chosenImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [_typingView setUserInteractionEnabled:true];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
-(void)uploadImageToServer:(NSData *)clickedImage{
    
    NSData *imageData = clickedImage;
    
    NSString *uploadImageUrl = [NSString stringWithFormat:@"%@%@?wooId=%@",kBaseURLV1,kUploadPictures,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
    [APP_Utilities showActivityIndicator];
    [[APIQueue sharedAPIQueue] uploadAnyFileOnServer:uploadImageUrl withBinaryDataOfFile:imageData withRetryCount:3 withDoYouWantToUseQueue:YES withCachingPolicy:GET_DATA_FROM_URL_ONLY withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        [self presentCroppingView:clickedImage andImageURL:[response objectForKey:@"photoUrl"]];
        [APP_Utilities hideActivityIndicator];
    } withKindOfRequest:uploadPictureToServer andKindOfFileImage:TRUE withProgress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        NSLog(@"Wrote========== %lld/%lld", totalBytesWritten, totalBytesExpectedToWrite);
    } andImageTemporaryName:@""];
}

-(void)presentCroppingView:(UIImage *)imageObj andImageURL:(NSString *)imageUrl{
    
    VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:imageObj cropFrame:CGRectMake(0,(([[UIScreen mainScreen] bounds].size.height/2)-(255/2)), 320, 255) limitScaleRatio:3.0];
    imgCropperVC.delegate = self;
    if (!tappedPlaceholderData) {
        tappedPlaceholderData = [[NSMutableDictionary alloc] init];
    }
    tappedPlaceholderData = [tappedPlaceholderData mutableCopy];
    [tappedPlaceholderData setObject:imageUrl forKey:@"imageURL"];
    [tappedPlaceholderData setObject:@"-1" forKey:@"isFakePhoto"];
    [tappedPlaceholderData removeObjectForKey:@"imageID"];
    [imgCropperVC setAdditionalData:tappedPlaceholderData];
    [self presentViewController:imgCropperVC animated:YES completion:^{
        // TO DO
    }];
    
}
#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(NSDictionary *)editedImageData {
    
    //    self.portraitImageView.image = [editedImageData objectForKey:@"imageObj"];
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // TO DO
    }];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        NSLog(@"cropperViewController.additionalData : %@",cropperViewController.additionalData);
    }];
}
-(void)saveImageTemporarilyAndUploadItToSever:(UIImage *)imageObj{
    
    NSFileManager *fm = [NSFileManager defaultManager];
    [APP_DELEGATE createImageFolderIfNotExists];
    NSArray *filelist= [fm contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/%@",[APP_Utilities applicationCacheDirectory],kSelfieImagesFolderName] error:nil];
    int filesCount = (int)[filelist count];
    NSString *ImageDirectorypath = [NSString stringWithFormat:@"%@/%@",[APP_Utilities applicationCacheDirectory],kSelfieImagesFolderName];
    NSString *imageName = [NSString stringWithFormat:@"wooTempImage%d.jpg",filesCount+1];
    NSString *filePath = [ImageDirectorypath stringByAppendingPathComponent:imageName];
    
    // Convert UIImage object into NSData (a wrapper for a stream of bytes) formatted according to PNG spec
    NSData *imageDataAfterReduction = UIImageJPEGRepresentation(imageObj,0);
    [imageDataAfterReduction writeToFile:filePath atomically:YES];
    [self sendImage:@{@"imagePath":imageName,@"isImageUploaded":@NO} withCompletionHandler:nil];
}

-(void)showConnectingView{
    if (connectingViewObj) {
        return;
    }
    
    // CGFloat safeAreaTop = [[Utilities sharedUtility] getSafeAreaForTop:true andBottom:false];
    
    if (!connectingViewObj) {
        connectingViewObj = [[ConnectingView alloc] initWithFrame:CGRectMake(-10, (IS_IPHONE_XS_MAX) ? 58: 64, APP_DELEGATE.window.bounds.size.width+20, 30)];

    }
    
    [connectingViewObj setBackgroundColorOfView:[APP_Utilities getUIColorObjectFromHexString:@"#F2F2F2" alpha:1.0]];
    [connectingViewObj changeLoadingTextView:NSLocalizedString(@"Connecting.", nil)];
    [connectingViewObj animateActivityIndicatorView];
    
    CGRect lblFrame = connectingViewObj.frame;
    lblFrame.size.height = 5;
    connectingViewObj.frame = lblFrame;
    lblFrame.size.height = 30;
    [self.view addSubview:connectingViewObj];
    
    [UIView animateWithDuration:0.25 animations:^{
        self->connectingViewObj.frame = lblFrame;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)hideconnectingView{
    
    [connectingViewObj stopAndHideActivityIndicatorView];
    CGRect lblFrame = connectingViewObj.frame;
    [connectingViewObj changeLoadingTextView:@""];
    [connectingViewObj hideBottomLine];
    lblFrame.size.height = 1;
    [UIView animateWithDuration:0.3 animations:^{
        connectingViewObj.frame = lblFrame;
    } completion:^(BOOL finished) {
        [connectingViewObj removeFromSuperview];
        connectingViewObj = nil;
    }];
}

//-(void)setFavImageOnBar{
//
//    if ([_myMatchesData.isFav boolValue]) {
//        [favNavBarIcon setSelected:YES];
//    }else{
//        [favNavBarIcon setSelected:NO];
//    }
//
//}

//- (IBAction)favButtonTapped:(id)sender {
//
//    [MyMatches changeFavStatusOfChatRoomForChatRoomID:_myMatchesData.matchedUserId];
//    [self setFavImageOnBar];
//
//    if ([_myMatchesData.isFav boolValue]) {
//        SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"C00CH2", @"match added to fav toast"));
//
//    }else{
//        SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"C00CH3", @"match removed from fav toast"));
//
//    }
//}
//MOved from view did appear
//    if (![[NSUserDefaults standardUserDefaults]boolForKey:kFirstTimeFavouriteGlow]) {
////        [APP_Utilities scaleUpAnimationOnView:favNavBarIcon withNumberOfTimes:2];
//        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:kFirstTimeFavouriteGlow];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }

//-(void)setNavbarColorFromConversationMetadata:(NSDictionary *)metadata
//{
//    // For more information about Metadata, check out https://developer.layer.com/docs/integration/ios#metadata
//    if (![metadata valueForKey:LQSBackgroundColorMetadataKey]) {
//        return;
//    }
//    CGFloat redColor = (CGFloat)[[metadata valueForKeyPath:LQSRedBackgroundColorMetadataKeyPath] floatValue];
//    CGFloat blueColor = (CGFloat)[[metadata valueForKeyPath:LQSBlueBackgroundColorMetadataKeyPath] floatValue];
//    CGFloat greenColor = (CGFloat)[[metadata valueForKeyPath:LQSGreenBackgroundColorMetadataKeyPath] floatValue];
//    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:redColor
//                                                                           green:greenColor
//                                                                            blue:blueColor
//                                                                           alpha:1.0f];
//}

//-(void)fetchStickers:(int)indexVal{
//    int indexValue = ++indexVal;
//
//    NSURL *urlObj = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kStickerBaseURL,[NSString stringWithFormat:@"sticker_%d.png",indexValue]]];
//
//    [[SDWebImageManager sharedManager] downloadImageWithURL:urlObj options:SDWebImageProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//        //    nothing here
//    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//        //    nothing here
//    }];
//    if(indexVal<31)
//        [self fetchStickers:indexValue];
//
//}
-(void)showGlowAnimation
{
    //    __block NSNumber *count = [NSNumber numberWithInteger:0];
    //    [NSTimer scheduledTimerWithTimeInterval:2.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
    //       // [self performSelector:@selector(glow) withObject:nil afterDelay:2.0]
    //        count = [NSNumber numberWithInteger:[count integerValue] + 1];
    if(hasSeenGlowAnimation == NO)
    {        if (IS_IPHONE_5)
    {
        [rippleOverlayView rippleStartingAt:CGPointMake(rippleOverlayView.frame.origin.x - 52, rippleOverlayView.frame.origin.y+44)  withColor:[UIColor colorWithWhite:1.0f alpha:0.60f]  duration:2.0 radius:44.0 fadeAfter:0.0];
    }
    else if(IS_IPHONE_6P || IS_IPHONE_XS_MAX)
    {
        [rippleOverlayView rippleStartingAt:CGPointMake(rippleOverlayView.frame.origin.x + 32 , rippleOverlayView.frame.origin.y+44)  withColor:[UIColor colorWithWhite:1.0f alpha:0.60f]  duration:2.0 radius:44.0 fadeAfter:0.0];
    }
    else
    {
        [rippleOverlayView rippleStartingAt:CGPointMake(rippleOverlayView.frame.origin.x, rippleOverlayView.frame.origin.y+44)  withColor:[UIColor colorWithWhite:1.0f alpha:0.60f]  duration:2.0 radius:44.0 fadeAfter:0.0];
    }
        hasSeenGlowAnimation = YES;
    }
    //        if([count integerValue] == 1)
    //        {
    //            [timer invalidate];
    //        }
    //
    //    }];
}

-(void)glow
{
    [rippleOverlayView rippleStartingAt:CGPointMake(rippleOverlayView.frame.origin.x, rippleOverlayView.frame.origin.y+44)  withColor:[UIColor colorWithWhite:1.0f alpha:0.60f]  duration:2.0 radius:44.0 fadeAfter:0.0];
    
}
- (IBAction)voiceCallButtonTapped:(UIButton *)sender
{
    //Calling button is now enabled for both
    if([[AppLaunchModel sharedInstance] isCallingEnabled])
    {
        [[Utilities sharedUtility]sendFirebaseEventWithScreenName:@"" withEventName:@"Chatbox_TAPS_ON_ENABLED_CALL_BUTTON"];
        
        if (![APP_Utilities reachable])
        {
            [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];
            return;
        }
        if([self.myMatchesData.isTargetACelebrity boolValue] == YES)
        {
            UIAlertController *celebrityAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Woo", @"Woo") message:NSLocalizedString(@"You can only receive a call from a Celebrity match.",@"You can only receive a call from a Celebrity match") preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [celebrityAlert addAction:okAction];
            [self presentViewController:celebrityAlert animated:true completion:nil];
            
            return;
        }
        
        if ([[[[DiscoverProfileCollection sharedInstance] myProfileData ]gender] isEqualToString:@"FEMALE"] && [[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenTutorialForVoiceCallForFirstTap"] == NO)
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasSeenTutorialForVoiceCallForFirstTap"];
            [self showCallingTutorialForWomen];
            return;
        }
        
        __weak NewChatViewController *weakSelf = self;
        if ([self.myMatchesData.isTargetVoiceCallingEnabled boolValue] == YES)
        {
            if(![self.myMatchesData.agoraChannelKey isEqualToString:@""])
            {
                if([[Utilities sharedUtility] checkMicrophonePermission] == -1)
                {
                    //Show introductory Popup and then show permission
                    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                        // CALL YOUR METHOD HERE - as this assumes being called only once from user interacting with permission alert!
                        if (granted) {
                            // Microphone enabled code
                            [weakSelf informingServerAboutVoiceCallInitiation:kVoiceCallInitiationEvent];
                            dispatch_async(dispatch_get_main_queue(),
                                           ^{
                                               [weakSelf presentVoiceCallVc];
                                           });
                        }
                        else {
                            // Microphone disabled code
                        }
                    }];
                    return;
                }
                else if([[Utilities sharedUtility] checkMicrophonePermission] == 0)
                {
                    
                    UIAlertController *microphoneAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Woo", @"Woo") message:NSLocalizedString(@"To enable calls , Woo needs access to your iPhone's microphone. Tap settings and turn on Microphone.",@"To enable calls , Woo needs access to your iPhone's microphone. Tap settings and turn on Microphone.") preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        
                    }];
                    [microphoneAlert addAction:cancelAction];
                    
                    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    }];
                    [microphoneAlert addAction:settingsAction];
                    
                    [self presentViewController:microphoneAlert animated:true completion:nil];
                    return;
                }
                [self informingServerAboutVoiceCallInitiation:kVoiceCallInitiationEvent];
                [self presentVoiceCallVc];
            }
            else
            {
                __weak NewChatViewController *weakSelf = self;
                [self.voiceCallButton setUserInteractionEnabled:NO];
                [[AgoraConnectionManager sharedManager] getChannelKeyForMatchId:self.myMatchesData.matchId andCompletionBlock:^(id response, BOOL success) {
                    if(success && [response objectForKey:@"agora_channel_key"])
                    {
                        
                        // Update in MyMatches
                        [MyMatches updateMatchedUserDetailsForMatchedUserID:self.myMatchesData.matchedUserId withAgoraChannelKey:[response objectForKey:@"agora_channel_key"] withChatUpdationSuccess:^(BOOL isUpdationCompleted)
                         {
                             
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 weakSelf.myMatchesData = [MyMatches getMatchDetailForMatchedUSerID:self.myMatchesData.matchedUserId isApplozic:false];
                                 [weakSelf.voiceCallButton setUserInteractionEnabled:YES];
                                 
                                 if([[Utilities sharedUtility] checkMicrophonePermission] == 0)
                                 {
                                     
                                     UIAlertController *microphoneAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Woo", @"Woo") message:NSLocalizedString(@"To enable calls , Woo needs access to your iPhone's microphone. Tap settings and turn on Microphone.",@"To enable calls , Woo needs access to your iPhone's microphone. Tap settings and turn on Microphone.") preferredStyle:UIAlertControllerStyleAlert];
                                     
                                     UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                                         
                                     }];
                                     [microphoneAlert addAction:cancelAction];
                                     
                                     UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                     }];
                                     [microphoneAlert addAction:settingsAction];
                                     
                                     [self presentViewController:microphoneAlert animated:YES completion:nil];
                                     
                                     
                                     return;
                                 }
                                 else  if([[Utilities sharedUtility] checkMicrophonePermission] == -1)
                                 {
                                     //Show introductory Popup and then show permission
                                     [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                                         // CALL YOUR METHOD HERE - as this assumes being called only once from user interacting with permission alert!
                                         if (granted) {
                                             // Microphone enabled code
                                             // Microphone enabled code
                                             [weakSelf informingServerAboutVoiceCallInitiation:kVoiceCallInitiationEvent];
                                             dispatch_async(dispatch_get_main_queue(),
                                                            ^{
                                                                [weakSelf presentVoiceCallVc];
                                                            });
                                             
                                         }
                                         else {
                                             // Microphone disabled code
                                         }
                                     }];
                                     return;
                                 }
                                 
                                 [self informingServerAboutVoiceCallInitiation:kVoiceCallInitiationEvent];
                                 [self presentVoiceCallVc];
                                 
                             });
                         }];
                    }
                    else
                    {
                        //Error
                    }
                }];
                
            }
        }
        else
        {
            //Show target needs update screen
            [self showVersionUpdateView];
        }
    }
    else
    {
        [[Utilities sharedUtility]sendFirebaseEventWithScreenName:@"" withEventName:@"Chatbox_TAPS_ON_DISABLED_CALL_BUTTON"];
        
        if( [[AppLaunchModel sharedInstance] voiceCallingPopUpEnabled])
        {
            [self showInviteViewForMen];
        }
        else
        {
            [self showCallingTutorialForMen];
        }
    }
    
}



-(void)presentVoiceCallVc
{
    //push to voice call
    VoiceCallingViewController *voiceCallVc = [self.storyboard instantiateViewControllerWithIdentifier:@"VoiceCallingViewController"];
    voiceCallVc.matchDetail = self.myMatchesData;
    voiceCallVc.currentChannelKey = self.myMatchesData.agoraChannelKey;
    voiceCallVc.currentChannelId = self.myMatchesData.matchId;
    [self.navigationController presentViewController:voiceCallVc animated:YES completion:^{
        //Join Channel
        [[AgoraConnectionManager sharedManager] joinChannelWithKey:self.myMatchesData.agoraChannelKey andMatchId:self.myMatchesData.matchId];
        
        NSLog(@"%@",self.myMatchesData.matchId);
        NSLog(@"self.myMatchesData.matchedUserId %@",self.myMatchesData.matchedUserId);
        [[AgoraConnectionManager sharedManager] inviteUserWithAccount:self.myMatchesData.matchedUserId andChannelId:self.myMatchesData.matchId andHandle:self.myMatchesData.matchUserName];
        
    }];
    
}
-(void)showVersionUpdateView
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    //    NSLog(@"Window subviews %@",window.subviews);
    VoiceCallingVersionUpdateOverlay *versionUpdateView =  [[[NSBundle mainBundle] loadNibNamed:@"VoiceCallingVersionUpdateOverlay" owner:window.rootViewController options:nil] firstObject];
    versionUpdateView.frame = CGRectMake(0, 0,self.view.bounds.size.width, self.view.bounds.size.height);
    CGFloat multiplier = SCREEN_WIDTH/320.0;
    CGFloat kConstraintOrignalValue = 14.0;
    versionUpdateView.versionUpdateText.font = [UIFont fontWithName:kLatoRegular size:(multiplier*kConstraintOrignalValue)];
    versionUpdateView.versionUpdateText.text = [NSString stringWithFormat:NSLocalizedString(@"Please ask %@ to download the latest version of Woo to receive calls.", @"Please ask %@ to download the latest version of Woo to receive calls."),self.myMatchesData.matchUserName];
    [window addSubview:versionUpdateView];
}

-(void)informingServerAboutVoiceCallInitiation:(NSString*)eventType{
    
    if ([APP_Utilities reachable])
    {
        
        AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
        if (!reachability.reachable)
            return;
        NSString *productEventAPI = [NSString stringWithFormat:@"%@%@%lld/%@",kBaseURLV1,kPurchaseEventAPI,[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue],eventType];
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],@"actorId",
                                self.myMatchesData.matchedUserId,@"targetId",
                                self.myMatchesData.matchId,@"match_Id",nil];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
        
        [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        [manager setRequestSerializer:requestSerializer];
        
        [manager  POST:productEventAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        } caching:GET_DATA_FROM_URL_ONLY andNumberOfRetries:3];
        
    }
}

- (void)textViewDidChangeHeight:(ChatTextView *)textView height:(CGFloat)height{
    
    if ((height + 60) > 90){
        _chatInputAreaHeightConstraint.constant = 60 + height;
    }
    else{
        _chatInputAreaHeightConstraint.constant = 90;
    }
    [UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.7 options:UIViewAnimationOptionCurveLinear animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)textViewDidChange:(UITextView *)textView{
    if (textView.text.length > 0){
        [_sendButton setSelected:true];
    }
    else{
        [_sendButton setSelected:false];
    }
}

- (void)keyboardWillChangeFrame:(NSNotification *)aNotification {
    
    NSDictionary *userInfo = aNotification.userInfo;
    
    NSValue *endFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardEndFrame = endFrameValue.CGRectValue;
    CGFloat keyboardHeight = UIScreen.mainScreen.bounds.size.height - keyboardEndFrame.origin.y;
    if (@available(iOS 11.0, *)){
        if (keyboardHeight > 0){
            keyboardHeight = keyboardHeight - self.view.safeAreaInsets.bottom;
        }
    }
    CGFloat safeAreaBottom = [[Utilities sharedUtility] getSafeAreaForTop:false andBottom:true];
    if (IS_IPHONE_XS_MAX || IS_IPHONE_X){
        if (keyboardHeight == 0){
            _chatInputAreaBottomConstraint.constant = keyboardHeight;
        }
        else{
            _chatInputAreaBottomConstraint.constant = keyboardHeight - safeAreaBottom;
        }
    }
    else{
        _chatInputAreaBottomConstraint.constant = keyboardHeight;
    }
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    NSInteger chatMessagesCount = [chatMessagesArray count];
    if(chatMessagesCount > 0){
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow: (chatMessagesCount - 1) inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }

}

-(void)showTimestampHeaderView{
    
    NSArray *visibleIndexPaths = [self.tableView indexPathsForVisibleRows];
    NSIndexPath *firstVisibleIndexpath = [visibleIndexPaths firstObject];
    
    if ([[chatMessagesArray objectAtIndex:firstVisibleIndexpath.row] isKindOfClass:[ChatMessage class]]){
        ChatMessage *chatMessageObject = [chatMessagesArray objectAtIndex:firstVisibleIndexpath.row];
        NSNumber *messageCreatedTime = [chatMessageObject chatMessageCreatedTime];
        NSString *messageTimeString = messageCreatedTime.stringValue;
        NSTimeInterval _interval=[messageTimeString doubleValue]/1000;
        NSDate *dateOfMessage = [NSDate dateWithTimeIntervalSince1970:_interval];
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:dateOfMessage];
        NSInteger day = [components day];
        NSInteger month = [components month];
        NSInteger year = [components year];
        
        NSString *monthString = [APP_Utilities getMonthStringFromIntegerValue:month];
        NSString *dateString;
        
        BOOL today = [self isSameDay:dateOfMessage otherDay:[NSDate date]];
        if (today){
            dateString = @"Today";
        }
        else{
            dateString = [NSString stringWithFormat:@"%@ %ld, %d",monthString,(long)day,year];
        }
        [_timestampHeaderLabel setText:dateString];
        [_timestampHeaderView setAlpha:1.0];
        [UIView animateWithDuration:0.3 delay:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [_timestampHeaderView setAlpha:0.0];
        } completion:nil];
    }
}

- (BOOL)isSameDay:(NSDate*)date1 otherDay:(NSDate*)date2 {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}

- (void)tapGestureHandler{
    [self.view endEditing:true];
    if(_isAppLozicUser){
        [[ApplozicChatManager sharedApplozicChatManager].applozic sendTypingStatusForUserId:_myMatchesData.targetAppLozicId orForGroupId:nil withTyping:false];
    }else{
//        [self.conversation sendTypingIndicator:LYRTypingIndicatorActionFinish];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (showHeaderTimeStampNow){
        [self showTimestampHeaderView];
        showHeaderTimeStampNow = false;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    showHeaderTimeStampNow = true;
}

@end
