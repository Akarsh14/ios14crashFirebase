//
//  ChatRoomMigration.m
//  Woo_v2
//
//  Created by Deepak Gupta on 5/2/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "ChatRoomMigration.h"
#import "MyMatches.h"
@implementation ChatRoomMigration

- (BOOL)createDestinationInstancesForSourceInstance:(NSManagedObject *)sInstance
                                      entityMapping:(NSEntityMapping *)mapping
                                            manager:(NSMigrationManager *)manager
                                              error:(NSError **)error
{
    NSArray *arrMatches =  [self getMatchDetailForMatchedUSerID:[sInstance valueForKey:@"chatRoomID"] withMappingManager:manager];
    
    if (arrMatches && [arrMatches count] > 0)
        for (int value = 0 ; value < [arrMatches count]; value++){
  
            MyMatches *matches = [arrMatches objectAtIndex:value];

            if ([sInstance valueForKey:@"chatSnippet"])
                [matches setValue:[sInstance valueForKey:@"chatSnippet"] forKey:@"chatSnippet"];
            
            if ([sInstance valueForKey:@"chatSnippetTime"])
                [matches setValue:[sInstance valueForKey:@"chatSnippetTime"] forKey:@"chatSnippetTime"];
            
            if ([sInstance valueForKey:@"isRead"])
                [matches setValue:[sInstance valueForKey:@"isRead"] forKey:@"isRead"];            
        }

        [STORE saveContext];
        return YES;
}



-(NSArray *)getMatchDetailForMatchedUSerID:(NSString *)matchedUserId withMappingManager: (NSMigrationManager *)manager{
    NSManagedObjectContext *managedObjectContext = [manager destinationContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MyMatches" inManagedObjectContext:[manager destinationContext]];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(matchedUserId==%@)", matchedUserId];
    
    [request setPredicate:predicateObj];
    
    NSError *error = nil;
    
    NSArray *matchedUserArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    return matchedUserArray;

}




@end
