//
//  UIImage+UIImageHandler.m
//  Headlines
//
//  Created by Lokesh Sehgal on 13/01/13.
//  Copyright (c) 2013 U2opia Mobile. All rights reserved.
//

#import "UIImage+UIImageHandler.h"

@implementation UIImage (UIImageHandler)

- (UIImage *) scaleToSize: (CGSize)size
{
    // Scalling selected image to targeted size
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextClearRect(context, CGRectMake(0, 0, size.width, size.height));
    
    if(self.imageOrientation == UIImageOrientationRight)
    {
        CGContextRotateCTM(context, -M_PI_2);
        CGContextTranslateCTM(context, -size.height, 0.0f);
        CGContextDrawImage(context, CGRectMake(0, 0, size.height, size.width), self.CGImage);
    }
    else
        CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), self.CGImage);
    
    CGImageRef scaledImage=CGBitmapContextCreateImage(context);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    UIImage *image = [UIImage imageWithCGImage: scaledImage];
    
    CGImageRelease(scaledImage);
    
    return image;
}

- (UIImage *) scaleProportionalToSize: (CGSize)size1
{
    if(self.size.width>self.size.height)
    {
        size1=CGSizeMake((self.size.width/self.size.height)*size1.height,size1.height);
    }
    else
    {
        size1=CGSizeMake(size1.width,(self.size.height/self.size.width)*size1.width);
    }
    
    return [self scaleToSize:size1];

}

@end
