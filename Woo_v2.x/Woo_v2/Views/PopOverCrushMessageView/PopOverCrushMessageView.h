//
//  PopOverCrushMessageView.h
//  Woo_v2
//
//  Created by Deepak Gupta on 1/14/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PopOverCrushMessageProtocol <NSObject>

- (void) crossButtonClickedFromPopOverCrushMessage;

@end
@interface PopOverCrushMessageView : UIView{
    
    __weak  IBOutlet   UIView        *viewPopOverMessageMiddleView;
    __weak  IBOutlet   UILabel       *lblPopOverMessageTitle;
    __weak  IBOutlet   UITextView    *txtViewPopOverMessageDesc;

}

@property (nonatomic , weak) id <PopOverCrushMessageProtocol> delegate;

- (IBAction)crossButtonClicked:(id)sender;

- (void)settingPopOverCrushMessageViewWithTitle:(NSString *)title withDescription:(NSString *)desc;
@end
