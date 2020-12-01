//
//  ImageGalleryController.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 09/06/15.
//  Modified by Suparno Bose on 30/11/15
//  Copyright (c) 2015 Woo. All rights reserved.
//

#import "ImageGalleryController.h"

#define BOUNDCE_DURATION 0.3f
@interface ImageGalleryController ()
{
    UIPanGestureRecognizer *panGestureRecognizer;
}
@end

@implementation ImageGalleryController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:kDismissTheScreenNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(dimissTheScreen)
//                                                 name:kDismissTheScreenNotification object:nil];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor redColor];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:TRUE];
//>> code to make sure that first pic is always profile picture
    if ([imagesDataArray count]>1 && [[[imagesDataArray firstObject] objectForKey:kProfilePicKey] boolValue] == FALSE) {
        NSMutableArray *newModifiedArray = [imagesDataArray mutableCopy];
        
        for (int index = 0; index < [newModifiedArray count]; index++) {
            NSDictionary *dict = [newModifiedArray objectAtIndex:index];
            if ([[dict objectForKey:kProfilePicKey] boolValue] == TRUE) {
                [imagesDataArray exchangeObjectAtIndex:index withObjectAtIndex:0];
                break;
            }
        }
    }
//<< images rearrangement ends here
    pageControlObj.numberOfPages = [imagesDataArray count];
    
    if (_needToShowFullImages) {
        CGFloat scrollWidth = SCREEN_WIDTH;
        CGFloat scrollHeight = SCREEN_HEIGHT;
        CGFloat imageWidth = SCREEN_WIDTH;
        CGFloat imageHeight = SCREEN_HEIGHT;
        
        for (int index = 0; index < [imagesDataArray count]; index++) {
            NSDictionary *imageDict = [imagesDataArray objectAtIndex:index];
            UIImageView *userGalleryImage = [[UIImageView alloc]init];
            
            NSURL *imageURL =[NSURL URLWithString:[imageDict objectForKey:kBigImageSourceKey]];
//            [userGalleryImage sd_setImageWithURL:imageURL
//                                placeholderImage:[UIImage imageNamed:(self.isMale?@"placeholder_male":@"placeholder_female")]];
            [userGalleryImage sd_setImageWithURL:imageURL];
            userGalleryImage.backgroundColor = [APP_Utilities getUIColorObjectFromHexString:@"EDEDED" alpha:1.0];
            [userGalleryImage setFrame:CGRectMake(index*imageWidth, 0, imageWidth, imageHeight)];
            userGalleryImage.contentMode = UIViewContentModeScaleAspectFit;
            [galleryScroller addSubview:userGalleryImage];
        }
        [galleryScroller setContentSize:CGSizeMake(scrollWidth*[imagesDataArray count], scrollHeight)];
    }
    else{
        CGFloat imageWidth = SCREEN_WIDTH;
        
        
        
        
        for (int index = 0; index < [imagesDataArray count]; index++) {
            NSDictionary *imageDict = [imagesDataArray objectAtIndex:index];
            UIImageView *userGalleryImage = [[UIImageView alloc]init];
            userGalleryImage.contentMode = UIViewContentModeScaleAspectFit;
            userGalleryImage.tag = index;
            
            NSURL *imageURL =[NSURL URLWithString:[imageDict objectForKey:kBigImageSourceKey]];
#ifdef CircularProgressView
            __block DACircularProgressView *circularProgressView = [[DACircularProgressView alloc]init];
            circularProgressView.roundedCorners = YES;
            circularProgressView.tag = 111115;
            circularProgressView.trackTintColor = kVeryLightGrayColor;
            circularProgressView.progressTintColor = kHeaderTextRedColor;
            [circularProgressView setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width/2,
                                                        [UIScreen mainScreen].bounds.size.height/2)];
            [userGalleryImage addSubview:circularProgressView];
            
            [userGalleryImage sd_setImageWithURL:imageURL
                                placeholderImage:[UIImage imageNamed:(self.isMale?@"placeholder_male":@"placeholder_female")]
                                         options:SDWebImageTransformAnimatedImage
                                        progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                            if (receivedSize >0) {
                                                float received = (float )receivedSize;
                                                float expected = (float )expectedSize;
                                                [circularProgressView setProgress:(received/expected) animated:YES];
                                            }
                                        }
                                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                           [circularProgressView removeFromSuperview];
                                           circularProgressView = nil;
                                           [self addDoubleTapGestureRecognizersForView:userGalleryImage];
                                           [self addPinchGestureRecognizersForView:userGalleryImage];
                                       }];
            
#else
            UIActivityIndicatorView *activityIndicatorView =[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [userGalleryImage addSubview:activityIndicatorView];
            [activityIndicatorView setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width/2,
                                                         [UIScreen mainScreen].bounds.size.height/2)];
            [activityIndicatorView startAnimating];
            [activityIndicatorView setHidden:NO];
            
            [userGalleryImage sd_setImageWithURL:imageURL
                                placeholderImage:[UIImage imageNamed:(self.isMale?@"placeholder_male":@"placeholder_female")]
                                         options:SDWebImageTransformAnimatedImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                             [activityIndicatorView setHidden:YES];
                                             [activityIndicatorView removeFromSuperview];
                                             
                                             [self addDoubleTapGestureRecognizersForView:userGalleryImage];
                                             [self addPinchGestureRecognizersForView:userGalleryImage];
                                             
                                         }];
#endif
            [userGalleryImage setFrame:CGRectMake(0,
                                                  0,
                                                  [UIScreen mainScreen].bounds.size.width,
                                                  [UIScreen mainScreen].bounds.size.height)];

            UIView *containerView = [[UIView alloc] initWithFrame:userGalleryImage.frame];
            [containerView setFrame:CGRectMake(index*imageWidth,
                                               0,
                                               [UIScreen mainScreen].bounds.size.width,
                                               [UIScreen mainScreen].bounds.size.height)];
            containerView.clipsToBounds = YES;
            [containerView addSubview:userGalleryImage];
            [galleryScroller addSubview:containerView];
        }
        [galleryScroller setContentSize:CGSizeMake(imageWidth*[imagesDataArray count], 50)];
    }
    
    
    if(_isProfileInformationNeeded){
        bottomProfileInformationView.hidden = NO;
    }
    else{
        bottomProfileInformationView.hidden = YES;
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self setCurrentImageIndex:_currentIndex];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Pinch and Pan and DoubleTap Observer methods

/*!
 * @discussion This function handles the pinch gesture
 * @param pinchGestureRecognizer The pinch recogniser object
 */
- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    NSInteger currentImageIndex = pageControlObj.currentPage;
    UIImageView *view = [self getImageViewForIndex:currentImageIndex];
    
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        pinchGestureRecognizer.scale = 1;
    }
    else if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGRect newFrame = [self handleScaleOverflow:view];
        [UIView animateWithDuration:BOUNDCE_DURATION animations:^{
            view.frame = newFrame;
            view.center = CGPointMake(view.superview.frame.size.width/2,view.superview.center.y);
        }];
    }
}

/*!
 * @discussion This function handles the pan gesture
 * @param pinchGestureRecognizer The pan recogniser object
 */
- (void) panView:(UIPanGestureRecognizer *)oPanGestureRecognizer
{
    NSInteger currentImageIndex = pageControlObj.currentPage;
    UIImageView *view           = [self getImageViewForIndex:currentImageIndex];
    
    if (oPanGestureRecognizer.state == UIGestureRecognizerStateBegan || oPanGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        // calculate accelerator
        CGFloat acceleratorX = 1;// - ABS(absCenterX - view.center.x) / (scaleRatio * absCenterX);
        CGFloat acceleratorY = 1;// - ABS(absCenterY - view.center.y) / (scaleRatio * absCenterY);
        CGPoint translation = [oPanGestureRecognizer translationInView:view.superview];
        
        [view setCenter:(CGPoint){view.center.x + translation.x * acceleratorX, view.center.y + translation.y * acceleratorY}];
        [oPanGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }
    else if (oPanGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        // bounce to original frame
        CGRect newFrame = [self handleBorderOverflow:view];
        [UIView animateWithDuration:BOUNDCE_DURATION animations:^{
            view.frame = newFrame;
        }];
    }
}

- (void) doubleTapView:(UIPanGestureRecognizer *)tapGestureRecognizer
{
    NSInteger currentImageIndex = pageControlObj.currentPage;
    UIImageView *view           = [self getImageViewForIndex:currentImageIndex];
    if(view.frame.size.width == [UIScreen mainScreen].bounds.size.width){

        CGRect newFrame = CGRectMake(view.frame.origin.x,
                                     view.frame.origin.y,
                                     view.frame.size.width * 1.5,
                                     view.frame.size.height * 1.5);
        galleryScroller.scrollEnabled = NO;
        [self addPanGestureRecognizersForView];
        [UIView animateWithDuration:BOUNDCE_DURATION animations:^{
            view.frame = newFrame;
            view.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,
                                     [UIScreen mainScreen].bounds.size.height/2);
        }];
    }
    else{
        [self goBackToOriginalSize:view WithAnimation:YES];
        [self removePanGestureRecognizersForView];
        galleryScroller.scrollEnabled = YES;
    }
}

#pragma mark - Internal methods

-(void)dimissTheScreen{    
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)createGalleryWithImagesFromArray:(NSMutableArray *)imagesArray{
    if (!imagesArray || [imagesArray count] < 1) {
        return;
    }
    imagesDataArray = [imagesArray mutableCopy];
    pageControlObj.numberOfPages = [imagesDataArray count];
}

-(void)setCurrentImageIndex:(NSInteger) index{
    pageControlObj.currentPage = index;
    CGRect rect = CGRectMake(index*galleryScroller.frame.size.width,
                             galleryScroller.frame.origin.y,
                             galleryScroller.frame.size.width,
                             galleryScroller.frame.size.height);
    [galleryScroller scrollRectToVisible:rect animated:NO];
}

/*!
 * @discussion This function adds The Pan gesture to the view
 */
- (void) addPanGestureRecognizersForView
{
    // add pan gesture
    if (panGestureRecognizer == nil) {
        panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                       action:@selector(panView:)];
    }
    [self.view addGestureRecognizer:panGestureRecognizer];
}

/*!
 * @discussion This function removes The Pan gesture from the view
 */
- (void) removePanGestureRecognizersForView
{
    // remove pan gesture
    [self.view removeGestureRecognizer:panGestureRecognizer];
}


- (void) addDoubleTapGestureRecognizersForView:(UIView*)view{
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapView:)];
    doubleTap.numberOfTapsRequired = 2;
    [view addGestureRecognizer:doubleTap];
    [view setUserInteractionEnabled:YES];
}

/*!
 * @discussion This function adds The Pinch gesture to the view
 */
- (void) addPinchGestureRecognizersForView:(UIView*)view
{
    // add pinch gesture
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                                                 action:@selector(pinchView:)];
    [view addGestureRecognizer:pinchGestureRecognizer];
    [view setUserInteractionEnabled:YES];
}

/*!
 * @discussion this function returns the Imageview object of a given index
 * @param index index for the UIImageView
 * @return image view at the index given
 */
-(UIImageView*) getImageViewForIndex: (NSInteger) index{
    UIView *currentIndexView    = (UIView *)[galleryScroller.subviews objectAtIndex:index];
    UIImageView *view           = (UIImageView*)[[currentIndexView subviews] objectAtIndex:0];
    return view;
}

/*!
 * @discussion This function is returns the intented frame if image sacle exceed @2x.
 * @param imageView The imge view which changes size on pinch and pan.
 * @return The new frame of the imageview after correction.
 */
- (CGRect)handleScaleOverflow:(UIImageView *)imageView {
    CGRect newFrame = imageView.frame;
    // bounce to original frame
    if (imageView.frame.size.width < [UIScreen mainScreen].bounds.size.width) {
        newFrame = [UIScreen mainScreen].bounds;
    }
    if (imageView.frame.size.width > imageView.image.size.width*2) {
        newFrame = CGRectMake(0, 0, imageView.image.size.width*2, imageView.image.size.height*2);
    }
    
    float diff1 = 0 - imageView.frame.origin.x;
    float diff2 = imageView.frame.size.width - imageView.superview.frame.size.width;
    if (diff1 > diff2) {
        galleryScroller.scrollEnabled = YES;
        [self removePanGestureRecognizersForView];
    }
    else{
        galleryScroller.scrollEnabled = NO;
        [self addPanGestureRecognizersForView];
    }
    return newFrame;
}

/*!
 * @discussion while panning if imageview overflows the border this function returns the corrected frame
 * @param imageView The imge view which changes size on pinch and pan.
 * @return The new frame of the imageview after correction.
 */
- (CGRect)handleBorderOverflow:(UIImageView *)imageView {
    CGRect newFrame = imageView.frame;
    if (imageView.frame.size.height <= [UIScreen mainScreen].bounds.size.height) {
        newFrame.origin.y = (imageView.superview.frame.size.height - imageView.frame.size.height)/2;
    }
    else{
        CGRect rect = [self calculateClientRectOfImageInUIImageView:imageView];
        NSLog(@">>>>>>>>>>>>[%@]",NSStringFromCGRect(rect));
        
        if (rect.size.height>[UIScreen mainScreen].bounds.size.height) {
            if (rect.origin.y >0) {
                newFrame.origin.y = (rect.size.height - imageView.frame.size.height)/2;
            }
            float diff1 = imageView.superview.frame.origin.y - rect.origin.y;
            float diff2 = rect.size.height - imageView.superview.frame.size.height;
            if (diff1 > diff2) {
                newFrame.origin.y = (imageView.superview.frame.origin.y - diff2 - (imageView.frame.size.height - rect.size.height)/2);
            }

        }
        else{
            newFrame.origin.y = (imageView.superview.frame.size.height - imageView.frame.size.height)/2;
        }
    }
    
    if (imageView.frame.size.width <= [UIScreen mainScreen].bounds.size.width) {
        newFrame.origin.x = (imageView.superview.frame.size.width - imageView.frame.size.width)/2;
    }
    else{
        if (imageView.frame.origin.x >0) {
            newFrame.origin.x = 0;
        }
        NSLog(@"###imageView.superview.frame.origin.x = %f",imageView.superview.frame.origin.x);
        float diff1 = 0 - imageView.frame.origin.x;
        float diff2 = imageView.frame.size.width - imageView.superview.frame.size.width;
        if (diff1 > diff2 ) {
            newFrame.origin.x = 0 - diff2;
            if(imageView.tag != ([imagesDataArray count] - 1)){
                galleryScroller.scrollEnabled = YES;
                [self scrollToPage:imageView.tag +1];
                [self removePanGestureRecognizersForView];
            }
        }
        else{
            if (diff1 < 0 && imageView.tag != 0) {
                galleryScroller.scrollEnabled = YES;
                [self scrollToPage:imageView.tag -1];
                [self removePanGestureRecognizersForView];
            }
            else{
                galleryScroller.scrollEnabled = NO;
            }
        }
    }
    return newFrame;
}

/*!
 * @discussion This method returns the given view to its initial size
 * @param view View passed as parameter to go back to actual size
 * @param ifYes YES or NO if animation is needed or not
 */
-(void)goBackToOriginalSize: (UIView*) view WithAnimation:(BOOL)ifYes{
    
    void (^theBlock)(void)   = ^{
        CGRect newRect = CGRectMake(0, 0,
                                    [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        [view setFrame:newRect];
    };
    
    if (!ifYes) {
        theBlock();
    }
    else{
        [UIView animateWithDuration:BOUNDCE_DURATION animations:theBlock];
    }
}

/*!
 * @discussion This function scroll to the intended page
 * @param index index of the page to move.
 */
-(void) scrollToPage: (NSInteger) index{
    if (index >= 0 && index < [imagesDataArray count]) {
        CGRect frame = galleryScroller.frame;
        frame.origin.x = frame.size.width * index;
        frame.origin.y = 0;
        [galleryScroller scrollRectToVisible:frame animated:YES];
        [self performSelector:@selector(scrollViewDidEndDecelerating:) withObject:galleryScroller afterDelay:0.5];
    }
}


-(CGRect )calculateClientRectOfImageInUIImageView:(UIImageView *)imgView
{
    CGSize imgViewSize=imgView.frame.size; // Size of UIImageView
    CGSize imgSize=imgView.image.size; // Size of the image, currently displayed
    
    // Calculate the aspect, assuming imgView.contentMode==UIViewContentModeScaleAspectFit
    
    CGFloat scaleW = imgViewSize.width / imgSize.width;
    CGFloat scaleH = imgViewSize.height / imgSize.height;
    CGFloat aspect=fmin(scaleW, scaleH);
    
    CGRect imageRect={ {0,0} , { imgSize.width*=aspect, imgSize.height*=aspect } };
    
    // Note: the above is the same as :
    // CGRect imageRect=CGRectMake(0,0,imgSize.width*=aspect,imgSize.height*=aspect) I just like this notation better
    
    // Center image
    
    imageRect.origin.x=(imgViewSize.width-imageRect.size.width)/2;
    imageRect.origin.y=(imgViewSize.height-imageRect.size.height)/2;
    
    // Add imageView offset
    
    imageRect.origin.x+=imgView.frame.origin.x;
    imageRect.origin.y+=imgView.frame.origin.y;
    
    return(imageRect);
}

#pragma mark - ScrollView  delegate methods

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    [APP_DELEGATE sendSwrveEventWithEvent:@"ImageSlide.Swipe" andScreen:@"ImageSlide"];
    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"SwipePhoto" forScreenName:@"ImageSlide"];
    int indexOfPage = scrollView.contentOffset.x / scrollView.frame.size.width;
    pageControlObj.currentPage = indexOfPage;
    
    
    if (indexOfPage > 0) {
        UIImageView *view = [self getImageViewForIndex:(indexOfPage - 1)];
        [self goBackToOriginalSize:view WithAnimation:NO];
    }
    
    if (indexOfPage < ([imagesDataArray count]-1)) {
        UIImageView *view = [self getImageViewForIndex:(indexOfPage + 1)];
        [self goBackToOriginalSize:view WithAnimation:NO];
    }
}

#pragma mark - IBAction methods

- (IBAction)backButtonTapped:(id)sender {
    if (_isAppeared) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
