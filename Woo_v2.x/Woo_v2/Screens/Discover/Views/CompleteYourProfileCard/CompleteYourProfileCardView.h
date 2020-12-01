//
//  CompleteYourProfileCardView.h
//  Woo_v2
//
//  Created by Umesh Mishra on 09/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LDProgressView.h"

@interface CompleteYourProfileCardView : UIView{
    LDProgressView *progressViewObj;
    UILabel *titleLabel;
    IBOutlet UIImageView *userProfileImage;
    IBOutlet UILabel *nameAgeLabel;
    IBOutlet UILabel *messageLabel;
    IBOutlet UIButton *buttonObj;
    IBOutlet UIView *progressViewContainer;
}

@property(nonatomic, weak) id delegate;
@property(nonatomic, assign) SEL selectorCompleteYourProfileButtonTapped;

-(void)addProgressViewWithProgress:(float)progressVal;

-(IBAction)completeYourProfileButtonTapped:(id)sender;
-(void)setName:(NSString *)userName andAge:(NSString *)userAge;

@end
