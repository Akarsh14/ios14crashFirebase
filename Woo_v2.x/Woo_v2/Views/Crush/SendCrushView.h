//
//  SendCrushView.h
//  Woo_v2
//
//  Created by Umesh Mishraji on 11/01/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

typedef void (^SendCrushViewDismissed) (NSString *crushText, BOOL isSendButtonTapped , BOOL isTemplateTapped, NSInteger rowSelected);

#import <UIKit/UIKit.h>
#import "TemplateCrushCell.h"

@interface SendCrushView : UIView<UITableViewDelegate, UITableViewDataSource,UITextViewDelegate>{
    
    __weak IBOutlet UIView *blankAreaView;
    __weak IBOutlet UITableView *templateCrushMessageTable;
    
    __weak IBOutlet UIView *crushMsgContainerView;
    __weak IBOutlet UITextView *crushMsgTextView;
    __weak IBOutlet UILabel *numberOfCharLeftLbl;
    __weak IBOutlet UILabel *placeholderLbl;
    __weak IBOutlet UILabel *numberOfCrushLeftLbl;
    __weak IBOutlet UIButton *sendBtn;
    __weak IBOutlet NSLayoutConstraint *templateCrushTableViewHeightConstraint;
    
    NSInteger selectedRow;
    
    BOOL isTextChanged;
    __weak IBOutlet NSLayoutConstraint *crushTextViewContainerViewHeightConstraint;
    
    __weak IBOutlet NSLayoutConstraint *sendCrushMainContainerViewHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *sendCrushHeaderLblLeftConstraint;
    __weak IBOutlet UIButton *backBtn;
    
    __weak IBOutlet UILabel     *lblSendACrush;
    
    NSString *userNameTxt;
    
    float lastHeight;
    
    float animationTimeOfView;
    
    BOOL isTemplateTapped;
    
    BOOL needToDeselectTemplateQuestion;
    
    BOOL wasTemplateSelected;
    
    NSString *crushMessageTyped;
}

@property(nonatomic, assign)BOOL wasTemplateSelected;
@property(nonatomic, strong)NSString *crushMessageTyped;;
@property(nonatomic, assign)BOOL isTemplateTapped;
@property(nonatomic, assign)NSInteger selectedRow;

@property(nonatomic, strong)NSArray *crushTemplateArray;
@property(nonatomic, strong) SendCrushViewDismissed sendCrushViewDismissedBlock;



-(void)presentViewOnView:(UIView *)viewObj withTemplateQuestions:(NSArray *)templateQuestionArray userName:(NSString *)userName withAnimationTime:(float)animationTime withCompletionBlock:(void(^)(BOOL animationCompleted))block;
-(void)beautifyView;

-(IBAction)sendButtonTapped:(id)sender;
-(IBAction)backBtnTapped:(id)sender;
-(void)viewDismissed:(SendCrushViewDismissed)dissmisBlock;
-(void)enableOrDisableSendBtn;
-(void)dismissSendViewWithoutAnimating;

@end
