//
//  AnswerScreenQuestionCell.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 06/07/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnswerScreenQuestionCell : UITableViewCell{
    
    __weak IBOutlet UILabel *questionLAbel;
    __weak IBOutlet UILabel *timeStampLabel;
    
}

-(void)setQuestionOnCellWithQuestionText:(NSString *)questionText;
-(void)setTimestampOnCellWithTimestamp:(NSDate *)createdTime;
@end
