//
//  PurchaseSelectionCell.m
//  Woo_v2
//
//  Created by Deepak Gupta on 12/29/15.
//  Copyright © 2015 Vaibhav Gautam. All rights reserved.
//

#import "PurchaseSelectionCell.h"

@implementation PurchaseSelectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


#pragma mark - Update Cell From Dictionary
-(void)updateDataOnCellFromDictionay:(NSDictionary *)dataDict{
    lbl_purchaseNumber.text = [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"count"]];
    lbl_purchaseType.text = [dataDict objectForKey:@"productName"];

    [self settingPurchasePriceWithAttributedString:[dataDict objectForKey:@"priceUnit"] withPricePerUnit:[dataDict objectForKey:@"pricePerUnit"] withProductName:[dataDict objectForKey:@"productNamePerUnit"]];
    
    lbl_purchasePeriod.text = [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"validityUnit"]];
    if ([[dataDict objectForKey:@"discount"] length]>0) {
        lbl_save.text = [NSString stringWithFormat:@"(%@)",[dataDict objectForKey:@"discount"]];
    }
    else{
        lbl_save.text = nil;
    }
}

- (void) settingPurchasePriceWithAttributedString : (NSString *)priceUnit withPricePerUnit:(NSString *)perUnitPrice withProductName : (NSString *)productName{
    
    UIFont *arialFont = [UIFont fontWithName:kProximaNovaFontRegular size:12.0];
    NSDictionary *arialDict = [NSDictionary dictionaryWithObject: arialFont forKey:NSFontAttributeName];
    NSMutableAttributedString *aAttrString = [[NSMutableAttributedString alloc] initWithString:priceUnit attributes: arialDict];
    
    UIFont *VerdanaFont = [UIFont fontWithName:kProximaNovaFontRegular size:17.0];
    NSDictionary *verdanaDict = [NSDictionary dictionaryWithObject:VerdanaFont forKey:NSFontAttributeName];
    NSMutableAttributedString *vAttrString = [[NSMutableAttributedString alloc]initWithString: perUnitPrice attributes:verdanaDict];
    
    [aAttrString appendAttributedString:vAttrString];
    
    UIFont *font = [UIFont fontWithName:kProximaNovaFontRegular size:11.0];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"/%@",productName]  attributes:dict];
    
    [aAttrString appendAttributedString:string];
    
    lbl_purchasePrice.attributedText = aAttrString;
}

@end
