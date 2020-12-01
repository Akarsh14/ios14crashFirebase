//
//  ReportUserCell.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 09/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportUserCell : UITableViewCell{
    
    __weak IBOutlet UIImageView *selectionImage;
    __weak IBOutlet UILabel *reportReasonText;
}

-(void)setTextOnCellWithText:(NSString *)textForCell setImageAsSelected:(BOOL )isSelected;

@end
