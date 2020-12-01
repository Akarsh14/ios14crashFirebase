//
//  ReportUserEditableCell.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 09/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "ReportUserEditableCell.h"

@implementation ReportUserEditableCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:NO animated:animated];

    // Configure the view for the selected state
}

-(void)setTextOnCellWithText:(NSString *)textForCell setImageAsSelected:(BOOL )isSelected andEditableText:(NSString *)enteredText{
    if (isSelected) {
        [selectionImage setImage:[UIImage imageNamed:@"ic_radio_on"]];
    }else{
        [selectionImage setImage:[UIImage imageNamed:@"ic_radio_off"]];
    }
    
    [editableTextView setText:enteredText];
    [reportReasonText setText:textForCell];
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if ([_delegate respondsToSelector:_selectorForTextChanged]) {
        [_delegate performSelector:_selectorForTextChanged withObject:textView.text];
    }
    
}

- (void)textViewDidChange:(UITextView *)textView{
    
    if ([_delegate respondsToSelector:_selectorForTextChanged]) {
        [_delegate performSelector:_selectorForTextChanged withObject:textView.text];
    }
}

@end
