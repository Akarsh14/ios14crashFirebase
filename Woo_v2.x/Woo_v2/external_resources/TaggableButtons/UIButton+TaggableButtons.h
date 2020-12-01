//
//  UIButton+TaggableButtons.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 11/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (TaggableButtons){
    
}

@property(nonatomic, strong)NSString *tagTypeKey;
@property(nonatomic, strong)NSString *customTagValue;

-(void)makeMeSelected:(BOOL)doINeedToGetSelected;

@end
