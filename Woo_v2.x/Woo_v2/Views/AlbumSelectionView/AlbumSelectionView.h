//
//  AlbumSelectionView.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 11/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumSelectionView : UIView<UITableViewDataSource, UITableViewDelegate>{
    
    __weak IBOutlet UITableView *albumTableView;
    __weak IBOutlet UIView *backgroundView;
    
}

-(void)fetchAlbums;

@property(nonatomic,weak) IBOutlet UIView *containerView;
@property(nonatomic, strong) NSMutableArray *albumDataArray;
@property(nonatomic, weak)id delegate;
@property(nonatomic, assign)SEL selectorForAlbumSelected;
@end
