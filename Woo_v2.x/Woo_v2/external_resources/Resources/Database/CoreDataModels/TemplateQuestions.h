//
//  TemplateQuestions.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 27/06/15.
//  Copyright (c) 2015 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TemplateQuestions : NSManagedObject

@property (nonatomic, retain) NSNumber * qid;
@property (nonatomic, retain) NSString * templateQuestion;


+(NSMutableArray *)getAllTemplateQuestions;
+(void)insertUpdateTemplateQuestionsFromArray:(NSArray *)questionsArray;
+(void)removeAllSavedQuestionsWithCompletionHandler:(BackgroundThreadCompletionHandler)backgroundCompletionHandler;
+(void)removeQuestionWithQuestionID:(long long int)questionID;
@end
