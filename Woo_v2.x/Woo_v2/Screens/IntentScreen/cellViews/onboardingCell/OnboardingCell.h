//
//  OnboardingCell.h
//  OnboardingSprint
//
//  Created by Suparno Bose on 12/05/16.
//  Copyright © 2016 Umesh Mishra. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^GenderButtonStateChangeBlock)(GenderPreference tappedGenderButton, BOOL isGenderSelected, IntentType myIntentType);
typedef void (^IntentSelectedBlock)(IntentType selectedIntentType);

@interface OnboardingCell : UITableViewCell{
    SelectedGenderPreference selectedGender;
    
    GenderButtonStateChangeBlock genderButtonStateChangeBlock;
    IntentSelectedBlock intentSelectedBlock;
    
    IntentType myIntentType;
    
    
}

-(void)genderButtonStateChanged:(GenderButtonStateChangeBlock)genderStateChangedBlock;
-(void)intentButtonTapped:(IntentSelectedBlock)intentBlock;

-(void)setTileForTheCell:(NSString *)cellTitle withIntentType:(IntentType)intentType withSelectedIntent:(IntentType)selectedIntent andSelectedGenderForIntent:(SelectedGenderPreference)genderPreference;

@property (weak, nonatomic) IBOutlet UIButton *primaryStarButton;

@property (weak, nonatomic) IBOutlet UIButton *manSelectionButton;

@property (weak, nonatomic) IBOutlet UIButton *womanSelectionButton;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


@end
