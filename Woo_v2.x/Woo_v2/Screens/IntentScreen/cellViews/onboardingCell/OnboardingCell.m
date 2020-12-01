//
//  OnboardingCell.m
//  OnboardingSprint
//
//  Created by Suparno Bose on 12/05/16.
//  Copyright © 2016 Umesh Mishra. All rights reserved.
//

#import "OnboardingCell.h"

@implementation OnboardingCell
{
    
}

-(void)setTileForTheCell:(NSString *)cellTitle withIntentType:(IntentType)intentType withSelectedIntent:(IntentType)selectedIntent andSelectedGenderForIntent:(SelectedGenderPreference)genderPreference{
    _titleLabel.text = cellTitle;
    myIntentType = intentType;
    selectedGender = genderPreference;
    self.primaryStarButton.tag = intentType;
    [self setPrimaryStarButtonStatusAccrodingToSelectedIntent:selectedIntent];
    [self setGenderStatesBasedOnSelectedGEnderPreference:genderPreference];
}

-(void)setPrimaryStarButtonStatusAccrodingToSelectedIntent:(IntentType)selectedIntent{
    if (selectedIntent == myIntentType) {
        self.primaryStarButton.selected = TRUE;
    }
    else{
        self.primaryStarButton.selected = FALSE;
    }
}

-(void)setGenderStatesBasedOnSelectedGEnderPreference:(SelectedGenderPreference)selectedGenderVal{
    switch (selectedGenderVal) {
        case SELECTED_GENDER_PREFERENCE_NONE:{
            self.manSelectionButton.selected = FALSE;
            self.womanSelectionButton.selected = FALSE;
        }
            break;
        case SELECTED_GENDER_PREFERENCE_MALE:{
            self.manSelectionButton.selected = TRUE;
            self.womanSelectionButton.selected = FALSE;
        }
            break;
        case SELECTED_GENDER_PREFERENCE_FEMALE:{
            self.manSelectionButton.selected = FALSE;
            self.womanSelectionButton.selected = TRUE;
        }
            break;
        case SELECTED_GENDER_PREFERENCE_BOTH:{
            self.manSelectionButton.selected = TRUE;
            self.womanSelectionButton.selected = TRUE;
        }
            break;
        default:
            break;
    }
}

-(void)genderButtonStateChanged:(GenderButtonStateChangeBlock)genderStateChangedBlock{
    genderButtonStateChangeBlock = genderStateChangedBlock;
}
-(void)intentButtonTapped:(IntentSelectedBlock)intentBlock{
    intentSelectedBlock = intentBlock;
}

- (IBAction)primaryStarButtonPressed:(id)sender {
    if (self.primaryStarButton.selected) {
        [self.primaryStarButton setSelected:FALSE];
    }
    else{
        [self.primaryStarButton setSelected:TRUE];
    }
    int selectedIntent = (int)self.primaryStarButton.tag;
    intentSelectedBlock(selectedIntent);
}

- (IBAction)manSelectionButtonPressed:(id)sender {
    if (self.manSelectionButton.selected) {
        [self.manSelectionButton setSelected:FALSE];
    }
    else{
        [self.manSelectionButton setSelected:TRUE];
    }
    
    genderButtonStateChangeBlock(GENDER_PREFERENCE_MALE,self.manSelectionButton.selected,myIntentType);
}

- (IBAction)womanSelectionButtonPressed:(id)sender {
    if (self.womanSelectionButton.selected) {
        [self.womanSelectionButton setSelected:FALSE];
    }
    else{
        [self.womanSelectionButton setSelected:TRUE];
    }
    genderButtonStateChangeBlock(GENDER_PREFERENCE_FEMALE,self.womanSelectionButton.selected,myIntentType);
}

@end
