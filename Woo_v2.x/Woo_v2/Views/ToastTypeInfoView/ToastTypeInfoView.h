//
//  ToastTypeInfoView.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 10/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^ToastViewDismissed) (BOOL isViewDismissed);
@interface ToastTypeInfoView : UIView{
    
    __weak IBOutlet UIImageView *centreImage;
    __weak IBOutlet UILabel *infoLabel;
    
    ToastViewDismissed toatViewDismissedBlock;
}


-(void)setTextOnView:(NSString *)infoText withImage:(UIImage *)infoImage;
-(void)presentViewDuration:(float )animationDuration onView:(UIView *)presentingView;

-(void)toastViewDismissedBlock:(ToastViewDismissed)toastViewDismissedBlock;

@end
