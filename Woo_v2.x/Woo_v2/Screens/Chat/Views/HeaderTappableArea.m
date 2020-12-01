//
//  HeaderTappableArea.m
//  Woo
//
//  Created by Vaibhav Gautam on 06/05/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "HeaderTappableArea.h"

@implementation HeaderTappableArea

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        NSArray *nibArray = [[NSBundle mainBundle]loadNibNamed:@"HeaderTappableArea" owner:self options:nil];
        [self addSubview:[nibArray lastObject]];
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void)setDataOnHeaderWithImage:(NSString *)imageName andUserFirstName:(NSString *)userFirstName withPlaceholderImageName:(NSString *)placeHolderImageName{
    
    NSString *trimmedName = userFirstName;
    
    if (userFirstName.length > 12) {
        trimmedName = [userFirstName substringWithRange:NSMakeRange(0, 12)];
        trimmedName = [NSString stringWithFormat:@"%@...",trimmedName];
    }
    [userName setText:trimmedName];
    [userName setTextColor:kHeaderTextRedColor];
    [userName setFont:kChatHeaderTextFont];
    
    CGSize labelSize = [[userName text] sizeWithAttributes:[[NSDictionary alloc]initWithObjectsAndKeys:[userName font],NSFontAttributeName,nil]];// @{NSFontAttributeName: [userName font]}];
    
    [userName setFrame:CGRectMake(userName.frame.origin.x, userName.frame.origin.y, labelSize.width, userName.frame.size.height)];
    
    [userName setFrame:CGRectMake(((WIDTH_OF_HEADER_VIEW/2) - (userName.frame.size.width/2)+25), userName.frame.origin.y, userName.frame.size.width, userName.frame.size.height)];
    
    [userImage setFrame:CGRectMake(userName.frame.origin.x-40, userImage.frame.origin.y, 27, 27)];
    
    [userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(kCircularImageSize),IMAGE_SIZE_FOR_POINTS(kCircularImageSize), imageName]] placeholderImage:[UIImage imageNamed:placeHolderImageName]];
    
    UIBezierPath *buttonMaskPath = [UIBezierPath bezierPathWithRoundedRect:userImage.bounds cornerRadius:4.0f];
    CAShapeLayer *buttonMaskLayer = [[CAShapeLayer alloc]init];
    buttonMaskLayer.frame = userImage.bounds;
    buttonMaskLayer.path = buttonMaskPath.CGPath;
    userImage.layer.mask = buttonMaskLayer;
    
    
}

-(void)headerTappedBlock:(void(^)())block{
    buttonTappedBlockObj = block;
}
- (IBAction)headerTapped:(id)sender {
    
    if (buttonTappedBlockObj) {
        buttonTappedBlockObj();
    }
}
@end
