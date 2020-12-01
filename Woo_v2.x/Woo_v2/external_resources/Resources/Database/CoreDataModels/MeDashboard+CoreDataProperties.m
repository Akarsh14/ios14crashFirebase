//
//  MeDashboard+CoreDataProperties.m
//
//
//  Created by Harish kuramsetty on 14/10/19.
//
//

#import "MeDashboard+CoreDataProperties.h"

@implementation MeDashboard (CoreDataProperties)

+ (NSFetchRequest<MeDashboard *> *)fetchRequest {
    return [NSFetchRequest fetchRequestWithEntityName:@"MeDashboard"];
}

@dynamic badgeType;
@dynamic commonTagDto;
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
@dynamic type;

@end
