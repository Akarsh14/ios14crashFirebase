//
//  MyPurchaseCell.m
//  Woo_v2
//
//  Created by Deepak Gupta on 7/12/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "MyPurchaseCell.h"

@implementation MyPurchaseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setDataOnCellFromObj:(NSDictionary *)dictData{
    
    /*
     {
     isActive = 1;
     isPurchased = 1;
     purchaseType = BOOST;
     }

     */
    
    [myPurchaseTitle setText:[dictData objectForKey:kMyPurchaseTitle]];
    [myPurchaseMessage setText:[dictData objectForKey:kMyPurchaseContent]];

    
    if ([[dictData objectForKey:kPurchaseType ] isEqualToString:kPurchaseTypeBoost]) { // BOOST
        [myPurchaseImg setImage:[UIImage imageNamed:@"ic_purchase_boost_medium"]];
        [backgroundCenterView setBackgroundColor:[UIColor colorWithRed:0.57 green:0.46 blue:0.86 alpha:1.0]];

        
    }else if ([[dictData objectForKey:kPurchaseType ] isEqualToString:kPurchaseTypeCrush]) { // CRUSH
        [myPurchaseImg setImage:[UIImage imageNamed:@"ic_purchase_crush_medium"]];
        [backgroundCenterView setBackgroundColor:[UIColor colorWithRed:0.98 green:0.28 blue:0.29 alpha:1.0]];

        
    } else if ([[dictData objectForKey:kPurchaseType ] isEqualToString:kPurchaseTypeWooPlus]) {
        [myPurchaseImg setImage:[UIImage imageNamed:@"ic_purchase_plus_medium"]];
        [backgroundCenterView setBackgroundColor:[UIColor colorWithRed:0.31 green:0.77 blue:0.38 alpha:1.0]];

    } else if ([[dictData objectForKey:kPurchaseType ] isEqualToString:kPurchaseTypeWooGlobe]) {
        [myPurchaseImg setImage:[UIImage imageNamed:@"ic_purchase_globe_white_medium"]];
        [backgroundCenterView setBackgroundColor:[UIColor colorWithRed:57.0/255.0 green:200.0/255.0 blue:195.0/255.0 alpha:1.0]];
        
    }
    
    
    
}

@end
