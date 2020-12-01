//
//  AlbumSelectionView.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 11/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "AlbumSelectionView.h"
#import "AlbumSelectionCell.h"
#import "ImageAPIClass.h"

@implementation AlbumSelectionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    //check if memory is allocated to self
    if (self) {
        NSArray *viewArrayFromXib = [[NSBundle mainBundle] loadNibNamed:@"AlbumSelectionView" owner:self options:nil];
        UIView *viewObj = [viewArrayFromXib objectAtIndex:0];
        viewObj.frame = self.bounds;
        [self addSubview:viewObj];
        
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapOnView:)];
        
        [backgroundView addGestureRecognizer:singleFingerTap];
    }
    return self;
}

-(void)handleSingleTapOnView:(id)tapData{
    [self removeFromSuperview];
}

-(void)fetchAlbums{
    [ImageAPIClass fetchAlbumsWithCompletionBlock:^(id response, BOOL success , int statusCode) {
            _albumDataArray = [[response objectForKey:@"albums"] mutableCopy];
            [self fetchMoreAlbums:response];
            [albumTableView reloadData];
    }];
}

-(void)fetchMoreAlbums:(NSDictionary *)responseDictionary{

    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    BOOL isNetworkReachable = (reachability.isReachable || reachability.isReachableViaWiFi || reachability.isReachableViaWWAN);
    if (!isNetworkReachable) {
        SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"Please check your internet connection",nil));
        return;
    }
    
    [ImageAPIClass fetchMoreAlbums:responseDictionary AndCompletionBlock:^(id response, BOOL success , int statusCode) {
        if ([_albumDataArray count]>0) {
            [_albumDataArray addObjectsFromArray:[response objectForKey:@"albums"]];
        }
        else{
            _albumDataArray = [[response objectForKey:@"albums"] mutableCopy];
        }
        [albumTableView reloadData];
    }];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_albumDataArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"AlbumSelectionCell";
    AlbumSelectionCell *cell = (AlbumSelectionCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell){
        UINib *nib = [UINib nibWithNibName:@"AlbumSelectionCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        cell = (AlbumSelectionCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    
    NSDictionary *imageDict = [_albumDataArray objectAtIndex:indexPath.row];
    
    
    if (![[imageDict objectForKey:@"photo_count"] isEqual:[NSNull null]]) {
        [cell setDataOnCellForAlbumName:[imageDict objectForKey:@"albumName"] withAbumImage:[NSURL URLWithString:[imageDict objectForKey:@"albumUrl"]] andNumberOfImages:[[imageDict objectForKey:@"photo_count"] intValue]];
    }
    
    
    return cell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([_delegate respondsToSelector:_selectorForAlbumSelected]) {
        [_delegate performSelector:_selectorForAlbumSelected withObject:[_albumDataArray objectAtIndex:indexPath.row]];
    }
    
    [self removeFromSuperview];
    
}


@end
