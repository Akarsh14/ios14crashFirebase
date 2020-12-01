//
//  Store.m
//  Created by Lokesh Sehgal
//

#import "Store.h"
#import <CoreData/CoreData.h>
#import "UConstant.h"
#import "MyMatches.h"
#import "ChatMessage.h"

@interface Store ()
@property (nonatomic,strong,readwrite) NSManagedObjectContext* mainManagedObjectContext;
@property (nonatomic,strong,readwrite) NSManagedObjectContext* privateManagedObjectContext;
@property (nonatomic,strong) NSManagedObjectModel* managedObjectModel;
@property (nonatomic,strong) NSPersistentStoreCoordinator* persistentStoreCoordinator;

@end

@implementation Store
static Store *sharedInstance = nil;

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    
    return self;
}


+ (Store *)sharedInstance {
    @synchronized(self){
        if (!sharedInstance) {
                sharedInstance = [[super allocWithZone:NULL] init];
        }
        return sharedInstance;
    }
    
}

-(void)saveDataOnParentContextWithHandler:(BackgroundThreadCompletionHandler)completionHandler{
    
    __block NSError *error = nil;
    
    NSManagedObjectContext *managedObjectContext = [self mainManagedObjectContext];
    
    if (managedObjectContext) {
        [managedObjectContext performBlock:^{
            if (managedObjectContext != nil) {
                if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    //abort();
                }
                else{
                    completionHandler(TRUE);
                }
            }
            
        }];
    }
}

-(void)saveMatchChatonMainBlockDataOnParentContextWithHandler:(BackgroundThreadCompletionHandler)completionHandler{
    
    __block NSError *error = nil;
    
    NSManagedObjectContext *managedObjectContext = [self mainManagedObjectContext];
    
    if (managedObjectContext) {
        [managedObjectContext performBlockAndWait:^{
            if (managedObjectContext != nil) {
                if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    //abort();
                }
                else{
                    completionHandler(TRUE);
                }
            }
            
        }];
    }
}


- (void)saveContext
{
    __block NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [self mainManagedObjectContext];
    if (managedObjectContext) {
        [managedObjectContext performBlock:^{
            if (managedObjectContext != nil) {
                if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    //abort();
                }
                else{
                }
            }
            
        }];
    }
    
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)mainManagedObjectContext
{
    if (_mainManagedObjectContext != nil) {
        return _mainManagedObjectContext;
    }
    
    _mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    // Added by lokesh
#if !TARGET_IPHONE_SIMULATOR
    [_mainManagedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
#endif
    
//    [_mainManagedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    _mainManagedObjectContext.persistentStoreCoordinator = [self persistentStoreCoordinator];
    return _mainManagedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
		return _managedObjectModel;
	}
	NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"woo" withExtension:@"momd"];
    
	_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
	return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSDictionary *options = nil;
    
    // Added by lokesh
    
#if TARGET_IPHONE_SIMULATOR
    
    options = @{ NSSQLitePragmasOption : @{@"journal_mode" : @"DELETE"},NSMigratePersistentStoresAutomaticallyOption : @YES,
                 NSInferMappingModelAutomaticallyOption : @YES};
    
#else
    
    options = @{NSMigratePersistentStoresAutomaticallyOption : @YES,
                NSInferMappingModelAutomaticallyOption : @YES
                };
    //    options = @{ NSSQLitePragmasOption : @{@"journal_mode" : @"DELETE"},NSMigratePersistentStoresAutomaticallyOption : @YES,
    //                 NSInferMappingModelAutomaticallyOption : @YES};
#endif
    
    NSError *copyError;
    
    NSURL *storeURL;
    
    
    NSString *dbFilePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    dbFilePath = [dbFilePath stringByAppendingString:[NSString stringWithFormat:@"/%@",databaseFileName]];
    
    
    NSString *dbFilePathWAL = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    dbFilePathWAL = [dbFilePathWAL stringByAppendingString:[NSString stringWithFormat:@"/%@",databaseFileNameWAL]];
    
    
    NSString *dbFilePathSHM = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    dbFilePathSHM = [dbFilePathSHM stringByAppendingString:[NSString stringWithFormat:@"/%@",databaseFileNameSHM]];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:dbFilePath];

    if (fileExists) {
        
        [[NSFileManager defaultManager] copyItemAtPath:dbFilePath toPath:[NSString stringWithFormat:@"%@/%@",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0],databaseFileName] error:&copyError];
        
        [[NSFileManager defaultManager] copyItemAtPath:dbFilePathSHM toPath:[NSString stringWithFormat:@"%@/%@",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0],databaseFileNameSHM] error:&copyError];
        
        [[NSFileManager defaultManager] copyItemAtPath:dbFilePathWAL toPath:[NSString stringWithFormat:@"%@/%@",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0],databaseFileNameWAL] error:&copyError];
        
        
        if (!copyError) {
            [self deleteCacheDatabase];
            NSLog(@"COPY SUCCESSFUL");
            storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:databaseFileName];
        }else{
            storeURL = [[self applicationCacheDirectory] URLByAppendingPathComponent:databaseFileName];
            NSLog(@"COPY FAILED");
        }
        
    }
    else{
        NSLog(@"COPY DOESNT EXIST");
        storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:databaseFileName];
    }
    
    NSLog(@"%@", storeURL);
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //abort();
    }
    
    return _persistentStoreCoordinator;
}


- (BOOL ) moveAllDocs {
        
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error = nil;
    
    NSString *sourceDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *destinationDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:sourceDirectory error:&error];
    
    for(NSString *sourceFileName in contents) {
        NSString *sourceFile = [sourceDirectory stringByAppendingPathComponent:sourceFileName];
        NSString *destFile = [destinationDirectory stringByAppendingPathComponent:sourceFileName];
        if(![fileManager moveItemAtPath:sourceFile toPath:destFile error:&error]) {
            
            if (error) {
                return NO;
            }
            NSLog(@"Error: %@", error);
             }
    }
    return YES;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];

}

- (NSURL *)applicationCacheDirectory
{

    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectContext*)newPrivateContext
{
    return [self mainManagedObjectContext];
    /*
        if (_privateManagedObjectContext != nil) {
            return _privateManagedObjectContext;
        }
        _privateManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _privateManagedObjectContext.persistentStoreCoordinator = [self persistentStoreCoordinator];
        return _privateManagedObjectContext;
    */
}

-(void)removeAllManageContextObjectAndPersistentStoreCoordinator{
    if(_privateManagedObjectContext){
        _privateManagedObjectContext=nil;
    }
   
    if(_childManagedObjectContext){
        _childManagedObjectContext=nil;
    }
    
    if(_mainManagedObjectContext){
        _mainManagedObjectContext=nil;
    }
    
    if(_persistentStoreCoordinator){
        _persistentStoreCoordinator=nil;
    }
    [self persistentStoreCoordinator];
    [self mainManagedObjectContext];
    [self newPrivateContext];
    [self childManagedObjectContext];
}

- (NSManagedObjectContext*)childPrivateManagedObjectContext
{
    if(self.childManagedObjectContext!=nil){
        return self.childManagedObjectContext;
    }
    _childManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_childManagedObjectContext setParentContext:[self mainManagedObjectContext]];
    return _childManagedObjectContext;
}

//Method added by Umesh 

-(void)deleteDatabase{
    
    NSError *errorObj;
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:databaseFileName];
    NSURL *storeURLSHM = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:databaseFileNameSHM];
    NSURL *storeURLWAL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:databaseFileNameWAL];
    
    if ([[NSFileManager defaultManager] removeItemAtURL:storeURL error:&errorObj]) {
        if ([[NSFileManager defaultManager] removeItemAtURL:storeURLSHM error:&errorObj]) {
            if ([[NSFileManager defaultManager] removeItemAtURL:storeURLWAL error:&errorObj]) {
                NSLog(@"DELETED SUCESSFULLY");
                return;
            }
        }
    }
    NSLog(@"DELETE FAILURE");
}

- (void)deleteAllDataInMeSection:(NSArray *)entityArray{
    
    for (NSString *entity in entityArray) {
        [self deleteAllDataForEntity:entity];
    }
}

- (void)deleteAllDataForEntity:(NSString*)entityName
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:entityName];
    [fetchRequest setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError *error;
    NSArray *fetchedObjects = [self.mainManagedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *object in fetchedObjects)
    {
        [self.mainManagedObjectContext deleteObject:object];
    }
    
    error = nil;
    [self.mainManagedObjectContext save:&error];
}

-(void)deleteCacheDatabase{
    
    NSError *errorObj;
    
    NSURL *storeURL = [[self applicationCacheDirectory] URLByAppendingPathComponent:databaseFileName];
    NSURL *storeURLSHM = [[self applicationCacheDirectory] URLByAppendingPathComponent:databaseFileNameSHM];
    NSURL *storeURLWAL = [[self applicationCacheDirectory] URLByAppendingPathComponent:databaseFileNameWAL];
    
    if ([[NSFileManager defaultManager] removeItemAtURL:storeURL error:&errorObj]) {
        if ([[NSFileManager defaultManager] removeItemAtURL:storeURLSHM error:&errorObj]) {
            if ([[NSFileManager defaultManager] removeItemAtURL:storeURLWAL error:&errorObj]) {
                NSLog(@"DELETED SUCESSFULLY");
                return;
            }
        }
    }
    NSLog(@"DELETE FAILURE");
    return;
    
}

//qrc118833 - refference id



-(void)deleteManagedObject{
    _privateManagedObjectContext = nil;
    _childManagedObjectContext =nil;
    _mainManagedObjectContext = nil;
    _managedObjectModel = nil;
    _persistentStoreCoordinator = nil;
}

-(void)deleteUserDataIfUserIsBlackListed{
    [MyMatches deleteAllMatchesOfUser];
    [ChatMessage deleteAllChats];
    //[RecommendedUsers deleteAllRecommendation];
//    [DiscoverCards deleteAllDiscoverCards];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCellTapped object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kChatCellTapped object:nil];
    
}


@end
