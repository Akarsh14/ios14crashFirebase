//
//  MyMatches.m
//  Woo
//
//  Created by Vaibhav Gautam on 07/04/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "MyMatches.h"
#import "ApplozicChatManager.h"

#define BOOST @"BOOST"
#define CRUSH @"CRUSH"

@implementation MyMatches

@dynamic matchedOn;
@dynamic matchedUserId;
@dynamic matchId;
@dynamic matchIntroText;
@dynamic matchOverlayText;
@dynamic matchUserName;
@dynamic matchUserPic;
@dynamic matchGender;

@dynamic layerChatID;
@dynamic layerConversationObject;
@dynamic isMultiMediaMsgAllowed;
@dynamic matchedAnswer;
@dynamic matchedQuestion;
@dynamic isFav;
@dynamic source;
@dynamic isDel;
@dynamic expiryTime;
@dynamic userLocation;

@dynamic chatSnippet;
@dynamic chatSnippetTime;
@dynamic isRead;
@dynamic matchedUserStatus;
@dynamic isTargetVoiceCallingEnabled;
@dynamic isRequesterFlagged;
@dynamic isTargetFlagged;
@dynamic locked;

+(MyMatches *)getIntroMessageForWooUserID:(NSString *)wooUserID{
    
    NSManagedObjectContext *managedObjectContext = [APP_DELEGATE.store childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MyMatches" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(matchedUserId==%@)", wooUserID];
    
    [request setPredicate:predicateObj];
    
    NSError *error = nil;
    
    NSArray *matchedUserArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    MyMatches *myMatchObject = nil;
    if (matchedUserArray && [matchedUserArray count]>0) {
        myMatchObject = (MyMatches *)[matchedUserArray objectAtIndex:0];
    }
    return myMatchObject;
}

+(void)updateMatchedUserForIsDeletedWithMatchId:(NSString *)matchId
{
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    __block NSError *error = nil;
    
    [privateManagedObjectContext performBlock:^{
        
        MyMatches *matchedUser = [self getMatchDetailForMatchID:matchId];
        
        if (matchedUser) {
            
            matchedUser.isDel = [NSNumber numberWithBool:YES];
            
        }
        
        if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
        else{
            // Saving data on parent context and then informing back
            [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter]postNotificationName:kMatchStatusSetToDeleted object:matchId];
                    [[WooScreenManager sharedInstance].oHomeViewController checkAndShowUnreadBadgeOnMatchIcon];
                });
            }];
        }
        
    }];
    
    
}

+(void)insertDataInMyMatchesFromArray:(NSArray *)matchesArray withChatInsertionSuccess:(MatchedUserInsertionCompletionBlock)matchUserInsertionBlock{
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsUserBlacklisted]) {
        return;
    }
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block int totalCount = 0;
    
    __block NSError *error = nil;
    
    [privateManagedObjectContext performBlock:^{

        if (matchesArray && [matchesArray count]>0) {
            
            totalCount = (int) [matchesArray count];
            
            for (NSMutableDictionary *userData in matchesArray) {
                
                BOOL isNewMatchCreated = FALSE;
                NSString *idForChat = @"";
                
                MyMatches *matchedUser = [self getMatchDetailForMatchID:[userData objectForKey:kMatchIDKey]];
              
                if (![userData objectForKey:@"chatId"] || [[userData objectForKey:@"chatId"] length] <= 0){
                    idForChat = @"ApplozicChatId";
                }
                else{
                    idForChat = [userData objectForKey:@"chatId"];
                }
             //  Removed since the line above does the same thing as this block of code
                if (!matchedUser) {
                    NSString *oneUserId = ([[userData objectForKey:kMatchedUserIDKey] isKindOfClass:[NSString class]]?[userData objectForKey:kMatchedUserIDKey]:[NSString stringWithFormat:@"%@",[userData objectForKey:kMatchedUserIDKey]]);
                    
                    if ([oneUserId isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]]) {
                        oneUserId = ([[userData objectForKey:kRequesterIDKey] isKindOfClass:[NSString class]]?[userData objectForKey:kRequesterIDKey]:[NSString stringWithFormat:@"%@",[userData objectForKey:kRequesterIDKey]]);
                    }
                    matchedUser = [self getMatchDetailForMatchedUSerID:oneUserId isApplozic:false];
                    
                    
                }
                
                NSString *targetId = ([[userData objectForKey:kMatchedUserIDKey] isKindOfClass:[NSString class]]?[userData objectForKey:kMatchedUserIDKey]:[NSString stringWithFormat:@"%@",[userData objectForKey:kMatchedUserIDKey]]);
                
                NSString *targetAppLozicId =  [[userData objectForKey:ktargetAppLozicId] isEqualToString:[[LoginModel sharedInstance]appLozicUserId]] ? [userData objectForKey:krequestAppLozicId] : [userData objectForKey:ktargetAppLozicId];
                
                [[ApplozicChatManager sharedApplozicChatManager] unBlockUser:targetAppLozicId];
                
                
                NSString *chatServerID = [userData objectForKey:ksecretChatKey];
                
                //NSString *chatServerID = kisAppLozicServer;

                
                // Adding deleted Key data in the database
                if ([userData objectForKey:@"isDeleted"] && [[userData objectForKey:@"isDeleted"] boolValue] == TRUE) {
                  // [self deleteMatchForMatchedUserId:matchedUser.matchedUserId withDeletionCompletionHandler:nil];
                     [[ApplozicChatManager sharedApplozicChatManager] blockUser:targetAppLozicId];
                    if ([targetId isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]] &&  ([userData objectForKey:KisRequesterFlagged] && [[userData objectForKey:KisRequesterFlagged] boolValue] == TRUE))
                    {
                        //means i m the target in MatchDTO
                        //Therefore check requesterFlagged to see if the matched user is flagged
                        if(matchedUser)
                        {
                            [self deleteMatchForMatchID:matchedUser.matchId];
                        }
                        --totalCount;
                        if(totalCount==0){
                            [self performSaveOperationAfterInsertionOfMyMatches:privateManagedObjectContext withChatInsertionSuccess:matchUserInsertionBlock withError:error];
                        }

                        continue;
                        
                    }
                    else if (![targetId isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]] &&  ([userData objectForKey:KisTargetFlagged] && [[userData objectForKey:KisTargetFlagged] boolValue] == TRUE))
                    {
                        //means i m the requester in MatchDTO
                        //Therefore check targetFlagged to see if the matched user is flagged
                        if(matchedUser)
                        {
                            [self deleteMatchForMatchID:matchedUser.matchId];
                        }
                        --totalCount;
                        if(totalCount==0){
                            [self performSaveOperationAfterInsertionOfMyMatches:privateManagedObjectContext withChatInsertionSuccess:matchUserInsertionBlock withError:error];
                        }
                            continue;
                    }
                    else
                    {
                    
                        NSLog(@"updated  isDEleted key value");
                        [self updateMatchedUserForIsDeletedWithMatchId:matchedUser.matchId];
                        --totalCount;
                        if(totalCount==0){
                            [self performSaveOperationAfterInsertionOfMyMatches:privateManagedObjectContext withChatInsertionSuccess:matchUserInsertionBlock withError:error];
                        }
                        continue;
                    }
                }else{
                     [[ApplozicChatManager sharedApplozicChatManager] unBlockUser:targetAppLozicId];
                }
                
                if ([chatServerID isEqualToString:kisAppLozicServer]){
                    idForChat = @"ApplozicChatId";
                }
                
                if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsUserBlacklisted] || ([[APP_Utilities validString:idForChat] length] < 1)) {
                    --totalCount;
                    if(totalCount==0){
                        [self performSaveOperationAfterInsertionOfMyMatches:privateManagedObjectContext withChatInsertionSuccess:matchUserInsertionBlock withError:error];
                    }
                    continue;
                }
                
                
                if (!matchedUser) {
                    matchedUser = (MyMatches *)[NSEntityDescription insertNewObjectForEntityForName:@"MyMatches" inManagedObjectContext:privateManagedObjectContext];
                    isNewMatchCreated = TRUE;
                }
                
                
                [matchedUser setMatchId:[userData objectForKey:kMatchIDKey]];
                
                if ([[APP_Utilities validString:[userData objectForKey:kMatchUserIntroKey]] length]>0) {
                    [matchedUser setMatchIntroText:[APP_Utilities validString:[userData objectForKey:kMatchUserIntroKey]]];
                }
                
                if ([[APP_Utilities validString:[userData objectForKey:kMatchUserOverlayText]] length]>0) {
                    [matchedUser setMatchOverlayText:[APP_Utilities validString:[userData objectForKey:kMatchUserOverlayText]]];
                }
                
                if ([userData objectForKey:kUserFavKey] && [[userData objectForKey:kUserFavKey] boolValue] == TRUE) {
                    [matchedUser setIsFav:[NSNumber numberWithBool:YES]];
                }else{
                    [matchedUser setIsFav:[NSNumber numberWithBool:NO]];
                }
                
                
                if ([[APP_Utilities validString:[userData objectForKey:@"agora_channel_key"]] length]>0) {
                    [matchedUser setAgoraChannelKey:[APP_Utilities validString:[userData objectForKey:@"agora_channel_key"]]];
                }
                else
                {
                    [matchedUser setAgoraChannelKey:@""];
                }
                
                

                if ([[APP_Utilities validString:[userData objectForKey:@"qaTextAnswer"]] length]>0) {
                    [matchedUser setMatchedAnswer:[APP_Utilities validString:[userData objectForKey:@"qaTextAnswer"]]];
                }
                
                if ([[APP_Utilities validString:[userData objectForKey:@"qaTextQuestion"]] length]>0) {
                    [matchedUser setMatchedQuestion:[APP_Utilities validString:[userData objectForKey:@"qaTextQuestion"]]];
                }
                
                [matchedUser setValue:targetAppLozicId forKey:ktargetAppLozicId];
                 [matchedUser setValue:chatServerID forKey:kchatServer];
                
                if (matchedUser.layerChatID && [matchedUser.layerChatID containsString:@"dummyChatId"]) {
                    isNewMatchCreated = TRUE;
                }
                
                [matchedUser setLayerChatID:idForChat];
                
                if (idForChat && ([[APP_Utilities validString:idForChat] length] > 0) && (![idForChat containsString:@"dummyChatId"])) {
                    [matchedUser setMatchedUserStatus:[NSNumber numberWithInt:MATCHED_USER_STATUS_CONNECTED_TO_LAYER]];
                }
                
                [matchedUser setMatchedOn:[APP_Utilities returnDateFromTimeStamp:[[userData objectForKey:kMatchTime] longLongValue]]];
                
                if ([userData objectForKey:kTargetUserLocation]) {
                    [matchedUser setUserLocation:[userData objectForKey:kTargetUserLocation]];
                }
                
                
                // Adding Match Expiry Time
                if ([userData objectForKey:kMatchExpiryTime])
                    [matchedUser setExpiryTime:[APP_Utilities returnDateFromTimeStamp:[[userData objectForKey:kMatchExpiryTime] longLongValue]]];
                [matchedUser setIsMultiMediaMsgAllowed:[NSNumber numberWithBool:TRUE]];
//                if ([[userData objectForKey:@"chatId"] length]>0) {
//                   [matchedUser setIsMultiMediaMsgAllowed:[NSNumber numberWithBool:TRUE]];
//                }
//                else{
//                    [matchedUser setIsMultiMediaMsgAllowed:[NSNumber numberWithBool:FALSE]];
//                }
                
                if ([[APP_Utilities validString:[userData objectForKey:@"source"]] length]>0)
                {
                    [matchedUser setSource:[APP_Utilities validString:[userData objectForKey:@"source"]]];
                }
                if ([targetId isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]])
                {
                    targetId = ([[userData objectForKey:kRequesterIDKey] isKindOfClass:[NSString class]]?[userData objectForKey:kRequesterIDKey]:[NSString stringWithFormat:@"%@",[userData objectForKey:kRequesterIDKey]]);
                    [matchedUser setMatchedUserId:targetId];
                    [matchedUser setMatchUserName:[userData objectForKey:kRequesterNameKey]];
                    [matchedUser setMatchUserPic:[userData objectForKey:kRequesterUserPicURLKey]];
                    [matchedUser setMatchGender:[userData objectForKey:kRequesterGenderKey]];
                    
                    //means i am target user therefore use requester keys
                    //isRequesterVoiceCallingEnabled
                    if ([userData objectForKey:KisRequesterVoiceCallingEnabled] && [[userData objectForKey:KisRequesterVoiceCallingEnabled] boolValue] == TRUE)
                    {
                        [matchedUser setIsTargetVoiceCallingEnabled:[NSNumber numberWithBool:YES]];
                    }
                    else
                    {
                        [matchedUser setIsTargetVoiceCallingEnabled:[NSNumber numberWithBool:NO]];
                    }
                    if ([[APP_Utilities validString:[userData objectForKey:KRequesterDeviceType]] length]>0) {
                        [matchedUser setTargetDeviceType:[APP_Utilities validString:[userData objectForKey:KRequesterDeviceType]]];
                    }
                    else
                    {
                        [matchedUser setTargetDeviceType:@""];
                    }
                   
                    //Celebrity check
                    if([userData objectForKey:KisRequesterACelebrity] && [[userData objectForKey:KisRequesterACelebrity] boolValue] == TRUE)
                    {
                        [matchedUser setIsTargetACelebrity:[NSNumber numberWithBool:YES]];
                    }
                    else
                    {
                        [matchedUser setIsTargetACelebrity:[NSNumber numberWithBool:NO]];
                    }
                    //Parse target source
                    if([[APP_Utilities validString:[userData objectForKey:KTargetSource]] length]>0)
                    {
                        [matchedUser setSource:[APP_Utilities validString:[userData objectForKey:KTargetSource]]];
                        
                    }
                    
                    // Parse PFG when i am target
                    if([userData objectForKey:KisRequesterFlagged] && [[userData objectForKey:KisRequesterFlagged] boolValue] == TRUE)
                    {
                        [matchedUser setIsTargetFlagged:[NSNumber numberWithBool:YES]];
                    }
                    else
                    {
                        [matchedUser setIsTargetFlagged:[NSNumber numberWithBool:NO]];
                    }
                    
                    if([userData objectForKey:KisTargetFlagged] && [[userData objectForKey:KisTargetFlagged] boolValue] == TRUE)
                    {
                        [matchedUser setIsRequesterFlagged:[NSNumber numberWithBool:YES]];
                    }
                    else
                    {
                        [matchedUser setIsRequesterFlagged:[NSNumber numberWithBool:NO]];
                    }

                    
                }
                else{
                    targetId = ([[userData objectForKey:kMatchedUserIDKey] isKindOfClass:[NSString class]]?[userData objectForKey:kMatchedUserIDKey]:[NSString stringWithFormat:@"%@",[userData objectForKey:kMatchedUserIDKey]]);
                    [matchedUser setMatchedUserId:targetId];
                    [matchedUser setMatchUserName:[userData objectForKey:kMatchNameKey]];
                    if ([userData objectForKey:kMatchUserPicURLKey] != [NSNull null]) {
                        [matchedUser setMatchUserPic:[userData objectForKey:kMatchUserPicURLKey]];
                    }else{
                        [matchedUser setMatchUserPic:@""];
                    }
                    [matchedUser setMatchGender:[userData objectForKey:kMatchGenderKey]];
                    
                    //means i am the requester therefore use requester keys
                    //isTargetVoiceCallingEnabled
                    if ([userData objectForKey:KisTargetVoiceCallingEnabled] && [[userData objectForKey:KisTargetVoiceCallingEnabled] boolValue] == TRUE)
                    {
                        [matchedUser setIsTargetVoiceCallingEnabled:[NSNumber numberWithBool:YES]];
                    }
                    else
                    {
                        [matchedUser setIsTargetVoiceCallingEnabled:[NSNumber numberWithBool:NO]];
                    }
                    if ([[APP_Utilities validString:[userData objectForKey:KTargetDeviceType]] length]>0) {
                        [matchedUser setTargetDeviceType:[APP_Utilities validString:[userData objectForKey:KTargetDeviceType]]];
                    }
                    else
                    {
                        [matchedUser setTargetDeviceType:@""];
                    }
                    //Celebrity check
                    if([userData objectForKey:KisTargetACelebrity] && [[userData objectForKey:KisTargetACelebrity] boolValue] == TRUE)
                    {
                        [matchedUser setIsTargetACelebrity:[NSNumber numberWithBool:YES]];
                    }
                    else
                    {
                        [matchedUser setIsTargetACelebrity:[NSNumber numberWithBool:NO]];
                    }

                    if([[APP_Utilities validString:[userData objectForKey:KRequesterSource]] length]>0)
                    {
                        [matchedUser setSource:[APP_Utilities validString:[userData objectForKey:KRequesterSource]]];
                        
                    }
                    // Parse PFG when i am requester
                    if([userData objectForKey:KisRequesterFlagged] && [[userData objectForKey:KisRequesterFlagged] boolValue] == TRUE)
                    {
                        [matchedUser setIsRequesterFlagged:[NSNumber numberWithBool:YES]];
                    }
                    else
                    {
                        [matchedUser setIsRequesterFlagged:[NSNumber numberWithBool:NO]];
                    }
                    
                    if([userData objectForKey:KisTargetFlagged] && [[userData objectForKey:KisTargetFlagged] boolValue] == TRUE)
                    {
                        [matchedUser setIsTargetFlagged:[NSNumber numberWithBool:YES]];
                    }
                    else
                    {
                        [matchedUser setIsTargetFlagged:[NSNumber numberWithBool:NO]];
                    }
                }

                
                if ([[NSUserDefaults standardUserDefaults] objectForKey:kHasFetchedMatchesAlready]) {
                    if (!matchedUser.isRead) {
                        [matchedUser setIsRead:[NSNumber numberWithInt:0]];
                    }else{
                        [matchedUser setIsRead:matchedUser.isRead];
                    }
                    
                }else{
                    [matchedUser setIsRead:[NSNumber numberWithInt:0]];
                }
                
                

//                [self acknowledgeServerAfterAMatchIsInserted:matchedUser];
                __block NSString *chatSnippet = @"";
                NSDate *chatSnippetTime = nil;
                if (matchedUser.chatSnippet && [matchedUser.chatSnippet length] > 0){
                    chatSnippet = matchedUser.chatSnippet;
                    chatSnippetTime = matchedUser.chatSnippetTime;
                }
                
                if (isNewMatchCreated) {
                    // chatSnippet will be returned nil and check outside of this if is to drop all those match insertions in which chatSnippet is nil
                    [self createChatRoomForMyMatch:matchedUser andWithresponseDict:userData withInsertionCompletionBlock:^(NSString *chatSnippets) {
                        chatSnippet = chatSnippets;
                        [MyMatches updateMatchDetails:matchedUser withChatSnippet:chatSnippet withChatSnippetTime:matchedUser.matchedOn withChatUpdationSuccess:^(BOOL isUpdationCompleted) {
                            if(!chatSnippet){
                                [MyMatches updateMatchDetails:matchedUser withChatSnippet:chatSnippet withChatSnippetTime:chatSnippetTime withChatUpdationSuccess:^(BOOL isUpdationCompleted) {
                                    --totalCount;
                                    if(totalCount==0){
                                        [self performSaveOperationAfterInsertionOfMyMatches:privateManagedObjectContext withChatInsertionSuccess:matchUserInsertionBlock withError:error];
                                        
                                    }
                                }];
                            }else{
                                if(matchedUser.isTargetFlagged.boolValue == true)
                                {
                                    [matchedUser setChatSnippetTime:[NSDate dateWithTimeIntervalSince1970:0]];
                                }
                                else
                                {
                                    [matchedUser setChatSnippetTime:[NSDate dateWithTimeIntervalSince1970:[[userData objectForKey:@"matchedTime"] longLongValue]/1000]];
                                }
                                --totalCount;
                                if(totalCount==0){
                                    [self performSaveOperationAfterInsertionOfMyMatches:privateManagedObjectContext withChatInsertionSuccess:matchUserInsertionBlock withError:error];
                                }
                            }
                        }];
                    }];
                }else{
                    if(!chatSnippet){
                        [MyMatches updateMatchDetails:matchedUser withChatSnippet:chatSnippet withChatSnippetTime:chatSnippetTime withChatUpdationSuccess:^(BOOL isUpdationCompleted) {
                            --totalCount;
                            if(totalCount==0){
                                [self performSaveOperationAfterInsertionOfMyMatches:privateManagedObjectContext withChatInsertionSuccess:matchUserInsertionBlock withError:error];
                            }
                        }];
                    }else{
                        --totalCount;
                        if(matchedUser.isTargetFlagged.boolValue == true)
                        {
                            [matchedUser setChatSnippetTime:[NSDate dateWithTimeIntervalSince1970:0]];
                        }
                        else
                        {
                            [matchedUser setChatSnippetTime:[NSDate dateWithTimeIntervalSince1970:[[userData objectForKey:@"matchedTime"] longLongValue]/1000]];
                        }
                        if(totalCount==0){
                            [self performSaveOperationAfterInsertionOfMyMatches:privateManagedObjectContext withChatInsertionSuccess:matchUserInsertionBlock withError:error];
                        }
                    }
                }
            }
            
        }else{
            if(matchUserInsertionBlock)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    matchUserInsertionBlock(TRUE);

                });
            }
        }
        
    }];
    
}

+(void)performSaveOperationAfterInsertionOfMyMatches:(NSManagedObjectContext*)privateManagedObjectContext withChatInsertionSuccess:(MatchedUserInsertionCompletionBlock)matchUserInsertionBlock withError:(NSError *)error {
    
    if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //abort();
    }
    else{
        // Saving data on parent context and then informing back
        [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
            
                [[WooScreenManager sharedInstance].oHomeViewController checkAndShowUnreadBadgeOnMatchIcon];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kMatchDataSavedInLocalDatabase object:nil];
                
                if(matchUserInsertionBlock)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        matchUserInsertionBlock(YES);
                    });
                }
        }];
    }
}
+(void)updateMatchDetails:(MyMatches *)matchedUser withChatSnippet:(NSString*)chatSnippet withChatSnippetTime:(NSDate*)chatSnippetTime withChatUpdationSuccess:(MatchedUserUpdationCompletionHandler)matchUserInsertionBlock{

    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    
    [privateManagedObjectContext performBlock:^{
        
        
        [matchedUser setChatSnippet:chatSnippet];
        if(matchedUser.isTargetFlagged.boolValue == false)
        {
            matchedUser.chatSnippetTime = chatSnippetTime;
        }
        else
        {
            [matchedUser setChatSnippetTime:[NSDate dateWithTimeIntervalSince1970:0]];
        }
        
        
        if (!matchedUser.chatSnippet || [matchedUser.chatSnippet length] < 1) {
            [matchedUser setChatSnippetUserId:@""];
        }
//            NSDateFormatter *dateFormatFromServer = [[NSDateFormatter alloc]init];
//            [dateFormatFromServer setDateFormat:@"dd/MM/yyyy"];
//
//            NSDate *localDate = matchedUser.matchedOn;
//
//            NSString *dateString = [NSString stringWithFormat:NSLocalizedString(@"Matched on: %@",nil),[dateFormatFromServer stringFromDate:localDate]];
//            matchedUser.chatSnippet = dateString;
//            //chatSnippetTime = matchedUser.matchedOn;
//        }
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kHasFetchedMatchesAlready]) {
            if (!matchedUser.isRead) {
                [matchedUser setIsRead:[NSNumber numberWithInt:0]];
            }else{
                [matchedUser setIsRead:matchedUser.isRead];
            }
            
        }else{
            [matchedUser setIsRead:[NSNumber numberWithInt:0]];
        }
        
        if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
        else{
            // Saving data on parent context and then informing back
            [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                
                // Do Nothing
                
                if(matchUserInsertionBlock)
                    matchUserInsertionBlock(TRUE);
                
            }];
        }
        
    }];
    
}


+(MyMatches *)getMatchDetailForMatchID:(NSString *)matchID{
    
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MyMatches" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(matchId==%@)", matchID];
    
    [request setPredicate:predicateObj];
    
    NSError *error = nil;
    
    NSArray *matchedUserArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    MyMatches *myMatchObject = nil;
    if (matchedUserArray && [matchedUserArray count]>0) {
        myMatchObject = (MyMatches *)[matchedUserArray objectAtIndex:0];
        return myMatchObject;
    }else{
        return nil;
    }
    
}

+(void)deleteMatchForMatchID:(NSString *)matchID{
    NSLog(@"deleteMatchForMatchID %@",matchID);
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
   
    [privateManagedObjectContext performBlock:^{
        
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MyMatches" inManagedObjectContext:privateManagedObjectContext];

        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        [request setEntity:entityDescription];
        
        NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(matchId==%@)",[NSString stringWithFormat:@"%@",matchID]];
        
        [request setPredicate:predicateObj];
        
        NSArray *matchedUserArray = [privateManagedObjectContext executeFetchRequest:request error:&error];
        
        for (MyMatches *matchObj in matchedUserArray) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kChatRoomDeleted object:matchObj.matchId];
            [privateManagedObjectContext deleteObject:matchObj];
            
        }
        if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
        else{
            // Saving data on parent context and then informing back
            [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"deletedMatchForMatchID");
                    [[NSNotificationCenter defaultCenter] postNotificationName:kMatchDeletedByNotification object:nil];
                    [[WooScreenManager sharedInstance].oHomeViewController checkAndShowUnreadBadgeOnMatchIcon];
                });
            }];
        }
        
    }];
    
}

+(NSMutableArray *)getAllMatches{
    
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MyMatches" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    // code for sorting starts here
    NSSortDescriptor *dateSortingDescriptior = [[NSSortDescriptor alloc]initWithKey:@"chatSnippetTime" ascending:NO];
    
    NSArray *sortDescriptorArray = [NSArray arrayWithObjects:dateSortingDescriptior, nil];
    [request setSortDescriptors:sortDescriptorArray];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(layerChatID != nil)"];
    
    [request setPredicate:predicateObj];

    // code for sorting ends here
    
    NSArray *notificationsArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    return (NSMutableArray*) ([notificationsArray count]>0 ? notificationsArray : nil );
}

+(void)deleteAllMatchesOfUser{
   
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    
    [privateManagedObjectContext performBlock:^{
        
        NSArray *allMatchesArray = [self getAllMatches];
        
        if (allMatchesArray && [allMatchesArray count]>0) {
            for (MyMatches *matchObj in allMatchesArray) {
                [privateManagedObjectContext deleteObject:matchObj];
            }
        }
        
        if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
        else{
            // Saving data on parent context and then informing back
            [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                
            }];
        }
        
    }];
    
}


+(void)deleteMatchForMatchedUserId:(NSString *)matchedUserId withDeletionCompletionHandler:(MatchedUserDeletionCompletionHandler)updationCompletionHandler{

    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    
    [privateManagedObjectContext performBlock:^{
        
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MyMatches" inManagedObjectContext:privateManagedObjectContext];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        [request setEntity:entityDescription];
        
        NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(matchedUserId==%@)",[NSString stringWithFormat:@"%@",matchedUserId]];
        
        [request setPredicate:predicateObj];
        
        NSArray *matchedUserArray = [privateManagedObjectContext executeFetchRequest:request error:&error];
        
        for (MyMatches *matchObj in matchedUserArray) {
            
            [[ApplozicChatManager sharedApplozicChatManager] blockUser:matchObj.targetAppLozicId];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kChatRoomDeleted object:matchObj.matchId];
            });
            [privateManagedObjectContext deleteObject:matchObj];
        }
        
        if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
        else{
            // Saving data on parent context and then informing back
            [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {

                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if(updationCompletionHandler){
                        updationCompletionHandler(TRUE);
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kMatchDeletedByNotification object:nil];
                    
                    [[WooScreenManager sharedInstance].oHomeViewController checkAndShowUnreadBadgeOnMatchIcon];
                });
            }];
        }
        
    }];

    
}

+(MyMatches *)getMatchDetailForMatchedUSerID:(NSString *)matchedUserId isApplozic:(BOOL)isApplozic{
    
    NSLog(@"matchedUserId %@",matchedUserId);
    
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MyMatches" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    
    NSPredicate *predicateObj = nil;
    
    if (isApplozic){
        predicateObj = [NSPredicate predicateWithFormat:@"(targetAppLozicId==%@)", matchedUserId];
    }
    else{
        predicateObj = [NSPredicate predicateWithFormat:@"(matchedUserId==%@)", matchedUserId];
    }
    
    [request setPredicate:predicateObj];
    
    NSError *error = nil;
    
    NSArray *matchedUserArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    MyMatches *myMatchObject = nil;
    
    NSLog(@"matchedUserArray %@",matchedUserArray);
    if (matchedUserArray && [matchedUserArray count]>0) {
        myMatchObject = (MyMatches *)[matchedUserArray objectAtIndex:0];
        return myMatchObject;
    }else{
        return nil;
    }
    
}



+(void)updateMatchedUserDetailsForMatchedUserID:(NSString *)userID withName:(NSString *)userName andProfilePic:(NSString *)profileURL withMatchUpdationSuccess:(MatchedUserUpdationCompletionHandler)matchUserInsertionBlock{

    if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsUserBlacklisted]) {
            return;
       
    }
    
    if (userID && [userID length]<1) {
            return;
    }

        NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
        
        __block NSError *error = nil;
        
        [privateManagedObjectContext performBlock:^{
            
            MyMatches *matchedUser = [self getMatchDetailForMatchedUSerID:userID isApplozic:false];
            
            if (!matchedUser) {
                return;
            }
            
            if (userName && [userName length]>1 && ![userName isEqualToString:@"(null)"]) {
                [matchedUser setMatchUserName:userName];
            }
            if (profileURL && [profileURL length]>1 && ![profileURL isEqualToString:@"(null)"]) {
                [matchedUser setMatchUserPic:profileURL];
            }
            
            if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                //abort();
            }
            else{
                // Saving data on parent context and then informing back
                [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                    if(matchUserInsertionBlock)
                        matchUserInsertionBlock(YES);

                    
                }];
            }
            
        }];
        
}


+(void)updateMatchedUserDetailsWithConversationIdentifier:(NSString *)userID withConversationIdentifier:(NSString*)conversationIdentifier andMultiMediaAllowedState:(BOOL)isMultiMediaAllowed{
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsUserBlacklisted]) {
        return;
    }
    if (userID && [userID length]<1) {
        return;
    }
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    
    [privateManagedObjectContext performBlock:^{
    
        MyMatches *matchedUser = [self getMatchDetailForMatchedUSerID:userID isApplozic:false];
        
        if (!matchedUser) {
            return;
        }
        
        [matchedUser setLayerChatID:conversationIdentifier];
//        [matchedUser setIsMultiMediaMsgAllowed:[NSNumber numberWithBool:isMultiMediaAllowed]];
//        if (isMultiMediaAllowed && [conversationIdentifier length]>0) {
//            [matchedUser setIsMultiMediaMsgAllowed:[NSNumber numberWithBool:isMultiMediaAllowed]];
//        }
//        else{
//            [matchedUser setIsMultiMediaMsgAllowed:[NSNumber numberWithBool:FALSE]];
//        }
        
        if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
        else{
            // Saving data on parent context and then informing back
            [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                
                // Do Nothing
                
            }];
        }
        
    }];
}


//+(LYRConversation*)getConversationObjectForAMatchedUser:(NSString *)userID{
//    
//    BOOL conversationObjectFound = TRUE;
//
//    LYRConversation *conversationObj = nil;
//    
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsUserBlacklisted]) {
//        conversationObjectFound = FALSE;
//    }
//    if (userID && [userID length]<1) {
//        conversationObjectFound = FALSE;
//    }
//    
//    if(conversationObjectFound){
//        MyMatches *matchedUser = [self getMatchDetailForMatchedUSerID:userID isApplozic:false];
//        conversationObj = [NSKeyedUnarchiver unarchiveObjectWithData:matchedUser.layerConversationObject];
//    }
//    
//    return conversationObj;
//}

+(void)acknowledgeServerAfterAMatchIsInserted:(MyMatches *)matchObj{

    if ([matchObj.matchedQuestion length]>0 || [matchObj.matchedAnswer length]>0) {
        NSString *acknowledgeURL = [NSString stringWithFormat:@"%@%@?matchId=%@&wooId=%@",kBaseURLV1,kAcknowledgement,matchObj.matchId,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
        WooRequest *wooRequestObj = [[WooRequest alloc]init];
        wooRequestObj.url =acknowledgeURL;
        wooRequestObj.time =900;
        wooRequestObj.requestParams =nil;
        wooRequestObj.methodType =postRequest;
        wooRequestObj.numberOfRetries = 1;
        wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
        wooRequestObj.requestType = fetchAllMatches;
        //making a request to server to get all matches after the savedTimeStamp
        [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        } shouldReachServerThroughQueue:YES];
    }
    
}

+(MyMatches *)getMatchObjectForLayerConversationId:(NSString *)layerId{

    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MyMatches" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(layerChatID==%@)", layerId];
    
    [request setPredicate:predicateObj];
    
    NSError *error = nil;
    
    NSArray *matchedUserArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    MyMatches *myMatchObject = nil;
    if (matchedUserArray && [matchedUserArray count]>0) {
        myMatchObject = (MyMatches *)[matchedUserArray objectAtIndex:0];
        return myMatchObject;
    }else{
        return nil;
    }
}

+(MyMatches *)getMatchObjectForApplozicId:(NSString *)applozicId{
    
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MyMatches" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(targetAppLozicId==%@)", applozicId];
    
    [request setPredicate:predicateObj];
    
    NSError *error = nil;
    
    NSArray *matchedUserArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    MyMatches *myMatchObject = nil;
    if (matchedUserArray && [matchedUserArray count]>0) {
        myMatchObject = (MyMatches *)[matchedUserArray objectAtIndex:0];
        return myMatchObject;
    }else{
        return nil;
    }
}


/**
 *  Methods after removing the ChatRoom
 */

+(NSArray *)getAllUnreadMessage{
    
    NSManagedObjectContext *managedObjectContext = [APP_DELEGATE.store childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MyMatches" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(isRead == %@) AND (isDel == %@) AND (isTargetFlagged == %@)", [NSNumber numberWithBool:FALSE],nil,[NSNumber numberWithBool:FALSE]];
    
    [request setPredicate:predicateObj];
    
    NSError *error = nil;
    
    NSArray *chatRoomArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (chatRoomArray && [chatRoomArray count]>0) {
        return chatRoomArray;
    }
    return nil;
}

+(void)resetChatSnippetOfChatRoom:(NSString *)chatRoomID withBackgroundCompletion:(MatchedUserInsertionCompletionBlock)completionBlock{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    
    [privateManagedObjectContext performBlock:^{
        
        MyMatches *matchObj = [MyMatches getMatchDetailForMatchID:chatRoomID];
        
        if (matchObj) {
//            NSDate *localDate = matchObj.matchedOn;
//
//            NSDateFormatter *dateFormatFromServer = [[NSDateFormatter alloc]init];
//            [dateFormatFromServer setDateFormat:@"dd/MM/yyyy"];
            
//            NSString *dateString = [NSString stringWithFormat:NSLocalizedString(@"Matched on: %@",nil),[dateFormatFromServer stringFromDate:localDate]];
            [matchObj setChatSnippet:@""];
            [matchObj setChatSnippetTime:matchObj.matchedOn];
            [matchObj setChatSnippetUserId:@""];
        }
        
        if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
        else{
            // Saving data on parent context and then informing back
            [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                
                completionBlock(TRUE);
                
            }];
        }
        
    }];
    
}


+(void)updateChatSnippetForChatRoom:(NSString *)chatRoomID
                    withChatSnippet:(NSString *)chatSnippet
                     forMatchDetail:(MyMatches *)matchUserObj
                          timeStamp:(NSDate *)chatTime
                          andIsRead:(BOOL)isRead
                          andSource:(NSString*)source withBackgroundCompletion:(MatchUpdationCompletionHandler)completionBlock{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
  
    [privateManagedObjectContext performBlock:^{
        
        NSString *chatRoomIdString = [NSString stringWithFormat:@"%@",chatRoomID];
        if (chatRoomIdString && [chatRoomIdString length]>0) {
//            MyMatches *matchUserObj = [self getMatchDetailForMatchedUSerID:chatRoomIdString];
            ChatMessage *chatMessageObj = [ChatMessage getLastMessageForChatRoom:chatRoomIdString];
            if (matchUserObj && matchUserObj.isFault == NO) {
                if (chatMessageObj) {
                    if (([chatMessageObj.messageType intValue] == INTRODUCTION) || matchUserObj.isTargetFlagged.boolValue == true) {
                        NSLog(@"do nothing");
                        [matchUserObj setChatSnippetUserId:@""];
                    }
                    else{
                        if ([chatMessageObj.messageType intValue] == TEXT) {
                            [matchUserObj setChatSnippet:chatMessageObj.message];
                            [matchUserObj setChatSnippetTime:[NSDate dateWithTimeIntervalSince1970:([chatMessageObj.chatMessageCreatedTime longLongValue]/1000)]];
                            [matchUserObj setChatSnippetUserId:chatMessageObj.messageSenderID];
                        }
                        else if (([chatMessageObj.messageType intValue] == QUESTION) || ([chatMessageObj.messageType intValue] == ANSWER)){
                            [matchUserObj setChatSnippet:chatMessageObj.message];
                            [matchUserObj setChatSnippetTime:chatTime];
                            [matchUserObj setChatSnippetUserId:@""];
                        }
                        else if ([chatMessageObj.messageType intValue] == IMAGE_SEND_BY_USER){
                            NSString *matchUserId = @"";
                            
                            if ([matchUserObj.chatServer isEqualToString:kisAppLozicServer]){
                                matchUserId = matchUserObj.targetAppLozicId;
                            }
                            else{
                                matchUserId = matchUserObj.matchedUserId;
                            }
                            if (![matchUserId isEqualToString:chatMessageObj.messageSenderID]) {
                                [matchUserObj setChatSnippet:@"You shared a photo"];
                            }
                            else{
                                [matchUserObj setChatSnippet:[NSString stringWithFormat:@"%@ shared a photo",matchUserObj.matchUserName]];
                            }
                            [matchUserObj setChatSnippetTime:[NSDate dateWithTimeIntervalSince1970:([chatMessageObj.chatMessageCreatedTime longLongValue]/1000)]];
                            [matchUserObj setChatSnippetUserId:chatMessageObj.messageSenderID];
                        }
                        else if ([chatMessageObj.messageType intValue] == IMAGE){
                            [matchUserObj setChatSnippet:@"Sticker"];
                            [matchUserObj setChatSnippetTime:[NSDate dateWithTimeIntervalSince1970:([chatMessageObj.chatMessageCreatedTime longLongValue]/1000)]];
                            [matchUserObj setChatSnippetUserId:chatMessageObj.messageSenderID];
                        }
                        //                [chatRoomObj setChatSnippet:chatMessageObj.message];
                        
                    }
                    
                    [matchUserObj setIsRead:[NSNumber numberWithBool:isRead]];
                    
                }
                else{
                      if(matchUserObj.isTargetFlagged.boolValue == false)
                      {
                        [matchUserObj setChatSnippet:chatSnippet];
                        [matchUserObj setChatSnippetTime:chatTime];
                        [matchUserObj setIsRead:[NSNumber numberWithBool:isRead]];
                      }
                    [matchUserObj setChatSnippetUserId:@""];
                }
                
                if (source) {
                    [matchUserObj setSource:source];
                }
                else{
                    [matchUserObj setSource:@""];
                }
                
                
            }
        }
        
        if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
        else{
            // Saving data on parent context and then informing back
            
      
            [STORE saveMatchChatonMainBlockDataOnParentContextWithHandler:^(BOOL isCompleted) {
                
               
                    if(isCompleted)
                    {
                        completionBlock(TRUE,matchUserObj);
                    if (matchUserObj && matchUserObj.isFault == NO)
                    {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kChatRoomChatSnippetUpdated object:matchUserObj];
                    }
                        [[WooScreenManager sharedInstance].oHomeViewController checkAndShowUnreadBadgeOnMatchIcon];
                    }
                
            }];
            

        }
        
    }];
    

    
    
}

+(void)changeFavStatusOfChatRoomForChatRoomID:(NSString *)chatRoomID{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    
    [privateManagedObjectContext performBlock:^{
        
        MyMatches *matchedUserObj = [self getMatchDetailForMatchedUSerID:chatRoomID isApplozic:false];
        
        if (!matchedUserObj) {
            return;
        }
        
        MyMatches *matchObj = [MyMatches getMatchDetailForMatchedUSerID:chatRoomID isApplozic:false];
        
        if ([matchedUserObj.isFav boolValue] == YES) {
            matchedUserObj.isFav = [NSNumber numberWithBool:NO];
            [APP_Utilities updatePendingUnFavListWithMatchID:matchObj.matchId];
        }else{
            matchedUserObj.isFav = [NSNumber numberWithBool:YES];
            [APP_Utilities updatePendingFavListWithMatchID:matchObj.matchId];
        }
        
        if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
        else{
            // Saving data on parent context and then informing back
            [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                
                // Do Nothing
                
            }];
        }
        
    }];
}

//+(void)checkIfChatRoomExistsForIncomingMessage:(LYRMessage *)messageObj withCompletionBlock:(void(^)(BOOL chatRoomExists))completionBlock{
//    BOOL chatRoomExist = FALSE;
//    if (messageObj && ([messageObj.conversation.participants count] > 1)) {
//        NSString *matchedUserID;
//        for (LYRIdentity *userInfo in messageObj.conversation.participants) {
//            if (![userInfo.userID isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]]) {
//                matchedUserID = userInfo.userID;
//                break;
//            }
//        }
//        if ([self getMatchDetailForMatchedUSerID:matchedUserID isApplozic:false]) {
//            chatRoomExist = TRUE;
//        }
//    }
//    completionBlock(chatRoomExist);
//}

+(void)checkIfChatRoomExistsForIncomingMessageFromApplozic:(NSString *)userID withCompletionBlock:(void(^)(BOOL chatRoomExists))completionBlock{
    BOOL chatRoomExist = FALSE;
    if (userID != nil && userID.length > 0) {
        NSString *matchedUserID;
        if (![userID isEqualToString:[LoginModel sharedInstance].appLozicUserId]) {
                matchedUserID = userID;
            }
        if ([self getMatchDetailForMatchedUSerID:matchedUserID isApplozic:true]) {
            chatRoomExist = TRUE;
        }
    }
    completionBlock(chatRoomExist);
}

+(int )getCountOfUnreadChatrooms{
    return ((int)[[self getAllUnreadMessage] count]);
}

+(NSArray *)getAllFavChatRoom{
    NSManagedObjectContext *managedObjectContext = [APP_DELEGATE.store childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MyMatches" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    NSError *error = nil;
    
    
    // code for sorting starts here
    NSSortDescriptor *dateSortingDescriptior = [[NSSortDescriptor alloc]initWithKey:@"chatSnippetTime" ascending:NO];
    
    NSArray *sortDescriptorArray = [NSArray arrayWithObjects:dateSortingDescriptior, nil];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(isFav==%@)", [NSNumber numberWithBool:YES]];
    
    [request setPredicate:predicateObj];
    
    [request setSortDescriptors:sortDescriptorArray];
    // code for sorting ends here
    
    NSArray *chatRoomArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    
    if (chatRoomArray && [chatRoomArray count]>0) {
        return chatRoomArray;
    }
    return nil;
}

/*
 +(void)updateChatSnippetForChatRoomID:(NSString *)chatRoomID{

    
}
 */

+(void)createChatRoomForMyMatch:(MyMatches *)myMatchObj andWithresponseDict:(NSDictionary *)matchedRespopnse withInsertionCompletionBlock:(MatchChatSnippetInsertionCompletionBlock)matchChatSnippetInsertionCompletion{
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsUserBlacklisted]) {
        matchChatSnippetInsertionCompletion(@"");
    }

    __block NSString *chatSnippetString = @"";
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    [privateManagedObjectContext performBlock:^{
        
        if (myMatchObj && [myMatchObj.matchId length]>0) {
            
            NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
            long long introLongLongNumber = timeInSeconds*1000;
            if (![ChatMessage getIntroMessageForTheChatRoom:myMatchObj.matchId]) {
                [ChatMessage insertNewChatMessageIntoDatabase: [[NSDictionary alloc] initWithObjectsAndKeys:
                                                                [NSNumber numberWithInt:INTRODUCTION],kMessageTypeKey,
                                                                myMatchObj.matchId,kChatRoomIDKey,
                                                                [NSString stringWithFormat:@"%lld",introLongLongNumber],kChatMessageCreatedTime,
                                                                nil] withCompletionHandler:^(ChatMessage *chatMessageObj) {
                [self createChatRoomAndInsertQuestionCreatedByMeOrOtherPersonWithInsertionCompletionBlock:matchChatSnippetInsertionCompletion andWithresponseDict:matchedRespopnse withMatchObject:myMatchObj withString:chatSnippetString withPrivateObject:privateManagedObjectContext];
                }];
            }else{
                [self createChatRoomAndInsertQuestionCreatedByMeOrOtherPersonWithInsertionCompletionBlock:matchChatSnippetInsertionCompletion andWithresponseDict:matchedRespopnse withMatchObject:myMatchObj withString:chatSnippetString withPrivateObject:privateManagedObjectContext];
            }
        }else{
            // Do Nothing
            dispatch_async(dispatch_get_main_queue(), ^{
                if(matchChatSnippetInsertionCompletion)
                    matchChatSnippetInsertionCompletion(chatSnippetString);
            });
        }
        
        
    }];
}

+(void)createChatRoomAndInsertQuestionCreatedByMeOrOtherPersonWithInsertionCompletionBlock:(MatchChatSnippetInsertionCompletionBlock)matchChatSnippetInsertionCompletion andWithresponseDict:(NSDictionary *)matchedRespopnse withMatchObject:(MyMatches *)myMatchObj withString:(NSString*)chatSnippetString withPrivateObject:(NSManagedObjectContext *)privateManagedObjectContext{
    
    
    BOOL isQuestionAskedByMe = FALSE;
    
    if (myMatchObj.matchedQuestion && [APP_Utilities validString:myMatchObj.matchedQuestion] > 0) {
        
        NSDecimalNumber *qDecimalNumber = [NSDecimalNumber decimalNumberWithString:kOldTimeStamp_Question];
       
        long long qLongLongNumber = [[qDecimalNumber description] longLongValue];
        
        if ([matchedRespopnse objectForKey:@"questionAuthorId"]) {
            
            if ([[NSString stringWithFormat:@"%@",[matchedRespopnse objectForKey:@"questionAuthorId"]] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]]) {
                isQuestionAskedByMe = TRUE;
            }
        }
        
        chatSnippetString = [APP_Utilities getURLDecodedStringFromString:myMatchObj.matchedQuestion];
        
        if (![ChatMessage getMessageForChatRoom:myMatchObj.matchId ofMessageType:QUESTION]) {
            if (!isQuestionAskedByMe) {

                [ChatMessage insertNewChatMessageIntoDatabase:[[NSDictionary alloc] initWithObjectsAndKeys:
                                                               [NSNumber numberWithInt:QUESTION],kMessageTypeKey,
                                                               myMatchObj.matchId,kChatRoomIDKey,
                                                               [NSString stringWithFormat:@"%lld",qLongLongNumber],kChatMessageCreatedTime,
                                                               myMatchObj.matchedUserId,kMessageSenderIDKey,
                                                               [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],kMessageReceiverID,
                                                               chatSnippetString,kMessageKey,
                                                               nil] withCompletionHandler:^(ChatMessage *chatMessageObj) {
                    [self createChatRoomAndInsertAnswerCreatedByMeOrOtherPerson:matchChatSnippetInsertionCompletion andWithresponseDict:matchedRespopnse withMatchObject:myMatchObj withString:chatSnippetString withPrivateObject:privateManagedObjectContext withAskedByMe:isQuestionAskedByMe];
                    
                }];
            }else{
                [ChatMessage insertNewChatMessageIntoDatabase:[[NSDictionary alloc] initWithObjectsAndKeys:
                                                               [NSNumber numberWithInt:QUESTION],kMessageTypeKey,
                                                               myMatchObj.matchId,kChatRoomIDKey,
                                                               [NSString stringWithFormat:@"%lld",qLongLongNumber],kChatMessageCreatedTime,
                                                               myMatchObj.matchedUserId,kMessageReceiverID,
                                                               [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],kMessageSenderIDKey,
                                                               chatSnippetString,kMessageKey,
                                                               nil] withCompletionHandler:^(ChatMessage *chatMessageObj) {
                    [self createChatRoomAndInsertAnswerCreatedByMeOrOtherPerson:matchChatSnippetInsertionCompletion andWithresponseDict:matchedRespopnse withMatchObject:myMatchObj withString:chatSnippetString withPrivateObject:privateManagedObjectContext withAskedByMe:isQuestionAskedByMe];
                }];
            }
        }else{
            [self createChatRoomAndInsertAnswerCreatedByMeOrOtherPerson:matchChatSnippetInsertionCompletion andWithresponseDict:matchedRespopnse withMatchObject:myMatchObj withString:chatSnippetString withPrivateObject:privateManagedObjectContext withAskedByMe:isQuestionAskedByMe];
        }
    }else{
        
        [self createChatRoomAndInsertAnswerCreatedByMeOrOtherPerson:matchChatSnippetInsertionCompletion andWithresponseDict:matchedRespopnse withMatchObject:myMatchObj withString:chatSnippetString withPrivateObject:privateManagedObjectContext withAskedByMe:isQuestionAskedByMe];
    }
    
}

+(void)createChatRoomAndInsertAnswerCreatedByMeOrOtherPerson:(MatchChatSnippetInsertionCompletionBlock)matchChatSnippetInsertionCompletion andWithresponseDict:(NSDictionary *)matchedRespopnse withMatchObject:(MyMatches *)myMatchObj withString:(NSString*)chatSnippetString withPrivateObject:(NSManagedObjectContext *)privateManagedObjectContext withAskedByMe:(BOOL) isQuestionAskedByMe{
    
    if (myMatchObj.matchedAnswer && [APP_Utilities validString:myMatchObj.matchedAnswer] > 0) {
        NSDecimalNumber *aDecimalNumber = [NSDecimalNumber decimalNumberWithString:kOldTimeStamp_Answer];
        long long aLongLongNumber = [[aDecimalNumber description] longLongValue];
        
        chatSnippetString = [APP_Utilities getURLDecodedStringFromString:myMatchObj.matchedAnswer];
        
        if (![ChatMessage getMessageForChatRoom:myMatchObj.matchId ofMessageType:ANSWER]) {
            if (!isQuestionAskedByMe) {
                [ChatMessage insertNewChatMessageIntoDatabase:[[NSDictionary alloc] initWithObjectsAndKeys:
                                                               [NSNumber numberWithInt:ANSWER],kMessageTypeKey,
                                                               myMatchObj.matchId,kChatRoomIDKey,
                                                               [NSString stringWithFormat:@"%lld",aLongLongNumber],kChatMessageCreatedTime,
                                                               myMatchObj.matchedUserId,kMessageReceiverID,
                                                               [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],kMessageSenderIDKey,
                                                               chatSnippetString,kMessageKey,
                                                               nil] withCompletionHandler:^(ChatMessage *chatMessageObj) {
                    [self createChatRoomAndInsertBothQACreatedByMeOrOtherPerson:matchChatSnippetInsertionCompletion andWithresponseDict:matchedRespopnse withMatchObject:myMatchObj withString:chatSnippetString withPrivateObject:privateManagedObjectContext withAskedByMe:isQuestionAskedByMe];
                }];
            }
            else{
                [ChatMessage insertNewChatMessageIntoDatabase:[[NSDictionary alloc] initWithObjectsAndKeys:
                                                               [NSNumber numberWithInt:ANSWER],kMessageTypeKey,
                                                               myMatchObj.matchId,kChatRoomIDKey,
                                                               [NSString stringWithFormat:@"%lld",([kOldTimeStamp_Answer longLongValue])],kChatMessageCreatedTime,
                                                               myMatchObj.matchedUserId,kMessageSenderIDKey,
                                                               [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],kMessageReceiverID,
                                                               chatSnippetString,kMessageKey,
                                                               nil] withCompletionHandler:^(ChatMessage *chatMessageObj) {
                    [self createChatRoomAndInsertBothQACreatedByMeOrOtherPerson:matchChatSnippetInsertionCompletion andWithresponseDict:matchedRespopnse withMatchObject:myMatchObj withString:chatSnippetString withPrivateObject:privateManagedObjectContext withAskedByMe:isQuestionAskedByMe];
                }];
            }
        }else{
            [self createChatRoomAndInsertBothQACreatedByMeOrOtherPerson:matchChatSnippetInsertionCompletion andWithresponseDict:matchedRespopnse withMatchObject:myMatchObj withString:chatSnippetString withPrivateObject:privateManagedObjectContext withAskedByMe:isQuestionAskedByMe];
        }
    }else{
        [self createChatRoomAndInsertBothQACreatedByMeOrOtherPerson:matchChatSnippetInsertionCompletion andWithresponseDict:matchedRespopnse withMatchObject:myMatchObj withString:chatSnippetString withPrivateObject:privateManagedObjectContext withAskedByMe:isQuestionAskedByMe];
    }
    
}

+(void)createChatRoomAndInsertBothQACreatedByMeOrOtherPerson:(MatchChatSnippetInsertionCompletionBlock)matchChatSnippetInsertionCompletion andWithresponseDict:(NSDictionary *)matchedRespopnse withMatchObject:(MyMatches *)myMatchObj withString:(NSString*)chatSnippetString withPrivateObject:(NSManagedObjectContext *)privateManagedObjectContext withAskedByMe:(BOOL) isQuestionAskedByMe{
    
//    NSDateFormatter *dateFormatFromServer = [[NSDateFormatter alloc]init];
//    [dateFormatFromServer setDateFormat:@"dd/MM/yyyy"];
//
//    NSDate *localDate = myMatchObj.matchedOn;
//
//    NSString *dateString = [NSString stringWithFormat:NSLocalizedString(@"Matched on: %@",nil),[dateFormatFromServer stringFromDate:localDate]];
//
//    if ([chatSnippetString length]<1) {
//        chatSnippetString = dateString;
//    }
//
    [self savePrivateContextWithInsertionCompletionBlock:matchChatSnippetInsertionCompletion withPrivateObject:privateManagedObjectContext withString:chatSnippetString];
    
}

+(void)savePrivateContextWithInsertionCompletionBlock:(MatchChatSnippetInsertionCompletionBlock)matchChatSnippetInsertionCompletion withPrivateObject:(NSManagedObjectContext *)privateManagedObjectContext withString:(NSString*)chatSnippetString{
    
    if(matchChatSnippetInsertionCompletion)
        matchChatSnippetInsertionCompletion(chatSnippetString);
    
    /*
    __block NSError *error = nil;
    
    if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //abort();
    }
    else{
        // Saving data on parent context and then informing back
        [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if(matchChatSnippetInsertionCompletion)
                    matchChatSnippetInsertionCompletion(chatSnippetString);
            });
        }];
    }
    */
}

/*+(void)createChatRoomForMyMatch:(MyMatches *)myMatchObj withInsertionCompletionBlock:(MatchChatSnippetInsertionCompletionBlock)matchChatSnippetInsertionCompletion{
 
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsUserBlacklisted]) {
        matchChatSnippetInsertionCompletion(@"");
    }

    __block NSString *chatSnippetString = @"";
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
 
    [privateManagedObjectContext performBlock:^{
    
        if (myMatchObj && [myMatchObj.matchId length]>0) {
            
            NSDecimalNumber *introDecimalNumber = [NSDecimalNumber decimalNumberWithString:kOldTimeStamp];
           
            long long introLongLongNumber = [[introDecimalNumber description] longLongValue];
            
            [ChatMessage insertNewChatMessageIntoDatabase:[[NSDictionary alloc] initWithObjectsAndKeys:
                                                           [NSNumber numberWithInt:INTRODUCTION],kMessageTypeKey,
                                                           myMatchObj.matchedUserId,kChatRoomIDKey,
                                                           [NSString stringWithFormat:@"%lld",introLongLongNumber],kChatMessageCreatedTime,
                                                           nil] withCompletionHandler:^(ChatMessage *chatMessageObj) {
                
            }];
            
            
            if (myMatchObj.matchedQuestion && [APP_Utilities validString:myMatchObj.matchedQuestion] > 0) {
                
                NSDecimalNumber *qDecimalNumber = [NSDecimalNumber decimalNumberWithString:kOldTimeStamp_Question];
               
                long long qLongLongNumber = [[qDecimalNumber description] longLongValue];
                
                //Added new encoding
                chatSnippetString = [APP_Utilities getURLDecodedStringFromString:myMatchObj.matchedQuestion];
                
                if ([APP_Utilities isGenderMale:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserGender]]) {
                    [ChatMessage insertNewChatMessageIntoDatabase:[[NSDictionary alloc] initWithObjectsAndKeys:
                                                                   [NSNumber numberWithInt:QUESTION],kMessageTypeKey,
                                                                   myMatchObj.matchedUserId,kChatRoomIDKey,
                                                                   [NSString stringWithFormat:@"%lld",qLongLongNumber],kChatMessageCreatedTime,
                                                                   myMatchObj.matchedUserId,kMessageSenderIDKey,
                                                                   [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],kMessageReceiverID,
                                                                   chatSnippetString,kMessageKey,
                                                                   nil] withCompletionHandler:^(ChatMessage *chatMessageObj) {
                        
                    }];
                }
                else{
                    [ChatMessage insertNewChatMessageIntoDatabase:[[NSDictionary alloc] initWithObjectsAndKeys:
                                                                   [NSNumber numberWithInt:QUESTION],kMessageTypeKey,
                                                                   myMatchObj.matchedUserId,kChatRoomIDKey,
                                                                   [NSString stringWithFormat:@"%lld",qLongLongNumber],kChatMessageCreatedTime,
                                                                   myMatchObj.matchedUserId,kMessageReceiverID,
                                                                   [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],kMessageSenderIDKey,
                                                                   chatSnippetString,kMessageKey,
                                                                   nil] withCompletionHandler:^(ChatMessage *chatMessageObj) {
                        
                    }];
                }
            }
            
            if (myMatchObj.matchedAnswer && [APP_Utilities validString:myMatchObj.matchedAnswer] > 0) {

                NSDecimalNumber *aDecimalNumber = [NSDecimalNumber decimalNumberWithString:kOldTimeStamp_Answer];
                
                long long aLongLongNumber = [[aDecimalNumber description] longLongValue];
                
                chatSnippetString = [APP_Utilities getURLDecodedStringFromString:myMatchObj.matchedAnswer];
                
                
                if ([APP_Utilities isGenderMale:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserGender]]) {
                    [ChatMessage insertNewChatMessageIntoDatabase:[[NSDictionary alloc] initWithObjectsAndKeys:
                                                                   [NSNumber numberWithInt:ANSWER],kMessageTypeKey,
                                                                   myMatchObj.matchedUserId,kChatRoomIDKey,
                                                                   [NSString stringWithFormat:@"%lld",aLongLongNumber],kChatMessageCreatedTime,
                                                                   myMatchObj.matchedUserId,kMessageReceiverID,
                                                                   [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],kMessageSenderIDKey,
                                                                   chatSnippetString,kMessageKey,
                                                                   nil] withCompletionHandler:^(ChatMessage *chatMessageObj) {
                        
                    }];
                }
                else{
                    [ChatMessage insertNewChatMessageIntoDatabase:[[NSDictionary alloc] initWithObjectsAndKeys:
                                                                   [NSNumber numberWithInt:ANSWER],kMessageTypeKey,
                                                                   myMatchObj.matchedUserId,kChatRoomIDKey,
                                                                   [NSString stringWithFormat:@"%lld",([kOldTimeStamp_Answer longLongValue])],kChatMessageCreatedTime,
                                                                   myMatchObj.matchedUserId,kMessageSenderIDKey,
                                                                   [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],kMessageReceiverID,
                                                                   chatSnippetString,kMessageKey,
                                                                   nil] withCompletionHandler:^(ChatMessage *chatMessageObj) {
                        
                    }];
                }
                
            }
            NSDateFormatter *dateFormatFromServer = [[NSDateFormatter alloc]init];
            [dateFormatFromServer setDateFormat:@"dd/MM/yyyy"];
            
            NSDate *localDate = myMatchObj.matchedOn;
            
            NSString *dateString = [NSString stringWithFormat:NSLocalizedString(@"Matched on: %@",nil),[dateFormatFromServer stringFromDate:localDate]];
            
            //            [myMatchObj setChatSnippet:dateString];
            if ([chatSnippetString length]<1) {
                chatSnippetString = dateString;
            }
        }

        if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
        else{
            // Saving data on parent context and then informing back
            [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                
                if(matchChatSnippetInsertionCompletion)
                    matchChatSnippetInsertionCompletion(chatSnippetString);
                
            }];
        }
        
    }];
} */

+(void)updateMatchedUserStatus:(int)currentStatus forChatRoomId:(NSString *)chatRoomId withUpdationCompletionHandler:(MatchedUserUpdationCompletionHandler)updationCompletionHandler{
  
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    [privateManagedObjectContext performBlock:^{
        
        MyMatches *matchedUser = [self getMatchDetailForMatchID:chatRoomId];
        
        
        if (!matchedUser) {
            if(updationCompletionHandler)
                updationCompletionHandler(false);
        }
        [matchedUser setMatchedUserStatus:[NSNumber numberWithInt:currentStatus]];
    
        
        if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
        else{
            // Saving data on parent context and then informing back
            [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                
                if(updationCompletionHandler)
                    updationCompletionHandler(TRUE);
                
            }];
        }
        
    }];
}

+(void)updateMatchedUserDummyStatus:(NSString *)server forID:(NSString *)kdummyID forChatRoomId:(NSString *)chatRoomId withUpdationCompletionHandler:(MatchedUserUpdationCompletionHandler)updationCompletionHandler{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    [privateManagedObjectContext performBlock:^{
        
        MyMatches *matchedUser = [self getMatchDetailForMatchID:chatRoomId];
        
        if (!matchedUser) {
            if(updationCompletionHandler)
                updationCompletionHandler(false);
        }
        [matchedUser setChatServer:server];
        [matchedUser setTargetAppLozicId:kdummyID];
        [matchedUser setIsRequesterFlagged:[NSNumber numberWithBool:false]];
        [matchedUser setIsTargetFlagged:[NSNumber numberWithBool:false]];
        
        
        
        if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
        else{
            // Saving data on parent context and then informing back
            [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                
                if(updationCompletionHandler)
                    updationCompletionHandler(TRUE);
                
            }];
        }
        
    }];
}

+(NSMutableArray *)getAllPendingMatched{
    
    NSError *error = nil;
    
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MyMatches" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(matchedUserStatus != %@)", [NSNumber numberWithInt:MATCHED_USER_STATUS_CONNECTED_TO_LAYER]];
    
    [request setPredicate:predicateObj];
    
    NSArray *notificationsArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    return (NSMutableArray*) ([notificationsArray count]>0 ? notificationsArray : nil );
}

+(void)deleteAllFailedMatchedAfter2HoursWithDeletionCompletionHandler:(MatchedUserDeletionCompletionHandler)completionHandler{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;

    [privateManagedObjectContext performBlock:^{
        
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MyMatches" inManagedObjectContext:privateManagedObjectContext];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        [request setEntity:entityDescription];
        
        NSDate *now = [NSDate date];
        
        NSString *stringWithDate = [NSString stringWithFormat:@"(layerChatID CONTAINS[cd] '%@')", @"dummyChatId"];

        NSPredicate *predicateObj = [NSPredicate predicateWithFormat:stringWithDate];
        
        [request setPredicate:predicateObj];
        
        NSArray *matchedToBeDeleted = [privateManagedObjectContext executeFetchRequest:request error:&error];
        
        if (matchedToBeDeleted && [matchedToBeDeleted count]) {
            for (MyMatches *matchObj in matchedToBeDeleted) {
                if ([now timeIntervalSinceDate:matchObj.matchedOn] > 7200) {
                    if (!([matchObj.chatServer isEqualToString:kisAppLozicServer] && [matchObj.targetAppLozicId isEqualToString:kDummyApplozicChatID])){
                    [privateManagedObjectContext deleteObject:matchObj];
                    }
                }
            }
        }
        
        if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
        else{
            // Saving data on parent context and then informing back
            [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                
                completionHandler(TRUE);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kMatchDataSavedInLocalDatabase object:nil];
                });
            }];
        }
        
    }];

}

+(void)updateMatchedUserDetailsForMatchedUserID:(NSString *)userID withAgoraChannelKey:(NSString *)channelKey withChatUpdationSuccess:(MatchedUserUpdationCompletionHandler)matchUserUpdationBlock{
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsUserBlacklisted]) {
        return;
        
    }
    
    if (userID && [userID length]<1) {
        return;
    }
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    
    [privateManagedObjectContext performBlock:^{
        
        MyMatches *matchedUser = [self getMatchDetailForMatchedUSerID:userID isApplozic:false];
        
        if (!matchedUser) {
            return;
        }
        
        //Update channel key
        [matchedUser setAgoraChannelKey:channelKey];
        if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
        else{
            // Saving data on parent context and then informing back
            [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                
                if(matchUserUpdationBlock)
                    matchUserUpdationBlock(YES);
            }];
        }
        
    }];
    
}


@end
