//
//  FacebookAlbumViewController.h
//  Woo_v2
//
//  Created by Deepak Gupta on 6/1/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FacebookAlbumViewController : UIViewController<UICollectionViewDelegate , UICollectionViewDataSource>{
    
    __weak IBOutlet UICollectionView        *collectionViewObj;
    
    __weak IBOutlet UILabel                 *lblNoPhotoFound;
}

@property (nonatomic , strong) NSArray     *arrAlbumData;

@property (assign) id  delegate;
@property (nonatomic, assign) BOOL isPresented;

-(IBAction)backButtonClicked:(id)sender;


@end
