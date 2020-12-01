//
//  UploadAPhotoView.m
//  Woo_v2
//
//  Created by Suparno Bose on 15/03/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "UploadAPhotoView.h"
#import "ImageSelectionViewController.h"
#import <CoreText/CTStringAttributes.h>
@interface UploadAPhotoView (){
    UploadAPhotoViewGetBlock _uploadBlock;
}
@end

@implementation UploadAPhotoView

+(UploadAPhotoView*) createFromNIBWithOwner:(id)owner{
    UploadAPhotoView *oUploadAPhotoView = [[[NSBundle mainBundle] loadNibNamed:@"UploadAPhotoView"
                                                                owner:owner options:nil] firstObject];
    [oUploadAPhotoView setFrame:CGRectMake(0,0,SCREEN_WIDTH,SCREEN_HEIGHT)];
    [APP_DELEGATE.window.rootViewController.view addSubview:oUploadAPhotoView];
    return oUploadAPhotoView;
}

-(void) drawRect:(CGRect)rect{
    [super drawRect:rect];
    containerView.layer.cornerRadius = 10.0;
    addPhotosButton.layer.cornerRadius =5.0;
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:skipbutton.titleLabel.text];
    [attString addAttribute:(NSString*)kCTUnderlineStyleAttributeName
                      value:[NSNumber numberWithInt:kCTUnderlineStyleSingle]
                      range:(NSRange){0,[attString length]}];
    UIColor *color = [UIColor colorWithRed:208.0/255.0 green:44.0/255.0 blue:54.0/255.0 alpha:1.0];
    [attString addAttribute:NSForegroundColorAttributeName value:color  range:NSMakeRange(0, [attString length])];
    [skipbutton setAttributedTitle:attString forState:UIControlStateNormal];
}

- (IBAction)addPhotosButtonPressed:(id)sender {
    _uploadBlock(0);
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"YayYouAreInOrPhotoUploadViewHasNotBeenDismissed"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self removeFromSuperview];
}

- (IBAction)skipButtonTapped:(id)sender {
    _uploadBlock(1);
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"YayYouAreInOrPhotoUploadViewHasNotBeenDismissed"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self removeFromSuperview];
}

- (void)performTaskBasedOnActionPerformed:(UploadAPhotoViewGetBlock _Nonnull)block
{
    _uploadBlock = block;
}

@end
