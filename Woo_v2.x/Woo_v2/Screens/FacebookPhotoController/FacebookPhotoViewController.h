//
//  FacebookPhotoViewController.h
//  Woo_v2
//
//  Created by Deepak Gupta on 6/2/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FacebookPhotoViewController : UIViewController{
    
    __weak IBOutlet UICollectionView        *collectionViewObj;
    
    __weak IBOutlet UILabel                 *lblTitle;

}
@property (nonatomic , strong) NSArray     *arrPhotoData;
@property (nonatomic , strong) NSString    *albumName;

@property (assign) id  delegate;
@property (nonatomic, assign) BOOL isPresented;

-(IBAction)backButtonClicked:(id)sender;
@end
