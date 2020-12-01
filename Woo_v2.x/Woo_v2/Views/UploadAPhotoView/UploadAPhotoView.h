//
//  UploadAPhotoView.h
//  Woo_v2
//
//  Created by Suparno Bose on 15/03/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^UploadAPhotoViewGetBlock)(NSInteger index);

@interface UploadAPhotoView : UIView
{
    __weak IBOutlet UIImageView *userImage;
    __weak IBOutlet UIButton *addPhotosButton;
    __weak IBOutlet UIView *containerView;
    __weak IBOutlet UIButton *skipbutton;
}

+(UploadAPhotoView* _Nonnull) createFromNIBWithOwner:(id _Nonnull)owner;

- (void)performTaskBasedOnActionPerformed:(UploadAPhotoViewGetBlock _Nonnull)block;

@end
