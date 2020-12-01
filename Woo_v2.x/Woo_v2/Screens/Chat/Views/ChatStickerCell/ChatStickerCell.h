//
//  ChatStickerCell.h
//  Woo
//
//  Created by Umesh Mishra on 09/05/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatStickerCell : UITableViewCell{
    IBOutlet UIImageView *imageViewObj;
}

-(void)showImage:(NSString *)imageURL;
-(void)alignImageViewToLeft:(BOOL)alignLeft;

@end
