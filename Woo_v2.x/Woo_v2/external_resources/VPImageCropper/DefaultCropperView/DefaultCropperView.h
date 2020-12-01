//
//  DefaultCropperView.h
//  Woo_v2
//
//  Created by Deepak Gupta on 8/23/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^PhotoOptionsTappedBlock)(int buttonTapState);

@interface DefaultCropperView : UIView
@property (weak, nonatomic) IBOutlet UILabel *lblIntro;

@property (weak, nonatomic) IBOutlet UIButton *btnCamera;
@property(nonatomic , weak) IBOutlet UIImageView      *botImg;
@property(nonatomic , weak) IBOutlet UILabel          *lblMessage;

- (void)actionPerformedWithBlock:(PhotoOptionsTappedBlock)block;

@end
