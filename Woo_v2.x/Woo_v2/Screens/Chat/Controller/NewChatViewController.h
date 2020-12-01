//
//  NewChatViewController.h
//  Woo_v2
//
//  Created by Umesh Mishraji on 04/05/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HeaderTappableArea.h"
#import "ChatMessage.h"
#import "MyMatches.h"
#import "SenderImageCell.h"
#import "RecieverImageCell.h"
#import "U2AlertView.h"
//#import <LayerKit/LayerKit.h>
#import "ConnectingView.h"
#import "WooLoader.h"
#import "ReportUserView.h"

@interface NewChatViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ReasonsDelegate>{
    
    NSMutableArray *chatMessagesArray;
    HeaderTappableArea *header;
    NSInteger currentIndex;
  //  NSTimeInterval entryTimeInChatRoom;
    UIView *introView;
    NSInteger previousYPosOfTypingArea;
    U2AlertView *reportOptionsAlert;
    
    BOOL isUserOnLayerChat;
    BOOL isUserTyping;
   // NSNumber *creationTimeOfMessageWithDeliveredStatusOnLayer;
    
    NSMutableDictionary *tappedPlaceholderData;
    ConnectingView *connectingViewObj;
    NSString *lastMessageId;
    
    BOOL needToShowConnectingView;
        
    int keyboardHeight;
    
    IBOutlet NSLayoutConstraint *bottomHeightLayout;
    
    IBOutlet UIImageView *userImage;
    IBOutlet UILabel *userNameLbl;
    WooLoader *customLoader;
    
}
@property (assign) BOOL openKeyboardForTyping;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
//@property (nonatomic, retain) LYRConversation *conversation;
//@property (nonatomic, retain) LYRQueryController *queryController;
@property (nonatomic, retain) NSString *directMsgStr;
@property (nonatomic, retain)MyMatches *myMatchesData;
@property(nonatomic, assign)BOOL pushToChatViewOnAppear;
@property(nonatomic, assign)BOOL isPushedFromMatchesScreen;
@property(nonatomic, assign) BOOL isAutomaticallyPushedFromChat;
@property(nonatomic, weak) id delegateFromMatch;
@property(nonatomic, assign) SEL selectorToDeleteRow;
@property(nonatomic, assign)DetailProfileViewParent parentView;
@property(nonatomic, assign)BOOL viewPushed;

-(NSArray *)returnGroupedChatMessges:(NSArray *)ungroupedChatMessages;
-(UIView *)getIntroView;
-(NSInteger) isMessage:(ChatMessage *)messageObj existsInArray:(NSMutableArray *)chatArray;
//-(void)markAllMessagesAsRead;
-(void)initialiseConversationObject;
-(void)sendMessage:(NSString *)messageText;
-(void)sendSticker:(NSString *)messageText;
//-(void)insertLayerChatIntoLocalDB:(LYRMessage *)messageObj;
//-(void)updateLayerChatIntoLocalDB:(LYRMessage *)messageObj;

-(IBAction)backButtonTapped:(id)sender;
-(IBAction)moreButtonTapped:(id)sender;
-(void)saveImageTemporarilyAndUploadItToSever:(UIImage *)imageObj;
-(IBAction)showUserDetailButtonTapped:(id)sender;

-(void)uploadImageToServer:(NSData *)clickedImage;

-(void)showConnectingView;
-(void)hideconnectingView;

-(void)addObserverForView;
-(void)removeObserverForView;
-(BOOL)isLastMessageFromDifferentUser:(ChatMessage *)messageDetail;

@end
