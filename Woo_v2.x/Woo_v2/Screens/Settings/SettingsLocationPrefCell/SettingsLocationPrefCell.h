//
//  SettingsLocationPrefCell.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 17/10/15.
//  Copyright © 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsLocationPrefCell : UITableViewCell{
    
    __weak IBOutlet UIView *redFilledView;
    
    __weak IBOutlet UIButton *firstButton;
    __weak IBOutlet UIButton *secondButton;
    __weak IBOutlet UIButton *thirdButton;
    __weak IBOutlet UIButton *fourthButton;
    __weak IBOutlet UIButton *fifthButton;
    
    
    __weak IBOutlet UILabel *firstLabel;
    __weak IBOutlet UILabel *secondLabel;
    __weak IBOutlet UILabel *thirdLabel;
    __weak IBOutlet UILabel *fourthLabel;
    __weak IBOutlet UILabel *fifthLabel;
    
    __weak IBOutlet NSLayoutConstraint *redBarWidthConstraint;
    __weak IBOutlet UIView *kmFadedView;
    __weak IBOutlet UIView *milesFadedView;
    
    __weak IBOutlet UILabel *warningTextLAbel;
    __weak IBOutlet UIImageView *distanceBG;
}
-(void)prepareCellForLocation:(NSInteger)maxDist;
- (IBAction)kmsTapped:(id)sender;
- (IBAction)milesTapped:(id)sender;

- (IBAction)locationSelectorButtonTapped:(id)sender;

@end
