//
//  LoginLoadingViewController.m
//  Woo_v2
//
//  Created by Deepak Gupta on 6/14/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "LoginLoadingViewController.h"
#import "LogInAPIClass.h"
#import "NoInternetScreenView.h"
@interface LoginLoadingViewController ()

@end

@implementation LoginLoadingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
 if (![APP_Utilities reachable]){
        [self performSelector:@selector(addingWooLoader) withObject:nil afterDelay:0.1];

        [self performSelector:@selector(loadingThirdScreenWhenNoInternet) withObject:nil afterDelay:0.2];
        //    [self loadingThirdScreenWhenNoInternet];
        
    }else{

            [self performSelector:@selector(addingWooLoader) withObject:nil afterDelay:0.2];
            NSLog(@"%@ %@", _TruecallerParameters, _loginVia);
            [self makeLoginCallToServerWithUserId:_fbId withAccessToken:_accessToken withLocation:_location withTrueCallerParameters:_TruecallerParameters type:_loginVia];
    }
}


-(void)animateImages
{
    //return the animation after it is moved
   
    [UIView transitionWithView:self.view
                      duration:4.0f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        NSLog(@"calling loading view controller");
                    } completion:^(BOOL finished) {
                        [self animateImages];
                    }];
}

#pragma mark - Adding Woo Loader
- (void)addingWooLoader{
    
    if (customLoader) {
        return;
    }
    CGRect frameForLoader = self.view.bounds;
    frameForLoader.size.width = self.view.bounds.size.width;
    frameForLoader.size.height = viewLoader.bounds.size.height;

    if (!customLoader)
        customLoader = [[WooLoader alloc]initWithFrame:frameForLoader];
    
    customLoader.shouldShowWooLoader = YES;
    
    [viewLoader addSubview:customLoader];
    
    NSDictionary *viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:customLoader,@"customLoader",nil];
  //@{@"customLoader":customLoader};
    NSArray *constraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[customLoader]-0-|" options:0 metrics:nil views:viewsDictionary];
    NSArray *constraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[customLoader]-0-|" options:0 metrics:nil views:viewsDictionary];
    
    [viewLoader addConstraints:constraint_POS_V];
    [viewLoader addConstraints:constraint_POS_H];
    
    [customLoader startAnimationOnView:viewLoader WithBackGround:NO];
    customLoader.shouldShowWooLoader = true;
    [customLoader customLoadingText:NSLocalizedString(@"Setting up Woo for you", @"Setting up Woo for you")];
    
}


-(void)makeLoginCallToServerWithUserId:(NSString *)fbId
                       withAccessToken:(NSString *)accessToken
                          withLocation:(CLLocation *)location withTrueCallerParameters:(id)parameters type:(NSString *)loginType{
    
    [customLoader customLoadingText:NSLocalizedString(@"Setting up Woo for you", @"Setting up Woo for you")];

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLoginErrorFeedbackTimeStamp];

    [self startTimerForShowingSecondScreen];
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:kWooUserId] != nil){
        [LogInAPIClass makeRegistrationCallwithCompletionBlock:^(BOOL success, id response, int statusCode , BOOL userChanged) {
            
            [self performAfterSuccessLoginResponse:response andSuccess:success andStatusCode:statusCode andUserChanged:userChanged withAccessToken:accessToken];
        }];
    }
    else{
    NSLog(@"%@ %@", parameters, loginType);
    [LogInAPIClass makeLoginCallToServerWithUserId:fbId withAccessToken:accessToken withLocation:location withAge:nil withGender:nil viaLogin:loginType AnyTRUECALLERdata:parameters withCompletionBlock:^(BOOL success, id response, int statusCode , BOOL userChanged) {
        [self performAfterSuccessLoginResponse:response andSuccess:success andStatusCode:statusCode andUserChanged:userChanged withAccessToken:accessToken];
    }];
    }
}

- (void)performAfterSuccessLoginResponse:(id)loginResponse andSuccess:(BOOL)success andStatusCode:(int)statusCode andUserChanged:(BOOL)userChanged withAccessToken:(NSString *)accessToken{
    
    [self resetScreen];
    
    NSLog(@"STATUS CODE LOGIN API = %d",statusCode);
    NSLog(@"RESPONSE LOGIN API = %@",loginResponse);
    
    if (statusCode == 408 || statusCode == 0){  //            Request Timeout
        [self loadingThirdScreenWhenNoInternet];
        return ;
    }
    else if (statusCode == 401){
        
        [self.delegate gettingResponseFromLoginAPI:success withResponse:loginResponse withStatusCode:statusCode withAccessToken:accessToken withLoginLoadingReference:self withUserChangedStatus:userChanged];
        
        return ;
        
    }else if (statusCode == 501 || statusCode == 416){
        [self.delegate gettingResponseFromLoginAPI:success withResponse:loginResponse withStatusCode:statusCode withAccessToken:accessToken withLoginLoadingReference:self withUserChangedStatus:userChanged];
        return ;
    }
    
    if (success){
        
        [APP_DELEGATE logEventOnFacebook:@"Logged_in_Sucessfully"];
        [APP_DELEGATE sendFirebaseEvent:@"login" andScreen:@""];
        [APP_DELEGATE logEventOnFacebook:@"login"];
        [APP_DELEGATE connectToFCM];
        
        if (![[[NSUserDefaults standardUserDefaults] objectForKey:KAPNS_PERMISSION] boolValue]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KAPNS_PERMISSION];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [APP_Utilities getPushNotificationPermission];
        }
        
        if (self.delegate && [self.delegate conformsToProtocol:@protocol(LoginLoadingDelegate)]) {
            APP_DELEGATE.onBaordingPageNumber = ON_BOARDING_PAGE_NUMBER_NONE;
            APP_DELEGATE.totalOnboardingPages = 0;
            
            [self calculateTotalNumberOfOnboardingPages:loginResponse];
            
            //[[AppSessionManager sharedManager] makeAppLaunchCallToServer];
            
            if ([[loginResponse objectForKey:@"confirmed"] boolValue] == false){
                if ([[loginResponse objectForKey:@"gender"] isEqualToString:@"FEMALE"]){
                    if ([[loginResponse objectForKey:@"locationFound"] boolValue] == false){
                        [self.delegate gettingResponseFromLoginAPI:success withResponse:loginResponse withStatusCode:statusCode withAccessToken:accessToken withLoginLoadingReference:self withUserChangedStatus:userChanged];
                    }
                    else{
                        [self addOnBoardingNameViewWithName:[loginResponse objectForKey:@"firstName"]];
                        
                        // Delay 2 seconds
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self.delegate gettingResponseFromLoginAPI:success withResponse:loginResponse withStatusCode:statusCode withAccessToken:accessToken withLoginLoadingReference:self withUserChangedStatus:userChanged];
                        });
                    }
                }
                else{
                    [self.delegate gettingResponseFromLoginAPI:success withResponse:loginResponse withStatusCode:statusCode withAccessToken:accessToken withLoginLoadingReference:self withUserChangedStatus:userChanged];
                }
            }
            else{
                [self.delegate gettingResponseFromLoginAPI:success withResponse:loginResponse withStatusCode:statusCode withAccessToken:accessToken withLoginLoadingReference:self withUserChangedStatus:userChanged];
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:0 forKey:kServerTimestampKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }
    }
}

- (void)addOnBoardingNameViewWithName:(NSString *)name{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"FemaleOnboardingNameView"
                                                      owner:self
                                                    options:nil];
    
    FemaleOnboardingNameView* nameView = [nibViews lastObject];
    [nameView setFrame:CGRectMake(0, 50, [UIScreen mainScreen].bounds.size.width, 150)];
    [nameView.nameLabel setText:[NSString stringWithFormat:@"Hi %@!",name]];
    [viewLoader addSubview:nameView];
    [customLoader customLoadingText:NSLocalizedString(@"Let's build your profile", @"Let's build your profile")];
}

#pragma mark - Calculate total number of pages
- (void) calculateTotalNumberOfOnboardingPages:(NSDictionary *)response{
    
    APP_DELEGATE.totalOnboardingPages = 0;
    
    if ([response objectForKey:kIntentDto]) {
        APP_DELEGATE.totalOnboardingPages++;
    }
    
    if (([response objectForKey:kuserRelationshipTagsAvailable] && [[response objectForKey:kuserRelationshipTagsAvailable] boolValue] == false) || ([response objectForKey:kuserLifestyleTagsAvailable] && [[response objectForKey:kuserLifestyleTagsAvailable] boolValue] == false)) {
        APP_DELEGATE.totalOnboardingPages++;
    }

    if ([response objectForKey:kuserOtherTagsAvailable] && [[response objectForKey:kuserOtherTagsAvailable] boolValue] == false) {       //changed condition as if the value is true user should not see the tag screen
        APP_DELEGATE.totalOnboardingPages++;
    }
    
    if ([LoginModel sharedInstance].age == 0 || [[LoginModel sharedInstance].gender isEqualToString:@"UNKNOWN"]) {
        APP_DELEGATE.totalOnboardingPages++;
    }

    if([[LoginModel sharedInstance] personalQuoteText]){
        APP_DELEGATE.totalOnboardingPages++;
    }
    
    if ([LoginModel sharedInstance].profilePicUrl != nil){
        APP_DELEGATE.totalOnboardingPages++;
    }

    NSLog(@"TOTAL NUMBER OF ONBOARDING PAGES %d",APP_DELEGATE.totalOnboardingPages);
    
}

#pragma mark - Showing Second Screen After Time Interval Timer
- (void) startTimerForShowingSecondScreen{

    myTimer = nil;
    myTimer =     [NSTimer scheduledTimerWithTimeInterval:7.0f
                                                   target:self
                                                 selector:@selector(loadingSecondScreenForTakingLongTime)
                                                 userInfo:nil
                                                  repeats:NO];
}


#pragma mark - Loading Second Screen
- (void)loadingSecondScreenForTakingLongTime{
    [self resetScreen];

    [customLoader customLoadingText:@""];

    CGRect frame = viewLoader.frame;
    
    UILabel  *lblTop = [[UILabel alloc] initWithFrame:CGRectMake(20, frame.size.height -100, SCREEN_WIDTH - 40, 150)];
    NSString *moreTimeText = [NSString stringWithFormat:@"%@ \n\n%@",NSLocalizedString(@"This is taking longer than it should be.", @"This is taking longer than it should be."),NSLocalizedString(@"Let's see what we can do about it.", @"Let's see")];
//    lblTop.text = NSLocalizedString(@"This is taking longer than it should be.", @"This is taking longer than it should be.");
    lblTop.text = moreTimeText;
    lblTop.numberOfLines = 0;
    lblTop.tag = 1000;
    lblTop.textAlignment= NSTextAlignmentCenter;
    [lblTop setFont:[UIFont fontWithName:@"Candela-Book" size:18.0f]];
    [self.view addSubview:lblTop];
//    lblTop.backgroundColor = [UIColor redColor];
//    [lblTop sizeToFit];
    
    
//    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 75/2, lblTop.frame.origin.y + lblTop.frame.size.height + 10, 74, 82)];
//    imgView.tag = 1001;
//    [imgView setImage:[UIImage imageNamed:@"ChatBoat"]];
//    [imgView.layer setCornerRadius:75/2];
//    [imgView.layer setMasksToBounds:YES];
//
//    [self.view addSubview:imgView];
    
//    UILabel  *lblBottom = [[UILabel alloc] initWithFrame:CGRectMake(20, imgView.frame.origin.y + imgView.frame.size.height + 5, SCREEN_WIDTH - 25, 50)];
//    lblBottom.tag = 1002;
//    lblBottom.text = NSLocalizedString(@"Let's see what we can do about it.", @"Let's see");
//    lblBottom.textAlignment= NSTextAlignmentCenter;
//    [lblBottom setFont:[UIFont fontWithName:@"Candela-Book" size:18.0f]];
//    [self.view addSubview:lblBottom];
    
    
}


#pragma mark - loading third screen
- (void)loadingThirdScreenWhenNoInternet{
    
    [self resetScreen];
    
    NoInternetScreenView *noInternet = [[NoInternetScreenView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [noInternet setDelegate:self];
    noInternet.tag = 10003;
    [noInternet setShowLoader:YES];
    [self.view addSubview:noInternet];
    
    [customLoader customLoadingText:@"No internet connection"];

}

#pragma mark - Refresh button clicked
- (void)refreshButtonClicked:(UIButton *)sender{
    
    if (![APP_Utilities reachable])
        return;
    
    [self resetScreen];

    
    [self makeLoginCallToServerWithUserId:_fbId withAccessToken:_accessToken withLocation:_location withTrueCallerParameters:_TruecallerParameters type:_loginVia];

}


#pragma mark - Reset Screen to Loading
- (void)resetScreen{
    
    if (myTimer)
        [myTimer invalidate];
    
    
        for (UIView *view in self.view.subviews) {
            if (view.tag >=1000 ) {
                [view removeFromSuperview];
            }
        }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
