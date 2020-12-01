//
//  PostAnswerApiClass.h
//  Woo_v2
//
//  Created by Akhil Singh on 21/06/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PostAnswerApiCompletionBlock)(BOOL, id);

@interface PostAnswerApiClass : NSObject

+(void)postAnswerForQuestionID:(NSInteger)questionID andAnswer:(NSString *)answerText withCompletionBlock:(PostAnswerApiCompletionBlock)block;
@end
