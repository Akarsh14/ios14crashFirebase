//
//  WooGlobeModel.m
//  Woo_v2
//
//  Created by Akhil Singh on 17/11/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "WooGlobeModel.h"

@implementation WooGlobeModel

+ (WooGlobeModel *)sharedInstance {
    static WooGlobeModel *sharedInstance = nil;
    if (!sharedInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
            NSData *decodedObject = [userDefault objectForKey: @"WooGlobeModel"];
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
    NSData *decodedObject = [userDefault objectForKey: @"WooGlobeModel"];
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
    [encoder encodeObject:_wooGlobeLocationCity forKey:@"wooGlobeLocationCity"];
    [encoder encodeObject:_wooGlobeLocationState forKey:@"wooGlobeLocationState"];
    [encoder encodeObject:[NSNumber numberWithBool:self.locationOption] forKey:@"locationOption"];
    [encoder encodeObject:[NSNumber numberWithBool:self.ethnicityOption] forKey:@"ethnicityOption"];
    [encoder encodeObject:self.ethnicityArray forKey:@"ethnicityArray"];
    [encoder encodeObject:[NSNumber numberWithBool:self.religionOption] forKey:@"religionOption"];
    [encoder encodeObject:self.religionArray forKey:@"religionArray"];
    [encoder encodeObject:[NSNumber numberWithBool:self.isExpired] forKey:@"isWooGlobeExpired"];
    [encoder encodeObject:[NSNumber numberWithBool:self.isAvailableInRegion] forKey:@"isAvailableInRegion"];
    [encoder encodeObject:[NSNumber numberWithBool:self.wooGlobleOption] forKey:@"wooGlobeOptionValue"];
    [encoder encodeObject:self.wooGlobeLocationDictionary forKey:@"wooGlobeLocationDictionary"];
    [encoder encodeObject:[NSNumber numberWithBool:self.hasEverPurchased] forKey:@"hasEverPurchased"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if( self != nil )
    {
        //decode properties, other class vars
        self.wooGlobeLocationCity         = [decoder decodeObjectForKey:@"wooGlobeLocationCity"];
        self.wooGlobeLocationState      = [decoder decodeObjectForKey:@"wooGlobeLocationState"];
        self.locationOption    = [[decoder decodeObjectForKey:@"locationOption"] boolValue];
        self.ethnicityOption         = [[decoder decodeObjectForKey:@"ethnicityOption"] boolValue];
        self.ethnicityArray             = [decoder decodeObjectForKey:@"ethnicityArray"];
        self.religionOption        = [[decoder decodeObjectForKey:@"religionOption"] boolValue];
        self.religionArray             = [decoder decodeObjectForKey:@"religionArray"];
        self.isExpired = [[decoder decodeObjectForKey:@"isWooGlobeExpired"] boolValue];
        self.isAvailableInRegion = [[decoder decodeObjectForKey:@"isAvailableInRegion"] boolValue];
        self.wooGlobleOption = [[decoder decodeObjectForKey:@"wooGlobeOptionValue"] boolValue];
        self.wooGlobeLocationDictionary = [decoder decodeObjectForKey:@"wooGlobeLocationDictionary"];
        self.hasEverPurchased = [decoder decodeObjectForKey:@"hasEverPurchased"];
    }
    return self;
}

-(void) appTerminationHandler{
    NSLog(@"kuch save hona chahiye");
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:self];
    [userDefault setObject:encodedObject forKey:@"WooGlobeModel"];
    [userDefault synchronize];
}

- (void)updateDataWithWooGlobeDictionary:(NSDictionary*) wooGlobeDict{
    
    if (self.wooGlobePurchaseStarted) {
        return;
    }
    
    self.wooGlobeLocationCity = @"";
    self.wooGlobeLocationState = @"";
    self.locationOption = NO;
    self.ethnicityOption = NO;
    self.ethnicityArray = [NSArray array];
    self.religionOption = NO;
    self.religionArray = [NSArray array];
    self.wooGlobleOption = NO;
    self.hasEverPurchased = NO;
    
    if ([wooGlobeDict valueForKey:@"city"]) {
        self.wooGlobeLocationCity = [wooGlobeDict valueForKey:@"city"];
    }
    
    if ([wooGlobeDict valueForKey:@"state"]) {
        self.wooGlobeLocationState = [wooGlobeDict valueForKey:@"state"];
    }
    
    if ([wooGlobeDict valueForKey:@"locationOn"]) {
        self.locationOption = [[wooGlobeDict valueForKey:@"locationOn"] boolValue] && (self.wooGlobeLocationCity.length > 0);
    }
    
    
    
    if ([wooGlobeDict valueForKey:@"ethnicity"]) {
        self.ethnicityArray =  [self getEthnicityArrayForEthnicityId:[wooGlobeDict valueForKey:@"ethnicity"]];
    }
    if ([wooGlobeDict valueForKey:@"ethnicityOn"]) {
        self.ethnicityOption = [[wooGlobeDict valueForKey:@"ethnicityOn"] boolValue] && ([self.ethnicityArray count] > 0);
    }
   if([wooGlobeDict valueForKey:@"hasEverPurchased"])
   {
       self.hasEverPurchased = [[wooGlobeDict valueForKey:@"hasEverPurchased"] boolValue] ? [[wooGlobeDict valueForKey:@"hasEverPurchased"] boolValue] : NO;
   }
    
    
    if ([wooGlobeDict valueForKey:@"religions"]) {
        self.religionArray = [self getReligionArrayForReligionId:[wooGlobeDict valueForKey:@"religions"]];
    }
    
    if ([wooGlobeDict valueForKey:@"religionOn"]) {
        self.religionOption = [[wooGlobeDict valueForKey:@"religionOn"] boolValue] && ([self.religionArray count] > 0);
    }
    
    if ([wooGlobeDict valueForKey:@"wooGlobeOn"]) {
        self.wooGlobleOption = [[wooGlobeDict valueForKey:@"wooGlobeOn"] boolValue];
    }
    if ([wooGlobeDict valueForKey:@"latitude"]) {
        NSDictionary *locationDict = [[NSDictionary alloc] initWithObjectsAndKeys:[wooGlobeDict valueForKey:@"latitude"],@"latitude",[wooGlobeDict valueForKey:@"longitude"],@"longitude",[wooGlobeDict valueForKey:@"placeId"],@"placeId", nil];
        self.wooGlobeLocationDictionary = locationDict;
    }
    [self appTerminationHandler];
    
}
-(void)updateWooGlobeAvailibilityData:(NSDictionary *)wooGlobeDetail{
    BOOL isExpiredPreviousValue = self.isExpired;
    
    if ([wooGlobeDetail valueForKey:@"availableInRegion"]) {
        self.isAvailableInRegion = [[wooGlobeDetail valueForKey:@"availableInRegion"] boolValue];
    }
    if ([wooGlobeDetail valueForKey:@"expired"]) {
        self.isExpired = [[wooGlobeDetail valueForKey:@"expired"] boolValue];
    }
    
    if ([wooGlobeDetail valueForKey:@"hasEverPurchased"])
    {
        self.hasEverPurchased = [[wooGlobeDetail valueForKey:@"hasEverPurchased"] boolValue];
    }
    if (isExpiredPreviousValue != self.isExpired) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateWooGlobeExpiredValue" object:nil];
    }
    
    NSLog(@"self.isExpired :%d",self.isExpired);
    NSLog(@"self.isExpired :%d",[WooGlobeModel sharedInstance].isExpired);
    [self appTerminationHandler];
}

- (void)resetModel{
    self.wooGlobeLocationCity = @"";
    self.wooGlobeLocationState = @"";
    self.locationOption = NO;
    self.ethnicityOption = NO;
    self.ethnicityArray = [NSArray array];
    self.religionOption = NO;
    self.religionArray = [NSArray array];
    self.isExpired = YES;
    self.isAvailableInRegion = NO;
    self.wooGlobleOption = NO;
    self.wooGlobeLocationDictionary = @{};
    self.hasEverPurchased = NO;
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:@"WooGlobeModel"];
}

-(void)setEthnicityArrayValue:(NSArray *)newEthnicityArray{
    self.ethnicityArray = newEthnicityArray;
    NSLog(@"newEthnicityArray %@",newEthnicityArray);
    NSLog(@"self.ethnicityArray :%@",self.ethnicityArray);
}

-(NSArray *)getReligionArrayForReligionId:(NSArray *)religionIdArray{
    NSArray *religionArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Region" ofType:@"plist"]];
//    NSArray(contentsOfFile: Bundle.main.path(forResource: "Region", ofType:"plist")!)
    NSString *predicateString = @"";
    for (NSString *religionId in religionIdArray) {
        if ([predicateString length] < 1) {
            predicateString = [NSString stringWithFormat:@"tagId = %@",religionId];
        }
        else{
            predicateString = [NSString stringWithFormat:@"%@ OR tagId = %@",predicateString,religionId];
        }
    }
    if (predicateString.length > 0) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:predicateString];
        NSArray *result = [religionArray filteredArrayUsingPredicate:pred];
        
        if (result != nil){
        return result;
        }
        else{
            return [NSArray array];
        }
    }
    
    return [NSArray array];
}
-(NSArray *)getEthnicityArrayForEthnicityId:(NSArray *)ethnicityIdArray{
    NSArray *ethnicityArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Ethnicity" ofType:@"plist"]];
    //    NSArray(contentsOfFile: Bundle.main.path(forResource: "Region", ofType:"plist")!)
    NSString *predicateString = @"";
    for (NSString *ethnicityId in ethnicityIdArray) {
        if ([predicateString length] < 1) {
            predicateString = [NSString stringWithFormat:@"tagId = %@",ethnicityId];
        }
        else{
            predicateString = [NSString stringWithFormat:@"%@ OR tagId = %@",predicateString,ethnicityId];
        }
    }
    if (predicateString.length > 0) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:predicateString];
        NSArray *result = [ethnicityArray filteredArrayUsingPredicate:pred];
        
        if (result != nil){
            return result;
        }
        else{
            return [NSArray array];
        }
    }
    
    return [NSArray array];
}

@end
