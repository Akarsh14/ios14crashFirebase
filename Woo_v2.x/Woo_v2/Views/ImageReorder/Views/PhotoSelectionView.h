//
//  PhotoSelectionView.h
//  Woo
//
//  Created by Vaibhav Gautam on 14/02/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoSelectionView : UIView<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>{
    
    __weak IBOutlet UIView *headerView;
    __weak IBOutlet UIView *contentView;
    __weak IBOutlet UILabel *headerLabel;
    
    UIActivityIndicatorView *waitingForFacebookAlbumIndicator;
}

@property(nonatomic)id delegate;
@property(nonatomic, assign)SEL selectorForImageTapped;
@property(nonatomic, assign)SEL selectorForNoImageAvailable;

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@property(nonatomic, retain) NSMutableDictionary *userDataDict;

@property(nonatomic, retain) NSMutableArray *selectedImagesArray;


-(void)fetchDataFromWebServiceForUserID:(long long int )userID;
-(void)fetchDataFromWebServiceForUserID:(long long int )userID forFacebookAlbum:(NSString *)fbAlbumId;

//Addedby Umesh on 30 Jan 2015 to show authorize alert as per new prd.
-(void)showAuthorizeFacebookAlert;

-(void)showActivityIndicator;
-(void)hideActivityIndicator;
@end
