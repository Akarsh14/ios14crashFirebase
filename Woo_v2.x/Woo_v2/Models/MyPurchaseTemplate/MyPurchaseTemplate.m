//
//  MyPurchaseTemplate.m
//  Woo_v2
//
//  Created by Deepak Gupta on 7/14/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "MyPurchaseTemplate.h"

@implementation MyPurchaseTemplate

+ (MyPurchaseTemplate *)sharedInstance {
    static MyPurchaseTemplate *sharedInstance = nil;
    if (!sharedInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
            NSData *decodedObject = [userDefault objectForKey: @"MyPurchaseTemplate"];
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
    NSData *decodedObject = [userDefault objectForKey: @"MyPurchaseTemplate"];
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
    [encoder encodeObject:_boostContent forKey:@"contentBoost"];
    [encoder encodeObject:_boostImgUrl forKey:@"imgUrlBoost"];
    [encoder encodeObject:_boostProductType forKey:@"productTypeBoost"];
    [encoder encodeObject:_boostTitle forKey:@"titleBoost"];

    [encoder encodeObject:_crushContent forKey:@"contentCrush"];
    [encoder encodeObject:_crushImgUrl forKey:@"imgUrlCrush"];
    [encoder encodeObject:_crushProductType forKey:@"productTypeCrush"];
    [encoder encodeObject:_crushTitle forKey:@"titleCrush"];

    [encoder encodeObject:_wooPlusContent forKey:@"contentWooPlus"];
    [encoder encodeObject:_wooPlusImgUrl forKey:@"imgUrlWooPlus"];
    [encoder encodeObject:_wooPlusProductType forKey:@"productTypeWooPlus"];
    [encoder encodeObject:_wooPlusTitle forKey:@"titleWooPlus"];

    [encoder encodeObject:_wooGlobeContent forKey:@"contentWooGlobe"];
    [encoder encodeObject:_wooGlobeImgUrl forKey:@"imgUrlWooGlobe"];
    [encoder encodeObject:_wooGlobeProductType forKey:@"productTypeWooGlobe"];
    [encoder encodeObject:_wooGlobeTitle forKey:@"titleWooGlobe"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if( self != nil )
    {
        //decode properties, other class vars
        _boostContent = [decoder decodeObjectForKey:@"contentBoost"];
        _boostImgUrl = [decoder decodeObjectForKey:@"imgUrlBoost"];
        _boostProductType = [decoder decodeObjectForKey:@"productTypeBoost"];
        _boostTitle = [decoder decodeObjectForKey:@"titleBoost"];

        _crushContent = [decoder decodeObjectForKey:@"contentCrush"];
        _crushImgUrl = [decoder decodeObjectForKey:@"imgUrlCrush"];
        _crushProductType = [decoder decodeObjectForKey:@"productTypeCrush"];
        _crushTitle = [decoder decodeObjectForKey:@"titleCrush"];

        _wooPlusContent = [decoder decodeObjectForKey:@"contentWooPlus"];
        _wooPlusImgUrl = [decoder decodeObjectForKey:@"imgUrlWooPlus"];
        _wooPlusProductType = [decoder decodeObjectForKey:@"productTypeWooPlus"];
        _wooPlusTitle = [decoder decodeObjectForKey:@"titleWooPlus"];

        _wooGlobeContent = [decoder decodeObjectForKey:@"contentWooGlobe"];
        _wooGlobeImgUrl = [decoder decodeObjectForKey:@"imgUrlWooGlobe"];
        _wooGlobeProductType = [decoder decodeObjectForKey:@"productTypeWooGlobe"];
        _wooGlobeTitle = [decoder decodeObjectForKey:@"titleWooGlobe"];
    }
    return self;
}


- (void)updateDataWithMyPurchaseTemplate:(NSDictionary*)myPurchaseTemplateDict{
    
    _boostContent = [[myPurchaseTemplateDict valueForKey:@"boost"] valueForKey:kMyPurchaseContent] ? [[myPurchaseTemplateDict valueForKey:@"boost"] valueForKey:kMyPurchaseContent] : @"";
    _boostImgUrl = [[myPurchaseTemplateDict valueForKey:@"boost"] valueForKey:@"imgUrl"] ? [[myPurchaseTemplateDict valueForKey:@"boost"] valueForKey:@"imgUrl"] : @"";
    _boostProductType = [[myPurchaseTemplateDict valueForKey:@"boost"] valueForKey:kPurchaseType] ? [[myPurchaseTemplateDict valueForKey:@"boost"] valueForKey:kPurchaseType] : @"";
    _boostTitle = [[myPurchaseTemplateDict valueForKey:@"boost"] valueForKey:kMyPurchaseTitle] ? [[myPurchaseTemplateDict valueForKey:@"boost"] valueForKey:kMyPurchaseTitle] : @"";

    _crushContent = [[myPurchaseTemplateDict valueForKey:@"crush"] valueForKey:kMyPurchaseContent] ? [[myPurchaseTemplateDict valueForKey:@"crush"] valueForKey:kMyPurchaseContent] : @"";
 
    _crushImgUrl = [[myPurchaseTemplateDict valueForKey:@"crush"] valueForKey:@"imgUrl"] ? [[myPurchaseTemplateDict valueForKey:@"crush"] valueForKey:@"imgUrl"] : @"";
    
    _crushProductType = [[myPurchaseTemplateDict valueForKey:@"crush"] valueForKey:kPurchaseType] ? [[myPurchaseTemplateDict valueForKey:@"crush"] valueForKey:kPurchaseType] : @"";
    
    _crushTitle = [[myPurchaseTemplateDict valueForKey:@"crush"] valueForKey:kMyPurchaseTitle] ? [[myPurchaseTemplateDict valueForKey:@"crush"] valueForKey:kMyPurchaseTitle] : @"";

    
    _wooPlusContent = [[myPurchaseTemplateDict valueForKey:@"wooPlus"] valueForKey:kMyPurchaseContent] ? [[myPurchaseTemplateDict valueForKey:@"wooPlus"] valueForKey:kMyPurchaseContent] : @"";
    _wooPlusImgUrl = [[myPurchaseTemplateDict valueForKey:@"wooPlus"] valueForKey:@"imgUrl"] ? [[myPurchaseTemplateDict valueForKey:@"wooPlus"] valueForKey:@"imgUrl"] : @"";
    _wooPlusProductType = [[myPurchaseTemplateDict valueForKey:@"wooPlus"] valueForKey:kPurchaseType] ? [[myPurchaseTemplateDict valueForKey:@"wooPlus"] valueForKey:kPurchaseType] : @"";
    _wooPlusTitle = [[myPurchaseTemplateDict valueForKey:@"wooPlus"] valueForKey:kMyPurchaseTitle] ? [[myPurchaseTemplateDict valueForKey:@"wooPlus"] valueForKey:kMyPurchaseTitle] : @"";

    
    _wooGlobeContent = [[myPurchaseTemplateDict valueForKey:@"wooGlobes"] valueForKey:kMyPurchaseContent] ? [[myPurchaseTemplateDict valueForKey:@"wooGlobes"] valueForKey:kMyPurchaseContent] : @"";
    _wooGlobeImgUrl = [[myPurchaseTemplateDict valueForKey:@"wooGlobes"] valueForKey:@"imgUrl"] ? [[myPurchaseTemplateDict valueForKey:@"wooGlobes"] valueForKey:@"imgUrl"] : @"";
    _wooGlobeProductType = [[myPurchaseTemplateDict valueForKey:@"wooGlobes"] valueForKey:kPurchaseType] ? [[myPurchaseTemplateDict valueForKey:@"wooGlobes"] valueForKey:kPurchaseType] : @"";
    _wooGlobeTitle = [[myPurchaseTemplateDict valueForKey:@"wooGlobes"] valueForKey:kMyPurchaseTitle] ? [[myPurchaseTemplateDict valueForKey:@"wooGlobes"] valueForKey:kMyPurchaseTitle] : @"";
    
    [self appTerminationHandler];
}

-(void) appTerminationHandler{
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:self];
    [userDefault setObject:encodedObject forKey:@"MyPurchaseTemplate"];
    [userDefault synchronize];
}



- (void)resetModel{
    
    _boostContent = @"";
    _boostImgUrl = @"";
    _boostProductType = @"";
    _boostTitle = @"";
    _crushContent = @"";
    _crushImgUrl = @"";
    _crushProductType = @"";
    _crushTitle = @"";
    _wooPlusContent = @"";
    _wooPlusImgUrl = @"";
    _wooPlusProductType = @"";
    _wooPlusTitle = @"";
    
    _wooGlobeContent = @"";
    _wooGlobeImgUrl = @"";
    _wooGlobeProductType = @"";
    _wooGlobeTitle = @"";
    
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:@"MyPurchaseTemplate"];
}


@end
