//
//  CompleteYourProfileCardView.m
//  Woo_v2
//
//  Created by Umesh Mishra on 09/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "CompleteYourProfileCardView.h"

@implementation CompleteYourProfileCardView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        NSArray *arrayObj = [[NSBundle mainBundle] loadNibNamed:@"CompleteYourProfileCardView" owner:self options:nil];
        UIView *viewObj = [arrayObj objectAtIndex:0];
        viewObj.frame = frame;
        [self addSubview:viewObj];
    }
    return self;
}

-(void)addProgressViewWithProgress:(float)progressVal{

    [APP_DELEGATE sendSwrveEventWithEvent:@"DiscoverEmpty.CompleteProfile" andScreen:@"DiscoverEmpty"];

    float xPosOfProgressView = 36;
    float yPosOfProgressView = 0;
    
    if (!progressViewObj) {
        progressViewObj = [[LDProgressView  alloc] initWithFrame:CGRectMake(xPosOfProgressView, yPosOfProgressView, 247, 5)];
        progressViewObj.color = [UIColor colorWithRed:232.0f/255.0f green:89.0f/255.0f blue:90.0f/255.0f alpha:1.0f];
        progressViewObj.showText = @NO;
        progressViewObj.progress = 0.0;
        progressViewObj.borderRadius = @5;
        progressViewObj.animate = @YES;
        progressViewObj.background = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
        progressViewObj.type = LDProgressSolid;
    }
    
    if ((progressVal*100)<10) {
        progressVal = 0.35;
    }
    [progressViewObj setProgress:progressVal];
    [progressViewContainer addSubview:progressViewObj];
    
    if (!titleLabel) {
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, yPosOfProgressView+15, self.frame.size.width, 25)];
    }
    
    titleLabel.font = [UIFont fontWithName:kHeavenetica6MedSH size:19];
    titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Your profile is %d%% complete", nil),(int)(progressVal*100)];
    titleLabel.textColor = [UIColor colorWithRed:232.0/255.0 green:89.0/255.0 blue:90.0/255.0 alpha:1.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.center = CGPointMake(progressViewContainer.frame.size.width/2, titleLabel.center.y);
    [progressViewContainer addSubview:titleLabel];
}
-(void)setName:(NSString *)userName andAge:(NSString *)userAge{
    nameAgeLabel.text = [NSString stringWithFormat:@"%@, %@",userName,userAge];
    
    NSURL *ImageCroppedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(290),IMAGE_SIZE_FOR_POINTS(230),[APP_Utilities encodeFromPercentEscapeString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooProfilePicURL]]]];

    [userProfileImage sd_setImageWithURL:ImageCroppedUrl placeholderImage:([APP_Utilities isGenderMale:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserGender]]?[UIImage imageNamed:@"placeholder_male"]:[UIImage imageNamed:@"placeholder_female"])];
    
    userProfileImage.layer.masksToBounds = YES;
    userProfileImage.layer.cornerRadius = 5.0f;
}

-(IBAction)completeYourProfileButtonTapped:(id)sender{
    if ([_delegate respondsToSelector:_selectorCompleteYourProfileButtonTapped]) {
        [_delegate performSelector:_selectorCompleteYourProfileButtonTapped withObject:nil afterDelay:0.0];
    }
}

@end
