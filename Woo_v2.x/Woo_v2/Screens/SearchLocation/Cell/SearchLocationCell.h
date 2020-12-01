//
//  SearchLocationCell.h
//  Woo_v2
//
//  Created by Deepak Gupta on 2/25/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchLocationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateCountryLabel;

@property (weak, nonatomic) IBOutlet UILabel *specificLocationLbl;


@end
