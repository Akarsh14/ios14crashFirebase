//
//  UIImage+UIImageHandler.h
//  Headlines
//
//  Created by Lokesh Sehgal on 13/01/13.
//  Copyright (c) 2013 U2opia Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UIImageHandler)
- (UIImage *) scaleToSize: (CGSize)size;
- (UIImage *) scaleProportionalToSize: (CGSize)size;
@end
