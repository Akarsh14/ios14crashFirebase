//
//  CrushesDashboard.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 18/01/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface CrushesDashboard : NSManagedObject

/**
 *  This method will be used to update objects in to Db from response received from server
 *
 *  @param crushesDict crush message from server
 */
+(void)updateCrushesData:(NSDictionary *)crushesDict ForWooId:(NSString*)wooId;

/**
 *  This method will be used to add objects in to Db from response received from server
 *
 *  @param crushesArray array of crush messages from server
 */
+(void)insertOrUpdateCrushWithData:(NSArray *)crushesArray withCompletionHandler:(InsertionCompletionHandler __nullable)completionHandler;;


/**
 *  Thie method will be used for fetching a single crush object from Database
 *
 *  @param userID user is for whom crush has to be fetched
 *
 *  @return crush object
 */
+(CrushesDashboard *)getDataCorCrushWithUserID:(NSString *)userID;


/**
 *  This will return all the crushes from DB
 *
 *  @return array of crushes managed objects
 */
+(NSArray *)getAllCrushesFromDB;

/**
 *  This will delete crushes from DB( needs array of IDs)
 *
 *  @param idsToBeDeleted array of IDs to be deleted from local database.
 */
+(void)deleteCrushDataFromDBWithUserIDs:(NSArray *)idsToBeDeleted withCompletionHandler:(DeletionCompletionHandler __nullable)completionHandler;



/**
 *  This will change status of crush message to read
 *
 *  @param crushObj crush object to be marked as read
 */
+(void)markCrushAsRead:(CrushesDashboard *)crushObj withCompletionHandler:(UpdationCompletionHandler __nullable)updationHandler;


/**
 *  This will return an array of all the users in crush DB
 *
 *  @return array of crush user IDs
 */
+(NSMutableArray *)getIDsOfAllTheCrushesInDB;


/**
 *  This method will return number of unread crushes for the user
 *
 *  @return int value having total unread crushes
 */
+(NSInteger)getTotalUnreadCrushes;


+(NSMutableDictionary *)getGroupedCrushesDataAccordingToTheGroups;


+(NSArray *)getDisctintGroupsForCrushes;
@end

NS_ASSUME_NONNULL_END

#import "CrushesDashboard+CoreDataProperties.h"
