//
//  Store.h
//
//  Created by Lokesh Sehgal
//

#import <Foundation/Foundation.h>
#import "MyMatches.h"
#import "ChatMessage.h"
//#import <LayerKit/LayerKit.h>

@interface Store : NSObject

@property (nonatomic,strong,readonly) NSManagedObjectContext* mainManagedObjectContext;
@property (nonatomic,strong,readonly) NSManagedObjectContext *privateManagedObjectContext;
@property (nonatomic,strong,readonly) NSManagedObjectContext *childManagedObjectContext;


typedef void(^BackgroundThreadCompletionHandler)(BOOL isCompleted);
typedef void(^DeletionCompletionHandler)(BOOL isDeletionCompleted);
typedef void(^InsertionCompletionHandler)(BOOL isInsertionCompleted);
typedef void(^UpdationCompletionHandler)(BOOL isUpdationCompleted);
+ (Store *)sharedInstance;
-(void)saveDataOnParentContextWithHandler:(BackgroundThreadCompletionHandler)completionHandler;
-(void)saveMatchChatonMainBlockDataOnParentContextWithHandler:(BackgroundThreadCompletionHandler)completionHandler;
- (void)saveContext;
- (NSManagedObjectContext*)newPrivateContext;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
-(void)removeAllManageContextObjectAndPersistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext*)childPrivateManagedObjectContext;
-(void)savePrivateContext;

//delete database
/**
 @author Umesh Mishra
 
 This method is called when user taps on logout button from setting.
 
 It will delete the databse file store in cache directory to remove all previous data of logged i n User
 
 */
-(void)deleteDatabase;
/**
 @author Umesh Mishra
 
 This method is called when user taps on logout button from setting.
 
 It will delete managedObject, persistant coordinate and mainContextobject, so that new objects will be created and also a new database file in cache directory.
 
 */
-(void)deleteManagedObject;



/**
 @author Umesh Mishra
 @date Oct 07, 2014
 *  Method to delete matches, chats and notification when user is black listed. 
    This method will be called when user black listed and we will recieve isBlackLsited value true from server.
 */

-(void)deleteUserDataIfUserIsBlackListed;

- (void)deleteAllDataInMeSection:(NSArray *)entityArray;

@end
