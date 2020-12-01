//
//  TokenGenerator.h
//  LinkedinTokenManager
//
//  Created by Vaibhav Gautam on 20/01/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>


#define REDIRECT_URI @"http://linkedin_oauth/success"
#define STATE @"AwesomenssAtItsBest"
#define APP_KEY @"75pdh3jgop8je3"
#define APP_SECRET @"E964Cqe7NgGeUPbf"


@interface TokenGenerator : UIViewController<UIWebViewDelegate>{
    
    __weak IBOutlet UIWebView *authenticationWebView;
    
    NSMutableData *responseData;
}

-(void)generateAuthCodeFromAPIKey:(NSString *)apiKey andSecretKey:(NSString *)secretKey;
-(void)generateAccessTokenFromAccessCode:(NSString *)accessCode apiKey:(NSString *)apiKey andSecretKey:(NSString *)secretKey;


@property(nonatomic)id delegate;
@property(nonatomic, assign)SEL successSelectorForTokenGenerated;
@property(nonatomic, assign)SEL failureSelectorForTokenGenerated;

@end
