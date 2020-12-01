//
//  QuestionAnswerAPIClass.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 12/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyQuestions.h"
#import "MyAnswers.h"


typedef void (^QuestionPostCompletion)(BOOL success, id responseObj, int errorNumber);

//typedef void (^ActivateBoostCompletionBlock)(BOOL success, id responseObj, int statusCode);


@interface QuestionAnswerAPIClass : NSObject

+(void)updateAnswer:(NSNumber *)answerId withText:(NSString *)answerText andCompletionBlock:(QuestionPostCompletion)resultBlock;
+(void)updateQuestion:(NSNumber *)OldquestionID withNew:(NSNumber *)newQuestionID withText:(NSString *)answerText andCompletionBlock:(QuestionPostCompletion)resultBlock;
+(void)postAnswer:(NSNumber *)questionID withText:(NSString *)answerText andCompletionBlock:(QuestionPostCompletion)resultBlock;



+(void)postQuestionForWooID:(NSString *)wooID withText:(NSString *)questionText preselectedQuestionID:(NSString *)selectedQuestionID andCompletionBlock:(QuestionPostCompletion)resultBlock;

+(void)deleteQuestionWithQuestionID:(NSString *)questionID withDeletionCompletionHandler:(DeletionCompletionHandler)completionHandler;

+(void)deleteAnswerForAnswerObject:(MyAnswers *)answerObj withCompletionHandler:(BackgroundThreadCompletionHandler)completionHandler;

+ (void)getLatestAnswersForQuestionObject:(MyQuestions *)questionObject andCompletionBlock:(QuestionPostCompletion)resultBlock;

//+ (void)likeAAnswerForAnswerObject:(MyAnswers *)answerObj andCompletionBlock:(QuestionPostCompletion)resultBlock;
+ (void)likeAAnswerForAnswerObject:(NSNumber*)answerId andCompletionBlock:(QuestionPostCompletion)resultBlock;
+ (void) getAllAnswersForQuestion:(MyQuestions *)questionObj andCompletionBlock:(QuestionPostCompletion )resultBlock;

@end
