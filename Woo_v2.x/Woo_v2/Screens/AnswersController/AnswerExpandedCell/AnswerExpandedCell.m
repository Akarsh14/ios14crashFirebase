//
//  AnswerExpandedCell.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 06/07/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "AnswerExpandedCell.h"

@implementation AnswerExpandedCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setDataOnCellFromAnswerObject:(MyAnswers *)answrObj{
    
    cellData = answrObj;
    [userNameAgeLAbel setText:[NSString stringWithFormat:@"%@, %d",answrObj.userName, [answrObj.userAge intValue]]];
    [completeAnswerLabel setText:answrObj.answerDescription];
    [userImageView sd_setImageWithURL:[NSURL URLWithString:answrObj.userImageURL] placeholderImage:[UIImage imageNamed:@"placeholder_male"]];
    
    NSDate *createdTime = answrObj.createdTime;
    NSTimeInterval timeInterval = [createdTime timeIntervalSince1970];
    
    [timestampLabel setText:[APP_Utilities returnDateStringOfTimestamp:[NSDate dateWithTimeIntervalSince1970:(timeInterval)]]];
    
}

- (IBAction)reportButtonTapped:(id)sender {
    
    if ([_delegate respondsToSelector:_selectorForReportTapped]) {
        [_delegate performSelector:_selectorForReportTapped withObject:cellData];
    }
}

- (IBAction)likeButtonTapped:(id)sender {
    [APP_Utilities scaleUpAnimationOnView:self.imageView withNumberOfTimes:1];
    if ([_delegate respondsToSelector:_selectorForLikeTapped]) {
        [_delegate performSelector:_selectorForLikeTapped withObject:cellData];
    }
}

- (IBAction)deleteButtonTapped:(id)sender {
    [APP_Utilities scaleUpAnimationOnView:self.imageView withNumberOfTimes:1];
    if ([_delegate respondsToSelector:_selectorForDeleteTapped]) {
        [_delegate performSelector:_selectorForDeleteTapped withObject:cellData];
    }
}

- (IBAction)profilePhotoTapped:(id)sender {
    if ([_delegate respondsToSelector:_selectorForImageTapped]) {
        [_delegate performSelector:_selectorForImageTapped withObject:cellData];
    }
}
@end
