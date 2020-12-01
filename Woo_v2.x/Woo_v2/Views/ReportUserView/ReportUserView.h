//
//  ReportUserView.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 09/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//
@protocol ReasonsDelegate<NSObject>
-(void)reasonsForUnmatchOrDelete:(NSString *)comment;
@end


#import <UIKit/UIKit.h>
#import "MyAnswers.h"

typedef enum : NSUInteger {
    reportUser,
    reasonsForUnmatch,
    reasonsForDelete,
} ReportViewType;

@class KMPlaceholderTextView;

@interface ReportUserView : UIView<UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>{
    
    __weak IBOutlet NSLayoutConstraint *reportMessageViewHeightConstraint;
    __weak IBOutlet UILabel *reportMessageLabel;
    __weak IBOutlet UILabel *headerTextLabel;
    __weak IBOutlet NSLayoutConstraint *tableViewHeightConstaint;
    __weak IBOutlet UITableView *optionsTableView;
    __weak IBOutlet NSLayoutConstraint *topLayoutConstraint;
    __weak IBOutlet UIButton *okButton;
    
    int selectedCell;
    NSString *enteredText;
}
@property (nonatomic , weak)IBOutlet KMPlaceholderTextView *textView;
@property (nonatomic , retain) UIViewController *reportedViewController;

@property(nonatomic, weak)id delegate;
@property(nonatomic, assign)SEL selectorForUserFlagged;
@property(nonatomic, assign)SEL selectorForCancelButtonTapped;
@property(nonatomic, strong)NSString *userToBeFlagged;
@property (nonatomic, strong) IBOutlet UIVisualEffectView *centerView;
@property (nonatomic)ReportViewType reportViewType;
@property(nonatomic, assign)BOOL reportingUserFromAnswer;
@property(nonatomic, strong)MyAnswers *answerObj;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CenterViewcenterYConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewLeadAlignmentConstrain;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centreViewHeightConstrain;
@property (nonatomic, assign) id<ReasonsDelegate> reasonsDelegate;


- (IBAction)okButtonTapped:(id)sender;
- (IBAction)cancelButtonTapped:(id)sender;
@property(nonatomic, assign)BOOL isAlreadMatched;
-(void)setHeaderForReportViewType:(ReportViewType)reportViewType;
@end
