//
//  ImageSelectionViewController.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 15/06/15.
//  Copyright (c) 2015 Woo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "AlbumSelectionView.h"
#import "PhotoSelectionView.h"
#import "UAProgressView.h"

typedef void (^ImageUpdatedCompletionBlock)(NSMutableArray *);

@interface ImageSelectionViewController : BaseViewController<UIActionSheetDelegate,UIImagePickerControllerDelegate>{
    
    __weak IBOutlet UIButton *mainPic;
    __weak IBOutlet UIButton *firstAdditionalPic;
    __weak IBOutlet UIButton *secondAdditionalPic;
    __weak IBOutlet UIButton *thirdAdditionalPic;
    __weak IBOutlet UIView *centreViewForDragDrop;
    __weak IBOutlet UINavigationBar *navbar;
    __weak IBOutlet UILabel *imageInfoLabel;
    __weak IBOutlet UIView *imageStatusContainer;
    
    UIView                  *backgroundView;
    UIButton                *selectedButton;
    UIBarButtonItem         *doneButtonObj;
    AlbumSelectionView      *albumSelectionViewObj;
    PhotoSelectionView      *photoSelectionObj;
    UAProgressView          *progressViewObj;
    
    NSURL                   *lastImageDownlodedForCropping;
    
    NSMutableArray          *imagesArray;
    NSDictionary            *selectedAlbumDetail;
    
    int                     selectedIndex;
    
    BOOL                    wasCameraOptionSelected;
    BOOL                    isPhotoSwapedAfterDrag;
}

#pragma mark - Properties
//@property (nonatomic, retain) UserProfileViewController *userProfileObj;
@property (nonatomic, strong) ImageUpdatedCompletionBlock imageUpdateBlock;
@property (nonatomic, assign) BOOL shouldViewAutoResignAfterOnePicConfirms;
@property (nonatomic, assign) BOOL isMale;

#pragma mark - Exposed methods
- (void)initialiseView;
- (void)addImagesOnArray;
- (void)showImageUpdatedPopup;

#pragma mark - IBAction methods
- (IBAction)mainPicTapped:(id)sender;
- (IBAction)doneButtonTapped:(id)sender;

@end
