//
//  TypingArea.m
//  Woo
//
//  Created by Vaibhav Gautam on 07/05/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "TypingArea.h"
#define KNumberOfButtonInTypingView 3
#define kSendButtonDisabledColor [UIColor colorWithRed:0.73 green:0.73 blue:0.73 alpha:1.00]
#define kSendButtonEnabledColor  [UIColor colorWithRed:0.97 green:0.29 blue:0.31 alpha:1.00]
#define kHeightAfterRemovingTextField (kTypingAreaHeight - 30)

@implementation TypingArea

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        NSArray *nibArray = [[NSBundle mainBundle]loadNibNamed:@"TypingArea" owner:self options:nil];
        
        UIView *visibleView = [nibArray lastObject];
        [visibleView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, kTypingAreaHeight)];
        [self addSubview:visibleView];
    }
    
    [self setTypingViewFramesAccordingToScreen];
    
    [self addKeyboardNotificationObservers];
    [self beautifyView];
    
    return self;
}

-(void)setTypingViewFramesAccordingToScreen{
    
    [topBar setFrame:CGRectMake(0, topBar.frame.origin.y, SCREEN_WIDTH, 1)];
    [sendButton setFrame:CGRectMake(SCREEN_WIDTH-60, sendButton.frame.origin.y, sendButton.frame.size.width, sendButton.frame.size.height)];
    
    [typingView.layer setCornerRadius:20.0];
    [typingView.layer setMasksToBounds:YES];
    [typingView.layer setBorderColor: [UIColorHelper colorWithRGBA:@"#DEDEDE"].CGColor];
    [typingView.layer setBorderWidth:1.0];
    [typingField setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [typingField setFrame:CGRectMake(5, 5, SCREEN_WIDTH-95, 30)];
    [typingView setFrame:CGRectMake(10, 33, SCREEN_WIDTH-85, 40)];

    [placeHolderLbl setFrame:typingView.frame];
    [placeHolderLbl.layer setCornerRadius:20.0];
    [placeHolderLbl.layer setMasksToBounds:YES];
    //[placeHolderLbl setBackgroundColor:[UIColor clearColor]];
    
    [toolBarView setFrame:CGRectMake(0, (self.frame.size.height - toolBarView.frame.size.height), SCREEN_WIDTH, toolBarView.frame.size.height)];
    [bottomGrayLineLbl setFrame:CGRectMake(0, toolBarView.frame.size.height - 1, SCREEN_WIDTH, 1)];
    
    float widthValue = 80;
    [textButton setFrame:CGRectMake(0, textButton.frame.origin.y, widthValue, textButton.frame.size.height)];
    [textButtonSelectedUnderlineLbl setFrame:CGRectMake(0, toolBarView.frame.size.height - 2, widthValue, 2)];
    [firstSeparator setFrame:CGRectMake(textButton.frame.origin.x+textButton.frame.size.width, firstSeparator.frame.origin.y, firstSeparator.frame.size.width, firstSeparator.frame.size.height)];
    [backgroundView setFrame:CGRectMake(0, topBar.frame.origin.y, SCREEN_WIDTH, self.frame.size.height - topBar.frame.origin.y)];
    
    [galleryButton setFrame:CGRectMake(textButton.frame.origin.x+textButton.frame.size.width, galleryButton.frame.origin.y, widthValue, galleryButton.frame.size.height)];
    [galleryButtonSelectedUnderlineLbl setFrame:CGRectMake(textButton.frame.origin.x+textButton.frame.size.width, 32, widthValue, 2)];
    [secondSeparator setFrame:CGRectMake(galleryButton.frame.origin.x+galleryButton.frame.size.width, secondSeparator.frame.origin.y, secondSeparator.frame.size.width, secondSeparator.frame.size.height)];
    [cameraButton setFrame:CGRectMake(galleryButton.frame.origin.x+galleryButton.frame.size.width, cameraButton.frame.origin.y, widthValue, cameraButton.frame.size.height)];
    [cameraButtonSelectedUnderlineLbl setFrame:CGRectMake(galleryButton.frame.origin.x+galleryButton.frame.size.width, 32, widthValue, 2)];
    
    [thirdSeparator setFrame:CGRectMake(cameraButton.frame.origin.x+cameraButton.frame.size.width, thirdSeparator.frame.origin.y, thirdSeparator.frame.size.width, thirdSeparator.frame.size.height)];
}

-(void)beautifyView{

    //[sendButton setBackgroundColor:kSendButtonDisabledColor];
    [sendButton setImage:[UIImage imageNamed:@"ic_match_send_grey"] forState:UIControlStateNormal];
    //sendButton.layer.cornerRadius = 20.0f;
    sendButton.layer.masksToBounds = TRUE;
    [sendButton setUserInteractionEnabled:NO];
    textButton.selected = TRUE;
}

- (IBAction)stickerButtonTapped:(id)sender {
    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"TapStickerIcon" forScreenName:@"Chat"];
    UIButton *buttonObj = (UIButton *)sender;
    textButton.selected = FALSE;
    if (buttonObj.selected) {
        return;
    }
    [self endEditing:YES];
    buttonObj.selected = TRUE;
    if (!stickerViewObj) {
        stickerViewObj = [[StickerView alloc]initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height, SCREEN_WIDTH, 216)];
    }
    isStickersVisible=TRUE;

    CGRect frameOfSticker = CGRectZero;
    
    frameOfSticker = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 216, SCREEN_WIDTH, 216);
    
    
    [UIView animateWithDuration:0.25 animations:^{
        [APP_DELEGATE.window addSubview:stickerViewObj];
        typingField.hidden = TRUE;

        [self setFrame:CGRectMake(self.frame.origin.x, [[UIScreen mainScreen] bounds].size.height-(34 + 10 + 216), SCREEN_WIDTH, 34 + 10)];
        CGRect toolBarViewFrame = toolBarView.frame;
        toolBarViewFrame.origin.y = 5;
        toolBarView.frame = toolBarViewFrame;
        [backgroundView setFrame:CGRectMake(0, topBar.frame.origin.y, SCREEN_WIDTH, self.frame.size.height - topBar.frame.origin.y)];
        [stickerViewObj setFrame:frameOfSticker];
    } completion:^(BOOL finished) {
        
    }];
    heightOfKeyboard = 216;
    [[NSNotificationCenter defaultCenter] postNotificationName:kHeightChangedNotification object:[NSNumber numberWithInt:heightOfKeyboard]];
    [stickerViewObj setDelegate:self];
    [stickerViewObj setSelectorForStickerTapped:@selector(callbackForStickerTapped:)];
    if ([_delegate respondsToSelector:_selectorForStickerButtonTapped]) {
        [_delegate performSelector:_selectorForStickerButtonTapped];
    }
}

- (IBAction)textButtonTapped:(id)sender{
    
    
    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"TapTextMsgIcon" forScreenName:@"Chat"];
    UIButton *buttonObj = (UIButton *)sender;
    stickerButton.selected = FALSE;
    if (buttonObj.selected && typingField.isFirstResponder) {
        return;
    }
    typingField.hidden = FALSE;
    isStickersVisible = FALSE;
    buttonObj.selected = TRUE;
    [UIView animateWithDuration:0.25 animations:^{
        [typingField becomeFirstResponder];
        [stickerViewObj removeFromSuperview];
        [self setFrame:CGRectMake(self.frame.origin.x, [[UIScreen mainScreen] bounds].size.height-(typingField.frame.size.height+kHeightAfterRemovingTextField)-heightOfKeyboard, SCREEN_WIDTH, typingField.frame.size.height + kHeightAfterRemovingTextField)];
        CGRect toolBarViewFrame = toolBarView.frame;
        toolBarViewFrame.origin.y = typingField.frame.origin.y + typingField.frame.size.height + 8;
        toolBarView.frame = toolBarViewFrame;
        [backgroundView setFrame:CGRectMake(0, topBar.frame.origin.y, SCREEN_WIDTH, self.frame.size.height - topBar.frame.origin.y)];
    } completion:^(BOOL finished) {
        NSLog(@"done");
    }];
    if ([_delegate respondsToSelector:_selectorForStickerButtonTapped]) {
        [_delegate performSelector:_selectorForStickerButtonTapped];
    }
}

-(void)callbackForStickerTapped:(id)data{
    if ([_delegate respondsToSelector:_selectorForStickerTappedOnStickerView]) {
        [_delegate performSelector:_selectorForStickerTappedOnStickerView withObject:data];
    }
}


- (UIView *)keyboardView
{
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for (UIWindow *window in [windows reverseObjectEnumerator])
    {
        for (UIView *view in [window subviews])
        {
            if (!strcmp(object_getClassName(view), "UIKeyboard"))
            {
                return view;
            }
        }
    }
    return nil;
}


- (IBAction)sendButtonTapped:(id)sender {
  
    
    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"SendMsg" forScreenName:@"Chat"];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kChatMessageSentFirstTime] && [[NSUserDefaults standardUserDefaults] boolForKey:kChatMessageSentFirstTime] == NO) {
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kChatMessageSentFirstTime];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    if ([_delegate respondsToSelector:_selectorForSendButtonTapped]) {
        [_delegate performSelectorInBackground:_selectorForSendButtonTapped withObject:[typingField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    }
    
    [typingField setContentSize:CGSizeMake(typingField.contentSize.width, 30)];
    [typingField setText:@""];
    [self textViewDidChange:typingField];

}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if ([_delegate respondsToSelector:_selectorForViewBecameActive]) {
        [_delegate performSelector:_selectorForViewBecameActive withObject:nil];
    }
    [self textButtonTapped:textButton];
    if (isStickersVisible) {
        [self stickerButtonTapped:nil];
    }
}


#pragma mark - TextField delegate methods
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    NSString *trimmedOldString = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *trimmedNewString = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([[NSString stringWithFormat:@"%@%@",trimmedOldString,trimmedNewString] length] > 2000 && [text length] > 0) {
        
        //[textView setBackgroundColor:[UIColor whiteColor]];
        [sendButton setUserInteractionEnabled:YES];
//        sendButton.backgroundColor = kSendButtonEnabledColor;
        [sendButton setImage:[UIImage imageNamed:@"ic_match_send_red"] forState:UIControlStateNormal];
        
        int pendingTextLength = 2000 - (int)[[textView text] length];
        
        if (pendingTextLength != 0){
            text = [text substringToIndex:pendingTextLength];
            textView.text = [NSString stringWithFormat:@"%@%@",textView.text,text];
        }
        if ([_delegate respondsToSelector:_selectorForUserIsTypingSomething]) {
            [_delegate performSelector:_selectorForUserIsTypingSomething withObject:nil afterDelay:0.0];
        }
        return NO;
    }else if([[NSString stringWithFormat:@"%@%@",trimmedOldString,trimmedNewString] length] <1){
//        [textView setBackgroundColor:[UIColorHelper colorWithRGBA:@"#F9F9F9"]];
        [sendButton setUserInteractionEnabled:NO];
//        sendButton.backgroundColor = kSendButtonDisabledColor;
        [sendButton setImage:[UIImage imageNamed:@"ic_match_send_grey"] forState:UIControlStateNormal];
    }else{
       // [textView setBackgroundColor:[UIColor whiteColor]];
        [sendButton setUserInteractionEnabled:YES];
//        sendButton.backgroundColor = kSendButtonEnabledColor;
        [sendButton setImage:[UIImage imageNamed:@"ic_match_send_red"] forState:UIControlStateNormal];
    }
    if ([_delegate respondsToSelector:_selectorForUserIsTypingSomething]) {
        [_delegate performSelector:_selectorForUserIsTypingSomething withObject:nil afterDelay:0.0];
    }
    return YES;
}


- (void)textViewDidChange:(UITextView *)textView{

    NSString *newText = [NSString stringWithFormat:@"%@",textView.text];
    
    if ([textView.text length] < 1) {
        [placeHolderLbl.layer setCornerRadius:20.0];
        [placeHolderLbl.layer setMasksToBounds:YES];
        //[placeHolderLbl setBackgroundColor:[UIColor whiteColor]];
        placeHolderLbl.hidden = FALSE;
    }
    else{
        placeHolderLbl.hidden = TRUE;
        
    }
    if ([[newText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0) {
        [sendButton setUserInteractionEnabled:YES];
//        sendButton.backgroundColor = kSendButtonEnabledColor;
        [sendButton setImage:[UIImage imageNamed:@"ic_match_send_red"] forState:UIControlStateNormal];
    }else{
        [sendButton setUserInteractionEnabled:NO];
//        sendButton.backgroundColor = kSendButtonDisabledColor;
        [sendButton setImage:[UIImage imageNamed:@"ic_match_send_grey"] forState:UIControlStateNormal];
    }
    BOOL isHeightChagned = FALSE;
    int widthOfTextField= (int)typingField.frame.size.width;
    
    int newCalculatedHeight = (int)textView.contentSize.height;
    if (newCalculatedHeight <= 101) {
        if(newCalculatedHeight < 40)
        {
            newCalculatedHeight = 40;
        }
        int heightOfTheKeyboardBefore = typingField.frame.size.height;
        [typingField setFrame:CGRectMake(5, 5, SCREEN_WIDTH-95, newCalculatedHeight - 10)];
        [typingView setFrame:CGRectMake(10, 33, SCREEN_WIDTH-85, newCalculatedHeight)];

        CGRect toolBarViewFrame = toolBarView.frame;
        toolBarViewFrame.origin.y = typingView.frame.origin.y + newCalculatedHeight + 8;
        toolBarView.frame = toolBarViewFrame;
        [backgroundView setFrame:CGRectMake(0, topBar.frame.origin.y, SCREEN_WIDTH, self.frame.size.height - topBar.frame.origin.y)];
        if (newCalculatedHeight != heightOfTheKeyboardBefore) {
            isHeightChagned  =TRUE;
        }
    }
    CGFloat safeAreaTop = [[Utilities sharedUtility] getSafeAreaForTop:true andBottom:false];

    if (isKeyboardVisible) {
        [self setFrame:CGRectMake(self.frame.origin.x, [[UIScreen mainScreen] bounds].size.height-heightOfKeyboard-(typingView.frame.size.height+kHeightAfterRemovingTextField)- safeAreaTop, SCREEN_WIDTH, typingView.frame.size.height + kHeightAfterRemovingTextField)];
    }else{
        if (isStickersVisible) {
            [self setFrame:CGRectMake(self.frame.origin.x, [[UIScreen mainScreen] bounds].size.height-216-(typingView.frame.size.height+kHeightAfterRemovingTextField), SCREEN_WIDTH, typingView.frame.size.height + kHeightAfterRemovingTextField)];
        }else{
            [self setFrame:CGRectMake(self.frame.origin.x, ([[UIScreen mainScreen] bounds].size.height-(typingView.frame.size.height+kHeightAfterRemovingTextField) - safeAreaTop), SCREEN_WIDTH, typingView.frame.size.height + kHeightAfterRemovingTextField)];
        }
    }
    [self scrollTextViewToBottom:typingField];
    if (isHeightChagned) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kHeightChangedNotification object:[NSNumber numberWithInt:100]];
    }
}



-(void)scrollTextViewToBottom:(UITextView *)textView {
    if(textView.text.length > 0 ) {
        NSRange bottom = NSMakeRange(textView.text.length -1, 1);
        [textView scrollRangeToVisible:bottom];
    }
    if (textView.contentSize.height > textView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, textView.contentSize.height - textView.frame.size.height);
        [textView setContentOffset:offset animated:YES];
    }
}

-(void)show{
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    [self deactivateTypingArea];
}
-(void)showOnView:(UIView *)viewObj{
    [viewObj addSubview:self];
    [self deactivateTypingArea];
}


- (void)keyboardWillShow:(NSNotification *)aNotification {
    
    isKeyboardVisible = YES;
    NSDictionary *userInfo = aNotification.userInfo;
    
    CGFloat safeAreaTop = [[Utilities sharedUtility] getSafeAreaForTop:true andBottom:false];

    NSValue *endFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardEndFrame = [self convertRect:endFrameValue.CGRectValue fromView:nil];
    
    NSValue *beginFrameValue = userInfo[UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardBeginFrame = [self convertRect:beginFrameValue.CGRectValue fromView:nil];
    NSNumber *durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration = durationValue.doubleValue;
    
    NSNumber *curveValue = userInfo[UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curveValue.intValue;
    if (heightOfKeyboard == keyboardEndFrame.size.height) {
        return;
    }
    void (^animations)() = ^() {
            self.frame = CGRectMake(keyboardEndFrame.origin.x, [[UIScreen mainScreen] bounds].size.height - keyboardEndFrame.size.height-self.frame.size.height - safeAreaTop, keyboardEndFrame.size.width, self.frame.size.height);
    };
    [UIView animateWithDuration:animationDuration delay:0.0 options:(animationCurve << 16) animations:animations completion:^(BOOL finished) {
        if (finished) {
            if (heightOfKeyboard != 0) {
                int newDifference = newDifference = keyboardEndFrame.size.height - keyboardBeginFrame.size.height;
                [[NSNotificationCenter defaultCenter] postNotificationName:kHeightChangedNotification object:[NSNumber numberWithInt:newDifference]];
            }
        }
    }];
    
    heightOfKeyboard = keyboardEndFrame.size.height;
}
- (void)keyboardWillHide:(NSNotification *)aNotification{
    isKeyboardVisible = NO;
    NSDictionary *userInfo = aNotification.userInfo;

    CGFloat safeArea = [[Utilities sharedUtility] getSafeAreaForTop:true andBottom:true];

    // Get keyboard animation.
    NSNumber *durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration = durationValue.doubleValue;
    
    NSNumber *curveValue = userInfo[UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curveValue.intValue;
        
    int screenHeight = APP_DELEGATE.window.frame.size.height;
    
    void (^animations)() = ^() {
        float yPos = screenHeight - (typingView.frame.size.height+kHeightAfterRemovingTextField) - safeArea;
        self.frame = CGRectMake(0,yPos, SCREEN_WIDTH, typingView.frame.size.height+kHeightAfterRemovingTextField);
    };
    [UIView animateWithDuration:animationDuration delay:0.0 options:(animationCurve << 16) animations:animations completion:^(BOOL finished) {
        heightOfKeyboard = 0;
        [[NSNotificationCenter defaultCenter] postNotificationName:kHeightChangedNotification object:[NSNumber numberWithInt:heightOfKeyboard]];
    }];

}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
//    NSLog(@">>>>>textFieldDidBeginEditing");
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
//    NSLog(@">>>>>textFieldDidEndEditing");
}

- (void)activateTypingArea{
    
    [typingField becomeFirstResponder];
    
    if ([_delegate respondsToSelector:_selectorForKeyboardDisplayed]) {
        [_delegate performSelector:_selectorForKeyboardDisplayed];
    }
}


- (void)deactivateTypingArea{
    dispatch_async(dispatch_get_main_queue(), ^{
        [stickerViewObj removeFromSuperview];
        isStickersVisible = NO;
        [self endEditing:YES];
        CGFloat safeAreaBottom = [[Utilities sharedUtility] getSafeAreaForTop:true andBottom:true];

        [self setFrame:CGRectMake(self.frame.origin.x, [[UIScreen mainScreen] bounds].size.height-(typingView.frame.size.height+kHeightAfterRemovingTextField) - safeAreaBottom, SCREEN_WIDTH, typingView.frame.size.height +  kHeightAfterRemovingTextField)];
        CGRect toolBarViewFrame = toolBarView.frame;
        toolBarViewFrame.origin.y = self.frame.size.height - toolBarView.frame.size.height;
        toolBarView.frame = toolBarViewFrame;
        textButton.selected = TRUE;
        stickerButton.selected = FALSE;
        [backgroundView setFrame:CGRectMake(0, topBar.frame.origin.y, SCREEN_WIDTH, self.frame.size.height - topBar.frame.origin.y)];
        isStickersVisible = FALSE;
        
        if ([_delegate respondsToSelector:_selectorForKeyboardDismissed]) {
            [_delegate performSelector:_selectorForKeyboardDismissed];
        }
        if ([typingField.text length] > 0) {
           // sendButton.backgroundColor = kSendButtonEnabledColor;
            [sendButton setImage:[UIImage imageNamed:@"ic_match_send_red"] forState:UIControlStateNormal];
        }
        else{
           // sendButton.backgroundColor = kSendButtonDisabledColor;
            [sendButton setImage:[UIImage imageNamed:@"ic_match_send_grey"] forState:UIControlStateNormal];
        }
    });
}


-(void)addKeyboardNotificationObservers{
    isKeyboardVisible = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


-(void)removeNotificationObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


-(void)enableAll:(BOOL)enable{
    [sendButton setEnabled:enable];
    [typingField setEditable:enable];
    [stickerButton setEnabled:enable];
//    sendButton.backgroundColor = enable?kSendButtonEnabledColor:kSendButtonDisabledColor;
    
    if (enable && ([typingField.text length] > 0)) {
//        sendButton.backgroundColor = kSendButtonEnabledColor;
        [sendButton setImage:[UIImage imageNamed:@"ic_match_send_red"] forState:UIControlStateNormal];
    }
    else{
//        sendButton.backgroundColor = kSendButtonDisabledColor;
        [sendButton setImage:[UIImage imageNamed:@"ic_match_send_grey"] forState:UIControlStateNormal];
    }
    [stickerButton setAlpha:enable?1.0f:0.5f];
    [textButton setEnabled:enable];
    [cameraButton setEnabled:enable];
    [galleryButton setEnabled:enable];
    
}


-(UITextView *)returnTextView{
    return typingField;
}

- (IBAction)cameraButtonTapped:(id)sender{
    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"TapCameraIcon" forScreenName:@"Chat"];
    if ([_delegate respondsToSelector:_selectorForCameraButtonTapped]) {
        [_delegate performSelector:_selectorForCameraButtonTapped withObject:nil afterDelay:0.0];
    }
}
- (IBAction)galleryButtonTapped:(id)sender{
    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"TapGalleryIcon" forScreenName:@"Chat"];
    if ([_delegate respondsToSelector:_selectorForGalleryButtonTapped]) {
        [_delegate performSelector:_selectorForGalleryButtonTapped withObject:nil afterDelay:0.0];
    }
}


//Added by Umesh to remove crash "cfnotificationcenter is calling out to an observer" on 11 August 2014
-(void)dealloc{
    [self removeNotificationObservers];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)makeAppsflyerFirstMessageCall{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] || [[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue] <=0) {
        return;
    }
    [[AppsFlyerTracker sharedTracker] trackEvent:@"CHAT" withValues:@{@"User_id":[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],}];
    [ApplicationDelegate sendFirebaseEvent:@"Chat" andScreen:@""];
}

@end
