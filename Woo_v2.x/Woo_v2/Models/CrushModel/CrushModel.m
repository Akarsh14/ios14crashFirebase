//
//  CrushModel.m
//  Woo_v2
//
//  Created by Suparno Bose on 12/01/16.
//  Copyright © 2016 Woo. All rights reserved.
//

#import "CrushModel.h"

@implementation CrushModel

+ (CrushModel *)sharedInstance {
    static CrushModel *sharedInstance = nil;
    if (!sharedInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
            NSData *decodedObject = [userDefault objectForKey: @"CrushModel"];
            if (decodedObject) {
                sharedInstance = [NSKeyedUnarchiver unarchiveObjectWithData: decodedObject];
            }
            else{
                sharedInstance = [[super allocWithZone:NULL] init];
            }
            [[NSNotificationCenter defaultCenter] addObserver:sharedInstance
                                                     selector:@selector(appTerminationHandler)
                                                         name:UIApplicationWillResignActiveNotification
                                                       object:nil];
        });
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    NSData *decodedObject = [userDefault objectForKey: @"CrushModel"];
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
    [encoder encodeObject:[NSNumber numberWithInteger:self.availableCrush] forKey:@"availableCrush"];
    [encoder encodeObject:[NSNumber numberWithBool:self.availableInRegion] forKey:@"availableInRegion"];
//    [encoder encodeObject:[NSNumber numberWithBool:self.hasPurchased] forKey:@"hasPurchased"];
    [encoder encodeObject:[NSNumber numberWithInteger:self.totalCrush] forKey:@"totalCrush"];
    [encoder encodeObject:[NSNumber numberWithBool:self.showInLeftMenu] forKey:@"showInLeftMenu"];
    [encoder encodeObject:[NSNumber numberWithUnsignedLongLong:self.expiryTime] forKey:@"expiryTime"];
    [encoder encodeObject:[NSNumber numberWithInteger:self.crushMessagesUpdatedTime] forKey:@"crushMessagesUpdatedTime"];
    [encoder encodeObject:[NSNumber numberWithInteger:self.crushMsgCharsLimit] forKey:@"crushMsgCharsLimit"];
    [encoder encodeObject:_templateQuestionArray forKey:@"templateQuestionArray"];
    [encoder encodeObject:[NSNumber numberWithBool:self.hasEverPurchased] forKey:@"hasEverPurchased"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if( self != nil )
    {
        //decode properties, other class vars
        self.availableCrush = [[decoder decodeObjectForKey:@"availableCrush"] integerValue];
        self.availableInRegion = [[decoder decodeObjectForKey:@"availableInRegion"] boolValue];
//        self.hasPurchased = [[decoder decodeObjectForKey:@"hasPurchased"] boolValue];
        self.totalCrush = [[decoder decodeObjectForKey:@"totalCrush"] integerValue];
        self.showInLeftMenu = [[decoder decodeObjectForKey:@"showInLeftMenu"] boolValue];
        self.expiryTime = [[decoder decodeObjectForKey:@"expiryTime"] unsignedLongLongValue];
        self.crushMessagesUpdatedTime = [[decoder decodeObjectForKey:@"crushMessagesUpdatedTime"] integerValue];
        self.crushMsgCharsLimit = [[decoder decodeObjectForKey:@"crushMsgCharsLimit"] integerValue];
        self.templateQuestionArray = [decoder decodeObjectForKey:@"templateQuestionArray"];
        self.hasEverPurchased = [decoder decodeObjectForKey:@"hasEverPurchased"];
    }
    return self;
}

-(void) appTerminationHandler{
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:self];
    [userDefault setObject:encodedObject forKey:@"CrushModel"];
    [userDefault synchronize];
}

- (void) updateDataWithCrushDictionary:(NSDictionary*) crushDics{
    
    _availableCrush         = 0;
    _availableInRegion      = NO;
//    _hasPurchased           = NO;
    _showInLeftMenu         = NO;
    _totalCrush             = -1;
    _expiryTime             = 0;
    _hasEverPurchased       = NO;
    _availableCrush     = [crushDics valueForKey:@"availableCrush"] ?
                            [[crushDics valueForKey:@"availableCrush"] integerValue]: -1;
    _availableInRegion  = [crushDics valueForKey:@"availableInRegion"] ? [[crushDics valueForKey:@"availableInRegion"] boolValue] : NO;
    _expiryTime       = [crushDics valueForKey:@"expiryTime"] ?
                        [[crushDics valueForKey:@"expiryTime"] longLongValue] : 0;
//    _hasPurchased = [crushDics valueForKey:@"hasPurchased"]?
//                    [[crushDics valueForKey:@"hasPurchased"] boolValue]:NO;
    _showInLeftMenu     = [crushDics valueForKey:@"showInLeftMenu"] ? [[crushDics valueForKey:@"showInLeftMenu"] boolValue] : NO;
    _totalCrush     = [crushDics valueForKey:@"totalCrush"]?
                        [[crushDics valueForKey:@"totalCrush"] integerValue]:-1;
    _hasEverPurchased = [crushDics valueForKey:@"hasEverPurchased"]?
    [[crushDics valueForKey:@"hasEverPurchased"] boolValue]:NO;
    [self appTerminationHandler];
    //54321
//    _availableCrush         = 5;
//    _availableInRegion      = YES;
//    _hasEverPurchased           = YES;
//    _showInLeftMenu         = YES;
//    _totalCrush             = 5;
//    _expiryTime             = 0;

}

- (BOOL)checkIfUserNeedsToPurchase
{
    if (_availableCrush < 1) {
        return YES;
    }
    else{
        return NO;
    }
}

- (void)resetModel{
    _availableCrush         = 0;
    _availableInRegion      = NO;
//    _hasPurchased           = NO;
    _hasEverPurchased       = NO;
    _showInLeftMenu         = NO;
    _totalCrush             = -1;
    _expiryTime             = 0;
    _templateQuestionArray = nil;
    _crushMsgCharsLimit = 0;
    _crushMessagesUpdatedTime = 0;
    
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:@"CrushModel"];
}
@end
