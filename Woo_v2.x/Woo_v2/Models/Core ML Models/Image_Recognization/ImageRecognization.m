//
//  ImageRecognization.m
//  Woo_v2
//
//  Created by Kuramsetty Harish on 06/03/19.
//  Copyright © 2019 Woo. All rights reserved.
//

#import "ImageRecognization.h"

@implementation ImageRecognization


-(id)initWithName:(UIImageView *)imageView
{
    self = [super init];
    if (self) {
        self.parentImageView = imageView;
    }
    return self;
}

- (BOOL)detectFace:(CIImage*)image{
    if (@available(iOS 11.0, *)) {
        NSMutableArray *widthObtained = [[NSMutableArray alloc]init];
        VNDetectFaceLandmarksRequest *faceLandmarks = [VNDetectFaceLandmarksRequest new];
        VNSequenceRequestHandler *faceLandmarksDetectionRequest = [VNSequenceRequestHandler new];
         [faceLandmarksDetectionRequest performRequests:@[faceLandmarks] onCIImage:image error:nil];
        for(VNFaceObservation *observation in faceLandmarks.results){
            CGRect boundingBox = observation.boundingBox;
            CGSize size = CGSizeMake(boundingBox.size.width * self.parentImageView.bounds.size.width, boundingBox.size.height * self.parentImageView.bounds.size.height);
            [widthObtained addObject:[NSNumber numberWithFloat:size.width]];
        }
        return [self getBestImagesWidth:widthObtained];
    }
    else{
        return false;
    }
}


- (BOOL)getBestImagesWidth:(NSMutableArray *)images {
    NSNumber *maxWidth = [images valueForKeyPath:@"@max.self"];
    CGFloat percentage = (([maxWidth doubleValue])/ (self.parentImageView.bounds.size.width)) * 100;
    CGFloat minimumPercentage = 10;
    if ([[AppLaunchModel sharedInstance]mainFacePercentageThreshold] != 0){
         minimumPercentage = [[AppLaunchModel sharedInstance]mainFacePercentageThreshold];
        if([[LoginModel sharedInstance]mainFacePercentageThreshold] != 0){
            minimumPercentage = [[LoginModel sharedInstance]mainFacePercentageThreshold];
        }
    }
    if (percentage > minimumPercentage ){
         [APP_DELEGATE sendFirebaseEvent:@"FACE_FOUND_WITH_APPROPRIATE_SIZE" andScreen:@""];
        return true;
    }else{
         [APP_DELEGATE sendFirebaseEvent:@"FACE_TOO_SMALL" andScreen:@""];
        return false;
    }
}

@end
