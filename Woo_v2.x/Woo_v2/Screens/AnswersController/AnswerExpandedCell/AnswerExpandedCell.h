//
//  AnswerExpandedCell.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 06/07/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyAnswers.h"


@interface AnswerExpandedCell : UITableViewCell{
    
    __weak IBOutlet UIImageView *userImageView;
    __weak IBOutlet UILabel *userNameAgeLAbel;
    __weak IBOutlet UILabel *completeAnswerLabel;
    __weak IBOutlet UILabel *timestampLabel;
    
    MyAnswers *cellData;
    __weak IBOutlet UIButton *trashButton;
    __weak IBOutlet UIButton *likeButton;
}


-(void)setDataOnCellFromAnswerObject:(MyAnswers *)answrObj;

@property(nonatomic, weak)id delegate;
@property(nonatomic, assign)SEL selectorForReportTapped;
@property(nonatomic, assign)SEL selectorForLikeTapped;
@property(nonatomic, assign)SEL selectorForDeleteTapped;
@property(nonatomic, assign)SEL selectorForImageTapped;

- (IBAction)reportButtonTapped:(id)sender;
- (IBAction)likeButtonTapped:(id)sender;
- (IBAction)deleteButtonTapped:(id)sender;
- (IBAction)profilePhotoTapped:(id)sender;

@end
