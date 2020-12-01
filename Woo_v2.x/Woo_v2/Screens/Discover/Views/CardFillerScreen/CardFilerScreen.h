//
//  CardFilerScreen.h
//  Woo_v2
//
//  Created by Umesh Mishra on 09/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardFilerScreen : UIView{
    __weak IBOutlet UIImageView *errorImageView;
    __weak IBOutlet UILabel *headingLabel;
    __weak IBOutlet UILabel *messageLabel;
    __weak IBOutlet UIButton *buttonObject;
}

@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) SEL selectorForButtonTapped;

-(void)setErrorImage:(UIImage *)errorImage setHeadingText:(NSString *)headingText setMessageText:(NSString *)MessageText andButtonText:(NSString *)buttonText;

-(IBAction)buttonTapped:(id)sender;

-(void)showButton:(BOOL)needToshowButton;

@end
