//
//  LikedMe+CoreDataProperties.m
//  
//
//  Created by Akhil Singh on 26/03/19.
//
//

#import "LikedMe+CoreDataProperties.h"

@implementation LikedMe (CoreDataProperties)

+ (NSFetchRequest<LikedMe *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"LikedMe"];
}

@dynamic badgeType;
@dynamic crushMsgSendToUser;
@dynamic groupId;
@dynamic isCrushSend;
@dynamic isUserBoosted;
@dynamic isUserLiked;
@dynamic isUserProfileSeenbyAppUser;
@dynamic userAge;
@dynamic userExpiryTime;
@dynamic userFirstName;
@dynamic userGender;
@dynamic userProfilePicURL;
@dynamic userWooId;
@dynamic commonTagDto;

@end
