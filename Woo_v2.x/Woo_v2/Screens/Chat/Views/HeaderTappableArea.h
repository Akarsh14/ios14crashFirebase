//
//  HeaderTappableArea.h
//  Woo
//
//  Created by Vaibhav Gautam on 06/05/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>


#define WIDTH_OF_HEADER_VIEW 196

@interface HeaderTappableArea : UIView{
    
    __weak IBOutlet UIImageView *userImage;
    __weak IBOutlet UILabel *userName;
    
    void(^buttonTappedBlockObj)();
}

@property(nonatomic, weak)id delegate;
//@property(nonatomic, assign)SEL selectorForHeaderTapped;

- (IBAction)headerTapped:(id)sender;
-(void)headerTappedBlock:(void(^)())block;

- (void)setDataOnHeaderWithImage:(NSString *)imageName andUserFirstName:(NSString *)userFirstName withPlaceholderImageName:(NSString *)placeHolderImageName;


@end
