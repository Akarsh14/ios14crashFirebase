//
//  LeftPanelImageView.h
//  Woo_v2
//
//  Created by Suparno Bose on 04/01/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftPanelImageView : UIView
{
    __weak IBOutlet UIImageView *blurImageView;
    __weak IBOutlet UIImageView *circularImageView;
    __weak IBOutlet UIImageView *boostImageView;
    __weak IBOutlet UILabel *nameAgeImageView;
    __weak IBOutlet UIButton *settingButton;
    __weak IBOutlet UIButton *editProfileButton;
}

/// property to set if the user profile is boosted or not
@property (nonatomic) BOOL isProfileBoosted;
/// property to set if the user profile is male or not
@property (nonatomic) BOOL isProfileMale;

/*!
 * @discussion Set the Profile Image by passing the url of the image
 * @param url URL of the image to be shown on the imageview
 */
-(void) setProfileImageWithUrl:(NSURL*) url;
/*!
 * @discussion Set the Username and the Age in the consecutive labels
 * @param name name string of the user
 * @param age age String of the user
 */
-(void) setUserName:(NSString*)name AndAge:(NSString*)age;
/*!
 * @discussion Sets the selector for Edit button pressed action
 * @param selector method to be called on edit button tapped
 * @param controller owner of the method to be called
 */
-(void) addSelectorForProfileEditButton:(SEL) selector WithController:(UIViewController*) controller;
/*!
 * @discussion Sets the selector for Edit button pressed action
 * @param selector method to be called on settings button tapped
 * @param controller owner of the method to be called
 */
-(void) addSelectorForSettingsButton:(SEL) selector WithController:(UIViewController*) controller;

@end
