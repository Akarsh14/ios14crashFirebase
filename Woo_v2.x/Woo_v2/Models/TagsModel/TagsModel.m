//
//  TagsModel.m
//  Woo_v2
//
//  Created by Umesh Mishraji on 30/06/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "TagsModel.h"
#import "TagScreenAPIClass.h"

@implementation TagsModel


+ (TagsModel *)sharedInstance {
    static TagsModel *sharedInstance = nil;
    if (!sharedInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
            NSData *decodedObject = [userDefault objectForKey: kTagsModelKey];
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
    NSData *decodedObject = [userDefault objectForKey: kTagsModelKey];
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
    [encoder encodeObject:self.allTags forKey:kAllTagsKey];
    [encoder encodeObject:self.popularTags forKey:kPopularTagsKey];
    [encoder encodeObject:self.selectedTags forKey:kSelectedTagsKey];
//    [encoder encodeInteger:self.minTagsAllowedCount forKey:kMinAllowedTagsBubbleCount];
//    [encoder encodeInteger:self.minTagsAllowedCount forKey:kMaxAllowedTagsBubbleCount];

}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //initialising array if not initialised
        if (!self.allTags) {
            self.allTags = [[NSMutableArray alloc] init];
        }
        if (!self.popularTags) {
            self.popularTags = [[NSMutableArray alloc] init];
        }
        if (!self.selectedTags) {
            self.selectedTags = [[NSMutableArray alloc] init];
        }
//        _minTagsAllowedCount = 5;
//        _maxTagsAllowedCount = 15;
        

        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if( self != nil )
    {
        
        //initialising array if not initialised
        if (!self.allTags) {
            self.allTags = [[NSMutableArray alloc] init];
        }
        if (!self.popularTags) {
            self.popularTags = [[NSMutableArray alloc] init];
        }
        if (!self.selectedTags) {
            self.selectedTags = [[NSMutableArray alloc] init];
        }
        
        //decode properties, other class vars
        
        NSMutableArray *tagsArray_temp = [decoder decodeObjectForKey:kAllTagsKey];
        if ([tagsArray_temp count] > 0) {
            if ([self.allTags count] > 0) {
                [self.allTags removeAllObjects];
            }
            [self.allTags addObjectsFromArray:tagsArray_temp];
        }
        
        NSMutableArray *popularTagsArray_temp = [decoder decodeObjectForKey:kPopularTagsKey];
        if ([popularTagsArray_temp count] > 0) {
            if ([self.popularTags count] > 0) {
                [self.popularTags removeAllObjects];
            }
            [self.popularTags addObjectsFromArray:popularTagsArray_temp];
        }
        
        NSMutableArray *selectedTagsArray_temp = [decoder decodeObjectForKey:kSelectedTagsKey];
        if ([selectedTagsArray_temp count] > 0) {
            if ([self.selectedTags count] > 0) {
                [self.selectedTags removeAllObjects];
            }
            [self.selectedTags addObjectsFromArray:selectedTagsArray_temp];
        }
    }
    return self;
}


-(void) appTerminationHandler{
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:self];
    [userDefault setObject:encodedObject forKey:kTagsModelKey];
    [userDefault synchronize];
}

-(void) updateSelectedTags:(NSMutableArray *)newSelectedTags{
    if ([_selectedTags count]>0) {
        [_selectedTags removeAllObjects];
    }
    if (newSelectedTags) {
        [_selectedTags addObjectsFromArray:newSelectedTags];
    }
}

-(void)updateTagsData:(NSDictionary *)tagsDetail{
    
    if (!self.allTags) {
        self.allTags = [[NSMutableArray alloc] init];
    }
    
    if (!self.popularTags) {
        self.popularTags = [[NSMutableArray alloc] init];
    }
    if (!self.selectedTags) {
        self.selectedTags = [[NSMutableArray alloc] init];
    }
    
    
    NSArray *keysArray = [tagsDetail allKeys];
    
    if ([keysArray containsObject:kAllTagsKey]) {
        if (_allTags && [_allTags count] < 1) {
            [_allTags addObjectsFromArray:[tagsDetail objectForKey:kAllTagsKey]];
        }
    }
    
    if ([keysArray containsObject:kPopularTagsKey]) {

        if (_popularTags && [_popularTags count]< 1) {
            [_popularTags addObjectsFromArray:[tagsDetail objectForKey:kPopularTagsKey]];
        }
    }
    
    if ([keysArray containsObject:kSelectedTagsKey]) {
        if (_selectedTags && [_selectedTags count]<1) {
            [_selectedTags addObjectsFromArray:[tagsDetail objectForKey:kSelectedTagsKey]];
        }
        
    }
}


- (void)resetModel{
    _allTags = nil;
    _popularTags = nil;
    _selectedTags = nil;
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:kTagsModelKey];
}

-(void)addTemporaryTagsDetails{
    NSArray * mainBubbleArray = @[@{kTagsIdKey:@2,
                                    kTagsNameKey:@"Scuba Diving",
                                    kTappableTagTypeKey : kTagTypeValue,
                                    kTagsColorCodeKey: @"#AFDB75" ,
                                    kTagsName:@"Scuba Diving"},
                                  
                                  @{kTagsIdKey:@3,
                                    kTagsNameKey:@"Sky Diving",
                                    kTappableTagTypeKey : kTagTypeValue,
                                    kTagsColorCodeKey: @"#AFDB75" ,
                                    kTagsName:@"Sky Diving"},
                                  @{kTagsIdKey:@6,  kTagsNameKey:@"Rock climbing", kTappableTagTypeKey : kTagTypeValue,               kTagsColorCodeKey: @"#AFDB75" , kTagsName:@"Rock climbing"},
                                  @{kTagsIdKey:@7,  kTagsNameKey:@"biker",   kTappableTagTypeKey : kTagTypeValue,               kTagsColorCodeKey: @"#9275DB" , kTagsName:@"biker"},
                                  @{kTagsIdKey:@8,  kTagsNameKey:@"Golfing", kTappableTagTypeKey : kTagTypeValue,                  kTagsColorCodeKey: @"#9275DB" , kTagsName:@"Golfing"},
                                  @{kTagsIdKey:@9,  kTagsNameKey:@"Swimming", kTappableTagTypeKey : kTagTypeValue,          kTagsColorCodeKey: @"#9275DB" , kTagsName:@"Swimming"},
                                  @{kTagsIdKey:@10, kTagsNameKey:@"Football", kTappableTagTypeKey : kTagTypeValue,              kTagsColorCodeKey: @"#9275DB" , kTagsName:@"Football"},
                                  @{kTagsIdKey:@11, kTagsNameKey:@"Cricket",  kTappableTagTypeKey : kTagTypeValue,                   kTagsColorCodeKey: @"#9275DB" , kTagsName:@"Cricket"},
                                  @{kTagsIdKey:@12, kTagsNameKey:@"Tennis",kTappableTagTypeKey : kTagTypeValue,                  kTagsColorCodeKey: @"#9275DB" , kTagsName:@"Tennis"},
                                  @{kTagsIdKey:@13, kTagsNameKey:@"Fitness Enthusiast", kTappableTagTypeKey : kTagTypeValue,                kTagsColorCodeKey: @"#9275DB" , kTagsName:@"Fitness Enthusiast"},
                                  @{kTagsIdKey:@14, kTagsNameKey:@"Yoga",    kTappableTagTypeKey : kTagTypeValue,              kTagsColorCodeKey: @"#9275DB" , kTagsName:@"Yoga"},
                                  @{kTagsIdKey:@15, kTagsNameKey:@"Martial Arts",  kTappableTagTypeKey : kTagTypeValue,             kTagsColorCodeKey: @"#9275DB" , kTagsName:@"Martial Arts"},
                                  @{kTagsIdKey:@16, kTagsNameKey:@"Marathons Runner", kTappableTagTypeKey : kTagTypeValue,                  kTagsColorCodeKey: @"#9275DB" , kTagsName:@"Marathons Runner"},
                                  @{kTagsIdKey:@17, kTagsNameKey:@"Running",  kTappableTagTypeKey : kTagTypeValue,                     kTagsColorCodeKey: @"#9275DB" , kTagsName:@"Running"},
                                  @{kTagsIdKey:@18, kTagsNameKey:@"Gym Junkie", kTappableTagTypeKey : kTagTypeValue,             kTagsColorCodeKey: @"#9275DB" , kTagsName:@"Gym Junkie"},
                                  @{kTagsIdKey:@19, kTagsNameKey:@"Basket ball", kTappableTagTypeKey : kTagTypeValue,             kTagsColorCodeKey: @"#9275DB" , kTagsName:@"Basket ball"},
                                  @{kTagsIdKey:@20, kTagsNameKey:@"Badminton", kTappableTagTypeKey : kTagTypeValue,             kTagsColorCodeKey: @"#9275DB" , kTagsName:@"Badminton"},
                                  @{kTagsIdKey:@1,
                                    kTagsNameKey:@"Adventure Junkie",
                                    kTappableTagTypeKey : kTagTypeValue,
                                    kTagsColorCodeKey: @"#AFDB75",
                                    kTagsName:@"Adventure Junkie"},
                                  @{kTagsIdKey:@4,
                                    kTagsNameKey:@"Bungee Jumping",
                                    kTappableTagTypeKey : kTagTypeValue,
                                    kTagsColorCodeKey: @"#AFDB75" ,
                                    kTagsName:@"Bungee Jumping"},
                                  
                                  @{kTagsIdKey:@5,
                                    kTagsNameKey:@"Extreme Sports",
                                    kTappableTagTypeKey : kTagTypeValue,
                                    kTagsColorCodeKey: @"#AFDB75" ,
                                    kTagsName:@"Extreme Sports"}];
    
    NSArray *popularTags = @[@{kTagsIdKey:@1, kTagsNameKey:@"AdventureJunkie", kTagsColorCodeKey: @"#AFDB75", kTappableTagTypeKey : kTagTypeValue, kTagsName:@"AdventureJunkie"},
                             @{kTagsIdKey:@2, kTagsNameKey:@"ScubaDiving", kTagsColorCodeKey: @"#AFDB75" , kTappableTagTypeKey : kTagTypeValue, kTagsName:@"ScubaDiving"},
                             @{kTagsIdKey:@3, kTagsNameKey:@"Skydiving", kTagsColorCodeKey: @"#AFDB75" , kTappableTagTypeKey : kTagTypeValue, kTagsName:@"Skydiving"}];
    
    NSDictionary *tempReponse = @{kAllTagsKey:mainBubbleArray, kPopularTagsKey: popularTags};
    [self updateTagsData:tempReponse];
}

-(void)addAllTags
{
    NSDictionary *jsonResult = [[NSDictionary alloc]init];
    NSString *tagsPath = [[NSBundle mainBundle] pathForResource:@"AllTags" ofType:@"json"];
    NSError *error = nil;
    NSData *jsonData = [NSData dataWithContentsOfFile:tagsPath options:NSDataReadingMappedIfSafe error:&error];
    if(!error)
    {
        jsonResult = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    }
    [self addNewTagsIntoExistingTagsArray:jsonResult andReturnControlToCallingClass:nil];
}

-(void)getNewTagsIfAny:(void(^)(NSArray *newTagsArray))block{
//    [TagScreenAPIClass getTagsDataFromServer:^(BOOL success, int statusCode, id response) {
//        if (success) {
//            NSDictionary *tagsResponse = (NSDictionary *)response;
//            NSLog(@"tags response :%@",tagsResponse);
    
    NSDictionary *jsonResult = [[NSDictionary alloc]init];
    NSString *tagsPath = [[NSBundle mainBundle] pathForResource:@"AllTags" ofType:@"json"];
    NSError *error = nil;
    NSData *jsonData = [NSData dataWithContentsOfFile:tagsPath options:NSDataReadingMappedIfSafe error:&error];
    if(!error)
    {
       jsonResult = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    }
            [self addNewTagsIntoExistingTagsArray:jsonResult andReturnControlToCallingClass:block];
//        }
//    }];
}
-(void)addNewTagsIntoExistingTagsArray:(NSDictionary *)tagsFromServer andReturnControlToCallingClass:(void(^)(NSArray *newTagsArray))block{
    if (tagsFromServer) {
        NSMutableArray *newTagsArray = [[NSMutableArray alloc] init];
        NSArray *keysArray = [tagsFromServer allKeys];
        
        //All tags array parsing
        if ([keysArray containsObject:kAllTagsKey]) {
            NSArray *allTagsArrayFromserver = [tagsFromServer objectForKey:kAllTagsKey];
            for (NSDictionary *tagsWithCategoryDict in allTagsArrayFromserver) {
                if ([[tagsWithCategoryDict allKeys] containsObject:kUserTagsKey]) {
                    NSArray *categoryTags = [tagsWithCategoryDict objectForKey:kUserTagsKey];
                    NSString *colorCodeString = [tagsWithCategoryDict objectForKey:kColorCode_Tags_Key];
                    for (NSDictionary *tagsDetail in categoryTags) {
                        NSArray *filtered = [_allTags filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(tagId == %@)", [tagsDetail objectForKey:kTagsIdKey]]];
                        if ([filtered count] < 1) {
                            //This tag in not present
                            NSMutableDictionary *newTagDetail = [NSMutableDictionary dictionaryWithDictionary:tagsDetail];
                            [newTagDetail setObject:colorCodeString forKey:kTagsColorCodeKey];
                            [newTagDetail setObject:kTagTypeValue forKey:kTappableTagTypeKey];
                            [newTagDetail setObject:[tagsDetail objectForKey:kTagsNameKey] forKey:kTagsName];
                            if([tagsDetail objectForKey:kFormattedTagsNameKey] != nil)
                            {
                                [newTagDetail setObject:[tagsDetail objectForKey:kFormattedTagsNameKey] forKey:kFormattedTagsNameKey];
                            }
                            [_allTags addObject:newTagDetail];
                            [newTagsArray addObject:newTagDetail];
                        }
                    }
                }
            }
        }
        //All tags array parsing Ends
        
        //Popular tags parsing
        if ([keysArray containsObject:kPopularTagsKey]) {
            NSArray *allTagsArrayFromserver = [tagsFromServer objectForKey:kPopularTagsKey];
            for (NSDictionary *tagsWithCategoryDict in allTagsArrayFromserver) {
                if ([[tagsWithCategoryDict allKeys] containsObject:kUserTagsKey]) {
                    NSArray *categoryTags = [tagsWithCategoryDict objectForKey:kUserTagsKey];
                    NSString *colorCodeString = [tagsWithCategoryDict objectForKey:kColorCode_Tags_Key];
                    for (NSDictionary *tagsDetail in categoryTags) {
                        NSArray *filtered = [_popularTags filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(tagId == %@)", [tagsDetail objectForKey:kTagsIdKey]]];
                        if ([filtered count] < 1) {
                            //This tag in not present
                            NSMutableDictionary *newTagDetail = [NSMutableDictionary dictionaryWithDictionary:tagsDetail];
                            [newTagDetail setObject:colorCodeString forKey:kTagsColorCodeKey];
                            [newTagDetail setObject:kTagTypeValue forKey:kTappableTagTypeKey];
                            [newTagDetail setObject:[tagsDetail objectForKey:kTagsNameKey] forKey:kTagsName];
                            if([tagsDetail objectForKey:kFormattedTagsNameKey] != nil)
                            {
                                [newTagDetail setObject:[tagsDetail objectForKey:kFormattedTagsNameKey] forKey:kFormattedTagsNameKey];
                            }
                            [_popularTags addObject:newTagDetail];
                        }
                    }
                }
            }
        }
        //Popular tags parsing Ends
        
        if (block) {
            block(newTagsArray);
        }
        
    }
    else{
        if (block) {
            block(nil);
        }
        
    }
}

@end
