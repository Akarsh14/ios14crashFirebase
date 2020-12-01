//
//  U2AlertView.h
//  U2AlertView
//
//  Created by Vaibhav Gautam on 25/02/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "ThemeFile.h"

typedef void (^U2AlertActionBlock)(int , id);

// for a consistent UI experience on both iPhone and iPad do not change these values. // best is 280
#define kWidthOfAlertView 280
#define kCornerRadiusForRoundedViews 5.0
#define kCornerRadiusForRoundedViewsIniOS9 12.0
#define kHeightOfHeaderBackground 44
#define kCustomAlertSpacing 0.0f
#define kCustomLeftRightSpacing 6.0f
#define kHorizontalLineDistanceFromBorders 3.0f
#define kAlertAnimationTime 0.2f

#define kNotifityU2AlertKeyBoardAppeared @"notifityU2AlertKeyBoardAppeared"
#define kNotifityU2AlertKeyBoardDismissed @"notifityU2AlertKeyBoardDismissed"

//  end of config



/** U2AlertView can perform basic tasks of an UIAlertView but it has one small advantage that this alert can be customised as per design needs.
 
 
 #How U2AlertView is different from UIAlertView ?#
 * U2AlertView is fully customizable.
 * Theming option is available.
 * Image buttons can be used.
 * Supports UIView as a subview of alertview.
 
 #How to use this control:#
 * Import U2AlertView.h, U2AlertView.m, U2AlertView.xib, Theme.h and U2AlertConfiguration.h in your project.
 * Instanciate U2AlertView class and select appropriate type of alert as per your needs.
 * Set delegate and selectors for callback on button tap.
 * Use "Show" method to show the alert.
 * Customise the theme by editing values in "Theme.h"
 * Customise various other configuration options by editing values in "Configuration.h"
 
 */

@interface U2AlertView : UIView{
    
    __weak IBOutlet UIView *centreAlertView;
    float topYPositionForView;
    id alertOptionalData;
    
    U2AlertActionBlock _block;
    
    UIAlertController *alertViewController;
    
}
-(void)setContainerData:(id)dataDict;

//@property(nonatomic, retain) NSMutableDictionary *alertOptionalData;

/** This is the delegate property which should be implemented to get proper callback when taps on any button */
//@property(nonatomic, weak)id delegate;

/** This property will specify where the callback should be redirected when the user presses a button on alert. Object of type "NSNumber" containing either 0 or 1 will be returned to which can used to identify weather first or second button was pressed */
//@property(nonatomic, assign)SEL selectorOnAlertButtonTapped;

//Added by Umesh Mishra 29 May 2014 to keep the alert view button tap
@property(nonatomic, assign)BOOL keepViewOnButtonTap;

/**
 *  This property can be used to access the on centreview if a custom view is in use instead of description text
 */
@property(nonatomic, strong)UIView *descriptionView;


/** Use this method if you wish to show an alert with text description and text based button
 @param headerText The text which will be displayed on header. If you specify an empty string or nil then header will not be displayed.
 @param descriptionText The text which will be displayed after header. If you specify an empty string or nil then no description will be displayed.
 @param leftButtonText This is the text for first button if you wish to display 2 buttons or text for button if your alert contains only one button. If you leaves both the buttons as blank then no button will be displayed.
 @param rightButtonText This is the text for first button if you wish to display 2 buttons or text for button if your alert contains only one button. If you specify text for both the buttons then 2 buttons will be displayed.
 @return This method doesn's returns anything, you can get the output only using selector "selectorOnAlertButtonTapped"
 */
-(void)alertWithHeaderText:(NSString *)headerText description:(NSString *)descriptionText leftButtonText:(NSString *)leftButtonText andRightButtonText:(NSString *)rightButtonText;

/** Use this method if you wish to show an alert with text description and text based button
 @param headerText The text which will be displayed on header. If you specify an empty string or nil then header will not be displayed.
 @param descriptionText The text which will be displayed after header. If you specify an empty string or nil then no description will be displayed.
 @param leftButton This object should contain UIImage object for the first button. You may leave both the images blank for no buttons, and only one image if you wish to see only one button.
 @param rightButton This object should contain UIImage object for the second button. You may leave both the images blank for no buttons, and only one image if you wish to see only one button.
 @return This method doesn's returns anything, you can get the output only using selector "selectorOnAlertButtonTapped"
 */
-(void)alertWithHeaderText:(NSString *)headerText description:(NSString *)descriptionText leftButton:(UIImage *)leftButton andRightButton:(UIImage *)rightButton;


/** Use this method if you wish to show an alert with text description and text based button
 @param headerText The text which will be displayed on header. If you specify an empty string or nil then header will not be displayed.
 @param centreView If you wish to use a UIView in description area then pass it here. If the view is within the width of U2AlertView then it will be centre aligned otherwise it will fo out of boundaries. managing custom description view is solely the responsibility of the developer.
 @param leftButtonText This is the text for first button if you wish to display 2 buttons or text for button if your alert contains only one button. If you leaves both the buttons as blank then no button will be displayed.
 @param rightButtonText This is the text for first button if you wish to display 2 buttons or text for button if your alert contains only one button. If you specify text for both the buttons then 2 buttons will be displayed.
 @return This method doesn's returns anything, you can get the output only using selector "selectorOnAlertButtonTapped"
 */
-(void)alertWithHeaderText:(NSString *)headerText descriptionView:(UIView *)centreView withLeftButtonText:(NSString *)leftButtonText andRightButtonText:(NSString *)rightButtonText;

/** Use this method if you wish to show an alert with text description and text based button
 @param headerText The text which will be displayed on header. If you specify an empty string or nil then header will not be displayed.
 @param centreView If you wish to use a UIView in description area then pass it here. If the view is within the width of U2AlertView then it will be centre aligned otherwise it will fo out of boundaries. managing custom description view is solely the responsibility of the developer.
 @param leftButton This object should contain UIImage object for the first button. You may leave both the images blank for no buttons, and only one image if you wish to see only one button.
 @param rightButton This object should contain UIImage object for the second button. You may leave both the images blank for no buttons, and only one image if you wish to see only one button.
 @return This method doesn's returns anything, you can get the output only using selector "selectorOnAlertButtonTapped"
 */
-(void)alertWithHeaderText:(NSString *)headerText descriptionView:(UIView *)centreView leftButton:(UIImage *)leftButton andRightButton:(UIImage *)rightButton;

-(void)setPropertiesForElementsOfAlertView:(NSDictionary *)elementProperties;

-(void)show;

-(void)enableRightButton;
-(void)DisableRightButton;


-(void)setU2AlertActionBlockForButton:(U2AlertActionBlock)block;


@end
