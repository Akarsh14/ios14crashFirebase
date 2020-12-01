//
//  DiscoverConfigModel.m
//  Woo_v2
//
//  Created by Akhil Singh on 29/04/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "DiscoverConfigModel.h"

@implementation DiscoverConfigModel

+ (DiscoverConfigModel *)sharedInstance {
    static DiscoverConfigModel *sharedInstance = nil;
    if (!sharedInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
                NSData *decodedObject = [userDefault objectForKey: @"DiscoverConfigModel"];
                if (decodedObject) {
                    sharedInstance = [NSKeyedUnarchiver unarchiveObjectWithData: decodedObject];
                }
                else{
                    sharedInstance = [[super allocWithZone:NULL] init];
                }
                [[NSNotificationCenter defaultCenter] addObserver:sharedInstance
                                                         selector:@selector(appTerminationHandler)
                                                             name:UIApplicationWillTerminateNotification
                                                           object:nil];
            });
        });
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    NSData *decodedObject = [userDefault objectForKey: @"DiscoverConfigModel"];
    if (decodedObject == nil) {
        return [self sharedInstance];
    }
    else{
        return [super allocWithZone:zone];
    }
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    //Encode properties, other class variables, etc
    //[encoder encodeObject:[NSNumber numberWithBool:self.cameraOption] forKey:@"cameraOption"];
    [encoder encodeObject:[NSNumber numberWithBool:self.availableForCity] forKey:@"availableForCity"];
    [encoder encodeObject:[NSNumber numberWithBool:self.isHidden] forKey:@"hidden"];
    [encoder encodeObject:[NSNumber numberWithBool:self.isNewUserNoPicScenario] forKey:@"newUserNoPic"];
    [encoder encodeObject:[NSNumber numberWithBool:self.noMatchesYet] forKey:@"noMatchesYet"];
    [encoder encodeObject:[NSNumber numberWithBool:self.narrowPrefrences] forKey:@"narrowPreferences"];

}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if( self != nil )
    {
        //decode properties, other class vars
        //self.cameraOption               = [[decoder decodeObjectForKey:@"cameraOption"] boolValue];
        self.availableForCity = [[decoder decodeObjectForKey:@"availableForCity"] boolValue];
        self.isHidden = [[decoder decodeObjectForKey:@"hidden"] boolValue];
        self.isNewUserNoPicScenario = [[decoder decodeObjectForKey:@"newUserNoPic"] boolValue];
        self.noMatchesYet = [[decoder decodeObjectForKey:@"noMatchesYet"] boolValue];
        self.narrowPrefrences = [[decoder decodeObjectForKey:@"narrowPreferences"] boolValue];

    }
    return self;
}

-(void) appTerminationHandler{
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:self];
    [userDefault setObject:encodedObject forKey:@"DiscoverConfigModel"];
    [userDefault synchronize];
}

-(void)updateModelWithData:(NSDictionary*)data{
    if ([data objectForKey:@"availableForCity"])
        self.availableForCity = [[data objectForKey:@"availableForCity"] boolValue];
    
    if ([data objectForKey:@"hidden"])
        self.isHidden = [[data objectForKey:@"hidden"] boolValue];
   
    if ([data objectForKey:@"newUserNoPic"])
        self.isNewUserNoPicScenario = [[data objectForKey:@"newUserNoPic"] boolValue];
    
    if ([data objectForKey:@"noMatchesYet"])
        self.noMatchesYet = [[data objectForKey:@"noMatchesYet"] boolValue];
    
    if ([data objectForKey:@"narrowPreferences"])
        self.narrowPrefrences = [[data objectForKey:@"narrowPreferences"] boolValue];
}

@end
