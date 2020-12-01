
//
//  ImageSelectionViewController.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 15/06/15.
//  Copyright (c) 2015 Woo. All rights reserved.
//

#import "ImageSelectionViewController.h"
#import "VPImageCropperViewController.h"
#import "ToastTypeInfoView.h"
#import "ImageAPIClass.h"
#import "ImageGalleryController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
//#import <SDWebImage/SDWebImageManager.h>

#define kActionSheetClickPicture    @"kActionSheetClickPicture"
#define kActionSheetPickFB          @"kActionSheetPickFB"
#define kActionSheetPickPhoneAlbum  @"kActionSheetPickPhoneAlbum"
#define kActionSheetSetProfilePic   @"kActionSheetSetProfilePic"
#define kActionSheetReplacePic      @"kActionSheetReplacePic"
#define kActionSheetCropPic         @"kActionSheetCropPic"
#define kActionSheetDeletePic       @"kActionSheetDeletePic"

#define kPhotoApproved  @"APPROVED"
#define kPhotoPending   @"PENDING"
#define kPhotoRejected  @"REJECTED"

#define kPhotoNoneTag       0
#define kPhotoApprovedTag   1
#define kPhotoPendingTag    2
#define kPhotoRejectedTag   3

typedef enum photoUploadType{
    PhotoUploadFacebook,
    PhotoUploadSelfie,
    PhotoUploadPhoneAlbum
}PhotoUploadType;

@interface ImageSelectionViewController ()<UINavigationControllerDelegate, VPImageCropperDelegate>
{
    UIButton *currentFocusedButton;
    PhotoUploadType currentUploadType;
    
//    BOOL firstImageApprovedSeen;
//    BOOL secondImageApprovedSeen;
//    BOOL thirdImageApprovedSeen;
    
    NSMutableArray *approvedImageArray;
}
@end

@implementation ImageSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //Initialise the view
    [self initialiseView];
    
    //Fetch imageList from Server
    [ImageAPIClass fetchUserImagesWithCompletionBlock:^(id response, BOOL success , int statusCode) {
        if (success)
        {
            imagesArray = [self rearrangeImagesArray:(NSMutableArray *)response];
            if ([imagesArray count]<1) {
                doneButtonObj.enabled = FALSE;
            }
            
            [self updateImagesOnScreen];
            NSLog(@"response > %@",response);
        }
    }];
    
    approvedImageArray = [[NSMutableArray alloc] init];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"approvedImageArray"]) {
        approvedImageArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"approvedImageArray"] mutableCopy];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(internetConnectionStatusChanged:)
                                                 name:kInternetConnectionStatusChanged object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    for (NSString *objectId in [approvedImageArray mutableCopy]) {
        BOOL flag = NO;
        for (NSDictionary *dict in imagesArray) {
            if ([[dict valueForKey:kProfilePicObjectId] isEqual:objectId]) {
                flag = YES;
                break;
            }
        }
        if (!flag) {
            [approvedImageArray removeObject:objectId];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:approvedImageArray forKey:@"approvedImageArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initialiseView{
    
    [navbar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    navbar.barTintColor = [UIColor whiteColor];
    
    doneButtonObj = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil)
                                                     style:UIBarButtonItemStyleDone
                                                    target:self
                                                    action:@selector(doneButtonTapped:)];
    [doneButtonObj setTintColor:kHeaderTextRedColor];
    UINavigationItem* navItem = (UINavigationItem*)[navbar.items firstObject];
    navItem.rightBarButtonItem = doneButtonObj;
    navItem.rightBarButtonItem.enabled = YES;
    //Add Nav Label to Navigation Bar
    UILabel *navBarLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
    navBarLabel.text = NSLocalizedString(@"Your photo", nil);
    navBarLabel.textColor = kHeaderTextRedColor;
    [navBarLabel setFont:kHeaderTextFont];
    [navBarLabel setBackgroundColor:[UIColor clearColor]];
    [navBarLabel sizeToFit];
    [navItem setTitleView:navBarLabel];
    
    imageStatusContainer.layer.cornerRadius = 5;
    imageStatusContainer.layer.masksToBounds = YES;
    
    mainPic.layer.cornerRadius = 5;
    mainPic.layer.masksToBounds = YES;
    mainPic.layer.borderColor = kVeryLightGrayColor.CGColor;
    mainPic.layer.borderWidth = 1.0f;
    
    firstAdditionalPic.layer.cornerRadius = 5;
    firstAdditionalPic.layer.masksToBounds = YES;
    firstAdditionalPic.layer.borderColor = kVeryLightGrayColor.CGColor;
    firstAdditionalPic.layer.borderWidth = 1.0f;
    
    secondAdditionalPic.layer.cornerRadius = 5;
    secondAdditionalPic.layer.masksToBounds = YES;
    secondAdditionalPic.layer.borderColor = kVeryLightGrayColor.CGColor;
    secondAdditionalPic.layer.borderWidth = 1.0f;
    
    thirdAdditionalPic.layer.cornerRadius = 5;
    thirdAdditionalPic.layer.masksToBounds = YES;
    thirdAdditionalPic.layer.borderColor = kVeryLightGrayColor.CGColor;
    thirdAdditionalPic.layer.borderWidth = 1.0f;
    
    
    [mainPic.imageView setContentMode:UIViewContentModeScaleAspectFill];
    [firstAdditionalPic.imageView setContentMode:UIViewContentModeScaleAspectFill];
    [secondAdditionalPic.imageView setContentMode:UIViewContentModeScaleAspectFill];
    [thirdAdditionalPic.imageView setContentMode:UIViewContentModeScaleAspectFill];
    
    [firstAdditionalPic addTarget:self action:@selector(secondaryImageButtonTapped:)
                 forControlEvents:UIControlEventTouchUpInside];
    
    [secondAdditionalPic addTarget:self action:@selector(secondaryImageButtonTapped:)
                  forControlEvents:UIControlEventTouchUpInside];
    
    [thirdAdditionalPic addTarget:self action:@selector(secondaryImageButtonTapped:)
                 forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)updateImagesOnScreen{
    
    int imagesSet = 0;
    
    for (NSDictionary *imageDict in imagesArray) {
        if ([imageDict objectForKey:kProfilePicKey] && [[imageDict objectForKey:kProfilePicKey] boolValue]) {
            
            NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(SCREEN_WIDTH),IMAGE_SIZE_FOR_POINTS(SCREEN_WIDTH*0.79),[APP_Utilities encodeFromPercentEscapeString:[imageDict objectForKey:kProfilePicURLKey]]]];
            
            [mainPic setSelected:YES];
            [mainPic sd_setImageWithURL:imageURL forState:UIControlStateSelected
                       placeholderImage:[UIImage imageNamed:(self.isMale?@"placeholder_male":@"placeholder_female")]
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                  [mainPic setImage:image forState:UIControlStateHighlighted];
                                  [mainPic setImage:image forState:UIControlStateNormal];
                                  [self setImageStatus:imageDict ForImage:mainPic];
                              }];
            continue;
        }
        
        switch (imagesSet) {
            case 0:
            {
                NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(SCREEN_WIDTH),IMAGE_SIZE_FOR_POINTS(SCREEN_WIDTH*0.79),[APP_Utilities encodeFromPercentEscapeString:[imageDict objectForKey:kProfilePicURLKey]]]];
                
                [firstAdditionalPic setSelected:YES];
                [firstAdditionalPic sd_setImageWithURL:imageURL forState:UIControlStateSelected
                                      placeholderImage:[UIImage imageNamed:(self.isMale?@"placeholder_male":@"placeholder_female")]
                                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                 [firstAdditionalPic setImage:image forState:UIControlStateHighlighted];
                                                 [firstAdditionalPic setImage:image forState:UIControlStateNormal];
                                                 [self setImageStatus:imageDict ForImage:firstAdditionalPic];
                                             }];
                
                imagesSet++;
            }
                break;
            case 1:
            {
                NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(SCREEN_WIDTH),IMAGE_SIZE_FOR_POINTS(SCREEN_WIDTH*0.79),[APP_Utilities encodeFromPercentEscapeString:[imageDict objectForKey:kProfilePicURLKey]]]];
                [secondAdditionalPic setSelected:YES];
                [secondAdditionalPic sd_setImageWithURL:imageURL forState:UIControlStateSelected
                                       placeholderImage:[UIImage imageNamed:(self.isMale?@"placeholder_male":@"placeholder_female")]
                                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                  [secondAdditionalPic setImage:image forState:UIControlStateHighlighted];
                                                  [secondAdditionalPic setImage:image forState:UIControlStateNormal];
                                                  [self setImageStatus:imageDict ForImage:secondAdditionalPic];
                                              }];
                
                imagesSet++;
            }
                break;
            case 2:
            {
                NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(SCREEN_WIDTH),IMAGE_SIZE_FOR_POINTS(SCREEN_WIDTH*0.79),[APP_Utilities encodeFromPercentEscapeString:[imageDict objectForKey:kProfilePicURLKey]]]];
                [thirdAdditionalPic setSelected:YES];
                [thirdAdditionalPic sd_setImageWithURL:imageURL forState:UIControlStateSelected
                                      placeholderImage:[UIImage imageNamed:(self.isMale?@"placeholder_male":@"placeholder_female")]
                                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                 [thirdAdditionalPic setImage:image forState:UIControlStateHighlighted];
                                                 [thirdAdditionalPic setImage:image forState:UIControlStateNormal];
                                                 [self setImageStatus:imageDict ForImage:thirdAdditionalPic];
                                             }];
                imagesSet++;
            }
                break;
            default:
                break;
        }
    }

    [self checkForUnselectedImages];
    
    if ([imagesArray count] < 1) {
        imageInfoLabel.text = NSLocalizedString(@"image_upload_text_5", nil);
        return;
    }
    BOOL flag =NO;
    for (NSDictionary* dict in imagesArray) {
        if ([[dict objectForKey:kProfilePicKey] boolValue] && ([[dict valueForKey:kPhotoStatus] isEqualToString:kPhotoRejected] ||
                                                   [[dict valueForKey:kPhotoStatus] isEqualToString:kPhotoPending])) {
            imageInfoLabel.text = NSLocalizedString(@"image_upload_text_6", nil);
            flag = TRUE;
            break;
        }
        if ([[dict valueForKey:kPhotoStatus] isEqualToString:kPhotoRejected]) {
            imageInfoLabel.text = NSLocalizedString(@"image_upload_text_3", nil);
            flag = TRUE;
            break;
        }
        else if ([[dict valueForKey:kPhotoStatus] isEqualToString:kPhotoPending]){
            imageInfoLabel.text = NSLocalizedString(@"image_upload_text_4", nil);
            flag = TRUE;
            break;
        }
    }
    if (!flag) {
        if ([imagesArray count] >= 4) {
            imageInfoLabel.text = NSLocalizedString(@"image_upload_text_1", nil);
        }
        else{
            imageInfoLabel.text = NSLocalizedString(@"image_upload_text_2", nil);
        }
    }
}

-(void)checkForUnselectedImages{
    
    NSArray *buttonArray = [NSArray arrayWithObjects:firstAdditionalPic,
                            secondAdditionalPic,
                            thirdAdditionalPic, nil];
    NSInteger imageCount = [imagesArray count];
    
    int imageOffset =0;
    if (mainPic.selected) {
        imageOffset = 1;
    }
    for (NSInteger counter = buttonArray.count-1; counter >= 0; counter--) {
        if ((counter + imageOffset + 1) == imageCount) {
            return;
        }   
        
        UIButton *button = [buttonArray objectAtIndex:counter];
        [button setImage:nil forState:UIControlStateHighlighted];
        [button setImage:[UIImage imageNamed:@"addImage"] forState:UIControlStateNormal];
        [button setSelected:NO];
        NSLog(@"%lu>>>>>>>>",(unsigned long)button.subviews.count);
        if (button.subviews.count>1) {
            [[[button subviews] lastObject] removeFromSuperview];
        }
    }
}

-(void)setImageStatus:(NSDictionary*)imageDict ForImage:(UIButton*)button{
    
    if(button.subviews.count > 1){
        [[button.subviews lastObject] removeFromSuperview];
    }
    
    NSString *status = [imageDict valueForKey:kPhotoStatus];
    UIImageView *statusImage = nil;
    if ( [status caseInsensitiveCompare:kPhotoApproved] == NSOrderedSame) {
        
        if([approvedImageArray containsObject:[imageDict valueForKey:kProfilePicObjectId]]){
            return;
        }
        else{
            [approvedImageArray addObject:[imageDict valueForKey:kProfilePicObjectId]];
        }
        
        statusImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_upload_photo_approved"]];
        statusImage.tag = kPhotoApprovedTag;
    }
    else if ( [status caseInsensitiveCompare:kPhotoPending] == NSOrderedSame) {
        statusImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_upload_photo_pending"]];
        statusImage.tag = kPhotoPendingTag;
    }
    else{
        statusImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_upload_photo_rejected"]];
        statusImage.tag = kPhotoRejectedTag;
    }
    statusImage.frame = CGRectMake(2, button.frame.size.height - statusImage.frame.size.height - 2,
                                   statusImage.frame.size.width,
                                   statusImage.frame.size.height);
//    if (([button isEqual:mainPic] && !([status caseInsensitiveCompare:kPhotoApproved] == NSOrderedSame)) ||
//        ![button isEqual:mainPic])
//    {
        [button addSubview:statusImage];
//    }
}


-(NSMutableArray *)rearrangeImagesArray:(NSArray *)arrayToBeReordered{
    
    NSMutableArray *orderedArray = [[NSMutableArray alloc]init];
    
    for (NSDictionary *imageDict in arrayToBeReordered) {
        if ([imageDict objectForKey:kProfilePicKey] && [[imageDict objectForKey:kProfilePicKey] boolValue]) {
            [orderedArray addObject:imageDict];
        }
    }
    
    for (NSDictionary *imageDict in arrayToBeReordered) {
        if (![imageDict objectForKey:kProfilePicKey] || [[imageDict objectForKey:kProfilePicKey] boolValue] == false) {
            [orderedArray addObject:imageDict];
        }
    }
    
    return orderedArray;
}

-(void)showImageCropperWithData:(NSMutableDictionary *)imageData{
    
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    if (!reachability.reachable) {
        return;
    }
    backgroundView = [[UIView alloc]initWithFrame:APP_DELEGATE.window.frame];
    [backgroundView setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f]];
    
    
    progressViewObj = [[UAProgressView alloc]initWithFrame:CGRectMake(((APP_DELEGATE.window.frame.size.width/2)-25),
                                                                      ((APP_DELEGATE.window.frame.size.height/2)-25),
                                                                      50, 50)];
    
    [progressViewObj setTintColor:[UIColor whiteColor]];
    UIButton *stopButton = [[UIButton alloc] initWithFrame:CGRectInset(progressViewObj.bounds, progressViewObj.bounds.size.width / 3.0, progressViewObj.bounds.size.height / 3.0)];
    stopButton.backgroundColor = [UIColor whiteColor];
    stopButton.userInteractionEnabled = YES; // Allows tap to pass through to the progress view.
    [stopButton addTarget:self action:@selector(stopButtonTappedOnProgressView) forControlEvents:UIControlEventTouchUpInside];
    progressViewObj.centralView = stopButton;
    
    [backgroundView addSubview:progressViewObj];
    
    [[[[UIApplication sharedApplication] windows] objectAtIndex:0] addSubview:backgroundView];
    
    NSString *imageUrl = nil;
    
    if ([[imageData allKeys] containsObject:@"imageURL"]) {
        imageUrl = [imageData objectForKey:@"imageURL"];
    }
    else if ([[imageData allKeys] containsObject:@"srcBig"]){
        imageUrl = [imageData objectForKey:@"srcBig"];
    }
    
    lastImageDownlodedForCropping = [NSURL URLWithString:imageUrl];
    
    
    [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:imageUrl]
                                                        options:0
                                                       progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL)
     {
         if (expectedSize>0) {
             [progressViewObj setProgress:(float)((1.0f*receivedSize)/(1.0f*expectedSize)) animated:YES];
         }
     }
                                                      completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished)
     {

         if (error) {
             
             [backgroundView removeFromSuperview];
             [progressViewObj removeFromSuperview];
         }
         if (image && finished)
         {
             [backgroundView removeFromSuperview];
             [progressViewObj removeFromSuperview];
             
             CGFloat imageWidth = SCREEN_WIDTH;
             CGFloat imageHeight = SCREEN_WIDTH * 0.7968;
             
             VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:image cropFrame:CGRectMake(0,((SCREEN_HEIGHT/2)-(imageHeight/2)), imageWidth, imageHeight) limitScaleRatio:3.0];
             
             imgCropperVC.delegate = self;
             [imgCropperVC setAdditionalData:imageData];
             [imgCropperVC setAlbumData:selectedAlbumDetail];
             [self presentViewController:imgCropperVC animated:YES completion:^{
                 // TO DO
             }];
             [backgroundView removeFromSuperview];
         }
     }];
}

-(void)stopButtonTappedOnProgressView{
    [backgroundView removeFromSuperview];
    //[[SDWebImageDownloader sharedDownloader] removeCallbacksForURL:lastImageDownlodedForCropping];
}

-(void)presentCroppingView:(UIImage *)imageObj andImageURL:(NSString *)imageUrl{
    
    CGFloat imageWidth = SCREEN_WIDTH;
    CGFloat imageHeight = SCREEN_WIDTH * 0.7968;
    
    VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:imageObj cropFrame:CGRectMake(0,((SCREEN_HEIGHT/2)-(imageHeight/2)), imageWidth, imageHeight) limitScaleRatio:3.0];
    imgCropperVC.delegate = self;
    NSMutableDictionary *imageDict = [[NSMutableDictionary alloc] initWithDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:imageUrl,@"imageURL",@"-1",@"isFakePhoto",nil]];
  //@{@"imageURL":imageUrl,@"isFakePhoto":@"-1"}];
    [imgCropperVC setAdditionalData:imageDict];
    [imgCropperVC setAlbumData:selectedAlbumDetail];
    [self presentViewController:imgCropperVC animated:YES completion:^{
        // TO DO
    }];
    
}

-(void)showActionsheetWithElementArray:(NSArray*) elementArray{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        UIAlertController *reportAlertcontroller =
        [UIAlertController alertControllerWithTitle:nil
                                            message:nil
                                     preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancelAction =
        [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil)
                                 style:UIAlertActionStyleCancel
                               handler:^(UIAlertAction *action) { NSLog(@"Cancel tapped"); }];
        [reportAlertcontroller addAction:cancelAction];
        
        for (NSString* elementText in elementArray) {
            UIAlertAction *alertAction =
            [UIAlertAction actionWithTitle:NSLocalizedString(elementText,nil)
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) {
                                       [self handleActionSheetEventForElement:elementText];
                                   }];
            [reportAlertcontroller addAction:alertAction];
        }
        
        [reportAlertcontroller.view setTintColor:kHeaderTextRedColor];
        [self presentViewController:reportAlertcontroller animated:YES completion:^{
            [reportAlertcontroller.view setTintColor:kHeaderTextRedColor];
        }];
    }
    else{
        UIActionSheet *reportActionSheet = nil;
        switch (elementArray.count) {
            case 1:
                reportActionSheet =
                [[UIActionSheet alloc]initWithTitle:nil delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
                             destructiveButtonTitle:nil
                                  otherButtonTitles:elementArray[0], nil];
                break;
            case 2:
                reportActionSheet =
                [[UIActionSheet alloc]initWithTitle:nil delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
                             destructiveButtonTitle:nil
                                  otherButtonTitles:elementArray[0],elementArray[1], nil];
                break;
            case 3:
                reportActionSheet =
                [[UIActionSheet alloc]initWithTitle:nil delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
                             destructiveButtonTitle:nil
                                  otherButtonTitles:elementArray[0],elementArray[1],elementArray[2], nil];
                break;
            default:
                break;
        }
        
        [reportActionSheet showInView:self.view];
    }
}

-(void)handleActionSheetEventForElement:(NSString*)elementText{
    if ([elementText isEqualToString:NSLocalizedString(kActionSheetClickPicture, nil)]) {
        [APP_DELEGATE sendSwrveEventWithEvent:@"EditProfile.TakeSelfie" andScreen:@"EditProfile"];
        [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"TakeSelfie" forScreenName:@"EditProfile"];
        currentUploadType = PhotoUploadSelfie;
        [self presentDeviceCameraForUser];
    }
    else if([elementText isEqualToString:NSLocalizedString(kActionSheetPickFB, nil)]){
        [APP_DELEGATE sendSwrveEventWithEvent:@"EditProfile.PickFromFacebook" andScreen:@"EditProfile"];
        [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"PickFromFacebook" forScreenName:@"EditProfile"];
        currentUploadType = PhotoUploadFacebook;
        [self showFacebookAlbumView];
    }
    else if([elementText isEqualToString:NSLocalizedString(kActionSheetPickPhoneAlbum, nil)]){
        [APP_DELEGATE sendSwrveEventWithEvent:@"EditProfile.PickFromPhone" andScreen:@"EditProfile"];
        [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"PickFromPhone" forScreenName:@"EditProfile"];
        currentUploadType = PhotoUploadPhoneAlbum;
        [self showPhoneAlbum];
    }
    else if([elementText isEqualToString:NSLocalizedString(kActionSheetSetProfilePic, nil)]){
        [APP_DELEGATE sendSwrveEventWithEvent:@"EditProfile.SetAsProfilePicture" andScreen:@"EditProfile"];
        [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"SetAsProfilePicture" forScreenName:@"EditProfile"];
        
        AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
        if (!reachability.reachable) {
            SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"Please check your internet connection",nil));
            return ;
        }
        
        [self setAsProfilePicture];
    }
    else if([elementText isEqualToString:NSLocalizedString(kActionSheetReplacePic, nil)]){
        [APP_DELEGATE sendSwrveEventWithEvent:@"EditProfile.ReplacePicture" andScreen:@"EditProfile"];
        [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"ReplacePicture" forScreenName:@"EditProfile"];
        [self showActionSheetForEmptyImageBox];
    }
    else if([elementText isEqualToString:NSLocalizedString(kActionSheetCropPic, nil)]){
        [APP_DELEGATE sendSwrveEventWithEvent:@"EditProfile.CropPicture" andScreen:@"EditProfile"];
        [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"CropPicture" forScreenName:@"EditProfile"];
        [self cropPicture];
    }
    else if([elementText isEqualToString:NSLocalizedString(kActionSheetDeletePic, nil)]){
        [APP_DELEGATE sendSwrveEventWithEvent:@"EditProfile.DeletePicture" andScreen:@"EditProfile"];
        [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"DeletePicture" forScreenName:@"EditProfile"];
        [self deletePicture];
    }
}

-(void)showActionSheetForEmptyImageBox{
    NSMutableArray *elementArray = [[NSMutableArray alloc] init];
    if ([AppLaunchModel sharedInstance].cameraOption)     {
        [elementArray addObject:NSLocalizedString(kActionSheetClickPicture, nil)];
    }
    if ([AppLaunchModel sharedInstance].fbAlbumEnable)    {
        [elementArray addObject:NSLocalizedString(kActionSheetPickFB, nil)];
    }
    if ([AppLaunchModel sharedInstance].phoneAlbumEnable) {
        [elementArray addObject:NSLocalizedString(kActionSheetPickPhoneAlbum, nil)];
    }
    [self showActionsheetWithElementArray:elementArray];
}

#pragma mark - Facebook Gallery Methods

-(void)albumSelected:(NSDictionary *)albumDetails{
    selectedAlbumDetail = albumDetails;
    [self showSelectImageFromAlbum:[albumDetails objectForKey:@"id"]];
    
}

-(void)showPhotoSelectionView{
    
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    if (!reachability.isReachable || reachability.isReachableViaWiFi || reachability.isReachableViaWWAN) {
        NSMutableDictionary *modelDictionary = [[NSMutableDictionary alloc]init];
        NSLog(@"imagesArray :%@",imagesArray);
        NSLog(@"imagesArray count :%lu",(unsigned long)[imagesArray count]);
        for (NSMutableDictionary *dataDictionary in imagesArray) {
            if ([[dataDictionary objectForKey:@"isImageAvailable"] intValue] == 1) {
                modelDictionary = dataDictionary;
            }
        }
        
        if (photoSelectionObj &&[photoSelectionObj superview]) {
            [photoSelectionObj removeFromSuperview];
        }
        
        photoSelectionObj = [[PhotoSelectionView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [photoSelectionObj setDelegate:self];
        [photoSelectionObj setSelectorForImageTapped:@selector(showImageCropperWithData:)];
        
        [photoSelectionObj setUserDataDict:modelDictionary];
        [photoSelectionObj setSelectedImagesArray:imagesArray];
        [photoSelectionObj fetchDataFromWebServiceForUserID:[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue]];
        
        [[[UIApplication sharedApplication] keyWindow] addSubview:photoSelectionObj];
    }
    else{
        [APP_Utilities showNoInternetAvailableToast];
    }
}

-(void)showSelectImageFromAlbum:(NSString *)albumId{
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    if (!reachability.isReachable || reachability.isReachableViaWiFi || reachability.isReachableViaWWAN) {
        NSMutableDictionary *modelDictionary = [[NSMutableDictionary alloc]init];
        NSLog(@"imagesArray :%@",imagesArray);
        NSLog(@"imagesArray count :%lu",(unsigned long)[imagesArray count]);
        for (NSMutableDictionary *dataDictionary in imagesArray) {
            if ([[dataDictionary objectForKey:@"isImageAvailable"] intValue] == 1) {
                modelDictionary = dataDictionary;
            }
        }
        
        if (photoSelectionObj &&[photoSelectionObj superview]) {
            [photoSelectionObj removeFromSuperview];
        }
        
        photoSelectionObj = [[PhotoSelectionView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [photoSelectionObj setDelegate:self];
        [photoSelectionObj setSelectorForImageTapped:@selector(showImageCropperWithData:)];
        
        [photoSelectionObj setUserDataDict:modelDictionary];
        [photoSelectionObj setSelectedImagesArray:imagesArray];
        [photoSelectionObj fetchDataFromWebServiceForUserID:[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue]
                                           forFacebookAlbum:albumId];
        
        [[[UIApplication sharedApplication] keyWindow] addSubview:photoSelectionObj];
        [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"PhotoSelectDone" forScreenName:@"MyPhotos"];
    }
    else{
        [APP_Utilities showNoInternetAvailableToast];
    }
    
}

#pragma mark - ActionSheet Methods

-(void)showPhoneAlbum{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status == ALAuthorizationStatusNotDetermined) {
        U2AlertView *alert = [[U2AlertView alloc] init];
        
        [alert setU2AlertActionBlockForButton:^(int tagValue , id data){
            NSLog(@"%d",tagValue);
            
            if (tagValue == 1)
                [self accessConfirmationCallback:data];
        }];
        
        [alert setContainerData:imagePickerController];
        [alert alertWithHeaderText:NSLocalizedString(@"Photo Access",nil)
                       description:NSLocalizedString(@"\nAllow access to photos\n", nil)
                    leftButtonText:NSLocalizedString(@"No", nil)
                andRightButtonText:NSLocalizedString(@"Yes", nil)];
        [alert show];
    }
    else{
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

-(void)presentDeviceCameraForUser{
    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"TakeSelfie" forScreenName:@"MyPhotos"];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.videoQuality = UIImagePickerControllerQualityTypeLow;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusNotDetermined) {
        U2AlertView *alert = [[U2AlertView alloc] init];

        [alert setU2AlertActionBlockForButton:^(int tagValue , id data){
            NSLog(@"%d",tagValue);
            
            if (tagValue == 1)
                [self accessConfirmationCallback:data];
            }];

        [alert setContainerData:picker];
        [alert alertWithHeaderText:NSLocalizedString(@"Photo Access",nil)
                       description:NSLocalizedString(@"\nAllow camera access\n", nil)
                    leftButtonText:NSLocalizedString(@"No", nil)
                andRightButtonText:NSLocalizedString(@"Yes", nil)];
        [alert show];
    }
    else{
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

-(void)showFacebookAlbumView{
    
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    if (!reachability.reachable) {
        SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"Please check your internet connection",nil));
        return ;
    }
    
    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"PickFromFB" forScreenName:@"MyPhotos"];
    if (!albumSelectionViewObj) {
        CGRect rect = CGRectMake(0, 64.0, SCREEN_WIDTH, SCREEN_HEIGHT - 44.0);
        albumSelectionViewObj = [[AlbumSelectionView alloc] initWithFrame:rect];
    }
    [albumSelectionViewObj fetchAlbums];
    [albumSelectionViewObj setDelegate:self];
    [albumSelectionViewObj setSelectorForAlbumSelected:@selector(albumSelected:)];
    [self.view addSubview:albumSelectionViewObj];
    CGRect rect = CGRectMake(albumSelectionViewObj.containerView.frame.origin.x,
                             SCREEN_HEIGHT+ albumSelectionViewObj.frame.size.height/2,
                             albumSelectionViewObj.containerView.frame.size.width,
                             albumSelectionViewObj.containerView.frame.size.height);
    [albumSelectionViewObj.containerView setFrame:rect];
    [UIView animateWithDuration:0.5
                          delay:0.5
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         albumSelectionViewObj.containerView.center = albumSelectionViewObj.center ;
                     } 
                     completion:^(BOOL finished){
                         NSLog(@"Done!");
                     }];
}

-(void)setAsProfilePicture{
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    if (!reachability.reachable) {
        SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"Please check your internet connection",nil));
        return ;
    }
    
    if (mainPic.isSelected) {
        
        NSMutableDictionary* mainImageInfo = [((NSDictionary*)[imagesArray firstObject]) mutableCopy];
        [mainImageInfo setValue:@"0" forKey:kProfilePicKey];
        [imagesArray replaceObjectAtIndex:0 withObject:mainImageInfo];
        
        [imagesArray exchangeObjectAtIndex:0 withObjectAtIndex:selectedIndex];
        
        NSMutableDictionary* mainImageInfo2 = [((NSDictionary*)[imagesArray firstObject]) mutableCopy];
        [mainImageInfo2 setValue:@"1" forKey:kProfilePicKey];
        [imagesArray replaceObjectAtIndex:0 withObject:mainImageInfo2];
    }
    else{
        NSMutableDictionary* mainImageInfo = [((NSDictionary*)[imagesArray objectAtIndex:selectedIndex]) mutableCopy];
        [mainImageInfo setValue:@"1" forKey:kProfilePicKey];
        
        [imagesArray removeObjectAtIndex:selectedIndex];
        
        [imagesArray insertObject:mainImageInfo atIndex:0];
    }
    [self updateImagesOnScreen];
}

-(void)cropPicture{
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    if (!reachability.reachable) {
        SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"Please check your internet connection",nil));
        return ;
    }
    
    NSMutableDictionary *cropData = nil;
    if([currentFocusedButton isEqual:mainPic]){
        cropData = [[imagesArray objectAtIndex:0] mutableCopy];
    }
    else if ([currentFocusedButton isEqual:firstAdditionalPic]) {
        cropData = [[imagesArray objectAtIndex:1] mutableCopy];
    }
    else if ([currentFocusedButton isEqual:secondAdditionalPic]){
        cropData = [[imagesArray objectAtIndex:2] mutableCopy];
    }
    else{
        cropData = [[imagesArray objectAtIndex:3] mutableCopy];
    }
    [cropData setObject:@"0" forKey:@"isFakePhoto"];
    [self showImageCropperWithData:cropData];
}

-(void)deletePicture{
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    if (!reachability.reachable) {
        SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"Please check your internet connection",nil));
        return;
    }
    
    if ([currentFocusedButton isEqual:firstAdditionalPic]) {
        [imagesArray removeObjectAtIndex:1];
    }
    else if ([currentFocusedButton isEqual:secondAdditionalPic]){
        [imagesArray removeObjectAtIndex:2];
    }
    else{
        [imagesArray removeObjectAtIndex:3];
    }
    [currentFocusedButton setSelected:NO];
    if (currentFocusedButton.subviews.count > 1) { // i.e. ImageStatus icon is showing
        [[[currentFocusedButton subviews] lastObject] removeFromSuperview];
    }
    [self updateImagesOnScreen];
}

#pragma mark - IBAction methods

- (IBAction)mainPicTapped:(id)sender {
    currentFocusedButton = mainPic;
    selectedIndex = 0;
    
    if ([imagesArray count] == 0) {
        [self showActionSheetForEmptyImageBox];
    }
    else{
        NSMutableArray *elementArray = [[NSMutableArray alloc] init];
        [elementArray addObject:NSLocalizedString(kActionSheetReplacePic, nil)];
        [elementArray addObject:NSLocalizedString(kActionSheetCropPic, nil)];
        
        [self showActionsheetWithElementArray:elementArray];
    }
}

- (IBAction)secondaryImageButtonTapped:(UIButton*)sender{
    
    currentFocusedButton = sender;
    if([currentFocusedButton isEqual:firstAdditionalPic]){
        selectedIndex = mainPic.selected?1:0;
    }
    else if([currentFocusedButton isEqual:secondAdditionalPic]){
        selectedIndex = mainPic.selected?2:1;
    }
    else{
        selectedIndex = mainPic.selected?3:2;
    }

    if (sender.selected) {
        NSInteger tagvalue = [[currentFocusedButton subviews] lastObject].tag;
        if (tagvalue == kPhotoRejectedTag){
            [self deletePicture];
            return;
        }
        NSMutableArray *elementArray = [[NSMutableArray alloc] init];
        if (tagvalue == kPhotoApprovedTag ||  tagvalue == kPhotoNoneTag) {
            [elementArray addObject:NSLocalizedString(kActionSheetSetProfilePic, nil)];
            [elementArray addObject:NSLocalizedString(kActionSheetReplacePic, nil)];
            [elementArray addObject:NSLocalizedString(kActionSheetCropPic, nil)];
        }
        else if (tagvalue == kPhotoPendingTag) {
            [elementArray addObject:NSLocalizedString(kActionSheetReplacePic, nil)];
        }

        [elementArray addObject:NSLocalizedString(kActionSheetDeletePic, nil)];
        
        [self showActionsheetWithElementArray:elementArray];
    }
    else{
        [self showActionSheetForEmptyImageBox];
    }
}

- (IBAction)doneButtonTapped:(id)sender {
    
    [APP_Utilities showActivityIndicator];
    
    [APP_DELEGATE sendSwrveEventWithEvent:@"EditProfile.PhotoDone" andScreen:@"EditProfile"];
    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"PhotoDone" forScreenName:@"EditProfile"];
    
    NSString* profilePicID = 0;
   // NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId];
    
    NSString *payloadString = @"";
    NSString *profilePicUrlStr = @"";
    
    NSMutableDictionary *imageDataToBeRemoved = nil;
    
    for (NSMutableDictionary *imageData in imagesArray) {
        if (![[imageData valueForKey:kPhotoStatus] isEqualToString:kPhotoRejected]) {
            NSMutableDictionary *newDataDict = [[NSMutableDictionary alloc]init];
            NSString *imageIdKey = nil;
            
            if ([[imageData allKeys] containsObject:@"imageID"]) {
                imageIdKey = @"imageID";
            }
            else if ([[imageData allKeys] containsObject:@"objectId"]){
                imageIdKey = @"objectId";
            }
            
            if([imageData objectForKey:imageIdKey]){
                [newDataDict setObject:[imageData objectForKey:imageIdKey]
                            forKey:kProfilePicObjectId];
            }
            if([imageData objectForKey:kBigImageSourceKey]){
                [newDataDict setObject:[imageData objectForKey:kBigImageSourceKey] forKey:kBigImageSourceKey];
            }
            if ([imageData objectForKey:kProfilePicKey]) {
                [newDataDict setObject:[imageData objectForKey:kProfilePicKey] forKey:kProfilePicKey];
            }
            if ([imageData objectForKey:kProfilePicKey] && [[imageData objectForKey:kProfilePicKey] boolValue]) {
                profilePicID = [imageData objectForKey:imageIdKey];
                profilePicUrlStr = [imageData objectForKey:kBigImageSourceKey];
            }
            if ([[imageData allKeys] containsObject:kPhotoStatus]) {
                [newDataDict setObject:[imageData objectForKey:kPhotoStatus] forKey:kPhotoStatus];
            }
            
            if ([payloadString length] < 1) {
                payloadString =[APP_Utilities convertDictionaryToString:newDataDict];
            }else{
                payloadString = [NSString stringWithFormat:@"%@,%@",payloadString,[APP_Utilities convertDictionaryToString:newDataDict]];
            }
        }
        else{
            if ([[imageData objectForKey:kProfilePicKey] boolValue]) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kWooProfilePicURL];
                [[NSUserDefaults standardUserDefaults] synchronize];
                profilePicUrlStr = nil;
                imageDataToBeRemoved = imageData;
            }
        }
    }
    
    if (imageDataToBeRemoved) {
        [imagesArray removeObject:imageDataToBeRemoved];
    }
    
    payloadString = [NSString stringWithFormat:@"[%@]",payloadString];
    
    BOOL status = [ImageAPIClass updateUserWooAlbumWithPayloadString:payloadString AndProfilePicId:profilePicID
                                    AndCompletionBlock:^(id response, BOOL success , int statusCode) {
                                        if (success)
                                        {
                                            if (_imageUpdateBlock) {
                                                _imageUpdateBlock(imagesArray);
                                            }
                                            
                                            if (_shouldViewAutoResignAfterOnePicConfirms) {
                                                [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kIsPreferencesChanged];
                                            }
                                            
                                            if (profilePicUrlStr && [profilePicUrlStr length]>0) {
                                                [[NSUserDefaults standardUserDefaults] setObject:profilePicUrlStr forKey:kWooProfilePicURL];
                                                
                                            }
                                            [[NSUserDefaults standardUserDefaults] synchronize];
                                            
                                            [[NSNotificationCenter defaultCenter] postNotificationName:kConfirmProfileDoneTapped object:nil];
                                            if([[NSUserDefaults standardUserDefaults] boolForKey:kNewUserNoPicStatus]){
                                                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kNewUserNoPicStatus];
//                                                [[NSNotificationCenter defaultCenter] postNotificationName:kTagTappedWithTagDataNotification
//                                                                                                    object:nil];
                                            }
                                        }
                                        else{
                                            [self handleErrorForResponseCode:203];
                                        }
                                        
                                        [self dismissViewControllerAnimated:YES completion:^{
                                            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsPreferencesChanged];
                                            [[NSUserDefaults standardUserDefaults] synchronize];
                                            [APP_Utilities hideActivityIndicator];
                                        }];
                                    }];
    
    if (!status) {
        SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"Please check your internet connection",nil));
        [self dismissViewControllerAnimated:YES completion:^{
            [APP_Utilities hideActivityIndicator];
        }];
    }
    
    if (_shouldViewAutoResignAfterOnePicConfirms) {
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kIsPreferencesChanged];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - UIImagePickerController delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = nil;
    if (picker.allowsEditing) {
        chosenImage = info[UIImagePickerControllerEditedImage];
    }
    else{
        chosenImage = info[UIImagePickerControllerOriginalImage];
    }
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    if (chosenImage.size.width > chosenImage.size.height) {
        if (chosenImage.size.width/chosenImage.size.height > 2) {
            U2AlertView *alert = [[U2AlertView alloc] init];

            [alert setU2AlertActionBlockForButton:^(int tagValue , id data){
                NSLog(@"%d",tagValue);
                
                if (tagValue == 1)
                    [self accessConfirmationCallback:data];
                }];

            [alert setContainerData:nil];
            [alert alertWithHeaderText:NSLocalizedString(@"Phone Album",nil)
                           description:NSLocalizedString(@"image_size_big_txt", nil)
                        leftButtonText:NSLocalizedString(@"Ok", nil)
                    andRightButtonText:nil];
            [alert show];
            return;
        }
    }
    else{
        if (chosenImage.size.height/chosenImage.size.width > 2) {
            U2AlertView *alert = [[U2AlertView alloc] init];
            [alert setU2AlertActionBlockForButton:^(int tagValue , id data){
                NSLog(@"%d",tagValue);
                
                if (tagValue == 1)
                    [self accessConfirmationCallback:data];
            }];

            
            [alert setContainerData:nil];
            [alert alertWithHeaderText:NSLocalizedString(@"Phone Album",nil)
                           description:NSLocalizedString(@"image_size_big_txt", nil)
                        leftButtonText:NSLocalizedString(@"Ok", nil)
                    andRightButtonText:nil];
            [alert show];
            return;
        }
    }
    
    CGFloat imageWidth = SCREEN_WIDTH;
    CGFloat imageHeight = SCREEN_WIDTH * 0.7968;
    
    VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:chosenImage
                                                                                           cropFrame:CGRectMake(0,((SCREEN_HEIGHT/2)-(imageHeight/2)), imageWidth, imageHeight)
                                                                                     limitScaleRatio:3.0];
    
    imgCropperVC.delegate = self;
    [imgCropperVC setAlbumData:selectedAlbumDetail];
    [self presentViewController:imgCropperVC animated:YES completion:^{
        // TO DO
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - VPImageCropperDelegate methods

- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(NSDictionary *)editedImageData {

    UIImage *uploadableImage = [editedImageData objectForKey:@"imageObj"];
    
    BOOL isFaceDetected = TRUE;//[APP_Utilities detectFacesInImage:uploadableImage];
    
    NSString *objetId = nil;
    NSString *imageIdKey = nil;
    if ([imagesArray count] > selectedIndex) {
        if ([[[imagesArray objectAtIndex:selectedIndex] allKeys] containsObject:@"imageID"]) {
            imageIdKey = @"imageID";
        }
        else if ([[[imagesArray objectAtIndex:selectedIndex] allKeys] containsObject:@"objectId"]){
            imageIdKey = @"objectId";
        }
        objetId = [NSString stringWithFormat:@"%@",[[imagesArray objectAtIndex:selectedIndex] valueForKey:imageIdKey]];
    }
    
    BOOL status =[ImageAPIClass uploadImageToServer:uploadableImage  AndObjectId:objetId WithFakeCheck:YES WithCompletionBlock:^(id response, BOOL success , int statusCode) {
        NSMutableDictionary *newDataDict = [[NSMutableDictionary alloc]init];
        [newDataDict setObject:[response objectForKey:kProfilePicObjectId] forKey:kProfilePicObjectId];
        [newDataDict setObject:[response objectForKey:@"photoUrl"] forKey:kBigImageSourceKey];
        
        NSString *imageStatus = (isFaceDetected && ![[response valueForKey:@"googleResult"] boolValue])?kPhotoApproved:kPhotoPending;
        [newDataDict setObject:imageStatus forKey:kPhotoStatus];
        
        if ([currentFocusedButton isEqual:mainPic] || (imagesArray.count < 1)) {
            [newDataDict setObject:@"true" forKey:kProfilePicKey];
        }
        else{
            [newDataDict setObject:@"false" forKey:kProfilePicKey];
        }
        
        NSString *cacheKey = [NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(320),IMAGE_SIZE_FOR_POINTS(255),[APP_Utilities encodeFromPercentEscapeString:[newDataDict objectForKey:@"srcBig"]]];
        
        [[SDImageCache sharedImageCache] removeImageForKey:cacheKey fromDisk:YES withCompletion:nil];
       // [[SDImageCache sharedImageCache] removeImageForKey:cacheKey
        //                                         fromDisk:YES];
        
        if (currentFocusedButton.selected) {
            [imagesArray replaceObjectAtIndex:selectedIndex withObject:newDataDict];
        }
        else{
            [imagesArray addObject:newDataDict];
        }
        
        if([imagesArray count]>0){
            doneButtonObj.enabled = TRUE;
        }
        
        if (currentUploadType == PhotoUploadFacebook) {
            [photoSelectionObj removeFromSuperview];
        }
        
        [cropperViewController dismissViewControllerAnimated:YES completion:^{

            if (!mainPic.selected || ([imagesArray count]==0)) {
                currentFocusedButton = mainPic;
            }
            else{
//                NSArray *buttonArray = [NSArray arrayWithObjects:firstAdditionalPic,
//                                        secondAdditionalPic,
//                                        thirdAdditionalPic, nil];
//                
//                NSInteger secondaryImageCount = [imagesArray count] - 1; // 1 deducted for profile Image
//                currentFocusedButton = [buttonArray objectAtIndex:(secondaryImageCount -1)];
            }
            
            [currentFocusedButton setImage:uploadableImage forState:UIControlStateNormal];
            [currentFocusedButton setImage:uploadableImage forState:UIControlStateSelected];
            [currentFocusedButton setImage:uploadableImage forState:UIControlStateHighlighted];
            [currentFocusedButton setSelected:YES];
            
//            if ([currentFocusedButton isEqual:firstAdditionalPic]) {
//                firstImageApprovedSeen =NO;
//            }
//            else if([currentFocusedButton isEqual:secondAdditionalPic]){
//                secondImageApprovedSeen=NO;
//            }
//            else if([currentFocusedButton isEqual:thirdAdditionalPic]){
//                thirdImageApprovedSeen=NO;
//            }
            
            [self performSelectorOnMainThread:@selector(updateImagesOnScreen) withObject:nil waitUntilDone:YES];
        }];
        [APP_Utilities hideActivityIndicator];
    }];
    
    if (!status) {
        [cropperViewController dismissViewControllerAnimated:YES completion:^{
            [APP_Utilities hideActivityIndicator];
            SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"Please check your internet connection",nil));
        }];
    }
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    
    [cropperViewController dismissViewControllerAnimated:NO completion:^{
        if (cropperViewController.showPreviousOption) {
            
            if ([AppLaunchModel sharedInstance].fbAlbumEnable || [AppLaunchModel sharedInstance].cameraOption) {
                if (wasCameraOptionSelected) {
                    [self presentDeviceCameraForUser];
                }
                else{
                    if (selectedAlbumDetail) {
                        [self albumSelected:selectedAlbumDetail];
                    }
                    else{
                        [self showFacebookAlbumView];
                    }
                }
            }
        }
    }];
}


#pragma mark - Access Confirmation Alert Button Tapped
- (void)accessConfirmationCallback:(id)imagePicker{
    if (!imagePicker)
        return;
 
    UIImagePickerController *imagePickerController = imagePicker;
    [self presentViewController:imagePickerController animated:YES completion:NULL];
}


#pragma mark - 

-(void) internetConnectionStatusChanged:(NSNotification*)notif{
    
    int internetStatus = [notif.object intValue];
    
    switch (internetStatus) {
        case AFNetworkReachabilityStatusNotReachable:{
            //
        }
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:
        case AFNetworkReachabilityStatusReachableViaWiFi:{
            NSLog(@"Reachable via WIFI Typing>>>");
            //Fetch imageList from Server
            [ImageAPIClass fetchUserImagesWithCompletionBlock:^(id response, BOOL success , int statusCode) {
                if (success)
                {
                    imagesArray = [self rearrangeImagesArray:(NSMutableArray *)response];
                    if ([imagesArray count]<1) {
                        doneButtonObj.enabled = FALSE;
                    }
                    
                    [self updateImagesOnScreen];
                    NSLog(@"response > %@",response);
                }
            }];
        }
            break;
        default:
        {
            NSLog(@"Unknown status here>>>");
            
        }
            break;
    }
}


@end
