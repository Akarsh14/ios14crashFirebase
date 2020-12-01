//
//  ReportUserView.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 09/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "ReportUserView.h"
#import "ReportUserCell.h"
#import "ReportUserEditableCell.h"
#import "IQKeyboardManager.h"
#import "MyMatches.h"
#import "Woo_v2-Swift.h"
#import "UIColorHelper.h"
#import "ApplozicChatManager.h"
#define kCellHeight 44.0
#define kReportMessageViewHeight 90.0

@interface ReportUserView(){
    int optionsCount;
}

@end

@implementation ReportUserView
@synthesize delegate,selectorForCancelButtonTapped,selectorForUserFlagged;



-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    //check if memory is allocated to self
    if (self) {
        //getting array of views from the xib
        NSArray *viewArrayFromXib = [[NSBundle mainBundle] loadNibNamed:@"ReportUserView" owner:self options:nil];
        UIView *viewObj = [viewArrayFromXib firstObject];
        viewObj.frame = self.bounds;
       [self addSubview:viewObj];
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(keyboardDisappeared) name:UIKeyboardWillHideNotification object:nil];
        [center addObserver:self selector:@selector(keyboardAppeared) name:UIKeyboardWillShowNotification object:nil];
    }
    return self;
}

-(void)setHeaderForReportViewType:(ReportViewType)reportViewType
{
    self.reportViewType = reportViewType;
    switch (self.reportViewType) {
        case reportUser:
        {
            selectedCell = 0;
            [reportMessageViewHeightConstraint setConstant:90];
            [reportMessageLabel setHidden:false];
            [okButton setTitle:NSLocalizedString(@"Report User",nil) forState:UIControlStateNormal];
            headerTextLabel.text = NSLocalizedString(@"Help us understand the problem", nil);
            [[Utilities sharedUtility] sendFirebaseEventWithScreenName:@"" withEventName:@"DiscoverCards_Tap_ReportUser"];
        }
            break;
        case reasonsForUnmatch:
        {
            selectedCell = -1;
            [reportMessageViewHeightConstraint setConstant:0];
            [reportMessageLabel setHidden:true];
            //okButton.enabled = false;
            //[okButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [okButton setTitle:NSLocalizedString(@"Unmatch",nil) forState:UIControlStateNormal];
            [[Utilities sharedUtility]sendFirebaseEventWithScreenName:@"" withEventName:@"Chatbox_Unmatch"];

            headerTextLabel.text = NSLocalizedString(@"Are you sure? Tell us why", nil);
            // _centreViewHeightConstrain.constant = 328;


        }
            break;
        case reasonsForDelete:
        {
            [reportMessageViewHeightConstraint setConstant:0];
            [reportMessageLabel setHidden:true];
            [[Utilities sharedUtility]sendFirebaseEventWithScreenName:@"" withEventName:@"DELETE_ACCOUNT"];
            selectedCell = -1;
            //okButton.enabled = false;
           // [okButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [okButton setTitle:NSLocalizedString(@"Submit",nil) forState:UIControlStateNormal];
            
            NSMutableAttributedString *newString = [[NSMutableAttributedString alloc] initWithAttributedString:[[NSAttributedString alloc] initWithString:@"We're sorry to see you go.\nHelp us improve by telling us why you're leaving?"]];
            
            NSRange changeRange2 = (NSRange){0,[newString length]};
            UIFont *replacementFont2 =  [UIFont fontWithName:@"Lato-Regular" size:16.0];
            [newString addAttribute:NSFontAttributeName value:replacementFont2 range:changeRange2];
            
            NSRange changeRange1 = (NSRange){0,[newString length] - 50};
            UIFont *replacementFont1 =  [UIFont fontWithName:@"Lato-Bold" size:18.0];
            [newString addAttribute:NSFontAttributeName value:replacementFont1 range:changeRange1];

            headerTextLabel.attributedText = newString;
            
            //_centreViewHeightConstrain.constant = 400;
        }
            break;
        default:
            break;
    }
}
- (void)removeFromSuperview{
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         _centerView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.4, 0.4);
                     }
                     completion:^(BOOL finished){
                         [super removeFromSuperview];
                     }];
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    
    _textView.delegate = self;
    _centerView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.4, 0.4);
    [UIView animateWithDuration:0.25 delay:0.0 usingSpringWithDamping:0.7f
          initialSpringVelocity:2.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
        _centerView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    } completion:nil];
    
    
    optionsTableView.rowHeight = UITableViewAutomaticDimension;
    optionsTableView.estimatedRowHeight = 44.0;
}

- (IBAction)okButtonTapped:(id)sender {
    
    switch (self.reportViewType) {
            case reportUser:
            {
                if (_reportingUserFromAnswer) {
                    if (_answerObj) {
                        switch (selectedCell) {
                            case 0:
                            {
                                [self reportTheAnswerForReason:@"7" andReportDescription:enteredText];
                            }
                                break;
                            case 1:
                            {
                                [self reportTheAnswerForReason:@"8" andReportDescription:enteredText];
                            }
                                break;
                            case 2:
                            {
                                [self reportTheAnswerForReason:@"2" andReportDescription:enteredText];
                            }
                                break;
                                
                            default:
                                break;
                        }
                    }
                }
            
                if (_isAlreadMatched) {
                    switch (selectedCell) {
                        case 0:
                        {
                            [self reportUserWithUserID:_userToBeFlagged forReason:@"0" andReportDescription:enteredText];
                        }
                            break;
                        case 1:
                        {
                            [self reportUserWithUserID:_userToBeFlagged forReason:@"7" andReportDescription:enteredText];
                        }
                            break;
                        case 2:
                        {
                            [self reportUserWithUserID:_userToBeFlagged forReason:@"8" andReportDescription:enteredText];
                        }
                            break;
                        case 3:
                        {
                            [self reportUserWithUserID:_userToBeFlagged forReason:@"6" andReportDescription:enteredText];
                        }
                            break;
                        case 4:
                        {
                            [self reportUserWithUserID:_userToBeFlagged forReason:@"8" andReportDescription:enteredText];
                        }
                            break;
                        case 5:
                        {
                            [self reportUserWithUserID:_userToBeFlagged forReason:@"2" andReportDescription:enteredText];
                        }
                            break;
                            
                        default:
                            break;
                    }
                }else{
                    switch (selectedCell) {
                        case 0:
                        {
                            [self reportUserWithUserID:_userToBeFlagged forReason:@"0" andReportDescription:enteredText];
                        }
                            break;
                        case 1:
                        {
                            [self reportUserWithUserID:_userToBeFlagged forReason:@"1" andReportDescription:enteredText];
                        }
                            break;
                        case 2:
                        {
                            [self reportUserWithUserID:_userToBeFlagged forReason:@"2" andReportDescription:enteredText];
                        }
                            break;
                        case 3:
                        {
                            [self reportUserWithUserID:_userToBeFlagged forReason:@"3" andReportDescription:enteredText];
                        }
                            break;
                            
                        default:
                            break;
                    }
                }
                NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                [center removeObserver:self name:UIKeyboardWillHideNotification object:nil];
                [center removeObserver:self name:UIKeyboardWillShowNotification object:nil];
                [self removeFromSuperview];
            }
            break;
        case reasonsForUnmatch:
            {
                if(selectedCell == 3)
                {
                    [[Utilities sharedUtility]sendFirebaseEventWithScreenName:@"" withEventName:@"Chatbox_Unmatch_Other_Submit"];
                }
                else
                {
                    [[Utilities sharedUtility]sendFirebaseEventWithScreenName:@"" withEventName:@"Chatbox_Unmatch_Submit"];
                }
                if(enteredText == nil){
                    enteredText = @"";
                }
                [self.reasonsDelegate reasonsForUnmatchOrDelete:enteredText];
                NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                [center removeObserver:self name:UIKeyboardWillHideNotification object:nil];
                [center removeObserver:self name:UIKeyboardWillShowNotification object:nil];
                [self removeFromSuperview];
                
            }
            break;
      
        case reasonsForDelete:
            {
                if(selectedCell == 3)
                {
                    [[Utilities sharedUtility]sendFirebaseEventWithScreenName:@"" withEventName:@"Delete_Popup_Others_Submit"];
                }
                else if (selectedCell == 0){
                    [[Utilities sharedUtility]sendFirebaseEventWithScreenName:@"" withEventName:@"Delete_Popup_Submit"];
                    enteredText = @"Found Someone On Woo";
                }
                else
                {
                    [[Utilities sharedUtility]sendFirebaseEventWithScreenName:@"" withEventName:@"Delete_Popup_Submit"];
                }
                if(enteredText == nil){
                    enteredText = @"";
                }
                [self.reasonsDelegate reasonsForUnmatchOrDelete:enteredText];
                [self removeFromSuperview];
            }
            break;

        default:
            break;
    }
   
}

- (IBAction)cancelButtonTapped:(id)sender{
    
    switch (self.reportViewType)
    {
        case reasonsForUnmatch:
        {
            headerTextLabel.text = NSLocalizedString(@"Are you sure?Tell us why", nil);
            if(selectedCell == 3)
            {
                [[Utilities sharedUtility]sendFirebaseEventWithScreenName:@"" withEventName:@"Chatbox_Unmatch_Other_Cancel"];

            }
            else
            {
                [[Utilities sharedUtility]sendFirebaseEventWithScreenName:@"" withEventName:@"Chatbox_Unmatch_Cancel"];
            }
        }
            break;
        case reasonsForDelete:
        {
            [headerTextLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:18.0]];
            
            NSMutableAttributedString *newString = [[NSMutableAttributedString alloc] initWithAttributedString:[[NSAttributedString alloc] initWithString:@"We're sorry to see you go.\nHelp us improve by telling us why you're leaving?"]];
            NSRange changeRange = (NSRange){0,[newString length] - 50};
            UIFont *replacementFont =  [UIFont fontWithName:@"Lato-Bold" size:18.0];
            [newString addAttribute:NSFontAttributeName value:replacementFont range:changeRange];
            headerTextLabel.attributedText = newString;
            
            if(selectedCell == 5)
            {
                [[Utilities sharedUtility]sendFirebaseEventWithScreenName:@"" withEventName:@"Delete_Popup_Others_Cancel"];
                
            }
            else
            {
                [[Utilities sharedUtility]sendFirebaseEventWithScreenName:@"" withEventName:@"Delete_Popup_Cancel"];
            }
        }
            break;
        default:
            break;
    }
    if ([delegate respondsToSelector:selectorForCancelButtonTapped]) {
        [delegate performSelector:selectorForCancelButtonTapped withObject:nil afterDelay:0.0];
    }
    [[IQKeyboardManager sharedManager] setEnable:FALSE];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:FALSE];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [center removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [self removeFromSuperview];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   
    int count = 0;

    switch (self.reportViewType) {
        case reportUser:
        {
            count = 4;

            if (_reportingUserFromAnswer) {
                count = 3;
            }
            if (_isAlreadMatched) {
                count = 6;
            }
            _centreViewHeightConstrain.constant = 12+44+10+(44 * count)+44+6 + kReportMessageViewHeight ;
        }
            break;
        case reasonsForUnmatch:
            count = 5;
            _centreViewHeightConstrain.constant = 12+28+10+(44 * count)+44+18 ;

            break;
            
        case reasonsForDelete:
            count = 7;
            _centreViewHeightConstrain.constant = 12+65+10+(44 * count)+44+6 ;
            break;
            
        default:
            break;
    }
    
    
//    [_centerView layoutIfNeeded];
    optionsCount = count;
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 40;
    
    switch (self.reportViewType) {
        case reportUser:
        {
            if (_reportingUserFromAnswer) {
                if (indexPath.row == 2 && selectedCell == 2) {
                    return 114;
                }else{
                    return 44;
                }
            }
            
            if (_isAlreadMatched) {
                if (indexPath.row == 5 && selectedCell == 5) {
                    return 114;
                }else{
                    return 44;
                }
            }
            
            if (indexPath.row == 4 && selectedCell == 4) {
                return 114;
            }else{
                return 44;
            }
        }
            break;
        case reasonsForUnmatch:
            if (indexPath.row == 3 && selectedCell == 3) {
                return 114;
            }else{
                return 44;
            }
            break;
            
        case reasonsForDelete:
            if (indexPath.row == 6 && selectedCell == 6) {
                return 114;
            }else{
                return 44;
            }
            break;
            
        default:
            break;
    }
    return 44;

}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (self.reportViewType) {
        case reportUser:
            {
                if (_reportingUserFromAnswer) {
                    switch (indexPath.row) {
                        case 0:
                        {
                            return [self createCellWithText:NSLocalizedString(@"Abusive language", nil) andIsSelected:(selectedCell == indexPath.row ?YES:NO)];
                        }
                            break;
                        case 1:
                        {
                            return [self createCellWithText:NSLocalizedString(@"Feels like spam", nil) andIsSelected:(selectedCell == indexPath.row ?YES:NO)];
                        }
                            break;
                        case 2:
                        {
                            return [self createCellWithText:NSLocalizedString(@"Other", nil) andIsSelected:(selectedCell == indexPath.row ?YES:NO) andPrefilledText:enteredText];
                        }
                            break;
                            
                        default:
                            break;
                    }
                }
                
                if (_isAlreadMatched) {
                        switch (indexPath.row) {
                            case 0:
                            {
                                return [self createCellWithText:NSLocalizedString(@"Improper conduct", nil) andIsSelected:(selectedCell == indexPath.row ?YES:NO)];
                            }
                                break;
                            case 1:
                            {
                                return [self createCellWithText:NSLocalizedString(@"Abusive language", nil) andIsSelected:(selectedCell == indexPath.row ?YES:NO)];
                            }
                                break;
                            case 2:
                            {
                                return [self createCellWithText:NSLocalizedString(@"spams my inbox", nil) andIsSelected:(selectedCell == indexPath.row ?YES:NO)];
                                
                            }
                                break;
                            case 3:
                            {
                                return [self createCellWithText:NSLocalizedString(@"Married / In a relationship", nil) andIsSelected:(selectedCell == indexPath.row ?YES:NO)];
                            }
                                break;
                            case 4:
                            {
                                return [self createCellWithText:NSLocalizedString(@"Misrepresented info", nil) andIsSelected:(selectedCell == indexPath.row ?YES:NO)];
                            }
                                break;
                            case 5:
                            {
                                return [self createCellWithText:NSLocalizedString(@"Other", nil) andIsSelected:(selectedCell == indexPath.row ?YES:NO)];
                            }
                                break;
                            default:
                                break;
                        }
                    }else{
                        
                        switch (indexPath.row) {
                            case 0:
                            {
                                return [self createCellWithText:NSLocalizedString(@"Inappropriate photos", nil) andIsSelected:(selectedCell == indexPath.row ?YES:NO)];
                            }
                                break;
                            case 1:
                            {
                                return [self createCellWithText:NSLocalizedString(@"Inappropriate and abusive content", nil) andIsSelected:(selectedCell == indexPath.row ?YES:NO)];
                            }
                                break;
                            case 2:
                            {
                                return [self createCellWithText:NSLocalizedString(@"Feels like spam", nil) andIsSelected:(selectedCell == indexPath.row ?YES:NO)];
                                
                            }
                                break;
                            case 3:
                            {
                                return [self createCellWithText:NSLocalizedString(@"Other", nil) andIsSelected:(selectedCell == indexPath.row ?YES:NO)];
                            }
                                break;
                            case 4:
                            {
                                return [self createCellWithText:NSLocalizedString(@"Other", nil) andIsSelected:(selectedCell == indexPath.row ?YES:NO) andPrefilledText:enteredText];
                            }
                                break;
                            default:
                                break;
                        }
                }
                break;
            case reasonsForUnmatch:
                switch (indexPath.row) {
                    case 0:
                    {
                        return [self createCellWithText:NSLocalizedString(@"Inappropriate messages", nil) andIsSelected:(selectedCell == indexPath.row ?YES:NO)];
                    }
                        break;
                    case 1:
                    {
                        return [self createCellWithText:NSLocalizedString(@"Inappropriate photos", nil) andIsSelected:(selectedCell == indexPath.row ?YES:NO)];
                    }
                        break;
                    case 2:
                    {
                        return [self createCellWithText:NSLocalizedString(@"Feels like spam", nil) andIsSelected:(selectedCell == indexPath.row ?YES:NO)];
                        
                    }
                        break;
                    case 3:
                    {
                        return [self createCellWithText:NSLocalizedString(@"Other", nil) andIsSelected:(selectedCell == indexPath.row ?YES:NO) andPrefilledText:enteredText];
                    }
                        break;
                    case 4:
                    {
                        return [self createCellWithText:NSLocalizedString(@"No reason", nil) andIsSelected:(selectedCell == indexPath.row ?YES:NO)];
                    }
                        break;
                    default:
                        break;
                }
                break;
                
            case reasonsForDelete:
                switch (indexPath.row) {
                    
                    case 0:
                    {
                        return [self createCellWithText:NSLocalizedString(@"Found someone on Woo", nil) andIsSelected:(selectedCell == indexPath.row ?YES:NO)];
                    }
                        break;
                    case 1:
                    {
                        return [self createCellWithText:NSLocalizedString(@"Too many notifications", nil) andIsSelected:(selectedCell == indexPath.row ?YES:NO)];
                    }
                        break;
                    case 2:
                    {
                        return [self createCellWithText:NSLocalizedString(@"Too many people sending me interest", nil) andIsSelected:(selectedCell == indexPath.row ?YES:NO)];
                    }
                        break;
                    case 3:
                    {
                        return [self createCellWithText:NSLocalizedString(@"Very few people sending me interest", nil) andIsSelected:(selectedCell == indexPath.row ?YES:NO)];

                    }
                        break;
                    case 4:
                    {
                        return [self createCellWithText:NSLocalizedString(@"Abusive language used by some matches", nil) andIsSelected:(selectedCell == indexPath.row ?YES:NO)];
                    }
                        break;
                    case 5:
                    {
                        return [self createCellWithText:NSLocalizedString(@"Poor quality of profiles", nil) andIsSelected:(selectedCell == indexPath.row ?YES:NO)];
                    }
                    case 6:
                    {
                        return [self createCellWithText:NSLocalizedString(@"Others", nil) andIsSelected:(selectedCell == indexPath.row ?YES:NO) andPrefilledText:enteredText];
                    }
                        break;
                    default:
                        break;
                }
                break;
                
            default:
                break;
        }
    
    }
    return [self createCellWithText:@"" andIsSelected:false];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selectedCell = indexPath.row;
    okButton.enabled = true;
    [okButton setTitleColor:[UIColorHelper colorFromRGB:@"#0072FB" withAlpha:1.0] forState:UIControlStateNormal];
    [optionsTableView reloadData];
    enteredText = @"";
    
    
    switch (self.reportViewType) {
        case reportUser:
        {
            if (_reportingUserFromAnswer && selectedCell == 2) {
                [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] atScrollPosition: UITableViewScrollPositionTop animated: YES];
                
                _textViewLeadAlignmentConstrain.constant = 20.0;
                
                [UIView animateWithDuration:0.25 animations:^{
                    [_textView layoutIfNeeded];
                } completion:^(BOOL finished) {
                    [_textView becomeFirstResponder];
                    _centreViewHeightConstrain.constant = 218.0;
                    [reportMessageLabel setHidden:true];
                    [UIView animateWithDuration:0.25 animations:^{
                        [_centerView layoutIfNeeded];
                    }];
                }];
                
                [UIView animateWithDuration:0.25 animations:^{
                    [optionsTableView setAlpha:0.0];
                }];
                
                return;
            }
            
            if ((_isAlreadMatched && selectedCell == 5) || (!_isAlreadMatched && selectedCell == 3)) {
                
                _textViewLeadAlignmentConstrain.constant = 20.0;
                
                [UIView animateWithDuration:0.25 animations:^{
                    [_textView layoutIfNeeded];
                } completion:^(BOOL finished) {
                    [_textView becomeFirstResponder];
                    _centreViewHeightConstrain.constant = 218.0;
                    [reportMessageLabel setHidden:true];
                    [UIView animateWithDuration:0.25 animations:^{
                        [_centerView layoutIfNeeded];
                    }];
                }];
                
                [UIView animateWithDuration:0.25 animations:^{
                    [optionsTableView setAlpha:0.0];
                }];
                
            }else{
                [okButton setEnabled:YES];
                [okButton setAlpha:1.0f];
            }
        }
            break;
        case reasonsForUnmatch:
            switch (indexPath.row) {
                case 0:
                    [[Utilities sharedUtility]sendFirebaseEventWithScreenName:@"" withEventName:@"Chatbox_Unmatch_InappMessages"];
                    break;
                case 1:
                    [[Utilities sharedUtility]sendFirebaseEventWithScreenName:@"" withEventName:@"Chatbox_Unmatch_InappPhotos"];
                    break;
                case 2:
                    [[Utilities sharedUtility]sendFirebaseEventWithScreenName:@"" withEventName:@"Chatbox_Unmatch_Feelslikespam"];
                    break;
                case 3:
                {
                    [[Utilities sharedUtility]sendFirebaseEventWithScreenName:@"" withEventName:@"Chatbox_Unmatch_Other"];
                    [headerTextLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:18.0]];
                    headerTextLabel.text = NSLocalizedString(@"Help us understand the problem", nil);

                    _textViewLeadAlignmentConstrain.constant = 20.0;
                    [UIView animateWithDuration:0.25 animations:^{
                        [_textView layoutIfNeeded];
                    } completion:^(BOOL finished) {
                        [_textView becomeFirstResponder];
                        _centreViewHeightConstrain.constant = 218.0;
                        [UIView animateWithDuration:0.25 animations:^{
                            [_centerView layoutIfNeeded];
                        }];
                    }];
                    
                    [UIView animateWithDuration:0.25 animations:^{
                        [optionsTableView setAlpha:0.0];

                    }];
                }
                    break;
                case 4:
                    [[Utilities sharedUtility]sendFirebaseEventWithScreenName:@"" withEventName:@"Chatbox_Unmatch_NoReason"];
                    break;
                default:
                    break;
            }
//            if (indexPath.row == 3 && selectedCell == 3) {
//            }
            break;
        case reasonsForDelete:
            switch (indexPath.row) {
                case 0:
                    [[Utilities sharedUtility]sendFirebaseEventWithScreenName:@"" withEventName:@"Delete_Popup_FoundSomeoneOnWoo"];
                    break;
                case 1:
                    [[Utilities sharedUtility]sendFirebaseEventWithScreenName:@"" withEventName:@"Delete_Popup_TooManyNoti"];
                    break;
                case 2:
                    [[Utilities sharedUtility]sendFirebaseEventWithScreenName:@"" withEventName:@"Delete_Popup_TooManyInt"];
                    break;
                case 3:
                    [[Utilities sharedUtility]sendFirebaseEventWithScreenName:@"" withEventName:@"Delete_Popup_VeryFewInt"];
                    break;
                case 4:
                    [[Utilities sharedUtility]sendFirebaseEventWithScreenName:@"" withEventName:@"Delete_Popup_AbusiveLang"];
                    break;
                case 5:
                    [[Utilities sharedUtility]sendFirebaseEventWithScreenName:@"" withEventName:@"Delete_Popup_PoorQualityProfiles"];
                    break;
                case 6:
                {
                    [headerTextLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:18.0]];
                    headerTextLabel.text = NSLocalizedString(@"Help us understand the problem", nil);

                    [[Utilities sharedUtility]sendFirebaseEventWithScreenName:@"" withEventName:@"Delete_Popup_Others"];
                    
                    _textViewLeadAlignmentConstrain.constant = 20.0;
                    [UIView animateWithDuration:0.25 animations:^{
                        [_textView layoutIfNeeded];
                    } completion:^(BOOL finished) {
                        [_textView becomeFirstResponder];
                        _centreViewHeightConstrain.constant = 218.0;
                        [UIView animateWithDuration:0.25 animations:^{
                            [_centerView layoutIfNeeded];
                        }];
                    }];
                    
                    [UIView animateWithDuration:0.25 animations:^{
                        [optionsTableView setAlpha:0.0];
                    }];
                }
                    break;
                default:
                    break;
            }
          //  if (indexPath.row == 5 && selectedCell == 5) {
            //}
                
            break;
            
        default:
            break;
    }
   
}

-(UITableViewCell *)createCellWithText:(NSString *)cellText andIsSelected:(BOOL)isSelected{
    static NSString *CellIdentifier = @"ReportUserCell";
    ReportUserCell *cell = (ReportUserCell *)[optionsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell){
        UINib *nib = [UINib nibWithNibName:@"ReportUserCell" bundle:nil];
        [optionsTableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        cell = (ReportUserCell *)[optionsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    
    [cell setTextOnCellWithText:cellText setImageAsSelected:isSelected];
    
    return cell;
}

-(UITableViewCell *)createCellWithText:(NSString *)cellText andIsSelected:(BOOL)isSelected andPrefilledText:(NSString *)prefilledText{
    
    static NSString *CellIdentifier = @"ReportUserEditableCell";
    ReportUserEditableCell *cell = (ReportUserEditableCell *)[optionsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell){
        UINib *nib = [UINib nibWithNibName:@"ReportUserEditableCell" bundle:nil];
        [optionsTableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        cell = (ReportUserEditableCell *)[optionsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        [cell setDelegate:self];
        [cell setSelectorForTextChanged:@selector(textChangedInOtherOption:)];
    }
    
    [cell setTextOnCellWithText:cellText setImageAsSelected:isSelected andEditableText:enteredText];
    
    return cell;
    
}

-(void)textChangedInOtherOption:(NSString *)otherOptionText{
//    enteredText = [APP_Utilities validString:otherOptionText];
//    if ([enteredText length] > 0 ) {
//        [okButton setEnabled:YES];
//        [okButton setAlpha:1.0f];
//    }else{
//        [okButton setEnabled:NO];
//        [okButton setAlpha:0.5f];
//    }
}


-(void)reportUserWithUserID:(NSString *)userID forReason:(NSString *)reportReason andReportDescription:(NSString *)reportDescription{
    
    
    if (![APP_Utilities reachable]){
        
        [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];
        
        
        return;
    }
    
    [[DiscoverProfileCollection sharedInstance] removeUserFromCollection:[NSString stringWithFormat:@"%@",_answerObj.wooId] reloadDiscover:FALSE];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Profile reported!" message:@"We will review the profile and take appropriate action. Thank you for your feedback." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if ([delegate respondsToSelector:selectorForUserFlagged]) {
            SuppressPerformSelectorLeakWarning(
                                               [delegate performSelector:selectorForUserFlagged withObject:nil];
                                               );
        }
    }];
    [alert addAction:okAlert];
    if (_reportedViewController != nil){
        [_reportedViewController presentViewController:alert animated:true completion:nil];
    }

    NSString *flagString = [NSString stringWithFormat:@"%@%@?actorId=%lld&targetId=%@&isMatch=%@&reason=%@&text=%@",kBaseURLV3,kFlagAProfile,[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue],userID,(_isAlreadMatched?@"TRUE":@"FALSE"),reportReason,[APP_Utilities encodeFromPercentEscapeString:reportDescription]];
    
    NSLog(@"this is sstring for flag %@",flagString);
    
        WooRequest *wooRequestObj = [[WooRequest alloc]init];
        wooRequestObj.url =flagString;
        wooRequestObj.time =0;
        wooRequestObj.requestParams =nil;
        wooRequestObj.methodType =postRequest;
        wooRequestObj.numberOfRetries =10;
        wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
        wooRequestObj.requestType = flagAProfile;
        
        [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
            NSLog(@"\n\n\n\n\n\n\n\n\n\n\n\n THIS IS STATUS %d AND RESPONSE %@ \n\n\n\n\n",statusCode, response);
            
            if (success){
            [APP_Utilities deleteMatchUserFromAppExceptMatchBoxWithoutReload:userID shouldDeleteFromAnswer:YES withCompletionHandler:nil];
            }
        }
                 shouldReachServerThroughQueue:TRUE];

}


-(void)reportTheAnswerForReason:(NSString *)reportReason andReportDescription:(NSString *)reportDescription{
    
    [[DiscoverProfileCollection sharedInstance] removeUserFromCollection:[NSString stringWithFormat:@"%@",_answerObj.wooId] reloadDiscover:FALSE];
    
    if (_isAlreadMatched) {

        [APP_DELEGATE sendSwrveEventWithEvent:@"DetailedPV.ReportPostMatch" andScreen:@"DetailedPV"];
        [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"ReportPostMatch" forScreenName:@"DetailedPV"];
        
    }else if (!_isAlreadMatched){
        
        [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"ReportPreMatch" forScreenName:@"DetailedPV"];
        [APP_DELEGATE sendSwrveEventWithEvent:@"DetailedPV.ReportPreMatch" andScreen:@"DetailedPV"];
    }
    
    NSString *reportAnswerURL = [NSString stringWithFormat:@"%@%@?actorId=%lld&targetId=%lld&isMatch=0&text=%@&reason=%@&answerId=%lld",kBaseURLV1,kReportAnswer,[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue], [_answerObj.wooId longLongValue],[APP_Utilities encodeFromPercentEscapeString:reportDescription],reportReason,[_answerObj.answerId longLongValue]];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =reportAnswerURL;
    wooRequestObj.time =0;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries =10;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = reportAnAnswer;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kUserHasBeenBlocked object:[NSString stringWithFormat:@"%lld",[_answerObj.wooId longLongValue]]];
        if (success){
        [APP_Utilities deleteMatchUserFromAppExceptMatchBoxWithoutReload:_answerObj.wooId.stringValue shouldDeleteFromAnswer:YES withCompletionHandler:nil];
        }

    }shouldReachServerThroughQueue:true];

    [MyAnswers deleteAllAnswersByUserWithUserID:[_answerObj.wooId longLongValue] withCompletionHandler:^(BOOL isDeletionCompleted) {
        if ([delegate respondsToSelector:selectorForUserFlagged]) {
            SuppressPerformSelectorLeakWarning([delegate performSelector:selectorForUserFlagged withObject:nil];);
        }
    }];
    
}

#pragma mark keyboardAppearDissappearMethods
-(void) keyboardDisappeared
{
    [UIView beginAnimations:@"animate" context:nil];
    [UIView setAnimationDuration:0.2f];
    [UIView setAnimationBeginsFromCurrentState: NO];
    self.centerView.transform = CGAffineTransformIdentity;
    [UIView commitAnimations];
}

-(void) keyboardAppeared
{
    [UIView beginAnimations:@"animate" context:nil];
    [UIView setAnimationDuration:0.2f];
    [UIView setAnimationBeginsFromCurrentState: NO];
    self.centerView.transform = CGAffineTransformMakeTranslation(0, -110);
    [UIView commitAnimations];
}

#pragma mark TextView delegate methods

- (void)textViewDidChange:(UITextView *)textView{
   
    
    switch (self.reportViewType) {
        case reportUser:
        {
            if (!_isAlreadMatched && selectedCell == optionsCount-1) {
                if (textView.text.length > 0) {
                    okButton.enabled = true;
                    okButton.alpha = 1.0;
                    enteredText = textView.text;
                }
                else{
                    //okButton.enabled = false;
                    //okButton.alpha = 0.5;
                }
            }
        }
            break;
        case reasonsForUnmatch:
        {
            if (selectedCell == optionsCount-2)
            {
                if (textView.text.length > 0)
                {
                    enteredText = textView.text;
                    okButton.enabled = true;
                    [okButton setTitleColor:[UIColorHelper colorFromRGB:@"#0072FB" withAlpha:1.0] forState:UIControlStateNormal];

                }
                else{
                    //okButton.enabled = false;
                    //[okButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal] ;
                }
            }
        }
            break;
        case reasonsForDelete:
        {
            if (selectedCell == optionsCount-1)
            {
                if (textView.text.length > 0)
                {
                    okButton.enabled = true;
                    enteredText = textView.text;
                    okButton.titleLabel.textColor = [UIColorHelper colorFromRGB:@"#0072FB" withAlpha:1.0];
                    
                }
                else{
                    //okButton.enabled = false;
                    //okButton.titleLabel.textColor = [UIColor grayColor];
                }
            }
            
        }
            break;
        default:
            break;
    }
    
    
}

@end
