//
//  LoginErrorFeedbackViewController.m
//  Woo_v2
//
//  Created by Deepak Gupta on 6/9/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "LoginErrorFeedbackViewController.h"
#import "IQKeyboardManager.h"
#import "LoginErrorFeedbackAPIClass.h"
@interface LoginErrorFeedbackViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation LoginErrorFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:FALSE];
    
    isDefaultText = YES;
    
    if(_isShownForAgeLimit){
        
//        wooUserID = [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId];
        
        [[Utilities sharedUtility] deleteAccount_Temp:^(BOOL isDeauthenticationCompleted) {
            // Logging out the user in age case so that user will be a fresh user
        }];
        
    }
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    textViewObj.textContainerInset = UIEdgeInsetsZero;
    
    btnSend.layer.cornerRadius = btnSend.frame.size.height/2;
    [btnSend.layer setMasksToBounds:YES];
    
    if (_isShownForAgeLimit){
        _descriptionLabel.text = @"You are out of our permissible age range.\nIn case you entered your age wrong, please write to us for assistance.";
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
    
    
    if (![APP_Utilities reachable]){
        
        [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];

        
    }
    
}


- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


#pragma mark - ******************* Button Clicked Method *********************************

-(IBAction)sendButtonClicked:(id)sender{
    
    if (![APP_Utilities reachable]){
        
        [APP_Utilities addingNoInternetSnackBarWithText:NSLocalizedString(@"No internet connection", @"No internet connection") withActionTitle:@"" withDuration:3.0];
        return;
    }
    
    NSString *strFeedback = textViewObj.text;
    strFeedback = [strFeedback stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    strFeedback = [strFeedback stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([strFeedback length] <= 0) {
        return;
    }
    
    
    // Set
    NSDate *myDate = [NSDate date];
   // NSTimeInterval myDateTimeInterval = [myDate timeIntervalSince1970];
    if (!_isShownForAgeLimit){
    [[NSUserDefaults standardUserDefaults] setObject:myDate forKey:kLoginErrorFeedbackTimeStamp];
    }
    
    
    [LoginErrorFeedbackAPIClass submitFeedbackForLoginError:strFeedback withCompletionBlock:^(id response, BOOL success) {
        NSLog(@"Login Error Feedback Response : %@",response);
    }];

    
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(LoginErroFeedbackDelegate)]) {
        
        [self.delegate gettingResponseFromLoginErrorFeebackWithLoginErrorReference:self];
    }

    
    
}

#pragma mark - keyboard movements
- (void)keyboardWillShow:(NSNotification *)notification
{
    
    
    [self.view layoutIfNeeded];
    
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    _bottomViewBottomConstraint.constant = -keyboardSize.height;
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    
    [self.view layoutIfNeeded];
    
    _bottomViewBottomConstraint.constant = 0;
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    
}







#pragma mark -------------- UITextView Delegate ---------------

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if (isDefaultText) {
        
        isDefaultText = NO;
        
        textView.textColor = [UIColor colorWithRed:114.0/255.0 green:119.0/255.0 blue:138.0/255.0 alpha:1.0];
        [textView setText:@""];
    }
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    NSLog(@"TEXT VALUE shouldChangeTextInRange= %@",textView.text);

    
//    if([text isEqualToString:@"\n"])
//        [textView resignFirstResponder];
    
    
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    
    NSLog(@"TEXT VALUE textViewDidChange= %@",textView.text);

    
    if ([textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0){
        btnSend.enabled = TRUE;
        [btnSend setBackgroundColor:kRedThemeV3];
        isDefaultText = NO;
        textView.textColor = [UIColor colorWithRed:114.0/255.0 green:119.0/255.0 blue:138.0/255.0 alpha:1.0];
        
    }
    else{
        
        btnSend.enabled = FALSE;
        [btnSend setBackgroundColor:[UIColor colorWithRed:193.0/255.0 green:193.0/255.0 blue:193.0/255.0 alpha:1.0]];
        isDefaultText = YES;
        
        textView.textColor = [UIColor colorWithRed:55.0/255.0 green:58.0/255.0 blue:67.0/255.0 alpha:0.3];
        
    }
    
    
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    
    NSLog(@"TEXT VALUE textViewDidEndEditing= %@",textView.text);
    
    if ([textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0){
        
        btnSend.enabled = TRUE;
        [btnSend setBackgroundColor:kRedThemeV3];
        isDefaultText = NO;
        textView.textColor = [UIColor colorWithRed:114.0/255.0 green:119.0/255.0 blue:138.0/255.0 alpha:1.0];
    }else{
        
        btnSend.enabled = FALSE;
        [btnSend setBackgroundColor:[UIColor colorWithRed:193.0/255.0 green:193.0/255.0 blue:193.0/255.0 alpha:1.0]];
        isDefaultText = YES;
        
        textView.textColor = [UIColor colorWithRed:55.0/255.0 green:58.0/255.0 blue:67.0/255.0 alpha:0.3];

    }
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];//
    if (isDefaultText) {
        textViewObj.text = NSLocalizedString(@"You can contact us here...", @"contact");

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
