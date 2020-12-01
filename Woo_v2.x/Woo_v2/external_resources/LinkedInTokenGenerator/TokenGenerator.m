//
//  TokenGenerator.m
//  LinkedinTokenManager
//
//  Created by Vaibhav Gautam on 20/01/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "TokenGenerator.h"

@interface TokenGenerator ()
{
    
    __weak IBOutlet UIActivityIndicatorView *activityIndicator;
    __weak IBOutlet NSLayoutConstraint *viewTopToSafeAreaConstraint;
}
@end

@implementation TokenGenerator

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [activityIndicator startAnimating];
    [[WooScreenManager sharedInstance] hideHomeViewTabBar:YES isAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     [[Utilities sharedUtility]colorStatusBar: discoverColor];
    if(SYSTEM_VERSION_LESS_THAN(@"11.0"))
    {
        viewTopToSafeAreaConstraint.constant = 0;
    }
    else
    {
        viewTopToSafeAreaConstraint.constant = -20.0;
    }
}
-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:YES];
    [self generateAuthCodeFromAPIKey:APP_KEY andSecretKey:APP_SECRET];
}

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)cancelButtonTapped{
    [self.navigationController popViewControllerAnimated:YES];
 //   [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)generateAuthCodeFromAPIKey:(NSString *)apiKey andSecretKey:(NSString *)secretKey{
    
    NSString *urlString = [NSString stringWithFormat:@"https://www.linkedin.com/uas/oauth2/authorization?response_type=code&client_id=%@&scope=%@&state=%@&redirect_uri=%@",apiKey,@"r_fullprofile",STATE,REDIRECT_URI];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [authenticationWebView loadRequest:request];
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    
    NSString *redirectionURL = [NSString stringWithFormat:@"%@",request.URL];
    NSLog(@"req >>>>> %@",request);
    
    
    if ([redirectionURL rangeOfString:@"https://www.linkedin.com/uas/oauth2/authorization"].location != NSNotFound) {
//        this is initial call for generating autharisation code
        
    }else if ([redirectionURL rangeOfString:@"http://linkedin_oauth/success?code"].location != NSNotFound){
        
//        this is call for exchanging authorisation code for access token

        
        if ([redirectionURL rangeOfString:@"http://linkedin_oauth/success"].location != NSNotFound) {
            
            NSArray *parameters = [[request.URL query] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"=&"]];
            
            NSMutableDictionary *keyValueParam = [NSMutableDictionary dictionary];
            
            for (int i = 0; i < [parameters count]; i=i+2) {
                [keyValueParam setObject:[parameters objectAtIndex:i+1] forKey:[parameters objectAtIndex:i]];
            }
            
            [self generateAccessTokenFromAccessCode:[keyValueParam objectForKey:@"code"] apiKey:APP_KEY andSecretKey:APP_SECRET];
            
        }

        
    }else if ([redirectionURL rangeOfString:@"https://www.linkedin.com/uas/oauth2/accessToken"].location != NSNotFound){
//        here the access token is generated
        
    }
    else if ([redirectionURL rangeOfString:@"http://linkedin_oauth/success?error=access_denied"].location != NSNotFound){
        //        here the access token is generated
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    
    return YES;
}

-(void)generateAccessTokenFromAccessCode:(NSString *)accessCode apiKey:(NSString *)apiKey andSecretKey:(NSString *)secretKey{
    
    NSString *urlString = [NSString stringWithFormat:@"https://www.linkedin.com/uas/oauth2/accessToken?grant_type=authorization_code&code=%@&redirect_uri=%@&client_id=%@&client_secret=%@",accessCode,REDIRECT_URI,apiKey,secretKey];
    
    
    NSError *error;
    
    NSString *page = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString]
                                              encoding:NSASCIIStringEncoding
                                                 error:&error];

    NSMutableDictionary *dataDictionary = (NSMutableDictionary *)page;
    
    if (!error) {
        if ([_delegate respondsToSelector:_successSelectorForTokenGenerated]) {
            [_delegate performSelector:_successSelectorForTokenGenerated withObject:dataDictionary];
        }
    }else{
        if ([_delegate respondsToSelector:_failureSelectorForTokenGenerated]) {
            [_delegate performSelector:_failureSelectorForTokenGenerated withObject:error];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [activityIndicator stopAnimating];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nonnull NSError *)error
{
    [activityIndicator stopAnimating];
}

@end
