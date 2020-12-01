//
//  LocationManager.h
//  Woo_v2
//
//  Created by Suparno Bose on 04/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^UserLocationFetched)(BOOL success ,CLLocation *locationObj);

@interface LocationManager : NSObject<CLLocationManagerDelegate>{
    UserLocationFetched fetchedUserLocationCompleteBlock;
    BOOL doNotChangeBlock;
    BOOL hideSearchPredicationView;
}

- (instancetype)initWithParentViewController:(UIViewController*) parent;

- (BOOL)isLocationAvailable;

- (void)startGetLocationFlow;

- (BOOL)isWooAllowedForLocation;

-(void)gettingUserCurrentLocationForDiscover;

-(void)getUserCurrentLocation:(UserLocationFetched)block;

-(void)getUserCurrentLocation:(UserLocationFetched)block withoutChangingBlock:(BOOL)doNotchangeTab;

- (void)moveToSearchLocationScreen;
- (void)makeLocationStringFromLatLongAndStartTheFlowForLocation:(CLLocation *)locationObj;
- (void)makeLocationStringFromLatLongAndStartTheFlowForLocation:(CLLocation *)locationObj withCompletion:(void(^)(BOOL done, NSString *cityName))block;
-(BOOL)checkIfUserIsAuthorisedToUseUserLocationOrNot;

@end
