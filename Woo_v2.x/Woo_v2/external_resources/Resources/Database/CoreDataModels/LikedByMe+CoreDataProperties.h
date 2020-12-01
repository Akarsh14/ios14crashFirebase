//
//  LikedByMe+CoreDataProperties.h
//  
//
//  Created by Harish Kuramsetty on 10/29/19.
//
//

#import "LikedByMe.h"


NS_ASSUME_NONNULL_BEGIN

@interface LikedByMe (CoreDataProperties)

+ (NSFetchRequest<LikedByMe *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *badgeType;
@property (nullable, nonatomic, retain) NSObject *commonTagDto;
@property (nullable, nonatomic, copy) NSString *crushMsgSendToUser;
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

@end

NS_ASSUME_NONNULL_END
