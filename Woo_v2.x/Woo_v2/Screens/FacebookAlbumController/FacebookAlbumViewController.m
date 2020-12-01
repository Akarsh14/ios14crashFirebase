//
//  FacebookAlbumViewController.m
//  Woo_v2
//
//  Created by Deepak Gupta on 6/1/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "FacebookAlbumViewController.h"
#import "ImageAPIClass.h"
#import "FacebookAlbumCollectionViewCell.h"
#import "FacebookPhotoViewController.h"

@interface FacebookAlbumViewController ()

@end

@implementation FacebookAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"%@",_arrAlbumData);
    
    if ([_arrAlbumData count]>0){
        [collectionViewObj registerNib:[UINib nibWithNibName:@"FacebookAlbumCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"FacebookAlbumCollectionViewCell"];
     
        [collectionViewObj setDelegate:self];
        [collectionViewObj setDataSource:self];
        [collectionViewObj reloadData];
        
    }
    else{
            [collectionViewObj setHidden:YES];
            [lblNoPhotoFound setHidden:NO];
    }

}

#pragma mark - ******************** Button Clicked Method *****************************
-(IBAction)backButtonClicked:(id)sender{
    if (_isPresented)
        [self dismissViewControllerAnimated:YES completion:nil];
    else
        [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UICollectionView Delegate
- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//    if (IS_IPHONE_4 || IS_IPHONE_5)
//        return UIEdgeInsetsMake(0, 10, 0, 10); // top, left, bottom, right
//    else
    
    
    if (IS_IPHONE_6P)
        return UIEdgeInsetsMake(0, 8, 0, 8); // top, left, bottom, right
    else
        return UIEdgeInsetsMake(0, 10, 0, 10); // top, left, bottom, right
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
    
    CGSize size = flowLayout.itemSize;
    
//    if (IS_IPHONE_4 || IS_IPHONE_5)
//        size.width = (SCREEN_WIDTH - 32)/3;
//    else
    if (IS_IPHONE_6P)
        size.width = (SCREEN_WIDTH - 38)/3;
    else
        size.width = (SCREEN_WIDTH - 32)/3;
    
    size.height = size.width;
    return size;
    
    
}



-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_arrAlbumData count];
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"FacebookAlbumCollectionViewCell";
    FacebookAlbumCollectionViewCell *cell = (FacebookAlbumCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
//    if (IS_IPHONE_4 || IS_IPHONE_5)
//        [cell updateDataOnCellFromDictionay:[_arrAlbumData objectAtIndex:indexPath.row] withBottomViewVisible:YES withWidth:(SCREEN_WIDTH - 32)/3 withHeight:(SCREEN_WIDTH - 32)/3];
//    else
    
    if (IS_IPHONE_6P)
        [cell updateDataOnCellFromDictionay:[_arrAlbumData objectAtIndex:indexPath.row] withBottomViewVisible:YES withWidth:(SCREEN_WIDTH - 38)/3 withHeight:(SCREEN_WIDTH - 38)/3];
        else
        [cell updateDataOnCellFromDictionay:[_arrAlbumData objectAtIndex:indexPath.row] withBottomViewVisible:YES withWidth:(SCREEN_WIDTH - 32)/3 withHeight:(SCREEN_WIDTH - 32)/3];
   
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    NSLog(@"Selected Album Data = %@",[_arrAlbumData objectAtIndex:indexPath.row]);
    
    [self getPhotoForFbAlbumData:[_arrAlbumData objectAtIndex:indexPath.row]forIndexPath:indexPath];
    
}


#pragma mark - Get Photo For Album
- (void) getPhotoForFbAlbumData : (NSDictionary *)albumData forIndexPath:(NSIndexPath *)indexPath{
    
    if(!albumData)
        return;
    
    if ([[albumData objectForKey:@"photo_count"] intValue] < 1) {
        
        U2AlertView *alert = [[U2AlertView alloc] init];
        [alert alertWithHeaderText:NSLocalizedString(@"No Photo Found",nil) description:NSLocalizedString(@"No photo found", nil) leftButtonText:NSLocalizedString(@"OK", nil) andRightButtonText:nil];
        [alert show];
        
        return;
    }
    
    [ImageAPIClass fetchDataFromWebServiceForUserID:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]] forFacebookAlbum:[NSString stringWithFormat:@"%@",[albumData objectForKey:@"id"]] AndCompletionBlock:^(id response, BOOL success, int statusCode) {
        
        [APP_Utilities hideActivityIndicator];
        
        NSLog(@"%@",response);
        
        if (success)
            if (response) {
                
                FacebookPhotoViewController *photoObj;
                photoObj = [self.storyboard instantiateViewControllerWithIdentifier:kFacebookPhotoControllerID];
                photoObj.arrPhotoData = [response objectForKey:@"photos"];
                
                if ([photoObj.arrPhotoData count] < 1) { // if there is no image in the album.
                    
                    UIAlertController *reportAlertcontroller = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"No photo found", @"") preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleCancel
                                                                         handler:^(UIAlertAction *action) {
                                                                             
                                                                         }];
            ;
                    
                    [reportAlertcontroller addAction:okAction];
                    
                   // [reportAlertcontroller.view setTintColor:kHeaderTextRedColor];
                    [self presentViewController:reportAlertcontroller animated:YES completion:^{
                       // [reportAlertcontroller.view setTintColor:kHeaderTextRedColor];
                    }];

                    return;
                    
                }
                
                photoObj.albumName = [[_arrAlbumData objectAtIndex:indexPath.row] objectForKey:@"albumName"];
                photoObj.delegate = _delegate;
                photoObj.isPresented = _isPresented;
                
                if (_isPresented)
                    [self presentViewController:photoObj animated:YES completion:nil];
                else
                    [self.navigationController pushViewController:photoObj animated:YES];
            }
        
    }];

//[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
