//
//  PhotoSelectionView.m
//  Woo
//
//  Created by Vaibhav Gautam on 14/02/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "PhotoSelectionView.h"
#import "PhotoSelectionCell.h"
#import "Utilities.h"
#import "ImageAPIClass.h"

@implementation PhotoSelectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        NSArray *nibArray = [[NSBundle mainBundle]loadNibNamed:@"PhotoSelectionView" owner:self options:nil];
        
        UIView *viewObj = [nibArray objectAtIndex:0];
        viewObj.frame = self.bounds;
        
        [self addSubview:viewObj];
        [_collectionView registerClass:[PhotoSelectionCell class] forCellWithReuseIdentifier:@"PhotoSelectionCell"];
        
        [self setupCollectionView];
        [self customizeView];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kFacebookPhotoLibraryRefreshNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDataOnView) name:kFacebookPhotoLibraryRefreshNotification object:nil];
        
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kFacebookPhotoLibraryUpdateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDataOnViewInBackground) name:kFacebookPhotoLibraryUpdateNotification object:nil];
    }
    return self;
}


-(void)refreshDataOnView{
    
    [self fetchDataFromWebServiceForUserID:[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue]];
}


-(void)refreshDataOnViewInBackground{
    
    [self updateDataOnPhotoselectionInBackground:[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue]];
    
}

-(void)customizeView{
    [APP_Utilities makeTopCornersOfViewRounded:headerView];
    
    contentView.layer.cornerRadius = 5;
    contentView.layer.masksToBounds = YES;
    
    [headerLabel setFont:kHeaderTextFont];
    
}

-(void)fetchDataFromWebServiceForUserID:(long long int )userID forFacebookAlbum:(NSString *)fbAlbumId{
    if ([_dataArray count]<1) {
        [self showActivityIndicator];
    }
    [_collectionView setContentOffset:CGPointZero animated:YES];
    NSMutableArray *newArray = [[NSMutableArray alloc]init];
    [ImageAPIClass fetchDataFromWebServiceForUserID:userID forFacebookAlbum:fbAlbumId AndCompletionBlock:^(id response, BOOL success, int statusCode) {
        if(success){
            [self hideActivityIndicator];
            if (_dataArray && [_dataArray count] > 0) {
                [_dataArray removeAllObjects];
            }
            
            for (NSMutableDictionary *dict in [response objectForKey:@"photos"]) {
                BOOL doesExists = NO;
                
                for (NSMutableDictionary *selectedDict in _selectedImagesArray) {
                    NSString *imageId = nil;
                    if ([[selectedDict allKeys] containsObject:@"imageID"]) {
                        imageId = [selectedDict objectForKey:@"imageID"];
                    }
                    else if ([[selectedDict allKeys] containsObject:@"objectId"]){
                        imageId = [selectedDict objectForKey:@"objectId"];
                    }
                    
                    if (([imageId longLongValue] ==[[dict objectForKey:@"objectId"] longLongValue])) {
                        
                        doesExists = YES;
                        break;
                    }
                }
                
                if (!doesExists) {
                    
                    if ([dict objectForKey:@"isFakePhoto"] != [NSNull null] && [[dict objectForKey:@"isFakePhoto"] boolValue] == YES) {
                        continue;
                    }
                    [newArray addObject:dict];
                }
            }
            _dataArray = newArray;
            if ([_dataArray count] < 1) {
                if (!self.isHidden) {
                    [self showFacebookPhotoSelectionAlert];
                }
            }
            [_collectionView reloadData];
            [_collectionView setContentOffset:CGPointZero animated:YES];
            [_collectionView scrollsToTop];
            
            [self fetchAdditionalDataWithOffset:[response objectForKey:@"cursorDto"] forAlbumID:fbAlbumId];
        }else{
            [_dataArray removeAllObjects];
            [_collectionView reloadData];
            [_collectionView setContentOffset:CGPointZero animated:YES];
            [_collectionView scrollsToTop];
            [[NSNotificationCenter defaultCenter] postNotificationName:kPhotoPermissionMissingNotification object:nil];
            [self removeFromSuperview];
        }
    }];
}

-(void)fetchAdditionalDataWithOffset:(NSDictionary *)cursorDictionary forAlbumID:(NSString *)fbAlbumID{
//    cursorDto
    NSMutableArray *newArray = [[NSMutableArray alloc]init];
    
    [ImageAPIClass fetchAdditionalDataWithOffset:cursorDictionary forAlbumID:fbAlbumID AndCompletionBlock:^(id response, BOOL success , int statusCode) {
        if(success){
            [self hideActivityIndicator];
            for (NSMutableDictionary *dict in [response objectForKey:@"photos"]) {
                BOOL doesExists = NO;
                
                for (NSMutableDictionary *selectedDict in _selectedImagesArray) {
                    NSString *imageId = nil;
                    if ([[selectedDict allKeys] containsObject:@"imageID"]) {
                        imageId = [selectedDict objectForKey:@"imageID"];
                    }
                    else if ([[selectedDict allKeys] containsObject:@"objectId"]){
                        imageId = [selectedDict objectForKey:@"objectId"];
                    }
                    
                    if (([imageId longLongValue] ==[[dict objectForKey:@"objectId"] longLongValue])) {
                        doesExists = YES;
                        break;
                    }
                }
                
                if (!doesExists) {
                    
                    if ([dict objectForKey:@"isFakePhoto"] != [NSNull null] && [[dict objectForKey:@"isFakePhoto"] boolValue] == YES) {
                        continue;
                    }
                    [newArray addObject:dict];
                }
            }
            
            [_dataArray addObjectsFromArray:newArray];
            [_collectionView reloadData];
            if ([(NSArray *)[response objectForKey:@"photos"] count] > 0) {
                [self fetchAdditionalDataWithOffset:[response objectForKey:@"cursorDto"] forAlbumID:fbAlbumID];
            }
            
        }else{
            [_dataArray removeAllObjects];
            [_collectionView reloadData];
            [_collectionView setContentOffset:CGPointZero animated:YES];
            [_collectionView scrollsToTop];
            //kAuthenticationErrorNotification
            [[NSNotificationCenter defaultCenter] postNotificationName:kPhotoPermissionMissingNotification object:nil];
            [self removeFromSuperview];
        }
        }];
}

-(void)fetchDataFromWebServiceForUserID:(long long int )userID{
    
    if ([_dataArray count]<1) {
        [self showActivityIndicator];
    }
    
    
    [_collectionView setContentOffset:CGPointZero animated:YES];
    
    NSMutableArray *newArray = [[NSMutableArray alloc]init];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url = [NSString stringWithFormat:@"%@/user/fbAlbum/full?wooUserId=%lld",kBaseURLV7,userID];
//    wooRequestObj.url = [NSString stringWithFormat:@"%@/user/fbAlbum/?wooUserId=%lld",kBaseURLV2,userID];
    wooRequestObj.time = 90;
    wooRequestObj.requestParams = nil;
    wooRequestObj.methodType = getRequest;
    wooRequestObj.numberOfRetries = 1;
    wooRequestObj.cachePolicy = GET_DATA_FROM_URL_AND_UPDATE_CACHE;
    wooRequestObj.requestType = getUserProfileImage;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {

        
        if (requestType == getUserProfileImage) {
            if(success){
                [self hideActivityIndicator];
                
                if (statusCode ==401) {
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kPhotoPermissionMissingNotification object:nil];
//                    [self showAuthorizeFacebookAlert];
                    //kAuthenticationErrorNotification
                    
                    //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Picture_Library_Close];
                    [_dataArray removeAllObjects];
                    [self removeFromSuperview];
                    return;
                }
                
                
                if (_dataArray && [_dataArray count] > 0) {
                    [_dataArray removeAllObjects];
                }
                
                for (NSMutableDictionary *dict in response) {
                    BOOL doesExists = NO;
                    
                    for (NSMutableDictionary *selectedDict in _selectedImagesArray) {
                        NSString *imageId = nil;
                        if ([[selectedDict allKeys] containsObject:@"imageID"]) {
                            imageId = [selectedDict objectForKey:@"imageID"];
                        }
                        else if ([[selectedDict allKeys] containsObject:@"objectId"]){
                            imageId = [selectedDict objectForKey:@"objectId"];
                        }
                        
                        if (([imageId longLongValue] ==[[dict objectForKey:@"objectId"] longLongValue])) {
                            
                            doesExists = YES;
                            break;
                        }
                    }
                    
                    if (!doesExists) {
                        
                        if ([dict objectForKey:@"isFakePhoto"] != [NSNull null] && [[dict objectForKey:@"isFakePhoto"] boolValue] == YES) {
                            continue;
                        }
                        [newArray addObject:dict];
                    }
                }
                _dataArray = newArray;
                if ([_dataArray count] < 1) {
                    if (!self.isHidden) {
                        [self showFacebookPhotoSelectionAlert];
                    }
                }
                [_collectionView reloadData];
                [_collectionView setContentOffset:CGPointZero animated:YES];
                [_collectionView scrollsToTop];
            }else{
                    if (statusCode ==401) {
                        [_dataArray removeAllObjects];
                        [_collectionView reloadData];
                        [_collectionView setContentOffset:CGPointZero animated:YES];
                        [_collectionView scrollsToTop];
                        //kAuthenticationErrorNotification
                        [[NSNotificationCenter defaultCenter] postNotificationName:kPhotoPermissionMissingNotification object:nil];
//                        [[NSNotificationCenter defaultCenter] postNotificationName:kAuthenticationErrorNotification object:nil];
                        //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Picture_Library_Close];
                        
                        [self removeFromSuperview];
                    }
            }
        }
        

    }  shouldReachServerThroughQueue:FALSE];
    
}




-(void)updateDataOnPhotoselectionInBackground:(long long int )userID{
    
    if ([_dataArray count]<1) {
        [self showActivityIndicator];
    }
    
    
    [_collectionView setContentOffset:CGPointZero animated:YES];
    NSMutableArray *newArray = [[NSMutableArray alloc]init];
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url = [NSString stringWithFormat:@"%@/user/fbAlbum/full?wooUserId=%lld",kBaseURLV7,userID];
    wooRequestObj.time = 90;
    wooRequestObj.requestParams = nil;
    wooRequestObj.methodType = getRequest;
    wooRequestObj.numberOfRetries = 1;
    wooRequestObj.cachePolicy = GET_DATA_FROM_URL_AND_UPDATE_CACHE;
    wooRequestObj.requestType = getUserProfileImage;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        
        if (requestType == getUserProfileImage) {
            if(success){
                [self hideActivityIndicator];
                if (statusCode ==401) {
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kPhotoPermissionMissingNotification object:nil];
                    //                    [self showAuthorizeFacebookAlert];
                    //kAuthenticationErrorNotification
                    
                    //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Picture_Library_Close];
                    [_dataArray removeAllObjects];
                    [self removeFromSuperview];
                    return;
                }
                
                
                if (_dataArray && [_dataArray count] > 0) {
                    [_dataArray removeAllObjects];
                }
                for (NSMutableDictionary *dict in response) {
                    BOOL doesExists = NO;
                    
                    for (NSMutableDictionary *selectedDict in _selectedImagesArray) {
                        //change by umesh on 2 April 2014
                        //                        ([[selectedDict objectForKey:@"imageURL"] isEqualToString:[dict objectForKey:@"srcBig"]] && [[selectedDict objectForKey:@"isImageAvailable"] boolValue]) to below
                        
                        if (([[selectedDict objectForKey:@"imageID"] longLongValue] ==[[dict objectForKey:@"objectId"] longLongValue]) && [[selectedDict objectForKey:@"isImageAvailable"] boolValue]) {
                            doesExists = YES;
                            
                            break;
                        }else{
                            doesExists = NO;
                        }
                    }
                    if (!doesExists) {
                        
                        if ([dict objectForKey:@"isFakePhoto"] != [NSNull null] && [[dict objectForKey:@"isFakePhoto"] boolValue] == YES) {
                            continue;
                        }
                        [newArray addObject:dict];
                    }
                }
                _dataArray = newArray;
                if ([_dataArray count] < 1) {
                    if (!self.isHidden) {
//                        [self showFacebookPhotoSelectionAlert];
                        [self removeFromSuperview];
                    }
                }
                [_collectionView reloadData];
                [_collectionView setContentOffset:CGPointZero animated:YES];
                [_collectionView scrollsToTop];
            }else{
                if (statusCode ==401) {
                    [_dataArray removeAllObjects];
                    [_collectionView reloadData];
                    [_collectionView setContentOffset:CGPointZero animated:YES];
                    [_collectionView scrollsToTop];
                    //kAuthenticationErrorNotification
                    [[NSNotificationCenter defaultCenter] postNotificationName:kPhotoPermissionMissingNotification object:nil];
                    //                        [[NSNotificationCenter defaultCenter] postNotificationName:kAuthenticationErrorNotification object:nil];
                    //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Picture_Library_Close];
                    
                    [self removeFromSuperview];
                }
            }
        }
        
        
    }  shouldReachServerThroughQueue:FALSE];
    
}


-(void)showFacebookPhotoSelectionAlert{
    U2AlertView *facebookAlert = [[U2AlertView alloc] init];
    NSString *headerStr = NSLocalizedString(@"Add a photo on Facebook", nil);
    NSString *msgStr = NSLocalizedString(@"Please upload a photo on Facebook where your face is clearly visible", nil);
    NSString *okButtonText = NSLocalizedString(@"CMP00356", nil);
    [facebookAlert alertWithHeaderText:headerStr description:msgStr leftButtonText:okButtonText andRightButtonText:nil];
    
    [facebookAlert setU2AlertActionBlockForButton:^(int tagValue , id data){
        [self callbackForButtonTappedOnFacebookAlert];
    }];

    [facebookAlert show];
}


-(void)callbackForButtonTappedOnFacebookAlert{
    NSString *urlString = [NSString stringWithFormat:@"fb://profile"];
    [self removeFromSuperview];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://fb.com/%@?v=photos",[[NSUserDefaults standardUserDefaults] objectForKey:kFacebookNumbericUserID]]]];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


#pragma mark - Collection View methods

-(void)setupCollectionView{
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    [flowLayout setItemSize:CGSizeMake(75, 75)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    [_collectionView setCollectionViewLayout:flowLayout];
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 12, 15, 12);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 15;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"count >>> %lu",(unsigned long)[_dataArray count]);
    return [_dataArray count];
    
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"PhotoSelectionCell";
    
    PhotoSelectionCell *cell = (PhotoSelectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [cell setDelegate:self];
    [cell setSelectorOnButtonTapped:@selector(imageSelectedForData:)];
    
    NSMutableDictionary *tempDataDictionaryForCell =(NSMutableDictionary *)[_dataArray objectAtIndex:indexPath.row];
    
    [cell updateDataOnCellFromDictionay:tempDataDictionaryForCell];
    cell.layer.shadowOpacity = 1.0;
    cell.layer.shadowOpacity = 0.5;
    cell.layer.cornerRadius = 5;
    cell.layer.masksToBounds = YES;
    return cell;
    
}



-(void)imageSelectedForData:(NSMutableDictionary *)dataDict{

    //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Picture_Selection_Done];
    NSMutableDictionary *tempDataDict = [[NSMutableDictionary alloc]init];
    
    [tempDataDict setObject:[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"objectId"]] forKey:@"imageID"];
    [tempDataDict setObject:@"1" forKey:@"isImageAvailable"];
    [tempDataDict setObject:[NSString stringWithFormat:@"%@",[dataDict objectForKey:kBigImageSourceKey]] forKey:@"imageURL"];
    if ([_userDataDict objectForKey:@"location"]) {
        [tempDataDict setObject:[_userDataDict objectForKey:@"location"] forKey:@"location"];
    }
    else{
        [tempDataDict setObject:@"1" forKey:@"location"];
    }
    
    if ([_userDataDict objectForKey:@"initialIndex"]) {
        [tempDataDict setObject:[_userDataDict objectForKey:@"initialIndex"] forKey:@"initialIndex"];
    }
    else{
        [tempDataDict setObject:@"1" forKey:@"initialIndex"];
    }
    
    
    
    if ([dataDict objectForKey:@"isFakePhoto"] == [NSNull null]) {

        [tempDataDict setObject:@"-1" forKey:@"isFakePhoto"];
        
    }else{
        ([[dataDict objectForKey:@"isFakePhoto"] boolValue]?[tempDataDict setObject:@"1" forKey:@"isFakePhoto"]:[tempDataDict setObject:@"0" forKey:@"isFakePhoto"]);
//        [tempDataDict setObject:[dataDict objectForKey:@"isFakePhoto"] forKey:@"isFakePhoto"];
        
    }
    
    if ([_delegate respondsToSelector:_selectorForImageTapped]) {
        [_delegate performSelector:_selectorForImageTapped withObject:tempDataDict];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //[APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Picture_Library_Close];

    [self removeFromSuperview];
}

-(void)showActivityIndicator{
    if (!waitingForFacebookAlbumIndicator) {
        waitingForFacebookAlbumIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    waitingForFacebookAlbumIndicator.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    [self addSubview:waitingForFacebookAlbumIndicator];
    [waitingForFacebookAlbumIndicator startAnimating];
}
-(void)hideActivityIndicator{
    if ([waitingForFacebookAlbumIndicator isAnimating]) {
        [waitingForFacebookAlbumIndicator stopAnimating];
        [waitingForFacebookAlbumIndicator removeFromSuperview];
        waitingForFacebookAlbumIndicator = nil;
    }
}

@end
