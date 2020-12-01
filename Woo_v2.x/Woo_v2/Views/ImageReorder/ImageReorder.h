//
//  ImageReorder.h
//  ImageDragControl
//
//  Created by Vaibhav Gautam on 06/02/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoSelectionView.h"
#import "VPImageCropperViewController.h"
#import "UAProgressView.h"

typedef enum {
    IMAGE_ONE = 100,
    IMAGE_TWO = 200,
    IMAGE_THREE = 300,
    IMAGE_FOUR = 400
}currentSelectedImage;

/** This class can perform reordering operation on upto 4 images on UIImageView
 
 the XIB file can be modified according to the needs, developer doesnt have to modify the code in any way to support new modified UI
 
 This small classes has just 4 properties and one method for setting images on the view.
 
 callback is provided with the help of selector namely "selectorForImagesSorted"
 
 How to use this class
 * modify xib file according to your needs.
 * create object of this class.
 * set delegate and selectors for callback.
 * add this class using addSubview method.
 
 */
@interface ImageReorder : UIView<UIGestureRecognizerDelegate, VPImageCropperDelegate>{
    
    currentSelectedImage selectedImage;
    CGRect initialRectOfDraggableView;
    CGPoint touchOffset;
    NSMutableArray *imageMetaArray;
    
    BOOL draggingEnabled;
    
    NSMutableArray *framesArray;
    
    int totalVisibleCrossButtons;
    
    IBOutlet UIView *mainImageViewObl;
    
    PhotoSelectionView *photoSelectionObj;
    
    int locationToBeUsedForChaingingImage;
    
    VPImageCropperViewController *imgCropperVC;
    
    UAProgressView *progressViewObj;
    NSURL *lastImageDownlodedForCropping;
    
    UIImage *cachedCroppedImage;
    
    UIView *backgroundView;
    
    BOOL isCropButtonZoomed;
    
    IBOutlet UIImageView *testImage;
        
}

/** This is the delegate property which should be implemented to get proper callback when user sorts the images on the view */
@property(nonatomic)id delegate;

/** This is the selector property which will be called when the user will remove his finger from the view. */
@property(nonatomic, assign)SEL selectorForImagesSorted;


//Added by Umesh
@property(nonatomic, assign)SEL selectorToPresentCroppingView;

@property (nonatomic, assign) SEL selectorForAddButtonTapped;

/** This will consist names of the images in order in which they were used initially. */
@property(nonatomic, strong)NSMutableArray *dataArray;

/** This is the only method which we need to use for setting the images on the view.
 @param arrayOfImageModels this will contain only the names of the images in NSString format.
 @return This method doesn's returns anything, you can get the output only using "selectorForImagesSorted"
 */
-(void)setImageOnViewFromDataArray:(NSMutableArray *)arrayOfImageModels;


/** We need to call this method to initialize dragging of images
 */
-(void)AllowDragging;

/** Call this method to stop dragging on this view */
-(void)DisallowrDragging;

/** This method will be called whenever someone will click on cross button or on add button */
- (IBAction)removeImageButton:(id)sender;

/** Call this method to start editing/reordering */
- (IBAction)startTapped:(id)sender;

/** Call this method to stop editing/reordering */
- (IBAction)stopTapped:(id)sender;


-(void)changeDataArrayAccordingToLoctionValue;

@property(nonatomic, assign)BOOL isOpenedFromOnBoarding;

//Added by umesh
//-(void)bringSelectedViewToFrontAndSendOtherToBack;
-(void)removeAllNotificationObservers;

-(void)addCropButtonAndDisableIt:(BOOL)disableCropButton;


-(void)setTest:(UIImage *)setImage;

-(void)showSelectImageFromAlbum:(NSString *)albumId;

@end
