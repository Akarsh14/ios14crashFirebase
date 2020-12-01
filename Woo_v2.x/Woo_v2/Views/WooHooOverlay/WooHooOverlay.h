//
//  WooHooOverlay.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 09/07/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DALabeledCircularProgressView.h"


@interface WooHooOverlay : UIView{
    
    __weak IBOutlet UILabel *nameLabel;
    __weak IBOutlet UIImageView *userImageView;
    __weak IBOutlet UILabel *introTextLAbel;
    __weak IBOutlet UIView *centreView;
    __weak IBOutlet UILabel *wooHooLabel;
    __weak IBOutlet UIButton *crossButton;
    
    int timeToDisplay;
    float timeElapsed;
    
    DALabeledCircularProgressView *progressView;
    
    NSTimer *loaderTimer;
    
    float stepper;
    
    BOOL crossButtonTapped;
    
    __weak IBOutlet NSLayoutConstraint *crossTopLayoutConstraint;
}

@property(nonatomic, strong)NSNumber *matchId;

- (IBAction)crossButtonTapped:(id)sender;

-(void)presentViewWithImageURL:(NSURL *)imageURL timerForConnection:(int )timer nameOfUser:(NSString *)nameOfUser andTeaserLine:(NSString *)teaserText forPresentingView:(UIView *)viweRef;

-(void)fixPlacementOfCrossButtonForScreenWithoutNavBar;

@property(nonatomic, weak)id delegate;
@property(nonatomic, assign)SEL selectorForOverlayRemoved;

@property(nonatomic, assign)SEL selectorForCrossButtonClicked;
@end
