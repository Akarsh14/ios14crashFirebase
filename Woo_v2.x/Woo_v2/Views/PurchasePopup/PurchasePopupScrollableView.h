//
//  PurchasePopupScrollableView.h
//  Woo_v2
//
//  Created by Akhil Singh on 12/10/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PurchasePopupScrollableView : UIView

- (instancetype)initWithFrame:(CGRect)frame;

- (void)setupDataWithModel:(id)modelObject ForType:(int)type withIndex:(int)index;

- (void)createAddPageControlNowWithFrame:(CGFloat)pageYAxis WithIndex:(NSInteger)pageIndex;

-(void)changePageControlTint:(UIColor*)color;

-(void)resetPageNumberForPageControl;
@end
