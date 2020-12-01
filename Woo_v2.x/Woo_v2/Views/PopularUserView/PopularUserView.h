//
//  PopularUserView.h
//  Woo_v2
//
//  Created by Deepak Gupta on 1/14/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

typedef void (^GetPopularBlock)(NSInteger selectedIndex, BOOL typeOfView);


#import <UIKit/UIKit.h>

@interface PopularUserView : UIView{
    
    __weak IBOutlet UIView      *viewMiddle;
    __weak IBOutlet UIImageView      *imgUserPopular;
    __weak IBOutlet UILabel     *lblUserName;
    
}

- (IBAction)btnClicked:(UIButton *)sender;

- (void)setPopularDataOnViewWithImage:(NSString *)imageName withName:(NSString *)name andType:(BOOL)outOfCrushesTypeView withGender:(NSString *)gender withBlock:(GetPopularBlock)block;

@end
