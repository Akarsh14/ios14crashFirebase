//
//  BoostModel.m
//  Woo_v2
//
//  Created by Suparno Bose on 12/01/16.
//  Copyright © 2016 Woo. All rights reserved.
//

#import "BoostModel.h"

@implementation BoostModel

+ (BoostModel *)sharedInstance {
    static BoostModel *sharedInstance = nil;
    if (!sharedInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
            NSData *decodedObject = [userDefault objectForKey: @"BoostModel"];
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
    NSData *decodedObject = [userDefault objectForKey: @"BoostModel"];
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
    [encoder encodeObject:[NSNumber numberWithInteger:self.availableBoost] forKey:@"availableBoost"];
    [encoder encodeObject:[NSNumber numberWithBool:self.availableInRegion] forKey:@"availableInRegion"];
    [encoder encodeObject:[NSNumber numberWithFloat:self.percentageCompleted] forKey:@"percentageCompleted"];
    [encoder encodeObject:[NSNumber numberWithFloat:self.hasEverPurchased] forKey:@"hasEverPurchased"];
    [encoder encodeObject:[NSNumber numberWithBool:self.showInLeftMenu] forKey:@"showInLeftMenu"];
    [encoder encodeObject:[NSNumber numberWithUnsignedLongLong:self.expiryTime] forKey:@"expiryTime"];
    [encoder encodeObject:[NSNumber numberWithBool:self.currentlyActive] forKey:@"currentlyActive"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if( self != nil )
    {
        //decode properties, other class vars
        self.availableBoost         = [[decoder decodeObjectForKey:@"availableBoost"] integerValue];
        self.availableInRegion      = [[decoder decodeObjectForKey:@"availableInRegion"] boolValue];
        self.percentageCompleted    = [[decoder decodeObjectForKey:@"percentageCompleted"] floatValue];
        self.hasEverPurchased       = [[decoder decodeObjectForKey:@"hasEverPurchased"] boolValue];
        self.showInLeftMenu         = [[decoder decodeObjectForKey:@"showInLeftMenu"] boolValue];
        self.expiryTime             = [[decoder decodeObjectForKey:@"expiryTime"] unsignedLongLongValue];
        self.currentlyActive        = [[decoder decodeObjectForKey:@"currentlyActive"] boolValue];

    }
    return self;
}

-(void) appTerminationHandler{
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:self];
    [userDefault setObject:encodedObject forKey:@"BoostModel"];
    [userDefault synchronize];
}

- (void) updateDataWithBoostDictionary:(NSDictionary*) boostDics{
    
    _availableBoost     = [boostDics valueForKey:@"availableBoost"] ?
                          [[boostDics valueForKey:@"availableBoost"] integerValue] : -1;
    
    _availableInRegion  = [[boostDics valueForKey:@"availableInRegion"] boolValue];
    _percentageCompleted = [boostDics valueForKey:@"percentageCompleted"] ?
                            [[boostDics valueForKey:@"percentageCompleted"] floatValue]: -1.0f;
    _showInLeftMenu     = [[boostDics valueForKey:@"showInLeftMenu"] boolValue];
    
    _currentlyActive = [[boostDics valueForKey:@"currentlyActive"] boolValue] ?
    [[boostDics valueForKey:@"currentlyActive"] boolValue] : NO;
    
    _hasEverPurchased = [[boostDics valueForKey:@"hasEverPurchased"] boolValue] ? [[boostDics valueForKey:@"hasEverPurchased"] boolValue] : NO;

    _expiryTime = [boostDics valueForKey:@"expiryTime"] ?
    [[boostDics valueForKey:@"expiryTime"] longLongValue]: 0;
    [self appTerminationHandler];
//    _availableBoost = 3;
//    _availableInRegion = YES;
//    _hasPurchased = YES;
//    _percentageCompleted = 60.0f;
//    _showInLeftMenu = YES;
//    _currentlyActive = YES;
//    _expiryTime = 300;

}

- (BOOL)checkIfUserNeedsToPurchase
{

    NSTimeInterval currentTimeInMilliSecond = [[NSDate date] timeIntervalSince1970]*1000;
    if ((_availableBoost < 1 && _currentlyActive == NO) || ((_expiryTime > 0) && (currentTimeInMilliSecond > _expiryTime))) {
        return YES;
    }
    else{
        return NO;
    }
}

- (void)resetModel{
    _availableBoost         = 0;
    _availableInRegion      = NO;
    _percentageCompleted    = 0.0;
    _showInLeftMenu         = NO;
    _currentlyActive        = NO;
    _expiryTime             = 0;
    _hasEverPurchased       = NO;
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:@"BoostModel"];
}



@end
