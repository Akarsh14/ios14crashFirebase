//
//  CrushesDashboard+CoreDataProperties.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 18/01/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CrushesDashboard.h"

NS_ASSUME_NONNULL_BEGIN

@interface CrushesDashboard (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *hasSeen;
@property (nullable, nonatomic, retain) NSString *crushMessage;
@property (nullable, nonatomic, retain) NSString *userID;
@property (nullable, nonatomic, retain) NSString *imageURL;
@property (nullable, nonatomic, retain) NSString *crushTimestamp;
@property (nullable, nonatomic, retain) NSDate *crushTimestampCurrent;

@property (nullable, nonatomic, retain) NSString *userAge;
@property (nullable, nonatomic, retain) NSString *userName;
@property (nullable, nonatomic, retain) NSNumber *isActorBoosted;
@property (nullable, nonatomic, retain) NSNumber *groupId;

@property (nullable, nonatomic, retain) NSString *userGender;



@end

NS_ASSUME_NONNULL_END
