//
//  WooPlusModel.m
//  Woo_v2
//
//  Created by Deepak Gupta on 7/13/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "WooPlusModel.h"

@implementation WooPlusModel


+ (WooPlusModel *)sharedInstance {
    static WooPlusModel *sharedInstance = nil;
    if (!sharedInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
            NSData *decodedObject = [userDefault objectForKey: @"WooPlusModel"];
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
    }
    return sharedInstance;
}


+ (id)allocWithZone:(NSZone *)zone {
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    NSData *decodedObject = [userDefault objectForKey: @"WooPlusModel"];
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
    [encoder encodeObject:[NSNumber numberWithBool:self.availableInRegion] forKey:@"availableInRegion"];
    [encoder encodeObject:[NSNumber numberWithBool:self.isExpired] forKey:@"expired"];
    [encoder encodeObject:self.subscriptionId forKey:@"subscriptionId"];
    [encoder encodeObject:[NSNumber numberWithFloat:self.hasEverPurchased] forKey:@"hasEverPurchased"];
    
    [encoder encodeObject:[NSNumber numberWithBool:self.showExpiryEnabledForVisitors] forKey:@"showExpiryEnabledForVisitors"];
    [encoder encodeObject:[NSNumber numberWithBool:self.maskingEnabledForVisitors] forKey:@"maskingEnabledForVisitors"];
    [encoder encodeObject:[NSNumber numberWithBool:self.showExpiryEnabledForLikedMe] forKey:@"showExpiryEnabledForLikedMe"];
    [encoder encodeObject:[NSNumber numberWithBool:self.maskingEnabledForLikedMe] forKey:@"maskingEnabledForLikedMe"];
    [encoder encodeObject:[NSNumber numberWithBool:self.showExpiryEnabledForSkippedProfiles] forKey:@"showExpiryEnabledForSkippedProfiles"];
    [encoder encodeObject:[NSNumber numberWithBool:self.maskingEnabledForSkippedProfiles] forKey:@"maskingEnabledForSkippedProfiles"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if( self != nil )
    {
        //decode properties, other class vars
        self.availableInRegion = [[decoder decodeObjectForKey:@"availableInRegion"] boolValue];
        self.isExpired = [[decoder decodeObjectForKey:@"expired"] boolValue];
        //54321
      //  self.isExpired = true;
        self.subscriptionId = [decoder decodeObjectForKey:@"subscriptionId"];
        
        self.hasEverPurchased = [decoder decodeObjectForKey:@"hasEverPurchased"];
        
        self.showExpiryEnabledForVisitors = [[decoder decodeObjectForKey:@"showExpiryEnabledForVisitors"] boolValue];
        self.maskingEnabledForVisitors = [[decoder decodeObjectForKey:@"maskingEnabledForVisitors"] boolValue];

        self.showExpiryEnabledForLikedMe = [[decoder decodeObjectForKey:@"showExpiryEnabledForLikedMe"] boolValue];
        self.maskingEnabledForLikedMe = [[decoder decodeObjectForKey:@"maskingEnabledForLikedMe"] boolValue];
        
        self.showExpiryEnabledForSkippedProfiles = [[decoder decodeObjectForKey:@"showExpiryEnabledForSkippedProfiles"] boolValue];
        self.maskingEnabledForSkippedProfiles = [[decoder decodeObjectForKey:@"maskingEnabledForSkippedProfiles"] boolValue];
    }
    return self;
}


- (void)updateDataWithWooPlusDictionary:(NSDictionary*)wooPlusDict{
    _availableInRegion  = [wooPlusDict valueForKey:@"availableInRegion"] ? [[wooPlusDict valueForKey:@"availableInRegion"] boolValue] : NO;
    _isExpired  = [wooPlusDict valueForKey:@"expired"] ? [[wooPlusDict valueForKey:@"expired"] boolValue] : YES;
    _subscriptionId = [wooPlusDict valueForKey:@"subscriptionId"] ? [wooPlusDict valueForKey:@"subscriptionId"] : @"";
    _hasEverPurchased = [wooPlusDict valueForKey:@"hasEverPurchased"] ? [[wooPlusDict valueForKey:@"hasEverPurchased"] boolValue] : NO;
    [self appTerminationHandler];
    //54321
//        self.showExpiryEnabledForVisitors = false;
//        self.maskingEnabledForVisitors = true;
//        self.showExpiryEnabledForLikedMe = false;
//        self.maskingEnabledForLikedMe = false;
//        self.showExpiryEnabledForSkippedProfiles = false;
//       self.maskingEnabledForSkippedProfiles = false;
//     _isExpired =        true;
}

-(void) appTerminationHandler{
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:self];
    [userDefault setObject:encodedObject forKey:@"WooPlusModel"];
    [userDefault synchronize];
}

- (void)resetModel{
    _availableInRegion  = NO;
    _isExpired =        YES;
    _hasEverPurchased  = NO;
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:@"WooPlusModel"];
}


@end
 
