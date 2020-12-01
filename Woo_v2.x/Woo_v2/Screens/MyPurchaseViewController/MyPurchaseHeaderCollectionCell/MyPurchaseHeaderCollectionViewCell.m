//
//  MyPurchaseHeaderCollectionViewCell.m
//  Woo_v2
//
//  Created by Deepak Gupta on 7/12/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "MyPurchaseHeaderCollectionViewCell.h"

@implementation MyPurchaseHeaderCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setDataOnCellForHeaderView : (NSDictionary *)dict withButtonTappedCallBack:(ButtonTappedCallbackForMyPurchaseHeaderCell)callback{
    
    /*
     isActive = 1;
     isPurchased = 1;
     purchaseCount = 5;
     purchaseType = BOOST;
     */
    
    
    _buttonTappedCallback = callback;
    
    [viewPurchaseBase.layer setBorderColor:[UIColor colorWithRed:0.28 green:0.57 blue:0.98 alpha:1.0].CGColor];
    [viewPurchaseBase setAlpha:1.0];
    
    if (![[dict objectForKey:kIsPurchased] boolValue]) {
        
        [lblPurchaseCount setText:@"+"];
        [viewPurchaseBase setAlpha:0.5];
        
        isExpired = YES;
        
        if ([[dict objectForKey:kPurchaseType] isEqualToString:kPurchaseTypeBoost]) {
            
            [viewPurchaseImg setImage:[UIImage imageNamed:@"ic_purchase_boost_small"]];
            btnPurchase.tag = 100;
            
        }else if ([[dict objectForKey:kPurchaseType] isEqualToString:kPurchaseTypeCrush]) {
            
            [viewPurchaseImg setImage:[UIImage imageNamed:@"ic_purchase_crush_small"]];
            btnPurchase.tag = 200;
            
        }else if ([[dict objectForKey:kPurchaseType] isEqualToString:kPurchaseTypeWooPlus]) {
            
            [viewPurchaseImg setImage:[UIImage imageNamed:@"ic_purchase_plus_small"]];
            btnPurchase.tag = 300;
        }
        else if ([[dict objectForKey:kPurchaseType] isEqualToString:kPurchaseTypeWooGlobe]) {
            
            [viewPurchaseImg setImage:[UIImage imageNamed:@"ic_purchase_wooglobe_small"]];
            btnPurchase.tag = 400;
        }
        
        [viewPurchaseEmptyDottedImg setHidden:NO];
        
        [viewPurchaseBase layer].borderWidth = 0.0;
        
        if ([[dict objectForKey:@"type"] isEqualToString:@"BOOST"]) {
            [viewPurchaseEmptyDottedImg setImage : [UIImage imageNamed:@"ic_my_purchase_purple_dotted_circle"]];
        }
        else if ([[dict objectForKey:@"type"] isEqualToString:@"CRUSH"]) {
            [viewPurchaseEmptyDottedImg setImage : [UIImage imageNamed:@"ic_my_purchase_red_dotted_circle"]];
        }
        else if ([[dict objectForKey:@"type"] isEqualToString:@"WOOPLUS"]) {
            [viewPurchaseEmptyDottedImg setImage : [UIImage imageNamed:@"ic_my_purchase_green_dotted_circle"]];
        }
        else if ([[dict objectForKey:@"type"] isEqualToString:@"WOOGLOBE"]) {
            [viewPurchaseEmptyDottedImg setImage : [UIImage imageNamed:@"ic_my_purchase_wooglobe_dotted_circle"]];
        }

    } else if (![[dict objectForKey:kIsActive] boolValue]){ // If expired
        
        [lblPurchaseCount setText:@"+"];
        [viewPurchaseBase setAlpha:0.5];

        isExpired = YES;
        
        if ([[dict objectForKey:kPurchaseType] isEqualToString:kPurchaseTypeBoost]) {
            
            [viewPurchaseImg setImage:[UIImage imageNamed:@"ic_purchase_boost_small"]];
            btnPurchase.tag = 100;
            
        }else if ([[dict objectForKey:kPurchaseType] isEqualToString:kPurchaseTypeCrush]) {
            
            [viewPurchaseImg setImage:[UIImage imageNamed:@"ic_purchase_crush_small"]];
        btnPurchase.tag = 200;
            
        }else if ([[dict objectForKey:kPurchaseType] isEqualToString:kPurchaseTypeWooPlus]) {
            
            [viewPurchaseImg setImage:[UIImage imageNamed:@"ic_purchase_plus_small"]];
            btnPurchase.tag = 300;
            
        }else if ([[dict objectForKey:kPurchaseType] isEqualToString:kPurchaseTypeWooGlobe]) {
            
            [viewPurchaseImg setImage:[UIImage imageNamed:@"ic_purchase_wooglobe_small"]];
            btnPurchase.tag = 400;
        }
        }else{                  // If active & not expired
        
        isExpired = NO;
        [viewPurchaseImg setHidden:YES];
            [viewPurchaseBase.layer setBorderColor:[UIColor clearColor].CGColor];
            [viewPurchaseBase setAlpha:1.0];
            viewPurchaseBase.backgroundColor = [UIColor clearColor];
            viewPurchaseEmptyDottedImg.hidden = FALSE;

            if ([[dict objectForKey:kPurchaseCount] intValue] > 99){
                [lblPurchaseCount setText:NSLocalizedString(@"99+",@"")];
            constraintWidthLblCount.constant = 35;
            }
            
            else{
                [lblPurchaseCount setText:[dict objectForKey:kPurchaseCount]];
            }
        if ([[dict objectForKey:kPurchaseType] isEqualToString:kPurchaseTypeBoost]) {
            
//            [viewPurchaseImg setImage:[UIImage imageNamed:@"ic_purchase_boost_small"]];
            [viewPurchaseEmptyDottedImg setImage:[UIImage imageNamed:@"ic_my_purchase_boost_circle"]];
            [lblPurchaseCount setHidden:NO];
            [viewPurchaseBase setHidden:NO];
           // [lblPurchaseCount setText:[dict objectForKey:kPurchaseCount]];
            btnPurchase.tag = 100;
        }else if ([[dict objectForKey:kPurchaseType] isEqualToString:kPurchaseTypeCrush]) {
            
//            [viewPurchaseImg setImage:[UIImage imageNamed:@"ic_purchase_crush_small"]];
            [viewPurchaseEmptyDottedImg setImage:[UIImage imageNamed:@"ic_my_purchase_crush_circle"]];
            //[lblPurchaseCount setText:[dict objectForKey:kPurchaseCount]];
            [lblPurchaseCount setHidden:NO];
            [viewPurchaseBase setHidden:NO];
            btnPurchase.tag = 200;
        }else if ([[dict objectForKey:kPurchaseType] isEqualToString:kPurchaseTypeWooPlus]) {
            
//            [viewPurchaseImg setImage:[UIImage imageNamed:@"ic_purchase_plus_small"]];
            [viewPurchaseEmptyDottedImg setImage:[UIImage imageNamed:@"ic_my_purchase_wooplus_circle"]];
            [lblPurchaseCount setHidden:YES];
            btnPurchase.tag = 300;
            
        }else if ([[dict objectForKey:kPurchaseType] isEqualToString:kPurchaseTypeWooGlobe]) {
            
//            [viewPurchaseImg setImage:[UIImage imageNamed:@"ic_purchase_wooglobe_small"]];
            [viewPurchaseEmptyDottedImg setImage:[UIImage imageNamed:@"ic_my_purchase_wooglobe_circle"]];
            [lblPurchaseCount setHidden:YES];
            btnPurchase.tag = 400;
        }
    }
    
    
    
    // added new condition if user active boost/crush has not been expired && their corresponding count = 0
    
        if ((([[dict objectForKey:kPurchaseType] isEqualToString:kPurchaseTypeBoost])|| ([[dict objectForKey:kPurchaseType] isEqualToString:kPurchaseTypeCrush])) && [[dict objectForKey:kIsActive] boolValue] && [[dict objectForKey:kPurchaseCount] intValue] == 0){
    
    
            [lblPurchaseCount setText:@"+"];
            [viewPurchaseBase setAlpha:0.5];
    
    
            isExpired = YES;
    
        }

    
    
    
}


- (IBAction)btnPurchaseClicked:(UIButton *)sender{
    
    if (sender.tag == 100)
        _buttonTappedCallback(kPurchaseTypeBoost , isExpired);
    else if (sender.tag == 200)
        _buttonTappedCallback(kPurchaseTypeCrush, isExpired);
    else if (sender.tag == 300)
        _buttonTappedCallback(kPurchaseTypeWooPlus, isExpired);
    else if (sender.tag == 400)
        _buttonTappedCallback(kPurchaseTypeWooGlobe, isExpired);
    
}


@end
