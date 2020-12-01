//
//  AnswerAQuestionFillerView.h
//  Woo_v2
//
//  Created by Umesh Mishra on 26/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnswerAQuestionFillerView : UIView{
    
    __weak IBOutlet UILabel *messageLabel;
    __weak IBOutlet UIButton *askButton;
    __weak IBOutlet UILabel *footerLabel;
    __weak IBOutlet UIImageView *askQuestionImageView;
}

@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) SEL selectorForButtonTapped;

-(void)setMessageText:(NSString *)messageText buttonText:(NSString *)buttonText andFooterText:(NSString *)footerText;

-(IBAction)askButtonTapped:(id)sender;

-(void)setAskQuestionImage:(NSString *)imageName;

@end
