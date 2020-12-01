//
//  MyPurchaseCell.h
//  Woo_v2
//
//  Created by Deepak Gupta on 7/12/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyPurchaseCell : UITableViewCell{
    
    __weak IBOutlet UILabel *myPurchaseTitle;
    __weak IBOutlet UILabel *myPurchaseMessage;
    __weak IBOutlet UIImageView *myPurchaseImg;
    __weak IBOutlet UIView *backgroundCenterView;

}

-(void)setDataOnCellFromObj:(NSDictionary *)dictData;

@end
