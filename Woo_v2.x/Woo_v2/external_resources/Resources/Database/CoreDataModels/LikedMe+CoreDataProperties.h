//
//  LikedMe+CoreDataProperties.h
//  
//
//  Created by Akhil Singh on 26/03/19.
//
//

#import "LikedMe.h"


NS_ASSUME_NONNULL_BEGIN

@interface LikedMe (CoreDataProperties)

+ (NSFetchRequest<LikedMe *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *badgeType;
@property (nullable, nonatomic, copy) NSString *crushMsgSendToUser;
@property (nullable, nonatomic, copy) NSNumber *groupId;
@property (nullable, nonatomic, copy) NSNumber *isCrushSend;
@property (nullable, nonatomic, copy) NSNumber *isUserBoosted;
@property (nullable, nonatomic, copy) NSNumber *isUserLiked;
@property (nullable, nonatomic, copy) NSNumber *isUserProfileSeenbyAppUser;
@property (nullable, nonatomic, copy) NSString *userAge;
@property (nullable, nonatomic, copy) NSDate *userExpiryTime;
@property (nullable, nonatomic, copy) NSString *userFirstName;
@property (nullable, nonatomic, copy) NSString *userGender;
@property (nullable, nonatomic, copy) NSString *userProfilePicURL;
@property (nullable, nonatomic, copy) NSString *userWooId;
@property (nullable, nonatomic, retain) NSObject *commonTagDto;

@end

NS_ASSUME_NONNULL_END
