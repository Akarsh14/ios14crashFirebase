//
//  VPImageCropperViewController.h
//  VPolor
//
//  Created by Vinson.D.Warm on 12/30/13.
//  Copyright (c) 2013 Huang Vinson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreML/CoreML.h>
#import <Vision/Vision.h>



@class VPImageCropperViewController;
@class LoginViewController;
@class AlbumPhoto;


typedef void (^GetBlock)(void);
typedef void (^ImageUploadBlockBlock)(WooAlbumModel*);

@protocol VPImageCropperDelegate <NSObject>

- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(NSDictionary *)editedImageData;
- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController;

@end

@interface VPImageCropperViewController : UIViewController{
    float initialeWidthOfTheImage;
    UIButton *confirmBtn;
    UIButton *cancelBtn;
    UILabel *warningLabel;
    NSString *photoObjetId;
    UIImagePickerController *imagePicker;
}


@property (nonatomic, assign) BOOL showPreviousOption;
@property (nonatomic, assign) BOOL isOpenedFromWizard;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, assign) id<VPImageCropperDelegate> delegate;
@property (nonatomic, assign) CGRect cropFrame;
@property (nonatomic, assign) BOOL isPresented;
@property BOOL isWooAlbumCallNotNeeded;
@property (nonatomic, copy) ImageUploadBlockBlock imageBlock;
@property BOOL isImageAdded;
@property (nonatomic, strong) NSMutableDictionary *additionalData;
@property (nonatomic, strong) AlbumPhoto *albumData;
@property (nonatomic, strong) WooAlbumModel *wooAlbum;


- (void)setDataOnCropperObj:(UIImage *)originalImage cropFrame:(CGRect)cropFrame limitScaleRatio:(NSInteger)limitRatio ;

- (id)initWithImage:(UIImage *)originalImage cropFrame:(CGRect)cropFrame limitScaleRatio:(NSInteger)limitRatio;
-(void)btnCameraClicked;
- (void)wooAlbumisUpdatedNow:(GetBlock)block;
@end
