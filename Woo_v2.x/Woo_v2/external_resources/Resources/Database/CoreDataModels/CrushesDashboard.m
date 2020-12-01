//
//  CrushesDashboard.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 18/01/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "CrushesDashboard.h"

@implementation CrushesDashboard

// Insert code here to add functionality to your managed object subclass
+(void)insertOrUpdateCrushWithData:(NSArray *)crushesArray withCompletionHandler:(InsertionCompletionHandler __nullable)completionHandler{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    __block NSError *error = nil;
    
    if (privateManagedObjectContext) {
        
        [privateManagedObjectContext performBlock:^{
            
            [self insertCrushes:crushesArray withPrivateContext:privateManagedObjectContext];
            
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
                                completionHandler(TRUE);
                            });
                        }
                    }];
                    
                }
            }
            
            /*****************************************************************************/
            
        }];
        
    }
    
}

+(void)updateCrushesData:(NSDictionary *)crushesDict ForWooId:(NSString*)wooId
{
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    __block NSError *error = nil;
    if (privateManagedObjectContext)
    {
        [privateManagedObjectContext performBlock:^{
            
            CrushesDashboard *crushObj = [self getDataCorCrushWithUserID:[crushesDict objectForKey:@"wooUserId"]];
            [crushObj setUserID:[NSString stringWithFormat:@"%lld",[[crushesDict objectForKey:@"wooUserId"] longLongValue]]];
            [crushObj setUserName:[crushesDict objectForKey:@"firstName"]];
            [crushObj setUserAge:[NSString stringWithFormat:@"%d",[[crushesDict objectForKey:@"age"] intValue]]];
            [crushObj setImageURL:[crushesDict objectForKey:@"profilePicUrl"]];
            
            if ([[crushesDict allKeys] containsObject:@"gender"])
            {
                [crushObj setUserGender:[crushesDict objectForKey:@"gender"]];
                
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
                         }
                         
                     }];
                    
                }
            }
        }];
        
    }
}
+(void)insertCrushes:(NSArray *)crushesArray withPrivateContext:(NSManagedObjectContext *)privateContext{
    
    if (crushesArray && [crushesArray count] > 0 ) {
        
        // Adding Group Id Logic *******************************
        
        BOOL isLastVisitorProfileBoosted = [self isLastProfileBoosted:[crushesArray firstObject]];
        NSInteger currentGroupIdToBeused = [self getGroupIdToBeUsed];
        
        
        // Adding Group Id Logic *****************************
        
        
        
        for (NSDictionary *crushDict in crushesArray) {
            
            // Adding Group Id Logic *****************************
            
            BOOL isCurrentProfileBoosted = [[crushDict objectForKey:@"isActorBoosted"] boolValue];
            
            if (isLastVisitorProfileBoosted != isCurrentProfileBoosted) {
                currentGroupIdToBeused++;
            }
            
            // Adding Group Id Logic *****************************
            
            
            
            if ([[APP_Utilities validString:[crushDict objectForKey:@"crushText"]] length] > 0 ){
                CrushesDashboard *crushObj = [self getDataCorCrushWithUserID:[crushDict objectForKey:@"wooUserId"]];
                
                if (!crushObj) {
                    crushObj = (CrushesDashboard *)[NSEntityDescription insertNewObjectForEntityForName:@"CrushesDashboard" inManagedObjectContext:privateContext];
                    [crushObj setHasSeen:@0];
                    
                    [crushObj setGroupId:[NSNumber numberWithInteger:currentGroupIdToBeused]];
                    
                }else{
                    // [crushObj setHasSeen:@1];
                }
                
                [crushObj setUserID:[[crushDict objectForKey:@"wooUserId"] stringValue]];
                [crushObj setUserName:[crushDict objectForKey:@"firstName"]];
                [crushObj setUserAge:[[crushDict objectForKey:@"age"] stringValue]];
                [crushObj setImageURL:[crushDict objectForKey:@"profilePicUrl"]];
                [crushObj setCrushMessage:[crushDict objectForKey:@"crushText"]];
                [crushObj setCrushTimestamp:[[crushDict objectForKey:@"time"] stringValue]];
                
                if ([[crushDict allKeys] containsObject:@"gender"]) {
                    [crushObj setUserGender:[crushDict objectForKey:@"gender"]];
                }
                
                
                // Adding Crush TimeStamp
                NSString *crushExpiryTime = [crushDict objectForKey:@"time"];
                long long int serverTimeInMilliSecs = [crushExpiryTime longLongValue];
                NSDate *dateToBeStoredInDb = [NSDate dateWithTimeIntervalSince1970:serverTimeInMilliSecs/1000];
                
                [crushObj setCrushTimestampCurrent:dateToBeStoredInDb];
                
                
                
                //            [crushObj setIsActorBoosted:[NSNumber numberWithBool:[[crushDict objectForKey:@"isActorBoosted"] boolValue]]];
                
                [crushObj setIsActorBoosted:[NSNumber numberWithBool:[[crushDict objectForKey:@"isActorBoosted"] boolValue]]];
                
                isLastVisitorProfileBoosted = isCurrentProfileBoosted;
                
            }
            
        }
    }

}


+(NSInteger)getGroupIdToBeUsed{
    
    NSInteger lastGroupId = 1;
    NSArray *allProfile = [self getAllCrushesFromDB];
    if (allProfile && [allProfile count] > 0) {
        CrushesDashboard *lastProfile = [allProfile lastObject];
        lastGroupId = [lastProfile.groupId integerValue];
    }
    
    
    return lastGroupId;
}


+(BOOL)isLastProfileBoosted:(NSDictionary *)firstObject{
    BOOL isLastProfileBoosted = FALSE;
    NSArray *allProfile = [self getAllCrushesFromDB];
    if (allProfile && [allProfile count] > 0) {
        CrushesDashboard *lastProfile = [allProfile lastObject];
        isLastProfileBoosted = [lastProfile.isActorBoosted boolValue];
    }
    else{
        isLastProfileBoosted = [[firstObject objectForKey:@"isActorBoosted"] boolValue];
    }
    return isLastProfileBoosted;
}


+(CrushesDashboard *)getDataCorCrushWithUserID:(NSString *)userID{
    
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"CrushesDashboard" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(userID==%@)",userID];
    
    [request setPredicate:predicateObj];
    
    NSError *error = nil;
    
    NSArray *selectedCrushArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    CrushesDashboard *crushObject = nil;
    
    if (selectedCrushArray && [selectedCrushArray count]>0) {
        crushObject = (CrushesDashboard *)[selectedCrushArray objectAtIndex:0];
    }
    
    return crushObject;
}


+(NSArray *)getAllCrushesFromDB{
    
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"CrushesDashboard" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSArray *allCrushes = [managedObjectContext executeFetchRequest:request error:&error];
    
    return (NSMutableArray*) ([allCrushes count]>0 ? allCrushes : nil );
}


+(void)deleteCrushDataFromDBWithUserIDs:(NSArray *)idsToBeDeleted withCompletionHandler:(DeletionCompletionHandler __nullable)completionHandler{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    __block NSError *error = nil;
    
    if (privateManagedObjectContext) {
        
        [privateManagedObjectContext performBlock:^{
            
            for (NSString *idToBeDeleted in idsToBeDeleted) {
                
                CrushesDashboard *toBeDeletedCrush = [self getDataCorCrushWithUserID:idToBeDeleted];
                
                if (toBeDeletedCrush) {
                    [privateManagedObjectContext deleteObject:toBeDeletedCrush];
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
                        
                        if(completionHandler){
                            dispatch_async(dispatch_get_main_queue(), ^{
                                completionHandler(TRUE);
                            });
                        }
                        
                    }];
                    
                }
            }
            
            /*****************************************************************************/
            
        }];
        
    }
    
}

+(void)markCrushAsRead:(CrushesDashboard *)crushObj withCompletionHandler:(UpdationCompletionHandler __nullable)updationHandler{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    __block NSError *error = nil;
    
    if (privateManagedObjectContext) {
        
        [privateManagedObjectContext performBlock:^{
            
            
            if (crushObj && ![[crushObj class] isKindOfClass:[NSNull class]]) {
                [crushObj setHasSeen:[NSNumber numberWithBool:YES]];
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
                        
                        if(updationHandler){
                            dispatch_async(dispatch_get_main_queue(), ^{
                                updationHandler(TRUE);
                            });
                        }
                        
                    }];
                    
                }
            }
            
            /*****************************************************************************/
            
        }];
        
    }
}

+(NSMutableArray *)getIDsOfAllTheCrushesInDB{
    
    NSArray *crushArray =[self getAllCrushesFromDB];
    NSMutableArray *arrayOfIDs = [[NSMutableArray alloc] init];
    
    for (CrushesDashboard *crushObj in crushArray) {
        [arrayOfIDs addObject:crushObj.userID];
    }
    return arrayOfIDs;
}

+(NSInteger)getTotalUnreadCrushes{
    
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"CrushesDashboard" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(hasSeen==%@)",[NSNumber numberWithBool:FALSE]];
    
    [request setPredicate:predicateObj];
    
    NSError *error = nil;
    
    NSArray *selectedCrushArray = [managedObjectContext executeFetchRequest:request error:&error];
    return [selectedCrushArray count];
    
}


+(NSArray *)getCrushesForGroupID:(NSString *)groupId{
    
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"CrushesDashboard" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(groupId == %@)",[NSNumber numberWithInt:[groupId intValue]]];
    
    [request setPredicate:predicateObj];

    NSSortDescriptor *serverTimeSorting = [[NSSortDescriptor alloc] initWithKey:@"crushTimestampCurrent" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:serverTimeSorting]];
    
    NSError *error = nil;
    
    NSArray *selectedBoostArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    return ([selectedBoostArray count]>0 ? selectedBoostArray : nil );
    
}

+(NSArray *)getDisctintGroupsForCrushes{
    NSArray *distintGroupsArray = nil;
    
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"CrushesDashboard" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    [request setResultType:NSDictionaryResultType];
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch:[NSArray arrayWithObject:[[entityDescription propertiesByName] objectForKey:@"groupId"]]];
    NSSortDescriptor *groupIdSorting = [[NSSortDescriptor alloc] initWithKey:@"groupId" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:groupIdSorting]];
    
    NSError *error = nil;
    
    distintGroupsArray = [managedObjectContext executeFetchRequest:request error:&error];
    //    NSLog(@"distintGroupsArray :%@",distintGroupsArray);
    NSMutableArray *groupIdArray = [[NSMutableArray alloc] init];
    for (NSDictionary *keyDict in distintGroupsArray) {
        [groupIdArray addObject:[NSString stringWithFormat:@"%d",[[keyDict objectForKey:@"groupId"] intValue]]];
    }
    //    NSLog(@"groupIdArray :%@",groupIdArray);
    return (NSArray *)groupIdArray;
    
}


+(NSMutableDictionary *)getGroupedCrushesDataAccordingToTheGroups{
    
    NSArray *differentGroups = [self getDisctintGroupsForCrushes];
    NSMutableDictionary *groupedVisitorData = [[NSMutableDictionary alloc] init];
    
    for (NSString *groupIdDict in differentGroups) {
        NSArray *visitorForGroup = [self getCrushesForGroupID:groupIdDict];
        if (visitorForGroup && [visitorForGroup count] > 0) {
            [groupedVisitorData setObject:visitorForGroup forKey:groupIdDict];
        }
    }
    return groupedVisitorData;
}


@end
