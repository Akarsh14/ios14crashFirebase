//
//  SkippedProfiles+CoreDataProperties.m
//  
//
//  Created by Akhil Singh on 26/03/19.
//
//

#import "SkippedProfiles+CoreDataProperties.h"

@implementation SkippedProfiles (CoreDataProperties)

+ (NSFetchRequest<SkippedProfiles *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"SkippedProfiles"];
}

@dynamic badgeType;
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
@dynamic commonTagDto;

@end
