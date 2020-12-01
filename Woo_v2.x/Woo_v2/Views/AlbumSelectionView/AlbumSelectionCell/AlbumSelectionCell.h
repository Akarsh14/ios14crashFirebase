//
//  AlbumSelectionCell.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 13/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumSelectionCell : UITableViewCell{
    
    __weak IBOutlet UIImageView *albumKeyImage;
    __weak IBOutlet UILabel *albumNameLabel;
    __weak IBOutlet UILabel *imageInAlbumLabel;
    
}
-(void)setDataOnCellForAlbumName:(NSString *)nameOfAlbum withAbumImage:(NSURL *)imageURL andNumberOfImages:(int )imagesInAlbum;


@end
