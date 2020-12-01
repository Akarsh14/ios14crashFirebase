//
//  LeftPanelImageView.m
//  Woo_v2
//
//  Created by Suparno Bose on 04/01/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "LeftPanelImageView.h"
#import "UIImageEffects.h"

@implementation LeftPanelImageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(void) setIsProfileBoosted:(BOOL)isProfileBoosted{
    _isProfileBoosted = isProfileBoosted;
    [boostImageView setHidden:!_isProfileBoosted];
}

-(void) setIsProfileMale:(BOOL)isProfileMale{
    _isProfileMale = isProfileMale;
}

-(UIImage*) blurImageOf:(UIImage*) image{
    
    return [UIImageEffects imageByApplyingBlurToImage:image
                                           withRadius:10.0
                                            tintColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2]
                                saturationDeltaFactor:1.0
                                            maskImage:nil];
}

-(void)setRoundedView:(UIImageView *)roundedView toDiameter:(float)newSize;
{
    CGPoint saveCenter = roundedView.center;
    CGRect newFrame = CGRectMake(roundedView.frame.origin.x, roundedView.frame.origin.y, newSize, newSize);
    roundedView.frame = newFrame;
    roundedView.layer.cornerRadius = newSize / 2.0;
    roundedView.center = saveCenter;
    [roundedView.layer setBorderWidth:2.0f];
    [roundedView.layer setBorderColor:[[UIColor whiteColor] CGColor]];

}

-(void) setProfileImageWithUrl:(NSURL*) url{
    
    CGFloat roundRadius = 0;
    roundRadius = SCREEN_WIDTH *(32.1875/100);
    circularImageView.clipsToBounds = YES;
    [self setRoundedView:circularImageView toDiameter:roundRadius];
    
    NSString *placeHolderImageStr = _isProfileMale ? @"placeholder_male" : @"placeholder_female";
    [circularImageView setImage:[UIImage imageNamed:placeHolderImageStr]];
    [blurImageView setImage:[self blurImageOf:[UIImage imageNamed:placeHolderImageStr]]];
    
    if (url) {
        [blurImageView sd_setImageWithURL:url
                         placeholderImage:[self blurImageOf:[UIImage imageNamed:placeHolderImageStr]]
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
                                    [circularImageView setImage:image];
                                    [blurImageView setImage:[self blurImageOf:image]];
                                }];
    }
    else{
        [blurImageView setImage:[self blurImageOf:[UIImage imageNamed:placeHolderImageStr]]];
        [circularImageView setImage:[UIImage imageNamed:placeHolderImageStr]];
    }
}

-(void) setUserName:(NSString*)name AndAge:(NSString*)age{
    NSString *strText = @"";
    if (age) {
        strText = [NSString stringWithFormat:@"%@, %@",name,age];
    }
    else{
        strText = [NSString stringWithFormat:@"%@",name];
    }
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:strText];
    [text addAttribute:NSFontAttributeName
                  value:[UIFont fontWithName:@"Helvetica-Bold" size:17]
                  range:NSMakeRange(0, [name length])];
    
    [nameAgeImageView setAttributedText:text];
}

-(void) addSelectorForProfileEditButton:(SEL) selector WithController:(UIViewController*) controller{
    [editProfileButton addTarget:controller action:selector forControlEvents:UIControlEventTouchUpInside];
}

-(void) addSelectorForSettingsButton:(SEL) selector WithController:(UIViewController*) controller{
    [settingButton addTarget:controller action:selector forControlEvents:UIControlEventTouchUpInside];
}

@end
