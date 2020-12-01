//
//  ReportUserEditableCell.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 09/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportUserEditableCell : UITableViewCell<UITextViewDelegate>{
    __weak IBOutlet UIImageView *selectionImage;
    __weak IBOutlet UILabel *reportReasonText;
    __weak IBOutlet UITextView *editableTextView;
    
}
-(void)setTextOnCellWithText:(NSString *)textForCell setImageAsSelected:(BOOL )isSelected andEditableText:(NSString *)enteredText;

@property(nonatomic, weak)id delegate;
@property(nonatomic, assign)SEL selectorForTextChanged;
@end
