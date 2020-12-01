//
//  QuestionCell.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 05/07/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "QuestionCell.h"

@implementation QuestionCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setDataOnQuestionCellWithQuestion:(NSString *)question withTotalAnswersCount:(int)answersCount andIsThereAnyUnreadAnswer:(BOOL)isUnread andLastUpdatedTime:(NSDate *)updatedTime{
    
    NSDictionary *atrribs = @{ NSForegroundColorAttributeName : kHeaderTextRedColor };
    
    NSMutableAttributedString *quesString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"Q. %@",question]];
        
    [quesString addAttributes:atrribs range:NSMakeRange(0, 2)];
    [questionLabel setAttributedText:quesString];
    
    if (isUnread) {
        [unreadAnswerDot setHidden:NO];
    }else{
        [unreadAnswerDot setHidden:YES];
    }
    
    NSTimeInterval timeInterval = [updatedTime timeIntervalSince1970];
    [newCountLabel setText:[APP_Utilities returnDateStringOfTimestamp:[NSDate dateWithTimeIntervalSince1970:(timeInterval)]]];
    /*
    if (answersCount > 0) {
        [newCountLabel setHidden:NO];
        //[newCountLabel setText:[NSString stringWithFormat:NSLocalizedString(@"%d ans", nil),answersCount]];
       // [newCountLabel setText:[APP_Utilities returnDateStringOfTimestamp:[NSDate dateWithTimeIntervalSince1970:(timeInterval)]]];

    }else{
        [newCountLabel setHidden:YES];
    }
     */
}
-(void)animateBackgroundColorOfTheCell{
    self.contentView.backgroundColor = [UIColor colorWithRed:225.0/255.0 green:225.0/255.0 blue:225.0/255.0 alpha:1.0];
    [UIView animateWithDuration:2.0 animations:^{
        self.contentView.backgroundColor = [UIColor whiteColor];
    } completion:^(BOOL finished) {
        self.contentView.backgroundColor = [UIColor whiteColor];
    }];
}

@end
