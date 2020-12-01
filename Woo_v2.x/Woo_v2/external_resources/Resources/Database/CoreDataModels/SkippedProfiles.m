//
//  SkippedProfiles.m
//  Woo_v2
//
//  Created by Umesh Mishraji on 29/08/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "SkippedProfiles.h"

@implementation SkippedProfiles

// Insert code here to add functionality to your managed object subclass
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
            
            SkippedProfiles *skippedProfileObj  = [[self getSkippedProfileDataForUserId:[skippedDict objectForKey:@"wooUserId"]]firstObject];
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
                    
                    SkippedProfiles *skippedProfileObj = nil;
                    if(resultsArray && [resultsArray count] >0)
                    {
                        skippedProfileObj = [resultsArray firstObject];
                    }
                    else
                    {
                        if (!skippedProfileObj) {
                            skippedProfileObj = (SkippedProfiles *)[NSEntityDescription insertNewObjectForEntityForName:@"SkippedProfiles" inManagedObjectContext:privateManagedObjectContext];
                        }
                    }
                    
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
                                
                                [AppLaunchModel sharedInstance].isNewDataPresentInSkippedSection = true;
                                BOOL hasVisitedSkippedSection = [[NSUserDefaults standardUserDefaults] boolForKey:@"hasVisitedSkippedSection"];
                                if(!hasVisitedSkippedSection)
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
            NSMutableArray *arrayOfNewSkippedProfiles = [[NSMutableArray alloc]init];
            
            for (NSDictionary *skippedProfileDict in skippedProfileDataArray) {
                
                
                NSString *myWooId = [NSString stringWithFormat:@"%lld",[[skippedProfileDict objectForKey:@"wooUserId"] longLongValue]];
                
                if ([myWooId isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]]) {
                    continue;
                }
                
                BOOL isCurrentProfileBoosted = [[skippedProfileDict objectForKey:@"isActorBoosted"] boolValue];

                NSArray * resultsArray = [self getSkippedProfileDataForUserId:[skippedProfileDict objectForKey:@"wooUserId"]];
                
                
                SkippedProfiles *skippedProfileObj = nil;
                if(resultsArray && [resultsArray count] >0)
                {
                    skippedProfileObj = [resultsArray firstObject];
                }
                else{
                    if (!skippedProfileObj) {
                        skippedProfileObj = (SkippedProfiles *)[NSEntityDescription insertNewObjectForEntityForName:@"SkippedProfiles" inManagedObjectContext:privateManagedObjectContext];
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
                [arrayOfNewSkippedProfiles addObject:skippedProfileObj];
                
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
                                [[NSNotificationCenter defaultCenter] postNotificationName:kNewSkippedProfilesAddedOnPagination object:arrayOfNewSkippedProfiles];
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

+(NSArray *)getAllSkippedProfiles{
    
    NSError *error = nil;

    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"SkippedProfiles" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    [request setReturnsObjectsAsFaults:false];
    
    NSSortDescriptor *groupIdSorting = [[NSSortDescriptor alloc] initWithKey:@"userExpiryTime" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:groupIdSorting]];
    NSPredicate *predicateObjBasedOnWooID = [NSPredicate predicateWithFormat:@"(userWooId != 0)"];
    [request setPredicate:predicateObjBasedOnWooID];
    NSArray *allSkippedProfiles = [managedObjectContext executeFetchRequest:request error:&error];
    
    NSMutableSet *seenDates = [NSMutableSet set];
    NSPredicate *duplicatePredicate = [NSPredicate predicateWithBlock: ^BOOL(id obj, NSDictionary *bind) {
        SkippedProfiles *e = (SkippedProfiles*)obj;
        BOOL seen = [seenDates containsObject:e.userWooId];
        if (!seen) {
            [seenDates addObject:e.userWooId];
        }
        return !seen;
    }];
    allSkippedProfiles = [allSkippedProfiles filteredArrayUsingPredicate:duplicatePredicate];
    

    return (NSMutableArray*) ([allSkippedProfiles count]>0 ? allSkippedProfiles : nil );
}

+(void)updateHasUserProfileVisitedByAppUser:(BOOL)isProfileVisited forUserWooId:(NSString *)userWooId withCompletionHandler:(UpdationCompletionHandler __nullable)completionHandler{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];

    __block NSError *error = nil;
    
        [privateManagedObjectContext performBlock:^{
            
            NSArray * resultsArray = [self getSkippedProfileDataForUserId:userWooId];
            
            SkippedProfiles *skippedProfileObj = nil;
         
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
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"SkippedProfiles" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(userWooId==%@)",userWooId];
    
    [request setPredicate:predicateObj];
    
    NSError *error = nil;
    
    NSArray *selectedBoostArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    return selectedBoostArray;
}

+(NSArray *)getIDsOfAllSkippedProfileInDB{
    
    NSArray *skippedProfileArray =[self getAllSkippedProfiles];
    NSMutableArray *arrayOfIDs = [[NSMutableArray alloc] init];
    
    for (SkippedProfiles *skippedProfileObj in skippedProfileArray) {
        
        if (skippedProfileObj.userWooId != nil) {
            [arrayOfIDs addObject:skippedProfileObj.userWooId];
        }
    }
    return arrayOfIDs;
}

+(NSInteger)getTotalNumberOfSkippedProfiled{
    NSArray *boostArray =[self getAllSkippedProfiles];
    return [boostArray count];
}

+(NSInteger)getTotalNumberOfUnvisitedSkippedProfiles{
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSDate *dateAfterDeletingDaysFromCurrentDate = [APP_Utilities dateAfterSubtractingDaysInCurrentDate:(int)[AppLaunchModel sharedInstance].meSectionProfileExpiryDays];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"SkippedProfiles" inManagedObjectContext:managedObjectContext];
    
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
                    for (SkippedProfiles *profile in toBeDeletedCrush) {
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
            SkippedProfiles * skippedProfileObj = nil;
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
    
    NSArray *boostArray =[self getAllSkippedProfiles];
    NSMutableArray *arrayOfIDs = [[NSMutableArray alloc] init];
    
    if ([arrayOfIDs count] > 0) {
        [arrayOfIDs removeAllObjects];
    }
    
    for (SkippedProfiles *skippedObj in boostArray) {
        [arrayOfIDs addObject:skippedObj.userWooId];
    }
    return arrayOfIDs;
}

+(void)deleteAllSkippedProfilesPresentInSystemForMoreThanDays:(int)numberOfDays{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    
        [privateManagedObjectContext performBlock:^{
            
            NSDate *dateAfterDeletingDaysFromCurrentDate = [APP_Utilities dateAfterSubtractingDaysInCurrentDate:numberOfDays];
            
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"SkippedProfiles" inManagedObjectContext:privateManagedObjectContext];
            
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            
            [request setEntity:entityDescription];
            
            NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(userExpiryTime < %@)",dateAfterDeletingDaysFromCurrentDate];
            
            [request setPredicate:predicateObj];
            
            NSArray *selectedBoostArray = [privateManagedObjectContext executeFetchRequest:request error:&error];
            
            for (SkippedProfiles *visitorToBeDeleted in selectedBoostArray) {
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
+(NSArray *)getAllExpiringSKippedProfiles{
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSDate *dateAfterDeletingDaysFromCurrentDate = [APP_Utilities dateAfterSubtractingDaysInCurrentDate:(int)[AppLaunchModel sharedInstance].meSectionProfileExpiryDaysThreshold];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"SkippedProfiles" inManagedObjectContext:managedObjectContext];
    
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
        SkippedProfiles *e = (SkippedProfiles*)obj;
        BOOL seen = [seenDates containsObject:e.userWooId];
        if (!seen) {
            [seenDates addObject:e.userWooId];
        }
        return !seen;
    }];
    expiringUsers = [expiringUsers filteredArrayUsingPredicate:duplicatePredicate];

    return expiringUsers;
    
}

+(NSArray *)getAllNonExpiringSkippedProfiles{
    
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSDate *dateAfterDeletingDaysFromCurrentDate = [APP_Utilities dateAfterSubtractingDaysInCurrentDate:(int)[AppLaunchModel sharedInstance].meSectionProfileExpiryDaysThreshold];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"SkippedProfiles" inManagedObjectContext:managedObjectContext];
    
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
        SkippedProfiles *e = (SkippedProfiles*)obj;
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
