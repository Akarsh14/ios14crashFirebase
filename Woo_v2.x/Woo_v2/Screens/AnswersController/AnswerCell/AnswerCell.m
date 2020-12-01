//
//  AnswerCell.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 06/07/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "AnswerCell.h"

@implementation AnswerCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setDataOnCellFromAnswerObject:(MyAnswers *)answrObj{
    /*
     __weak IBOutlet UILabel *timestampLabel;
     */
    
    NSDate *createdTime = answrObj.createdTime;
    NSTimeInterval timeInterval = [createdTime timeIntervalSince1970];
    
    [timestampLabel setText:[APP_Utilities returnDateStringOfTimestamp:[NSDate dateWithTimeIntervalSince1970:(timeInterval)]]];
    if ([answrObj.isRead boolValue]) {
        [self setBackgroundColor:[UIColor whiteColor]];
        coralView.hidden = TRUE;
    }else{
        [self setBackgroundColor:kLightestGreyColor];
        coralView.hidden = FALSE;
    }
    cellData = answrObj;
    [userNameAgeLabel setText:[NSString stringWithFormat:@"%@, %d",answrObj.userName, [answrObj.userAge intValue]]];
    [questionPreviewLabel setText:answrObj.answerDescription];
    [userImageLabel sd_setImageWithURL:[NSURL URLWithString:answrObj.userImageURL] placeholderImage:[UIImage imageNamed:@"placeholder_male"]];

    
}

- (IBAction)profilePhotoTapped:(id)sender {
    if ([_delegate respondsToSelector:_selectorForImageTapped]) {
        [_delegate performSelector:_selectorForImageTapped withObject:cellData];
    }
}
@end
