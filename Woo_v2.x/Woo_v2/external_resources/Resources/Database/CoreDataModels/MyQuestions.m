//
//  MyQuestions.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 28/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "MyQuestions.h"
#import "MyAnswers.h"

@implementation MyQuestions

@dynamic qid;
@dynamic questionText;
@dynamic totalUnreadAnswers;
@dynamic totalAnswers;
@dynamic lastUpdateTime;
@dynamic questionCreatedTime;


+(NSMutableArray *)getAllMyQuestions{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MyQuestions" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSSortDescriptor *serverTimeSorting = [[NSSortDescriptor alloc] initWithKey:@"lastUpdateTime" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:serverTimeSorting]];
    
    NSArray *questionsArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    if ([questionsArray count]>0) {
        return (NSMutableArray *) questionsArray;
    }else{
        return nil;
    }

}


+(void)insertUpdateMyQuestionsFromArray:(NSArray *)questionsArray withInsertionCompletionHandler:(InsertionCompletionHandler)completionHandler{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    
        [privateManagedObjectContext performBlock:^{
            
            if (questionsArray && [questionsArray count] > 0 ) {
                
                for (NSDictionary *questionDict in questionsArray) {
                    
                    if ([questionDict objectForKey:kQuestionIDKey] && [questionDict objectForKey:kQuestionIDKey] !=[NSNull null]) {
                        
                        MyQuestions *questionObj = [self getQuestionForQuestionID:[[questionDict objectForKey:kQuestionIDKey] longLongValue]];
                        
                        if (!questionObj) {
                            questionObj = (MyQuestions *)[NSEntityDescription insertNewObjectForEntityForName:@"MyQuestions" inManagedObjectContext:privateManagedObjectContext];
                        }
                        
                        [questionObj setQid:[NSNumber numberWithLongLong:[[questionDict objectForKey:kQuestionIDKey] longLongValue]]];
                        
                        if ([questionDict objectForKey:kQuestionTextKey] && [[APP_Utilities validString:[questionDict objectForKey:kQuestionTextKey]] length] > 0) {
                            
                            NSString *decodedString = [APP_Utilities getURLDecodedStringFromString:[questionDict objectForKey:kQuestionTextKey]];
                            
                            [questionObj setQuestionText:decodedString];
                        }else{
                            [questionObj setQuestionText:@""];
                        }
                        NSString *serverCreatedTime = [questionDict objectForKey:@"createdTime"];
                        long long int serverTimeInMilliSecs = [serverCreatedTime longLongValue];
                        NSDate *dateToBeStoredInDb = [NSDate dateWithTimeIntervalSince1970:serverTimeInMilliSecs/1000];
                        
                        [questionObj setQuestionCreatedTime:dateToBeStoredInDb];
                        if (questionObj.lastUpdateTime != nil) {
                            if ([dateToBeStoredInDb compare:questionObj.lastUpdateTime] == NSOrderedDescending ) {
                                [questionObj setLastUpdateTime:dateToBeStoredInDb];
                            }
                        }
                        else{
                            [questionObj setLastUpdateTime:dateToBeStoredInDb];
                        }
                        //                [questionObj setLastUpdateTime:[NSDate date]];
                        
                        [questionObj setTotalAnswers:[NSNumber numberWithLongLong:[[questionDict objectForKey:kQuestionTotalAnswers] longLongValue]]];
                        
                        [questionObj setTotalUnreadAnswers:[NSNumber numberWithLongLong:[[questionDict objectForKey:kQuestionUnreadAnswerCount] longLongValue]]];
                        
                    }
                }
                
                
                
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
                                completionHandler(TRUE);
                            });
                            
                        }];
                        
                    }
                }
                
                /*****************************************************************************/
            }else{
                completionHandler(TRUE);
            }
            
        }];
    
}


+(MyQuestions *)getQuestionForQuestionID:(long long int)questionId{
    
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MyQuestions" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(qid==%@)", [NSNumber numberWithLongLong:questionId]];
    
    [request setPredicate:predicateObj];
    
    NSError *error = nil;
    
    NSArray *selectedQuestionsArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    MyQuestions *questionObject = nil;
    if (selectedQuestionsArray && [selectedQuestionsArray count]>0) {
        questionObject = (MyQuestions *)[selectedQuestionsArray objectAtIndex:0];
    }
    return questionObject;
}


+(void)removeAllQuestions{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    
        [privateManagedObjectContext performBlock:^{
            
            NSArray *allQuestionsArray = [self getAllMyQuestions];
            
            if (allQuestionsArray && [allQuestionsArray count]>0) {
                for (MyQuestions *question in allQuestionsArray) {
                    [privateManagedObjectContext deleteObject:question];
                }
                
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
                            
                            
                        }];
                        
                    }
                }
                
                /*****************************************************************************/
            }
            
        }];
    
}


+(void)removeQuestionForQuestionID:(long long int)questionId withDeletionCompletionHandler:(DeletionCompletionHandler)completionHandler{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    
        [privateManagedObjectContext performBlock:^{
            
            MyQuestions *ToBeDeletedQuestion = [self getQuestionForQuestionID:questionId];
            
            if (ToBeDeletedQuestion) {
                
                [privateManagedObjectContext deleteObject:ToBeDeletedQuestion];
                
                
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
                                [[NSNotificationCenter defaultCenter] postNotificationName:kMatchDeletedByNotification object:nil];
                                if(completionHandler){
                                        completionHandler(TRUE);
                                }
                            });
                            
                        }];
                        
                    }
                }
                
                /*****************************************************************************/
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kMatchDeletedByNotification object:nil];
                    if(completionHandler){
                        completionHandler(TRUE);
                    }
                });

            }
            
        }];
}


+(void)decrementUnreadAnswersForQuestionWithQuestionID:(long long int)questionID by:(int )toBeDecremented withCompletionHandler:(BackgroundThreadCompletionHandler)completionHandler{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    
        [privateManagedObjectContext performBlock:^{
            
            MyQuestions *toBeUpdatedQuestion = [self getQuestionForQuestionID:questionID];
            
            if (toBeUpdatedQuestion && toBeUpdatedQuestion.totalUnreadAnswers.intValue > 0) {
                int unread = [toBeUpdatedQuestion.totalUnreadAnswers intValue];
                
                unread = unread - toBeDecremented;
                if (unread < 0) {
                    unread = 0;
                }
                [toBeUpdatedQuestion setTotalUnreadAnswers:[NSNumber numberWithInt:unread]];
                
                
                
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
                                    completionHandler(TRUE);
                            });
                        }];
                        
                    }
                }
                
                /*****************************************************************************/
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(TRUE);
                });
            }
            
        }];
}


+(void)decrementTotalAnswersForQuestionID:(long long int)questionID by:(int )toBeDecremented withCompletionHandler:(BackgroundThreadCompletionHandler)completionHandler{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
  
        [privateManagedObjectContext performBlock:^{
            
            MyQuestions *toBeUpdatedQuestion = [self getQuestionForQuestionID:questionID];
            
            if (toBeUpdatedQuestion && toBeUpdatedQuestion.totalAnswers.intValue > 0) {
                int totalAnswers = [toBeUpdatedQuestion.totalAnswers intValue];
                
                totalAnswers = totalAnswers - toBeDecremented;
                if (totalAnswers < 0) {
                    totalAnswers = 0;
                }
                [toBeUpdatedQuestion setTotalAnswers:[NSNumber numberWithInt:totalAnswers]];
                
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
                                completionHandler(TRUE);
                            });
                        }];
                        
                    }
                }
                
                /*****************************************************************************/
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(TRUE);
                });
            }
            
        }];
    
}

+(void)incrementUnreadAnswersForQuestionWithQuestionID:(long long int)questionID by:(int )toBeIncremented withCompletionHandler:(BackgroundThreadCompletionHandler)completionHandler{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    
        [privateManagedObjectContext performBlock:^{
            
            MyQuestions *toBeUpdatedQuestion = [self getQuestionForQuestionID:questionID];
            
            int unread = [toBeUpdatedQuestion.totalUnreadAnswers intValue];
            
            unread = unread + toBeIncremented;
            
            [toBeUpdatedQuestion setTotalUnreadAnswers:[NSNumber numberWithInt:unread]];
            
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
                            completionHandler(TRUE);
                        });
                    }];
                    
                }
            }
            
            /*****************************************************************************/
            
        }];
}

+(void)incrementTotalAnswersForQuestionWithQuestionID:(long long int)questionID by:(int )toBeIncremented withCompletionHandler:(BackgroundThreadCompletionHandler)completionHandler{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    
        [privateManagedObjectContext performBlock:^{
            
            MyQuestions *toBeUpdatedQuestion = [self getQuestionForQuestionID:questionID];
            
            int answers = [toBeUpdatedQuestion.totalAnswers intValue];
            
            answers = answers + toBeIncremented;
            
            [toBeUpdatedQuestion setTotalAnswers:[NSNumber numberWithInt:answers]];
            
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
                            completionHandler(TRUE);
                        });
                        
                    }];
                    
                }
            }
            
            /*****************************************************************************/
            
        }];

}

+(int) getTotalUnreadAnswersCount{
    NSMutableArray *totalQuestionsAvailable = [self getAllMyQuestions];
    
    if (totalQuestionsAvailable && [totalQuestionsAvailable count] <1) {
        return 0;
    }
    
    int totalUnread = 0;
    
    for (MyQuestions *questionObj in totalQuestionsAvailable) {
        //added condition  to check if object exists and if object exists does the attribute exists. Condition to fix issue #478 in crashalytics
        if (questionObj && questionObj.totalUnreadAnswers) {
            totalUnread = totalUnread + [questionObj.totalUnreadAnswers intValue];
        }
        
        
    }
    return totalUnread;
}

+ (void)markAllAnswersReadForQuestionID:(long long int)questionID withInsertionCompletionHandler:(BackgroundThreadCompletionHandler)completionHandler{
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    
        [privateManagedObjectContext performBlock:^{
            
            MyQuestions *questionObj = [MyQuestions getQuestionForQuestionID:questionID];
            questionObj.totalUnreadAnswers = [NSNumber numberWithInt:0];
            
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
            
        }];
}

+(void)updateLastUpdatedTimeOfQuestion:(long long int)questionID withTime:(NSDate *)updateTime withCompletionHandler:(UpdationCompletionHandler)completionHandler{
    MyQuestions *toBeUpdatedQuestion = [self getQuestionForQuestionID:questionID];
    if ([updateTime compare:toBeUpdatedQuestion.lastUpdateTime] == NSOrderedDescending) {
        NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
        
        __block NSError *error = nil;

            [privateManagedObjectContext performBlock:^{
                
                [toBeUpdatedQuestion setLastUpdateTime:updateTime];

                /***************************Save Context*************************************/
                
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
                                completionHandler(TRUE);
                            });
                        }];
                        
                    }
                
                /*****************************************************************************/
                
            }];
            
    }
    else
    {
        completionHandler(TRUE);
    }
}

+(void)insertOrUpdateQuestionWithoutModifiyingLastUpdateTime:(NSArray *)questionsArray{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    
        [privateManagedObjectContext performBlock:^{
            
            if (questionsArray && [questionsArray count] > 0 ) {
                
                for (NSDictionary *questionDict in questionsArray) {
                    
                    if ([questionDict objectForKey:kQuestionIDKey] && [questionDict objectForKey:kQuestionIDKey] !=[NSNull null]) {
                        
                        MyQuestions *questionObj = [self getQuestionForQuestionID:[[questionDict objectForKey:kQuestionIDKey] longLongValue]];
                        
                        // BOOL isQuestionNew = FALSE;
                        
                        if (!questionObj) {
                            questionObj = (MyQuestions *)[NSEntityDescription insertNewObjectForEntityForName:@"MyQuestions" inManagedObjectContext:privateManagedObjectContext];
                            //isQuestionNew = TRUE;
                        }
                        
                        [questionObj setQid:[NSNumber numberWithLongLong:[[questionDict objectForKey:kQuestionIDKey] longLongValue]]];
                        
                        if ([questionDict objectForKey:kQuestionTextKey] && [[APP_Utilities validString:[questionDict objectForKey:kQuestionTextKey]] length] > 0) {
                            NSString *decodedString = [APP_Utilities decodeFromPercentEscapingString:[questionDict objectForKey:kQuestionTextKey]];
                            
                            [questionObj setQuestionText:[decodedString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                        }else{
                            [questionObj setQuestionText:@""];
                        }
                        NSString *serverCreatedTime = [questionDict objectForKey:@"createdTime"];
                        long long int serverTimeInMilliSecs = [serverCreatedTime longLongValue];
                        NSDate *dateToBeStoredInDb = [NSDate dateWithTimeIntervalSince1970:serverTimeInMilliSecs/1000];
                        
                        [questionObj setQuestionCreatedTime:dateToBeStoredInDb];
                        
                        //condition to check if question is newly created, than update the last update time else not.
                        NSArray *answerArray = [MyAnswers getAllAnswerForQuestionWithQuestionID:[[questionDict objectForKey:kQuestionIDKey] longLongValue]];
                        
                        if (!answerArray || [answerArray count]<1) {
                            [questionObj setLastUpdateTime:questionObj.questionCreatedTime];
                        }
                        else{
                            MyAnswers *latestAnswerObj = [MyAnswers getLatestAnswerTimestampForQuestion:[[questionDict objectForKey:kQuestionIDKey] longLongValue]];
                            [questionObj setLastUpdateTime:latestAnswerObj.createdTime];
                            
                        }
                        
                        
                        [questionObj setTotalAnswers:[NSNumber numberWithLongLong:[[questionDict objectForKey:kQuestionTotalAnswers] longLongValue]]];
                        
                        [questionObj setTotalUnreadAnswers:[NSNumber numberWithLongLong:[[questionDict objectForKey:kQuestionUnreadAnswerCount] longLongValue]]];
                        
                    }
                }
            }
            
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
                        
                        
                    }];
                    
                }
            }
            
            /*****************************************************************************/
            
        }];

}
@end
