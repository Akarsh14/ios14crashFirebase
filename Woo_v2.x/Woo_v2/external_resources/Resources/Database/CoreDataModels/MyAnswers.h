//
//  Answers.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 06/07/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MyQuestions.h"

static BOOL isfetchingQnAFromServer = false;

@interface MyAnswers : NSManagedObject

@property (nonatomic, retain) NSNumber * answerId;
@property (nonatomic, retain) NSNumber * questionId;
@property (nonatomic, retain) NSNumber * wooId;
@property (nonatomic, retain) NSString * answerDescription;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * userImageURL;
@property (nonatomic, retain) NSNumber * userAge;
@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSDate * createdTime;

/*
 
 "createdTime": 1435826257000,
 "status": 4,
 "strStatus": "MATCH_AFTER_ANSWERED",
 "read": true

 
 */

+(void)updateAnswerData:(NSDictionary *)answerDict ForWooId:(NSString*)wooId;

+(NSArray *)getAllAnswerForQuestionWithQuestionID:(long long int)questionID;

+(NSArray *)getAllAnswerByUserID:(long long int)userId;

+(MyAnswers *)getAnswerByAnswerID:(long long int )answerID;

+(void)deleteAllAnswersByUserWithUserID:(long long int)userID withCompletionHandler:(DeletionCompletionHandler)completionHandler;

+(void)deleteAnswerByAnswerId:(long long int)AnswerId withCompletionHandler:(DeletionCompletionHandler)completionHandler;

+(void)deleteAllAnswerForQuestionWithQuestionID:(long long int)questionID;

+(MyAnswers *)getOldestAnswerTimestampForQuestion:(long long int)questionID;

+(void) markAnswerAsReadWithAnswerID:(long long int)answerID withCompletionHandler:(BackgroundThreadCompletionHandler)completionHandler;

+(void) markAllAsnwersAsReadForQuestionID:(long long int)questionID withInsertionCompletionHandler:(BackgroundThreadCompletionHandler)completionHandler;

+(MyAnswers *)getLatestAnswerTimestampForQuestion:(long long int)questionID;

+(void)deleteAllAnswersByUserWithUserID_Str:(NSString *)userID withCompletionHandler:(DeletionCompletionHandler)completionHandler;;

+(void)insertOrUpdateAnswersFromAnswerArray:(NSArray *)answersArray isFetchingNewAnswers:(BOOL)isFetchingNewAnswers withCompletionHandler:(InsertionCompletionHandler __nullable)completionHandler;

+(BOOL)getIsFetchingAnswers;
+(void)setIsFetchingAnswers:(BOOL)value;
@end
