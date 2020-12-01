//
//  TypingArea.h
//  Woo
//
//  Created by Vaibhav Gautam on 07/05/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StickerView.h"

@interface TypingArea : UIView<UITextViewDelegate>{
    
    __weak IBOutlet UIView *typingView;
    __weak IBOutlet UIButton *sendButton;
    __weak IBOutlet UITextView *typingField;
    __weak IBOutlet UIButton *stickerButton;
    __weak IBOutlet UIButton *textButton;
    __weak IBOutlet UILabel *topBar;
    
    __weak IBOutlet UIButton *cameraButton;
    __weak IBOutlet UIButton *galleryButton;
    __weak IBOutlet UIView *toolBarView;
    
    __weak IBOutlet UILabel *firstSeparator;
    __weak IBOutlet UILabel *secondSeparator;
    __weak IBOutlet UILabel *thirdSeparator;
    
    __weak IBOutlet UILabel *textButtonSelectedUnderlineLbl;
    __weak IBOutlet UILabel *galleryButtonSelectedUnderlineLbl;
    __weak IBOutlet UILabel *cameraButtonSelectedUnderlineLbl;
    __weak IBOutlet UILabel *bottomGrayLineLbl;
    __weak IBOutlet UILabel *placeHolderLbl;
    
    
    BOOL isStickersVisible;
    BOOL isKeyboardVisible;
    
    StickerView *stickerViewObj;
    
    int heightOfKeyboard;
    
    NSInteger lastSelectedButtonTag;
    
    IBOutlet UIView *backgroundView;
}

@property(nonatomic, weak)id delegate;
@property(nonatomic, assign)SEL selectorForStickerButtonTapped;
@property(nonatomic, assign)SEL selectorForSendButtonTapped;
@property(nonatomic, assign)SEL selectorForCameraButtonTapped;
@property(nonatomic, assign)SEL selectorForGalleryButtonTapped;
@property(nonatomic, assign)SEL selectorForUserIsTypingSomething;

@property(nonatomic, assign)SEL selectorForViewBecameActive;

@property(nonatomic, assign)SEL selectorForKeyboardDisplayed;
@property(nonatomic, assign)SEL selectorForKeyboardDismissed;

@property(nonatomic, assign)SEL selectorForStickerTappedOnStickerView;

- (IBAction)stickerButtonTapped:(id)sender;
- (IBAction)cameraButtonTapped:(id)sender;
- (IBAction)galleryButtonTapped:(id)sender;
- (IBAction)textButtonTapped:(id)sender;
- (IBAction)sendButtonTapped:(id)sender;
- (void)activateTypingArea;
- (void)deactivateTypingArea;
- (void)show;
-(void)showOnView:(UIView *)viewObj;

-(void)enableAll:(BOOL)enable;

-(UITextView *)returnTextView;
-(void)addKeyboardNotificationObservers;
-(void)removeNotificationObservers;
@end
