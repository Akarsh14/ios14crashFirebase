//
//  TagCollectionViewCell.m
//  Woo_v2
//
//  Created by Umesh Mishraji on 09/06/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "TagCollectionViewCell.h"

@interface TagCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIView *backgroundViewObj;
@property (weak, nonatomic) IBOutlet UILabel *actionButtonLbl;

@end

@implementation TagCollectionViewCell

-(void)drawRect:(CGRect)rect {
    
    // inset by half line width to avoid cropping where line touches frame edges
   // CGRect insetRect = CGRectInset(rect, 0.5, 0.5);
    
    
    
}

-(void)setLabelText:(NSString *)labelText {
    tagText = labelText;
    
    
    if ([[_itemData objectForKey:kTagsIdKey] intValue] == 9991999) {
        //
        
        _backgroundViewObj.backgroundColor = [UIColor clearColor];
        self.stringLabel.textColor = kSelectedBackgroundColor;
        if (_isShowLessButton) {
            //▴
            _actionButtonLbl.text = @"▴";
        }
        else{
            _actionButtonLbl.text = @"▾";
        }
        
        _actionButtonLbl.textColor = kSelectedBackgroundColor;
        self.stringLabel.text = [NSString stringWithFormat:@"%@",tagText];
        self.layer.shadowColor = [UIColor clearColor].CGColor;
    }
    else{
        shadowPath = [UIBezierPath bezierPathWithRect:self.bounds];
        self.layer.masksToBounds = NO;
        self.layer.shadowColor = [UIColor grayColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        self.layer.shadowOpacity = 1.0;
        self.layer.shadowRadius = 2.0;
        
        _actionButtonLbl.text = kCrossStr;
        _actionButtonLbl.textColor = [UIColor whiteColor];
       // NSString *tagTextWithoutSpace = [tagText stringByReplacingOccurrencesOfString:@" " withString:@""];
        self.stringLabel.text = [NSString stringWithFormat:@"#%@",tagText];
        
        _backgroundViewObj.backgroundColor = kSelectedBackgroundColor;
        self.stringLabel.textColor = [UIColor whiteColor];
    }
    
    
    
    
//    [self.stringLabel sizeToFit];
    imageViewObj.hidden = TRUE;
    labelLeftMarginLayoutContraint.constant = 13;
}
-(void)animateMyView:(void(^)(BOOL success))animationSuccessBlock{

    if (self.animateView) {
        self.backgroundViewObj.transform = CGAffineTransformMakeScale(0.001, 0.001);
        [UIView animateWithDuration:kBubbleScaleDownTime delay:kBubbleScaleUpTime options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.layer.shadowOpacity = 0.5f;
            self.backgroundViewObj.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:^(BOOL finished) {
            animationSuccessBlock(TRUE);
            
        }];
    }
    else{
        self.backgroundViewObj.transform = CGAffineTransformMakeScale(1.0, 1.0);
        self.layer.shadowOpacity = 0.5f;
    }
}

-(void)destroyMe:(void(^)(BOOL success, NSDictionary *destroyedObj))destroySuccessBlock{
    destroyBlock = destroySuccessBlock;
}
-(IBAction)destroyButtonTapped:(id)sender{
    if (_needToBeUsedForRelationship){
        destroyBlock(TRUE,_itemData);
    }
    else{
    if (([[_itemData valueForKey:kTagsIdKey] intValue] == 9991999) || (!_destroyCellOnSelection)) {
        destroyBlock(TRUE,_itemData);
    }
    else{
        [UIView animateWithDuration:kBubbleScaleUpTime animations:^{
            self.backgroundViewObj.transform = CGAffineTransformMakeScale(0.01, 0.01);
        } completion:^(BOOL finished) {
            destroyBlock(TRUE,_itemData);
        }];
    }
    }
}

-(void)changeViewBasedOnProperties{
    if (_showAddButton) {
        if (_showAsSelected) {
            _actionButtonLbl.text = kCrossStr;
        }
        else{
            _actionButtonLbl.text = kAddStr;
        }
    }
    if (_showBorder && !_showAsSelected) {
        _backgroundViewObj.layer.borderColor = kBorderColor.CGColor;
        _backgroundViewObj.layer.borderWidth = 1.0;
    }
    if (_showAsSelected) {
        _backgroundViewObj.backgroundColor = kSelectedBackgroundColor;
        _stringLabel.textColor = [UIColor whiteColor];
        _actionButtonLbl.textColor = [UIColor whiteColor];
        
    }
    else{
        _backgroundViewObj.backgroundColor = [UIColor whiteColor];
        _stringLabel.textColor = kSelectedBackgroundColor;
        _actionButtonLbl.textColor = kSelectedBackgroundColor;
    }
}

@end
