//
//  MessageConversationView.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 13/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageConversationView : UIView{
    
}

@property(nonatomic, weak)id delegate;
@property(nonatomic, assign)SEL selectorForCreateMAtchTapped;
@property(nonatomic, assign)BOOL isOpenedFromDiscover;

- (IBAction)cancelButtonTapped:(id)sender;
- (IBAction)likeButtonTapped:(id)sender;

@end
