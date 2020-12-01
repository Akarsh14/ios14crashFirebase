//
//  PurchaseOptionViewController.h
//  Woo_v2
//
//  Created by Deepak Gupta on 12/29/15.
//  Copyright © 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CrushPurchasedFromServer) (BOOL crushPurchasedSuccessfully);             //added by Umesh

@interface PurchaseOptionViewController : BaseViewController<UICollectionViewDataSource,UICollectionViewDelegate>{
    
    __weak IBOutlet UIScrollView        *scrollView_obj;
    
    __weak IBOutlet UIPageControl       *pageControl_obj;
    
    __weak IBOutlet UICollectionView    *collectionView_obj;
    
    __weak IBOutlet UIImageView         *imgView_bg;
    __weak IBOutlet UIView              *view_top;
    __weak IBOutlet UIView              *view_bottom;
    
    
    NSIndexPath                         *selectedIndexPath;
    
    CrushPurchasedFromServer crushPurchasedBlock;               //added by Umesh
    
    
    NSTimer             *myTimer;
}

@property(nonatomic, assign)BOOL isCrushLoaded;

@property(nonatomic, assign)BOOL isViewPushed;

@property(nonatomic, assign)BOOL needToLandOnDiscover;

-(void)setCrushPurchasedSuccessfullyBlock:(CrushPurchasedFromServer)block;              //added by Umesh

@end
