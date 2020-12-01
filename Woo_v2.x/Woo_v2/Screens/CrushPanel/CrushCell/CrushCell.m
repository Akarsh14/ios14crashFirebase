//
//  CrushCell.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 18/01/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "CrushCell.h"

@implementation CrushCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void)setDataOnCellFromObj:(CrushesDashboard *)dashboardObj{
    
    [crushMessageLabel sizeToFit];
    dashboard = dashboardObj;
    
    NSURL *croppedImageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(kCircularImageSize),IMAGE_SIZE_FOR_POINTS(kCircularImageSize),[APP_Utilities encodeFromPercentEscapeString:dashboardObj.imageURL]]];
    
    [userImage sd_setImageWithURL:croppedImageURL placeholderImage:[UIImage imageNamed:@"ic_me_avatar_big"]];

    if ([dashboardObj.hasSeen boolValue]) {
        
        [crushAge setTextColor:kBlackThemeV3];
        [crushName setTextColor:kBlackThemeV3];
        [crushMessageLabel setTextColor:[UIColor colorWithRed:114.0f/255.0f green:119.0f/255.0f blue:138.0f/255.0f alpha:1.0]];
        [crushMessageLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:16.0f]];
        
    }else{
        
        [crushAge setTextColor:[UIColor colorWithRed:117.0f/255.0f green:196.0f/255.0f blue:219.0f/255.0f alpha:1.0]];
        [crushName setTextColor:[UIColor colorWithRed:117.0f/255.0f green:196.0f/255.0f blue:219.0f/255.0f alpha:1.0]];
        [crushMessageLabel setTextColor:kBlackThemeV3];
        [crushMessageLabel setFont:[UIFont fontWithName:@"Lato-Semibold" size:16.0f]];
    }
    [crushAge setText:dashboardObj.userAge];
    [crushName setText:[NSString stringWithFormat:@"%@,",dashboardObj.userName]];
    
    [crushMessageLabel setText:dashboardObj.crushMessage];
  
}

- (IBAction)likeButtonTapped:(UIButton*)sender {
    [self.crushCellButtonTappedDelegate likeButtonTappedWithCrushValue:dashboard];
}

- (IBAction)dislikeButtonTapped:(UIButton*)sender {
    [self.crushCellButtonTappedDelegate dislikeButtonTappedWithCrushValue:dashboard];
}

@end
