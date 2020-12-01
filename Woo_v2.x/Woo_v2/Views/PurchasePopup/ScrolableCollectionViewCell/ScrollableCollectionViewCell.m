//
//  ScrollableCollectionViewCell.m
//  Woo_v2
//
//  Created by Akhil Singh on 12/10/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "ScrollableCollectionViewCell.h"

@interface ScrollableCollectionViewCell(){
    float multiplier;
}
@property (weak, nonatomic) IBOutlet UIImageView *backGroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconImageToBgImageContraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconImageHeightRatioConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *aspectRatioEqualHeightsConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconWidthTwiceOfHeightConstraint;

@end

@implementation ScrollableCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"ScrollableCollectionViewCell" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex:0];
    }
    
    return self;
}

- (void)loadViewForType:(NSString *)carousalType withImage:(NSString *)imageName orTextData:(NSDictionary *)textData baseImageUrlName:(NSString *)baseUrlNameForImage andCurrentType:(int)currentType
{
    if (currentType == 4)
    {
        //Woo Globe
        if ([self.iconImageToBgImageContraint isActive] && [self.iconImageHeightRatioConstraint isActive] )
        {
            self.iconImageToBgImageContraint.active  = NO;
            self.iconImageHeightRatioConstraint.active = NO;
        }
            if(![self.aspectRatioEqualHeightsConstraint isActive] && ![self.iconWidthTwiceOfHeightConstraint isActive] )
            {
                self.aspectRatioEqualHeightsConstraint.active = YES;
                self.iconWidthTwiceOfHeightConstraint.active = YES;
            }
    }
    else
    {
        if ([self.aspectRatioEqualHeightsConstraint isActive] && [self.iconWidthTwiceOfHeightConstraint isActive] )
        {
            self.aspectRatioEqualHeightsConstraint.active = NO;
            self.iconWidthTwiceOfHeightConstraint.active = NO;
        }
        if(![self.iconImageToBgImageContraint isActive] && ![self.iconImageHeightRatioConstraint isActive] )
        {
            self.iconImageToBgImageContraint.active  = YES;
            self.iconImageHeightRatioConstraint.active = YES;
        }
    }
    
    [self layoutIfNeeded];
    
    if(multiplier == 0)
    {
        multiplier = SCREEN_WIDTH/320.0;
        if(multiplier != 1 && _descLabel.font.pointSize == 15.0)
        {

            _descLabel.font = [UIFont fontWithName:@"Lato-Regular " size:_descLabel.font.pointSize * multiplier];
        }
    }
    self.hidden = false;
    if ([carousalType isEqualToString:@"IMAGE"]) {
        _backGroundImageView.hidden = false;
        _iconImageView.hidden = true;
        _descLabel.hidden = true;
        
        NSString *backgroundImageName = [NSString stringWithFormat:@"%@%@",baseUrlNameForImage,imageName];
        NSURL *imageURL =[NSURL URLWithString:backgroundImageName];
        
        [_backGroundImageView sd_setImageWithURL:imageURL placeholderImage:[UIImage new]];
        
    }
    else if ([carousalType isEqualToString:@"TEXT"]){
        _backGroundImageView.hidden = true;
        _iconImageView.hidden = true;
        _descLabel.hidden = false;
        _descLabel.text = [textData objectForKey:@"text"];
    }
    else if ([carousalType isEqualToString:@"HYBRID"]){
        _backGroundImageView.hidden = true;
        _iconImageView.hidden = false;
        _descLabel.hidden = false;
        _descLabel.text = [textData objectForKey:@"text"];

        NSString *iconName = [NSString stringWithFormat:@"%@%@",baseUrlNameForImage,[textData objectForKey:@"iconImgUrl"]];
        NSURL *imageURL =[NSURL URLWithString:iconName];
        [_iconImageView sd_setImageWithURL:imageURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            _iconImageView.image = image;
        }];
        [_iconImageView sd_setImageWithURL:imageURL placeholderImage:[UIImage new]];

    }
    
    
}

@end
