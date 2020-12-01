//
//  VPImageCropperViewController.m
//  VPolor
//
//  Created by Vinson.D.Warm on 12/30/13.
//  Copyright (c) 2013 Huang Vinson. All rights reserved.
//

#import "VPImageCropperViewController.h"
#import "ImageAPIClass.h"
#import "FacebookAlbumViewController.h"
#import "NoInternetScreenView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "LoginViewController.h"
#import "Woo_v2-Swift.h"
#import "DeletePhotoView.h"
#import "MDSnackbar.h"
#import "DiscoverAPIClass.h"
#import "ImageRecognization.h"
#import "DefaultCropperView.h"
#import "AppLaunchModel.h"
#import "ProfileAPIClass.h"


#define SCALE_FRAME_Y 100.0f
#define BOUNDCE_DURATION 0.3f


#define kPhotoApproved  @"APPROVED"
#define kPhotoPending   @"PENDING"
#define kPhotoRejected  @"REJECTED"

#define kPhotoNoneTag       0
#define kPhotoApprovedTag   1
#define kPhotoPendingTag    2
#define kPhotoRejectedTag   3

@interface VPImageCropperViewController ()<UIImagePickerControllerDelegate , UINavigationControllerDelegate>{
    UIPinchGestureRecognizer *pinchGestureRecognizer;
    UIPanGestureRecognizer *panGestureRecognizer;
    GetBlock _getBlock;
    WooLoader  *customLoader;
}

@property (nonatomic, retain) UIImage *originalImage;
@property (nonatomic, retain) UIImage *nonEditedImage;
@property (nonatomic, retain) UIImageView *showImgView;
@property (nonatomic, retain) UIView *overlayView;
@property (nonatomic, retain) UIView *ratioView;
@property(nonatomic, strong) UIButton *btnOK;
@property (nonatomic, assign) CGRect oldFrame;
@property (nonatomic, assign) CGRect largeFrame;
@property (nonatomic, assign) CGFloat limitRatio;

@property (nonatomic, assign) CGRect latestFrame;

@property (nonatomic , strong) UIButton *btnRemovePhoto;

@property (nonatomic , strong) DefaultCropperView *cropperView;

@property (nonatomic , strong) PhotoTipsView *photoTipsViewObject;

@end

@implementation VPImageCropperViewController

- (void)dealloc {
    self.originalImage = nil;
    self.showImgView = nil;
    self.nonEditedImage = nil;
    self.overlayView = nil;
    self.ratioView = nil;
}

- (id)initWithImage:(UIImage *)originalImage cropFrame:(CGRect)cropFrame limitScaleRatio:(NSInteger)limitRatio {
    self = [super init];
    if (self) {
        self.cropFrame = cropFrame;
        self.limitRatio = limitRatio;
        _cropperView = [[DefaultCropperView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        __block VPImageCropperViewController *selfObject = self;
        [_cropperView actionPerformedWithBlock:^(int buttonTapState) {
            switch (buttonTapState) {
                case 100:
                    [selfObject btnCameraClicked];
                    break;
                case 200:
                    [selfObject btnGalleryClicked];
                    break;
                case 300:
                    [selfObject btnFaceBookClicked];
                    break;
                default:
                    break;
            }
        }];
        self.originalImage = [self fixOrientation:originalImage];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Swrve Event
    [APP_DELEGATE sendSwrveEventWithEvent:@"3-AddPhoto.AddPhotoScreen.AP_Landing" andScreen:@"AddPhotoScreen"];
    [[Utilities sharedUtility]colorStatusBar:[[Utilities sharedUtility] getUIColorObjectFromHexString:@"#6B6B6B" alpha:1.0f]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"dismissPhotoSelection" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissPhotoSelection) name:@"dismissPhotoSelection" object:nil];
    [self initView];
    
    if (_originalImage != nil){
        _nonEditedImage = _originalImage;
    }
    //[self initControlBtn];
    if (_isOpenedFromWizard == false){
        //[self initialiseBottomButton];
    }
    [confirmBtn setEnabled:NO];
    [confirmBtn setAlpha:0.5f];
    
    initialeWidthOfTheImage = self.latestFrame.size.width;
    NSLog(@"self.originalImage.size.width : %f",self.originalImage.size.width);
    NSLog(@"self.latestFrame.size.width : %f",self.latestFrame.size.width);
    NSData *imagedata = UIImagePNGRepresentation(self.originalImage);
    NSLog(@"size in kb %lu",(unsigned long)imagedata.length);
    
     _btnOK = [[UIButton alloc]init];
    
    _btnOK.tag = 9999;
    
    (IS_IPHONE_X || IS_IPHONE_XS_MAX ) ?  [_btnOK setFrame:CGRectMake(SCREEN_WIDTH-80, 45, 80, 30)] : [_btnOK setFrame:CGRectMake(SCREEN_WIDTH-80, 25, 80, 30)];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isOnboardingMyProfileShown"]){
        [_btnOK setTitle:@"OK" forState:UIControlStateNormal];
    }else{
        
        if (LoginModel.sharedInstance.isAlternateLogin==true && LoginModel.sharedInstance.isNewUserNoPicScreenOn == true && (_isOpenedFromWizard == false)){
            [_btnOK setTitle:@"NEXT" forState:UIControlStateNormal];
        }else{
            [_btnOK setTitle:@"OK" forState:UIControlStateNormal];
        }
    }
    
    _btnOK.titleLabel.font = [UIFont fontWithName:@"Lato-Medium" size:14.0f];
    [_btnOK setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnOK addTarget:self action:@selector(OkButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isOnboardingMyProfileShown"] == false && (_isOpenedFromWizard == false)) {
        if ([LoginModel.sharedInstance minPhotoCountForOnboarding] > 0){
            [_btnOK setAlpha:0.5];
        }
        else{
            [_btnOK setAlpha:1];
            
        }
    }
    
    
    if (![self.view.subviews containsObject:_btnOK]){
        [self.view addSubview:_btnOK];
    }
    
    
    
    // Adding Photo Remove Button
    
    _btnRemovePhoto = [UIButton buttonWithType:UIButtonTypeCustom];
//    if (_isOpenedFromWizard){
//
//    }
//    else{
//        [_btnRemovePhoto setImage:[UIImage imageNamed:@"ImageRemove"] forState:UIControlStateNormal];
//        [_btnRemovePhoto setFrame:CGRectMake(self.ratioView.frame.origin.x + 10, self.ratioView.frame.origin.y + self.ratioView.frame.size.height - 48, 38, 38)];
//    }
    
    
    [_btnRemovePhoto setImage:[UIImage imageNamed:@"ic_edit_photo_delete"] forState:UIControlStateNormal];
    [_btnRemovePhoto setFrame:CGRectMake(self.ratioView.frame.size.width + 10, self.ratioView.frame.origin.y + self.ratioView.frame.size.height - 40, 52, 52)];
    if (!_albumData || _albumData.isProfilePic) {//hide the delete button if image is preloaded
        [_btnRemovePhoto setHidden:YES];
    }
   
    
    [_btnRemovePhoto addTarget:self action:@selector(selectedPhotoRemoved) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnRemovePhoto];
    
    [self.view setClipsToBounds:YES];
    
}

//btnCameraClicked
- (void) btnCameraClicked{
    
    if (![APP_Utilities reachable]){
        
        [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];
        
        return;
    }
    
     [self openCamera];
}

- (void) btnGalleryClicked{
    if (![APP_Utilities reachable]){
        
        [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];
        
        return;
    }
    
    [self openPhotoGallery];
}

- (void) btnFaceBookClicked{
    if (![APP_Utilities reachable]){
        
        [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];
        
        return;
    }
    
   [self getFaceBookPhotos:false];
}



-(void)dismissPhotoSelection
{
    NSLog(@"dismissPhotoSelection");
    if(imagePicker != nil)
    {
        [imagePicker dismissViewControllerAnimated:YES completion:NULL];
    }
    [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
}

- (void)showPhotoTipsView{
    if (_photoTipsViewObject != nil){
        _photoTipsViewObject = nil;
    }
    if ([[DiscoverProfileCollection sharedInstance].myProfileData.gender isEqualToString:@"FEMALE"]){
        _photoTipsViewObject = [PhotoTipsView showView:false];
    }
    else{
        _photoTipsViewObject = [PhotoTipsView showView:true];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    
    [[WooScreenManager sharedInstance] hideHomeViewTabBar:YES isAnimated:NO];

    [APP_Utilities sendFirebaseEventWithScreenName:@"" withEventName:@"PhotoScreen_Landing"];
    if (![APP_Utilities reachable]){
        
        [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];
    }
    
    [self.navigationController.navigationBar setHidden:YES];
    
    [confirmBtn setEnabled:YES];
    [confirmBtn setAlpha:1.0f];
    
    UILabel *headerLabel =  [[UILabel alloc] initWithFrame:CGRectMake(APP_DELEGATE.window.frame.size.width/2, 30, 0, 0)];
    NSString *viewHeaderTitle = NSLocalizedString(@"Move and Scale", nil);
    [headerLabel setText:viewHeaderTitle];
    [headerLabel setTextColor:kHeaderTextRedColor];
    [headerLabel setFont:kHeaderTextFont];
    [headerLabel sizeToFit];
    [headerLabel setFrame:CGRectMake(((APP_DELEGATE.window.frame.size.width/2)-(headerLabel.frame.size.width/2)), 30, headerLabel.frame.size.width, headerLabel.frame.size.height)];
    //  [self.view addSubview:headerLabel];
    
    
    // Adding Cancel Button
    
    UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    (IS_IPHONE_X || IS_IPHONE_XS_MAX ) ? [btnCancel setFrame:CGRectMake(15, 45, 80, 30)] : [btnCancel setFrame:CGRectMake(15, 25, 80, 30)];
    [btnCancel setTitle:NSLocalizedString(@"CANCEL", @"CANCEL") forState:UIControlStateNormal];
    btnCancel.titleLabel.font = [UIFont fontWithName:@"Lato-Medium" size:14.0f];
    
    [btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
   
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isOnboardingMyProfileShown"]){
      
        [self.view addSubview:btnCancel];
    }else{
        (LoginModel.sharedInstance.isAlternateLogin == false) ? [self.view addSubview:btnCancel] : nil;
    }
 
    
    //PHOTO TIPS
    UIView *photoTipsView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 120, SCREEN_HEIGHT - 60, 100, 30)];
    [self.view addSubview:photoTipsView];
    
    UIButton *btnPhotoTips = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnPhotoTips setFrame:CGRectMake(0, 0, 80, 30)];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Photo Tips",nil)
                                                                             attributes:@{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
                                                                                          NSForegroundColorAttributeName: [UIColor whiteColor]}]];
    [btnPhotoTips setAttributedTitle:attributedString forState:UIControlStateNormal];
    btnPhotoTips.titleLabel.font = [UIFont fontWithName:@"Lato-Medium" size:14.0f];
    [btnPhotoTips addTarget:self action:@selector(showPhotoTipsView) forControlEvents:UIControlEventTouchUpInside];
    [photoTipsView addSubview:btnPhotoTips];
    
    UIImageView *photoTipsImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_edit_photo_tips"]];
    [photoTipsImageView setFrame:CGRectMake(82, 6, 18, 18)];
    [photoTipsView addSubview:photoTipsImageView];
    //ENDING PHOTO TOPS
    
    UILabel *zoomPinchLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 170)/2, 48.0, 170, 20)];
    zoomPinchLabel.textAlignment = NSTextAlignmentCenter;
    zoomPinchLabel.backgroundColor = [UIColor clearColor];
    zoomPinchLabel.text = NSLocalizedString(@"Pinch or zoom to scale image",nil);
    zoomPinchLabel.textColor = [UIColor whiteColor];
    zoomPinchLabel.font = [UIFont fontWithName:@"Lato-Regular" size:12.0];
    zoomPinchLabel.tag = 4050;
    [zoomPinchLabel setHidden:YES];
    [self.view addSubview:zoomPinchLabel];
    
    
    
    // This is code is added for the selected image coming from Edit Profile
    if (!_isImageAdded) {
        [self settingFrameAfterSelectingPhoto:self.originalImage];
        [self addGestureRecognizers];
        UIView *view = [self.view viewWithTag:9999];
        UILabel *pincLevel = [self.view viewWithTag:4050];
        if (view)
            [view setHidden:NO];
        
        if (pincLevel)
             [pincLevel setHidden:NO];
    }   //    [self createCornerForCropView];
}

-(void) setAlbumData:(AlbumPhoto *)albumData{
    _albumData = albumData;
    _btnRemovePhoto.hidden = NO;
    _cropperView.hidden = YES;
}

#pragma mark - ************************ Button Clicked Event *********************************
- (void)OkButtonClicked{
    
    if (![APP_Utilities reachable]){
        
            MDSnackbar *snackBarObj = [[MDSnackbar alloc] initWithText:NSLocalizedString(@"No internet connection", nil)
                                                           actionTitle:@""
                                                              duration:2.0];
            snackBarObj.multiline = YES;
            [snackBarObj show];
    }
    else{
        
        if (_btnOK.alpha == 0.5){
             UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"" message:@"Add a photo to continue" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CMP00356", @"Ok Button") style:UIAlertActionStyleCancel handler:nil];
                [errorAlert addAction:okAction];
                [self presentViewController:errorAlert animated:true completion:nil];
        }else{
            [self showWooLoader];
           
                NSDictionary *editedImageData = [self getSubImageData];
                UIImage *uploadableImage = [editedImageData objectForKey:@"imageObj"];
            CIImage *ciImage=[[CIImage alloc] initWithImage:uploadableImage];
            //[self OkButtonHandlingWhenThereIsInternet];
          
                 ImageRecognization *imgRek = [[ImageRecognization alloc]initWithName:self.showImgView];
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
            dispatch_async(queue, ^{
         if (@available(iOS 11.0, *)) {
                if([imgRek detectFace:ciImage]){
                    dispatch_async(dispatch_get_main_queue(), ^{
                    [self OkButtonHandlingWhenThereIsInternet];
                    });
                }else{
                    [APP_DELEGATE sendFirebaseEvent:@"FACE_NOT_FOUND" andScreen:@""];
                    dispatch_async(dispatch_get_main_queue(), ^{
                   [self removeWooLoader];
                    UIAlertController *authenticationAlert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"Woo_pic_noPicAlert", @"") preferredStyle:UIAlertControllerStyleAlert];

                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CMP00356", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
                        [self.navigationController popViewControllerAnimated:true];
                    }];
                    [authenticationAlert addAction:okAction];

                    [self presentViewController:authenticationAlert animated:true completion:nil];
                });
                 } }else{
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [self OkButtonHandlingWhenThereIsInternet];
                     });
                }});
    }
    
}
}


- (void)wooAlbumisUpdatedNow:(GetBlock)block{
    _getBlock = block;
}

- (void)OkButtonHandlingWhenThereIsInternet{
    
    NSDictionary *editedImageData = [self getSubImageData];

    UIImage *uploadableImage = [editedImageData objectForKey:@"imageObj"];
    if ([LoginModel sharedInstance].isAlternateLogin){
        [[Utilities sharedUtility]sendFirebaseEventWithScreenName:@"" withEventName:@"PHONE_LOGIN_NOPICSCREEN_NEXT"];
        [[Utilities sharedUtility] sendMixPanelEventWithName:@"PHONE_LOGIN_NOPICSCREEN_NEXT"];
    }
    
    if (_btnRemovePhoto.isHidden == true || [self isEqualImage:uploadableImage second:_nonEditedImage]) {
        if (_imageBlock) {
            _imageBlock(self.wooAlbum);
        }
        
        if (self.delegate && [self.delegate conformsToProtocol:@protocol(VPImageCropperDelegate)]) {
            [self.delegate imageCropper:self didFinished:editedImageData];
        }
        if (_getBlock) {
            _getBlock();
        }
        
        [self removeWooLoader];
        [self.navigationController popViewControllerAnimated:NO];
        return;
    }
    
    [[Utilities sharedUtility]sendFirebaseEventWithScreenName:@"" withEventName:@"Photoscreen_ok"];

    [self showWooLoader];
    
    NSString *objetId = self.albumData.objectId;
    
    [[Utilities sharedUtility] sendFirebaseEventWithScreenName:@"" withEventName:@"EditProfile_EditPhoto_Crop"];

    BOOL status =[ImageAPIClass uploadImageToServer:uploadableImage  AndObjectId:objetId WithFakeCheck:YES WithCompletionBlock:^(id response, BOOL success , int statusCode) {
        
        if (statusCode == 401) {
            // [self handleErrorForResponseCode:statusCode];
             [self removeWooLoader];
            [self authenticationFailedAlert];
            return ;
        }
        
        //  fbPhotoObjetId = nil;
        if (success) {
            [[DiscoverProfileCollection sharedInstance].myProfileData setProfileCompletenessScore:[NSString stringWithFormat:@"%@",[response objectForKey:@"profileCompletenessScore"]]];
            WooAlbumModel *albumModel = [[WooAlbumModel alloc] init];
            [albumModel setIsMyprofile:true];
            [albumModel addObjectsFromArray:[response objectForKey:@"wooAlbum"]];
            [DiscoverProfileCollection sharedInstance].myProfileData.wooAlbum = albumModel;
            
            int imageIndex = [albumModel count] - 1;
            if (objetId != nil){
                imageIndex = self->_albumData.imageOrder;
            }
            
            AlbumPhoto *photoObject = [albumModel objectAtIndex:imageIndex];
            NSString *imageUrlString = photoObject.url;

            if (imageUrlString && imageUrlString.length > 0){
            [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:imageUrlString] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                
            } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                NSLog(@"completed url = %@",[NSString stringWithFormat:@"%@",imageURL]);
                [self performOperationAfterResponseOfCall:editedImageData andAlbumData:albumModel];
            }];
            }
            else{
                [self performOperationAfterResponseOfCall:editedImageData andAlbumData:albumModel];
            }
        }
        else{
            [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"Please try again", @"No internet connection") withActionTitle:@"" withDuration:3.0];
            [self removeWooLoader];
        }
    }];
    
    if (!status) {
        SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"Please check your internet connection",nil));
    }
    
}

- (void)performOperationAfterResponseOfCall:(NSDictionary *)editedImageData andAlbumData:(WooAlbumModel *)albumModel{
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(VPImageCropperDelegate)]) {
        [self.delegate imageCropper:self didFinished:editedImageData];
    }
    if (_getBlock) {
        _getBlock();
    }
    if (_imageBlock) {
        _imageBlock(albumModel);
    }
    [self removeWooLoader];
    [self.navigationController popViewControllerAnimated:NO];
}


#pragma mark - Handle Authentication Error Code = 401

- (void)authenticationFailedAlert{
    UIAlertController *authenticationAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Authentication error", @"") message:NSLocalizedString(@"Something unexpected has happened. Please login again", @"") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CMP00356", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showLoginScreen];
    }];
    [authenticationAlert addAction:okAction];
    [self presentViewController:authenticationAlert animated:true completion:nil];
}

- (void)showLoginScreen{
    [[FBSession activeSession] clearJSONCache];
    [[FBSession activeSession] close];
    [[FBSession activeSession] closeAndClearTokenInformation];
    [FBSession setActiveSession:nil];
    [[FBSDKLogin sharedManagerFBSDKLogin] logOutUserFromFacebook];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"FBAccessTokenInformationKey"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kIsLoginProcessCompleted];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kWooUserId];
    [[NSUserDefaults standardUserDefaults] synchronize];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                @"onboarding" bundle:[NSBundle mainBundle]];
   LoginViewController *loginViewControllerObj = [storyboard instantiateViewControllerWithIdentifier:kLoginViewControllerID];
    [loginViewControllerObj setIsAuthenticationFailed:YES];
    [loginViewControllerObj setAuthenticationController:self];
    [self presentViewController:loginViewControllerObj animated:YES completion:^{
        [[WooScreenManager sharedInstance] loadLoginView];
    }];
}


- (void)authenticationFailedCallBack{
    [self getWooAlbum];
    
}




#pragma mark - Cancel Button Clicked
- (void) cancelButtonClicked{
    
    if (![APP_Utilities reachable]){
        [self loadinngNoInternetScreenwithTag:10000];
        return;
    }
    else if (self.delegate && [self.delegate conformsToProtocol:@protocol(VPImageCropperDelegate)]) {
        [self.delegate imageCropperDidCancel:self];
        return;
    }
    
    if ([LoginModel sharedInstance].isAlternateLogin){
        [[Utilities sharedUtility]sendFirebaseEventWithScreenName:@"" withEventName:@"PHONE_LOGIN_NOPICSCREEN_BACK"];
        [[Utilities sharedUtility] sendMixPanelEventWithName:@"PHONE_LOGIN_NOPICSCREEN_BACK"];
    }
    else{
    [[Utilities sharedUtility]sendFirebaseEventWithScreenName:@"" withEventName:@"Photoscreen_cancel"];
    }

    if (_isPresented == true || self.navigationController == nil) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark Alert Method

- (void)showDeletePopup:(BOOL)showForSingleImage{
    NSString *commentString = nil;
    if (showForSingleImage){
        commentString = NSLocalizedString(@"You need more than one approved photo to delete your main photo.", @"");
    }
    else{
        NSString *photoString = nil;
        if ([LoginModel sharedInstance].minPhotoCountForOnboarding == 1){
            photoString = @" photo";
        }
        else{
            photoString = @" photos";
        }
        commentString = [NSString stringWithFormat:@"You need minimum %d %@",[LoginModel sharedInstance].minPhotoCountForOnboarding,photoString];
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:commentString preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:true completion:nil];
    
}


#pragma mark - loading third screen
- (void)loadinngNoInternetScreenwithTag:(int)tag{
    
    NoInternetScreenView *noInternet = [[NoInternetScreenView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [noInternet setDelegate:self];
    noInternet.tag = tag;
    [self.view addSubview:noInternet];
    
}


#pragma mark - Refresh button clicked
- (void)refreshButtonClicked:(UIButton *)sender{
    
    if ([APP_Utilities reachable]){
        [self removeNoInternetScreenWithTag];
        
    }
    
}


- (void) removeNoInternetScreenWithTag{
    
    for (UIView *view in self.view.subviews)
        if (view.tag == 10000) // For Cancel Button Clicked
            [view removeFromSuperview];
        else if(view.tag == 20000){ // For Ok Button Clicked
            [view removeFromSuperview];
            [self OkButtonHandlingWhenThereIsInternet];
        }
}


#pragma mark - Remove Selected Photo
- (void) selectedPhotoRemoved{

    [[Utilities sharedUtility]sendFirebaseEventWithScreenName:@"" withEventName:@"PhotoScreen_RemovePhoto"];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isOnboardingMyProfileShown"] == false){
    if (_isOpenedFromWizard){
        if (self.albumData.isProfilePic == true){
        if ([DiscoverProfileCollection.sharedInstance.myProfileData.wooAlbum countOfApprovedPhotos] <= LoginModel.sharedInstance.minPhotoCountForOnboarding){
            if (LoginModel.sharedInstance.minPhotoCountForOnboarding == 1){
                [self showDeletePopup:true];
            }
            else{
                [self showDeletePopup:false];
            }
        return;
        }
        }
        else{
            
            if([DiscoverProfileCollection.sharedInstance.myProfileData.wooAlbum countOfApprovedPhotos] == 0){
            }
            
            if ([DiscoverProfileCollection.sharedInstance.myProfileData.wooAlbum countOfApprovedPhotos] < LoginModel.sharedInstance.minPhotoCountForOnboarding){
                [self showDeletePopup:false];
                return;
            }
        }
    }
    }
    else{
        if ([self.albumData isProfilePic] == true && [_wooAlbum countOfApprovedPhotos] == 1){
            [self showDeletePopup:true];
            return;
        }
    }
    
    if (_albumData && _albumData.url) {
        DeletePhotoView *popup = [[NSBundle mainBundle] loadNibNamed:@"DeletePhotoView" owner:self options:nil].firstObject;
        popup.frame = self.view.bounds;
        [popup setDeleteDataOnViewWithImage:self.originalImage withBlock:^{
            
            if (_isOpenedFromWizard){
//                if (_imageBlock) {
//                    _imageBlock(nil);
//                }
//                [self cancelButtonClicked];
                if (self.albumData.objectId != nil){
                [self showWooLoader];
                [ImageAPIClass deletePhotoForObjectID:self.albumData.objectId AndCompletionBlock:^(id response, BOOL success, int statusCode) {
                    [self removeWooLoader];
                    [[DiscoverProfileCollection sharedInstance].myProfileData setProfileCompletenessScore:[NSString stringWithFormat:@"%@",[response objectForKey:@"profileCompletenessScore"]]];
                    WooAlbumModel *albumModel = [[WooAlbumModel alloc] init];
                    [albumModel setIsMyprofile:true];
                    [albumModel addObjectsFromArray:[response objectForKey:@"wooAlbum"]];
                    if (_imageBlock) {
                        _imageBlock(albumModel);
                    }
                    else{
                        [DiscoverProfileCollection sharedInstance].myProfileData.wooAlbum = albumModel;
                    }
                    
                    [self removeWooLoader];
                    [self.navigationController popViewControllerAnimated:YES];
                    
                    NSDictionary* userInfo = @{@"UIImage":self.originalImage};
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteFromDictionaryInWizardScreen" object:nil userInfo:userInfo];
                }];
                }
                else{
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
            else{
            self.originalImage = [UIImage imageNamed:@"crop_default"];
            self.originalImage = [self fixOrientation:_originalImage];
            [self.showImgView setImage:self.originalImage];
            
            [self settingFrameFor:self.originalImage];
            
            UIView *view = [self.view viewWithTag:9999];
            if (view){
                [view setHidden:NO];
            }
                UILabel *pincLevel = [self.view viewWithTag:4050];
              
                if (pincLevel){
                    [pincLevel setHidden:NO];
                }
            _albumData.isProfilePic = NO;
            _albumData.url = nil;
            
            [_btnRemovePhoto setHidden:YES];
            [_cropperView setHidden:NO];

            [self.view removeGestureRecognizer:pinchGestureRecognizer];
            [self.view removeGestureRecognizer:panGestureRecognizer];
            }
        }];
        [self.view addSubview:popup];
    }
    else{
        self.originalImage = [UIImage imageNamed:@"crop_default"];
        self.originalImage = [self fixOrientation:_originalImage];
        [self.showImgView setImage:self.originalImage];
        
        [self settingFrameFor:self.originalImage];
        
        // Removing OK Button
        UIView *view = [self.view viewWithTag:9999];
        if (view){
            [view setHidden:YES];
        }
        UILabel *pincLevel = [self.view viewWithTag:4050];
       
        if (pincLevel){
            [pincLevel setHidden:YES];}
        
        [_btnRemovePhoto setHidden:YES];
        [_cropperView setHidden:NO];
        
        [self.view removeGestureRecognizer:pinchGestureRecognizer];
        [self.view removeGestureRecognizer:panGestureRecognizer];
    }
    if (LoginModel.sharedInstance.isAlternateLogin == true && LoginModel.sharedInstance.isNewUserNoPicScreenOn == true){
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isOnboardingMyProfileShown"] == false){
        if ([LoginModel.sharedInstance minPhotoCountForOnboarding] > 0){
           [_btnOK setAlpha:0.5];
        }
        else{
            [_btnOK setAlpha:1];
        }
    }
        if (![self.view.subviews containsObject:_btnOK]){
            [self.view addSubview:_btnOK];
        }
         [_btnOK setHidden:false];
    }
}

-(void)showFakeAlert{
   U2AlertView *fakeAlert = [[U2AlertView alloc] init];
    NSString *headerStr = NSLocalizedString(@"We didn't see you there!", nil);
    NSString *msgStr = NSLocalizedString(@"Select a picture with your face visible.", nil);
    NSString *buttonText = NSLocalizedString(@"CMP00356", nil);
    [fakeAlert alertWithHeaderText:headerStr description:msgStr leftButtonText:nil andRightButtonText:buttonText];
    
    [fakeAlert setU2AlertActionBlockForButton:^(int tagValue , id data){
        NSLog(@"%d",tagValue);
        [self buttonTappedOnFakeAlert];
    }];
    [fakeAlert show];
 }

-(void)buttonTappedOnFakeAlert{
    //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Confirms_To_Search_For_Another_Picture forScreenName:@"PR"];
    _showPreviousOption = TRUE;
    [self cancel:nil];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NO;
}

- (void)initView {
    
    self.view.backgroundColor = [UIColor colorWithRed:107.0/255.0 green:107.0/255.0 blue:107.0/255.0 alpha:1.0];
    
    self.showImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.showImgView setMultipleTouchEnabled:YES];
    [self.showImgView setUserInteractionEnabled:YES];
    
    [self settingFrameFor:self.originalImage];

    [self.view addSubview:self.showImgView];
    
    self.overlayView = [[UIView alloc] initWithFrame:self.view.bounds];

    self.overlayView.backgroundColor = [UIColor colorWithRed:107.0/255.0 green:107.0/255.0 blue:107.0/255.0 alpha:0.6];
    self.overlayView.userInteractionEnabled = NO;
    
    self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.overlayView];
    
    self.ratioView = [[UIView alloc] initWithFrame:self.cropFrame];
    
    self.ratioView.layer.borderColor = kRedThemeV3.CGColor;
    self.ratioView.layer.borderWidth = 2.0f;
    self.ratioView.autoresizingMask = UIViewAutoresizingNone;
    [self.view addSubview:self.ratioView];
    
    
    //    [self createGridForCropView];
    
    [self overlayClipping];
    
    
    _cropperView.frame = self.ratioView.frame;
    
    _cropperView.layer.borderColor = kRedThemeV3.CGColor;
    _cropperView.layer.borderWidth = 2.0f;

    if([[[[DiscoverProfileCollection sharedInstance] myProfileData] wooAlbum] count]  > 0){
        _cropperView.lblMessage.text = NSLocalizedString(@"Where do you want to load your picture from?",@"Where do you want to load your picture from?");
    }
    else
    {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isOnboardingMyProfileShown"])
            {
                _cropperView.lblIntro.text = @"";
                _cropperView.lblMessage.text = NSLocalizedString(@"Where do you want to load your picture from?",@"Where do you want to load your picture from?");

            }
            else
            {
                _cropperView.lblIntro.text = [NSString stringWithFormat:@"Hi %@,", LoginModel.sharedInstance.firstName];
                _cropperView.lblMessage.text = @"Add your best pic!";

            }
    }
    [self.view addSubview:_cropperView];

    if (_isImageAdded){
        _cropperView.hidden = NO;
    }
}

-(void)settingFrameFor:(UIImage *)img{
    // scale to fit the screen
    CGFloat oriWidth = self.cropFrame.size.width;
    CGFloat oriHeight = self.originalImage.size.height * (oriWidth / self.originalImage.size.width);
    CGFloat oriX = self.cropFrame.origin.x + (self.cropFrame.size.width - oriWidth) / 2;
    CGFloat oriY = self.cropFrame.origin.y + (self.cropFrame.size.height - oriHeight) / 2;
    self.oldFrame = CGRectMake(oriX, oriY, oriWidth, oriHeight);
    self.latestFrame = self.oldFrame;
    
    self.showImgView.frame = self.oldFrame;
    
    [self.showImgView setImage:img];
    
    self.largeFrame = CGRectMake(0, 0, self.limitRatio * self.oldFrame.size.width, self.limitRatio * self.oldFrame.size.height);
    
    [_btnRemovePhoto setHidden:NO];
    [_cropperView setHidden:YES];
}

-(void)settingFrameAfterSelectingPhoto:(UIImage *)img{
    
    if (img == nil) {
        return;
    }
    CGFloat oriWidth = 0;
    CGFloat oriHeight = 0;
    CGFloat oriX = 0;
    CGFloat oriY = 0;
    
    // scale to fit the Old Frame
    
    CGFloat widthScalingFactor;
    CGFloat heightScalingFactor;
    
    // checking whether selected image height & width is > RatioView
    if (img.size.width > self.ratioView.frame.size.width && img.size.height > self.ratioView.frame.size.height) {
        
        widthScalingFactor = self.ratioView.frame.size.width/self.originalImage.size.width;
        heightScalingFactor = self.ratioView.frame.size.height/self.originalImage.size.height;
        
        if (heightScalingFactor > widthScalingFactor) {
            oriWidth = heightScalingFactor * self.originalImage.size.width;
            oriHeight = heightScalingFactor *self.originalImage.size.height;
            
            oriX = self.cropFrame.origin.x-((oriWidth-self.cropFrame.size.width)/2);// only x to be changed
            oriY = self.cropFrame.origin.y;
            
        }else{
            oriWidth = widthScalingFactor * self.originalImage.size.width;
            oriHeight = widthScalingFactor *self.originalImage.size.height;
            oriX = self.cropFrame.origin.x;
            oriY = self.cropFrame.origin.y-((oriHeight-self.cropFrame.size.height)/2); // only y needs to be changed
        }
        
        
    }else if (img.size.width > self.ratioView.frame.size.width){ // checking whether selected image width is > RatioView
        
        heightScalingFactor = self.ratioView.frame.size.height/self.originalImage.size.height;
        
        oriWidth = self.originalImage.size.width * heightScalingFactor;
        oriHeight = self.originalImage.size.height * heightScalingFactor;
        
        oriX = self.cropFrame.origin.x-((oriWidth-self.cropFrame.size.width)/2);
        oriY = self.cropFrame.origin.y;
        
        
        
    }else if (img.size.height > self.ratioView.frame.size.height){ // checking whether selected image height is > RatioView
        
        widthScalingFactor = self.ratioView.frame.size.width/self.originalImage.size.width;
        
        oriWidth = self.originalImage.size.width * widthScalingFactor;
        oriHeight = self.originalImage.size.height * widthScalingFactor;
        
        oriX = self.cropFrame.origin.x;
        oriY = self.cropFrame.origin.y-((oriHeight-self.cropFrame.size.height)/2);
        
    }else if (img.size.height < self.ratioView.frame.size.height && img.size.width < self.ratioView.frame.size.width ){
               
        if (img.size.width < img.size.height) {
            
            widthScalingFactor = self.ratioView.frame.size.width/self.originalImage.size.width;
            
            oriWidth = self.originalImage.size.width * widthScalingFactor;
            oriHeight = self.originalImage.size.height * widthScalingFactor;
            oriX = self.cropFrame.origin.x;
            oriY = self.cropFrame.origin.y-((oriHeight-self.cropFrame.size.height)/2);
            
            
            
        }else if (img.size.height < img.size.width){
            
            heightScalingFactor = self.ratioView.frame.size.height/self.originalImage.size.height;
            
            oriWidth = self.originalImage.size.width * heightScalingFactor;
            oriHeight = self.originalImage.size.height * heightScalingFactor;
            oriX = self.cropFrame.origin.x-((oriWidth-self.cropFrame.size.width)/2);
            oriY = self.cropFrame.origin.y;
            
        }else if (img.size.width == img.size.height) {
            
            heightScalingFactor = self.ratioView.frame.size.height/self.originalImage.size.height;
            oriWidth = self.originalImage.size.width * heightScalingFactor;
            oriHeight = self.originalImage.size.height * heightScalingFactor;
            oriX = self.cropFrame.origin.x-((oriWidth-self.cropFrame.size.width)/2);
            oriY = self.cropFrame.origin.y-((oriHeight-self.cropFrame.size.height)/2);
            
        }
    }
    self.latestFrame = CGRectMake(oriX, oriY, oriWidth, oriHeight);
    if (self.showImgView != nil) {
        self.showImgView.frame = CGRectMake(oriX, oriY, oriWidth, oriHeight);
    }
    
    self.oldFrame = CGRectMake(oriX, oriY, oriWidth, oriHeight);
    
    [self.showImgView setImage:img];
    self.largeFrame = CGRectMake(0, 0, self.limitRatio * self.oldFrame.size.width, self.limitRatio * self.oldFrame.size.height);
    
    [_btnRemovePhoto setHidden:NO];
    [_cropperView setHidden:YES];
}

/*#pragma mark - Initialise Bottom Button
- (void)initialiseBottomButton{
    CGFloat yAxis = self.ratioView.frame.origin.y + self.ratioView.frame.size.height;
     // Adding Fb button
    UIButton *btnFb = [[UIButton alloc] initWithFrame:CGRectMake((([[UIScreen mainScreen] bounds].size.width/2)-48/2), yAxis + 10 , 48, 55)];
    [btnFb setBackgroundColor:[UIColor clearColor]];
    //    [btnFb setTitleColor:[UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1] forState:UIControlStateNormal];
    //NSString *cancelButtonStr = NSLocalizedString(@"facebook", nil);
    //  [btnFb setTitle:cancelButtonStr forState:UIControlStateNormal];
    [btnFb setImage:[UIImage imageNamed:@"cropPlaceholder"] forState:UIControlStateNormal];
    
    [btnFb.titleLabel setFont:kVerifyingMessageTextFont];
    btnFb.tag = 0;
    [btnFb addTarget:self action:@selector(buttomButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    btnFb.layer.shouldRasterize = YES;
    btnFb.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    [btnFb.layer setCornerRadius:2.0f];
    
    [self.view addSubview:btnFb];
    
    
    
    UIImageView *imgViewFb = [[UIImageView alloc] initWithFrame:CGRectMake(btnFb.frame.origin.x + btnFb.frame.size.width - 10, btnFb.frame.origin.y + btnFb.frame.size.height - 10, 20, 20)];
    [imgViewFb setImage:[UIImage imageNamed:@"fbIconCrop"]];
    [self.view addSubview:imgViewFb];
    
    
    
    // Adding Gallery Button
    UIButton *btnGallery = [[UIButton alloc] initWithFrame:CGRectMake(btnFb.frame.origin.x - 48 - 25, yAxis + 10, 48, 55)];
    [btnGallery setBackgroundColor:[UIColor clearColor]];
    [btnGallery setImage:[UIImage imageNamed:@"cropPlaceholder"] forState:UIControlStateNormal];
    
    [btnGallery.titleLabel setFont:kVerifyingMessageTextFont];
    btnGallery.tag = 1;
    [btnGallery addTarget:self action:@selector(buttomButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    btnGallery.layer.shouldRasterize = YES;
    btnGallery.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    [btnGallery.layer setCornerRadius:2.0f];
    
    //[self.view addSubview:btnGallery];
    
    
    UIImageView *imgViewGallery = [[UIImageView alloc] initWithFrame:CGRectMake(btnGallery.frame.origin.x + btnGallery.frame.size.width - 10, btnGallery.frame.origin.y + btnGallery.frame.size.height - 10, 20, 20)];
    [imgViewGallery setImage:[UIImage imageNamed:@"galleryIcon"]];
    [self.view addSubview:imgViewGallery];
    
    
    
    
    // Adding Camera Button
    UIButton *btnCamera = [[UIButton alloc] initWithFrame:CGRectMake(btnFb.frame.origin.x + 48 + 25, yAxis + 10, 48, 55)];
    [btnCamera setBackgroundColor:[UIColor clearColor]];
    [btnCamera setImage:[UIImage imageNamed:@"cameraIcon"] forState:UIControlStateNormal];
    [btnCamera.titleLabel setFont:kVerifyingMessageTextFont];
    
    btnCamera.tag = 2;
    [btnCamera addTarget:self action:@selector(buttomButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    btnCamera.layer.shouldRasterize = YES;
    btnCamera.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    [btnCamera.layer setCornerRadius:2.0f];
    
    [self.view addSubview:btnCamera];
    
    
    
}


#pragma mark - Bottom Button Clicked
- (void)buttomButtonClicked:(UIButton *)sender {
    
    if (![APP_Utilities reachable]){
        
        [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];

        return;
    }
    
   // fbPhotoObjetId = nil;
    if (sender.tag == 0) { // for facebook
        [self getWooAlbum];
    }else if (sender.tag == 1){ // For Gallery
        
        [self openPhotoGallery];
        
    }else if (sender.tag == 2){ // For Camera
        [self openCamera];
    }
}
*/
#pragma mark - Open Photo Gallery
-(void)openPhotoGallery{
    
    if (![self checkPhotosPermissionCallBack]){
        
        UIAlertController *authenticationAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Not Authorized", @"Not Authorized") message:NSLocalizedString(@"Please enable photos for this app to use this feature.", @"Photos setting") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
        [authenticationAlert addAction:cancelAction];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CMP00356", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        [authenticationAlert addAction:okAction];
        
        [self presentViewController:authenticationAlert animated:true completion:nil];
        return;
    }

    [[Utilities sharedUtility]sendFirebaseEventWithScreenName:@"" withEventName:@"Photoscreen_add_gallery"];

    if (imagePicker)
        imagePicker = nil;
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = NO;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePicker animated:YES completion:NULL];
}

#pragma mark - Open Photo Camera
-(void)openCamera{
    
    if (![self checkCameraPermissionCallBack]){
        
        UIAlertController *authenticationAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Not Authorized", @"Not Authorized") message:NSLocalizedString(@"Please enable the camera for this app to use this feature.", @"Camera setting") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
        [authenticationAlert addAction:cancelAction];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CMP00356", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        [authenticationAlert addAction:okAction];
        
        [self presentViewController:authenticationAlert animated:true completion:nil];
        return;
    }

    [[Utilities sharedUtility]sendFirebaseEventWithScreenName:@"" withEventName:@"Photoscreen_add_cam"];

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])  {
    
        if (imagePicker)
            imagePicker = nil;
        
        imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = NO;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        [self presentViewController:imagePicker animated:YES completion:NULL];
    }
}

#pragma maek - Get Woo Album
- (void)getWooAlbum{
    
    [ImageAPIClass fetchAlbumsWithCompletionBlock:^(id response, BOOL success, int statusCode) {
        
        if (statusCode == 401) {
            // [self handleErrorForResponseCode:statusCode];
            if ([[LoginModel sharedInstance]isAlternateLogin] == true){
                [self showAuthPopUP];
            }else{
                [self authenticationFailedAlert];
            }
            
            return ;
        }

        if (success)
        {
            [_btnOK setAlpha:1.0];

            [[Utilities sharedUtility]sendFirebaseEventWithScreenName:@"" withEventName:@"Photoscreen_add_fb"];

            NSLog(@"response > %@",response);
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                        @"onboarding" bundle:[NSBundle mainBundle]];
            
            FacebookAlbumViewController *obj = [storyboard instantiateViewControllerWithIdentifier:kFacebookAlbumControllerID];
            obj.delegate = self;
            obj.isPresented = _isPresented;
            obj.arrAlbumData = [response objectForKey:@"albums"];
            if ([obj.arrAlbumData count] < 1) { // If there is no Album found.
                
                
                UIAlertController *reportAlertcontroller = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"No album found.", @"") preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction *action) {
                                                                     
                                                                 }];
                ;
                
                [reportAlertcontroller addAction:okAction];
                
                // [reportAlertcontroller.view setTintColor:kHeaderTextRedColor];
                [self presentViewController:reportAlertcontroller animated:YES completion:^{
                    // [reportAlertcontroller.view setTintColor:kHeaderTextRedColor];
                }];

                
                
                
            }
            
            
            if (_isPresented) 
                [self presentViewController:obj animated:YES completion:nil];
            else
                [self.navigationController pushViewController:obj animated:YES];
            
        }
    }];
}

-(void)getFaceBookPhotos:(BOOL)isAuthNeeded{
    if([[LoginModel sharedInstance]isAlternateLogin]){
        
        SwiftUtilities *swiftUtils = [[SwiftUtilities alloc]init];
        [swiftUtils getAccessTokenFromFacebook:self isAuthNeeded:isAuthNeeded accessToken:^(BOOL isSucess, NSString *token) {
            if (isSucess){
                [self getWooAlbum];
            }else{
                [self showAuthPopUP];
            }
        }];
        
    }else{
        [self getWooAlbum];
    }
 }

-(void)showAuthPopUP{
    UIAlertController *permissionMissingAlert = [UIAlertController alertControllerWithTitle:@"Need more details!" message:@"We need some more details to build \nan accurate Woo profile for you. \nPlease allow Woo to access \nFacebook for this information. \n\nWoo never posts on your wall." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Authorize Facebook", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getFaceBookPhotos:true];
    }];
    
    [permissionMissingAlert addAction:defaultAction];
    [self presentViewController:permissionMissingAlert animated:YES completion:nil];
}

#pragma mark - Photo Selection Method CallBack
- (void) selectedPhotoData:(id)photoData{
    
    NSLog(@"%@",photoData);
    
   // fbPhotoObjetId = [NSString stringWithFormat:@"%@",[photoData objectForKey:@"objectId"]] ;
    
    [self addGestureRecognizers];
    if ([photoData objectForKey:@"srcBig"]) {
        
        
        NSString *strImage = [[photoData objectForKey:@"srcBig"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [APP_Utilities showActivityIndicator];
        
        /// Asynchronous call
        
        dispatch_queue_t mycustomQueue = dispatch_queue_create("com.woo.VPICropper", NULL);
        dispatch_async(mycustomQueue, ^{
            
            self.originalImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:strImage]]];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [APP_Utilities hideActivityIndicator];
                self.originalImage = [self fixOrientation:self.originalImage];
                
                [self settingFrameAfterSelectingPhoto:self.originalImage];
                
                if (_albumData.url == nil) {
                    _albumData.url = @"";
                }
                
                UIView *view = [self.view viewWithTag:9999];
                if (view)
                    [view setHidden:NO];
                UILabel *pincLevel = [self.view viewWithTag:4050];
                if (pincLevel)
                    [pincLevel setHidden:NO];
                
                if (self.originalImage == nil) {
                    self.originalImage = [UIImage imageNamed:@"crop_default"];
                    self.originalImage = [self fixOrientation:_originalImage];
                    [self.showImgView setImage:self.originalImage];
                    
                    [self settingFrameFor:self.originalImage];

                    _albumData.isProfilePic = NO;
                    _albumData.url = nil;
                    
                    [_btnRemovePhoto setHidden:YES];
                    [_cropperView setHidden:NO];
                    
                    [self.view removeGestureRecognizer:pinchGestureRecognizer];
                    [self.view removeGestureRecognizer:panGestureRecognizer];
                }
            });
        });
    }
}

#pragma mark - UIImagePicker Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    self.originalImage = info[UIImagePickerControllerOriginalImage];
    
   
    [_btnOK setAlpha:1.0];

    if (self.originalImage) {
        
        [self addGestureRecognizers];
        // [self.showImgView setImage:chosenImage];
        self.originalImage = [self fixOrientation:self.originalImage];
        [self settingFrameAfterSelectingPhoto:self.originalImage];
        
        if (_albumData.url == nil) {
            _albumData.url = @"";
        }
        
        UIView *view = [self.view viewWithTag:9999];
        if (view)
            [view setHidden:NO];
        UILabel *pincLevel = [self.view viewWithTag:4050];
        if (pincLevel)
            [pincLevel setHidden:NO];
        
    }
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [[WooScreenManager sharedInstance] hideHomeViewTabBar:YES isAnimated:NO];
    }];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        [[WooScreenManager sharedInstance] hideHomeViewTabBar:YES isAnimated:NO];
    }];
    
}

#pragma mark - Check Camera Permission
- (BOOL)checkCameraPermissionCallBack{
    
    __block  BOOL        permission = TRUE;
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        // do your logic
    } else if(authStatus == AVAuthorizationStatusDenied){
        // Permission has been denied.
        return FALSE;
        
        
        
    } else if(authStatus == AVAuthorizationStatusRestricted){
        // restricted, normally won't happen
    } else if(authStatus == AVAuthorizationStatusNotDetermined){
        // not determined?!
        
    } else {
        // impossible, unknown authorization status
    }
    
    
    return permission;
}


- (BOOL)checkPhotosPermissionCallBack{
    
    BOOL permission = TRUE;
    
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    switch (status) {
        case ALAuthorizationStatusDenied:
        case ALAuthorizationStatusRestricted:
        {
            return NO;
        }
            
    }
    
    return permission;
}



- (void)initControlBtn {
    
    cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake((([[UIScreen mainScreen] bounds].size.width/2)-91), [[UIScreen mainScreen] bounds].size.height - 60.0f, 71, 33)];
    cancelBtn.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
    [cancelBtn setTitleColor:[UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1] forState:UIControlStateNormal];
    NSString *cancelButtonStr = NSLocalizedString(@"Cancel", nil);
    [cancelBtn setTitle:cancelButtonStr forState:UIControlStateNormal];
    [cancelBtn.titleLabel setFont:kVerifyingMessageTextFont];
    
    [cancelBtn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.layer.shouldRasterize = YES;
    cancelBtn.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    [cancelBtn.layer setCornerRadius:2.0f];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isOnboardingMyProfileShown"]){
      [self.view addSubview:cancelBtn];
    }else{
        (LoginModel.sharedInstance.isAlternateLogin == false) ? [self.view addSubview:cancelBtn] : nil;
     }
    
    
    confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake((([[UIScreen mainScreen] bounds].size.width/2)+21), [[UIScreen mainScreen] bounds].size.height - 60.0f, 71, 33)];
    confirmBtn.backgroundColor = [UIColor colorWithRed:1 green:0.34 blue:0.36 alpha:1];
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    NSString *cropButtonStr = NSLocalizedString(@"Done", nil);
    [confirmBtn setTitle:cropButtonStr forState:UIControlStateNormal];
    [confirmBtn.titleLabel setFont:kVerifyingMessageTextFont];
    [confirmBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    confirmBtn.titleLabel.textColor = [UIColor whiteColor];
    
    confirmBtn.layer.shouldRasterize = YES;
    confirmBtn.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    [confirmBtn.layer setCornerRadius:2.0f];
    
    [confirmBtn setTitleEdgeInsets:UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f)];
    [confirmBtn addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmBtn];
    
    if (!warningLabel) {
        warningLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, confirmBtn.frame.origin.y-60, self.view.frame.size.width, 60)];
    }
    
    [warningLabel setText:NSLocalizedString(@"Your photo is being screened by Woo. We'll be done in a blink.",nil)];
    [warningLabel setFont:kVerifyingMessageTextFont];
    [warningLabel setTextColor:kHeaderTextRedColor];
    [warningLabel setNumberOfLines:2];
    [warningLabel setTextAlignment:NSTextAlignmentCenter];
    [warningLabel setHidden:YES];
    [self.view addSubview:warningLabel];
    
}

- (void)cancel:(id)sender {
    
    //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Cancels_Crop forScreenName:@"PR"];
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(VPImageCropperDelegate)]) {
        [self.delegate imageCropperDidCancel:self];
    }
}

- (void)confirm:(id)sender {
    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"CropPhoto" forScreenName:@"MyPhotos"];
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.alpha = 1.0;
    activityIndicator.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    activityIndicator.hidesWhenStopped = NO;
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.color = [UIColor whiteColor];
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
    
    [confirmBtn setEnabled:NO];
    [cancelBtn setEnabled:NO];
    
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(VPImageCropperDelegate)]) {
        [self.delegate imageCropper:self didFinished:[self getSubImageData]];
    }
    
}

- (void)overlayClipping
{
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    // Left side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(0, 0,
                                        self.ratioView.frame.origin.x,
                                        self.overlayView.frame.size.height));
    // Right side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(
                                        self.ratioView.frame.origin.x + self.ratioView.frame.size.width,
                                        0,
                                        self.overlayView.frame.size.width - self.ratioView.frame.origin.x - self.ratioView.frame.size.width,
                                        self.overlayView.frame.size.height));
    // Top side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(0, 0,
                                        self.overlayView.frame.size.width,
                                        self.ratioView.frame.origin.y));
    // Bottom side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(0,
                                        self.ratioView.frame.origin.y + self.ratioView.frame.size.height,
                                        self.overlayView.frame.size.width,
                                        self.overlayView.frame.size.height - self.ratioView.frame.origin.y + self.ratioView.frame.size.height));
    maskLayer.path = path;
    self.overlayView.layer.mask = maskLayer;
    CGPathRelease(path);
}

// register all gestures
- (void) addGestureRecognizers
{
    // add pinch gesture
    pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [self.view addGestureRecognizer:pinchGestureRecognizer];
    
    // add pan gesture
    panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [self.view addGestureRecognizer:panGestureRecognizer];
}

// pinch gesture handler
- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    UIView *view = self.showImgView;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        pinchGestureRecognizer.scale = 1;
    }
    else if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGRect newFrame = self.showImgView.frame;
        newFrame = [self handleScaleOverflow:newFrame];
        newFrame = [self handleBorderOverflow:newFrame];
        [UIView animateWithDuration:BOUNDCE_DURATION animations:^{
            self.showImgView.frame = newFrame;
            self.latestFrame = newFrame;
        }];
    }
}

// pan gesture handler

- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    
    
    UIView *view = self.showImgView;
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        // calculate accelerator
        
        //        CGFloat absCenterX = self.cropFrame.origin.x + self.cropFrame.size.width / 2;
        //        CGFloat absCenterY = self.cropFrame.origin.y + self.cropFrame.size.height / 2;
        //        CGFloat scaleRatio = self.showImgView.frame.size.width / self.cropFrame.size.width;
        CGFloat acceleratorX = 1;// - ABS(absCenterX - view.center.x) / (scaleRatio * absCenterX);
        CGFloat acceleratorY = 1;// - ABS(absCenterY - view.center.y) / (scaleRatio * absCenterY);
        
        
        //        Calculation of accelrators removed by Vaibhav Gautam
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        
        
        [view setCenter:(CGPoint){view.center.x + translation.x * acceleratorX, view.center.y + translation.y * acceleratorY}];
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }
    else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        // bounce to original frame
        CGRect newFrame = self.showImgView.frame;
        newFrame = [self handleBorderOverflow:newFrame];
        [UIView animateWithDuration:BOUNDCE_DURATION animations:^{
            self.showImgView.frame = newFrame;
            self.latestFrame = newFrame;
        }];
    }
}

- (CGRect)handleScaleOverflow:(CGRect)newFrame {
    // bounce to original frame
    CGPoint oriCenter = CGPointMake(newFrame.origin.x + newFrame.size.width/2, newFrame.origin.y + newFrame.size.height/2);
    if (newFrame.size.width < self.oldFrame.size.width) {
        newFrame = self.oldFrame;
    }
    if (newFrame.size.width > self.largeFrame.size.width) {
        newFrame = self.largeFrame;
    }
    newFrame.origin.x = oriCenter.x - newFrame.size.width/2;
    newFrame.origin.y = oriCenter.y - newFrame.size.height/2;
    return newFrame;
}

- (CGRect)handleBorderOverflow:(CGRect)newFrame {
    // horizontally
    
    
    NSLog(@"CGRectGetMaxX = %f",CGRectGetMaxX(newFrame));
    
    if (newFrame.origin.x > self.cropFrame.origin.x)
        newFrame.origin.x = self.cropFrame.origin.x;
    //    if (CGRectGetMaxX(newFrame) < self.cropFrame.size.width)
    if (CGRectGetMaxX(newFrame) < self.cropFrame.origin.x + self.cropFrame.size.width)
        newFrame.origin.x = self.cropFrame.origin.x + self.cropFrame.size.width - newFrame.size.width;
    // vertically
    if (newFrame.origin.y > self.cropFrame.origin.y)
        newFrame.origin.y = self.cropFrame.origin.y;
    if (CGRectGetMaxY(newFrame) < self.cropFrame.origin.y + self.cropFrame.size.height) {
        newFrame.origin.y = self.cropFrame.origin.y + self.cropFrame.size.height - newFrame.size.height;
    }
    // adapt horizontally rectangle
    if (self.showImgView.frame.size.width > self.showImgView.frame.size.height && newFrame.size.height <= self.cropFrame.size.height) {
        newFrame.origin.y = self.cropFrame.origin.y + (self.cropFrame.size.height - newFrame.size.height) / 2;
    }
    return newFrame;
}

-(NSDictionary *)getSubImageData{
    CGRect squareFrame = self.cropFrame;
    CGFloat scaleRatio = self.latestFrame.size.width / self.originalImage.size.width;
    
    CGFloat x = (squareFrame.origin.x - self.latestFrame.origin.x) / scaleRatio;
    CGFloat y = (squareFrame.origin.y - self.latestFrame.origin.y) / scaleRatio;
    CGFloat w = squareFrame.size.width / scaleRatio;
    CGFloat h = squareFrame.size.height / scaleRatio;
    if (floor(self.latestFrame.size.width) < floor(self.cropFrame.size.width)) {
        CGFloat newW = self.originalImage.size.width;
        CGFloat newH = newW * (self.cropFrame.size.height / self.cropFrame.size.width);
        x = 0; y = y + (h - newH) / 2;
        w = newH; h = newH;
    }
    if (floor(self.latestFrame.size.height) < floor(self.cropFrame.size.height)) {
        CGFloat newH = self.originalImage.size.height;
        CGFloat newW = newH * (self.cropFrame.size.width / self.cropFrame.size.height);
        x = x + (w - newW) / 2; y = 0;
        w = newH; h = newH;
    }
    CGRect myImageRect = CGRectMake(x, y, w, h);
    CGImageRef imageRef = self.originalImage.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, myImageRect);
    CGSize size;
    size.width = myImageRect.size.width;
    size.height = myImageRect.size.height;
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, myImageRect, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    CGImageRelease(subImageRef);
    UIGraphicsEndImageContext();
    
    if (x<0) {
        x = 0;
    }
    if (y<0) {
        y = 0;
    }
    NSDictionary *imageDataDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   smallImage,@"imageObj",
                                   [NSNumber numberWithDouble:floor(x)], @"croppingStartingX",
                                   [NSNumber numberWithDouble:floor(y)], @"croppingStartingY",
                                   [NSNumber numberWithDouble:floor(w)], @"croppingWidth",
                                   [NSNumber numberWithDouble:floor(h)], @"croppingHeight",
                                   nil];
    
    
    return imageDataDict;
}

- (UIImage *)fixOrientation:(UIImage *)srcImg {
    
    if (srcImg.imageOrientation == UIImageOrientationUp)
        return srcImg;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (srcImg.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (srcImg.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, srcImg.size.width, srcImg.size.height,
                                             CGImageGetBitsPerComponent(srcImg.CGImage), 0,
                                             CGImageGetColorSpace(srcImg.CGImage),
                                             CGImageGetBitmapInfo(srcImg.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (srcImg.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.height,srcImg.size.width), srcImg.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.width,srcImg.size.height), srcImg.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

-(void) createGridForCropView{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(SCREEN_WIDTH*0.33, _cropFrame.origin.y)];
    [path addLineToPoint:CGPointMake(SCREEN_WIDTH*0.33, _cropFrame.origin.y + _cropFrame.size.height)];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor yellowColor] CGColor];
    shapeLayer.lineWidth = 1.0;
    shapeLayer.fillColor = [[UIColor yellowColor] CGColor];
    
    [self.view.layer addSublayer:shapeLayer];
    
    
    [path moveToPoint:CGPointMake(SCREEN_WIDTH*0.66, _cropFrame.origin.y)];
    [path addLineToPoint:CGPointMake(SCREEN_WIDTH*0.66, _cropFrame.origin.y + _cropFrame.size.height)];
    
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor yellowColor] CGColor];
    shapeLayer.lineWidth = 1.0;
    shapeLayer.fillColor = [[UIColor yellowColor] CGColor];
    
    
    CGFloat lineHeight = _cropFrame.origin.y + _cropFrame.size.height*0.33;
    [path moveToPoint:CGPointMake(0, lineHeight)];
    [path addLineToPoint:CGPointMake(SCREEN_WIDTH, lineHeight)];
    
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor yellowColor] CGColor];
    shapeLayer.lineWidth = 1.0;
    shapeLayer.fillColor = [[UIColor yellowColor] CGColor];
    
    
    lineHeight = _cropFrame.origin.y + _cropFrame.size.height*0.66;
    [path moveToPoint:CGPointMake(0, lineHeight)];
    [path addLineToPoint:CGPointMake(SCREEN_WIDTH, lineHeight)];
    
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor yellowColor] CGColor];
    shapeLayer.lineWidth = 1.0;
    shapeLayer.fillColor = [[UIColor yellowColor] CGColor];
}


-(void) createCornerForCropView{
    
    UIColor *color = [UIColor colorWithRed:224.0/255.0 green:65.0/255.0 blue:72.0/255.0 alpha:1.0];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:CGPointMake(0.0, _cropFrame.origin.y)];
    [path addLineToPoint:CGPointMake(16.0, _cropFrame.origin.y)];
    
    [path moveToPoint:CGPointMake(SCREEN_WIDTH*0.5 - 16, _cropFrame.origin.y)];
    [path addLineToPoint:CGPointMake(SCREEN_WIDTH*0.5 + 16, _cropFrame.origin.y)];
    
    [path moveToPoint:CGPointMake(SCREEN_WIDTH - 16.0, _cropFrame.origin.y)];
    [path addLineToPoint:CGPointMake(SCREEN_WIDTH, _cropFrame.origin.y)];
    
    //>>>>>>>>>>
    [path moveToPoint:CGPointMake(SCREEN_WIDTH -2, _cropFrame.origin.y)];
    [path addLineToPoint:CGPointMake(SCREEN_WIDTH-2, _cropFrame.origin.y + 16)];
    
    [path moveToPoint:CGPointMake(SCREEN_WIDTH-2, _cropFrame.origin.y + _cropFrame.size.height*0.5 - 8)];
    [path addLineToPoint:CGPointMake(SCREEN_WIDTH-2, _cropFrame.origin.y + _cropFrame.size.height*0.5 + 8)];
    
    [path moveToPoint:CGPointMake(SCREEN_WIDTH-2, _cropFrame.origin.y + _cropFrame.size.height - 16)];
    [path addLineToPoint:CGPointMake(SCREEN_WIDTH-2, _cropFrame.origin.y + _cropFrame.size.height)];
    
    //>>>>>>>>>>
    [path moveToPoint:CGPointMake(SCREEN_WIDTH, _cropFrame.origin.y + _cropFrame.size.height)];
    [path addLineToPoint:CGPointMake(SCREEN_WIDTH - 16, _cropFrame.origin.y + _cropFrame.size.height)];
    
    [path moveToPoint:CGPointMake(SCREEN_WIDTH*0.5 + 16, _cropFrame.origin.y + _cropFrame.size.height)];
    [path addLineToPoint:CGPointMake(SCREEN_WIDTH*0.5 - 16, _cropFrame.origin.y + _cropFrame.size.height)];
    
    [path moveToPoint:CGPointMake(16, _cropFrame.origin.y + _cropFrame.size.height)];
    [path addLineToPoint:CGPointMake(0, _cropFrame.origin.y + _cropFrame.size.height)];
    
    //>>>>>>>>
    [path moveToPoint:CGPointMake(2, _cropFrame.origin.y)];
    [path addLineToPoint:CGPointMake(2, _cropFrame.origin.y + 16)];
    
    [path moveToPoint:CGPointMake(2, _cropFrame.origin.y + _cropFrame.size.height*0.5 - 8)];
    [path addLineToPoint:CGPointMake(2, _cropFrame.origin.y + _cropFrame.size.height*0.5 + 8)];
    
    [path moveToPoint:CGPointMake(2, _cropFrame.origin.y + _cropFrame.size.height - 16)];
    [path addLineToPoint:CGPointMake(2, _cropFrame.origin.y + _cropFrame.size.height)];
    
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [color CGColor];
    shapeLayer.lineWidth = 4.0;
    shapeLayer.fillColor = [color CGColor];
    
    [self.view.layer addSublayer:shapeLayer];
}

#pragma mark - Woo Loader
- (void)showWooLoader{
    int subtractor = 0;
    if (SYSTEM_VERSION_LESS_THAN(@"9.0")) {
        subtractor = 0;
    }else{
        subtractor = 60;
    }
    
    customLoader = [[WooLoader alloc]initWithFrame:CGRectMake((SCREEN_WIDTH- subtractor)/2, (SCREEN_HEIGHT)/2, 60, 60)];
    [customLoader startAnimationOnView:self.view  WithBackGround:YES];
    [self.view setUserInteractionEnabled:NO];
}

-(void)removeWooLoader{
    [self.view setUserInteractionEnabled:YES];
    [customLoader removeFromSuperview];
    customLoader = nil;
}

#pragma mark imageCheck Method
- (BOOL)isEqualImage:(UIImage *)firstImage second:(UIImage *)secondImage{
    NSData *firstImageData = UIImagePNGRepresentation(firstImage);
    NSData *secondImageData = UIImagePNGRepresentation(secondImage);
    return [firstImageData isEqualToData:secondImageData];
}

@end
