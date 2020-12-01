//
//  Answers.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 06/07/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "MyAnswers.h"

@implementation MyAnswers

@dynamic answerId;
@dynamic questionId;
@dynamic wooId;
@dynamic answerDescription;
@dynamic userName;
@dynamic userImageURL;
@dynamic userAge;
@dynamic isRead;
@dynamic createdTime;


+(NSArray *)getAllAnswerForQuestionWithQuestionID:(long long int)questionID{
    
    NSManagedObjectContext *managedObjectContext = [APP_DELEGATE.store childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Answers" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSSortDescriptor *serverTimeSorting = [[NSSortDescriptor alloc] initWithKey:@"createdTime" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:serverTimeSorting]];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(questionId==%@)", [NSNumber numberWithLongLong:questionID]];
    
    [request setPredicate:predicateObj];
    
    NSError *error = nil;
    
    NSArray *answersArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (answersArray && [answersArray count]>0 && !error) {
        return answersArray;
    }
    return [[NSArray alloc] init];
}


+(void)deleteAllAnswersByUserWithUserID:(long long int)userID withCompletionHandler:(DeletionCompletionHandler)completionHandler{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    
        [privateManagedObjectContext performBlock:^{
            
            NSArray *allAnswersArray = [self getAllAnswerByUserID:userID];
            
            if (allAnswersArray && [allAnswersArray count]>0) {
                
                __block int totalCount = (int)[allAnswersArray count];
                
                for (MyAnswers *answerObj in allAnswersArray) {
                    
                    if (![answerObj.isRead boolValue]) {
                        
                        MyQuestions *toBeUpdatedQuestion = [MyQuestions getQuestionForQuestionID:[answerObj.questionId longLongValue]];
                        
                        if (toBeUpdatedQuestion && toBeUpdatedQuestion.totalUnreadAnswers.intValue > 0) {
                            int unread = [toBeUpdatedQuestion.totalUnreadAnswers intValue];
                            
                            unread = unread - 1;
                            if (unread < 0) {
                                unread = 0;
                            }
                            [toBeUpdatedQuestion setTotalUnreadAnswers:[NSNumber numberWithInt:unread]];
                            
                        }
                        
                        if (toBeUpdatedQuestion && toBeUpdatedQuestion.totalAnswers.intValue > 0) {
                            int totalAnswers = [toBeUpdatedQuestion.totalAnswers intValue];
                            
                            totalAnswers = totalAnswers - 1;
                            if (totalAnswers < 0) {
                                totalAnswers = 0;
                            }
                            [toBeUpdatedQuestion setTotalAnswers:[NSNumber numberWithInt:totalAnswers]];
                            
                        }
                        
                        [privateManagedObjectContext deleteObject:answerObj];
                        
                        --totalCount;
                        
                        if(totalCount<=0){
                            
                            /***************************Save Context*************************************/
                            
                            if (privateManagedObjectContext != nil) {
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
                                            if(completionHandler){
                                                completionHandler(TRUE);
                                            }
                                        });
                                    }];
                                    
                                }
                            }
                            
                            /*****************************************************************************/
                        }


                    }else{
                        
                        MyQuestions *toBeUpdatedQuestion = [MyQuestions getQuestionForQuestionID:[answerObj.questionId longLongValue]];
                        
                        if (toBeUpdatedQuestion && toBeUpdatedQuestion.totalAnswers.intValue > 0) {
                            int totalAnswers = [toBeUpdatedQuestion.totalAnswers intValue];
                            
                            totalAnswers = totalAnswers - 1;
                            if (totalAnswers < 0) {
                                totalAnswers = 0;
                            }
                            [toBeUpdatedQuestion setTotalAnswers:[NSNumber numberWithInt:totalAnswers]];
                            
                        }
                        
                        [privateManagedObjectContext deleteObject:answerObj];
                        
                        --totalCount;
                        
                        if(totalCount<=0){
                            
                            /***************************Save Context*************************************/
                            
                            if (privateManagedObjectContext != nil) {
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
                                            if(completionHandler){
                                                completionHandler(TRUE);
                                            }
                                        });
                                    }];
                                    
                                }
                            }
                            
                            /*****************************************************************************/
                        }
                        
                    }
                }
            }
        }];
}

+(void)deleteAllAnswersByUserWithUserID_Str:(NSString *)userID withCompletionHandler:(DeletionCompletionHandler)completionHandler{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    [privateManagedObjectContext performBlock:^{
        
        NSArray *allAnswersArray = [self getAllAnswerByUserID:[userID longLongValue]];
        
        if (allAnswersArray && [allAnswersArray count]>0) {
            
            __block int totalCount = (int)[allAnswersArray count];

            for (MyAnswers *answerObj in allAnswersArray) {
                
                if (![answerObj.isRead boolValue]) {
                    
                    MyQuestions *toBeUpdatedQuestion = [MyQuestions getQuestionForQuestionID:[answerObj.questionId longLongValue]];
                    
                    if (toBeUpdatedQuestion && toBeUpdatedQuestion.totalUnreadAnswers.intValue > 0) {
                        int unread = [toBeUpdatedQuestion.totalUnreadAnswers intValue];
                        
                        unread = unread - 1;
                        if (unread < 0) {
                            unread = 0;
                        }
                        [toBeUpdatedQuestion setTotalUnreadAnswers:[NSNumber numberWithInt:unread]];
                        
                    }
                    
                    [MyAnswers decrementTotalAfterUpdationOfCounter:answerObj withPrivateContext:privateManagedObjectContext withCount:totalCount withCompletionHandler:completionHandler];
                    
                }else{
                    [MyAnswers decrementTotalAfterUpdationOfCounter:answerObj withPrivateContext:privateManagedObjectContext withCount:totalCount withCompletionHandler:completionHandler];
                }
            }
        }
    }];
    
}

+(void)decrementTotalAfterUpdationOfCounter:(MyAnswers*)answerObj withPrivateContext:(NSManagedObjectContext*)privateManagedObjectContext withCount:(int)count withCompletionHandler:(DeletionCompletionHandler)completionHandler{
    
    __block NSError *error = nil;
    
    __block int totalCount = count;
    
    [MyQuestions decrementTotalAnswersForQuestionID:[answerObj.questionId longLongValue] by:1 withCompletionHandler:^(BOOL isCompleted) {
        [privateManagedObjectContext deleteObject:answerObj];
        
        --totalCount;
        
        if(totalCount<=0){
            
            /***************************Save Context*************************************/
            
            if (privateManagedObjectContext != nil) {
                if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    //abort();
                }
                else{
                    // Saving data on parent context and then informing back
                    [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                        if(completionHandler){
                            dispatch_async(dispatch_get_main_queue(), ^{
                                    completionHandler(TRUE);
                            });
                        }
                        
                    }];
                    
                }
            }
            
            /*****************************************************************************/
        }
    }];

}


+(NSArray *)getAllAnswerByUserID:(long long int)userId{
    
    NSManagedObjectContext *managedObjectContext = [APP_DELEGATE.store childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Answers" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(wooId==%@)", [NSNumber numberWithLongLong:userId]];
    
    [request setPredicate:predicateObj];
    
    NSError *error = nil;
    
    NSArray *answersArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (answersArray && [answersArray count]>0) {
        return answersArray;
    }
    return nil;
}

+(MyAnswers *)getAnswerByAnswerID:(long long int )answerID{
    
    NSManagedObjectContext *managedObjectContext = [APP_DELEGATE.store childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Answers" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(answerId==%@)", [NSNumber numberWithLongLong:answerID]];
    
    [request setPredicate:predicateObj];
    
    NSError *error = nil;
    
    NSArray *answersArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (answersArray) {
        return [answersArray firstObject];
    }else{
        return nil;
    }
}

+(void)deleteAnswerByAnswerId:(long long int)AnswerId withCompletionHandler:(DeletionCompletionHandler)completionHandler{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    [privateManagedObjectContext performBlock:^{
        
        MyAnswers *answerObj = [self getAnswerByAnswerID:AnswerId];
        
        NSNumber *currentQuestionId = answerObj.questionId;
        if (answerObj) {
            [privateManagedObjectContext deleteObject:answerObj];
        }
        
        MyAnswers *latestAnswerObj = [self getLatestAnswerTimestampForQuestion:[currentQuestionId longLongValue]];

        if (latestAnswerObj) {
            [MyQuestions updateLastUpdatedTimeOfQuestion:[latestAnswerObj.questionId longLongValue] withTime:latestAnswerObj.createdTime withCompletionHandler:^(BOOL isUpdationCompleted) {
                /***************************Save Context*************************************/
                
                __block NSError *error = nil;
                
                
                if (privateManagedObjectContext != nil) {
                    if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
                        // Replace this implementation with code to handle the error appropriately.
                        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                        //abort();
                    }
                    else{
                        // Saving data on parent context and then informing back
                        [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                            if(completionHandler){
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    completionHandler(TRUE);
                                });
                            }
                        }];
                        
                    }
                }
                
                /*****************************************************************************/
            }];
        }
        else{
            MyQuestions *questionToBeUpdated = [MyQuestions getQuestionForQuestionID:[currentQuestionId longLongValue]];
            if (questionToBeUpdated.questionCreatedTime) {
                [MyQuestions updateLastUpdatedTimeOfQuestion:[questionToBeUpdated.qid longLongValue] withTime:questionToBeUpdated.questionCreatedTime withCompletionHandler:^(BOOL isUpdationCompleted) {
                    /***************************Save Context*************************************/
                    
                    __block NSError *error = nil;
                    
                    
                    if (privateManagedObjectContext != nil) {
                        if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
                            // Replace this implementation with code to handle the error appropriately.
                            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                            //abort();
                        }
                        else{
                            // Saving data on parent context and then informing back
                            [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                                if(completionHandler){
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        completionHandler(TRUE);
                                    });
                                }
                            }];
                            
                        }
                    }
                    
                    /*****************************************************************************/

                }];
            }else{
                /***************************Save Context*************************************/
                
                __block NSError *error = nil;
                
                
                if (privateManagedObjectContext != nil) {
                    if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
                        // Replace this implementation with code to handle the error appropriately.
                        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                        //abort();
                    }
                    else{
                        // Saving data on parent context and then informing back
                        [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                            if(completionHandler){
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    completionHandler(TRUE);
                                });
                            }
                        }];
                        
                    }
                }
                
                /*****************************************************************************/

            }
        }
        
    }];

}

+(void)saveMainAndPrivateContextWithPrivateContext:(NSManagedObjectContext*)privateManagedObjectContext withNotify:(BOOL)isNotify withCompletionHandler:(InsertionCompletionHandler)completionHandler{
 
    /***************************Save Context*************************************/
    
    __block NSError *error = nil;
    
    
    if (privateManagedObjectContext != nil) {
        if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
        else{
            // Saving data on parent context and then informing back
            [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                if(isNotify){
                    [self setIsFetchingAnswers:false];
                    if(completionHandler){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completionHandler(TRUE);
                            [[AppLaunchModel sharedInstance] setIsNewDataPresentMyQuestionSection:[NSNumber numberWithBool:true]];
                            [[WooScreenManager sharedInstance].oHomeViewController checkAndshowUnreadBadgeOnAboutMeIcon];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"AnswersAddedNotification" object:nil];
                        });
                    }
                }
                
            }];
            
        }
    }
    
    /*****************************************************************************/
}

+(void)deleteAllAnswerForQuestionWithQuestionID:(long long int)questionID{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    [privateManagedObjectContext performBlock:^{
        
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Answers" inManagedObjectContext:privateManagedObjectContext];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        [request setEntity:entityDescription];
        
        NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(questionId==%@)", [NSNumber numberWithLongLong:questionID]];
        
        [request setPredicate:predicateObj];
        
        NSError *error = nil;
        
        NSArray *answersArray = [privateManagedObjectContext executeFetchRequest:request error:&error];
        
        for (MyAnswers *answerObj in answersArray) {
            [privateManagedObjectContext deleteObject:answerObj];
        }
        
        [MyAnswers saveMainAndPrivateContextWithPrivateContext:privateManagedObjectContext withNotify:NO withCompletionHandler:nil];
        
    }];
}


+(void)updateAnswerData:(NSDictionary *)answerDict ForWooId:(NSString*)wooId
{
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    __block NSError *error = nil;
    if (privateManagedObjectContext)
    {
        [privateManagedObjectContext performBlock:^{
            
            MyAnswers *answerObj = [[self getAllAnswerByUserID:[[answerDict objectForKey:@"wooUserId"]longLongValue]] firstObject];
            [answerObj setWooId:[NSNumber numberWithLong:[[answerDict objectForKey:@"wooUserId"] longLongValue]]];
            [answerObj setUserName:[answerDict objectForKey:@"firstName"]];
            [answerObj setUserAge:[NSNumber numberWithInt:[[answerDict objectForKey:@"age"] intValue]]];
            [answerObj setUserImageURL:[answerDict objectForKey:@"profilePicUrl"]];
            
            NSLog(@"privateManagedObjectContext");
            /***************************Save Context*************************************/
            if (privateManagedObjectContext != nil)
            {
                if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error])
                {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    //abort();
                }
                else{
                    // Saving data on parent context and then informing back
                    NSLog(@"Saving data on parent context and then informing back");
                    [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted)
                     {
                         if(isCompleted)
                         {
                         }
                     }];
                    
                }
            }
        }];
        
    }
}

+(void)insertOrUpdateAnswersFromAnswerArray:(NSArray *)answersArray isFetchingNewAnswers:(BOOL)isFetchingNewAnswers withCompletionHandler:(InsertionCompletionHandler __nullable)completionHandler{
    
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    [privateManagedObjectContext performBlock:^{
        
        if (answersArray && [answersArray count] > 0 ) {
            
            __block int totalCount = (int)[answersArray count];
            
            for (NSDictionary *answerDictionary in answersArray) {
                
                if ([answerDictionary objectForKey:kQuestionIDKey] && [answerDictionary objectForKey:kQuestionIDKey] !=[NSNull null]) {
                    MyAnswers *answerObj = [self getAnswerByAnswerID:[[answerDictionary objectForKey:kQuestionIDKey] longLongValue]];
                    //Added new bool to check if answer already exists in the db or not it will be replacing the "isFetchingNewAnswers" bool value
                    BOOL isNewAnswerForThisQuestion = FALSE;
                    if (!answerObj) {
                        answerObj = (MyAnswers *)[NSEntityDescription insertNewObjectForEntityForName:@"Answers" inManagedObjectContext:privateManagedObjectContext];
                        isNewAnswerForThisQuestion = TRUE;
                    }
                    
                    if ([[answerDictionary objectForKey:kAnswerStatusKey] isEqualToString:@"NONE"]) {
                        [answerObj setAnswerId:[NSNumber numberWithLongLong:[[answerDictionary objectForKey:kAnswerIdKey] longLongValue]]];
                        [answerObj setQuestionId:[NSNumber numberWithLongLong:[[answerDictionary objectForKey:kQuestionIdKey] longLongValue]]];
                        [answerObj setUserAge:[NSNumber numberWithLongLong:[[answerDictionary objectForKey:kQuestionUserAge] longLongValue]]];
                        [answerObj setWooId:[NSNumber numberWithLongLong:[[answerDictionary objectForKey:kUserWooIdKey] longLongValue]]];
                        [answerObj setAnswerDescription:[APP_Utilities getURLDecodedStringFromString:[answerDictionary objectForKey:kAnswerTextKey]]];
                        [answerObj setCreatedTime:[APP_Utilities returnDateFromTimeStamp:[[answerDictionary objectForKey:kAnswerCreatedTimestampKey] longLongValue]]];
                        [answerObj setUserName:[answerDictionary objectForKey:kUserFirstNameKey]];
                        [answerObj setUserImageURL:[answerDictionary objectForKey:kUserImageURLKey]];
                        [answerObj setIsRead:[NSNumber numberWithInt:([[answerDictionary objectForKey:kAnswerReadStatusKey] intValue] == 1?1:0)]];
                        
                        if (isFetchingNewAnswers && isNewAnswerForThisQuestion) {
                            [MyQuestions incrementTotalAnswersForQuestionWithQuestionID:[[answerDictionary objectForKey:kQuestionIdKey] longLongValue] by:1 withCompletionHandler:^(BOOL isCompleted) {
                                if ([[answerDictionary objectForKey:kAnswerReadStatusKey] boolValue] == FALSE) {
                                    [MyQuestions incrementUnreadAnswersForQuestionWithQuestionID:[[answerDictionary objectForKey:kQuestionIdKey] longLongValue] by:1 withCompletionHandler:^(BOOL isCompleted) {
                                        [MyQuestions updateLastUpdatedTimeOfQuestion:[[answerDictionary objectForKey:kQuestionIdKey] longLongValue] withTime:[APP_Utilities returnDateFromTimeStamp:[[answerDictionary objectForKey:kAnswerCreatedTimestampKey] longLongValue]] withCompletionHandler:^(BOOL isUpdationCompleted) {
                                            --totalCount;
                                            if(totalCount<=0){
                                                [self saveMainAndPrivateContextWithPrivateContext:privateManagedObjectContext withNotify:YES withCompletionHandler:^(BOOL isInsertionCompleted) {
                                                    completionHandler(TRUE);
                                                }];
                                            }
                                        }];
                                    }];
                                }else{
                                    [MyQuestions updateLastUpdatedTimeOfQuestion:[[answerDictionary objectForKey:kQuestionIdKey] longLongValue] withTime:[APP_Utilities returnDateFromTimeStamp:[[answerDictionary objectForKey:kAnswerCreatedTimestampKey] longLongValue]] withCompletionHandler:^(BOOL isUpdationCompleted) {
                                        --totalCount;
                                        if(totalCount<=0){
                                            [self saveMainAndPrivateContextWithPrivateContext:privateManagedObjectContext withNotify:YES withCompletionHandler:^(BOOL isInsertionCompleted) {
                                                completionHandler(TRUE);
                                            }];
                                        }
                                    }];
                                }
                            }];
                        }
                        else{
                            [MyQuestions updateLastUpdatedTimeOfQuestion:[[answerDictionary objectForKey:kQuestionIdKey] longLongValue] withTime:[APP_Utilities returnDateFromTimeStamp:[[answerDictionary objectForKey:kAnswerCreatedTimestampKey] longLongValue]] withCompletionHandler:^(BOOL isUpdationCompleted) {
                                --totalCount;
                                if(totalCount<=0){
                                    [self saveMainAndPrivateContextWithPrivateContext:privateManagedObjectContext withNotify:YES withCompletionHandler:^(BOOL isInsertionCompleted) {
                                        completionHandler(TRUE);
                                    }];
                                }
                            }];
                        }
                        
                        
                    }
                    else{
                        [self deleteAnswerByAnswerId:[[answerDictionary objectForKey:kAnswerIdKey] longLongValue] withCompletionHandler:^(BOOL isDeletionCompleted) {
                            --totalCount;
                            if(totalCount<=0){
                                [self saveMainAndPrivateContextWithPrivateContext:privateManagedObjectContext withNotify:YES withCompletionHandler:^(BOOL isInsertionCompleted) {
                                    completionHandler(TRUE);
                                }];
                            }
                        }];
                    }
                    
                }
            }
            
            
        }
        else{
            completionHandler(TRUE);
        }
    }];
    
}

+(NSArray *)getAllAnswers{
    
    NSManagedObjectContext *managedObjectContext = [APP_DELEGATE.store childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Answers" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSError *error = nil;
    
    NSArray *answersArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (answersArray) {
        
        return answersArray;
    }else{
        return nil;
    }
}

+(MyAnswers *)getOldestAnswerTimestampForQuestion:(long long int)questionID{
    
    NSManagedObjectContext *managedObjectContext = [APP_DELEGATE.store childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Answers" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSSortDescriptor *serverTimeSorting = [[NSSortDescriptor alloc] initWithKey:@"createdTime" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:serverTimeSorting]];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(questionId==%@)",[NSNumber numberWithLongLong:questionID]];
    
    [request setPredicate:predicateObj];
    
    NSError *error = nil;
    
    NSArray *answersArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (answersArray) {
        
        return [answersArray firstObject];
    }else{
        return 0;
    }
}

+(MyAnswers *)getLatestAnswerTimestampForQuestion:(long long int)questionID{
    
    NSManagedObjectContext *managedObjectContext = [APP_DELEGATE.store childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Answers" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSSortDescriptor *serverTimeSorting = [[NSSortDescriptor alloc] initWithKey:@"createdTime" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:serverTimeSorting]];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(questionId==%@)", [NSNumber numberWithLongLong:questionID]];
    
    [request setPredicate:predicateObj];
    
    NSError *error = nil;
    
    NSArray *answersArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (answersArray) {
        
        return [answersArray firstObject];
    }else{
        return nil;
    }
}

+(void) markAllAsnwersAsReadForQuestionID:(long long int)questionID withInsertionCompletionHandler:(BackgroundThreadCompletionHandler)completionHandler{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    [privateManagedObjectContext performBlock:^{
        
        NSArray *answers = [self getAllAnswerForQuestionWithQuestionID:questionID];
        
        for (MyAnswers *answerObj in answers) {
            
            answerObj.isRead = [NSNumber numberWithBool:YES];
            
        }
        
        NSError *error = nil;
        
        if (privateManagedObjectContext != nil) {
            if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                //abort();
            }
            else{
                // Saving data on parent context and then informing back
                [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                    if(completionHandler){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completionHandler(TRUE);
                        });
                    }
                }];
                
            }
        }
        
    }];
    
}


+(void) markAnswerAsReadWithAnswerID:(long long int)answerID  withCompletionHandler:(BackgroundThreadCompletionHandler)completionHandler{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    [privateManagedObjectContext performBlock:^{
        
        MyAnswers *toBeUpdatedAnswer = [self getAnswerByAnswerID:answerID];
        
        [toBeUpdatedAnswer setIsRead:[NSNumber numberWithInt:1]];
        
        __block NSError *error = nil;
        
        
        if (privateManagedObjectContext != nil) {
            if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                //abort();
            }
            else{
                // Saving data on parent context and then informing back
                [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                    if(completionHandler){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completionHandler(TRUE);
                        });
                    }
                }];
                
            }
        }
    }];
    
}

+(BOOL)getIsFetchingAnswers
{
   return isfetchingQnAFromServer;
}
+(void)setIsFetchingAnswers:(BOOL)value
{
    isfetchingQnAFromServer = value;
}

@end
