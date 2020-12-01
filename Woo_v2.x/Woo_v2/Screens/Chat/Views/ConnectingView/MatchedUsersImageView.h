//
//  MatchedUsersImageView.h
//  Woo_v2
//
//  Created by Umesh Mishraji on 15/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MatchedUsersImageView : UIView{
    IBOutlet UIImageView *leftUserImage;
    IBOutlet UIImageView *rightUserImage;
    IBOutlet UIView *rightUserContainerView;
    
}
-(void)setLeftUserImage:(NSString *)leftUserImageUrlString getFromUrl:(BOOL)getLeftImageFromUrl andRightUserImage:(NSString *)rightUserImageUrlString getFromURl:(BOOL)getRightImageFromUrl;

@end
