//
//  TagsView.h
//  TagsView
//
//  Created by Vaibhav Gautam on 28/02/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIButton+TaggableButtons.h"


#define kTagsCornerRadius 5.0f
#define kHorizontalDistanceBetweenTwoTags 0.0f
#define kWidthOfTagView 242.0f

#define kLeftPadding 5.0f
#define kRightPadding 5.0f
#define kTopPading 4.0f
#define kBottomPadding 5.0f

#define kTagTextLeftRightPadding 7.0f
#define kTagTextTopBottomPadding 5.0f
#define kMaximumSelectableTags 10 // set -1 for no limit no maximum selectable tags

#define kStartXPosition 16.0f

/** TagsView is a class which can generate tappable tags and they can toggle their states. output is fully customisable and supports theming option too.
 
 
 This control is fully reusable and customisable according to needs. Just modify the Theme.h for changing colors and fonts. Use Configuration.h for changing width, internal or external padding and corner edges.
 
#How to use this control:#
* Import TagsView.h in your project.
* Instanciate TagsView class using initWithDataArray: method and pass an array of "NSMutableDictionary" to it
* This method will return an object of UIView type and all the data at current state will reside in property namely "tagsDataArray"
* You can use the testDataArray to check the currently selected and unselected tags.
 
*/

@interface TagsView : UIView{
    
    float currentXPosition;
    float currentYPosition;
    float heightOfView;
    float widthOfTagView;
        
    NSMutableArray *placedTagsTempArray;
    NSMutableArray *tagsOfARow;
    
}
/** This property contains data of all the tags which are displayed on the view weather they are visible or not. */
@property(nonatomic, retain)NSMutableArray *tagsDataArray;

/**
 *  this method will create and return a tappable tags view with selectable tags
 *
 *  @param tagsArray   array of dictionaries which will be converted to the tags
 *  @param widthOfView width of view to be created
 *
 *  @return tagsView which can directly be used
 */
-(TagsView *)initWithDataArray:(NSMutableArray *)tagsArray withWidthOfView:(float )widthOfView;


/**
 *  this method will create and return a tappable tags view with selectable tags
 *
 *  @param tagsArray   array of dictionaries which will be converted to the tags
 *  @param widthOfView width of view to be created
 *  @param id of selected tag
 *
 *  @return tagsView which can directly be used
 */
-(TagsView *)initWithDataArray:(NSMutableArray *)tagsArray withWidthOfView:(float )widthOfView andSelectedTag:(NSString *) selectedTag;
@property(nonatomic, weak)id delegate;
@property(nonatomic, assign)SEL selectorForTagTapped;

/**
 *  This method will make sure that all the which are already selected come at first place
 *
 *  @param selectedTagsID id of selected tag
 */
-(void)setSelectedTag:(NSString *)selectedTagsID;

-(void)selectFirstTagAutomatically;


@end