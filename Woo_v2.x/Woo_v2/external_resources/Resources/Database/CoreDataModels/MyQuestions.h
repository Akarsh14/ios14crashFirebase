//
//  MyQuestions.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 28/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MyQuestions : NSManagedObject

@property (nonatomic, retain) NSNumber * qid;
@property (nonatomic, retain) NSString * questionText;
@property (nonatomic, retain) NSNumber * totalUnreadAnswers;
@property (nonatomic, retain) NSNumber * totalAnswers;
@property (nonatomic, retain) NSDate * lastUpdateTime;
@property (nonatomic, retain) NSDate * questionCreatedTime;



+(NSMutableArray *)getAllMyQuestions;

+(void)insertUpdateMyQuestionsFromArray:(NSArray *)questionsArray withInsertionCompletionHandler:(InsertionCompletionHandler)completionHandler;

+(MyQuestions *)getQuestionForQuestionID:(long long int)qid;

+(void)removeAllQuestions;

+(void)removeQuestionForQuestionID:(long long int)questionId withDeletionCompletionHandler:(DeletionCompletionHandler)completionHandler;

+(void)decrementUnreadAnswersForQuestionWithQuestionID:(long long int)questionID by:(int )toBeDecremented withCompletionHandler:(BackgroundThreadCompletionHandler)completionHandler;

+(void)incrementUnreadAnswersForQuestionWithQuestionID:(long long int)questionID by:(int )toBeIncremented withCompletionHandler:(BackgroundThreadCompletionHandler)completionHandler;;

+(void)decrementTotalAnswersForQuestionID:(long long int)questionID by:(int )toBeDecremented withCompletionHandler:(BackgroundThreadCompletionHandler)completionHandler;

+(void)incrementTotalAnswersForQuestionWithQuestionID:(long long int)questionID by:(int )toBeIncremented withCompletionHandler:(BackgroundThreadCompletionHandler)completionHandler;

+(int) getTotalUnreadAnswersCount;

+ (void)markAllAnswersReadForQuestionID:(long long int)questionID withInsertionCompletionHandler:(BackgroundThreadCompletionHandler)completionHandler;;

+(void)updateLastUpdatedTimeOfQuestion:(long long int)questionID withTime:(NSDate *)updateTime withCompletionHandler:(UpdationCompletionHandler)completionHandler;

+(void)insertOrUpdateQuestionWithoutModifiyingLastUpdateTime:(NSArray *)questionsArray;

@end
