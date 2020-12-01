//
//  ScrollableCollectionViewCell.h
//  Woo_v2
//
//  Created by Akhil Singh on 12/10/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrollableCollectionViewCell : UICollectionViewCell

- (void)loadViewForType:(NSString *)carousalType withImage:(NSString *)imageName orTextData:(NSDictionary *)textData baseImageUrlName:(NSString *)baseUrlNameForImage andCurrentType:(int)currentType;

@end
