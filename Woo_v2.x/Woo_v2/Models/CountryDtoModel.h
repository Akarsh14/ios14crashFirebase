//
//  CountryDtoModel.h
//  Woo_v2
//
//  Created by Akhil Singh on 06/06/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CountryDtoModel : NSObject

@property (nonatomic, strong) NSString          *countryCode;
@property (nonatomic, strong) NSString          *countryName;
@property (nonatomic, assign) int               maxAllowedDigit;
@property (nonatomic, assign) int               minAllowedDigit;

- (void)updateDataWithCountryDtoDictionary:(NSDictionary*) countyDict;

@end
