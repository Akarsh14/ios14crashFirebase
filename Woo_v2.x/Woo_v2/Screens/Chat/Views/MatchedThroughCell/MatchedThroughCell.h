//
//  MatchedThroughCell.h
//  Woo_v2
//
//  Created by Umesh Mishraji on 15/01/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kSourceBoost @"BOOST"
#define kSourceCrush @"CRUSH"

@interface MatchedThroughCell : UITableViewCell{
    
    
    __weak IBOutlet UILabel *matchThroughLb;
    __weak IBOutlet UIImageView *matchedThroughImage;
}

-(void)setCellTextAccrodingToMatchType:(NSString *)matchSource;

@end
