//
//  AccountsAlertView.m
//  Woo
//
//  Created by Vaibhav Gautam on 08/11/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "AccountsAlertView.h"

@implementation AccountsAlertView


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    //check if memory is allocated to self
    if (self) {
        
        NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"AccountsAlertView" owner:self options:nil];
        [self addSubview:[nibArray lastObject]];
        [self setFrame:[[nibArray lastObject] frame]];
    
    }
    self.tickIndex = 0;
    [self setStatusOfTicks];
    
    return self;
}

- (IBAction)logoutButtonTapped {
//    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Select_Logout_From_Account forScreenName:@"SE"];
    self.tickIndex = 0;
    [self setStatusOfTicks];
}

- (IBAction)deleteButtonTapped:(id)sender {
    
//    [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:Select_Delete_Account_From_Account forScreenName:@"SE"];
    
    _tickIndex = 1;
    [self setStatusOfTicks];
}

-(void)setStatusOfTicks{
    switch (_tickIndex) {
        case 0:
            [logoutTickButton setImage:[UIImage imageNamed:@"profile_radioselected"] forState:UIControlStateNormal];
            [deleteTickButton setImage:[UIImage imageNamed:@"profile_radioselect"] forState:UIControlStateNormal];
            
            break;
        case 1:
            [logoutTickButton setImage:[UIImage imageNamed:@"profile_radioselect"] forState:UIControlStateNormal];
            [deleteTickButton setImage:[UIImage imageNamed:@"profile_radioselected"] forState:UIControlStateNormal];
            
            break;
            
        default:
            break;
    }
}
-(void)setFirstoption:(NSString *)firstOption andSecondOption:(NSString *)secondOption{
    
    if ([firstOption length]>0) {
        firstOptionLabel.text = firstOption;
    }
    
    if ([secondOption length]>0) {
        secondOptionLabel.text = secondOption;
    }
    
}
@end
