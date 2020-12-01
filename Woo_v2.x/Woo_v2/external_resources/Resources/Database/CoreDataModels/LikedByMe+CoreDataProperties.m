//
//  LikedByMe+CoreDataProperties.m
//  
//
//  Created by Harish Kuramsetty on 10/29/19.
//
//

#import "LikedByMe+CoreDataProperties.h"

@implementation LikedByMe (CoreDataProperties)

+ (NSFetchRequest<LikedByMe *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"LikedByMe"];
}

@dynamic badgeType;
@dynamic commonTagDto;
@dynamic crushMsgSendToUser;
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

@end
