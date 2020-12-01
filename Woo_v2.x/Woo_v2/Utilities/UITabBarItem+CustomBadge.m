//
//  UITabBarItem+CustomBadge.m
//  CityGlance
//
//  Created by Enrico Vecchio on 18/05/14.
//  Copyright (c) 2014 Cityglance SRL. All rights reserved.
//

#import "UITabBarItem+CustomBadge.h"


#define CUSTOM_BADGE_TAG 99
#define OFFSET 0.6f


@implementation UITabBarItem (CustomBadge)

-(void) setCustomBadgeValue: (NSString *) value isFirstTimeForMe:(BOOL)meValue  AndIsFirstTimeForMatchbox:(BOOL)matchboxValue
{
    UIView *v = (UIView *)[self performSelector:@selector(view)];
    
//    [self setBadgeValue:value];
    for(UIView *sv in v.subviews)
    {
        NSString *str = NSStringFromClass([sv class]);
        
        if([str isEqualToString:@"_UIBadgeView"])
        {
            if(meValue || matchboxValue)
            {
                CABasicAnimation *popup = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
                popup.fromValue =  [NSNumber numberWithInt:0];
                popup.toValue = [NSNumber numberWithInt:1];
                popup.duration = 0.2;
                [sv.layer addAnimation:popup forKey:@"scaleAnimation"];
                
                [sv.layer performSelector:@selector(removeAllAnimations) withObject:nil afterDelay:1.0];
            }
            sv.layer.transform = CATransform3DIdentity;
            sv.layer.transform = CATransform3DMakeTranslation(-10.0, 0.0, 1.0);
            // Fix for border
//            sv.layer.borderWidth = 0;
//            sv.layer.borderColor = [[UIColor whiteColor] CGColor];
            //[[UIColor colorWithRed:(224.0/255.0) green:(39.0/255.0) blue:(40.0/255.0) alpha: 1.0] CGColor];
//            sv.layer.cornerRadius = sv.frame.size.height/2;
//            sv.layer.masksToBounds = YES;
            
            for(UILabel *l in sv.subviews)
            {
                if ([l isKindOfClass:[UILabel class]])
                {
                    l.font =  [UIFont systemFontOfSize:11.0];
                }
            }
        }
    }
}


//-(void)addGrowthAnimation
//{
//    UIView *v = (UIView *)[self performSelector:@selector(view)];
//
//    //    [self setBadgeValue:value];
//    for(UIView *sv in v.subviews)
//    {
//        NSString *str = NSStringFromClass([sv class]);
//        if([str isEqualToString:@"_UIBadgeView"])
//        {
//            CABasicAnimation *popup = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
//            popup.fromValue =  [NSNumber numberWithInt:0];
//            popup.toValue = [NSNumber numberWithInt:1];
//            popup.duration = 1;
//            [sv.layer addAnimation:popup forKey:@"scaleAnimation"];
//        }
//    }
//}



-(void)removeGrowthAnimation
{
    UIView *v = (UIView *)[self performSelector:@selector(view)];
    
    //    [self setBadgeValue:value];
    for(UIView *sv in v.subviews)
    {
        NSString *str = NSStringFromClass([sv class]);
        if([str isEqualToString:@"_UIBadgeView"])
        {
            [sv.layer removeAllAnimations];
        }
    }
}

@end
