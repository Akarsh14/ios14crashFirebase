//
//  FacebookPhotoViewController.m
//  Woo_v2
//
//  Created by Deepak Gupta on 6/2/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "FacebookPhotoViewController.h"

#import "FacebookAlbumCollectionViewCell.h"


@interface FacebookPhotoViewController ()

@end

@implementation FacebookPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"%@",_arrPhotoData);
    [collectionViewObj registerNib:[UINib nibWithNibName:@"FacebookAlbumCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"FacebookAlbumCollectionViewCell"];
    
    [lblTitle setText:_albumName];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ******************** Button Clicked Method *****************************
-(IBAction)backButtonClicked:(id)sender{
    //[self.navigationController popViewControllerAnimated:YES];
    
    if (_isPresented)
        [self dismissViewControllerAnimated:YES completion:nil];
    else
        [self.navigationController popViewControllerAnimated:YES];

}



#pragma mark - UICollectionView Delegate
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
//    if (IS_IPHONE_4 || IS_IPHONE_5)
//        return UIEdgeInsetsMake(0, 11, 0, 11); // top, left, bottom, right
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
//        size.width = (SCREEN_WIDTH - 25)/2;
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
    return [_arrPhotoData count];
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"FacebookAlbumCollectionViewCell";
    FacebookAlbumCollectionViewCell *cell = (FacebookAlbumCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
//    if (IS_IPHONE_4 || IS_IPHONE_5)
//        [cell updateDataOnCellFromDictionay:[_arrPhotoData objectAtIndex:indexPath.row] withBottomViewVisible:NO withWidth:(SCREEN_WIDTH - 25)/3 withHeight:(SCREEN_WIDTH - 25)/3];
//    else
    
    if (IS_IPHONE_6P)
        [cell updateDataOnCellFromDictionay:[_arrPhotoData objectAtIndex:indexPath.row] withBottomViewVisible:NO withWidth:(SCREEN_WIDTH - 38)/3 withHeight:(SCREEN_WIDTH - 38)/3];
    else
        [cell updateDataOnCellFromDictionay:[_arrPhotoData objectAtIndex:indexPath.row] withBottomViewVisible:NO withWidth:(SCREEN_WIDTH - 32)/3 withHeight:(SCREEN_WIDTH - 32)/3];


    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    NSLog(@"Selected Album Data = %@",[_arrPhotoData objectAtIndex:indexPath.row]);

    
    if ([_delegate respondsToSelector:@selector(selectedPhotoData:)]) {
        [_delegate performSelector:@selector(selectedPhotoData:) withObject:[_arrPhotoData objectAtIndex:indexPath.row]];
        
        
        if (_isPresented){
      //      [[[self parentViewController] parentViewController] dismissViewControllerAnimated:YES completion:nil];
            [[self.presentingViewController presentingViewController] dismissViewControllerAnimated:YES completion:nil];
        } else
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-3] animated:YES];
        
        
    }
    
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
