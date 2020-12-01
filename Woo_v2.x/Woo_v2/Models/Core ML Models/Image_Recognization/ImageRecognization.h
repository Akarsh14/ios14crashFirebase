//
//  ImageRecognization.h
//  Woo_v2
//
//  Created by Kuramsetty Harish on 06/03/19.
//  Copyright © 2019 Woo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageRecognization : NSObject
-(id)initWithName:(UIImageView *)imageView;
@property(nonatomic, strong) UIImageView *parentImageView;

- (BOOL)detectFace:(CIImage*)image;
@end

NS_ASSUME_NONNULL_END
