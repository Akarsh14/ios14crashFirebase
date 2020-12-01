//
//  UnderLineButton.h
//  UnderlineButton
//
//  Created by Deepak Gupta on 11/27/15.
//  Copyright © 2015 Deepak Gupta. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum UnderLineButtonType{
    work = 0,
    education
}underLineButtonType;

//isTagable = 1;
//name = "SDITM / NCCE";
//tagId = 158657837604144;
//tagsDtoType = "USER_EDUCATION";

@interface DY_UnderLineButton : UIButton

@property (nonatomic , strong) UIColor     *lineColor;

@property (nonatomic ,  assign) BOOL         isTagable;
@property (nonatomic , strong) NSString     *name;
@property (nonatomic , strong) NSString     *tagId;
@property (nonatomic , assign) BOOL         isCommon;
@property (nonatomic , strong) NSString     *tagsDtoType;
@property (nonatomic , strong) NSDictionary * tagDataDict;

@property (assign) int      tagValue;


@property (nonatomic , assign) underLineButtonType      underButtonValue;


- (void) setButtonLineColorBasedOnisTaggableIsCommonWithName : (NSString *)name withTagId : (NSNumber *)tagId withTagsDToType : (NSString *)tagsDtoType withIsTagable : (BOOL)isTagable withIsCommon : (BOOL) isCommon;


/**
 *  Changing the line color of the UIButton
 *
 *  @param frame Button Rect
 *  @param color Pass UIColor Object
 */
@end
