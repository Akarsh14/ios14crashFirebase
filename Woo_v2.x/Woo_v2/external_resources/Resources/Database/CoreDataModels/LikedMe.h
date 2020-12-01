//
//  LikedMe.h
//  Woo_v2
//
//  Created by Umesh Mishraji on 08/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface LikedMe : NSManagedObject
+(void)setInsertionCompleted:(int)value;
+(int)getInsertionCompleted;

// Insert code here to declare functionality of your managed object subclass

+(void)updateLikedMeData:(NSDictionary *)likedMeDict ForWooId:(NSString*)wooId;

// Insert code here to declare functionality of your managed object subclass

+(void)setExpiryIndexForInsertionForLikedMe:(int)value;
+(int)getExpiryIndexForInsertionForLikedMe;
/**
 *
 *  This method will be used to insert or update Boost/Visitor data in local db recieved from server
 *
 *  @param boostDataArray array of dictionary of boost/Visitor profile recieved from server
 */
+(void)insertOrUpdateLikedMeData:(NSArray *)likedDataArray withCompletionHandler:(InsertionCompletionHandler __nullable)completionHandler;;

/**
 *  This method will return all the Boost/Visitr profile stored in local db
 *
 *  @return array of Boost Object
 *
 */
+(NSArray *)getAllLikedMeProfiles;

/**
 *  This method will return all the Boost/Visitr profile stored in local db sorted by timestamp - 
 *
 *  @return array of Boost Object
 *
 */
+(NSArray *)getAllLikedMeProfilesSortedByTimestamp;

/**
 *  This method will update has visted attribute in local db.
 *
 *  @param isProfileVisited TRUE/FALSE whether Boost/Visitor profile is visited by User or not.
 *
 *  @param visitorId wooId of boost/Visitor whose profile in visited by current app user.
 *
 */

+(void)updateHasUserProfileVisitedByAppUser:(BOOL)isProfileVisited forUserWooId:(NSString *)userWooId withCompletionHandler:(UpdationCompletionHandler __nullable)completionHandler;


/**
 *  This method will return Boost Object for Visitor/BoostUser id
 *
 *  @param visitorId wooId of boost/Visitor whose profile in visited by current app user.
 *
 *  @return BoostDashboard Object for the given profile
 *
 */
+(NSArray *)getLikedMeDataForUserId:(NSString *)userWooId;


/**
 *  This method will return Id's of all the visitor's id
 *
 *  @return Array of visitor ids.
 *
 */
+(NSArray *)getIDsOfAllTheLikedMeProfileInDB;


/**
 *  This method will return the count of total number of visitors
 *
 *  @return INTEGER value that will be the total number of visitors
 *
 */
+(NSInteger)getTotalNumberOfLikedMeProfiled;

/**
 *  This method will return the count of total number of Un visited visitors
 *
 *  @return INTEGER value that will be the total number of Un visited visitors
 *
 */

+(NSInteger)getTotalNumberOfUnvisitedLikedMeProfiles;

/**
 *  This will delete crushes from DB( needs array of IDs)
 *
 *  @param idsToBeDeleted array of IDs to be deleted from local database.
 */
+(void)deleteLikedMeProfileDataFromDBWithUserIDs:(NSArray *)idsToBeDeleted withCompletionHandler:(DeletionCompletionHandler __nullable)completionHandler;


/**
 *  This method will update is visitor like by current user attribute in local db.
 *
 *  @param visitorId wooId of boost/Visitor whose profile in visited by current app user.
 *
 
+(void)updateIsLikedMeProfileLikedStatusForUserId:(NSString *)userWooId;
*/

/**
 *  Get distinct group id from db
 *
 *  @return return array of distinct groups or returns nil;
 */
+(NSArray *)getDisctintGroups;

+(NSMutableDictionary *)getGroupedLikeMeDataAccordingToTheGroups;

+(NSArray *)getLikeMeProfileForGroupID:(NSString *)groupId;

+(void)deleteAllLikedMeProfilesPresentInSystemForMoreThanDays:(int)numberOfDays;

+(NSArray *)getAllExpiringLikedMeProfiles;

+(NSArray *)getAllNonExpiringLikedMeProfiles;

+(NSMutableDictionary *)getNonExpiredGroupedLikeMeDataAccordingToTheGroups;

@end

NS_ASSUME_NONNULL_END

#import "LikedMe+CoreDataProperties.h"
