//
//  MyPurchaseViewController.h
//  Woo_v2
//
//  Created by Deepak Gupta on 7/12/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyPurchaseCell.h"
#import "MyPurchaseHeader.h"
#import "BoostModel.h"
#import "CrushModel.h"
#import "WooPlusModel.h"
#import "MyPurchaseTemplate.h"

@interface MyPurchaseViewController : UIViewController{
    
    MyPurchaseHeader        *viewHeader;
    
    __weak IBOutlet UITableView     *tblViewObj;
    
    NSMutableArray              *arrData;
    NSMutableArray              *arrDataHeader;
}

@end
