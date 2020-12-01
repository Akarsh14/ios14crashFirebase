//
//  TagCollectionViewCell.h
//  Woo_v2
//
//  Created by Umesh Mishraji on 09/06/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kSelectedBackgroundColor [UIColor colorWithRed:146.0/255.0 green:117.0/255.0 blue:219.0/255.0 alpha:1.0]
#define kCrossStr @"✕"
#define kAddStr   @"+"
#define kBorderColor    [UIColor colorWithRed:146.0/255.0 green:117.0/255.0 blue:219.0/255.0 alpha:1.0]
#define kFontColor      [UIColor colorWithRed:146.0/255.0 green:117.0/255.0 blue:219.0/255.0 alpha:1.0]

@interface TagCollectionViewCell : UICollectionViewCell{
    IBOutlet NSLayoutConstraint *labelLeftMarginLayoutContraint;
    IBOutlet NSLayoutConstraint *labelMaximumWidthLayoutConstraint;
    void (^destroyBlock)(BOOL success, NSDictionary *destroyedObj);
    NSString *tagText;
    IBOutlet UIImageView *imageViewObj;
    
    UIBezierPath *shadowPath;
    IBOutlet UIButton *crossButton;
}

@property (weak, nonatomic) IBOutlet UILabel *stringLabel;
@property (nonatomic, strong) NSString *labelText;
@property (nonatomic, strong) NSDictionary *itemData;
@property (nonatomic, assign) BOOL animateView;
@property (nonatomic, assign) BOOL showAddButton;
@property (nonatomic, assign) BOOL showBorder;
@property (nonatomic, assign) BOOL showAsSelected;
@property (nonatomic, assign) BOOL needToBeUsedForRelationship;
@property (nonatomic, assign) BOOL destroyCellOnSelection;

@property (nonatomic, assign) BOOL isShowLessButton;


-(IBAction)destroyButtonTapped:(id)sender;

-(void)changeViewBasedOnProperties;

-(void)animateMyView:(void(^)(BOOL success))animationSuccessBlock;
-(void)destroyMe:(void(^)(BOOL success, NSDictionary *destroyedObj))destroySuccessBlock;

@end
