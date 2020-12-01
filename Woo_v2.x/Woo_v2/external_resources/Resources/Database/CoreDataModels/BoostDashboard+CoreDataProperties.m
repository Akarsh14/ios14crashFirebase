//
//  BoostDashboard+CoreDataProperties.m
//  
//
//  Created by Akhil Singh on 26/03/19.
//
//

#import "BoostDashboard+CoreDataProperties.h"

@implementation BoostDashboard (CoreDataProperties)

+ (NSFetchRequest<BoostDashboard *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"MeDashboard"];
}

@dynamic badgeType;
@dynamic crushMsgSendToUser;
@dynamic groupId;
@dynamic isCrushSend;
@dynamic isVisitorBoosted;
@dynamic isVisitorLiked;
@dynamic isVisitorProfileSeenbyUser;
@dynamic visitorAge;
@dynamic visitorExpiryTime;
@dynamic visitorFirstName;
@dynamic visitorGender;
@dynamic visitorId;
@dynamic visitorProfilePicURL;
@dynamic commonTagDto;

@end
