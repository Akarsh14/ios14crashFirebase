//
//  LikedByMe+CoreDataClass.m
//  
//
//  Created by Harish Kuramsetty on 10/29/19.
//
//

#import "LikedByMe.h"

@implementation LikedByMe


static int expiryIndexForInsertionForSkipped = 0;
static int insertionCompleted = true;


+(void)setExpiryIndexForInsertionForSkipped:(int)value
{
    expiryIndexForInsertionForSkipped = value;
}
+(int)getExpiryIndexForInsertionForSkipped
{
    return expiryIndexForInsertionForSkipped;
}

+(void)setInsertionCompleted:(int)value
{
    insertionCompleted = value;
}
+(int)getInsertionCompleted
{
    return insertionCompleted;
}

+(void)updateSkippedData:(NSDictionary *)skippedDict // ForWooId:(NSString*)wooId
{
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    __block NSError *error = nil;
    if (privateManagedObjectContext)
    {
        [privateManagedObjectContext performBlock:^{
            
            LikedByMe *skippedProfileObj  = [[self getSkippedProfileDataForUserId:[skippedDict objectForKey:@"wooUserId"]]firstObject];
            [skippedProfileObj setUserWooId:[NSString stringWithFormat:@"%lld",[[skippedDict objectForKey:@"wooUserId"] longLongValue]]];
            [skippedProfileObj setUserFirstName:[skippedDict objectForKey:@"firstName"]];
            [skippedProfileObj setUserAge:[NSString stringWithFormat:@"%d",[[skippedDict objectForKey:@"age"] intValue]]];
            [skippedProfileObj setUserProfilePicURL:[skippedDict objectForKey:@"profilePicUrl"]];
            
            if ([[skippedDict allKeys] containsObject:@"gender"])
            {
                [skippedProfileObj setUserGender:[skippedDict objectForKey:@"gender"]];
                
            }
            NSLog(@"privateManagedObjectContext");
            /***************************Save Context*************************************/
            if (privateManagedObjectContext != nil)
            {
                if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error])
                { NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    //abort();
                }
                else{
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

+(void)insertOrUpdateSkippedProfileDataFromDiscoverCard:(NSArray *)skippedProfileDataArray withCompletionHandler:(InsertionCompletionHandler __nullable)completionHandler{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    __block NSError *error = nil;
    
        [privateManagedObjectContext performBlock:^{
            
            // Insertion of skipped profiles
            
            /***************************************************************/
            
            if (skippedProfileDataArray && [skippedProfileDataArray count] > 0 ) {
                
                for (ProfileCardModel *skippedProfileDetail in skippedProfileDataArray) {
                    
                    if ([skippedProfileDetail.wooId isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]]) {
                        continue;
                    }
                    
                    NSArray * resultsArray = [self getSkippedProfileDataForUserId:skippedProfileDetail.wooId];
                    
                    LikedByMe *skippedProfileObj = nil;
                    if(resultsArray && [resultsArray count] >0)
                    {
                        skippedProfileObj = [resultsArray firstObject];
                    }
                    else
                    {
                        if (!skippedProfileObj) {
                            skippedProfileObj = (LikedByMe *)[NSEntityDescription insertNewObjectForEntityForName:@"LikedByMe" inManagedObjectContext:privateManagedObjectContext];
                        }
                    }
                    
                    //54321
                    /*
                        BoostDashboard *boostObj = (BoostDashboard *)[NSEntityDescription insertNewObjectForEntityForName:@"BoostDashboard" inManagedObjectContext:privateManagedObjectContext];
                    int r = arc4random_uniform(563334);
                    [boostObj setVisitorId:[NSString stringWithFormat:@"%d",r]];
                    [boostObj setVisitorFirstName:@"AS"];
                    [boostObj setVisitorAge:@"23"];
                    [boostObj setVisitorProfilePicURL:@""];
                    [boostObj setVisitorExpiryTime:[APP_Utilities dateAfterSubtractingDaysInCurrentDate:0]];
                    [boostObj setIsVisitorBoosted:[NSNumber numberWithBool:true]];
                    
                    LikedMe *likedMeProfileObj = (LikedMe *)[NSEntityDescription insertNewObjectForEntityForName:@"LikedMe" inManagedObjectContext:privateManagedObjectContext];
                    [likedMeProfileObj setUserWooId:[NSString stringWithFormat:@"%d",r]];
                    [likedMeProfileObj setUserFirstName:@"AS"];
                    [likedMeProfileObj setUserAge:@"23"];
                    [likedMeProfileObj setUserProfilePicURL:@""];
                    [likedMeProfileObj setIsUserBoosted:[NSNumber numberWithBool:true]];
                    [likedMeProfileObj setUserExpiryTime:[APP_Utilities dateAfterSubtractingDaysInCurrentDate:0]];
                    */
                     
                    
                    [skippedProfileObj setIsUserLiked:[NSNumber numberWithBool:skippedProfileDetail.isProfileLiked]];
                    [skippedProfileObj setUserWooId:skippedProfileDetail.wooId];
                    [skippedProfileObj setUserFirstName:skippedProfileDetail.firstName];
                    [skippedProfileObj setUserAge:skippedProfileDetail.age];
                    [skippedProfileObj setUserProfilePicURL:skippedProfileDetail.wooAlbum.discoverProfilePicUrl];
                    [skippedProfileObj setUserGender:skippedProfileDetail.gender];
                    
                    if (skippedProfileDetail.commonTagDto != nil){
                        [skippedProfileObj setCommonTagDto:skippedProfileDetail.commonTagDto];
                    }
                    
                    if (skippedProfileObj.isUserProfileSeenbyAppUser == nil) {
                        [skippedProfileObj setIsUserProfileSeenbyAppUser:@FALSE];
                    }
                    [skippedProfileObj setUserExpiryTime:[APP_Utilities dateAfterSubtractingDaysInCurrentDate:0]];
                    [skippedProfileObj setBadgeType:[skippedProfileDetail getBadgeType]];

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
                            insertionCompleted = true;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                [AppLaunchModel sharedInstance].isNewDataPresentInLikedByMeSection = true;
                                BOOL hasVisitedLikedByMeSection = [[NSUserDefaults standardUserDefaults] boolForKey:@"hasVisitedLikedByMeSection"];
                                if(!hasVisitedLikedByMeSection)
                                {
                                    [[WooScreenManager sharedInstance].oHomeViewController checkAndshowUnreadBadgeOnAboutMeIcon];
                                }
                                if(completionHandler)
                                    completionHandler(TRUE);
                            });
                            
                        }];
                        
                    }
                }
                
                /*****************************************************************************/
            }
            
        }];
    
}


+(void)insertOrUpdateSkippedProfileData:(NSArray *)skippedProfileDataArray withCompletionHandler:(InsertionCompletionHandler __nullable)completionHandler{
    insertionCompleted = false;
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    __block NSError *error = nil;
    
    
        [privateManagedObjectContext performBlock:^{
            
            BOOL newRecordsAded = NO;
            NSMutableArray *arrayOfNewLikedByMe = [[NSMutableArray alloc]init];
            
            for (NSDictionary *skippedProfileDict in skippedProfileDataArray) {
                
                
                NSString *myWooId = [NSString stringWithFormat:@"%lld",[[skippedProfileDict objectForKey:@"wooUserId"] longLongValue]];
                
                if ([myWooId isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]]) {
                    continue;
                }
                
                BOOL isCurrentProfileBoosted = [[skippedProfileDict objectForKey:@"isActorBoosted"] boolValue];

                NSArray * resultsArray = [self getSkippedProfileDataForUserId:[skippedProfileDict objectForKey:@"wooUserId"]];
                
                
                LikedByMe *skippedProfileObj = nil;
                if(resultsArray && [resultsArray count] >0)
                {
                    skippedProfileObj = [resultsArray firstObject];
                }
                else{
                    if (!skippedProfileObj) {
                        skippedProfileObj = (LikedByMe *)[NSEntityDescription insertNewObjectForEntityForName:@"LikedByMe" inManagedObjectContext:privateManagedObjectContext];
                        newRecordsAded = YES;
                        
                    }
                }
                if ([skippedProfileDict objectForKey:@"commonTagDto"]){
                    [skippedProfileObj setCommonTagDto:[skippedProfileDict objectForKey:@"commonTagDto"]];
                }
                [skippedProfileObj setUserWooId:[NSString stringWithFormat:@"%lld",[[skippedProfileDict objectForKey:@"wooUserId"] longLongValue]]];
                [skippedProfileObj setUserFirstName:[skippedProfileDict objectForKey:@"firstName"]];
                [skippedProfileObj setUserAge:[NSString stringWithFormat:@"%d",[[skippedProfileDict objectForKey:@"age"] intValue]]];
                [skippedProfileObj setUserProfilePicURL:[skippedProfileDict objectForKey:@"profilePicUrl"]];
                [skippedProfileObj setIsUserBoosted:[NSNumber numberWithBool:isCurrentProfileBoosted]];

                if (skippedProfileObj.isUserProfileSeenbyAppUser == nil) {
                    [skippedProfileObj setIsUserProfileSeenbyAppUser:@FALSE];
                }
                
                if ([[skippedProfileDict allKeys] containsObject:@"bagdeType"]) {
                    [skippedProfileObj setBadgeType:[skippedProfileDict objectForKey:@"bagdeType"]];
                }
                else{
                    [skippedProfileObj setBadgeType:@"NONE"];
                }
                
                if ([[skippedProfileDict allKeys] containsObject:@"gender"]) {
                    [skippedProfileObj setUserGender:[skippedProfileDict objectForKey:@"gender"]];
                }
                
                
                NSString *visitorExpiryTime = [skippedProfileDict objectForKey:@"time"];
                long long int serverTimeInMilliSecs = [visitorExpiryTime longLongValue];
                NSDate *dateToBeStoredInDb = [NSDate dateWithTimeIntervalSince1970:serverTimeInMilliSecs/1000];
                
                [skippedProfileObj setUserExpiryTime:dateToBeStoredInDb];
                
                NSLog(@"\n\n\n\n\n\n------------------- IN SAVE DATA----------- \n\n\n\n\n");
                [arrayOfNewLikedByMe addObject:skippedProfileObj];
                
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
                        insertionCompleted = true;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            if (newRecordsAded)
                            {
                                [[NSNotificationCenter defaultCenter] postNotificationName:kNewLikedByMeAddedOnPagination object:arrayOfNewLikedByMe];
                            }
                           
                            if(completionHandler){
                                completionHandler(TRUE);
                            }
                        });
                        
                    }];
                    
                }
            }
            
            /*****************************************************************************/
        }];
    
    
}

+(NSArray *)getAllLikedByMe{
    
    NSError *error = nil;

    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"LikedByMe" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    [request setReturnsObjectsAsFaults:false];
    
    NSSortDescriptor *groupIdSorting = [[NSSortDescriptor alloc] initWithKey:@"userExpiryTime" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:groupIdSorting]];
    NSPredicate *predicateObjBasedOnWooID = [NSPredicate predicateWithFormat:@"(userWooId != 0)"];
    [request setPredicate:predicateObjBasedOnWooID];
    NSArray *allLikedByMe = [managedObjectContext executeFetchRequest:request error:&error];
    
    NSMutableSet *seenDates = [NSMutableSet set];
    NSPredicate *duplicatePredicate = [NSPredicate predicateWithBlock: ^BOOL(id obj, NSDictionary *bind) {
        LikedByMe *e = (LikedByMe*)obj;
        BOOL seen = [seenDates containsObject:e.userWooId];
        if (!seen) {
            [seenDates addObject:e.userWooId];
        }
        return !seen;
    }];
    allLikedByMe = [allLikedByMe filteredArrayUsingPredicate:duplicatePredicate];
    

    return (NSMutableArray*) ([allLikedByMe count]>0 ? allLikedByMe : nil );
}

+(void)updateHasUserProfileVisitedByAppUser:(BOOL)isProfileVisited forUserWooId:(NSString *)userWooId withCompletionHandler:(UpdationCompletionHandler __nullable)completionHandler{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];

    __block NSError *error = nil;
    
        [privateManagedObjectContext performBlock:^{
            
            NSArray * resultsArray = [self getSkippedProfileDataForUserId:userWooId];
            
            LikedByMe *skippedProfileObj = nil;
         
            if(resultsArray && [resultsArray count] >0)
            {
                skippedProfileObj = [resultsArray firstObject];
                
                if (skippedProfileObj) {
                    
                    [skippedProfileObj setIsUserProfileSeenbyAppUser:[NSNumber numberWithBool:isProfileVisited]];
                    
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
                                
                                // Do Nothing
                                if(completionHandler){
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        completionHandler(true);
                                    });
                                }
                            }];
                            
                        }
                    }
                    
                    /*****************************************************************************/
                }else{
                    if(completionHandler){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completionHandler(true);
                        });
                    }
                }
            }else{
                if(completionHandler){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionHandler(true);
                    });
                }
            }
            
        }];
    
}

+(NSArray *)getSkippedProfileDataForUserId:(NSString *)userWooId{
    
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"LikedByMe" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(userWooId==%@)",userWooId];
    
    [request setPredicate:predicateObj];
    
    NSError *error = nil;
    
    NSArray *selectedBoostArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    return selectedBoostArray;
}

+(NSArray *)getIDsOfAllSkippedProfileInDB{
    
    NSArray *skippedProfileArray =[self getAllLikedByMe];
    NSMutableArray *arrayOfIDs = [[NSMutableArray alloc] init];
    
    for (LikedByMe *skippedProfileObj in skippedProfileArray) {
        
        if (skippedProfileObj.userWooId != nil) {
            [arrayOfIDs addObject:skippedProfileObj.userWooId];
        }
    }
    return arrayOfIDs;
}

+(NSInteger)getTotalNumberOfSkippedProfiled{
    NSArray *boostArray =[self getAllLikedByMe];
    return [boostArray count];
}

+(NSInteger)getTotalNumberOfUnvisitedLikedByMe{
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSDate *dateAfterDeletingDaysFromCurrentDate = [APP_Utilities dateAfterSubtractingDaysInCurrentDate:(int)[AppLaunchModel sharedInstance].meSectionProfileExpiryDays];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"LikedByMe" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(isUserProfileSeenbyAppUser==%@) AND (userExpiryTime > %@)",[NSNumber numberWithBool:FALSE],dateAfterDeletingDaysFromCurrentDate];
    
    [request setPredicate:predicateObj];
    
    NSError *error = nil;
    
    NSArray *selectedBoostArray = [managedObjectContext executeFetchRequest:request error:&error];
    return [selectedBoostArray count];
}



+(void)deleteSkippedProfileDataFromDBWithUserIDs:(NSArray *)idsToBeDeleted withCompletionHandler:(DeletionCompletionHandler)completionHandler{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    
        [privateManagedObjectContext performBlock:^{
            
            BOOL isDeleted = FALSE;

            for (NSString *idToBeDeleted in idsToBeDeleted) {
               
                NSArray *toBeDeletedCrush = [self getSkippedProfileDataForUserId:idToBeDeleted];
                
                if ([toBeDeletedCrush count] > 0) {
                    isDeleted = TRUE;
                    for (LikedByMe *profile in toBeDeletedCrush) {
                        [privateManagedObjectContext deleteObject:profile];
                    }
                }
            }
            
            /***************************Save Context*************************************/
            
            if (isDeleted && privateManagedObjectContext != nil) {
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
            }else{
                if(completionHandler){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionHandler(true);
                    });
                }
            }
            
            /*****************************************************************************/
            
        }];
}

/*
+(void)updateIsLikedMeProfileLikedStatusForUserId:(NSString *)userWooId{

    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    if (privateManagedObjectContext) {
        
        [privateManagedObjectContext performBlock:^{
            
            NSArray *resultsArray = [self getSkippedProfileDataForUserId:userWooId];
            LikedByMe * skippedProfileObj = nil;
            if(resultsArray && [resultsArray count] >0)
            {
                skippedProfileObj = [resultsArray firstObject];
                if (skippedProfileObj) {
                    [skippedProfileObj setIsUserLiked:[NSNumber numberWithBool:TRUE]];
                }
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
                        
                        // Do Nothing
                        
                    }];
                    
                }
            }
 
        }];
    }
}
 */


+(NSArray *)getIDsOfAllTheSkippedProfileInDB{
    
    NSArray *boostArray =[self getAllLikedByMe];
    NSMutableArray *arrayOfIDs = [[NSMutableArray alloc] init];
    
    if ([arrayOfIDs count] > 0) {
        [arrayOfIDs removeAllObjects];
    }
    
    for (LikedByMe *skippedObj in boostArray) {
        [arrayOfIDs addObject:skippedObj.userWooId];
    }
    return arrayOfIDs;
}

+(void)deleteAllLikedByMePresentInSystemForMoreThanDays:(int)numberOfDays{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    
        [privateManagedObjectContext performBlock:^{
            
            NSDate *dateAfterDeletingDaysFromCurrentDate = [APP_Utilities dateAfterSubtractingDaysInCurrentDate:numberOfDays];
            
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"LikedByMe" inManagedObjectContext:privateManagedObjectContext];
            
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            
            [request setEntity:entityDescription];
            
            NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(userExpiryTime < %@)",dateAfterDeletingDaysFromCurrentDate];
            
            [request setPredicate:predicateObj];
            
            NSArray *selectedBoostArray = [privateManagedObjectContext executeFetchRequest:request error:&error];
            
            for (LikedByMe *visitorToBeDeleted in selectedBoostArray) {
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
                        
                        // Do Nothing
                        
                    }];
                    
                }
            }
            
            /*****************************************************************************/
            
        }];
    
}
+(NSArray *)getAllExpiringLikedByMe{
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSDate *dateAfterDeletingDaysFromCurrentDate = [APP_Utilities dateAfterSubtractingDaysInCurrentDate:(int)[AppLaunchModel sharedInstance].meSectionProfileExpiryDaysThreshold];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"LikedByMe" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(userExpiryTime <= %@)",dateAfterDeletingDaysFromCurrentDate];
    NSPredicate *predicateObjBasedOnWooID = [NSPredicate predicateWithFormat:@"(userWooId != 0)"];
    NSPredicate *combinedPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicateObj, predicateObjBasedOnWooID]];
    [request setPredicate:combinedPredicate];
        
    NSSortDescriptor *groupIdSorting = [[NSSortDescriptor alloc] initWithKey:@"userExpiryTime" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:groupIdSorting]];

    NSError *error = nil;
    
    NSArray *expiringUsers = [managedObjectContext executeFetchRequest:request error:&error];
    
    NSMutableSet *seenDates = [NSMutableSet set];
    NSPredicate *duplicatePredicate = [NSPredicate predicateWithBlock: ^BOOL(id obj, NSDictionary *bind) {
        LikedByMe *e = (LikedByMe*)obj;
        BOOL seen = [seenDates containsObject:e.userWooId];
        if (!seen) {
            [seenDates addObject:e.userWooId];
        }
        return !seen;
    }];
    expiringUsers = [expiringUsers filteredArrayUsingPredicate:duplicatePredicate];

    return expiringUsers;
    
}

+(NSArray *)getAllNonExpiringLikedByMe{
    
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSDate *dateAfterDeletingDaysFromCurrentDate = [APP_Utilities dateAfterSubtractingDaysInCurrentDate:(int)[AppLaunchModel sharedInstance].meSectionProfileExpiryDaysThreshold];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"LikedByMe" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    [request setReturnsObjectsAsFaults:false];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(userExpiryTime > %@)",dateAfterDeletingDaysFromCurrentDate];
    NSPredicate *predicateObjBasedOnWooID = [NSPredicate predicateWithFormat:@"(userWooId != 0)"];
    NSPredicate *combinedPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicateObj, predicateObjBasedOnWooID]];
    [request setPredicate:combinedPredicate];
    
    NSSortDescriptor *groupIdSorting = [[NSSortDescriptor alloc] initWithKey:@"userExpiryTime" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:groupIdSorting]];

    NSError *error = nil;
    
    NSArray *nonExpiringUsers = [managedObjectContext executeFetchRequest:request error:&error];
    
    NSMutableSet *seenDates = [NSMutableSet set];
    NSPredicate *duplicatePredicate = [NSPredicate predicateWithBlock: ^BOOL(id obj, NSDictionary *bind) {
        LikedByMe *e = (LikedByMe*)obj;
        BOOL seen = [seenDates containsObject:e.userWooId];
        if (!seen) {
            [seenDates addObject:e.userWooId];
        }
        return !seen;
    }];
    nonExpiringUsers = [nonExpiringUsers filteredArrayUsingPredicate:duplicatePredicate];

    return nonExpiringUsers;
    
}


@end
