//
//  QuestionAnswerAPIClass.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 12/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "QuestionAnswerAPIClass.h"
#import "Woo_v2-Swift.h"

@implementation QuestionAnswerAPIClass


//MARK:-New Implementation


+(void)updateQuestion:(NSNumber *)OldquestionID withNew:(NSNumber *)newQuestionID withText:(NSString *)answerText andCompletionBlock:(QuestionPostCompletion)resultBlock{
    NSDictionary *params = @{
                             @"oldQuestionId":OldquestionID,
                             @"newQuestionId":newQuestionID,
                             @"answerTxt":[[APP_Utilities validString:answerText] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                             };
    
    NSString *postQuestionURL = [NSString stringWithFormat:@"%@%@wooId=%@",kBaseURLV1,kqnaReplaceQuestion,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager setRequestSerializer:requestSerializer];
    [manager POST:postQuestionURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableDictionary *response = [responseObject mutableCopy];
        resultBlock(YES, response, 200);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        resultBlock(NO, nil, 422);
    } caching:GET_DATA_FROM_URL_ONLY andNumberOfRetries:3];
}

+(void)updateAnswer:(NSNumber *)answerId withText:(NSString *)answerText andCompletionBlock:(QuestionPostCompletion)resultBlock{
    NSDictionary *params = @{
                             @"answerId":answerId,
                             @"answerTxt":[[APP_Utilities validString:answerText] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                             };
    
    NSString *postQuestionURL = [NSString stringWithFormat:@"%@%@wooId=%@",kBaseURLV1,kqnaUpdateAnswer,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager setRequestSerializer:requestSerializer];
    [manager POST:postQuestionURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableDictionary *response = [responseObject mutableCopy];
        resultBlock(YES, response, 200);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        resultBlock(NO, nil, 422);
    } caching:GET_DATA_FROM_URL_ONLY andNumberOfRetries:3];
}

+(void)postAnswer:(NSNumber *)questionID withText:(NSString *)answerText andCompletionBlock:(QuestionPostCompletion)resultBlock{
    NSDictionary *params = @{
                                       @"questionId":questionID,
                                       @"answerTxt":[[APP_Utilities validString:answerText] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                       };
    NSString *postQuestionURL = [NSString stringWithFormat:@"%@%@wooId=%@",kBaseURLV1,kqnaPostAnswer,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager setRequestSerializer:requestSerializer];
    [manager POST:postQuestionURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
       NSMutableDictionary *response = [responseObject mutableCopy];
            resultBlock(YES, response, 200);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        resultBlock(NO, nil, 422);
     } caching:GET_DATA_FROM_URL_ONLY andNumberOfRetries:3];
}


//MARK: - Old Implementation

+(void)postQuestionForWooID:(NSString *)wooID withText:(NSString *)questionText preselectedQuestionID:(NSString *)selectedQuestionID andCompletionBlock:(QuestionPostCompletion)resultBlock{
    NSDictionary *params;
    if (selectedQuestionID.length > 0) {
        
        params = @{@"wooId":[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],
                   @"question":[[APP_Utilities validString:questionText] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                   @"templateQuestionId":selectedQuestionID,
                   @"guid":[NSString stringWithFormat:@"%lld",CURRENT_TIMESTAMP_IN_LONG_MILLI]
                   };
    }else{
        params = @{@"wooId":[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],
                   @"question": [APP_Utilities validString:questionText],
                   @"guid":[NSString stringWithFormat:@"%lld",CURRENT_TIMESTAMP_IN_LONG_MILLI]
                   };
    }
    
    
    NSString *postQuestionURL = [NSString stringWithFormat:@"%@%@",kBaseURLV1,kPostQuestion];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [manager setRequestSerializer:requestSerializer];
    [manager  POST:postQuestionURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSMutableDictionary *response = [responseObject mutableCopy];
        
        
        if ([response objectForKey:kGenericAttributeKey] && [[response objectForKey:kGenericAttributeKey] objectForKey:@"QA_QN_ASKED_TODAY"]) {
            
            [AppLaunchModel sharedInstance].questionsAskedToday = [[[response objectForKey:kGenericAttributeKey] objectForKey:@"QA_QN_ASKED_TODAY"] integerValue];
        }
        
        if ([response objectForKey:kGenericAttributeKey] && [[response objectForKey:kGenericAttributeKey] objectForKey:@"QA_QN_MAX_LIMIT"]) {
            
            [AppLaunchModel sharedInstance].qaQuestionLimit = [[[response objectForKey:kGenericAttributeKey] objectForKey:@"QA_QN_MAX_LIMIT"] integerValue];
        }
        
       // NSInteger remainingItem = [AppLaunchModel sharedInstance].qaQuestionLimit - [AppLaunchModel sharedInstance].questionsAskedToday;
        
        [MyQuestions insertUpdateMyQuestionsFromArray:[NSArray arrayWithObjects:(NSDictionary *)response, nil] withInsertionCompletionHandler:^(BOOL isCompleted) {
            
            resultBlock(YES, response, 200);

            dispatch_async(dispatch_get_main_queue(), ^{
                            [[WooScreenManager sharedInstance].oHomeViewController checkAndshowUnreadBadgeOnAboutMeIcon];
            });
            
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"error >>> %@",error);
        
        
    } caching:GET_DATA_FROM_URL_ONLY andNumberOfRetries:3];
}


+(void)deleteQuestionWithQuestionID:(NSString *)questionID withDeletionCompletionHandler:(DeletionCompletionHandler)completionHandler{
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] || [[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue] <= 0) {
        return;
    }
    
    NSString *deleteQuestionURL = [NSString stringWithFormat:@"%@%@%@/activity?delete=1&wooId=%lld",kBaseURLV1,kQuestion,questionID,[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue]];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =deleteQuestionURL;
    wooRequestObj.time =0;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = deleteQuestion;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        if (success){
            
            [AppLaunchModel sharedInstance].questionsAskedToday = [AppLaunchModel sharedInstance].questionsAskedToday - 1;

            [MyQuestions removeQuestionForQuestionID:[questionID longLongValue] withDeletionCompletionHandler:^(BOOL isDeletionCompleted) {
                completionHandler(TRUE);
            }];
        }
        
    } shouldReachServerThroughQueue:TRUE];
    
}

+(void)deleteAnswerForAnswerObject:(MyAnswers *)answerObj withCompletionHandler:(BackgroundThreadCompletionHandler)completionHandler
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] || [[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue] <= 0) {
        return;
    }
    
    MyAnswers *answer = (MyAnswers *)answerObj;
    NSString *deleteAnswerURL = [NSString stringWithFormat:@"%@%@%lld/activity?status=2&wooId=%lld",kBaseURLV3,kAnswers,[answer.answerId longLongValue],[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue]];
    
    if (!answer.isRead) {
        [MyQuestions decrementUnreadAnswersForQuestionWithQuestionID:[answerObj.questionId longLongValue] by:1 withCompletionHandler:^(BOOL isCompleted) {
            [MyQuestions decrementTotalAnswersForQuestionID:[answerObj.questionId longLongValue] by:1 withCompletionHandler:^(BOOL isCompleted) {
                [QuestionAnswerAPIClass markAnswerAsDeleted:answerObj withAnswerURL:deleteAnswerURL withCompletionHandler:completionHandler];
            }];
        }];
    }else{
        [MyQuestions decrementTotalAnswersForQuestionID:[answerObj.questionId longLongValue] by:1 withCompletionHandler:^(BOOL isCompleted) {
               [QuestionAnswerAPIClass markAnswerAsDeleted:answerObj withAnswerURL:deleteAnswerURL withCompletionHandler:completionHandler];
        }];
    }
}

+(void)markAnswerAsDeleted:(MyAnswers*)answerObj withAnswerURL:(NSString*)deleteAnswerURL withCompletionHandler:(BackgroundThreadCompletionHandler)completionHandler{
    [MyAnswers deleteAnswerByAnswerId:[answerObj.answerId longLongValue] withCompletionHandler:^(BOOL isDeletionCompleted) {
        
        WooRequest *wooRequestObj = [[WooRequest alloc]init];
        wooRequestObj.url =deleteAnswerURL;
        wooRequestObj.time =0;
        wooRequestObj.requestParams =nil;
        wooRequestObj.methodType = postRequest;
        wooRequestObj.numberOfRetries =3;
        wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
        wooRequestObj.requestType = markAsnwerAsDeleted;
        
        [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
            
            if (success && requestType == markAsnwerAsDeleted) {
                completionHandler(TRUE);
            }
        } shouldReachServerThroughQueue:TRUE];

    }];
}

+ (void)getLatestAnswersForQuestionObject:(MyQuestions *)questionObject andCompletionBlock:(QuestionPostCompletion)resultBlock{
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] || [[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue] <= 0) {
        return;
    }

    MyAnswers *oldestAnswer = [MyAnswers getLatestAnswerTimestampForQuestion:[questionObject.qid longLongValue]];
    
    NSString *fetchAnswersURL = [NSString stringWithFormat:@"%@%@%lld?wooId=%lld&createdTime=%lld",kBaseURLV1,kAnswers,[questionObject.qid longLongValue],[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue], ((long long)[oldestAnswer.createdTime timeIntervalSince1970]*1000)];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =fetchAnswersURL;
    wooRequestObj.time =0;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType = getRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = fetchOlderAnswers;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
    

        if (success && requestType == fetchOlderAnswers) {
            
            [MyAnswers insertOrUpdateAnswersFromAnswerArray:[response objectForKey:@"listAnswerDto"] isFetchingNewAnswers:FALSE withCompletionHandler:^(BOOL isInsertionCompleted) {
                resultBlock(success, response, statusCode);
            }];
        }
    } shouldReachServerThroughQueue:TRUE];

}

+ (void)likeAAnswerForAnswerObject:(NSNumber*)answerId andCompletionBlock:(QuestionPostCompletion)resultBlock{
    if(answerId.intValue > 0){
        if (![[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] || [[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue] <= 0) {
            return;
        }
        
        [APP_DELEGATE sendSwrveEventWithEvent:@"Answers.LikeAnswer" andScreen:@"Answers"];
        [APP_DELEGATE sendEventToGoogleAnalyticsForEvent:@"LikeAnswer" forScreenName:@"Answer"];
        NSString *likeAnswerURL = [NSString stringWithFormat:@"%@/answers/%lld/activity?wooId=%@&readActivity=%@&status=%@",kBaseURLV3,[answerId longLongValue],[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],@"1",@"1"];
        
        WooRequest *wooRequestObj = [[WooRequest alloc]init];
        wooRequestObj.url =likeAnswerURL;
        wooRequestObj.time =0;
        wooRequestObj.requestParams =nil;
        wooRequestObj.methodType =postRequest;
        wooRequestObj.numberOfRetries =3;
        wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
        wooRequestObj.requestType = likeOrDislikeAProfile;
        
        [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
            if (statusCode==200) {
                // save data in local database
                [APP_DELEGATE makeAppsflyerFirstMatchCall];
                
        
                
                [APP_Utilities deleteMatchUserFromAppExceptMatchBox:[NSString stringWithFormat:@"%lld",[answerId longLongValue]] shouldDeleteFromAnswer:YES withCompletionHandler:^(BOOL isDeletionCompleted) {

                    resultBlock(success, response, statusCode);
                    
                }];
            }
        } shouldReachServerThroughQueue:TRUE];
    }
}


+ (void) getAllAnswersForQuestion:(MyQuestions *)questionObj andCompletionBlock:(QuestionPostCompletion )resultBlock{
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] || [[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue] <= 0) {
        return;
    }
    
    NSString *fetchAnswerURL = [NSString stringWithFormat:@"%@%@%lld?wooId=%lld",kBaseURLV2,kAnswers,[questionObj.qid longLongValue],[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue]];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =fetchAnswerURL;
    wooRequestObj.time =0;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType = getRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = fetchOlderAnswers;
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
                
        if (success && requestType == fetchOlderAnswers) {
            
            [MyAnswers insertOrUpdateAnswersFromAnswerArray:[response objectForKey:@"listAnswerDto"] isFetchingNewAnswers:FALSE withCompletionHandler:^(BOOL isInsertionCompleted)
            {
                resultBlock(success, response, statusCode);
            }];
            
        }
    } shouldReachServerThroughQueue:TRUE];
}

@end
