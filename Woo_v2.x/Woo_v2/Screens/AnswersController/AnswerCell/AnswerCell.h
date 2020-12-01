//
//  AnswerCell.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 06/07/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyAnswers.h"

@interface AnswerCell : UITableViewCell{
    
    __weak IBOutlet UILabel *userNameAgeLabel;
    __weak IBOutlet UILabel *questionPreviewLabel;
    __weak IBOutlet UILabel *timestampLabel;
    __weak IBOutlet UIImageView *userImageLabel;
    __weak IBOutlet UIView *coralView;
    
    MyAnswers *cellData;
}

@property(nonatomic, weak)id delegate;
@property(nonatomic, assign)SEL selectorForImageTapped;

-(void)setDataOnCellFromAnswerObject:(MyAnswers *)answrObj;

- (IBAction)profilePhotoTapped:(id)sender;
@end
