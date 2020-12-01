//
//  MyPurchaseHeader.h
//  Woo_v2
//
//  Created by Deepak Gupta on 7/12/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyPurchaseHeaderCollectionViewCell.h"

typedef void(^ButtonTappedCallbackForMyPurchaseHeader)(NSString *purchaseType , BOOL isExpired);

@interface MyPurchaseHeader : UIView<UICollectionViewDataSource , UICollectionViewDelegate>{
    
    __weak IBOutlet  UICollectionView        *collectionViewPurchaseHeader;
    
    NSArray         *arrDataValue;
    
    ButtonTappedCallbackForMyPurchaseHeader _buttonTappedCallback;

}


-(void)setDataOnMyPurchaseHeader : (NSArray *)arrData withButtonTappedCallBack:(ButtonTappedCallbackForMyPurchaseHeader)callBack;

@end
