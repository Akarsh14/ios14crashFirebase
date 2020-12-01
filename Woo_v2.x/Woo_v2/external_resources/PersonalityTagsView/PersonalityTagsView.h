//
//  PersonalityTagsView.h
//  PersonalityTagsView
//
//  Created by Vaibhav Gautam on 28/02/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTagsCornerRadius 15.0f
#define kHorizontalDistanceBetweenTwoTags 30.0f
#define kWidthOfTagView (SCREEN_WIDTH-45)

#define kLeftPadding 5.0f
#define kRightPadding 5.0f
#define kTopPading 9.0f
#define kBottomPadding 5.0f

#define kTagTextLeftRightPadding 10.0f
#define kTagTextTopBottomPadding 10.0f
#define kMaximumSelectableTags 3 // set -1 for no limit no maximum selectable tags

#define kStartXPosition 0.0f

#define kPersonalityUnselectedBackground kExtraLightGreyColor
#define kPersonalityUnselectedTextColor [UIColor colorWithRed:0.36 green:0.36 blue:0.36 alpha:1]
/** PersonalityTagsView is a class which can generate tappable tags and they can toggle their states. output is fully customisable and supports theming option too.
 
 
 This control is fully reusable and customisable according to needs. Just modify the Theme.h for changing colors and fonts. Use Configuration.h for changing width, internal or external padding and corner edges.
 
#How to use this control:#
* Import PersonalityTagsView.h in your project.
* Instanciate PersonalityTagsView class using initWithDataArray: method and pass an array of "NSMutableDictionary" to it
* This method will return an object of UIView type and all the data at current state will reside in property namely "tagsDataArray"
* You can use the testDataArray to check the currently selected and unselected tags.
 
*/

@interface PersonalityTagsView : UIView{
    
    float currentXPosition;
    float currentYPosition;
    float heightOfView;
}
/** This property contains data of all the tags which are displayed on the view weather they are visible or not. */
@property(nonatomic, retain)NSMutableArray *tagsDataArray;

/** Use this method if you wish to show an alert with text description and text based button
 @param headerText The text which will be displayed on header. If you specify an empty string or nil then header will not be displayed.
 @param descriptionText The text which will be displayed after header. If you specify an empty string or nil then no description will be displayed.
 @param leftButtonText This is the text for first button if you wish to display 2 buttons or text for button if your alert contains only one button. If you leaves both the buttons as blank then no button will be displayed.
 @param rightButtonText This is the text for first button if you wish to display 2 buttons or text for button if your alert contains only one button. If you specify text for both the buttons then 2 buttons will be displayed.
 @return This method doesn's returns anything, you can get the output only using selector "selectorOnAlertButtonTapped"
 */
-(PersonalityTagsView *)initWithDataArray:(NSMutableArray *)tagsArray;

@property(nonatomic, weak)id delegate;
@property(nonatomic, assign)SEL selectorForTagTapped;

-(void)setTagDataArrayAndReloadView:(NSMutableArray *)tagsArray;


@end
