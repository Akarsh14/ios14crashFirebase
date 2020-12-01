//
//  LoginScreenInfoView.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 16/03/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "LoginScreenInfoView.h"
@implementation LoginScreenInfoView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(void)awakeFromNib{
    
    centerView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    centerView.layer.shadowOpacity = 0.4;
    centerView.layer.shadowRadius = 3.0;
    centerView.layer.shadowOffset = CGSizeMake(0.0, 2.0);

    
//    centerView.layer.masksToBounds = NO;
//    centerView.layer.shadowColor = [UIColor blackColor].CGColor;
//    centerView.layer.shadowOffset = CGSizeMake(0, 0);
//    centerView.layer.shadowOpacity = 0.5f;
//    centerView.layer.shadowRadius = 50.0;
//    centerView.layer.cornerRadius = 10.0f;
    
    centerView.layer.borderWidth = 0.3f;
    centerView.layer.borderColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.1].CGColor;
    
}
- (IBAction)removeButtonTapped:(id)sender {
    [self dismissLoginInfoView];
}

-(void)dismissLoginInfoView{
    [UIView animateWithDuration:0.5f animations:^{
        [self setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        viewDismissedBlock(TRUE , FALSE , FALSE);
    }];
}


- (IBAction)privacyButtonTapped:(id)sender{
//    if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"http://www.getwooapp.com/pdf/Woo-privacy-policy.pdf"]]) {
//        [[UIApplication sharedApplication] openURL: [NSURL URLWithString:@"http://www.getwooapp.com/pdf/Woo-privacy-policy.pdf"]];
//    }
    

    viewDismissedBlock(FALSE , TRUE , FALSE);
    
}

- (IBAction)termsButtonTapped:(id)sender{
//    if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"http://www.getwooapp.com/pdf/Woo-privacy-policy.pdf"]]) {
//        [[UIApplication sharedApplication] openURL: [NSURL URLWithString:@"http://www.getwooapp.com/pdf/Woo-privacy-policy.pdf"]];
//    }
    
        viewDismissedBlock(FALSE , FALSE , TRUE);
}


-(void)presentViewOnView:(UIView *)viewObj{
    self.alpha = 0.0f;
    [viewObj addSubview:self];
    
    [UIView animateWithDuration:0.3f animations:^{
        [self setAlpha:1.0f];
    } completion:^(BOOL finished) {
        //
    }];
}

-(void)viewDismissed:(LoginInfoViewDismissed)callBack{
    viewDismissedBlock = callBack;
}
@end
