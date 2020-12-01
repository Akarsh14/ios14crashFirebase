//
//  ShowMoreCell.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 07/07/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShowMoreCell : UITableViewCell{
    
    __weak IBOutlet UILabel *showMoreLabel;
}

-(void)setDataOnShowMoreCellWithPendingReplies:(int )repliesRemaining;
@end
