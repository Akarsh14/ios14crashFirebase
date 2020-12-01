//
//  CountryDtoModel.m
//  Woo_v2
//
//  Created by Akhil Singh on 06/06/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

#import "CountryDtoModel.h"

@implementation CountryDtoModel


- (id)init{
    self = [super init];
    if (self){
        self.countryCode = @"";
        self.countryName = @"";
        self.maxAllowedDigit = 0;
        self.minAllowedDigit = 0;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.countryName forKey:@"countryName"];
    [encoder encodeObject:self.countryCode forKey:@"countryCode"];
    [encoder encodeObject:[NSNumber numberWithInt:self.maxAllowedDigit] forKey:@"maxAllowedDigit"];
    [encoder encodeObject:[NSNumber numberWithInt:self.minAllowedDigit] forKey:@"minAllowedDigit"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if( self != nil )
    {
        //decode properties, other class vars
        self.countryName         = [decoder decodeObjectForKey:@"countryName"];
        self.countryCode         = [decoder decodeObjectForKey:@"countryCode"];
        self.maxAllowedDigit     = [[decoder decodeObjectForKey:@"maxAllowedDigit"] intValue];
        self.minAllowedDigit     = [[decoder decodeObjectForKey:@"minAllowedDigit"] intValue];
    }
    return self;
}


- (void)updateDataWithCountryDtoDictionary:(NSDictionary*) countyDict{
    
    
    if ([countyDict valueForKey:@"countryCode"]) {
        self.countryCode = [countyDict valueForKey:@"countryCode"];
    }
    
    if ([countyDict valueForKey:@"countryName"]) {
        self.countryName = [countyDict valueForKey:@"countryName"];
    }
    
    if ([countyDict valueForKey:@"maxAllowedDigit"]) {
        self.maxAllowedDigit = [[countyDict valueForKey:@"maxAllowedDigit"] intValue];
    }
    
    if ([countyDict valueForKey:@"minAllowedDigit"]) {
        self.minAllowedDigit = [[countyDict valueForKey:@"minAllowedDigit"] intValue];
    }
    }

@end
