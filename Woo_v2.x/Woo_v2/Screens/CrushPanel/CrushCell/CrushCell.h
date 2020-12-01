//
//  CrushCell.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 18/01/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CrushesDashboard.h"

@protocol CrushCellButtonTappedDelegate <NSObject>

- (void)likeButtonTappedWithCrushValue:(CrushesDashboard *)crushValue;
- (void)dislikeButtonTappedWithCrushValue:(CrushesDashboard *)crushValue;
@end

typedef void(^ButtonTappedCallback)(BOOL isLiked, CrushesDashboard *crushData);

@interface CrushCell : UITableViewCell{
    
    __weak IBOutlet UILabel *cellNameAgeLabel;
    
    
    __weak IBOutlet UILabel *crushName;
    __weak IBOutlet UILabel *crushAge;
    __weak IBOutlet UIImageView *userImage;
    __weak IBOutlet UILabel *crushMessageLabel;
            CrushesDashboard *dashboard;
    
    ButtonTappedCallback _buttonTappedCallback;
    
    __weak IBOutlet UIView *crushTextBackground;
    __weak IBOutlet UIView *redDotView;
}

@property (nonatomic,weak) id <CrushCellButtonTappedDelegate> crushCellButtonTappedDelegate;

-(void)setDataOnCellFromObj:(CrushesDashboard *)dashboardObj;

- (IBAction)likeButtonTapped:(id)sender;
- (IBAction)dislikeButtonTapped:(id)sender;

@end
