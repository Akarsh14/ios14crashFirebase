//
//  MeDashboard+CoreDataClass.h
//
//
//  Created by Harish kuramsetty on 14/10/19.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NSObject;

NS_ASSUME_NONNULL_BEGIN

@interface MeDashboard : NSManagedObject

+(void)setExpiryIndexForInsertion:(int)value;
+(int)getExpiryIndexForInsertion;

// Insert code here to declare functionality of your managed object subclass

+(void)setInsertionCompleted:(int)value;
+(int)getInsertionCompleted;

+(void)migrateThingsFromVisit:(NSArray *)boostDataArray forType:(ProfileType)type  withInsertionCompletionHandler:(InsertionCompletionHandler)insertionCompletion;

/**
 *
 *  This method will be used to update Boost/Visitor data in local db recieved from server
 *
 *  @param boostDataArray array of dictionary of boost/Visitor profile recieved from server
 */
+(void)updateBoostData:(NSDictionary *)visitorDict ForWooId:(NSString*)wooId;

/**
 *
 *  This method will be used to insert or update Boost/Visitor data in local db recieved from server
 *
 *  @param boostDataArray array of dictionary of boost/Visitor profile recieved from server
 */

+(void)updateCommonTags:(NSDictionary *)commonTags ForBoostObject:(MeDashboard *)boostObj withUpdatedCompletionHandler:(UpdationCompletionHandler)updationCompletion;


+(void)insertOrUpdateBoostDashboardData:(NSArray *)boostDataArray forType:(ProfileType)type  withInsertionCompletionHandler:(InsertionCompletionHandler)insertionCompletion;
/**
 *  This method will return all the Boost/Visitr profile stored in local db
 *
 *  @return array of Boost Object
 *
 */
+(NSArray *)getAllBoostProfiles;


/**
 *  This method will return all the Boost/Visitr profile stored in local db sorting by timestamp - recent profiles first
 *
 *  @return array of Boost Object
 *
 */

+(NSArray *)getAllBoostProfilesSortedByTimestamp;
/**
 *  This method will update has visted attribute in local db.
 *
 *  @param isProfileVisited TRUE/FALSE whether Boost/Visitor profile is visited by User or not.
 *
 *  @param visitorId wooId of boost/Visitor whose profile in visited by current app user.
 *
 */
+(void)updateHasVisitorProfileVisitedByUser:(BOOL)isProfileVisited forVisitorId:(NSString *)visitorId withCompletionHandler:(UpdationCompletionHandler)insertionCompletion;


/**
 *  This method will return Boost Object for Visitor/BoostUser id
 *
 *  @param visitorId wooId of boost/Visitor whose profile in visited by current app user.
 *
 *  @return BoostDashboard Object for the given profile
 *
 */
+(NSArray *)getBoostDataForVisitorId:(NSString *)visitorId;


/**
 *  This method will return Id's of all the visitor's id
 *
 *  @return Array of visitor ids.
 *
 */
+(NSArray *)getIDsOfAllTheBoostInDB;


/**
 *  This method will return the count of total number of visitors
 *
 *  @return INTEGER value that will be the total number of visitors
 *
 */
+(NSInteger)getTotalNumberOfVisitors;

/**
 *  This method will return the count of total number of Un visited visitors
 *
 *  @return INTEGER value that will be the total number of Un visited visitors
 *
 */

+(NSInteger)getTotalNumberOfUnvisitedVisitor;

/**
 *  This will delete crushes from DB( needs array of IDs)
 *
 *  @param idsToBeDeleted array of IDs to be deleted from local database.
 */
+(void)deleteBoostDataFromDBWithUserIDs:(NSArray *)idsToBeDeleted withCompletionHandler:(DeletionCompletionHandler __nullable)completionHandler;


/**
 *  This method will update is visitor like by current user attribute in local db.
 *
 *  @param visitorId wooId of boost/Visitor whose profile in visited by current app user.
 *
 
+(void)updateIsVisitorLikedStatusForVisitorId:(NSString *)visitorId;
*/
/**
 *  This method will update crush message, is visitor liked and is crush send  attribute in local db.
 *
 *  @param visitorId wooId of boost/Visitor whose profile in visited by current app user.
 *
 *  @param crushMsg crush message send by the current app user.
 *

+(void)updateCrushMessageForVisitorId:(NSString *)visitorId withCrushMessage:(NSString *)crushMsg;
 */
/**
 *  Get distinct group id from db
 *
 *  @return return array of distinct groups or returns nil;
 */
+(NSArray *)getDisctintGroups;

// Get all data grouped by boost non boost
+(NSMutableDictionary *)getGroupedVisitorDataAccordingToTheGroups;


+(void)deleteAllVisotorsPresentInSystemForMoreThanDays:(int)numberOfDays;

+(NSArray *)getAllExpiringVisitors;

+(NSArray *)getAllNonExpiringVisitors;

+(NSMutableDictionary *)getNonExpiredGroupedVisitorDataAccordingToTheGroups;



@end

NS_ASSUME_NONNULL_END

#import "MeDashboard+CoreDataProperties.h"
