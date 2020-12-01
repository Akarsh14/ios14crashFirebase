//
//  LikedMe.m
//  Woo_v2
//
//  Created by Umesh Mishraji on 08/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "LikedMe.h"

@implementation LikedMe

// Insert code here to add functionality to your managed object subclass

// Insert code here to add functionality to your managed object subclass
static int expiryIndexForInsertionForLikedMe = 0;

static int insertionCompleted = true;

+(void)setInsertionCompleted:(int)value
{
    insertionCompleted = value;
}
+(int)getInsertionCompleted
{
    return insertionCompleted;
}

+(void)setExpiryIndexForInsertionForLikedMe:(int)value
{
    expiryIndexForInsertionForLikedMe = value;
}
+(int)getExpiryIndexForInsertionForLikedMe
{
    return expiryIndexForInsertionForLikedMe;
}

+(void)updateLikedMeData:(NSDictionary *)likedMeDict ForWooId:(NSString*)wooId
{
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    __block NSError *error = nil;
    if (privateManagedObjectContext)
    {
        [privateManagedObjectContext performBlock:^{
            
             LikedMe *likedMeProfileObj  = [[self getLikedMeDataForUserId:[likedMeDict objectForKey:@"wooUserId"]]firstObject];
            [likedMeProfileObj setUserWooId:[NSString stringWithFormat:@"%lld",[[likedMeDict objectForKey:@"wooUserId"] longLongValue]]];
            [likedMeProfileObj setUserFirstName:[likedMeDict objectForKey:@"firstName"]];
            [likedMeProfileObj setUserAge:[NSString stringWithFormat:@"%d",[[likedMeDict objectForKey:@"age"] intValue]]];
            [likedMeProfileObj setUserProfilePicURL:[likedMeDict objectForKey:@"profilePicUrl"]];
            if ([likedMeDict objectForKey:@"commonTagDto"]){
                [likedMeProfileObj setCommonTagDto:[likedMeDict objectForKey:@"commonTagDto"]];
            }
            if ([[likedMeDict allKeys] containsObject:@"gender"])
            {
                [likedMeProfileObj setUserGender:[likedMeDict objectForKey:@"gender"]];
                
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

+(void)insertOrUpdateLikedMeData:(NSArray *)likedDataArray withCompletionHandler:(InsertionCompletionHandler __nullable)completionHandler{
    
    insertionCompleted = false;
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    
        [privateManagedObjectContext performBlock:^{
            
            BOOL newRecordsAdded = NO;
            NSMutableArray *arrayOfNewAddedLikedMeProfiles = [[NSMutableArray alloc]init];
            
            if (likedDataArray && [likedDataArray count] > 0 ) {
                BOOL isLastVisitorProfileBoosted = [self isLastProfileBoosted:[likedDataArray firstObject]];
                NSInteger currentGroupIdToBeused = [self getGroupIdToBeUsed];
                
                for (NSDictionary *visitorDict in likedDataArray) {
                    
                    BOOL isCurrentProfileBoosted = [[visitorDict objectForKey:@"isActorBoosted"] boolValue];
                    
                    if (isLastVisitorProfileBoosted != isCurrentProfileBoosted) {
                        currentGroupIdToBeused++;
                    }
                    
                    NSArray *resultsArray =  [self getLikedMeDataForUserId:[visitorDict objectForKey:@"wooUserId"]];
                    
                    LikedMe *likedMeProfileObj = nil;
                    
                    if(resultsArray && [resultsArray count]>0)
                    {
                        likedMeProfileObj = [resultsArray firstObject];
                    }else
                    {
                        if (!likedMeProfileObj) {
                            likedMeProfileObj = (LikedMe *)[NSEntityDescription insertNewObjectForEntityForName:@"LikedMe" inManagedObjectContext:privateManagedObjectContext];
                            [likedMeProfileObj setGroupId:[NSNumber numberWithInteger:currentGroupIdToBeused]];
                            newRecordsAdded = YES;
                        }
                    }
                    if ([visitorDict objectForKey:@"commonTagDto"]){
                        [likedMeProfileObj setCommonTagDto:[visitorDict objectForKey:@"commonTagDto"]];
                    }
                        
                    [likedMeProfileObj setUserWooId:[NSString stringWithFormat:@"%lld",[[visitorDict objectForKey:@"wooUserId"] longLongValue]]];
                    [likedMeProfileObj setUserFirstName:[visitorDict objectForKey:@"firstName"]];
                    [likedMeProfileObj setUserAge:[NSString stringWithFormat:@"%d",[[visitorDict objectForKey:@"age"] intValue]]];
                    [likedMeProfileObj setUserProfilePicURL:[visitorDict objectForKey:@"profilePicUrl"]];
                    [likedMeProfileObj setIsUserBoosted:[NSNumber numberWithBool:isCurrentProfileBoosted]];
                    [likedMeProfileObj setIsUserLiked:[NSNumber numberWithBool:[[visitorDict objectForKey:@"like"] boolValue]]];
                    if (![likedMeProfileObj.isUserProfileSeenbyAppUser boolValue]) {
                        [likedMeProfileObj setIsUserProfileSeenbyAppUser:@FALSE];
                    }
                    
                    if ([[visitorDict allKeys] containsObject:@"bagdeType"]) {
                        [likedMeProfileObj setBadgeType:[visitorDict objectForKey:@"bagdeType"]];
                    }
                    else{
                        [likedMeProfileObj setBadgeType:@"NONE"];
                    }
                    
                    if ([[visitorDict allKeys] containsObject:@"gender"]) {
                        [likedMeProfileObj setUserGender:[visitorDict objectForKey:@"gender"]];
                    }
                    
                    isLastVisitorProfileBoosted = isCurrentProfileBoosted;
                    
                    
                    NSString *visitorExpiryTime = [visitorDict objectForKey:@"time"];
                    long long int serverTimeInMilliSecs = [visitorExpiryTime longLongValue];
                    NSDate *dateToBeStoredInDb = [NSDate dateWithTimeIntervalSince1970:serverTimeInMilliSecs/1000];
                    
                    [likedMeProfileObj setUserExpiryTime:dateToBeStoredInDb];
                    
                    NSLog(@"\n\n\n\n\n\n------------------- IN SAVE DATA----------- \n\n\n\n\n");
                    [arrayOfNewAddedLikedMeProfiles addObject:likedMeProfileObj];
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
                        insertionCompleted = true;
                        if (newRecordsAdded)
                        {
                            
                            [[NSNotificationCenter defaultCenter] postNotificationName:kNewLikedMeProfileAddedOnPagination object:arrayOfNewAddedLikedMeProfiles];
                        }
                        
                        
                        if(completionHandler)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[WooScreenManager sharedInstance].oHomeViewController checkAndshowUnreadBadgeOnAboutMeIcon];
                                completionHandler(TRUE);
                            });
                        }
                    }];
                    
                }
            }
            
            /*****************************************************************************/
            
        }];
        
}

+(NSArray *)getAllLikedMeProfiles{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"LikedMe" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    //NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(userWooId>0)"];
    
    //[request setPredicate:predicateObj];

    
    NSArray *allBoosts = [managedObjectContext executeFetchRequest:request error:&error];
    if(!error)
    {
        return  ([allBoosts count]>0 ? allBoosts : [[NSArray alloc] init] );
    }
    else
    {
        return  [[NSArray alloc] init];
    }
}


+(NSArray *)getIdsForAllLikedMeProfiles{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"LikedMe" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    [request setPropertiesToFetch:[NSArray arrayWithObject:@"userWooId"]];
    [request setResultType:NSDictionaryResultType];
    NSArray *allBoosts = [managedObjectContext executeFetchRequest:request error:&error] ;
    NSMutableArray *arrayOfIDs = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in allBoosts) {
        [arrayOfIDs addObject: [dict objectForKey:@"userWooId"]];
    }
    if(!error)
    {
        return  ([arrayOfIDs count]>0 ? arrayOfIDs : [[NSArray alloc] init] );
    }
    else
    {
        return  [[NSArray alloc] init];
    }
}

+(void)updateHasUserProfileVisitedByAppUser:(BOOL)isProfileVisited forUserWooId:(NSString *)userWooId withCompletionHandler:(UpdationCompletionHandler __nullable)completionHandler{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    __block NSError *error = nil;
    
        [privateManagedObjectContext performBlock:^{
            NSArray *resultsArray = [self getLikedMeDataForUserId:userWooId];
            if(resultsArray && [resultsArray count]>0)
            {
                LikedMe *likedMeObj = [resultsArray firstObject];

                [likedMeObj setIsUserProfileSeenbyAppUser:[NSNumber numberWithBool:isProfileVisited]];
                    
                    
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
                                if(completionHandler)
                                    completionHandler(TRUE);
                            }];
                            
                        }
                    }
                    
                    /*****************************************************************************/
            }else{
                
                // Do Nothing
                if(completionHandler)
                    completionHandler(TRUE);
            }
            
        }];
          
}

+(NSArray *)getLikedMeDataForUserId:(NSString *)userWooId{
    
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"LikedMe" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(userWooId==%@)",userWooId];
    
    [request setPredicate:predicateObj];
    
    NSError *error = nil;
    
    NSArray *selectedBoostArray = [managedObjectContext executeFetchRequest:request error:&error];

    return selectedBoostArray;
}

+(NSArray *)getIDsOfAllTheLikedMeProfileInDB{
    
    NSArray *boostArray =[self getIdsForAllLikedMeProfiles];
//    NSMutableArray *arrayOfIDs = [[NSMutableArray alloc] init];
//
//    for (LikedMe *likedObj in boostArray) {
//        [arrayOfIDs addObject:likedObj.userWooId];
//    }
    return boostArray;
}

+(NSInteger)getTotalNumberOfLikedMeProfiled{
    NSArray *boostArray =[self getAllLikedMeProfiles];
    return [boostArray count];
}

+(NSInteger)getTotalNumberOfUnvisitedLikedMeProfiles{
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
   
    NSDate *dateAfterDeletingDaysFromCurrentDate = [APP_Utilities dateAfterSubtractingDaysInCurrentDate:(int)[AppLaunchModel sharedInstance].meSectionProfileExpiryDays];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"LikedMe" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(isUserProfileSeenbyAppUser==%@) AND (userExpiryTime > %@)",[NSNumber numberWithBool:FALSE],dateAfterDeletingDaysFromCurrentDate];
    
    [request setPredicate:predicateObj];
    
    NSError *error = nil;
    
    NSArray *selectedBoostArray = [managedObjectContext executeFetchRequest:request error:&error];
    return [selectedBoostArray count];
}



+(void)deleteLikedMeProfileDataFromDBWithUserIDs:(NSArray *)idsToBeDeleted withCompletionHandler:(DeletionCompletionHandler __nullable)completionHandler{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    
    if (privateManagedObjectContext) {
        
        [privateManagedObjectContext performBlock:^{
         
            
            for (NSString *idToBeDeleted in idsToBeDeleted)
            {
                NSArray *toBeDeletedCrush = [self getLikedMeDataForUserId:idToBeDeleted];
                
                for (LikedMe *profile in toBeDeletedCrush)
                {
                    [privateManagedObjectContext deleteObject:profile];
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
                        
                        if(completionHandler)
                            completionHandler(TRUE);
                        
                    }];
                    
                }
            }
            
            /*****************************************************************************/
            
        }];
        
    }
    
}

/*
+(void)updateIsLikedMeProfileLikedStatusForUserId:(NSString *)userWooId{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];

    __block NSError *error = nil;
 
    if (privateManagedObjectContext) {
        
        [privateManagedObjectContext performBlock:^{
            
            NSArray *resultsArray = [self getLikedMeDataForUserId:userWooId];
            if(resultsArray && [resultsArray count]>0)
            {
                LikedMe *likedMeObj = [[self getLikedMeDataForUserId:userWooId] firstObject];
                if (likedMeObj) {
                    [likedMeObj setIsUserLiked:[NSNumber numberWithBool:TRUE]];
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

+(BOOL)isLastProfileBoosted:(NSDictionary *)firstObject{
    BOOL isLastProfileBoosted = FALSE;
    NSArray *allProfile = [self getAllLikedMeProfiles];
    if (allProfile && [allProfile count] > 0) {
        LikedMe *lastProfile = [allProfile lastObject];
        isLastProfileBoosted = [lastProfile.isUserBoosted boolValue];
    }
    else{
        isLastProfileBoosted = [[firstObject objectForKey:@"isActorBoosted"] boolValue];
    }
    return isLastProfileBoosted;
}

+(NSInteger)getGroupIdToBeUsed{
    
    NSInteger lastGroupId = 1;
    NSArray *allProfile = [self getAllLikedMeProfiles];
    if (allProfile && [allProfile count] > 0) {
        LikedMe *lastProfile = [allProfile lastObject];
        lastGroupId = [lastProfile.groupId integerValue];
    }
    
    return lastGroupId;
}

+(NSArray *)getDisctintGroups{
    NSArray *distintGroupsArray = nil;
    
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"LikedMe" inManagedObjectContext:managedObjectContext];
    
    NSSortDescriptor *groupIdSorting = [[NSSortDescriptor alloc] initWithKey:@"groupId" ascending:YES];
    
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
+(NSArray *)getLikeMeProfileForGroupID:(NSString *)groupId{
    
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"LikedMe" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(groupId==%@)",[NSNumber numberWithInt:[groupId intValue]]];
    
    [request setPredicate:predicateObj];
    
    NSSortDescriptor *groupIdSorting = [[NSSortDescriptor alloc] initWithKey:@"userExpiryTime" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:groupIdSorting]];
    
    NSError *error = nil;
    
    NSArray *selectedBoostArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    return ([selectedBoostArray count]>0 ? selectedBoostArray : nil);
    
}


/// new method that creates groups for all data present
+(NSMutableDictionary *)getGroupedLikeMeDataAccordingToTheGroups
{
    // Get all data sorted by timestamp desc
    NSArray *likedMeDataArray = [self getAllLikedMeProfilesSortedByTimestamp];
    // Create groups
    //Empty mutable dictionary to store data
    NSMutableDictionary *groupedDataDictionary = [[NSMutableDictionary alloc]init];
    
    BOOL isCurrentProfileBoosted = nil;
    BOOL islastProfileBoosted = nil;
    NSNumber *currentGroupIdToBeused = [NSNumber numberWithInt:0];
    NSMutableArray *arrayContainingGroupElements = [[NSMutableArray alloc]init];
    //When no groups have been made
    
    for (LikedMe *likedMe in likedMeDataArray)
    {
        isCurrentProfileBoosted = likedMe.isUserBoosted.boolValue;
        //If last and current profile status is not the same
        //add a new group
        if (islastProfileBoosted != isCurrentProfileBoosted || [[groupedDataDictionary allKeys] count] == 0)
        {
            //create group for boost/nonboost
            currentGroupIdToBeused = [NSNumber numberWithInt:currentGroupIdToBeused.intValue+1];
            arrayContainingGroupElements = [[NSMutableArray alloc]init];
            [arrayContainingGroupElements addObject:likedMe];
        }
        else
        {
            [arrayContainingGroupElements addObject:likedMe];
        }
        [groupedDataDictionary setObject:arrayContainingGroupElements forKey:currentGroupIdToBeused];
        islastProfileBoosted = isCurrentProfileBoosted;
        
    }
    return groupedDataDictionary;
}


//method to extract all profiles in timestamp descending
+(NSArray *)getAllLikedMeProfilesSortedByTimestamp
{
    
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"LikedMe" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"userExpiryTime" ascending:NO];
    NSPredicate *predicateObjBasedOnWooID = [NSPredicate predicateWithFormat:@"(userWooId != 0)"];
    [request setPredicate:predicateObjBasedOnWooID];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSArray *allLikedMe = [managedObjectContext executeFetchRequest:request error:&error];
    
   //duplicatePredicate
    NSMutableSet *seenDates = [NSMutableSet set];
    NSPredicate *duplicatePredicate = [NSPredicate predicateWithBlock: ^BOOL(id obj, NSDictionary *bind) {
        LikedMe *e = (LikedMe*)obj;
        BOOL seen = [seenDates containsObject:e.userWooId];
        if (!seen) {
            [seenDates addObject:e.userWooId];
        }
        return !seen;
    }];
    allLikedMe = [allLikedMe filteredArrayUsingPredicate:duplicatePredicate];

    return (NSMutableArray*) ([allLikedMe count]>0 ? allLikedMe : nil );
}


+(void)deleteAllLikedMeProfilesPresentInSystemForMoreThanDays:(int)numberOfDays{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    
    if (privateManagedObjectContext) {
        
        [privateManagedObjectContext performBlock:^{
            
            NSDate *dateAfterDeletingDaysFromCurrentDate = [APP_Utilities dateAfterSubtractingDaysInCurrentDate:numberOfDays];
            
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"LikedMe" inManagedObjectContext:privateManagedObjectContext];
            
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            
            [request setEntity:entityDescription];
            
            NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(userExpiryTime < %@)",dateAfterDeletingDaysFromCurrentDate];
            
            [request setPredicate:predicateObj];
            
            NSArray *selectedBoostArray = [privateManagedObjectContext executeFetchRequest:request error:&error];
            
            for (LikedMe *visitorToBeDeleted in selectedBoostArray) {
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
}

+(NSArray *)getAllExpiringLikedMeProfiles{
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSDate *dateAfterDeletingDaysFromCurrentDate = [APP_Utilities dateAfterSubtractingDaysInCurrentDate:(int)[AppLaunchModel sharedInstance].meSectionProfileExpiryDaysThreshold];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"LikedMe" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(userExpiryTime <= %@)",dateAfterDeletingDaysFromCurrentDate];
    NSPredicate *predicateObjBasedOnWooID = [NSPredicate predicateWithFormat:@"(userWooId != 0)"];
    NSPredicate *combinedPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicateObj, predicateObjBasedOnWooID]];
    [request setPredicate:combinedPredicate];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"userExpiryTime" ascending:YES];
    
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error = nil;
    
    NSArray *expiringvisitors = [managedObjectContext executeFetchRequest:request error:&error];
    
    NSMutableSet *seenDates = [NSMutableSet set];
    NSPredicate *duplicatePredicate = [NSPredicate predicateWithBlock: ^BOOL(id obj, NSDictionary *bind) {
        LikedMe *e = (LikedMe*)obj;
        BOOL seen = [seenDates containsObject:e.userWooId];
        if (!seen) {
            [seenDates addObject:e.userWooId];
        }
        return !seen;
    }];
    expiringvisitors = [expiringvisitors filteredArrayUsingPredicate:duplicatePredicate];
    return expiringvisitors;
    
}

+(NSArray *)getAllNonExpiringLikedMeProfiles{
    
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSDate *dateAfterDeletingDaysFromCurrentDate = [APP_Utilities dateAfterSubtractingDaysInCurrentDate:(int)[AppLaunchModel sharedInstance].meSectionProfileExpiryDaysThreshold];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"LikedMe" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(userExpiryTime > %@)",dateAfterDeletingDaysFromCurrentDate];
    NSPredicate *predicateObjBasedOnWooID = [NSPredicate predicateWithFormat:@"(userWooId != 0)"];
    NSPredicate *combinedPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicateObj, predicateObjBasedOnWooID]];
    [request setPredicate:combinedPredicate];
    
    NSError *error = nil;
    
    NSArray *nonExpiringVisitors = [managedObjectContext executeFetchRequest:request error:&error];
    //duplicatePredicate
    NSMutableSet *seenDates = [NSMutableSet set];
    NSPredicate *duplicatePredicate = [NSPredicate predicateWithBlock: ^BOOL(id obj, NSDictionary *bind) {
        LikedMe *e = (LikedMe*)obj;
        BOOL seen = [seenDates containsObject:e.userWooId];
        if (!seen) {
            [seenDates addObject:e.userWooId];
        }
        return !seen;
    }];
    nonExpiringVisitors = [nonExpiringVisitors filteredArrayUsingPredicate:duplicatePredicate];

    
    return nonExpiringVisitors;
    
}

//method to extract all non expiring profiles in timestamp descending
+(NSArray *)getAllNonExpiringLikedMeProfilesSortedByTimestamp{
    
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    NSDate *dateAfterDeletingDaysFromCurrentDate = [APP_Utilities dateAfterSubtractingDaysInCurrentDate:(int)[AppLaunchModel sharedInstance].meSectionProfileExpiryDaysThreshold];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"LikedMe" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"userExpiryTime" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(userExpiryTime > %@)",dateAfterDeletingDaysFromCurrentDate];
    NSPredicate *predicateObjBasedOnWooID = [NSPredicate predicateWithFormat:@"(userWooId != 0)"];
    NSPredicate *combinedPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicateObj, predicateObjBasedOnWooID]];
    [request setPredicate:combinedPredicate];
    NSError *error = nil;
    
    NSArray *nonExpiringVisitors = [managedObjectContext executeFetchRequest:request error:&error];
    
    NSMutableSet *seenDates = [NSMutableSet set];
    NSPredicate *duplicatePredicate = [NSPredicate predicateWithBlock: ^BOOL(id obj, NSDictionary *bind) {
        LikedMe *e = (LikedMe*)obj;
        BOOL seen = [seenDates containsObject:e.userWooId];
        if (!seen) {
            [seenDates addObject:e.userWooId];
        }
        return !seen;
    }];
    nonExpiringVisitors = [nonExpiringVisitors filteredArrayUsingPredicate:duplicatePredicate];

    return nonExpiringVisitors;
}

+(NSMutableDictionary *)getNonExpiredGroupedLikeMeDataAccordingToTheGroups
{
    
    // Get all data sorted by timestamp desc
    NSArray *likedMeDataArray = [self getAllNonExpiringLikedMeProfilesSortedByTimestamp];
    // Create groups
    //Empty mutable dictionary to store data
    NSMutableDictionary *groupedDataDictionary = [[NSMutableDictionary alloc]init];
    
    BOOL isCurrentProfileBoosted = nil;
    BOOL islastProfileBoosted = nil;
    NSNumber *currentGroupIdToBeused = [NSNumber numberWithInt:0];
    NSMutableArray *arrayContainingGroupElements = [[NSMutableArray alloc]init];
    //When no groups have been made
    
    for (LikedMe *likedMe in likedMeDataArray)
    {
        isCurrentProfileBoosted = likedMe.isUserBoosted.boolValue;
        //If last and current profile status is not the same
        //add a new group
        if (islastProfileBoosted != isCurrentProfileBoosted || [[groupedDataDictionary allKeys] count] == 0)
        {
            //create group for boost/nonboost
            currentGroupIdToBeused = [NSNumber numberWithInt:currentGroupIdToBeused.intValue+1];
            arrayContainingGroupElements = [[NSMutableArray alloc]init];
            [arrayContainingGroupElements addObject:likedMe];
        }
        else
        {
            [arrayContainingGroupElements addObject:likedMe];
        }
        [groupedDataDictionary setObject:arrayContainingGroupElements forKey:currentGroupIdToBeused];
        islastProfileBoosted = isCurrentProfileBoosted;
        
    }
    return groupedDataDictionary;
}



+(NSArray *)getDisctintGroupsForNonExpiredusers{
    
    NSArray *distintGroupsArray = nil;
    
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"LikedMe" inManagedObjectContext:managedObjectContext];
    
    NSSortDescriptor *groupIdSorting = [[NSSortDescriptor alloc] initWithKey:@"groupId" ascending:YES];
    
    NSDate *dateAfterDeletingDaysFromCurrentDate = [APP_Utilities dateAfterSubtractingDaysInCurrentDate:(int)[AppLaunchModel sharedInstance].meSectionProfileExpiryDaysThreshold];
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(userExpiryTime > %@)",dateAfterDeletingDaysFromCurrentDate];
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
+(NSArray *)getNonExpiredLikeMeProfileForGroupID:(NSString *)groupId{
    
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    NSDate *dateAfterDeletingDaysFromCurrentDate = [APP_Utilities dateAfterSubtractingDaysInCurrentDate:(int)[AppLaunchModel sharedInstance].meSectionProfileExpiryDaysThreshold];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"LikedMe" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(groupId==%@) AND (userExpiryTime > %@)",[NSNumber numberWithInt:[groupId intValue]],dateAfterDeletingDaysFromCurrentDate];
    
    [request setPredicate:predicateObj];
    
    NSSortDescriptor *groupIdSorting = [[NSSortDescriptor alloc] initWithKey:@"userExpiryTime" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:groupIdSorting]];
    
    NSError *error = nil;
    
    NSArray *selectedBoostArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    return ([selectedBoostArray count]>0 ? selectedBoostArray : nil);
    
}

@end
