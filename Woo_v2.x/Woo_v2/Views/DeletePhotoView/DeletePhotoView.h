//
//  DeletePhotoView.h
//  Woo_v2
//
//  Created by Suparno Bose on 1/14/16.
//  Copyright © 2016 Woo. All rights reserved.
//

typedef void (^DeletePhotoBlock)();


#import <UIKit/UIKit.h>

@interface DeletePhotoView : UIView{
    
    __weak IBOutlet UIView           *viewMiddle;
    __weak IBOutlet UIImageView      *imgUserPopular;
}

- (IBAction)btnClicked:(UIButton *)sender;

- (void)setDeleteDataOnViewWithImage:(UIImage *)image withBlock:(DeletePhotoBlock)block;

@end
