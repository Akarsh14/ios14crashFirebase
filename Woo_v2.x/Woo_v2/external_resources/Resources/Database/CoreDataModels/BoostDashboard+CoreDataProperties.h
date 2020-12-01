//
//  BoostDashboard+CoreDataProperties.h
//  
//
//  Created by Akhil Singh on 26/03/19.
//
//

#import "BoostDashboard.h"


NS_ASSUME_NONNULL_BEGIN

@interface BoostDashboard (CoreDataProperties)

+ (NSFetchRequest<BoostDashboard *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *badgeType;
@property (nullable, nonatomic, copy) NSString *crushMsgSendToUser;
@property (nullable, nonatomic, copy) NSNumber *groupId;
@property (nullable, nonatomic, copy) NSNumber *isCrushSend;
@property (nullable, nonatomic, copy) NSNumber *isVisitorBoosted;
@property (nullable, nonatomic, copy) NSNumber *isVisitorLiked;
@property (nullable, nonatomic, copy) NSNumber *isVisitorProfileSeenbyUser;
@property (nullable, nonatomic, copy) NSString *visitorAge;
@property (nullable, nonatomic, copy) NSDate *visitorExpiryTime;
@property (nullable, nonatomic, copy) NSString *visitorFirstName;
@property (nullable, nonatomic, copy) NSString *visitorGender;
@property (nullable, nonatomic, copy) NSString *visitorId;
@property (nullable, nonatomic, copy) NSString *visitorProfilePicURL;
@property (nullable, nonatomic, retain) NSObject *commonTagDto;

@end

NS_ASSUME_NONNULL_END
