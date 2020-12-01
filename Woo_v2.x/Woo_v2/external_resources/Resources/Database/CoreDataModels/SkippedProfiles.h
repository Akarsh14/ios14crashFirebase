//
//  SkippedProfiles.h
//  Woo_v2
//
//  Created by Umesh Mishraji on 29/08/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface SkippedProfiles : NSManagedObject
+(void)setInsertionCompleted:(int)value;
+(int)getInsertionCompleted;


+(void)updateSkippedData:(NSDictionary *)skippedDict;// ForWooId:(NSString*)wooId;

// Insert code here to declare functionality of your managed object subclass

// Insert code here to declare functionality of your managed object subclass


// Insert code here to declare functionality of your managed object subclass

+(void)setExpiryIndexForInsertionForSkipped:(int)value;
+(int)getExpiryIndexForInsertionForSkipped;
/** 
 *
 *  This method will be used to insert or update Boost/Visitor data in local db recieved from server
 *
 *  @param boostDataArray array of dictionary of boost/Visitor profile recieved from server
 */
+(void)insertOrUpdateSkippedProfileDataFromDiscoverCard:(NSArray *)skippedProfileDataArray withCompletionHandler:(InsertionCompletionHandler __nullable)completionHandler;
+(void)insertOrUpdateSkippedProfileData:(NSArray *)skippedProfileDataArray withCompletionHandler:(InsertionCompletionHandler __nullable)completionHandler;

/**
 *  This method will return all the Boost/Visitr profile stored in local db
 *
 *  @return array of Boost Object
 *
 */
+(NSArray *)getAllSkippedProfiles;


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
+(NSArray *)getSkippedProfileDataForUserId:(NSString *)userWooId;


/**
 *  This method will return Id's of all the visitor's id
 *
 *  @return Array of visitor ids.
 *
 */
+(NSArray *)getIDsOfAllSkippedProfileInDB;


/**
 *  This method will return the count of total number of visitors
 *
 *  @return INTEGER value that will be the total number of visitors
 *
 */
+(NSInteger)getTotalNumberOfSkippedProfiled;

/**
 *  This method will return the count of total number of Un visited visitors
 *
 *  @return INTEGER value that will be the total number of Un visited visitors
 *
 */

+(NSInteger)getTotalNumberOfUnvisitedSkippedProfiles;

/**
 *  This will delete crushes from DB( needs array of IDs)
 *
 *  @param idsToBeDeleted array of IDs to be deleted from local database.
 */
+(void)deleteSkippedProfileDataFromDBWithUserIDs:(NSArray *)idsToBeDeleted withCompletionHandler:(DeletionCompletionHandler)completionHandler;


/**
 *  This method will update is visitor like by current user attribute in local db.
 *
 *  @param visitorId wooId of boost/Visitor whose profile in visited by current app user.
 *
 */
/*+(void)updateIsLikedMeProfileLikedStatusForUserId:(NSString *)userWooId;*/

+(void)deleteAllSkippedProfilesPresentInSystemForMoreThanDays:(int)numberOfDays;

+(NSArray *)getAllExpiringSKippedProfiles;

+(NSArray *)getAllNonExpiringSkippedProfiles;



@end

NS_ASSUME_NONNULL_END

#import "SkippedProfiles+CoreDataProperties.h"
