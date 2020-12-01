//
//  MeDashboard+CoreDataClass.m
//
//
//  Created by Harish kuramsetty on 14/10/19.
//
//

#import "MeDashboard.h"

@implementation MeDashboard

// Insert code here to add functionality to your managed object subclass
static int expiryIndexForInsertion = 0;
static int insertionCompleted = true;


+(void) setExpiryIndexForInsertion:(int)value
{
    expiryIndexForInsertion = value;
}
+(int)getExpiryIndexForInsertion
{
    return expiryIndexForInsertion;
}


+(void)setInsertionCompleted:(int)value
{
    insertionCompleted = value;
}
+(int)getInsertionCompleted
{
    return insertionCompleted;
}

+(void)updateBoostData:(NSDictionary *)visitorDict ForWooId:(NSString*)wooId
{
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    __block NSError *error = nil;
    if (privateManagedObjectContext)
    {
        [privateManagedObjectContext performBlock:^{
            
            MeDashboard *boostObj = [[self getBoostDataForVisitorId:[visitorDict objectForKey:@"wooUserId"]]firstObject];
            [boostObj setVisitorId:[NSString stringWithFormat:@"%lld",[[visitorDict objectForKey:@"wooUserId"] longLongValue]]];
            [boostObj setVisitorFirstName:[visitorDict objectForKey:@"firstName"]];
            [boostObj setVisitorAge:[NSString stringWithFormat:@"%d",[[visitorDict objectForKey:@"age"] intValue]]];
            [boostObj setVisitorProfilePicURL:[visitorDict objectForKey:@"profilePicUrl"]];
            
            if ([visitorDict objectForKey:@"commonTagDto"]){
                [boostObj setCommonTagDto:[visitorDict objectForKey:@"commonTagDto"]];
            }
            
            if ([[visitorDict allKeys] containsObject:@"gender"])
            {
                [boostObj setVisitorGender:[visitorDict objectForKey:@"gender"]];
                
            }
            NSLog(@"privateManagedObjectContext");
            /***************************Save Context*************************************/
            if (privateManagedObjectContext != nil)
            {
                if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error])
                {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    //abort();
                }
                else{
                    // Saving data on parent context and then informing back
                    NSLog(@"Saving data on parent context and then informing back");
                    [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted)
                     {
                        if(isCompleted)
                        {
                            insertionCompleted = true;
                            
                        }
                        
                    }];
                    
                }
            }
        }];
        
    }
}

+(void)updateCommonTags:(NSDictionary *)commonTags ForBoostObject:(MeDashboard *)boostObj withUpdatedCompletionHandler:(UpdationCompletionHandler)updationCompletion
{
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    __block NSError *error = nil;
    if (privateManagedObjectContext)
    {
        [privateManagedObjectContext performBlock:^{
            
            if (commonTags){
                [boostObj setCommonTagDto:commonTags];
            }
            NSLog(@"privateManagedObjectContext");
            /***************************Save Context*************************************/
            if (privateManagedObjectContext != nil)
            {
                if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error])
                {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    //abort();
                }
                else{
                    // Saving data on parent context and then informing back
                    NSLog(@"Saving data on parent context and then informing back");
                    [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted)
                     {
                        if(isCompleted)
                        {
                            updationCompletion(isCompleted);
                        }
                        
                    }];
                    
                }
            }
        }];
        
    }
}

+(void)migrateThingsFromVisit:(NSArray *)boostDataArray forType:(ProfileType)type  withInsertionCompletionHandler:(InsertionCompletionHandler)insertionCompletion{
    
    insertionCompleted = false;
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    
    __block BOOL newRecordsAdded = FALSE;
    
    if (privateManagedObjectContext) {
        
        [privateManagedObjectContext performBlock:^{
            
            NSMutableArray *arrayOfNewAddedVisitors = [[NSMutableArray alloc]init];
            
            if (boostDataArray && [boostDataArray count] > 0 )
            {
                
                
                
                
                
                if(type == likedMe){
                   
                    
                    
                    for (LikedMe *visitorDict in boostDataArray) {
                         MeDashboard *boostObj = [[self getBoostDataForVisitorId:visitorDict.userWooId]firstObject];
                        if (!boostObj) {
                            boostObj = (MeDashboard *)[NSEntityDescription insertNewObjectForEntityForName:@"MeDashboard" inManagedObjectContext:privateManagedObjectContext];
                            newRecordsAdded = YES;
                            
                            
                        }
                    
                        [boostObj setType:kFromlikedMe];
                        [boostObj setCommonTagDto:visitorDict.commonTagDto];
                        [boostObj setGroupId:visitorDict.groupId];
                        [boostObj setVisitorId:visitorDict.userWooId];
                        [boostObj setVisitorFirstName:visitorDict.userFirstName];
                        [boostObj setVisitorAge:visitorDict.userAge];
                        [boostObj setVisitorProfilePicURL:visitorDict.userProfilePicURL];
                        [boostObj setIsVisitorBoosted:visitorDict.isUserBoosted];
                        [boostObj setIsVisitorLiked:visitorDict.isUserLiked];
                        [boostObj setIsVisitorProfileSeenbyUser:visitorDict.isUserProfileSeenbyAppUser];
                        [boostObj setBadgeType:visitorDict.badgeType];
                        [boostObj setVisitorGender:visitorDict.userGender];
                        [boostObj setVisitorExpiryTime:visitorDict.userExpiryTime];
                        [arrayOfNewAddedVisitors addObject:boostObj];
                    }
                    
                }else if(type == VisitorMe){
                       
                        
                        for (BoostDashboard *visitorDict in boostDataArray) {
                            MeDashboard *boostObj = [[self getBoostDataForVisitorId:visitorDict.visitorId]firstObject];
                            if (!boostObj) {
                                boostObj = (MeDashboard *)[NSEntityDescription insertNewObjectForEntityForName:@"MeDashboard" inManagedObjectContext:privateManagedObjectContext];
                                newRecordsAdded = YES;
                            }
                            [boostObj setType:kFromvistors];
                            [boostObj setCommonTagDto:visitorDict.commonTagDto];
                            [boostObj setGroupId:visitorDict.groupId];
                            [boostObj setVisitorId:visitorDict.visitorId];
                            [boostObj setVisitorFirstName:visitorDict.visitorFirstName];
                            [boostObj setVisitorAge:visitorDict.visitorAge];
                            [boostObj setVisitorProfilePicURL:visitorDict.visitorProfilePicURL];
                            [boostObj setIsVisitorBoosted:visitorDict.isVisitorBoosted];
                            [boostObj setIsVisitorLiked:visitorDict.isVisitorLiked];
                            [boostObj setIsVisitorProfileSeenbyUser:visitorDict.isVisitorProfileSeenbyUser];
                            [boostObj setBadgeType:visitorDict.badgeType];
                            [boostObj setVisitorGender:visitorDict.visitorGender];
                            [boostObj setVisitorExpiryTime:visitorDict.visitorExpiryTime];
                            [arrayOfNewAddedVisitors addObject:boostObj];
                        }
                        
                    
                }
            }
            
            
            NSLog(@"privateManagedObjectContext");
            
            /***************************Save Context*************************************/
            
            if (privateManagedObjectContext != nil) {
                if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    //abort();
                }
                else{
                    // Saving data on parent context and then informing back
                    NSLog(@"Saving data on parent context and then informing back");
                    [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                        if(isCompleted)
                        {
                            insertionCompleted = true;
                            if (newRecordsAdded)
                            {
                                [[NSNotificationCenter defaultCenter] postNotificationName:kNewVisitorAddedOnPagination object:arrayOfNewAddedVisitors];
                            }
                            
                            if(insertionCompletion){
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [[WooScreenManager sharedInstance].oHomeViewController checkAndshowUnreadBadgeOnAboutMeIcon];
                                    insertionCompletion(true);
                                });
                            }
                        }
                        
                    }];
                    
                }
            }
            
            /*****************************************************************************/
            
        }];
        
    }}

+(void)insertOrUpdateBoostDashboardData:(NSArray *)boostDataArray forType:(ProfileType)type  withInsertionCompletionHandler:(InsertionCompletionHandler)insertionCompletion{
    
    insertionCompleted = false;
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    
    __block BOOL newRecordsAdded = FALSE;
    
    if (privateManagedObjectContext) {
        
        [privateManagedObjectContext performBlock:^{
            
            NSMutableArray *arrayOfNewAddedVisitors = [[NSMutableArray alloc]init];
            
            if (boostDataArray && [boostDataArray count] > 0 )
            {
                BOOL isLastVisitorProfileBoosted = [self isLastProfileBoosted:[boostDataArray firstObject]];
                
                NSInteger currentGroupIdToBeused = [self getGroupIdToBeUsed];
                
                for (NSDictionary *visitorDict in boostDataArray) {
                    
                    BOOL isCurrentProfileBoosted = [[visitorDict objectForKey:@"isActorBoosted"] boolValue];
                    
                    if (isLastVisitorProfileBoosted != isCurrentProfileBoosted) {
                        currentGroupIdToBeused++;
                    }
                    
                    MeDashboard *boostObj = [[self getBoostDataForVisitorId:[visitorDict objectForKey:@"wooUserId"]]firstObject];
                    
                    if (!boostObj) {
                        boostObj = (MeDashboard *)[NSEntityDescription insertNewObjectForEntityForName:@"MeDashboard" inManagedObjectContext:privateManagedObjectContext];
                        newRecordsAdded = YES;
                        
                        if ([visitorDict objectForKey:@"commonTagDto"]){
                            
                            if ([[BoostModel sharedInstance] checkIfUserNeedsToPurchase] && [[WooPlusModel sharedInstance] isExpired]){
                                int random = arc4random_uniform(100);
                                if (random < 30){
                                    int randomOfTwo = arc4random_uniform(2);
                                    NSMutableDictionary *commonTagsDict = [NSMutableDictionary dictionary];
                                    if (randomOfTwo == 0){
                                        //location
                                        [commonTagsDict setValue:[[DiscoverProfileCollection sharedInstance] myProfileData].location forKey:@"name"];
                                        [commonTagsDict setValue:0 forKey:@"order"];
                                        [commonTagsDict setValue:0 forKey:@"tagId"];
                                        [commonTagsDict setValue:[NSNumber numberWithBool:true] forKey:@"isFake"];
                                        [commonTagsDict setValue:@"USER_DISTANCE" forKey:@"tagsDtoType"];
                                        [commonTagsDict setValue:@"ic_location.png" forKey:@"url"];
                                        
                                    }
                                    else{
                                        //kms away
                                        int randomKms = arc4random_uniform(6);
                                        if (randomKms == 0){
                                            randomKms = 1;
                                        }
                                        NSString *kmsString = [NSString stringWithFormat:@"%d kms away",randomKms];
                                        [commonTagsDict setValue:kmsString forKey:@"name"];
                                        [commonTagsDict setValue:0 forKey:@"order"];
                                        [commonTagsDict setValue:0 forKey:@"tagId"];
                                        [commonTagsDict setValue:[NSNumber numberWithBool:true] forKey:@"isFake"];
                                        [commonTagsDict setValue:@"USER_DISTANCE" forKey:@"tagsDtoType"];
                                        [commonTagsDict setValue:@"ic_location.png" forKey:@"url"];
                                    }
                                    [boostObj setCommonTagDto:commonTagsDict];
                                }
                                else{
                                    [boostObj setCommonTagDto:[visitorDict objectForKey:@"commonTagDto"]];
                                }
                            }
                            else{
                                [boostObj setCommonTagDto:[visitorDict objectForKey:@"commonTagDto"]];
                            }
                            
                        }
                        else{
                            int randomOfTwo = arc4random_uniform(2);
                            NSMutableDictionary *commonTagsDict = [NSMutableDictionary dictionary];
                            if (randomOfTwo == 0){
                                //location
                                [commonTagsDict setValue:[[DiscoverProfileCollection sharedInstance] myProfileData].location forKey:@"name"];
                                [commonTagsDict setValue:0 forKey:@"order"];
                                [commonTagsDict setValue:0 forKey:@"tagId"];
                                [commonTagsDict setValue:[NSNumber numberWithBool:true] forKey:@"isFake"];
                                [commonTagsDict setValue:@"USER_DISTANCE" forKey:@"tagsDtoType"];
                                [commonTagsDict setValue:@"ic_location.png" forKey:@"url"];
                                
                            }
                            else{
                                //kms away
                                int randomKms = arc4random_uniform(6);
                                if (randomKms == 0){
                                    randomKms = 1;
                                }
                                NSString *kmsString = [NSString stringWithFormat:@"%d kms away",randomKms];
                                [commonTagsDict setValue:kmsString forKey:@"name"];
                                [commonTagsDict setValue:0 forKey:@"order"];
                                [commonTagsDict setValue:0 forKey:@"tagId"];
                                [commonTagsDict setValue:[NSNumber numberWithBool:true] forKey:@"isFake"];
                                [commonTagsDict setValue:@"USER_DISTANCE" forKey:@"tagsDtoType"];
                                [commonTagsDict setValue:@"ic_location.png" forKey:@"url"];
                            }
                            [boostObj setCommonTagDto:commonTagsDict];
                        }
                    }
                    if(type == likedMe){
                        [boostObj setType:kFromlikedMe];
                    }else if(type == VisitorMe){
                        [boostObj setType:kFromvistors];
                    }
                    
                    [boostObj setGroupId:[NSNumber numberWithInteger:currentGroupIdToBeused]];
                    [boostObj setVisitorId:[NSString stringWithFormat:@"%lld",[[visitorDict objectForKey:@"wooUserId"] longLongValue]]];
                    [boostObj setVisitorFirstName:[visitorDict objectForKey:@"firstName"]];
                    [boostObj setVisitorAge:[NSString stringWithFormat:@"%d",[[visitorDict objectForKey:@"age"] intValue]]];
                    [boostObj setVisitorProfilePicURL:[visitorDict objectForKey:@"profilePicUrl"]];
                    [boostObj setIsVisitorBoosted:[NSNumber numberWithBool:isCurrentProfileBoosted]];
                    [boostObj setIsVisitorLiked:[NSNumber numberWithBool:[[visitorDict objectForKey:@"like"] boolValue]]];
                    if (![boostObj.isVisitorProfileSeenbyUser boolValue]) {
                        [boostObj setIsVisitorProfileSeenbyUser:@FALSE];
                    }
                    
                    if ([[visitorDict allKeys] containsObject:@"bagdeType"]) {
                        [boostObj setBadgeType:[visitorDict objectForKey:@"bagdeType"]];
                    }
                    else{
                        [boostObj setBadgeType:@"NONE"];
                    }
                    
                    if ([[visitorDict allKeys] containsObject:@"gender"]) {
                        [boostObj setVisitorGender:[visitorDict objectForKey:@"gender"]];
                    }
                    
                    
                    isLastVisitorProfileBoosted = isCurrentProfileBoosted;
                    
                    
                    NSString *visitorExpiryTime = [visitorDict objectForKey:@"time"];
                    long long int serverTimeInMilliSecs = [visitorExpiryTime longLongValue];
                    NSDate *dateToBeStoredInDb = [NSDate dateWithTimeIntervalSince1970:serverTimeInMilliSecs/1000];
                    
                    [boostObj setVisitorExpiryTime:dateToBeStoredInDb];
                    
                    [arrayOfNewAddedVisitors addObject:boostObj];
                }
            }
            
            NSLog(@"privateManagedObjectContext");
            
            /***************************Save Context*************************************/
            
            if (privateManagedObjectContext != nil) {
                if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    //abort();
                }
                else{
                    // Saving data on parent context and then informing back
                    NSLog(@"Saving data on parent context and then informing back");
                    [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                        if(isCompleted)
                        {
                            insertionCompleted = true;
                            if (newRecordsAdded)
                            {
                                [[NSNotificationCenter defaultCenter] postNotificationName:kNewVisitorAddedOnPagination object:arrayOfNewAddedVisitors];
                            }
                            
                            if(insertionCompletion){
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [[WooScreenManager sharedInstance].oHomeViewController checkAndshowUnreadBadgeOnAboutMeIcon];
                                    insertionCompletion(true);
                                });
                            }
                        }
                        
                    }];
                    
                }
            }
            
            /*****************************************************************************/
            
        }];
        
    }
}



+(NSArray *)getAllBoostProfiles{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MeDashboard" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSArray *allBoosts = [managedObjectContext executeFetchRequest:request error:&error];
    
    if(!error)
    {
        return ([allBoosts count]>0 ? allBoosts : [[NSArray alloc] init]);
    }
    else{
        return [[NSArray alloc] init];
    }
}

+(NSArray *)getAllVisitorIds{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MeDashboard" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setPropertiesToFetch:[NSArray arrayWithObject:@"visitorId"]];
    [request setResultType:NSDictionaryResultType];
    NSArray *allBoosts = [managedObjectContext executeFetchRequest:request error:&error];
    NSMutableArray *arrayOfIDs = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in allBoosts) {
        [arrayOfIDs addObject: [dict objectForKey:@"visitorId"]];
    }
    if(!error)
    {
        return ([arrayOfIDs count]>0 ? arrayOfIDs : [[NSArray alloc] init]);
    }
    else{
        return [[NSArray alloc] init];
    }
}


+(void)updateHasVisitorProfileVisitedByUser:(BOOL)isProfileVisited forVisitorId:(NSString *)visitorId withCompletionHandler:(UpdationCompletionHandler)insertionCompletion{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    
    if (privateManagedObjectContext) {
        
        [privateManagedObjectContext performBlock:^{
            
            MeDashboard *boostObj = [[self getBoostDataForVisitorId:visitorId]firstObject];
            if (boostObj) {
                [boostObj setIsVisitorProfileSeenbyUser:[NSNumber numberWithBool:isProfileVisited]];
            }
            
            /***************************Save Context*************************************/
            
            if (privateManagedObjectContext != nil) {
                if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    //abort();
                }
                else{
                    // Saving data on parent context and then informing back
                    [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                        if(insertionCompletion){
                            dispatch_async(dispatch_get_main_queue(), ^{
                                insertionCompletion(true);
                            });
                        }
                    }];
                    
                }
            }
            
            /*****************************************************************************/
            
        }];
        
    }
    
}

+(NSArray *)getBoostDataForVisitorId:(NSString *)visitorId{
    
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MeDashboard" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(visitorId==%@)",visitorId];
    
    [request setPredicate:predicateObj];
    
    NSError *error = nil;
    
    NSArray *selectedBoostArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    return selectedBoostArray;
}

+(NSArray *)getIDsOfAllTheBoostInDB{
    
    NSArray *boostArray =[self getAllVisitorIds];
    //    NSMutableArray *arrayOfIDs = [[NSMutableArray alloc] init];
    //    for (BoostDashboard *boostObj in boostArray) {
    //
    //
    //        [arrayOfIDs addObject:boostObj.visitorId];
    //    }
    return boostArray;
}

+(NSInteger)getTotalNumberOfVisitors{
    NSArray *boostArray =[self getAllBoostProfiles];
    return [boostArray count];
}

+(NSInteger)getTotalNumberOfUnvisitedVisitor{
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MeDashboard" inManagedObjectContext:managedObjectContext];
    
    NSDate *dateAfterDeletingDaysFromCurrentDate = [APP_Utilities dateAfterSubtractingDaysInCurrentDate:(int)[AppLaunchModel sharedInstance].meSectionProfileExpiryDays];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(isVisitorProfileSeenbyUser==%@) AND (visitorExpiryTime > %@)",[NSNumber numberWithBool:FALSE],dateAfterDeletingDaysFromCurrentDate];
    
    [request setPredicate:predicateObj];
    
    NSError *error = nil;
    
    NSArray *selectedBoostArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    return [selectedBoostArray count];
}



+(void)deleteBoostDataFromDBWithUserIDs:(NSArray *)idsToBeDeleted withCompletionHandler:(DeletionCompletionHandler __nullable)completionHandler{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    
    if (privateManagedObjectContext) {
        
        [privateManagedObjectContext performBlock:^{
            
            NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
            
            for (NSString *idToBeDeleted in idsToBeDeleted) {
                
                NSArray *toBeDeletedCrush = [self getBoostDataForVisitorId:idToBeDeleted];
                
                if (toBeDeletedCrush)
                {
                    for (MeDashboard *boostProfile in toBeDeletedCrush)
                    {
                        [privateManagedObjectContext deleteObject:boostProfile];
                    }
                }
            }
            
            /***************************Save Context*************************************/
            
            if (privateManagedObjectContext != nil) {
                if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    //abort();
                }
                else{
                    // Saving data on parent context and then informing back
                    [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                        if(completionHandler){
                            dispatch_async(dispatch_get_main_queue(), ^{
                                completionHandler(true);
                            });
                        }
                    }];
                    
                }
            }
            
            /*****************************************************************************/
            
        }];
        
    }
    
}

/*
 
 +(void)updateIsVisitorLikedStatusForVisitorId:(NSString *)visitorId{
 
 NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
 
 __block NSError *error = nil;
 
 if (privateManagedObjectContext) {
 
 [privateManagedObjectContext performBlock:^{
 
 BoostDashboard *boostObj = [[self getBoostDataForVisitorId:visitorId] firstObject];
 if (boostObj) {
 [boostObj setIsVisitorLiked:[NSNumber numberWithBool:TRUE]];
 }
 
 if (privateManagedObjectContext != nil) {
 if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
 // Replace this implementation with code to handle the error appropriately.
 // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
 NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
 //abort();
 }
 else{
 // Saving data on parent context and then informing back
 [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
 
 }];
 
 }
 }
 
 }];
 
 }
 }
 */

/*
 +(void)updateCrushMessageForVisitorId:(NSString *)visitorId withCrushMessage:(NSString *)crushMsg{
 
 NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
 
 __block NSError *error = nil;
 
 if (privateManagedObjectContext) {
 
 [privateManagedObjectContext performBlock:^{
 
 BoostDashboard *boostObj = [[self getBoostDataForVisitorId:visitorId] firstObject];
 if (boostObj && [crushMsg length]>0) {
 [boostObj setCrushMsgSendToUser:crushMsg];
 [boostObj setIsCrushSend:[NSNumber numberWithBool:TRUE]];
 [boostObj setIsVisitorLiked:[NSNumber numberWithBool:TRUE]];
 }
 
 if (privateManagedObjectContext != nil) {
 if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
 // Replace this implementation with code to handle the error appropriately.
 // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
 NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
 //abort();
 }
 else{
 // Saving data on parent context and then informing back
 [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
 
 }];
 
 }
 }
 
 }];
 
 }
 }
 
 */

+(BOOL)isLastProfileBoosted:(NSDictionary *)firstObject{
    BOOL isLastProfileBoosted = FALSE;
    NSArray *allProfile = [self getAllBoostProfiles];
    if (allProfile && [allProfile count] > 0) {
        MeDashboard *lastProfile = [allProfile lastObject];
        isLastProfileBoosted = [lastProfile.isVisitorBoosted boolValue];
    }
    else{
        isLastProfileBoosted = [[firstObject objectForKey:@"isActorBoosted"] boolValue];
    }
    return isLastProfileBoosted;
}

+(NSInteger)getGroupIdToBeUsed{
    
    NSInteger lastGroupId = 1;
    NSArray *allProfile = [self getAllBoostProfiles];
    if (allProfile && [allProfile count] > 0) {
        MeDashboard *lastProfile = [allProfile lastObject];
        lastGroupId = [lastProfile.groupId integerValue];
    }
    
    
    return lastGroupId;
}

+(NSArray *)getDisctintGroups{
    NSArray *distintGroupsArray = nil;
    
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MeDashboard" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    [request setResultType:NSDictionaryResultType];
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch:[NSArray arrayWithObject:[[entityDescription propertiesByName] objectForKey:@"groupId"]]];
    NSSortDescriptor *groupIdSorting = [[NSSortDescriptor alloc] initWithKey:@"groupId" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:groupIdSorting]];
    
    NSError *error = nil;
    
    distintGroupsArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    NSMutableArray *groupIdArray = [[NSMutableArray alloc] init];
    for (NSDictionary *keyDict in distintGroupsArray) {
        [groupIdArray addObject:[NSString stringWithFormat:@"%d",[[keyDict objectForKey:@"groupId"] intValue]]];
    }
    return (NSArray *)groupIdArray;
    
}
+(NSArray *)getVisitorsForGroupID:(NSString *)groupId{
    
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MeDashboard" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(groupId == %@)",[NSNumber numberWithInt:[groupId intValue]]];
    
    [request setPredicate:predicateObj];
    
    NSSortDescriptor *groupIdSorting = [[NSSortDescriptor alloc] initWithKey:@"visitorExpiryTime" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:groupIdSorting]];
    
    NSError *error = nil;
    
    NSArray *selectedBoostArray = nil;
    if (managedObjectContext) {
        selectedBoostArray = [managedObjectContext executeFetchRequest:request error:&error];
    }
    
    return ([selectedBoostArray count]>0 ? selectedBoostArray : nil );
    
}

/// new method that creates groups for all data present
+(NSMutableDictionary *)getGroupedVisitorDataAccordingToTheGroups
{
    // Get all data sorted by timestamp desc
    NSArray *boostDataArray = [self getAllBoostProfilesSortedByTimestamp];
    // Create groups
    //Empty mutable dictionary to store data
    NSMutableDictionary *groupedDataDictionary = [[NSMutableDictionary alloc]init];
    
    BOOL isCurrentProfileBoosted = nil;
    BOOL islastProfileBoosted = nil;
    NSNumber *currentGroupIdToBeused = [NSNumber numberWithInt:0];
    NSMutableArray *arrayContainingGroupElements = [[NSMutableArray alloc]init];
    //When no groups have been made
    
    for (MeDashboard *boost in boostDataArray)
    {
        isCurrentProfileBoosted = boost.isVisitorBoosted.boolValue;
        //If last and current profile status is not the same
        //add a new group
        if (islastProfileBoosted != isCurrentProfileBoosted || [[groupedDataDictionary allKeys] count] == 0)
        {
            //create group for boost/nonboost
            currentGroupIdToBeused = [NSNumber numberWithInt:currentGroupIdToBeused.intValue+1];
            arrayContainingGroupElements = [[NSMutableArray alloc]init];
            [arrayContainingGroupElements addObject:boost];
        }
        else
        {
            [arrayContainingGroupElements addObject:boost];
        }
        [groupedDataDictionary setObject:arrayContainingGroupElements forKey:currentGroupIdToBeused];
        islastProfileBoosted = isCurrentProfileBoosted;
        
    }
    
    return groupedDataDictionary;
}


//method to extract all profiles in timestamp descending
+(NSArray *)getAllBoostProfilesSortedByTimestamp
{
    
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MeDashboard" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"visitorExpiryTime" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSPredicate *predicateObjBasedOnWooID = [NSPredicate predicateWithFormat:@"(visitorId != 0)"];
    [request setPredicate:predicateObjBasedOnWooID];
    NSArray *allBoosts = [managedObjectContext executeFetchRequest:request error:&error];
    
    NSMutableSet *seenDates = [NSMutableSet set];
    NSPredicate *duplicatePredicate = [NSPredicate predicateWithBlock: ^BOOL(id obj, NSDictionary *bind) {
        MeDashboard *e = (MeDashboard*)obj;
        BOOL seen = [seenDates containsObject:e.visitorId];
        if (!seen) {
            [seenDates addObject:e.visitorId];
        }
        return !seen;
    }];
    allBoosts = [allBoosts filteredArrayUsingPredicate:duplicatePredicate];
    
    return (NSMutableArray*) ([allBoosts count]>0 ? allBoosts : nil );
}



+(void)deleteAllVisotorsPresentInSystemForMoreThanDays:(int)numberOfDays{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    
    
    [privateManagedObjectContext performBlock:^{
        
        NSDate *dateAfterDeletingDaysFromCurrentDate = [APP_Utilities dateAfterSubtractingDaysInCurrentDate:numberOfDays];
        
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MeDashboard" inManagedObjectContext:privateManagedObjectContext];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        [request setEntity:entityDescription];
        
        NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(visitorExpiryTime < %@)",dateAfterDeletingDaysFromCurrentDate];
        
        [request setPredicate:predicateObj];
        
        NSArray *selectedBoostArray = [privateManagedObjectContext executeFetchRequest:request error:&error];
        
        for (MeDashboard *visitorToBeDeleted in selectedBoostArray) {
            if (visitorToBeDeleted) {
                [privateManagedObjectContext deleteObject:visitorToBeDeleted];
            }
        }
        
        /***************************Save Context*************************************/
        
        if (privateManagedObjectContext != nil) {
            if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                //abort();
            }
            else{
                // Saving data on parent context and then informing back
                [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                    
                }];
                
            }
        }
        
        /*****************************************************************************/
        
    }];
    
}



+(NSArray *)getAllExpiringVisitors{
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSDate *dateAfterDeletingDaysFromCurrentDate = [APP_Utilities dateAfterSubtractingDaysInCurrentDate:(int)[AppLaunchModel sharedInstance].meSectionProfileExpiryDaysThreshold];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MeDashboard" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(visitorExpiryTime <= %@)",dateAfterDeletingDaysFromCurrentDate];
    NSPredicate *predicateObjBasedOnWooID = [NSPredicate predicateWithFormat:@"(visitorId != 0)"];
    NSPredicate *combinedPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicateObj, predicateObjBasedOnWooID]];
    [request setPredicate:combinedPredicate];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"visitorExpiryTime" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error = nil;
    
    NSArray *expiringvisitors = [managedObjectContext executeFetchRequest:request error:&error];
    NSMutableSet *seenDates = [NSMutableSet set];
    NSPredicate *duplicatePredicate = [NSPredicate predicateWithBlock: ^BOOL(id obj, NSDictionary *bind) {
        MeDashboard *e = (MeDashboard*)obj;
        BOOL seen = [seenDates containsObject:e.visitorId];
        if (!seen) {
            [seenDates addObject:e.visitorId];
        }
        return !seen;
    }];
    expiringvisitors = [expiringvisitors filteredArrayUsingPredicate:duplicatePredicate];
    
    return expiringvisitors;
    
}

+(NSArray *)getAllNonExpiringVisitors{
    
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSDate *dateAfterDeletingDaysFromCurrentDate = [APP_Utilities dateAfterSubtractingDaysInCurrentDate:(int)[AppLaunchModel sharedInstance].meSectionProfileExpiryDaysThreshold];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MeDashboard" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(visitorExpiryTime > %@)",dateAfterDeletingDaysFromCurrentDate];
    NSPredicate *predicateObjBasedOnWooID = [NSPredicate predicateWithFormat:@"(visitorId != 0)"];
    NSPredicate *combinedPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicateObj, predicateObjBasedOnWooID]];
    [request setPredicate:combinedPredicate];
    
    NSError *error = nil;
    
    NSArray *nonExpiringVisitors = [managedObjectContext executeFetchRequest:request error:&error];
    NSMutableSet *seenDates = [NSMutableSet set];
    NSPredicate *duplicatePredicate = [NSPredicate predicateWithBlock: ^BOOL(id obj, NSDictionary *bind) {
        MeDashboard *e = (MeDashboard*)obj;
        BOOL seen = [seenDates containsObject:e.visitorId];
        if (!seen) {
            [seenDates addObject:e.visitorId];
        }
        return !seen;
    }];
    nonExpiringVisitors = [nonExpiringVisitors filteredArrayUsingPredicate:duplicatePredicate];
    return nonExpiringVisitors;
    
    
}

//method to extract all non expiring profiles in timestamp descending
+(NSArray *)getAllNonExpiringVisitorsSortedByTimestamp{
    
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    NSDate *dateAfterDeletingDaysFromCurrentDate = [APP_Utilities dateAfterSubtractingDaysInCurrentDate:(int)[AppLaunchModel sharedInstance].meSectionProfileExpiryDaysThreshold];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MeDashboard" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"visitorExpiryTime" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(visitorExpiryTime > %@)",dateAfterDeletingDaysFromCurrentDate];
    NSPredicate *predicateObjBasedOnWooID = [NSPredicate predicateWithFormat:@"(visitorId != 0)"];
    NSPredicate *combinedPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicateObj, predicateObjBasedOnWooID]];
    [request setPredicate:combinedPredicate];
    NSError *error = nil;
    
    
    NSArray *nonExpiringVisitors = [managedObjectContext executeFetchRequest:request error:&error];
    
    NSMutableSet *seenDates = [NSMutableSet set];
    NSPredicate *duplicatePredicate = [NSPredicate predicateWithBlock: ^BOOL(id obj, NSDictionary *bind) {
        MeDashboard *e = (MeDashboard*)obj;
        BOOL seen = [seenDates containsObject:e.visitorId];
        if (!seen) {
            [seenDates addObject:e.visitorId];
        }
        return !seen;
    }];
    nonExpiringVisitors = [nonExpiringVisitors filteredArrayUsingPredicate:duplicatePredicate];
    
    return nonExpiringVisitors;
}



+(NSMutableDictionary *)getNonExpiredGroupedVisitorDataAccordingToTheGroups
{
    
    // Get all data sorted by timestamp desc
    NSArray *boostDataArray = [self getAllNonExpiringVisitorsSortedByTimestamp];
    // Create groups
    //Empty mutable dictionary to store data
    NSMutableDictionary *groupedDataDictionary = [[NSMutableDictionary alloc]init];
    
    BOOL isCurrentProfileBoosted = nil;
    BOOL islastProfileBoosted = nil;
    NSNumber *currentGroupIdToBeused = [NSNumber numberWithInt:0];
    NSMutableArray *arrayContainingGroupElements = [[NSMutableArray alloc]init];
    //When no groups have been made
    
    for (MeDashboard *boost in boostDataArray)
    {
        isCurrentProfileBoosted = boost.isVisitorBoosted.boolValue;
        //If last and current profile status is not the same
        //add a new group
        if (islastProfileBoosted != isCurrentProfileBoosted || [[groupedDataDictionary allKeys] count] == 0)
        {
            //create group for boost/nonboost
            currentGroupIdToBeused = [NSNumber numberWithInt:currentGroupIdToBeused.intValue+1];
            arrayContainingGroupElements = [[NSMutableArray alloc]init];
            [arrayContainingGroupElements addObject:boost];
        }
        else
        {
            [arrayContainingGroupElements addObject:boost];
        }
        [groupedDataDictionary setObject:arrayContainingGroupElements forKey:currentGroupIdToBeused];
        islastProfileBoosted = isCurrentProfileBoosted;
        
    }
    
    return groupedDataDictionary;
}

//Return distinct groups that exist in database
+(NSArray *)getDisctintGroupsForNonExpiredusers{
    
    NSArray *distintGroupsArray = nil;
    
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MeDashboard" inManagedObjectContext:managedObjectContext];
    
    NSSortDescriptor *groupIdSorting = [[NSSortDescriptor alloc] initWithKey:@"groupId" ascending:YES];
    
    NSDate *dateAfterDeletingDaysFromCurrentDate = [APP_Utilities dateAfterSubtractingDaysInCurrentDate:(int)[AppLaunchModel sharedInstance].meSectionProfileExpiryDaysThreshold];
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(visitorExpiryTime > %@)",dateAfterDeletingDaysFromCurrentDate];
    [request setPredicate:predicateObj];
    
    [request setEntity:entityDescription];
    [request setResultType:NSDictionaryResultType];
    [request setPropertiesToFetch:[NSArray arrayWithObject:[[entityDescription propertiesByName] objectForKey:@"groupId"]]];
    [request setReturnsDistinctResults:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:groupIdSorting]];
    NSError *error = nil;
    
    distintGroupsArray = [managedObjectContext executeFetchRequest:request error:&error];
    NSMutableArray *groupIdArray = [[NSMutableArray alloc] init];
    for (NSDictionary *keyDict in distintGroupsArray) {
        [groupIdArray addObject:[NSString stringWithFormat:@"%d",[[keyDict objectForKey:@"groupId"] intValue]]];
    }
    return (NSArray *)groupIdArray;
    
}
+(NSArray *)getNonExpiredVisitorsForGroupID:(NSString *)groupId{
    
    NSDate *dateAfterDeletingDaysFromCurrentDate = [APP_Utilities dateAfterSubtractingDaysInCurrentDate:(int)[AppLaunchModel sharedInstance].meSectionProfileExpiryDaysThreshold];
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MeDashboard" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(groupId == %@) AND (visitorExpiryTime > %@)",[NSNumber numberWithInt:[groupId intValue]],dateAfterDeletingDaysFromCurrentDate];
    
    [request setPredicate:predicateObj];
    
    NSSortDescriptor *groupIdSorting = [[NSSortDescriptor alloc] initWithKey:@"visitorExpiryTime" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:groupIdSorting]];
    
    NSError *error = nil;
    
    NSArray *selectedBoostArray = nil;
    if (managedObjectContext) {
        selectedBoostArray = [managedObjectContext executeFetchRequest:request error:&error];
    }
    
    return ([selectedBoostArray count]>0 ? selectedBoostArray : nil );
    
}


@end



