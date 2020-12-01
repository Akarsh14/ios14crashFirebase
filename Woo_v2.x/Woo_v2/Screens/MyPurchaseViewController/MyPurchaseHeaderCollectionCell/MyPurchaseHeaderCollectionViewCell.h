//
//  MyPurchaseHeaderCollectionViewCell.h
//  Woo_v2
//
//  Created by Deepak Gupta on 7/12/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ButtonTappedCallbackForMyPurchaseHeaderCell)(NSString *purchaseType , BOOL isExpired);
@interface MyPurchaseHeaderCollectionViewCell : UICollectionViewCell{
    
     __weak IBOutlet UIView *viewPurchaseBase;
     __weak IBOutlet UIImageView *viewPurchaseImg;
    __weak IBOutlet UIImageView *viewPurchaseEmptyDottedImg;
    
    __weak IBOutlet UILabel     *lblPurchaseCount;
    
    __weak IBOutlet UIButton *btnPurchase;


    __weak IBOutlet NSLayoutConstraint *constraintWidthLblCount;
    ButtonTappedCallbackForMyPurchaseHeaderCell _buttonTappedCallback;
    BOOL            isExpired;
    
}

-(void)setDataOnCellForHeaderView : (NSDictionary *)dict withButtonTappedCallBack:(ButtonTappedCallbackForMyPurchaseHeaderCell)callback;


- (IBAction)btnPurchaseClicked:(UIButton *)sender;

@end
