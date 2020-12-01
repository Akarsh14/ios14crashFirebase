//
//  LocationFetchingView.m
//  Woo_v2
//
//  Created by Akhil Singh on 2/26/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "LocationFetchingView.h"

@interface LocationFetchingView ()
{
    __weak IBOutlet UIImageView *userImageView;
    LocationFetchingGetBlock _locationGetBlock;
    __weak IBOutlet UIButton *setAsMyLocationButton;
    __weak IBOutlet DY_UnderLineButton *changeButton;
    __weak IBOutlet UILabel *locationDetectedLabel;
    __weak IBOutlet UILabel *orLabel;
}
- (IBAction)setAsMyLocationTapped:(id)sender;
- (IBAction)changeButtonTapped:(id)sender;

@end
@implementation LocationFetchingView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+(LocationFetchingView* _Nonnull) createFromNIBWithOwner:(id _Nonnull)owner
                                                AndFrame:(CGRect)frame
{
    NSArray *xibArray = [[NSBundle mainBundle] loadNibNamed:@"LocationFetchingView"
                                                      owner:owner options:nil];
    LocationFetchingView *locationFetchingView= [xibArray lastObject];
    
    [locationFetchingView setFrame:frame];
    
    return locationFetchingView;
}

- (void)SetLocationName:(NSString* _Nonnull)nameOfLocation
{
    NSString *detectedLocationString = NSLocalizedString(@"We have detected your location as", nil);
    NSString *completeLocationString = [NSString stringWithFormat:@"%@ %@",detectedLocationString,nameOfLocation];
    NSMutableAttributedString *locationAttrString = [[NSMutableAttributedString alloc] initWithString:completeLocationString];
    NSRange locationBoldedRange;
    locationBoldedRange = [completeLocationString rangeOfString:nameOfLocation];
    
    [locationAttrString beginEditing];
    [locationAttrString addAttribute:NSFontAttributeName
                          value:[UIFont boldSystemFontOfSize:14.0f]
                          range:locationBoldedRange];
    [locationAttrString endEditing];
    [locationDetectedLabel setAttributedText:locationAttrString];
    
    NSString *setAsMyLocationText = NSLocalizedString(@"Set as my location", nil);
    [setAsMyLocationButton.titleLabel setText:[NSString stringWithFormat:@"   %@   ",setAsMyLocationText]];
    NSString *changeString = NSLocalizedString(@"Select Manually", nil);
    NSString *orString = NSLocalizedString(@"Or", nil);
    [orLabel setText:orString];
    [changeButton.titleLabel setText:changeString];
    [changeButton setBackgroundColor:[UIColor clearColor]];
    [changeButton setButtonLineColorBasedOnisTaggableIsCommonWithName:changeString withTagId:nil withTagsDToType:nil withIsTagable:YES withIsCommon:nil];
    
    NSURL *croppedImageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(SCREEN_WIDTH),IMAGE_SIZE_FOR_POINTS(SCREEN_WIDTH*0.8),[APP_Utilities encodeFromPercentEscapeString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooProfilePicURL]]]];
    
    NSString *placeHolderImageStr = [APP_Utilities isGenderMale:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserGender]] ? @"placeholder_male" : @"placeholder_female";
    
    [userImageView sd_setImageWithURL:croppedImageURL
               placeholderImage:[UIImage imageNamed:placeHolderImageStr]];

}

- (void)performTaskBasedOnActionPerformed:(LocationFetchingGetBlock _Nonnull)block
{
    _locationGetBlock = block;
}
- (IBAction)setAsMyLocationTapped:(id)sender {
    _locationGetBlock(NO);
}

- (IBAction)changeButtonTapped:(id)sender {
    _locationGetBlock(YES);
}
@end
