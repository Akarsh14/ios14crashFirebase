//
//  QuestionCell.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 05/07/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestionCell : UITableViewCell{
    __weak IBOutlet UILabel *questionLabel;
    __weak IBOutlet UIView *unreadAnswerDot;
    __weak IBOutlet UILabel *newCountLabel;
    
}

-(void)setDataOnQuestionCellWithQuestion:(NSString *)question withTotalAnswersCount:(int)answersCount andIsThereAnyUnreadAnswer:(BOOL)isUnread andLastUpdatedTime:(NSDate *)updatedTime;
-(void)animateBackgroundColorOfTheCell;
@end
