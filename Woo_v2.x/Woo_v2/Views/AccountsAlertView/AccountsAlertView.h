//
//  AccountsAlertView.h
//  Woo
//
//  Created by Vaibhav Gautam on 08/11/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountsAlertView : UIView{
    
    __weak IBOutlet UIButton *logoutTickButton;
    __weak IBOutlet UIButton *deleteTickButton;
    
    __weak IBOutlet UILabel *firstOptionLabel;
    __weak IBOutlet UILabel *secondOptionLabel;
    
    
}

@property(nonatomic, assign)int tickIndex;


- (IBAction)logoutButtonTapped:(id)sender;
- (IBAction)deleteButtonTapped:(id)sender;

/**
 *  @author : umesh mishra, 5 June 2015
 
 Method to set the text on the radio button view.
 *
 *  @param firstOption  text of the first option Label.
 *  @param secondOption text of the second option Label.
 */
-(void)setFirstoption:(NSString *)firstOption andSecondOption:(NSString *)secondOption;

@end
