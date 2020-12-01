//
//  CustomCodeTextField.h
//  Woo_v2
//
//  Created by Akhil Singh on 08/06/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomCodeTextField <NSObject>
@optional
- (void)textFieldDidDelete;
@end

@interface CustomCodeTextField : UITextField<UIKeyInput>

@property (nonatomic, assign) id<CustomCodeTextField> myDelegate;

@end
