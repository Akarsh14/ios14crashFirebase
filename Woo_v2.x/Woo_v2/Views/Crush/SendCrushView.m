//
//  SendCrushView.m
//  Woo_v2
//
//  Created by Umesh Mishraji on 11/01/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "SendCrushView.h"

@implementation SendCrushView


-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    [lblSendACrush setText:NSLocalizedString(@"Send a Crush", nil)];
    
    //check if memory is allocated to self
    if (self) {
        NSArray *viewArrayFromXib = [[NSBundle mainBundle] loadNibNamed:@"SendCrushView" owner:self options:nil];
        UIView *viewObj = [viewArrayFromXib objectAtIndex:0];
        viewObj.frame = self.bounds;
        [self addSubview:viewObj];
        [self addSingleTapGestureToRemoveView];
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlesingleTapeGesture) name:@"MatchOverlaySeen" object:nil];
    
    return self;
}

-(void)removeFromSuperview{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super removeFromSuperview];
}

-(void)presentViewOnView:(UIView *)viewObj withTemplateQuestions:(NSArray *)templateQuestionArray userName:(NSString *)userName withAnimationTime:(float)animationTime withCompletionBlock:(void(^)(BOOL animationCompleted))block{
    
    if (!_wasTemplateSelected){
        _selectedRow = -1;
    }
    [templateCrushMessageTable registerNib:[UINib nibWithNibName:@"TemplateCrushCell" bundle:nil] forCellReuseIdentifier:@"templateCrushCell"];
    
    _crushTemplateArray = templateQuestionArray;
    animationTimeOfView = animationTime;
    userNameTxt = userName;
    [self beautifyView];
    [templateCrushMessageTable reloadData];
    CGRect frameRect = self.frame;
    frameRect.origin.y = APP_DELEGATE.window.frame.size.height;
    self.frame = frameRect;
    [viewObj addSubview:self];
    [self enableOrDisableSendBtn];
    
    if (_wasTemplateSelected){
        placeholderLbl.text = @"";
        lastHeight = 0;
        crushMsgTextView.text = @"";
        [self templateSelectedForIndexPath:[NSIndexPath indexPathForRow:_selectedRow inSection:0]];
    }
    else{
        if (_crushMessageTyped.length == 0 || _crushMessageTyped == nil){
            placeholderLbl.text = NSLocalizedString(@"Write something interesting.", nil);
        }
    }
    
    [UIView animateWithDuration:animationTime animations:^{
        CGRect newFrameAfterAnimation = self.frame;
        newFrameAfterAnimation.origin.y = 0;
        self.frame = newFrameAfterAnimation;
    } completion:^(BOOL finished) {
        block(TRUE);
    }];
    
}

-(void)beautifyView{
    if ([CrushModel sharedInstance].availableCrush > 0){
        numberOfCrushLeftLbl.text = [NSString stringWithFormat:@"(%ld/%ld)",[CrushModel sharedInstance].availableCrush,(long)[CrushModel sharedInstance].totalCrush];
        crushMsgContainerView.layer.borderColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1].CGColor;
    }
    else{
        numberOfCrushLeftLbl.text = @"";
    }
    lastHeight = 40;
    crushMsgTextView.contentSize = CGSizeMake(crushMsgTextView.contentSize.width, 40.0f);
    backBtn.hidden = TRUE;
    sendCrushHeaderLblLeftConstraint.constant = 20;
    // [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    // [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    // [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
}


-(void)addSingleTapGestureToRemoveView{
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlesingleTapeGesture)];
    singleTapGesture.numberOfTapsRequired = 1;
    [blankAreaView addGestureRecognizer:singleTapGesture];
}

-(void)handlesingleTapeGesture{
    isTemplateTapped = false;
    crushMsgTextView.text = @"";
    [self performSelector:@selector(textViewDidChange:) withObject:crushMsgTextView afterDelay:0.01f];
    [self dismissViewWithAnimation:FALSE];
}

-(void)dismissViewWithAnimation:(BOOL)isSendButtonTapped{
    if (_selectedRow >= 0){
        NSString *selectedText = [_crushTemplateArray objectAtIndex:_selectedRow];
        if (![selectedText isEqualToString:crushMsgTextView.text]){
        _isTemplateTapped = false;
        }
    }
    else{
        _isTemplateTapped = false;
    }
    [UIView animateWithDuration:animationTimeOfView animations:^{
        CGRect newFrameAfterAnimation = self.frame;
        newFrameAfterAnimation.origin.y = APP_DELEGATE.window.frame.size.height;;
        self.frame = newFrameAfterAnimation;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
        _sendCrushViewDismissedBlock(crushMsgTextView.text, isSendButtonTapped , _isTemplateTapped, _selectedRow);
    }];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_crushTemplateArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float width = APP_DELEGATE.window.frame.size.width-95;
    //    NSLog(@"width of the lbl :%f",width);
    float heightOfCell = [APP_Utilities getHeightForText:[_crushTemplateArray objectAtIndex:indexPath.row] forFont:[UIFont fontWithName:kProximaNovaFontRegular size:12] widthOfLabel:width];
    //    NSLog(@"height of the cell :%f",heightOfCell);
    return heightOfCell+26;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"templateCrushCell";
    
    TemplateCrushCell *cell = (TemplateCrushCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = (TemplateCrushCell *)[[NSBundle mainBundle] loadNibNamed:@"TemplateCrushCell" owner:self options:nil];
    }
    [cell setTextOnCell:[_crushTemplateArray objectAtIndex:indexPath.row] setIfTheCellIsSelected:((indexPath.row == _selectedRow)?TRUE:FALSE)];
    [cell isFirstCellOfTheTable:(indexPath.row == 0)];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self templateSelectedForIndexPath:indexPath];
}

- (void)templateSelectedForIndexPath:(NSIndexPath *)indexPath{
    _isTemplateTapped = YES;
    _selectedRow = indexPath.row;
    [templateCrushMessageTable reloadData];
    if ([placeholderLbl.text length]>0) {
        placeholderLbl.text = @"";
    }
    NSString *selectedText = [_crushTemplateArray objectAtIndex:indexPath.row];
    [self textView:crushMsgTextView shouldChangeTextInRange:NSMakeRange(0, 0) replacementText:selectedText];
    if (![crushMsgTextView.text isEqualToString:selectedText]) {
        crushMsgTextView.text = selectedText;
    }
    [self performSelector:@selector(textViewDidChange:) withObject:crushMsgTextView afterDelay:0.01f];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    
    backBtn.hidden = FALSE;
    needToDeselectTemplateQuestion = TRUE;
    sendCrushHeaderLblLeftConstraint.constant = 30;
    return TRUE;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    needToDeselectTemplateQuestion = FALSE;
    return TRUE;
}

- (void)textViewDidChange:(UITextView *)textView{
    
    NSLog(@"content height of the textview new :%f",crushMsgTextView.contentSize.height);
    
    if (lastHeight != crushMsgTextView.contentSize.height) {
        NSLog(@"change in height");
        
        [self layoutIfNeeded];
        crushTextViewContainerViewHeightConstraint.constant = crushMsgTextView.contentSize.height;
        if (crushMsgTextView.contentSize.height>90) {
            crushTextViewContainerViewHeightConstraint.constant = 90;
        }
        if (crushMsgTextView.contentSize.height<40) {
            crushMsgTextView.contentSize = CGSizeMake(crushMsgTextView.contentSize.width, 40.0f);
        }
    }
    if (crushMsgTextView.contentSize.height<=90) {
        crushTextViewContainerViewHeightConstraint.constant = crushMsgTextView.contentSize.height;
        sendCrushMainContainerViewHeightConstraint.constant = 64 + crushMsgTextView.contentSize.height;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        [self layoutIfNeeded];
    }];
    
    if ([textView.text length]>140) {
        textView.text = [textView.text substringToIndex:140];
    }
    numberOfCharLeftLbl.text = [NSString stringWithFormat:@"%d",(int)(140-[textView.text length])];
    [self enableOrDisableSendBtn];
    if ((_selectedRow != -1) && needToDeselectTemplateQuestion) {
        _selectedRow = -1;
        [templateCrushMessageTable reloadData];
    }
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if ([text isEqualToString:@"\n"] || (([textView.text length]>=140) && ([text length]>0))){
        [textView resignFirstResponder];
        return FALSE;
    }
    
    if ([text length]>0) {
        if (!isTextChanged) {
            placeholderLbl.text = @"";
        }
    }
    else{
        if (([crushMsgTextView.text length] - range.length) <= 0) {
            placeholderLbl.text = NSLocalizedString(@"Write something interesting", nil);
        }
    }
    return TRUE;
}


-(IBAction)sendButtonTapped:(id)sender{
    if (sendBtn.selected == true) {
        return;
    }
    [self dismissViewWithAnimation:TRUE];
    
}
-(IBAction)backBtnTapped:(id)sender{
    backBtn.hidden = TRUE;
    sendCrushHeaderLblLeftConstraint.constant = 20;
    if ([crushMsgTextView isFirstResponder]) {
        [crushMsgTextView resignFirstResponder];
    }
}

-(void)viewDismissed:(SendCrushViewDismissed)dissmisBlock{
    _sendCrushViewDismissedBlock = dissmisBlock;
}

- (void)keyboardWillShow:(NSNotification *)aNotification{
    
}

- (void)keyboardWillHide:(NSNotification *)aNotification{
    [self backBtnTapped:nil];
}

- (void)keyboardWasShown:(NSNotification *)aNotification{
    [self layoutIfNeeded];
    
    CGSize endKeyboardSize = [[aNotification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    int endHeightInInt = endKeyboardSize.height;
    int endWidthInInt = endKeyboardSize.width;
    int endHeight = MIN(endHeightInInt, endWidthInInt);
    
    CGFloat expectedKeyBoardHeight = endHeight;
    
    templateCrushTableViewHeightConstraint.constant = expectedKeyBoardHeight;
    
    [UIView animateWithDuration:0.25 animations:^{
        [self layoutIfNeeded];
        
    }];
}

-(void)enableOrDisableSendBtn{
    if ([crushMsgTextView.text length]>0) {
        sendBtn.selected = false;
        [UIView animateWithDuration:0.75 animations:^{
            sendBtn.backgroundColor = [UIColor colorWithRed:245.0f/255.0f green:47.0f/255.0f blue:57.0f/255.0f alpha:1.0];
        }];
    }
    else{
        sendBtn.selected = true;
        [UIView animateWithDuration:0.75 animations:^{
            sendBtn.backgroundColor = [UIColor colorWithRed:193.0f/255.0f green:193.0f/255.0f blue:193.0f/255.0f alpha:1.0];
        }];
    }
}



@end
