//
//  TemplateQuestions.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 27/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import "TemplateQuestions.h"


@implementation TemplateQuestions

@dynamic qid;
@dynamic templateQuestion;



+(NSMutableArray *)getAllTemplateQuestions{
    
    NSError *error = nil;
    
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"TemplateQuestions" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSArray *notificationsArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    return (NSMutableArray*) ([notificationsArray count]>0 ? notificationsArray : nil );
}


+(void)insertUpdateTemplateQuestionsFromArray:(NSArray *)questionsArray{
    
    NSManagedObjectContext *privateManagedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    
        [privateManagedObjectContext performBlock:^{
            
            if (questionsArray && [questionsArray count] > 0 ) {
                
                [self removeAllSavedQuestionsWithCompletionHandler:^(BOOL isCompleted) {
                    
                    for (NSDictionary *questionDict in questionsArray) {
                        
                        if ([questionDict objectForKey:kQuestionIDKey] && [questionDict objectForKey:kQuestionIDKey] !=[NSNull null]) {
                            
                            TemplateQuestions *questionObj = [self getQuestionForQuestionID:[[questionDict objectForKey:kQuestionIDKey] longLongValue]];
                            
                            if (!questionObj) {
                                questionObj = (TemplateQuestions *)[NSEntityDescription insertNewObjectForEntityForName:@"TemplateQuestions" inManagedObjectContext:privateManagedObjectContext];
                                
                            }
                            
                            [questionObj setQid:[NSNumber numberWithLongLong:[[questionDict objectForKey:kQuestionIDKey] longLongValue]]];
                            
                            if ([questionDict objectForKey:kQuestionTextKey] && [[APP_Utilities validString:[questionDict objectForKey:kQuestionTextKey]] length] > 0) {
                                [questionObj setTemplateQuestion:[questionDict objectForKey:kQuestionTextKey]];
                            }else{
                                [questionObj setTemplateQuestion:@""];
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
                                
                                // Do Nothing
                                
                            }];
                            
                        }
                    }
                    
                    /*****************************************************************************/
                }];
                
            }

            
        }];
}


+(TemplateQuestions *)getQuestionForQuestionID:(long long int)qid{
    
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"TemplateQuestions" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicateObj = [NSPredicate predicateWithFormat:@"(qid==%@)", [NSNumber numberWithLongLong:qid]];
    
    [request setPredicate:predicateObj];
    
    NSError *error = nil;

    NSArray *selectedQuestionsArray;

    selectedQuestionsArray = [managedObjectContext executeFetchRequest:request error:&error];

    TemplateQuestions *questionObject = nil;
    if (selectedQuestionsArray && [selectedQuestionsArray count]>0) {
        questionObject = (TemplateQuestions *)[selectedQuestionsArray lastObject];
    }
    return questionObject;
}


+(void)removeQuestionWithQuestionID:(long long int)questionID{
    
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    NSError *error = nil;
    
//    [privateManagedObjectContext performBlock:^{
    
        TemplateQuestions *ToBeDeletedQuestion = [self getQuestionForQuestionID:questionID];
        
        if (ToBeDeletedQuestion) {
            [managedObjectContext deleteObject:ToBeDeletedQuestion];
            if(![managedObjectContext save:&error])
            {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            }
            else
            {
                NSLog(@"Deleted Question successfully");

            }
            
        }
        /*
        **************************Save Context************************************
        
        if (privateManagedObjectContext != nil) {
            if ([privateManagedObjectContext hasChanges] && ![privateManagedObjectContext save:&error]) {
                 Replace this implementation with code to handle the error appropriately.
                 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
            else{
                 Saving data on parent context and then informing back
                [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kMatchDeletedByNotification object:nil];

                }];
                
            }
        }
        
        ***************************************************************************
        
    }];
    */


}


+(void)removeAllSavedQuestionsWithCompletionHandler:(BackgroundThreadCompletionHandler)backgroundCompletionHandler{
    NSManagedObjectContext *managedObjectContext = [STORE childPrivateManagedObjectContext];
    
    __block NSError *error = nil;
    
    [managedObjectContext performBlock:^{
    
        NSArray *allQuestionsArray = [self getAllTemplateQuestions];
        
        if (allQuestionsArray && [allQuestionsArray count]>0) {
            for (TemplateQuestions *question in [allQuestionsArray mutableCopy]) {
                [managedObjectContext deleteObject:question];
            }
            if(![managedObjectContext save:&error])
            {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            }
            else
            {
                NSLog(@"Deleted Question successfully");
                
            }
        }
        
        /***************************Save Context*************************************/
       
        if (managedObjectContext != nil) {
            if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                //abort();
            }
            else{
                // Saving data on parent context and then informing back
                [STORE saveDataOnParentContextWithHandler:^(BOOL isCompleted) {
                    backgroundCompletionHandler(TRUE);
                    
                }];
                
            }
        }
        
        /*****************************************************************************/
        
    }];

    
}
@end
