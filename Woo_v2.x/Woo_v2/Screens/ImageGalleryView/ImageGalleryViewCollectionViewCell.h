//
//  ImageGalleryViewCollectionViewCell.h
//  Woo_v2
//
//  Created by Akhil Singh on 09/06/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Woo_v2-Swift.h"

//#import "EditProfileProgressbar-Swift.h"

@interface ImageGalleryViewCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@property (nonatomic, assign) BOOL isProfileImageAlreadyLoaded;

- (void) loadImageWithImageNamed:(NSString *)imageName ForGender:(BOOL)isMale;

- (void) removeShadowLayers;

@end
