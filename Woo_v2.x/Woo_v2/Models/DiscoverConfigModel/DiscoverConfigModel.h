//
//  DiscoverConfigModel.h
//  Woo_v2
//
//  Created by Akhil Singh on 29/04/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiscoverConfigModel : NSObject

@property (nonatomic, assign)BOOL availableForCity;

@property (nonatomic, assign)BOOL isHidden;

@property (nonatomic, assign)BOOL isNewUserNoPicScenario;

@property (nonatomic, assign)BOOL noMatchesYet;

@property (nonatomic, assign)BOOL narrowPrefrences;

/*!
 * @discussion method to get the shared Instance of the Class
 * @return AppLaunchModel shared instance Object
 */
+ (DiscoverConfigModel *)sharedInstance;
/*!
 * @discussion Updates the shared instance properties with given data
 * @param data Dictionary type of data with appLaunch Info
 */
- (void)updateModelWithData:(NSDictionary*)data;


@end
