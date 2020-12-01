//
//  FacebookSyncView.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 24/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FacebookSyncView : UIView{
    
    __weak IBOutlet UIButton *workPlaceRadio;
    __weak IBOutlet UIButton *educationRadio;
    __weak IBOutlet UIButton *genderRadio;
    __weak IBOutlet UIButton *ageRadio;
    
    __weak IBOutlet UIButton *syncButton;
    
//    BOOL isWorkPlaceSelected;
//    BOOL isEducationSelected;
//    BOOL isGenderSelected;
//    BOOL isAgeSelected;
    
}
@property(nonatomic, assign)BOOL isWorkPlaceSelected;
@property(nonatomic, assign)BOOL isEducationSelected;
@property(nonatomic, assign)BOOL isGenderSelected;
@property(nonatomic, assign)BOOL isAgeSelected;
@property(nonatomic, weak)id delegate;
@property(nonatomic, assign)SEL selectorForsubmittButtonTapped;
- (IBAction)workplaceButtonTapped:(id)sender;
- (IBAction)educationButtonTapped:(id)sender;
- (IBAction)genderButtonTapped:(id)sender;
- (IBAction)ageButtonTapped:(id)sender;


- (IBAction)cancelButtonTapped:(id)sender;
- (IBAction)syncButtonTapped:(id)sender;

@end
