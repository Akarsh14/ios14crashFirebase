//
//  IFTTTBaseController.h
//  Woo
//
//  Created by Umesh Mishra on 13/03/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "ChatRoom.h"
#import "MDToast.h"
#import <JazzHands/IFTTTJazzHands.h>

@interface IFTTTBaseController : IFTTTAnimatedPagingScrollViewController{
    NSString *baseClassVariable;
    UIActivityIndicatorView *activityIndicatorObj;
//    ChatRoom *chatRoomObj;
}


-(void)baseClassMethod;
-(void)showActivityIndicatorViewInCenter:(BOOL)showInCenter;
-(void)hideActivityIndcatorView;

-(void)handleErrorForResponseCode:(int)responseCode;
-(void)disableRightPanel;
-(void)enableRightPanel;

-(void)logoutUser;
-(void)showLoginScreen;
//-(void)showPayWall;

-(void)logoutWithoutRaisingAnyNotificaiton;

//-(void)reinitialiseUserDefaultAndDatabase;
@end
