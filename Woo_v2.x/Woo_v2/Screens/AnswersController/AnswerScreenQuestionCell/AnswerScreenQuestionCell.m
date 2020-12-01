//
//  AnswerScreenQuestionCell.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 06/07/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "AnswerScreenQuestionCell.h"

@implementation AnswerScreenQuestionCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setQuestionOnCellWithQuestionText:(NSString *)questionText{
    NSDictionary *atrribs = [[NSDictionary alloc] initWithObjectsAndKeys:kHeaderTextRedColor,NSForegroundColorAttributeName,nil];
    //@{ NSForegroundColorAttributeName : kHeaderTextRedColor };
    
    NSMutableAttributedString *quesString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"Q. %@",questionText]];
    
    [quesString addAttributes:atrribs range:NSMakeRange(0, 2)];
    [questionLAbel setAttributedText:quesString];
    
}

-(void)setTimestampOnCellWithTimestamp:(NSDate *)createdTime{
    NSString *dateStr = [APP_Utilities getDateStringForDate:createdTime forDateFormate:@"dd MMM"];
    if ([APP_Utilities validString:dateStr]) {
        NSString *timeStampStr = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Created on", nil), dateStr];
        timeStampLabel.text = timeStampStr;
    }
}

@end
