//
//  PurchaseSelectionCell.h
//  Woo_v2
//
//  Created by Deepak Gupta on 12/29/15.
//  Copyright © 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PurchaseSelectionCell : UICollectionViewCell{
    
    __weak IBOutlet UILabel     *lbl_purchaseNumber;
    __weak IBOutlet UILabel     *lbl_purchaseType;
    __weak IBOutlet UILabel     *lbl_purchasePeriod;
    __weak IBOutlet UILabel     *lbl_purchasePrice;
    __weak IBOutlet UILabel     *lbl_save;
    
}


-(void)updateDataOnCellFromDictionay:(NSDictionary *)dataDict;

@end
