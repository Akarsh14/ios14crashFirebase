//
//  ImageReorder.m
//  ImageDragControl
//
//  Created by Vaibhav Gautam on 06/02/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "ImageReorder.h"
#import "PhotoSelectionView.h"
#import "VPImageCropperViewController.h"
#import "SDWebImageDownloader.h"


#define NORMAL_BORDER CGRectMake(0, 0, 75, 75)
#define POLAROID_BORDER CGRectMake(0, 0, (imageView.frame.size.width), (imageView.frame.size.height))

@implementation ImageReorder

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *nibArray;
        if (IS_IPHONE_5) {
            nibArray = [[NSBundle mainBundle]loadNibNamed:@"ImageReorder" owner:self options:nil];
        }else{
            nibArray = [[NSBundle mainBundle]loadNibNamed:@"ImageReorder_small" owner:self options:nil];
        }
        
        //        [self addLongPress];
        
        [self addSubview:[nibArray lastObject]];
        
        [self initializeFramesArray];
        
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleSingleTapOnView:)];
        
        [self addGestureRecognizer:singleFingerTap];
        
        [self initializePhotoSelectionView];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kPhotoPermissionMissingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoPermissionMissingError) name:kPhotoPermissionMissingNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kShowFBAlbumView object: nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAlbumView) name:kShowFBAlbumView object:nil];
    }
    return self;
}

-(void)photoPermissionMissingError{
    [self showAuthorizeFacebookAlert];
}

-(void)showAuthorizeFacebookAlert{
    //    [self removeSyncAlert:FALSE];
    U2AlertView *alert = [[U2AlertView alloc]init];
    
    [alert setU2AlertActionBlockForButton:^(int tagValue , id data){
        NSLog(@"%d",tagValue);
        
        if (tagValue == 1)
            [self getNewFbToken];
        
    }];
    
    
    [alert alertWithHeaderText:NSLocalizedString(@"Authorize Facebook", nil) description:NSLocalizedString(@"Please allow us to access your profile photos in Facebook.", nil) leftButtonText:NSLocalizedString(@"Cancel",nil) andRightButtonText:NSLocalizedString(@"Authorize",nil)];
    [self removeOtherAlertBeforeShowingNew];
    [alert show];
}

-(void)getNewFbToken{
    
    [APP_Utilities showActivityIndicator];
    U2opiaFBLoginView *loginViewObj = [U2opiaFBLoginView sharedU2opiaFBLoginView];
    [loginViewObj setIsPresentedForFBSync:TRUE];
    
    if ([FBSession activeSession].accessTokenData) {
        NSLog(@"hai ");
        [loginViewObj getReadPermissions:[loginViewObj fetchReadPermissions] withBlock:^(bool isValid) {
            [APP_Utilities hideActivityIndicator];
            if (isValid) {
                if ([APP_Utilities isFacebookPermissionMissing]) {
                    U2AlertView *showLoginALert = [[U2AlertView alloc] init];
                    [showLoginALert alertWithHeaderText:NSLocalizedString(@"Need more details!", nil) description:NSLocalizedString(@"We need some more details to build \nan accurate Woo profile for you. \nPlease allow Woo to access \nFacebook for this information. \n\nWoo never posts on your wall.", nil) leftButtonText:NSLocalizedString(@"Authorize Facebook", nil) andRightButtonText:nil];
                    
                    [showLoginALert setU2AlertActionBlockForButton:^(int tagValue , id data){
                        [self getNewFbToken];
                        
                    }];

                    
                    
                    [self removeOtherAlertBeforeShowingNew];
                    [showLoginALert show];
                }
                else{
                    [self addButtonTappedWithTag:1];
                }
            }
            else{
                NSLog(@"fbsession value :%@",[FBSession activeSession]);
                //            [self showLoginScreen];
                [[NSNotificationCenter defaultCenter] postNotificationName:kAuthenticationErrorNotification object:nil];
            }
            
        }];
    }
    else{
        NSLog(@"fbsession value :%@",[FBSession activeSession]);
        //            [self showLoginScreen];
        [[NSNotificationCenter defaultCenter] postNotificationName:kAuthenticationErrorNotification object:nil];
        
    }
}

-(void)showAlbumView{
    [self addButtonTappedWithTag:1];
    [APP_Utilities hideActivityIndicator];
}

-(void)addLongPress{
    UILongPressGestureRecognizer *longPressRecogniser = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(AllowDragging)];
    [longPressRecogniser setMinimumPressDuration:0.5];
    [longPressRecogniser setDelegate:self];
    [self addGestureRecognizer:longPressRecogniser];
}




-(void)initializeFramesArray{
    if (!framesArray) {
        framesArray = [[NSMutableArray alloc]init];
    }
    for (int i =1; i<=4; i++) {
        [framesArray addObject:NSStringFromCGRect([(UIView *)[self viewWithTag:i*100] frame])];
    }
    
    mainImageViewObl.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-0.75));
}



-(void)setImageOnViewFromDataArray:(NSMutableArray *)arrayOfImageModels{
    
    _dataArray = nil;
    
    totalVisibleCrossButtons = 0;
    
    for (int i = 0; i<4; i++) {
        NSMutableDictionary *data = [arrayOfImageModels objectAtIndex:i];
        [data setObject:[NSString stringWithFormat:@"%d",((i+1)*100)] forKey:@"initialIndex"];
    }
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    [_dataArray addObjectsFromArray:arrayOfImageModels];
//    _dataArray = arrayOfImageModels;
    
    for (int i=1; i<=4; i++) {
        UIView *viewObj = [self viewWithTag:i*100];
        [viewObj setFrame:CGRectFromString([framesArray objectAtIndex:i-1])];
    }
    
    
    for (NSMutableDictionary *dataDict in arrayOfImageModels) {
        int currentTag = [[dataDict objectForKey:@"location"] intValue];
        __weak UIImageView *imageViewObj = (UIImageView *)[self viewWithTag:(currentTag*100)+5];
        
        if (currentTag == 1) {
            [self addPolaroidFrameOnImageView:imageViewObj];
        }else{
            [self addNormalBorderOnImageView:imageViewObj];
        }
        UIButton *actionButton;
        
        if ([[dataDict objectForKey:@"isImageAvailable"] intValue] == 1){
            
            NSString *sillHouette = nil;
            
            if ([APP_Utilities isGenderMale:[[NSUserDefaults standardUserDefaults] valueForKeyPath:kWooUserGender]]) {
                sillHouette = @"profile_emptyboy.png";
            }
            else{
                sillHouette = @"profile_emptygirl.png";
            }
            
            
            [imageViewObj sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(250),IMAGE_SIZE_FOR_POINTS(303),[APP_Utilities encodeFromPercentEscapeString:[dataDict objectForKey:@"imageURL"]]]] placeholderImage:[UIImage imageNamed:sillHouette] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                int numberOfTimesCropButtonBlinked = 0;
                if ([[NSUserDefaults standardUserDefaults] integerForKey:kNumberOfTimesCropButtonBlinked]) {
                    numberOfTimesCropButtonBlinked = [[NSUserDefaults standardUserDefaults] integerForKey:kNumberOfTimesCropButtonBlinked];
                }
                
                if (imageViewObj.tag == 105 && !isCropButtonZoomed && numberOfTimesCropButtonBlinked <2) {
                    UIButton *buttonObject = (UIButton *)[self viewWithTag:101];
                    [APP_Utilities performSelector:@selector(scaleUpAnimationOnView:) withObject:buttonObject afterDelay:0.5];
                    isCropButtonZoomed = YES;
                    [[NSUserDefaults standardUserDefaults] setInteger:++numberOfTimesCropButtonBlinked forKey:kNumberOfTimesCropButtonBlinked];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }];
            
            UIButton *cropButton = (UIButton *)[self viewWithTag:1123];
            cropButton.hidden = TRUE;
            actionButton = (UIButton *)[self viewWithTag:(currentTag*100)+1];
            [imageViewObj addSubview:actionButton];
            
            [actionButton setBackgroundColor:[UIColor clearColor]];
            if (currentTag == 1) {
                [actionButton setImage:[UIImage imageNamed:@"board_crop.png"] forState:UIControlStateNormal];
                [actionButton setFrame:CGRectMake(imageViewObj.frame.origin.x-27, imageViewObj.frame.origin.y, 27, 27)];
            }
            else{
                [actionButton setImage:[UIImage imageNamed:@"profile_cross.png"] forState:UIControlStateNormal];
                [actionButton setFrame:CGRectMake(imageViewObj.frame.origin.x-23, imageViewObj.frame.origin.y, 23, 23)];
            }
            
            [actionButton setHidden:YES];
            
            
        }else{
//            NSString *sillHouette = nil;
//            
//            if ([APP_Utilities isGenderMale:[[NSUserDefaults standardUserDefaults] valueForKeyPath:kWooUserGender]]) {
//                sillHouette = @"profile_emptyboy.png";
//            }
//            else{
//                sillHouette = @"profile_emptygirl.png";
//            }
            [imageViewObj setImage:[UIImage imageNamed:@""]];
            actionButton = (UIButton *)[self viewWithTag:(currentTag*100)+1];
            
            [imageViewObj addSubview:actionButton];
            [actionButton setTag:actionButton.tag+1];
            imageViewObj.backgroundColor = [UIColor colorWithRed:(199.0/255.0) green:(199.0/255.0) blue:(199.0/255.0) alpha:1.0];
//            [actionButton setBackgroundColor:[UIColor colorWithRed:(199.0/255.0) green:(199.0/255.0) blue:(199.0/255.0) alpha:1.0]];
//            [actionButton setBackgroundColor:[UIColor clearColor]];
            
            if (imageViewObj.frame.size.width>100) {
                UIButton *cropButton = (UIButton *)[self viewWithTag:1123];
//                [imageViewObj addSubview:cropButton];
                [cropButton setBackgroundColor:[UIColor clearColor]];
                [cropButton setImage:[UIImage imageNamed:@"board_crop.png"] forState:UIControlStateNormal];
                [cropButton setEnabled:FALSE];
                [cropButton setUserInteractionEnabled:FALSE];
//                [cropButton setFrame:CGRectMake(imageViewObj.frame.origin.x-27, imageViewObj.frame.origin.y, 27, 27)];
                [cropButton setHidden:FALSE];
                [actionButton setImage:[UIImage imageNamed:@"plus_small.png"] forState:UIControlStateNormal];
            }else{
                [actionButton setImage:[UIImage imageNamed:@"plus_small.png"] forState:UIControlStateNormal];
//                [cropButton setHidden:TRUE];
            }
            [actionButton setFrame:CGRectMake(0, 0, imageViewObj.frame.size.width, imageViewObj.frame.size.height)];
//            [actionButton setBackgroundColor:[UIColor clear]];
            
            [self setAppropriateBorderOnImageView:actionButton];
            [actionButton setHidden:NO];
            
        }
        [imageViewObj setUserInteractionEnabled:YES];
        [imageViewObj setExclusiveTouch:YES];
    }
    
    [self stopTapped:nil];
    [self AllowDragging];
    [self adjustFramesAfterDragging];
    
    
}


-(void)addNormalBorderOnImageView:(UIView *)imageView{
    return;
 /*
    CATiledLayer *customBorder = [CATiledLayer layer];
    [customBorder setName:@"customBorder"];
    [customBorder setBorderColor:[[UIColor whiteColor] CGColor]];
    [customBorder setBorderWidth:10.0];
    [customBorder setFrame:CGRectMake(-5, -5, imageView.frame.size.width+10, imageView.frame.size.height+10)];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:imageView.bounds cornerRadius:2.0f];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
    maskLayer.frame = imageView.bounds;
    maskLayer.path = maskPath.CGPath;
    imageView.layer.mask = maskLayer;
    
    
    imageView.layer.shadowOpacity = 1.0;
    imageView.layer.shadowOffset = CGSizeMake(30, 30);
    imageView.layer.shadowRadius = 20.0;
    
    [imageView.layer addSublayer:customBorder];
  */
}

-(void) addPolaroidFrameOnImageView:(UIView *)imageView{
    return;
 
    /*
    imageView.transform = CGAffineTransformIdentity;
    
    CATiledLayer *customBorder = [CATiledLayer layer];
    [customBorder setName:@"customBorder"];
    [customBorder setBorderColor:[[UIColor whiteColor] CGColor]];
    [customBorder setBorderWidth:50.0];
    [customBorder setFrame:CGRectMake(-35, -35, imageView.frame.size.width+70, imageView.frame.size.height+35)];
    
    [imageView.layer setMasksToBounds:TRUE];
    [imageView.layer setContentsGravity:kCAGravityResizeAspectFill];
    imageView.layer.mask = nil;
    imageView.layer.shadowOpacity = 1.0;
    imageView.layer.shadowOffset = CGSizeMake(0, 30);
    imageView.layer.shadowRadius = 2.0;
    
    [imageView.layer addSublayer:customBorder];
    
//    imageView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-0.75));
     
     */
    
}

#pragma mark - touches method

-(void)adjustFramesBeforeDragging{
    return;
    /*
    for(NSDictionary *dict in _dataArray){
        if([[dict objectForKey:@"location"] intValue]==1){
            
            UIImageView *imgViewObj = (UIImageView*)[self viewWithTag:[[dict objectForKey:@"initialIndex"] intValue]];
            
            imgViewObj.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(0));
        }
    }
     */
}

-(void)adjustFramesAfterDragging{
    return;
    /*
    for(NSDictionary *dict in _dataArray){
        if([[dict objectForKey:@"location"] intValue]==1){
            
            UIImageView *imgViewObj = (UIImageView*)[self viewWithTag:[[dict objectForKey:@"initialIndex"] intValue]];
            
            imgViewObj.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-0.75));
        }
    }
     */
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!draggingEnabled) {
        return;
    }
    
    
    if ([touches count] == 1) {
        CGPoint touchPoint = [[touches anyObject] locationInView:self];
        selectedImage = [self getTagOfSelectedViewForTouchPoint:touchPoint];
        
//        [self insertSubview:[self viewWithTag:selectedImage] atIndex:1000];
//        [self insertSubview:[self viewWithTag:selectedImage] aboveSubview:self];
        UIView *viewObj = [self viewWithTag:selectedImage];
        [[viewObj superview] bringSubviewToFront:[self viewWithTag:selectedImage]];
        
        if ([self viewWithTag:selectedImage].frame.size.width>200) {
            selectedImage = 0;
            return;
        }
        [self adjustFramesBeforeDragging];
        initialRectOfDraggableView = [[self viewWithTag:selectedImage] frame];
        
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    
    if (!draggingEnabled) {
        return;
    }
    
    
    
    if (selectedImage == 100 ||selectedImage == 200 ||selectedImage== 300 ||selectedImage== 400) {
        [self hideCrossButton];
        UIView *iv = (UIView *)[self viewWithTag:selectedImage];
        
//        [self insertSubview:iv aboveSubview:self];
        [[iv superview] bringSubviewToFront:iv];
        
        CGPoint touchPoint = [[touches anyObject] locationInView:self];
        
        CGRect newDragObjectFrame = CGRectMake(touchPoint.x - touchOffset.x,
                                               touchPoint.y - touchOffset.y,
                                               iv.frame.size.width,
                                               iv.frame.size.height);
        
        iv.frame = newDragObjectFrame;
        
        
        if (iv.tag == 100) {
            if ([self checkIfViewsNeedToBeSwappedforTag:100 andSecondTag:200]) {
                
                [self swapViewsWithTags:100 andSecondTag:200];
                
            }else if ([self checkIfViewsNeedToBeSwappedforTag:100 andSecondTag:300]) {
                
                [self swapViewsWithTags:100 andSecondTag:300];
                
            }else if ([self checkIfViewsNeedToBeSwappedforTag:100 andSecondTag:400]) {
                
                [self swapViewsWithTags:100 andSecondTag:400];
                
            }
        }else if (iv.tag == 200){
            if ([self checkIfViewsNeedToBeSwappedforTag:200 andSecondTag:100]) {
                
                [self swapViewsWithTags:200 andSecondTag:100];
                
            }else if ([self checkIfViewsNeedToBeSwappedforTag:200 andSecondTag:300]) {
                
                [self swapViewsWithTags:200 andSecondTag:300];
                
            }else if ([self checkIfViewsNeedToBeSwappedforTag:200 andSecondTag:400]) {
                
                [self swapViewsWithTags:200 andSecondTag:400];
                
            }
        }else if (iv.tag == 300){
            if ([self checkIfViewsNeedToBeSwappedforTag:300 andSecondTag:100]) {
                
                [self swapViewsWithTags:300 andSecondTag:100];
                
            }else if ([self checkIfViewsNeedToBeSwappedforTag:300 andSecondTag:200]) {
                
                [self swapViewsWithTags:300 andSecondTag:200];
                
            }else if ([self checkIfViewsNeedToBeSwappedforTag:300 andSecondTag:400]) {
                
                [self swapViewsWithTags:300 andSecondTag:400];
                
            }
        }else if (iv.tag == 400){
            if ([self checkIfViewsNeedToBeSwappedforTag:400 andSecondTag:100]) {
                
                [self swapViewsWithTags:400 andSecondTag:100];
                
            }else if ([self checkIfViewsNeedToBeSwappedforTag:400 andSecondTag:200]) {
                
                [self swapViewsWithTags:400 andSecondTag:200];
                
            }else if ([self checkIfViewsNeedToBeSwappedforTag:400 andSecondTag:300]) {
                
                [self swapViewsWithTags:400 andSecondTag:300];
                
            }
        }
    }
}


-(BOOL)checkIfViewsNeedToBeSwappedforTag:(int )firstViewTag andSecondTag:(int )secondViewTag{
    UIView *iv = [self viewWithTag:firstViewTag];
    if ([self viewWithTag:secondViewTag].frame.size.width>200) {
        return NO;
    }
    
    
    if (CGRectIntersectsRect(iv.frame, [self viewWithTag:secondViewTag].frame) && (iv.frame.origin.x >([self viewWithTag:secondViewTag].frame.origin.x - ([self viewWithTag:secondViewTag].frame.size.width/4))) && (iv.frame.origin.y >= [self viewWithTag:secondViewTag].frame.origin.y - ([self viewWithTag:secondViewTag].frame.size.height/4)) &&(iv.frame.origin.y < ([self viewWithTag:secondViewTag].frame.origin.y+([self viewWithTag:secondViewTag].frame.size.height/2)))) {
        return YES;
    }
    
    return NO;
}
-(BOOL)checkIfViewsNeedToBeSwappedAfterDraggingEndedforTag:(int )firstViewTag andSecondTag:(int )secondViewTag{
    UIView *iv = [self viewWithTag:firstViewTag];
    if ([self viewWithTag:secondViewTag].frame.size.width>200) {
        if (CGRectIntersectsRect(iv.frame, [self viewWithTag:secondViewTag].frame) && (iv.frame.origin.x >([self viewWithTag:secondViewTag].frame.origin.x - ([self viewWithTag:secondViewTag].frame.size.width/4))) && (iv.frame.origin.y >= [self viewWithTag:secondViewTag].frame.origin.y - ([self viewWithTag:secondViewTag].frame.size.height/4)) &&(iv.frame.origin.y < ([self viewWithTag:secondViewTag].frame.origin.y+([self viewWithTag:secondViewTag].frame.size.height/2)))) {
            return YES;
        }
    }
    return NO;
}

-(void)swapViewsAfterDraggingWithTags:(int )firstTag andSecondTag:(int )secondTag{
    
    UIImageView *firstImageView = (UIImageView *)[self viewWithTag:firstTag+5];
    UIImageView *secondImageView = (UIImageView *)[self viewWithTag:secondTag+5];
    UIImage *tempImageObj = firstImageView.image;
    firstImageView.image = secondImageView.image;
    secondImageView.image = tempImageObj;
    
    //
    //    firstImageView.tag = secondTag + 5;
    //    secondImageView.tag = firstTag+5;
    //
    //    UIView *firstView = (UIView *)[self viewWithTag:firstTag];
    //    UIView *secondView = (UIView *)[self viewWithTag:secondTag];
    //
    //    firstView.tag = secondTag;
    //    secondView.tag = firstTag;
    //
    //    UIButton *firstButton = (UIButton *)[self viewWithTag:firstTag];
    //    UIButton *secondButton = (UIButton *)[self viewWithTag:secondTag];
    //
    //    firstButton.tag = secondTag+1;
    //    secondButton.tag = firstTag+1;
    //
    //    UIImageView *firstPlusImage = (UIImageView *)[self viewWithTag:firstTag];
    //    UIImageView *secondPlusImaeg = (UIImageView *)[self viewWithTag:firstTag];
    //
    //    firstPlusImage.tag = secondTag+2;
    //    secondPlusImaeg.tag = firstTag+2;
    
    
    
    
//    CGRect tempFrame;
    UIView *tempImage = (UIView *)[self viewWithTag:firstTag];
//    tempFrame = tempImage.frame;
    
    if ([self viewWithTag:secondTag+2]) {
        return;
    }
    
    
    [UIView animateWithDuration:0.15 animations:^{
        [tempImage setFrame:initialRectOfDraggableView];
        [self removeBorderFromView:tempImage];
        [self removeBorderFromView:[self viewWithTag:tempImage.tag+2]];
        UIButton *plusView = (UIButton *)[self viewWithTag:tempImage.tag+2];
        if (plusView) {
            [tempImage addSubview:plusView];
            [plusView setFrame:CGRectMake(0, 0, initialRectOfDraggableView.size.width, initialRectOfDraggableView.size.height)];
            
            [plusView setImage:[UIImage imageNamed:@"plus_small.png"] forState:UIControlStateNormal];
        }
        
        [self setAppropriateBorderOnImageView:tempImage];
        [self setAppropriateBorderOnImageView:plusView];
        //        initialRectOfDraggableView = tempFrame;
        [self swapItemsForIndex:firstTag andSecondIndex:secondTag];
        [self changeDataArrayAccordingToLoctionValue];
    }];
}

-(void)swapViewsWithTags:(int )firstTag andSecondTag:(int )secondTag{
    
    CGRect tempFrame;
    UIView *tempImage = (UIView *)[self viewWithTag:secondTag];
    tempFrame = tempImage.frame;
    
    if ([self viewWithTag:secondTag+2]) {
        return;
    }
    
    
    [UIView animateWithDuration:0.15 animations:^{
        [tempImage setFrame:initialRectOfDraggableView];
        [self removeBorderFromView:tempImage];
        [self removeBorderFromView:[self viewWithTag:tempImage.tag+2]];
        UIButton *plusView = (UIButton *)[self viewWithTag:tempImage.tag+2];
        if (plusView) {
            [tempImage addSubview:plusView];
            [plusView setFrame:CGRectMake(0, 0, initialRectOfDraggableView.size.width, initialRectOfDraggableView.size.height)];
            
            [plusView setImage:[UIImage imageNamed:@"plus_small.png"] forState:UIControlStateNormal];
        }
        
        [self setAppropriateBorderOnImageView:tempImage];
        [self setAppropriateBorderOnImageView:plusView];
        initialRectOfDraggableView = tempFrame;
        [self swapItemsForIndex:firstTag andSecondIndex:secondTag];
        [self changeDataArrayAccordingToLoctionValue];
    }];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if (!draggingEnabled) {
        return;
    }
    
    
    
    if (selectedImage == 100 ||selectedImage == 200 ||selectedImage== 300 ||selectedImage== 400) {
        [self hideCrossButton];
        UIView *iv = (UIView *)[self viewWithTag:selectedImage];
        [self bringSubviewToFront:iv];
        CGPoint touchPoint = [[touches anyObject] locationInView:self];
        
        CGRect newDragObjectFrame = CGRectMake(touchPoint.x - touchOffset.x,
                                               touchPoint.y - touchOffset.y,
                                               iv.frame.size.width,
                                               iv.frame.size.height);
        
        iv.frame = newDragObjectFrame;
        
        
        
        if (iv.tag == 100) {
            if ([self checkIfViewsNeedToBeSwappedAfterDraggingEndedforTag:100 andSecondTag:200]) {
                
                [self swapViewsAfterDraggingWithTags:100 andSecondTag:200];
                
            }else if ([self checkIfViewsNeedToBeSwappedAfterDraggingEndedforTag:100 andSecondTag:300]) {
                
                [self swapViewsAfterDraggingWithTags:100 andSecondTag:300];
                
            }else if ([self checkIfViewsNeedToBeSwappedAfterDraggingEndedforTag:100 andSecondTag:400]) {
                
                [self swapViewsAfterDraggingWithTags:100 andSecondTag:400];
                
            }
        }else if (iv.tag == 200){
            if ([self checkIfViewsNeedToBeSwappedAfterDraggingEndedforTag:200 andSecondTag:100]) {
                
                [self swapViewsAfterDraggingWithTags:200 andSecondTag:100];
                
            }else if ([self checkIfViewsNeedToBeSwappedAfterDraggingEndedforTag:200 andSecondTag:300]) {
                
                [self swapViewsAfterDraggingWithTags:200 andSecondTag:300];
                
            }else if ([self checkIfViewsNeedToBeSwappedAfterDraggingEndedforTag:200 andSecondTag:400]) {
                
                [self swapViewsAfterDraggingWithTags:200 andSecondTag:400];
                
            }
        }else if (iv.tag == 300){
            if ([self checkIfViewsNeedToBeSwappedAfterDraggingEndedforTag:300 andSecondTag:100]) {
                
                [self swapViewsAfterDraggingWithTags:300 andSecondTag:100];
                
            }else if ([self checkIfViewsNeedToBeSwappedAfterDraggingEndedforTag:300 andSecondTag:200]) {
                
                [self swapViewsAfterDraggingWithTags:300 andSecondTag:200];
                
            }else if ([self checkIfViewsNeedToBeSwappedAfterDraggingEndedforTag:300 andSecondTag:400]) {
                
                [self swapViewsAfterDraggingWithTags:300 andSecondTag:400];
                
            }
        }else if (iv.tag == 400){
            if ([self checkIfViewsNeedToBeSwappedAfterDraggingEndedforTag:400 andSecondTag:100]) {
                
                [self swapViewsAfterDraggingWithTags:400 andSecondTag:100];
                
            }else if ([self checkIfViewsNeedToBeSwappedAfterDraggingEndedforTag:400 andSecondTag:200]) {
                
                [self swapViewsAfterDraggingWithTags:400 andSecondTag:200];
                
            }else if ([self checkIfViewsNeedToBeSwappedforTag:400 andSecondTag:300]) {
                
                [self swapViewsAfterDraggingWithTags:400 andSecondTag:300];
                
            }
        }
    }
    
    
    //    return;
    
    
    
    
    
    UIView *iv = (UIView *)[self viewWithTag:selectedImage];
    
    [UIView animateWithDuration:0.15 animations:^{
        if (iv.tag == 100 || iv.tag == 200 || iv.tag == 300 || iv.tag == 400) {
            
            [iv setFrame:initialRectOfDraggableView];
            
//            NSArray* sublayers = [NSArray arrayWithArray:iv.layer.sublayers];
//            for (CATiledLayer *layer in sublayers) {
//                if ([layer.name isEqualToString:@"customBorder"]) {
//                    [layer removeFromSuperlayer];
//                }
//            }
//            
//            [self setAppropriateBorderOnImageView:iv];
//            [self removeShadowFromViewWithTag:selectedImage];
//            [self DisallowrDragging];
            
        }
    } completion:^(BOOL finished) {
        [self showCrossButton];
    }];
}

-(void)removeBorderFromView:(UIView *)viewObj{
    return;
    
    /*
    NSArray* sublayers = [NSArray arrayWithArray:viewObj.layer.sublayers];
    for (CATiledLayer *layer in sublayers) {
        if ([layer.name isEqualToString:@"customBorder"]) {
            [layer removeFromSuperlayer];
        }
    }
     
     */
}

-(void)setAppropriateBorderOnImageView:(UIView *)imageView{
    
    if (initialRectOfDraggableView.size.width > 200 && initialRectOfDraggableView.size.width < 320 ) {
        [self addPolaroidFrameOnImageView:imageView];
    }else if(initialRectOfDraggableView.size.width < 200){
        [self addNormalBorderOnImageView:imageView];
    }
}


#pragma mark - Dragging methods

-(void)AllowDragging{
    draggingEnabled = YES;
    [self showCrossButton];
    return;
    
    /*
    for(NSDictionary *dict in _dataArray){
        if([[dict objectForKey:@"location"] intValue]==1){
            
            UIView *imgViewObj = (UIView*)[self viewWithTag:[[dict objectForKey:@"initialIndex"] intValue]];
            
            imgViewObj.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(0));
        }
    }
     
     */
}


-(void)DisallowrDragging{
    //    draggingEnabled = NO;
    //    [self hideCrossButton];
    selectedImage=0;
    [self adjustFramesAfterDragging];
}

-(void)showCrossButton{
    
    int imagesAvailable= 0 ;
    for (NSMutableDictionary *images in _dataArray) {
        if ([[images objectForKey:@"isImageAvailable"] intValue] == 1) {
            imagesAvailable++;
        }
    }
    
    
    for (UIView *btn in [[[self subviews] objectAtIndex:0] subviews]) {
        
        if (btn.tag == 100 ||btn.tag == 200 ||btn.tag == 300 ||btn.tag == 400) {
            
            UIButton *crossButton = (UIButton *)[self viewWithTag:btn.tag+1];
            UIButton *plusButton = (UIButton *)[self viewWithTag:btn.tag+2];
            
            [crossButton setFrame:CGRectMake([self viewWithTag:btn.tag].frame.size.width-23,0,23,23)];
            
            UIButton *newCrossButton = crossButton;
            
            [newCrossButton setFrame:CGRectMake(btn.frame.origin.x+btn.frame.size.width-13, btn.frame.origin.y-10, 23, 23)];
            [self addSubview:newCrossButton];
            [self bringSubviewToFront:newCrossButton];
            
            if (btn.tag == 100) {
                UIImageView *viewObj = (UIImageView *)[self viewWithTag:btn.tag+5];
                [crossButton setFrame:CGRectMake(viewObj.frame.size.width-23,0,23,23)];
                
                UIButton *newCrossButton = crossButton;
                if (IS_IPHONE_5) {
                    [newCrossButton setFrame:CGRectMake(282, 6, 28, 28)];
                }
                else{
                    [newCrossButton setFrame:CGRectMake(273, 2, 27, 27)];
                }
                [self bringSubviewToFront:newCrossButton];
            }
            
            
            [btn addSubview:plusButton];
            [plusButton setFrame:CGRectMake(5,5,[self viewWithTag:btn.tag].frame.size.width-10,[self viewWithTag:btn.tag].frame.size.height-10)];
            
            if (draggingEnabled) {
                if (imagesAvailable>1) {
                    [crossButton setHidden:NO];
                }else{
                    [crossButton setHidden:NO];
                }
            }else{
                [crossButton setHidden:YES];
            }
            
            [btn bringSubviewToFront:crossButton];
            [plusButton setHidden:NO];
        }
        
    }
}

-(void)hideCrossButton{
    for (UIView *btn in [[[self subviews] objectAtIndex:0] subviews]) {
        
        if (btn.tag == 100 ||btn.tag == 200 ||btn.tag == 300 ||btn.tag == 400) {
            UIButton *crossButton = (UIButton *)[self viewWithTag:btn.tag+1];
            //            UIButton *plusButton = (UIButton *)[self viewWithTag:btn.tag+2];
            [crossButton setHidden:YES];
            //            [plusButton setHidden:YES];
        }
    }
}

- (IBAction)removeImageButton:(id)sender {
    
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *buttonTapped;
        buttonTapped = sender;
        
        if (buttonTapped.tag == 101 || buttonTapped.tag == 201 || buttonTapped.tag == 301 || buttonTapped.tag == 401) {
            
            [self removeButtonTappedWithTag:buttonTapped.tag];
            
        }else if (buttonTapped.tag == 102 || buttonTapped.tag == 202 || buttonTapped.tag == 302 || buttonTapped.tag == 402){
            [self addButtonTappedWithTag:buttonTapped.tag];
        }
    }
}


-(void)initializePhotoSelectionView{
//    NSMutableDictionary *modelDictionary;
//    
//    for (NSMutableDictionary *dataDictionary in _dataArray) {
//        if ([[dataDictionary objectForKey:@"isImageAvailable"] intValue] == 1) {
//            modelDictionary = dataDictionary;
//        }
//    }
    if (photoSelectionObj &&[photoSelectionObj superview]) {
        [photoSelectionObj removeFromSuperview];
    }
    photoSelectionObj = [[PhotoSelectionView alloc]initWithFrame:self.frame];
    [photoSelectionObj setDelegate:self];
    [photoSelectionObj setSelectorForImageTapped:@selector(showImageCropperWithData:)];
//    [photoSelectionObj setUserDataDict:modelDictionary];
}



-(void)showImageCropperWithData:(NSMutableDictionary *)imageData{
//    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
//    if (!reachability.reachable) {
//        return;
//    }
    backgroundView = [[UIView alloc]initWithFrame:APP_DELEGATE.window.frame];
    [backgroundView setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f]];
    

    progressViewObj = [[UAProgressView alloc]initWithFrame:CGRectMake(((APP_DELEGATE.window.frame.size.width/2)-25), ((APP_DELEGATE.window.frame.size.height/2)-25), 50, 50)];
    
    [progressViewObj setTintColor:[UIColor whiteColor]];
    UIButton *stopButton = [[UIButton alloc] initWithFrame:CGRectInset(progressViewObj.bounds, progressViewObj.bounds.size.width / 3.0, progressViewObj.bounds.size.height / 3.0)];
    stopButton.backgroundColor = [UIColor whiteColor];
    stopButton.userInteractionEnabled = YES; // Allows tap to pass through to the progress view.
    [stopButton addTarget:self action:@selector(stopButtonTappedOnProgressView) forControlEvents:UIControlEventTouchUpInside];
    progressViewObj.centralView = stopButton;
    
    [backgroundView addSubview:progressViewObj];
    
    [[[[UIApplication sharedApplication] windows] objectAtIndex:0] addSubview:backgroundView];
    
    lastImageDownlodedForCropping = [NSURL URLWithString:[imageData objectForKey:@"imageURL"]];
    
    [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:[imageData objectForKey:@"imageURL"]]
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
             imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:image cropFrame:CGRectMake(0,(([[UIScreen mainScreen] bounds].size.height/2)-(255/2)), 320, 255) limitScaleRatio:3.0];
             
             imgCropperVC.delegate = self;
             [imgCropperVC setAdditionalData:imageData];
             [[[UIApplication sharedApplication] keyWindow] addSubview:imgCropperVC.view];
//             [self bringSubviewToFront:imgCropperVC.view];
             [backgroundView removeFromSuperview];
             //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Crop_From_Facebook_Gallery forScreenName:@"PR"];
         }
     }];
}

-(void)stopButtonTappedOnProgressView{
    
    [backgroundView removeFromSuperview];
//    [[SDWebImageDownloader sharedDownloader] removeCallbacksForURL:lastImageDownlodedForCropping];
}

//-(void)updateProgress
-(void)addButtonTappedWithTag:(NSInteger )tagValue{
    
    if ([AppLaunchModel sharedInstance].fbAlbumEnable || [AppLaunchModel sharedInstance].cameraOption) {
        int index = (tagValue/100) - 1;
        if ([_delegate respondsToSelector:_selectorForAddButtonTapped]) {
            [_delegate performSelector:_selectorForAddButtonTapped withObject:[_dataArray objectAtIndex:index] afterDelay:0.0];
        }
        return;
    }
    else{
//        AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
//        if (reachability.isReachable || reachability.isReachableViaWiFi || reachability.isReachableViaWWAN) {
            NSMutableDictionary *modelDictionary = [[NSMutableDictionary alloc]init];
            
            for (NSMutableDictionary *dataDictionary in _dataArray) {
                if ([[dataDictionary objectForKey:@"isImageAvailable"] intValue] == 1) {
                    modelDictionary = dataDictionary;
                }
            }
            
            [photoSelectionObj setUserDataDict:modelDictionary];
            [photoSelectionObj setSelectedImagesArray:_dataArray];
            [photoSelectionObj fetchDataFromWebServiceForUserID:[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue]];
            
            [[[UIApplication sharedApplication] keyWindow] addSubview:photoSelectionObj];
            
//        }
//        else{
//            [APP_Utilities showNoInternetAvailableToast];
//        }
    }
    
    
    
    
   
    //    [self addSubview:photoSelectionObj];
    
}

-(void)showSelectImageFromAlbum:(NSString *)albumId{
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    if (!reachability.isReachable || reachability.isReachableViaWiFi || reachability.isReachableViaWWAN) {
        NSMutableDictionary *modelDictionary = [[NSMutableDictionary alloc]init];
        
        for (NSMutableDictionary *dataDictionary in _dataArray) {
            if ([[dataDictionary objectForKey:@"isImageAvailable"] intValue] == 1) {
                modelDictionary = dataDictionary;
            }
        }
        
        [photoSelectionObj setUserDataDict:modelDictionary];
        [photoSelectionObj setSelectedImagesArray:_dataArray];
        [photoSelectionObj fetchDataFromWebServiceForUserID:[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue] forFacebookAlbum:albumId];
        
        //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Picture_Library_Select_Picture];
        [[[UIApplication sharedApplication] keyWindow] addSubview:photoSelectionObj];
        
    }
    else{
        [APP_Utilities showNoInternetAvailableToast];
    }

}

- (void)handleSingleTapOnView:(UITapGestureRecognizer *)recognizer{
    
    //int tagOfFirstView = 0;
    
    for (NSMutableDictionary *tempParsingDict in _dataArray) {
        if ([[tempParsingDict objectForKey:@"location"] intValue] == 1) {
            //tagOfFirstView = [[tempParsingDict objectForKey:@"initialIndex"] intValue];
            break;
        }
    }
//    41 27 228 239
    CGPoint locationOftouch = [recognizer locationInView:self];
    
    if (locationOftouch.x > 41 && locationOftouch.y > 27 && locationOftouch.y < 266 && locationOftouch.x < 269) {
            locationToBeUsedForChaingingImage = 1;
            [self addButtonTappedWithTag:102];
    }else{
            locationToBeUsedForChaingingImage = 0;
    }
    

}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}


-(void)callbackForImageSelected:(NSMutableDictionary *)data{
    
    for (NSMutableDictionary *currentDict in _dataArray) {
        if ([[currentDict objectForKey:@"imageID"] longLongValue] == [[data objectForKey:@"imageID"]longLongValue] && [[currentDict objectForKey:@"isImageAvailable"] intValue] == [[data objectForKey:@"isImageAvailable"]intValue] ) {
            if ([[data objectForKey:@"location"]intValue] !=1) {
                return;
            }
            
        }
    }
    
    int imageAddedAtIndex = 0;
    
    if ([[data objectForKey:@"location"] intValue] == 1) {
        [[NSUserDefaults standardUserDefaults] setObject:[data objectForKey:@"imageURL"] forKey:kWooProfilePicURL];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:kProfileImageObj];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if (locationToBeUsedForChaingingImage==0) {
        for (int i=0; i<[_dataArray count]; i++) {
            
            if ([[[_dataArray objectAtIndex:i] objectForKey:@"isImageAvailable"] intValue] == 0) {
                
                if (_isOpenedFromOnBoarding) {
                    
                    
                    
                    switch ([[[_dataArray objectAtIndex:i] objectForKey:@"location"] intValue]) {
                        case 2:
                        {
                            //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Add_First_Other_Picture forScreenName:@"OB.PC"];
                        }
                            break;
                            
                        case 3:
                        {
                            //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Add_Second_Other_Picture forScreenName:@"OB.PC"];
                        }
                            break;
                            
                        case 4:
                        {
                            //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:ADD_Third_Other_Picture forScreenName:@"OB.PC"];
                        }
                            break;
                        default:
                            break;
                    }
                }
                
                NSMutableDictionary *newDetails = (NSMutableDictionary *)[_dataArray objectAtIndex:i];
                [newDetails setObject:[data objectForKey:@"imageID"] forKey:@"imageID"];
                [newDetails setObject:[data objectForKey:@"imageURL"] forKey:@"imageURL"];
                [newDetails setObject:[data objectForKey:@"isImageAvailable"] forKey:@"isImageAvailable"];
                [_dataArray setObject:newDetails atIndexedSubscript:i];
                imageAddedAtIndex = i;
                break;
            }
        }
    }else{
        
        
        NSMutableDictionary *newImageData = [[NSMutableDictionary alloc] init];
        
        [newImageData setObject:@"1" forKey:@"location"];
        [newImageData setObject:[data objectForKey:@"imageURL"] forKey:@"imageURL"];
        [newImageData setObject:@"1" forKey:@"isImageAvailable"];
        [newImageData setObject:[data objectForKey:@"imageID"] forKey:@"imageID"];
        [newImageData setObject:[data objectForKey:@"initialIndex"] forKey:@"initialIndex"];
        
        NSMutableArray *newImagesArray = [[NSMutableArray alloc]init];
        
        if ([newImagesArray count] > 0) {
            [newImagesArray removeAllObjects];
        }
        
        for (NSMutableDictionary *individualImageDict in _dataArray) {
            if ([[individualImageDict objectForKey:@"location"] intValue] == 1) {
                [newImageData setObject:[individualImageDict objectForKey:@"initialIndex"] forKey:@"initialIndex"];
                [newImagesArray addObject:newImageData];
            }else{
                [newImagesArray addObject:individualImageDict];
            }
        }
        _dataArray = newImagesArray;
        
        locationToBeUsedForChaingingImage = 0;
    }
    
    
    
    
    data = [_dataArray objectAtIndex:imageAddedAtIndex];
    int currentTag = [[data objectForKey:@"initialIndex"] intValue];
    UIImageView *image = (UIImageView *)[self viewWithTag:currentTag+5];
    
    NSString *sillHouette = nil;
    
    if ([APP_Utilities isGenderMale:[[NSUserDefaults standardUserDefaults] valueForKeyPath:kWooUserGender]]) {
        sillHouette = @"profile_emptyboy.png";
    }
    else{
        sillHouette = @"profile_emptygirl.png";
    }
    
    if (cachedCroppedImage != nil) {

        if (image.frame.size.width < 200) {
            NSLog(@"image > %@",image);
        }
        [image setImage:cachedCroppedImage];
        cachedCroppedImage = nil;

    }else{
        
        [image sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(250),IMAGE_SIZE_FOR_POINTS(303), [APP_Utilities encodeFromPercentEscapeString:[data objectForKey:@"imageURL"]]]] placeholderImage:[UIImage imageNamed:sillHouette]];

    }
    
    
    [image setUserInteractionEnabled:YES];
    [image setExclusiveTouch:YES];
    
    UIButton *plusButton = (UIButton *)[self viewWithTag:currentTag+2];
    [image addSubview:plusButton];
    [plusButton setTag:currentTag+1];
    [plusButton setBackgroundColor:[UIColor clearColor]];
    [plusButton setImage:[UIImage imageNamed:@"profile_cross.png"] forState:UIControlStateNormal];
    [plusButton setFrame:CGRectMake([self viewWithTag:currentTag].frame.size.width-23,0,23,23)];
    [self removeBorderFromView:plusButton];
    
    [self showCrossButton];
    [self setImageOnViewFromDataArray:_dataArray];
    
}


- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(NSDictionary *)editedImageData {
    
    
    int cropX = [[editedImageData objectForKey:@"croppingStartingX"] intValue];
    int cropY = [[editedImageData objectForKey:@"croppingStartingY"] intValue];
    int cropWidth = [[editedImageData objectForKey:@"croppingWidth"] intValue];
    int cropHeight = [[editedImageData objectForKey:@"croppingHeight"] intValue];
    long long int objectID =[[cropperViewController.additionalData objectForKey:@"imageID"] longLongValue] ;
    NSString *imageURL = [APP_Utilities encodeFromPercentEscapeString:[cropperViewController.additionalData objectForKey:@"imageURL"]];
    

    NSString *apiPath = [NSString stringWithFormat:@"%@?url=%@&height=%d&width=%d&zoom=1&cropX=%d&cropY=%d&objectId=%lld",kImageCroppingServerURL,imageURL,cropHeight,cropWidth,cropX,cropY,objectID];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =apiPath;
    wooRequestObj.time =900;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =getRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = cropAnImage;
    
//    [cropperViewController.view setAlpha:0.5];
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        

        if (cropAnImage) {
            
            [photoSelectionObj removeFromSuperview];
            
            
            NSMutableDictionary *newDataDictionary = [cropperViewController.additionalData mutableCopy];
            
            
            [newDataDictionary setObject:[response objectForKey:@"url"] forKey:@"imageURL"];
            
            [[SDImageCache sharedImageCache] removeImageForKey:[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(320),IMAGE_SIZE_FOR_POINTS(255),[APP_Utilities encodeFromPercentEscapeString:[newDataDictionary objectForKey:@"imageURL"]]] fromDisk:YES withCompletion:nil];
            
//            [[SDImageCache sharedImageCache] removeImageForKey:[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(320),IMAGE_SIZE_FOR_POINTS(255),[APP_Utilities encodeFromPercentEscapeString:[newDataDictionary objectForKey:@"imageURL"]]] fromDisk:YES];
            
            [self callbackForImageSelected:newDataDictionary];

            [cropperViewController.view performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0];
            [[NSNotificationCenter defaultCenter] postNotificationName:kImageAddedMakeConfirmCallAutomatically object:nil];
        }
        
    }  shouldReachServerThroughQueue:TRUE];
    
    cachedCroppedImage = [editedImageData objectForKey:@"imageObj"];

}



- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {

    [cropperViewController.view removeFromSuperview];
    locationToBeUsedForChaingingImage = 0;

}




-(void)removeButtonTappedWithTag:(NSInteger )tagValue{
    
    if (tagValue ==101) {
        NSLog(@"main cross button tapped");
//        -(void)showImageCropperWithData:(NSMutableDictionary *)imageData
        locationToBeUsedForChaingingImage = 1;
        NSMutableDictionary *cropData = [[_dataArray objectAtIndex:0] mutableCopy];
        [cropData setObject:@"0" forKey:@"isFakePhoto"];
        [self showImageCropperWithData:cropData];
        //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:My_profile_Crop_On_Main_Picture forScreenName:@"PR"];
        return;
    }
    else{
        NSLog(@"other cross button tapped");
    }
    

    NSMutableArray *newDataArray = [[NSMutableArray alloc]init];
    int indexX = (tagValue/100)-1;
    
    NSSortDescriptor *locationDescriptor = [[NSSortDescriptor alloc] initWithKey:@"location" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:locationDescriptor];
    NSArray *tempArray = [_dataArray sortedArrayUsingDescriptors:sortDescriptors];
    
    if ([_dataArray count]>0) {
        [_dataArray removeAllObjects];
    }
    [_dataArray addObjectsFromArray:tempArray];
    
    if (indexX>0) {
        for (int y = 0; y<indexX; y++) {
            [newDataArray addObject:[_dataArray objectAtIndex:y]];
        }
    }
    
    for (int i =indexX; i<[_dataArray count]; i++) {
        NSMutableDictionary *dataDict;
        dataDict = [_dataArray objectAtIndex:i];
        int locationOfImage = [[dataDict objectForKey:@"location"] intValue];
        if (_isOpenedFromOnBoarding) {
            switch (locationOfImage) {
                case 1:
                {
                    //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Delete_Main_Picture forScreenName:@"OB.PC"];
                }
                    break;
                    
                case 2:
                {
                    //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Delete_First_Other_Picture forScreenName:@"OB.PC"];
                }
                    break;
                    
                case 3:
                {
                    //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Delete_Second_other_Picture forScreenName:@"OB.PC"];
                }
                    break;
                    
                case 4:
                {
                    //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Delete_Third_other_Picture forScreenName:@"OB.PC"];
                }
                    break;
                    
                default:
                    break;
            }
        }
        
        locationOfImage = locationOfImage-1;
        
        
        if (indexX == i) {
            [dataDict setValue:@"0" forKey:@"isImageAvailable"];
            locationOfImage = 0;
//            [dataDict setValue:[NSString stringWithFormat:@"%d",locationOfImage*100] forKey:@"initialIndex"];
//            lastImageDetails = dataDict;
//            continue;
        }
        if (locationOfImage == 0) {
            locationOfImage = 4;
        }
        [dataDict setValue:[NSString stringWithFormat:@"%d",locationOfImage] forKey:@"location"];
        [dataDict setValue:[NSString stringWithFormat:@"%d",locationOfImage*100] forKey:@"initialIndex"];
        [newDataArray addObject:dataDict];
    }
//    if ([newDataArray count]<4) {
//        [newDataArray addObject:lastImageDetails];
//    }
    newDataArray = (NSMutableArray *)[newDataArray sortedArrayUsingDescriptors:sortDescriptors];
    
    [self setImageOnViewFromDataArray:newDataArray];
    return;

    
    
    
    
//    UIButton *buttonTapped = (UIButton *)[self viewWithTag:tagValue];
//    UIImageView* im = (UIImageView *)[self viewWithTag:(buttonTapped.tag-1)+5];
//    
//    [im setImage:[UIImage imageNamed:@"profile_left_emptybox.png"]];
//    
//    initialRectOfDraggableView = im.frame;
//    [buttonTapped setTag:buttonTapped.tag+1];
//    
//    if (im.frame.size.width>100) {
//        [buttonTapped setImage:[UIImage imageNamed:@"plus_small.png"] forState:UIControlStateNormal];
//    }else{
//        [buttonTapped setImage:[UIImage imageNamed:@"plus_small.png"] forState:UIControlStateNormal];
//    }
//    
//    [buttonTapped setBackgroundColor:[UIColor colorWithRed:(199.0/255.0) green:(199.0/255.0) blue:(199.0/255.0) alpha:1.0]];
//    [buttonTapped setFrame:im.frame];
//    [self setAppropriateBorderOnImageView:buttonTapped];
//    
//    
//    NSMutableArray *newDataArray = [[NSMutableArray alloc]init];
//    NSDictionary *lastImageDetails = nil;
//    
//    for (int i =0; i<[_dataArray count]; i++) {
//        NSMutableDictionary *dataDict = [[NSMutableDictionary alloc]init];
//        dataDict = [_dataArray objectAtIndex:i];
//        int locationOfImage = [[dataDict objectForKey:@"location"] intValue];
//        locationOfImage = locationOfImage-1;
//        if (locationOfImage == 0) {
//            locationOfImage = 4;
//        }
//        [dataDict setValue:[NSString stringWithFormat:@"%d",locationOfImage] forKey:@"location"];
//        if ([[dataDict objectForKey:@"initialIndex"] intValue] == tagValue-1) {
//            [dataDict setValue:@"0" forKey:@"isImageAvailable"];
//            [dataDict setValue:[NSString stringWithFormat:@"%d",locationOfImage*100] forKey:@"initialIndex"];
//            lastImageDetails = dataDict;
//            continue;
//        }
//        [dataDict setValue:[NSString stringWithFormat:@"%d",locationOfImage*100] forKey:@"initialIndex"];
//        [newDataArray addObject:dataDict];
//    }
//    if ([newDataArray count]<4) {
//        [newDataArray addObject:lastImageDetails];
//    }
//    
//    [self setImageOnViewFromDataArray:newDataArray];
//    return;
//    
//    _dataArray = newDataArray;
//    
//    [self searchForNextSwappableViewForCrossedImage:tagValue];
//    
//    [self showCrossButton];
}


-(void)searchForNextSwappableViewForCrossedImage:(int)tag{
    
    [self adjustFramesBeforeDragging];
    int locationOfCrossedImage = 0;
    
    for (NSMutableDictionary *imageDataDict in _dataArray) {
        if ([[imageDataDict objectForKey:@"initialIndex"] intValue] == tag-1) {
            locationOfCrossedImage = [[imageDataDict objectForKey:@"location"] intValue];
            break;
        }
    }
    if (locationOfCrossedImage == 4) {
        return;
    }
    
    int nextSwappableView = 0;
    
    for (NSMutableDictionary *imageDataDict in _dataArray) {
        if ([[imageDataDict objectForKey:@"location"] intValue] == locationOfCrossedImage+1) {
            nextSwappableView = [[imageDataDict objectForKey:@"initialIndex"] intValue];
            break;
        }
    }
    
    [self searchForNextSwappableViewForCrossedImage:nextSwappableView+1];
    
    
    
    initialRectOfDraggableView = [self viewWithTag:(tag-1)].frame;
    
    CGRect tempFrame = [self viewWithTag:(tag-1)].frame;
    
    [self removeBorderFromView:[self viewWithTag:nextSwappableView]];
    [self removeBorderFromView:[self viewWithTag:nextSwappableView+2]];
    
    
    [self viewWithTag:(tag-1)].frame = [self viewWithTag:nextSwappableView].frame;
    [self viewWithTag:nextSwappableView].frame = tempFrame;
    
    [self setAppropriateBorderOnImageView:[self viewWithTag:nextSwappableView]];
    [self setAppropriateBorderOnImageView:[self viewWithTag:nextSwappableView+2]];
    
    if (tempFrame.size.width > 200) {
        [self removeBorderFromView:[self viewWithTag:tag+1]];
        [self removeBorderFromView:[self viewWithTag:tag-1]];
        if (IS_IPHONE_5) {
            [self viewWithTag:tag+1].frame = CGRectMake(tempFrame.origin.x, tempFrame.origin.y, 80, 80);
        }else{
            [self viewWithTag:tag+1].frame = CGRectMake(tempFrame.origin.x, tempFrame.origin.y, 75, 75);
        }
        
        [self addNormalBorderOnImageView:[self viewWithTag:(tag+1)]];
        [self addNormalBorderOnImageView:[self viewWithTag:(tag-1)]];
        
    }
    
    
    [self showCrossButton];
    [self swapItemsForIndex:(tag-1) andSecondIndex:nextSwappableView];
}


#pragma mark - helper methods
-(void)addShadowOnViewWithTag:(int )viewTag{
    
    if (viewTag == 100 ||viewTag == 200 ||viewTag == 300 ||viewTag == 400) {
        UIImageView *iv = (UIImageView *)[self viewWithTag:viewTag];
        iv.layer.shadowOpacity = 1.0;
        iv.layer.shadowOpacity = 0.5;
    }
}

-(void)removeShadowFromViewWithTag:(int )viewTag{
    
    UIImageView *iv = (UIImageView *)[self viewWithTag:viewTag];
    iv.layer.shadowOpacity = 0.0;
    iv.layer.shadowOpacity = 0.0;
    
}

-(int )getTagOfSelectedViewForTouchPoint:(CGPoint )point{
    
    int imageTag = 0;
    
    for (UIView *iView in [[[self subviews] objectAtIndex:0] subviews]) {
        
        if ([iView isMemberOfClass:[UIView class]]) {
            if (CGRectContainsPoint(iView.frame, point)) {
                imageTag = iView.tag;
                touchOffset = CGPointMake(point.x - iView.frame.origin.x,
                                          point.y - iView.frame.origin.y);
                
            }
        }
    }
    return imageTag;
}

-(void)swapItemsForIndex:(int )firstTag andSecondIndex:(int )secondTag{
    
    int firstIndex = 0;
    int secondIndex = 0;
    int i = 0;
    for (NSMutableDictionary *dataDictionary in _dataArray) {
        
        if ([[dataDictionary objectForKey:@"initialIndex"] intValue] == firstTag) {
            firstIndex = i;
        }else if ([[dataDictionary objectForKey:@"initialIndex"] intValue] == secondTag){
            secondIndex = i;
        }
        i++;
    }
    
    NSMutableDictionary *firstDict = [_dataArray objectAtIndex:firstIndex];
    NSMutableDictionary *secondDict = [_dataArray objectAtIndex:secondIndex];
    
    int firstLocation = [[[_dataArray objectAtIndex:firstIndex] objectForKey:@"location"] intValue];
    int secondLocation = [[[_dataArray objectAtIndex:secondIndex] objectForKey:@"location"] intValue];
    
    [firstDict setObject:[NSString stringWithFormat:@"%d",secondLocation] forKey:@"location"];
    [secondDict setObject:[NSString stringWithFormat:@"%d",firstLocation] forKey:@"location"];
    
    
    [_dataArray setObject:firstDict atIndexedSubscript:firstIndex];
    [_dataArray setObject:secondDict atIndexedSubscript:secondIndex];
}



- (IBAction)startTapped:(id)sender {
    [self AllowDragging];
}

- (IBAction)stopTapped:(id)sender {
    
    for (NSMutableDictionary *picDictionary in _dataArray) {
        if (([[picDictionary objectForKey:@"location"] intValue] == 1) && [picDictionary objectForKey:@"imageURL"] && [[picDictionary objectForKey:@"imageURL"] length]>1) {
            [[NSUserDefaults standardUserDefaults] setObject:[picDictionary objectForKey:@"imageURL"] forKey:kWooProfilePicURL];
            [[NSUserDefaults standardUserDefaults] setObject:picDictionary forKey:kProfileImageObj];
            [[NSUserDefaults standardUserDefaults] synchronize];
            break;
        }
    }
    
    
    if ([_delegate respondsToSelector:_selectorForImagesSorted]) {
        [_delegate performSelector:_selectorForImagesSorted withObject:_dataArray];
    }
}

-(void)changeDataArrayAccordingToLoctionValue{
    NSMutableArray *newDataArray = [[NSMutableArray alloc]init];
    NSSortDescriptor *brandDescriptor = [[NSSortDescriptor alloc] initWithKey:@"location" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:brandDescriptor];
    NSArray *tempArray = [_dataArray sortedArrayUsingDescriptors:sortDescriptors];
    if ([_dataArray count]>0) {
        [_dataArray removeAllObjects];
    }
    [_dataArray addObjectsFromArray:tempArray];
//    _dataArray = (NSMutableArray *)[_dataArray sortedArrayUsingDescriptors:sortDescriptors];
    
    
    for (int i =0; i<[_dataArray count]; i++) {
        NSMutableDictionary *dataDict;
        dataDict = [_dataArray objectAtIndex:i];
        int locationOfImage = [[dataDict objectForKey:@"location"] intValue];
        [dataDict setValue:[NSString stringWithFormat:@"%d",locationOfImage*100] forKey:@"initialIndex"];
        [newDataArray addObject:dataDict];
    }
    newDataArray = (NSMutableArray *)[newDataArray sortedArrayUsingDescriptors:sortDescriptors];
    
    if ([_dataArray count]>0) {
        [_dataArray removeAllObjects];
    }
    [_dataArray addObjectsFromArray:newDataArray];
//     _dataArray = newDataArray;
}

-(void)removeAllNotificationObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShowFBAlbumView object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPhotoPermissionMissingNotification object:nil];
}
-(void)dealloc{
    [self removeAllNotificationObservers];
}
-(void)removeOtherAlertBeforeShowingNew{
    for (id viewObj in [APP_DELEGATE.window subviews]) {
        if ([viewObj isKindOfClass:[U2AlertView class]]) {
            [viewObj removeFromSuperview];
        }
    }
}


-(void)addCropButtonAndDisableIt:(BOOL)disableCropButton{
    
}

-(void)setTest:(UIImage *)setImage{
    testImage.image = setImage;
}

@end
