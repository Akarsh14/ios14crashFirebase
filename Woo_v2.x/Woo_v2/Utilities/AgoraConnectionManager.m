//
//  AgoraConnectionManager.m
//  Woo_v2
//
//  Created by Ankit Batra on 05/06/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

#import "AgoraConnectionManager.h"
//#import "agorasdk.h"
#import <AgoraAudioKit/AgoraRtcEngineKit.h>
#import <CommonCrypto/CommonDigest.h>
#import <CallKit/CallKit.h>
//#import <AgoraSigKit/AgoraSigKit.h>

//#define KagoraAppId             @"87c1ae4cbb784b4ba8cbd98d386d3e1d"
//#define KagoraAppCertificate    @"baa639a38e78457e819767526959e057"

#define vendorKey @"87c1ae4cbb784b4ba8cbd98d386d3e1d"
#define signkey @"baa639a38e78457e819767526959e057"
#import "demohelp.h"
#import <CommonCrypto/CommonDigest.h>
@import AgoraRtmKit;

@interface AgoraConnectionManager()<AgoraRtcEngineDelegate,CXProviderDelegate,CXCallObserverDelegate,AgoraRtmDelegate,AgoraRtmChannelDelegate,AgoraRtmCallDelegate>
@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,strong)NSTimer *incomingCallTimer;

@property(nonatomic,strong)NSString *ckCallState;
@property(nonatomic)BOOL wasInviteReceivedByPeer;
@property(nonatomic,strong)CXCallObserver *callObserver;

@property(nonatomic,strong) AgoraRtmKit *kit;
@property (atomic, strong, nullable) AgoraRtmCallKit *rtmCallKit;
@property(nonatomic, strong)AgoraRtmChannel *channel;

@property(nonatomic)BOOL wasInviteRefusedByPeer;
@property(nonatomic)BOOL WasCallAnswered;

@end
@implementation AgoraConnectionManager
{
//    AgoraAPI* inst;
    AgoraRtcEngineKit * instMedia;
    AgoraRtmLocalInvitation *localRTMInvitation;
    AgoraRtmRemoteInvitation *remoteRTMInvitation;
    
    BOOL isInCall;
    BOOL isCallHeld;

    BOOL isAudioStreamMuted;
    BOOL isSpeakerOn;

    unsigned my_uid;
    CXProvider *provider;
    CXCallController *callController;
    NSUUID *uuidOfOngoingCall;
    
    //
    unsigned incomingCallerUid;
    NSString *incomingCallerAccount;
    
    NSString *secondIncomingCallChannelId;
    int outGoingInviteDuration;
    int incomingInviteDuration;
    
    NSString *channelIDByAgoraRTM;
    NSString *userIDByAgoraRTM;
    NSString *channelKeyStored;
}

+ (AgoraConnectionManager *)sharedManager {
    static AgoraConnectionManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[super allocWithZone:NULL] init];
    });
    
    return sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
//        inst =  [AgoraAPI getInstanceWithoutMedia:vendorKey];
        NSLog(@"%@",vendorKey);
        //a7985dc5ad6d42448028fd203de9ccb3
        
        _kit = [[AgoraRtmKit alloc] initWithAppId:vendorKey delegate:self];
        _kit.agoraRtmDelegate = self;
        [[_kit getRtmCallKit] setCallDelegate:self];
        instMedia = [AgoraRtcEngineKit sharedEngineWithAppId:vendorKey delegate:self];
        [instMedia muteLocalAudioStream:NO];
        int audioEnabled = [instMedia enableAudio];
        NSLog(@"audioEnabled %d",audioEnabled);
        _isLogin = false;
        isInCall = false;
        isCallHeld = false;
        [self observerChangesForAgoraInstance];
        NSString *localizedName = NSLocalizedString(@"Woo",@"Woo");
        
        CXProviderConfiguration *config = [[CXProviderConfiguration alloc] initWithLocalizedName:localizedName];
        config.supportsVideo = NO;
        config.maximumCallGroups = 1;
        config.ringtoneSound = @"ringtone.mp3";
        config.maximumCallsPerCallGroup = 1;
        config.supportedHandleTypes = [NSSet setWithObject:[NSNumber numberWithInt:1]];
        config.iconTemplateImageData = UIImagePNGRepresentation([UIImage imageNamed:@"AppIcon"]);
        provider = [[CXProvider alloc]initWithConfiguration:config];
        [provider setDelegate:self queue:nil];
        
        callController = [[CXCallController alloc]init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CallStateDidChange:) name:@"CTCallStateDidChange" object:nil];
        _ckCallState = CTCallStateDisconnected;
        
        _callObserver = [[CXCallObserver alloc]init];
        [_callObserver setDelegate:self queue:nil];

    }
    return self;
}

-(unsigned)getIncomingCallUid
{
    return incomingCallerUid;
}
-(NSString *)getIncomingCallerAccount
{
    return incomingCallerAccount;
}


-(void)pingInst
{
//    [inst ping];
}

-(BOOL)getCurrentStateOfCall
{
    return isInCall;
}


- (void)channel:(AgoraRtmChannel *)channel memberLeft:(AgoraRtmMember *)member
{
    NSLog(@"%@ left channel %@", member.userId, member.channelId);
    
    __weak AgoraConnectionManager *weakSelf = self;
    
    if ([weakSelf getCurrentStateOfCall])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"currentCallLeftByPeer" object:nil];
        isInCall = false;
        [[VoiceCallAudioManager sharedInstance] stopPlayingCallerTune];
        if (SYSTEM_VERSION_LESS_THAN(@"11.0")) {
            [[VoiceCallAudioManager sharedInstance] activateAudioSessionWithActivate:NO];
        }
        [weakSelf setWasCallAnswered:NO];
        [weakSelf setWasInviteRefusedByPeer:NO];
        [[weakSelf incomingCallTimer] invalidate];
    }
}


- (void)channel:(AgoraRtmChannel *)channel memberJoined:(AgoraRtmMember *)member
{
    NSLog(@"%@ joined channel %@", member.userId, member.channelId);
    channelIDByAgoraRTM = member.channelId;
    userIDByAgoraRTM = member.userId;
}


- (void)rtmCallKit:(AgoraRtmCallKit *)callKit localInvitationRefused:(AgoraRtmLocalInvitation *)localInvitation withResponse:(NSString *)response{
    
    NSLog(@"local invitation refused");
        __weak AgoraConnectionManager *weakSelf = self;
        [weakSelf setWasInviteRefusedByPeer:YES];
        [weakSelf setDurationInSeconds:[NSNumber numberWithInteger:0]];
        //Show call declined by peer -- will only be received at the outgoing end
        [weakSelf logCallEventForCallWithMatchId:localInvitation.channelId wasCallDeclined:YES wasAnswered:NO];
        [weakSelf.timer invalidate];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"outGoingCallInviteDeclined" object:nil];
        isInCall = false;
        [[VoiceCallAudioManager sharedInstance] stopPlayingCallerTune];
        if (SYSTEM_VERSION_LESS_THAN(@"11.0")) {
            [[VoiceCallAudioManager sharedInstance] activateAudioSessionWithActivate:NO];
        }
        [weakSelf setWasInviteReceivedByPeer:false];
        
}
- (void)rtmCallKit:(AgoraRtmCallKit *)callKit remoteInvitationReceived:(AgoraRtmRemoteInvitation *)remoteInvitation{
    
     __weak AgoraConnectionManager *weakSelf = self;
    
    NSLog(@"remoteInvitationReceived to");
    NSLog(@"onInviteReceived to %@ from:%@", remoteInvitation.channelId, remoteInvitation.callerId);
    
    remoteRTMInvitation = remoteInvitation;
    NSLog(@"ckCallState %@",weakSelf.ckCallState);
    if([weakSelf checkifInviteFromAMatch:remoteInvitation.channelId])
    {
        [weakSelf startTimerForIncomingCall];
        if(![weakSelf getCurrentStateOfCall] && !self.incomingCallChannelId)
        {
            NSLog(@"onInviteReceived isnotincall");
            //will only be received at the incoming end
            incomingCallerUid = (int)remoteInvitation.callerId;
            weakSelf.incomingCallChannelId = remoteInvitation.channelId;
            
            NSLog(@"incomingCallerAccount %@",remoteInvitation.callerId);
            
            incomingCallerAccount = remoteInvitation.callerId;
            if([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
            {
                
                MyMatches *matchObj = [MyMatches getMatchDetailForMatchID:weakSelf.incomingCallChannelId];
                
//                MyMatches *matchDetail  = [MyMatches                    getMatchDetailForMatchedUSerID:remoteRTMInvitation.channelId isApplozic:false];
//
                NSLog(@"matchdetails in foreground %@",matchObj);
                NSLog(@"onInviteReceived isnotincall active");
                // open incoming call screen
                //play ringtone

                [[VoiceCallAudioManager sharedInstance] configureAudioSession];
                [[VoiceCallAudioManager sharedInstance] playRingtone];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[WooScreenManager sharedInstance] openIncomingCallScreenForCallFromUserWithId:(long)remoteInvitation.callerId withMatchDetail:matchObj andChannelId:remoteInvitation.channelId withPresentationCompletion:^(BOOL completed) {
                        
                    }];
                });
            }
            else
            {
                NSLog(@"background vaale state pe ghus rha hai");
                
                if([[Utilities sharedUtility] checkMicrophonePermission] == 1)
                {
                    NSLog(@"Log State %ld",(long)[[UIApplication sharedApplication] applicationState]);
                    NSLog(@" remoteRTMInvitation.channelId %@",remoteRTMInvitation.channelId);
//                    MyMatches *matchDetail  = [MyMatches getMatchDetailForMatchedUSerID:remoteRTMInvitation.channelId isApplozic:false];
                    
                    
                    MyMatches *matchObj = [MyMatches getMatchDetailForMatchID:weakSelf.incomingCallChannelId];
                    
                    NSLog(@" matchDetails hai : %@",matchObj.matchUserName);
                    
                    NSLog(@"reportIncomingCallWithHandle");
                    [weakSelf reportIncomingCallWithHandle:matchObj.matchUserName];
                }
            }
        }
        else
        {
            secondIncomingCallChannelId = remoteInvitation.channelId;
            if([weakSelf getCurrentStateOfCall])
            {
//                [weakSelf sendUserInstantMessageToAccount:userIDByAgoraRTM withUid:(long)remoteInvitation.callerId];
            }
            else
            {
                //decline
//                [weakSelf declineInviteWithChannelId:remoteInvitation.channelId asUserWithAccount:(long)remoteInvitation.callerId];
            }
        }
    }
}

- (void)rtmCallKit:(AgoraRtmCallKit *)callKit localInvitationReceivedByPeer:(AgoraRtmLocalInvitation *)localInvitation{
    
    __weak AgoraConnectionManager *weakSelf = self;
    
    NSLog(@"localInvitationReceivedByPeer");
    NSLog(@"%@",localInvitation.channelId);
    
//    //Call accepted
//    //Now changeState to IN call
//    [weakSelf setWasCallAnswered:YES];
//    [weakSelf.timer invalidate];
//    [weakSelf reportNewOutgoingCall];
////    [[NSNotificationCenter defaultCenter] postNotificationName:@"outGoingCallInviteAccepted" object:nil];
////    isInCall = true;
////    [[VoiceCallAudioManager sharedInstance] stopPlayingCallerTune];
//    [weakSelf setWasInviteReceivedByPeer:false];
//
    [self->instMedia joinChannelByToken:channelKeyStored channelId:localInvitation.channelId info:nil uid:self->my_uid joinSuccess:^(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed) {
        NSLog(@"Joined Channel from localInvitationReceivedByPeer %@ successfully with Uid %lu",channel ,(unsigned long)uid);
    }];
    
}

- (void)rtmCallKit:(AgoraRtmCallKit *)callKit localInvitationAccepted:(AgoraRtmLocalInvitation *)localInvitation withResponse:(NSString *)response{
    
    __weak AgoraConnectionManager *weakSelf = self;
    NSLog(@"localInvitationAccepted to");
    NSLog(@"response is %@", response);
    //Call accepted
    //Now changeState to IN call
    [weakSelf setWasCallAnswered:YES];
    [weakSelf.timer invalidate];
    
    [weakSelf reportNewOutgoingCall];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"outGoingCallInviteAccepted" object:nil];
    isInCall = true;
    [[VoiceCallAudioManager sharedInstance] stopPlayingCallerTune];
    [weakSelf setWasInviteReceivedByPeer:false];
//    [self startTimerForOutgoingCall];
    
    [self->instMedia joinChannelByToken:channelKeyStored channelId:localInvitation.channelId info:nil uid:self->my_uid joinSuccess:^(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed) {
        NSLog(@"Joined Channel localInvitationAccepted %@ successfully with Uid %lu",channel ,(unsigned long)uid);
    }];
}


- (void)rtmCallKit:(AgoraRtmCallKit *)callKit remoteInvitationCanceled:(AgoraRtmRemoteInvitation *)remoteInvitation{
    
    NSLog(@"%@ and %@",remoteInvitation.content,remoteInvitation.callerId);
        __weak AgoraConnectionManager *weakSelf = self;
       NSLog(@"remoteInvitationCanceled");
       [weakSelf setWasInviteReceivedByPeer:false];
    
    NSLog(@"%@",[[AgoraConnectionManager sharedManager] incomingCallChannelId]);
       //If this is of the second
       if([[[AgoraConnectionManager sharedManager] incomingCallChannelId] isEqualToString:remoteInvitation.channelId])
       {
           [weakSelf.timer invalidate];
           weakSelf.incomingCallChannelId = nil;
           //Show call cancelled by peer -- will only be received at the incoming end
           [weakSelf leaveChannelWithId:remoteInvitation.channelId];
           //needed to end when call received is ended befor picked up at lock screen
           dispatch_async(dispatch_get_main_queue(), ^{
               [weakSelf endOngoingCallWithChannelId:remoteInvitation.channelId];
               if (SYSTEM_VERSION_LESS_THAN(@"10.0"))
               {
                   [[UIApplication sharedApplication] cancelAllLocalNotifications];
                   [UIApplication sharedApplication].applicationIconBadgeNumber=0;
                   
               }
           });
           isInCall = false;
           [[NSNotificationCenter defaultCenter] postNotificationName:@"incomingInviteCancelledByPeer" object:nil];
       }
    
}


- (void)rtmCallKit:(AgoraRtmCallKit *)callKit localInvitationCanceled:(AgoraRtmLocalInvitation *)localInvitation{
     __weak AgoraConnectionManager *weakSelf = self;
    
    NSLog(@"onInviteEndByMyself to");
    [weakSelf setDurationInSeconds:[NSNumber numberWithInteger:0]];
    [weakSelf logCallEventForCallWithMatchId:localInvitation.channelId wasCallDeclined:NO wasAnswered:NO];
    [weakSelf.timer invalidate];
    
    [weakSelf leaveChannelWithId:localInvitation.channelId];
    isInCall = false;
    [[VoiceCallAudioManager sharedInstance] stopPlayingCallerTune];
    if (SYSTEM_VERSION_LESS_THAN(@"11.0")) {
        [[VoiceCallAudioManager sharedInstance] activateAudioSessionWithActivate:NO];
    }
    [weakSelf setWasInviteReceivedByPeer:false];
}


- (void)rtmCallKit:(AgoraRtmCallKit *)callKit localInvitationFailure:(AgoraRtmLocalInvitation *)localInvitation errorCode:(AgoraRtmLocalInvitationErrorCode)errorCode{
    
    NSLog(@"local invitation failure %ld", (long)errorCode);
    __weak AgoraConnectionManager *weakSelf = self;
    [weakSelf setDurationInSeconds:[NSNumber numberWithInteger:0]];
        [weakSelf logCallEventForCallWithMatchId:localInvitation.channelId wasCallDeclined:NO wasAnswered:NO];
        [weakSelf.timer invalidate];
        [[VoiceCallAudioManager sharedInstance] stopPlayingCallerTune];
        if (SYSTEM_VERSION_LESS_THAN(@"11.0")) {
            [[VoiceCallAudioManager sharedInstance] activateAudioSessionWithActivate:NO];
        }
//        NSLog(@"Call %@ failed, ecode = %lu", c, (unsigned long)ecode);
        [weakSelf setWasInviteReceivedByPeer:false];
        
        if(errorCode == AgoraRtmLocalInvitationErrorNotLoggedIn)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"outGoingCallInviteFailiure" object:@"Not available"];
            //Not Logged in
            [weakSelf loginToAgora:[[NSUserDefaults standardUserDefaults]objectForKey:kWooUserId] withCompletionHandler:^(BOOL completed)
             {
                 
                 
             }];
            
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"cancelInvite" object:@"Not available"];
            
            // [[NSNotificationCenter defaultCenter] postNotificationName:@"outGoingCallInviteFailiure" object:@"Not available"];
        }
        //show call again popup
        isInCall = false;
    
}

-(void)observerChangesForAgoraInstance
{
    __weak AgoraConnectionManager *weakSelf = self;
   
//    inst.onChannelLeaved = ^(NSString* name, AgoraEcode ecode){
//        if (ecode == AgoraEcode_LEAVECHANNEL_E_BYUSER){
//            NSLog(@"Left channel by current user");
//            //Incoming user leaves channel
//            isInCall = false;
//            weakSelf.incomingCallChannelId = nil;
//            [weakSelf setWasCallAnswered:NO];
//            [weakSelf setWasInviteRefusedByPeer:NO];
//            [[weakSelf incomingCallTimer] invalidate];
//
//        }
//        else{
//
//        }
//        [[VoiceCallAudioManager sharedInstance] stopPlayingCallerTune];
//        if (SYSTEM_VERSION_LESS_THAN(@"11.0")) {
//            [[VoiceCallAudioManager sharedInstance] activateAudioSessionWithActivate:NO];
//        }
//    };
    
    
    [_channel leaveWithCompletion:^(AgoraRtmLeaveChannelErrorCode errorCode) {
        if(errorCode == AgoraRtmLeaveChannelErrorOk) {
            NSLog(@"leave success");
            NSLog(@"Left channel by current user");
            //Incoming user leaves channel
            self->isInCall = false;
            weakSelf.incomingCallChannelId = nil;
            [weakSelf setWasCallAnswered:NO];
            [weakSelf setWasInviteRefusedByPeer:NO];
            [[weakSelf incomingCallTimer] invalidate];
        } else {
            NSLog(@"leave failed: %@", @(errorCode));
        }
        
        [[VoiceCallAudioManager sharedInstance] stopPlayingCallerTune];
        if (SYSTEM_VERSION_LESS_THAN(@"11.0")) {
            [[VoiceCallAudioManager sharedInstance] activateAudioSessionWithActivate:NO];
        }
    }];
    
    
//    inst.onChannelUserLeaved = ^(NSString* account,uint32_t uid)
//    {
//        NSLog(@"Left channel by user");
//        if ([weakSelf getCurrentStateOfCall])
//        {
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"currentCallLeftByPeer" object:nil];
//            isInCall = false;
//            [[VoiceCallAudioManager sharedInstance] stopPlayingCallerTune];
//            if (SYSTEM_VERSION_LESS_THAN(@"11.0")) {
//                [[VoiceCallAudioManager sharedInstance] activateAudioSessionWithActivate:NO];
//            }
//            [weakSelf setWasCallAnswered:NO];
//            [weakSelf setWasInviteRefusedByPeer:NO];
//            [[weakSelf incomingCallTimer] invalidate];
//        }
//
//
//    };
    
    
//    inst.onChannelUserJoined = ^(NSString* account,uint32_t uid)
//    {
//        NSLog(@"Joined channel by user with account : %@ and uid %u",account,uid);
//    };
    
    
//    inst.onInviteReceived = ^(NSString *channelID, NSString *account, uint32_t uid, NSString *extra) {
//        NSLog(@"onInviteReceived to %@ from %@:%u", channelID, account, uid);
//        NSLog(@"ckCallState %@",weakSelf.ckCallState);
//        if([weakSelf checkifInviteFromAMatch:channelID])
//        {
//            [weakSelf startTimerForIncomingCall];
//            if(![weakSelf getCurrentStateOfCall] && !self.incomingCallChannelId)
//            {
//                NSLog(@"onInviteReceived isnotincall");
//                //will only be received at the incoming end
//                self->incomingCallerUid = uid;
//                weakSelf.incomingCallChannelId = channelID;
//                self->incomingCallerAccount = account;
//                if([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
//                {
//                    MyMatches *matchObj = [MyMatches getMatchDetailForMatchID:weakSelf.incomingCallChannelId];
//                    NSLog(@"onInviteReceived isnotincall active");
//                    // open incoming call screen
//                    //play ringtone
//
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [[WooScreenManager sharedInstance] openIncomingCallScreenForCallFromUserWithId:uid withMatchDetail:matchObj andChannelId:channelID withPresentationCompletion:^(BOOL completed) {
//                            [[VoiceCallAudioManager sharedInstance] configureAudioSession];
//                            [[VoiceCallAudioManager sharedInstance] playRingtone];
//
//                        }];
//                    });
//                }
//                else
//                {
//                    if([[Utilities sharedUtility] checkMicrophonePermission] == 1)
//                    {
//                        NSLog(@"Log State %ld",(long)[[UIApplication sharedApplication] applicationState]);
//                        NSLog(@"onInviteReceived isnotincall other states");
//                        MyMatches *matchDetail  = [MyMatches getMatchDetailForMatchedUSerID:account isApplozic:false];
//                        [weakSelf reportIncomingCallWithHandle:matchDetail.matchUserName];
//                    }
//                }
//            }
//            else
//            {
//                self->secondIncomingCallChannelId = channelID;
//                if([weakSelf getCurrentStateOfCall])
//                {
//                    [weakSelf sendUserInstantMessageToAccount:account withUid:uid];
//                }
//                else
//                {
//                    //decline
//                    [weakSelf declineInviteWithChannelId:channelID asUserWithAccount:account];
//                }
//            }
//        }
//    };
    
//    inst.onInviteReceivedByPeer = ^(NSString* channel, NSString *name, uint32_t uid){
//        //will only be received at the outgoing end
//       NSLog(@"Target User ko mil gaya invite \n onInviteReceivedByPeer to %@ from %@:%u", channel, name, uid);
//        [weakSelf setWasInviteReceivedByPeer:true];
//    };
    
//    inst.onInviteAcceptedByPeer = ^(NSString *channelID, NSString *account, uint32_t uid, NSString *extra) {
//        //will only be received at the outgoing end
//        NSLog(@"onInviteAcceptedByPeer to %@ from %@:%u", channelID, account, uid);
//        //Call accepted
//        //Now changeState to IN call
//        [weakSelf setWasCallAnswered:YES];
//        [weakSelf.timer invalidate];
//        [weakSelf reportNewOutgoingCall];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"outGoingCallInviteAccepted" object:nil];
//        isInCall = true;
//        [[VoiceCallAudioManager sharedInstance] stopPlayingCallerTune];
//        [weakSelf setWasInviteReceivedByPeer:false];
//    };
    
//    inst.onInviteRefusedByPeer = ^(NSString *channelID, NSString *account, uint32_t uid, NSString *extra) {
//        NSLog(@"onInviteRefusedByPeer to %@ from %@:%u", channelID, account, uid);
//        [weakSelf setWasInviteRefusedByPeer:YES];
//        [weakSelf setDurationInSeconds:[NSNumber numberWithInteger:0]];
//        //Show call declined by peer -- will only be received at the outgoing end
//        [weakSelf logCallEventForCallWithMatchId:channelID wasCallDeclined:YES wasAnswered:NO];
//        [weakSelf.timer invalidate];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"outGoingCallInviteDeclined" object:nil];
//        isInCall = false;
//        [[VoiceCallAudioManager sharedInstance] stopPlayingCallerTune];
//        if (SYSTEM_VERSION_LESS_THAN(@"11.0")) {
//            [[VoiceCallAudioManager sharedInstance] activateAudioSessionWithActivate:NO];
//        }
//        [weakSelf setWasInviteReceivedByPeer:false];
//
//
//    };
    
//    inst.onInviteEndByPeer = ^(NSString *channelID, NSString *account, uint32_t uid, NSString *extra) {
//        NSLog(@"onInviteEndByPeer to %@ from %@:%u", channelID, account, uid);
//        [weakSelf setWasInviteReceivedByPeer:false];
//
//        //If this is of the second
//        if([[[AgoraConnectionManager sharedManager] incomingCallChannelId] isEqualToString:channelID])
//        {
//            [weakSelf.timer invalidate];
//            weakSelf.incomingCallChannelId = nil;
//            //Show call cancelled by peer -- will only be received at the incoming end
//            [weakSelf leaveChannelWithId:channelID];
//            //needed to end when call received is ended befor picked up at lock screen
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [weakSelf endOngoingCallWithChannelId:channelID];
//                if (SYSTEM_VERSION_LESS_THAN(@"10.0"))
//                {
//                    [[UIApplication sharedApplication] cancelAllLocalNotifications];
//                    [UIApplication sharedApplication].applicationIconBadgeNumber=0;
//
//                }
//            });
//            isInCall = false;
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"incomingInviteCancelledByPeer" object:nil];
//        }
//
//    };
    
//    inst.onInviteEndByMyself = ^(NSString* channel, NSString *name, uint32_t uid){
//        [weakSelf setDurationInSeconds:[NSNumber numberWithInteger:0]];
//        [weakSelf logCallEventForCallWithMatchId:channel wasCallDeclined:NO wasAnswered:NO];
//        [weakSelf.timer invalidate];
//        NSLog(@"onInviteEndByMyself to %@ from %@:%u", channel, name, uid);
//        [weakSelf leaveChannelWithId:channel];
//        isInCall = false;
//        [[VoiceCallAudioManager sharedInstance] stopPlayingCallerTune];
//        if (SYSTEM_VERSION_LESS_THAN(@"11.0")) {
//            [[VoiceCallAudioManager sharedInstance] activateAudioSessionWithActivate:NO];
//        }
//        [weakSelf setWasInviteReceivedByPeer:false];
//
//    };
    
//    inst.onInviteFailed = ^(NSString *channelID, NSString *account, uint32_t uid, AgoraEcode ecode, NSString *extra) {
//        [weakSelf setDurationInSeconds:[NSNumber numberWithInteger:0]];
//        [weakSelf logCallEventForCallWithMatchId:channelID wasCallDeclined:NO wasAnswered:NO];
//        [weakSelf.timer invalidate];
//        [[VoiceCallAudioManager sharedInstance] stopPlayingCallerTune];
//        if (SYSTEM_VERSION_LESS_THAN(@"11.0")) {
//            [[VoiceCallAudioManager sharedInstance] activateAudioSessionWithActivate:NO];
//        }
//        NSLog(@"Call %@ failed, ecode = %lu", account, (unsigned long)ecode);
//        [weakSelf setWasInviteReceivedByPeer:false];
//
//        if(ecode == 1003)
//        {
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"outGoingCallInviteFailiure" object:@"Not available"];
//            //Not Logged in
//            [weakSelf loginToAgora:[[NSUserDefaults standardUserDefaults]objectForKey:kWooUserId] withCompletionHandler:^(BOOL completed)
//             {
//
//
//             }];
//
//        }
//        else if  (ecode == 704)
//            {
//                //timeout
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"cancelInvite" object:@"Not answered"];
//
//                //            [[NSNotificationCenter defaultCenter] postNotificationName:@"outGoingCallInviteFailiure" object:@{@"reason":@"Call not answered"}];
//
//            }
//        else
//        {
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"cancelInvite" object:@"Not available"];
//
//            //            [[NSNotificationCenter defaultCenter] postNotificationName:@"outGoingCallInviteFailiure" object:@"Not available"];
//        }
//        //show call again popup
//        self->isInCall = false;
//
//    };
    
    
//    inst.onMessageChannelReceive = ^(NSString* channelID,NSString* account,uint32_t uid,NSString* msg) {
//
//        NSLog(@"on message received");
//        [weakSelf setWasInviteReceivedByPeer:false];
//        if ([msg isEqualToString:@"11001"])
//        {
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"cancelInvite" object:@"Not answered"];
//        }
//
//    };
    
//    inst.onMessageInstantReceive = ^(NSString *account, uint32_t uid, NSString *msg) {
//        NSLog(@"on onMessage Instant Receive");
//        [weakSelf setWasInviteReceivedByPeer:false];
//        if ([msg isEqualToString:@"11001"])
//        {
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"cancelInvite" object:@"Not answered"];
//        }
//        else
//        {
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"cancelInvite" object:msg];
//
//        }
//    };

}

-(BOOL)checkifInviteFromAMatch:(NSString*)matchId
{
    MyMatches *matchDetail =  [MyMatches getMatchDetailForMatchID:matchId];
    if (matchDetail)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(void)loginToAgora:(NSString *)userId withCompletionHandler:(CompletionBlock)block
{
    __weak AgoraConnectionManager *weakSelf = self;

    [instMedia setParameters:@"{\"rtc.log_filter\":32783}"];
    [instMedia setParameters:@"{\"che.audio.record.signal.volume\":100}"];

    
//    inst.onLoginSuccess = ^(uint32_t uid, int fd){
//        NSLog(@"Logged in with uid %u",uid);
//        my_uid = uid;
//        weakSelf.isLogin = true;
//        [[NSNotificationCenter defaultCenter] postNotificationName:KLoggedInToAgora object:nil];
//        block(true);
//
//    };
    
    
    
   
//    inst.onLoginFailed = ^(AgoraEcode e){
//        weakSelf.isLogin = false;
//        NSLog(@"Login failed, ecode = %lu",(unsigned long)e);
//        if(e == 204 || e == 206)
//        {
//            //get token again from server and login
//            [weakSelf getSignalingKeyFromServerForUserWithWooId:[[NSUserDefaults standardUserDefaults]objectForKey:kWooUserId] andCompletionBlock:^(id response, BOOL completed) {
//               if (completed)
//               {
//                   [weakSelf loginToAgora:[[NSUserDefaults standardUserDefaults]objectForKey:kWooUserId] withCompletionHandler:^(BOOL completed) {
//
//                       block(true);
//
//                   }];
//               }
//            }];
//            //retry login
//        }
//        else if(e == 208)
//        {
//            //already lgin
//            block(true);
//
//        }
//        else
//        {
//            block(false);
//        }
//        self->isInCall = false;
//    };
    
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"agoraRTMToken"]);
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"agoraRTMToken"])
    {
        uint32_t uid = 0;
        [_kit loginByToken:[[NSUserDefaults standardUserDefaults] objectForKey:@"agoraRTMToken"] user:[[NSUserDefaults standardUserDefaults]objectForKey:kWooUserId] completion:^(AgoraRtmLoginErrorCode errorCode) {
            if (errorCode != AgoraRtmLoginErrorOk) {
                if(errorCode == AgoraRtmLoginErrorTokenExpired){
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"agoraRTMToken"];
                    [self loginToAgora:[[NSUserDefaults standardUserDefaults]objectForKey:kWooUserId] withCompletionHandler:^(BOOL completed) {
                        if (completed)
                        {
                            // self reportIncomingCallWithHandle:handle];
                        }
                    }];
                }
                NSLog(@"login failed %@", @(errorCode));
            } else {
                NSLog(@"login success");
                NSLog(@"Logged in with uid %u",uid);
                self->my_uid = uid;
                weakSelf.isLogin = true;
                [[NSNotificationCenter defaultCenter] postNotificationName:KLoggedInToAgora object:nil];
                block(true);
            }
        }];
    }else{
        [self getRTMKeyFromServerForUserWithWooId:[[NSUserDefaults standardUserDefaults]objectForKey:kWooUserId] andCompletionBlock:^(id response, BOOL success)
         {
             uint32_t uid = 0;
             
             [self->_kit loginByToken:[[NSUserDefaults standardUserDefaults] objectForKey:@"agoraRTMToken"] user:[[NSUserDefaults standardUserDefaults]objectForKey:kWooUserId] completion:^(AgoraRtmLoginErrorCode errorCode) {
                 if (errorCode != AgoraRtmLoginErrorOk) {
                     NSLog(@"login failed %@", @(errorCode));
                 } else {
                     NSLog(@"login success");
                     NSLog(@"Logged in with uid %u",uid);
                     self->my_uid = uid;
                     weakSelf.isLogin = true;
                     [[NSNotificationCenter defaultCenter] postNotificationName:KLoggedInToAgora object:nil];
                     block(true);
                 }
             }];
             
             
         }];
    }
    
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"agora_signal_token"])
    {
        uint32_t uid = 0;
//        [inst login2:vendorKey account:userId token:[[NSUserDefaults standardUserDefaults] objectForKey:@"agora_signal_token"] uid:uid deviceID:@"" retry_time_in_s:60 retry_count:5];

        NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"agora_signal_token"]);

//        [_kit loginByToken:nil user:userId completion:^(AgoraRtmLoginErrorCode errorCode) {
//            if (errorCode != AgoraRtmLoginErrorOk) {
//                NSLog(@"login failed %@", @(errorCode));
//            } else {
//                NSLog(@"login success");
//                NSLog(@"Logged in with uid %u",uid);
//                my_uid = uid;
//                weakSelf.isLogin = true;
//                [[NSNotificationCenter defaultCenter] postNotificationName:KLoggedInToAgora object:nil];
//                block(true);
//            }
//        }];

    }
    else
    {
        [self getSignalingKeyFromServerForUserWithWooId:[[NSUserDefaults standardUserDefaults]objectForKey:kWooUserId] andCompletionBlock:^(id response, BOOL success)
         {
             uint32_t uid = 0;
//             [inst login2:vendorKey account:userId token:[[NSUserDefaults standardUserDefaults] objectForKey:@"agora_signal_token"] uid:uid deviceID:@"" retry_time_in_s:5 retry_count:5];


//            [_kit loginByToken:nil user:userId completion:^(AgoraRtmLoginErrorCode errorCode) {
//                if (errorCode != AgoraRtmLoginErrorOk) {
//                    NSLog(@"login failed %@", @(errorCode));
//                } else {
//                    NSLog(@"login success");
//                   NSLog(@"Logged in with uid %u",uid);
//                   my_uid = uid;
//                   weakSelf.isLogin = true;
//                   [[NSNotificationCenter defaultCenter] postNotificationName:KLoggedInToAgora object:nil];
//                   block(true);
//                }
//            }];


         }];
    }
    
}

- (void)rtmKit:(AgoraRtmKit *)kit connectionStateChanged:(AgoraRtmConnectionState)state reason:(AgoraRtmConnectionChangeReason)reason{
    
    NSLog(@"connection state changed to %@", @(reason));
}


-(void)logoutFromAgora:(NSString *)userId withCompletionHandler:(CompletionBlock)block
{
    __weak AgoraConnectionManager *weakSelf = self;
//    inst.onLogout = ^(AgoraEcode e)
//    {
//        if (e == 101 || e == 108 )
//        {
//            weakSelf.isLogin = false;
//            self->isInCall = false;
//            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"agoraRTMToken"];
//            [[NSUserDefaults standardUserDefaults]synchronize];
//            block(true);
//        }
//        else
//        {
//            block(false);
//        }
//    };
    
//    [inst logout];
    
    
    [_kit logoutWithCompletion:^(AgoraRtmLogoutErrorCode errorCode) {
        if (errorCode != AgoraRtmLogoutErrorOk) {
            NSLog(@"logout failed %@", @(errorCode));
            block(false);
        } else {
            NSLog(@"logout success");
            
            weakSelf.isLogin = false;
            self->isInCall = false;
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"agoraRTMToken"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            block(true);
        }
    }];
}

-(void)startTimerForIncomingCall
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self->incomingInviteDuration = 0;
        self.incomingCallTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkTimerAndEndIncomingCall) userInfo:nil repeats:YES];
    });
  
    
}

-(void)checkTimerAndEndIncomingCall
{
    incomingInviteDuration += 1;
    //shouldnot be in call or shouldnot have incoming call
    NSLog(@"checkTimerAndEndIncomingCall %d",incomingInviteDuration);

    if((!isInCall && incomingInviteDuration>=30) || (self.incomingCallChannelId != nil && incomingInviteDuration>=30))
    {
        NSLog(@"checkTimerAndEndIncomingCall");
        [self endIncomingCall];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"incomingInviteCancelledByPeer" object:nil];
            
    }
}

-(void)endIncomingCall
{
    [self.incomingCallTimer invalidate];
    [[VoiceCallAudioManager sharedInstance] stopRingtone];
    //Show call cancelled by peer -- will only be received at the incoming end
    [self leaveChannelWithId:self.incomingCallChannelId];
    self.incomingCallChannelId = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self endOngoingCallWithChannelId:self.incomingCallChannelId];
        
        if (SYSTEM_VERSION_LESS_THAN(@"10.0"))
        {
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            [UIApplication sharedApplication].applicationIconBadgeNumber=0;
            
        }
    });
    isInCall = false;

}
-(void)startTimerForOutgoingCall
{
    outGoingInviteDuration = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkTimerAndCancelInvite) userInfo:nil repeats:YES];

}

-(void)checkTimerAndCancelInvite
{
    outGoingInviteDuration += 1;
    if(!isInCall && outGoingInviteDuration >=35)
    {
        //cancel invite
        if([self wasInviteReceivedByPeer])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"cancelInvite" object:@"Not answered"];
         }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"cancelInvite" object:@"Not available"];

        }
        [self.timer invalidate];

    }
}

-(void)getSignalingKeyFromServerForUserWithWooId:(NSString*)wooId andCompletionBlock:(ApiCompletionBlock)block{
    
    NSString *getIdentifyTokenForNonce = [NSString stringWithFormat:@"%@%@?wooId=%@&nonce=%@&onlyAgoraKey=%u",kBaseURLV1,kAuthenticateLayerWithServerAPI,wooId,@"",YES];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =getIdentifyTokenForNonce;
    wooRequestObj.time =0;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = authenticateLayerWithServer;
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        if (success)
        {
            if ([response objectForKey:@"agora_signal_token"] && [[APP_Utilities validString:[response objectForKey:@"agora_signal_token"]] length] >0)
            {
                
                [[NSUserDefaults standardUserDefaults] setObject: [response objectForKey:@"agora_signal_token"] forKey:@"agora_signal_token"];
                [[NSUserDefaults standardUserDefaults] setObject: [NSDate date] forKey:@"agora_signal_token_timestamp"];
                
                [[NSUserDefaults standardUserDefaults]synchronize];
                if (block)
                {
                    block(response, YES);
                }
            }
            
            
        }
        else{
                if (block) {
                    block(error, NO);
                }
            }
    } shouldReachServerThroughQueue:YES];
}


-(void)getRTMKeyFromServerForUserWithWooId:(NSString*)wooId andCompletionBlock:(ApiCompletionBlock)block{
    
    NSString *getIdentifyTokenForNonce = [NSString stringWithFormat:@"%@/generate/agora/rtmToken?wooId=%@",kBaseURLV1,wooId];
    NSLog(@"%@",getIdentifyTokenForNonce);
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =getIdentifyTokenForNonce;
    wooRequestObj.time =0;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries =3;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        
        NSLog(@"%@",response);
        if (success)
        {
            if ([response objectForKey:@"agoraRTMToken"] && [[APP_Utilities validString:[response objectForKey:@"agoraRTMToken"]] length] >0)
            {
                
                [[NSUserDefaults standardUserDefaults] setObject: [response objectForKey:@"agoraRTMToken"] forKey:@"agoraRTMToken"];
                
                [[NSUserDefaults standardUserDefaults]synchronize];
                if (block)
                {
                    block(response, YES);
                }
            }
            
            
        }
        else{
            if (block) {
                block(error, NO);
            }
        }
    } shouldReachServerThroughQueue:YES];
}



-(void)getChannelKeyForMatchId:(NSString *)matchid andCompletionBlock:(ApiCompletionBlock)block
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@?match_id=%@&agora_user_id=%@",kBaseURLV1, kGetChannelKeyForCall, matchid,[NSString stringWithFormat:@"%u",my_uid]];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =urlString;
    NSLog(@"getChannelKeyForMatchId urlString :%@",urlString);
    wooRequestObj.time =900;
//    wooRequestObj.requestParams = bodyParamDict;
    wooRequestObj.methodType =getRequest;
    wooRequestObj.numberOfRetries = 0;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = getChannelKeyFromSever;
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        NSLog(@"response :%@",response);

        if (success)
        {
            block(response,YES);
        }
        else{
            block(error,NO);

        }
    } shouldReachServerThroughQueue:YES];
}


-(void)pushVoIPAPNFromActorWith:(NSString *)actorWooId toTargetWithTargetId:(NSString*)targetWooId andCompletionBlock:(ApiCompletionBlock)block
{
    MyMatches *match = [MyMatches getMatchDetailForMatchedUSerID:targetWooId isApplozic:false];
    
    //{{test}}/woo/api/v1/send/voip/push/apns?actorWooId=4489006&targetWooId=4489006&alert=Hii Calling
    //new api - 13-11-2017 /send/voip/push
    //NSString *urlString = [NSString stringWithFormat:@"%@%@?wooId=%@&targetWooId=%@&alert=%@",kBaseURLV1,kSendVoipPushApn, actorWooId,targetWooId,[NSString stringWithFormat:@"VoiceCallFrom%@",match.matchUserName]];
    NSString *urlString = [NSString stringWithFormat:@"%@%@?wooId=%@&targetWooId=%@&alert=Hi",kBaseURLV1,kSendVoipPushApn, actorWooId,targetWooId];
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url = urlString;
    NSLog(@"pushVoIPAPNFromActorWith urlString :%@",urlString);
    wooRequestObj.time = 900;
    wooRequestObj.requestParams =nil;
    wooRequestObj.methodType = postRequest;
    wooRequestObj.numberOfRetries = 0;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = pushVoIPAPN;
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        if (success)
        {
            block(response,YES);
        }
        else{
            block(error,NO);
        }
    } shouldReachServerThroughQueue:YES];
}



-(void)joinChannelWithKey:(NSString *)channelKey andMatchId:(NSString *)matchId
{
    
    _channel = [_kit createChannelWithId:matchId delegate:self];
    
    localRTMInvitation = [[AgoraRtmLocalInvitation alloc] initWithCalleeId:[[NSUserDefaults standardUserDefaults]objectForKey:kWooUserId]];
    NSLog(@"local rtm invitation ka object create ho gya hai");
    
    channelKeyStored = channelKey;
    
    [_channel joinWithCompletion:^(AgoraRtmJoinChannelErrorCode errorCode) {
        
        if(errorCode == 102){
            [self loginToAgora:[[NSUserDefaults standardUserDefaults]objectForKey:kWooUserId] withCompletionHandler:^(BOOL completed) {
                if (completed)
                {
                    // self reportIncomingCallWithHandle:handle];
                }
            }];
        }
        
        if(errorCode == AgoraRtmLoginErrorOk){
            NSLog(@"joinWithCompletion successfully AgoraRtmLoginErrorOk");
        }
        
        if(errorCode == AgoraRtmLoginErrorTokenExpired){
            NSLog(@"joinWithCompletion successfully AgoraRtmLoginErrorTokenExpired");
        }
        
        if(errorCode == AgoraRtmLoginErrorTimeout){
            NSLog(@"joinWithCompletion successfully AgoraRtmLoginErrorTimeout");
        }
        
        NSLog(@"joinWithCompletion successfully %ld", (long)errorCode);
        
    }];
    
}



-(void)leaveChannelWithId:(NSString *)channelId;
{
//    [inst channelLeave:channelId];
    [_channel leaveWithCompletion:^(AgoraRtmLeaveChannelErrorCode errorCode) {
        //Do nothing
        NSLog(@"leave channel error: %ld", (long)errorCode);
    }];
    [instMedia leaveChannel:nil];
}

-(void)inviteUserWithAccount:(NSString *)account andChannelId:(NSString *)channelId andHandle:(NSString *)userHandle
{
    
    [self pushVoIPAPNFromActorWith:[[NSUserDefaults standardUserDefaults]objectForKey:kWooUserId] toTargetWithTargetId:account andCompletionBlock:^(id response, BOOL success)
     {
         NSLog(@"success kya hai %@",channelId);
         //            [inst channelInviteUser:channelId account:account uid:0];
         
         self.callInititationTime = [NSDate date];
         MyMatches *match = [MyMatches getMatchDetailForMatchID:channelId];
         NSLog(@"channel id for send local invitatation is %@",channelId);
         
         //        [self joinChannelWithKey:match.agoraChannelKey andMatchId:channelId];
         
         localRTMInvitation.channelId = channelId;
         localRTMInvitation.content = [[NSUserDefaults standardUserDefaults]objectForKey:kWooUserId];
         NSLog(@"%@",match);
         localRTMInvitation.calleeId = match.matchedUserId;
         
         NSLog(@"%@",localRTMInvitation.calleeId);
         
         [[self->_kit getRtmCallKit] sendLocalInvitation:(AgoraRtmLocalInvitation * _Nonnull)localRTMInvitation completion:^(AgoraRtmInvitationApiCallErrorCode errorCode) {
             
             NSLog(@" error code is %ld",(long)errorCode);
             
             if(errorCode == AgoraRtmLocalInvitationErrorOk){
                 
                 NSLog(@"send local invitation");
                 NSLog(@"channelKeyStored is %@",self->channelKeyStored);
                 NSLog(@"%@",self->localRTMInvitation.calleeId);
                 
                 
                 [self->instMedia joinChannelByToken:match.agoraChannelKey channelId:channelId info:nil uid:self->my_uid joinSuccess:^(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed) {
                     NSLog(@"Joined Channel %@ successfully with Uid %lu",channel ,(unsigned long)uid);
                 }];
             }
         }];
         
         //        [self startTimerForOutgoingCall];
         //configure session
         [[VoiceCallAudioManager sharedInstance] configureAudioSession];
         [[VoiceCallAudioManager sharedInstance] startPlayingCallerTune];
     }];
    
}

-(void)acceptInviteFromUserWithUid:(unsigned)uid WithChannelID:(NSString *)channelId asUserWithAccount:(NSString *)account andMyChannelKey:(NSString *)myChannelKey
{
    NSLog(@"accept vaala call chala yha pe");
    [self joinChannelWithKey:myChannelKey andMatchId:channelId];
//    [inst channelInviteAccept:channelId account:account uid:uid extra:@""];
    
    [[_kit getRtmCallKit] acceptRemoteInvitation:(AgoraRtmRemoteInvitation * _Nonnull)remoteRTMInvitation completion:^(AgoraRtmInvitationApiCallErrorCode errorCode) {
        // Do nothing
        NSLog(@"%@",self->remoteRTMInvitation.content);
        NSLog(@"channel id for accept remote invitation %ld",(long)errorCode);
        
        if(errorCode == AgoraRtmInvitationApiCallErrorOk){
            
            [self->instMedia joinChannelByToken:myChannelKey channelId:channelId info:nil uid:self->my_uid joinSuccess:^(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed) {
                NSLog(@"Joined Channel %@ successfully with Uid %lu",channel ,(unsigned long)uid);
            }];
            
        }

    }];
    isInCall = true;
    [self.incomingCallTimer invalidate];
//    [[VoiceCallAudioManager sharedInstance] stopRingtone];
}


-(void)declineInviteWithChannelId:(NSString *)channelId asUserWithAccount:(NSString *)account
{
//    [inst channelInviteRefuse:channelId account:account uid:my_uid extra:@""];
    
    NSLog(@"decline waala method chala");
    
    [[_kit getRtmCallKit] refuseRemoteInvitation:(AgoraRtmRemoteInvitation * _Nonnull) remoteRTMInvitation completion:^(AgoraRtmInvitationApiCallErrorCode errorCode) {
        
        NSLog(@"%@",remoteRTMInvitation.channelId);
        NSLog(@"%ld", (long)errorCode);
        if(errorCode == AgoraRtmInvitationApiCallErrorOk){
            // Do nothing
            NSLog(@"refuse remote invitaion");
        }
    }];
    [self.incomingCallTimer invalidate];
    [[VoiceCallAudioManager sharedInstance] stopRingtone];
    if (SYSTEM_VERSION_LESS_THAN(@"11.0")) {
        [[VoiceCallAudioManager sharedInstance] activateAudioSessionWithActivate:NO];
    }
    self.incomingCallChannelId = nil;

}

-(void)cancelInviteForChannelId:(NSString *)channelId asUserWithAccount:(NSString *)account
{
//    [inst channelInviteEnd:channelId account:account uid:my_uid];
    
    localRTMInvitation.channelId = channelId;
    localRTMInvitation.content = [[NSUserDefaults standardUserDefaults]objectForKey:kWooUserId];
//    localRTMInvitation.calleeId = [[NSUserDefaults standardUserDefaults]objectForKey:kWooUserId];
    
    NSLog(@"%@",localRTMInvitation.channelId);
    [[_kit getRtmCallKit] cancelLocalInvitation:(AgoraRtmLocalInvitation * _Nonnull) localRTMInvitation completion:^(AgoraRtmInvitationApiCallErrorCode errorCode) {
        // Do nothing
        
        NSLog(@"error code for cancel invitation %ld",(long)errorCode);
        NSLog(@"cancel invitation pressed");
    }];
    
    if (SYSTEM_VERSION_LESS_THAN(@"11.0")) {
        [[VoiceCallAudioManager sharedInstance] activateAudioSessionWithActivate:NO];
    }
    [self.timer invalidate];
    [self setWasInviteReceivedByPeer:false];
}

-(void)endOngoingCallWithChannelId:(NSString *)channelId
{
    [self leaveChannelWithId:channelId];
    //not reqd for outgoing wala banda but for incoming in bg state
//    [provider reportCallWithUUID:uuidOfOngoingCall endedAtDate:[NSDate date] reason:CXCallEndedReasonRemoteEnded];
    isInCall = false;
    [self.incomingCallTimer invalidate];
    self.incomingCallChannelId = nil;
    [[VoiceCallAudioManager sharedInstance] stopRingtone];
    if (SYSTEM_VERSION_LESS_THAN(@"11.0")) {
        [[VoiceCallAudioManager sharedInstance] activateAudioSessionWithActivate:NO];
    }
    
}

-(void)sendUserInstantMessageToAccount:(NSString*)account withUid:(unsigned)uid
{
//    [inst messageInstantSend:account uid:0 msg:@"11001" msgID:@""];
}

-(void)sendUserInstantMessage:(NSString*)msg ToAccount:(NSString*)account withUid:(unsigned)uid
{
//    [inst messageInstantSend:account uid:0 msg:msg msgID:@""];
    
}

/*
#pragma mark - key generation utility methods
- (NSString*)MD5:(NSString*)s
{
    // Create pointer to the string as UTF8
    const char *ptr = [s UTF8String];
    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, strlen(ptr), md5Buffer);
    
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

- (NSString *) calcToken:(NSString *)_vendorKey signKey:(NSString *)signKey account:(NSString*)account expiredTime:(unsigned)expiredTime {
    // Token = 1:vendorKey:expiredTime:sign
    // Token = 1:vendorKey:expiredTime:md5(account + vendorID + signKey + expiredTime)
    
    NSString * sign = [self MD5:[NSString stringWithFormat:@"%@%@%@%d", account, _vendorKey, signKey, expiredTime]];
    return [NSString stringWithFormat:@"1:%@:%d:%@", _vendorKey, expiredTime, sign];
}
*/
-(BOOL)getIsAudioStreamMuted
{
    return isAudioStreamMuted;
}

-(BOOL)getIsSpeakerOn
{
    return isSpeakerOn;
}
-(void)mute:(BOOL)ismuted
{
    isAudioStreamMuted = ismuted;
    [instMedia muteLocalAudioStream:ismuted];
    if (uuidOfOngoingCall){
    CXSetMutedCallAction *mutingAction = [[CXSetMutedCallAction alloc]initWithCallUUID:uuidOfOngoingCall muted:ismuted];
    CXTransaction *transaction = [[CXTransaction alloc]initWithAction:mutingAction];
    [callController requestTransaction:transaction completion:^(NSError * _Nullable error) {
        if (error)
        {
            NSLog(@"Error muting call");
        }
    }];
    }
}

-(void)speaker:(BOOL)isSpeaker
{
    isSpeakerOn = isSpeaker;
    [instMedia setEnableSpeakerphone:isSpeaker];
    //Notify
}


#pragma mark Agora Rtc Engine delegate

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didRejoinChannel:
(NSString*)channel withUid:(NSUInteger)uid elapsed:(NSInteger) elapsed
{
    NSLog(@"AgoraRtcEngineKit didRejoinChannel");

}

- (void)rtcEngineConnectionDidInterrupted:(AgoraRtcEngineKit *)engine;
{
    NSLog(@"Connection Interrupted");

    if (isInCall)
    {
        //endongoing call
        [[NSNotificationCenter defaultCenter] postNotificationName:@"currentCallLeftByPeer" object:nil];
        isInCall = false;
    }
    else
    {
        if (self.incomingCallChannelId)
        {
            [self.timer invalidate];
            //Show call cancelled by peer -- will only be received at the incoming end
            [self leaveChannelWithId:self.incomingCallChannelId];
            self.incomingCallChannelId = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (SYSTEM_VERSION_LESS_THAN(@"10.0"))
                {
                    [[UIApplication sharedApplication] cancelAllLocalNotifications];
                    [UIApplication sharedApplication].applicationIconBadgeNumber=0;
                    
                }
            });
            isInCall = false;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"incomingInviteCancelledByPeer" object:nil];
        }
        else
        {
            [[VoiceCallAudioManager sharedInstance] stopPlayingCallerTune];
            if (SYSTEM_VERSION_LESS_THAN(@"11.0")) {
                [[VoiceCallAudioManager sharedInstance] activateAudioSessionWithActivate:NO];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"endCall" object:@"Call disconnected"];

        }
    }
    
}

- (void)rtcEngineConnectionDidLost:(AgoraRtcEngineKit *)engine
{
    NSLog(@"Connection Lost");
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOccurError:(AgoraErrorCode)errorCode{
    NSLog(@"Occur error:%ld",(long)errorCode);
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinChannel:(NSString*)channel withUid:(NSUInteger)uid elapsed:(NSInteger) elapsed
{
    NSLog(@"Did joined channel: %@ , with uid: %lu, elapsed: %ld",channel,(unsigned long)uid,(long)elapsed);
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed
{
    NSLog(@"Did joined of uid: %lu",(unsigned long)uid);
}


- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason{
    NSLog(@"Did offline of uid: %lu, reason: %lu",(unsigned long)uid,(unsigned long)reason);
    if (uid != my_uid)
    {
        //other user has left call
        //endongoing call
        [[NSNotificationCenter defaultCenter] postNotificationName:@"currentCallLeftByPeer" object:nil];
        isInCall = false;
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine audioQualityOfUid:(NSUInteger)uid quality:(AgoraNetworkQuality)quality delay:(NSUInteger)delay lost:(NSUInteger)lost{
    NSLog(@"Audio Quality of uid: %lu, quality: %lu, delay: %lu, lost: %lu",(unsigned long)uid,(unsigned long)quality,(unsigned long)delay,(unsigned long)lost);

}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didApiCallExecute:(NSString*)api error:(NSInteger)error
{
    NSLog(@"Did api call execute:%@",api);
}


#pragma mark - CXCallController Delegates and helpers

-(void)requestTransaction:(CXTransaction *)transaction
{
    [callController requestTransaction:transaction completion:^(NSError * _Nullable error) {
        if (error)
        {
            NSLog(@"CXTransaction error %@",[error localizedDescription]);
        }
        else
        {
            NSLog(@"Requested transaction successfully");
        }
    }];
}

#pragma mark - CXprovider Delegates and helpers
-(void)recieveIncomingCallFRomUuid:(NSUUID *)uuid withHandle:(NSString *)handle withVideo:(BOOL)hasVideo
{
    NSLog(@"recieveIncomingCallFRomUuid %@",uuid);
    
    //
    if(![self getCurrentStateOfCall])
    {
        if (!self.isLogin)
        {
            NSLog(@"needstologin");

            
            if([[NSUserDefaults standardUserDefaults] objectForKey:@"agoraRTMToken"])
            {
                NSLog(@"agoraRTMToken available");
                
                [self loginToAgora:[[NSUserDefaults standardUserDefaults]objectForKey:kWooUserId] withCompletionHandler:^(BOOL completed) {
                    if (completed)
                    {
                        //                        [self reportIncomingCallWithHandle:handle];
                    }
                }];
            }
            else
            {
                [self getRTMKeyFromServerForUserWithWooId:[[NSUserDefaults standardUserDefaults]objectForKey:kWooUserId] andCompletionBlock:^(id response, BOOL success)
                 {
                     NSLog(@"agoraRTMToken fetched");
                     if (success)
                     {
                         [self loginToAgora:[[NSUserDefaults standardUserDefaults]objectForKey:kWooUserId] withCompletionHandler:^(BOOL completed) {
                             if (completed)
                             {
//                                    [self reportIncomingCallWithHandle:handle];
                             }
                         }];
                     }
                 }];
                
            }
            
//
//            if([[NSUserDefaults standardUserDefaults] objectForKey:@"agora_signal_token"])
//            {
//                NSLog(@"agora_signal_token available");
//
//                [self loginToAgora:[[NSUserDefaults standardUserDefaults]objectForKey:kWooUserId] withCompletionHandler:^(BOOL completed) {
//                    if (completed)
//                    {
////                        [self reportIncomingCallWithHandle:handle];
//                    }
//                }];
//            }
//            else
//            {
//                [self getSignalingKeyFromServerForUserWithWooId:[[NSUserDefaults standardUserDefaults]objectForKey:kWooUserId] andCompletionBlock:^(id response, BOOL success)
//                 {
//                     NSLog(@"agora_signal_token fetched");
//                     if (success)
//                     {
//                         [self loginToAgora:[[NSUserDefaults standardUserDefaults]objectForKey:kWooUserId] withCompletionHandler:^(BOOL completed) {
//                                if (completed)
//                                {
////                                    [self reportIncomingCallWithHandle:handle];
//                                }
//                         }];
//                     }
//                 }];
//
//            }
        }
        else
        {
//            [self reportIncomingCallWithHandle:handle];
        }
       
    }
    else
    {
//        [self sendUserBusyMessageToCalledForChannelID:secondIncomingCallChannelId];
//        [weakSelf declineInviteWithChannelId:channel forMatchId:channel asUserWithAccount:name];
    }
}

-(void)reportIncomingCallWithHandle:(NSString *)handle
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0"))
    {
         NSLog(@"reportIncomingCallWithHandle k if me aaya hai %@",handle);
        NSUUID *newUuid = [[NSUUID alloc]init];
        // Construct a CXCallUpdate describing the incoming call, including the caller.
        CXCallUpdate *update = [[CXCallUpdate alloc]init];
        update.remoteHandle =  [[CXHandle alloc]initWithType:CXHandleTypeGeneric value:handle];
        update.hasVideo = NO;
        
        NSLog(@"newUuid %@",newUuid);
        
        [provider reportNewIncomingCallWithUUID:newUuid update:update completion:^(NSError * _Nullable error) {
            if(!error)
            {
                //login to agora
                NSLog(@"reportNewIncomingCallWithUUID Completed");
                self->uuidOfOngoingCall = newUuid;
            }
            else
            {
                NSLog(@"Error recieving call %@",[error localizedDescription]);
            }
        }];
    }
    else{
        
        NSLog(@"reportIncomingCallWithHandle k else me aaya hai");
        
        UILocalNotification *localNotificationForVoipCall = [[UILocalNotification alloc]init];
        localNotificationForVoipCall.alertBody = [NSString stringWithFormat:@"Voice Call from %@",handle];
        localNotificationForVoipCall.soundName = UILocalNotificationDefaultSoundName;
        localNotificationForVoipCall.category = @"voiceCallReminderCategory";
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotificationForVoipCall];
    }
}

-(void)reportNewOutgoingCall
{
    
    NSLog(@"uuidOfOngoingCall %@",uuidOfOngoingCall);
//    [provider reportOutgoingCallWithUUID:uuidOfOngoingCall connectedAtDate:[NSDate date]];
}

-(void)reportOngoingCallEnded
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"reportOngoingCallEnded %@",uuidOfOngoingCall);
        [self endCallFromCxController];
//        [provider reportCallWithUUID:uuidOfOngoingCall endedAtDate:[NSDate date] reason:CXCallEndedReasonRemoteEnded];

    });
}

-(void)endCallFromCxController
{
    NSLog(@"endCallFromCxController %@",uuidOfOngoingCall);
    CXEndCallAction *endCallAction = [[CXEndCallAction alloc] initWithCallUUID:uuidOfOngoingCall];
    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:endCallAction];
    NSLog(@"endCallFromCxController transaction%@",transaction);
    
    [self requestTransaction:transaction];
}


-(void)providerDidBegin:(CXProvider *)provider
{
    NSLog(@"Provider did begin");
   
}
-(void)providerDidReset:(CXProvider *)provider
{
    NSLog(@"Provider did reset");
    [[VoiceCallAudioManager sharedInstance] stopAudio];
}
-(void)provider:(CXProvider *)provider performStartCallAction:(CXStartCallAction *)action
{
    NSLog(@"Provider performStartCallAction");
    /*
     Configure agora
     */
    //loginto agora if not already logged in
    
    //update call state

    [action fulfill];

}

-(void)provider:(CXProvider *)provider performEndCallAction:(CXEndCallAction *)action
{
    //End incoming call
    NSLog(@"Provider performEndCallAction With incoming channel id %@",self.incomingCallChannelId);
    if (self.incomingCallChannelId)
    {
        if (!isInCall)
        {
            NSLog(@"Provider isInCall %d incoming caller account %@",isInCall,incomingCallerAccount);
            [[AgoraConnectionManager sharedManager] declineInviteWithChannelId:self.incomingCallChannelId asUserWithAccount:incomingCallerAccount];
//            [inst channelLeave:self.incomingCallChannelId];
            [instMedia leaveChannel:nil];

        }
        else
        {
            [self leaveChannelWithId:self.incomingCallChannelId];
            //needed to end when call received is ended befor picked up at lock screen
            dispatch_async(dispatch_get_main_queue(), ^{
                [self endOngoingCallWithChannelId:self.incomingCallChannelId];
            });
            
            isInCall = false;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"currentCallEndedByReceiver" object:nil];
        }
        
    }
    [action fulfill];

}
-(void)provider:(CXProvider *)provider performSetHeldCallAction:(CXSetHeldCallAction *)action
{
    NSLog(@"Provider performSetHeldCallAction");
//    [action fail];
//    return;
    
    isCallHeld = action.isOnHold;
    
    // 2.
    if (isCallHeld ) {
        [[VoiceCallAudioManager sharedInstance]stopAudio];
    } else {
        [[VoiceCallAudioManager sharedInstance]startAudio];
    }
    
    // 3.
    [action fulfill];
}
-(void)provider:(CXProvider *)provider performAnswerCallAction:(CXAnswerCallAction *)action
{
    //AnswerCall
    //login to agora if not logged in
    //call accept invitation
    //update call state
    NSLog(@"Provider performAnswerCallAction");

    
    [self getChannelKeyForMatchId:self.incomingCallChannelId andCompletionBlock:^(id response, BOOL success)
    {
        if(success && [response objectForKey:@"agora_channel_key"])
        {
            dispatch_async(dispatch_get_main_queue(), ^{

            [[WooScreenManager sharedInstance] openIncomingCallScreenForCallFromUserWithId:incomingCallerUid withMatchDetail:[MyMatches getMatchDetailForMatchedUSerID:incomingCallerAccount isApplozic:false] andChannelId:self.incomingCallChannelId  withPresentationCompletion:^(BOOL completed)
             {
                 NSLog(@"Provider performAnswerCallAction %d",completed);

                 NSLog(@"Provider performAnswerCallAction incomingCallerUid %u",self->incomingCallerUid);
                 
                 [self acceptInviteFromUserWithUid:self->incomingCallerUid WithChannelID: self.incomingCallChannelId asUserWithAccount:self->incomingCallerAccount andMyChannelKey:[response objectForKey:@"agora_channel_key"]];
                 /*
                  Configure the audio session, but do not start call audio here, since it must be done once
                  the audio session has been activated by the system after having its priority elevated.
                  */
                 [[VoiceCallAudioManager sharedInstance] configureAudioSession];

                 [[NSNotificationCenter defaultCenter] postNotificationName:@"outGoingCallInviteAccepted" object:nil];

                 [action fulfill];

            }];
            });
            
        }
        
    }];
}

-(void)acceptCallFromBackground
{
    NSLog(@"acceptCallFromBackground from %u",incomingCallerUid);
    NSLog(@"incomingCallerAccount %@",incomingCallerAccount);
    __weak AgoraConnectionManager *weakSelf = [AgoraConnectionManager sharedManager];
    [self getChannelKeyForMatchId:self.incomingCallChannelId andCompletionBlock:^(id response, BOOL success)
     {
         if(success && [response objectForKey:@"agora_channel_key"])
         {
             [self acceptInviteFromUserWithUid:self->incomingCallerUid WithChannelID: weakSelf.incomingCallChannelId asUserWithAccount:self->incomingCallerAccount andMyChannelKey:[response objectForKey:@"agora_channel_key"]];
         }
     }];
}


-(void)provider:(CXProvider *)provider didActivateAudioSession:(AVAudioSession *)audioSession
{
    NSLog(@"Provider didActivateAudioSession");
    [[VoiceCallAudioManager sharedInstance] startAudio];

}

-(void)provider:(CXProvider *)provider didDeactivateAudioSession:(nonnull AVAudioSession *)audioSession
{
    NSLog(@"Provider didDeactivateAudioSession");

}

-(void)provider:(CXProvider *)provider performSetMutedCallAction:(CXSetMutedCallAction *)action
{
    NSLog(@"Provider performSetMutedCallAction");
    if(action.muted)
    {
        isAudioStreamMuted = true;
        [instMedia muteLocalAudioStream:true];
    }
    else
    {
        isAudioStreamMuted = false;
        [instMedia muteLocalAudioStream:false];
    }
    //Notify
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MuteStateChanged" object:[NSNumber numberWithBool:action.muted]];

    [action fulfill];

}

-(void)provider:(CXProvider *)provider timedOutPerformingAction:(CXAction *)action
{
    NSLog(@"ProvidertimedOutPerformingAction");
}

#pragma mark - Call Center delegates
- (void)CallStateDidChange:(NSNotification *)notification
{
    NSLog(@"Notification : %@", notification);
    NSString *callInfo = [[notification userInfo] objectForKey:@"callState"];
    NSSet *currentCallsSet = [[notification userInfo] objectForKey:@"currentCallsSet"];
    self.ckCallState = callInfo;
    if([callInfo isEqualToString: CTCallStateDialing])
    {
        NSLog(@"Call is dailing");
        //The call state, before connection is established, when the user initiates the call.
        if(isInCall)
        {
            //cancel woo call
            [[NSNotificationCenter defaultCenter] postNotificationName:@"currentCallLeftByPeer" object:nil];
            isInCall = false;

        }
    }
    else if([callInfo isEqualToString: CTCallStateIncoming])
    {
        //The call state, before connection is established, when a call is incoming but not yet answered by the user.
        NSLog(@"Call is Coming");
        if(isInCall)
        {
            if([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive || [[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive )
            {
                //End Woo Call
                [[NSNotificationCenter defaultCenter] postNotificationName:@"currentCallLeftByPeer" object:nil];
                isInCall = false;
            }
           // else let the user decide if in background where callkit ui is visible
        }
        else
        {
            //Not on Woo Call but you might be getting an incoming WOO call or you might be calling someone on Woo
            //and another call comes in
            //NSLog(@"Woo Call is dailing or WooCall is Coming and another call call comes in%lu",currentCallsSet.count);
                //VersionCheck if less than iOS 8
                if(self.incomingCallChannelId)
                {
                    if([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive || [[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive )
                    {
                        
                    [[AgoraConnectionManager sharedManager]declineInviteWithChannelId:self.incomingCallChannelId asUserWithAccount:incomingCallerAccount];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"currentCallLeftByPeer" object:nil];
                    }
                    else
                    {
                        //Another Call is persistent and woo call in incoming if call count > 1
                        if (currentCallsSet.count > 1)
                        {
                            //Commented to enable the user to answer woo call if they want to.
//                            [[AgoraConnectionManager sharedManager]declineInviteWithChannelId:self.incomingCallChannelId asUserWithAccount:incomingCallerAccount];
//                            [[NSNotificationCenter defaultCenter] postNotificationName:@"currentCallLeftByPeer" object:nil];
                        }
                        
                    }
                }
                else
                {
                    //cancel invite
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"cancelInvite" object:@"Call interrupted by GSM call."];
                }
        }
    }

    if([callInfo isEqualToString: CTCallStateConnected])
    {
        //The call state when the call is fully established for all parties involved.
        NSLog(@"Call Connected");
    }
    
    if([callInfo isEqualToString: CTCallStateDisconnected])
    {
        //The call state Ended.
        NSLog(@"Call Ended");

    }
    
}

#pragma mark - Call Center delegates

-(void)callObserver:(CXCallObserver *)callObserver callChanged:(CXCall *)call
{
    if([call hasEnded] == true)
    {
        //Disconnected
        NSLog(@"Call is Disconnected");
    }
    if([call isOutgoing] == true && [call hasConnected] == false)
    {
        //Dialing
        NSLog(@"Call is Dialing");
        
        //The call state, before connection is established, when the user initiates the call.
        if(isInCall)
        {
            //cancel woo call
            [[NSNotificationCenter defaultCenter] postNotificationName:@"currentCallLeftByPeer" object:nil];
            isInCall = false;
            
        }

    }
    if([call isOutgoing] == false && [call hasConnected] == false && [call hasEnded] == false)
    {
        //Incoming
        NSLog(@"Call is Incoming");
        if(isInCall)
        {
            if([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive || [[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive )
            {
                //End Woo Call
                [[VoiceCallAudioManager sharedInstance] stopPlayingCallerTune];
                if (SYSTEM_VERSION_LESS_THAN(@"11.0")) {
                    [[VoiceCallAudioManager sharedInstance] activateAudioSessionWithActivate:NO];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"currentCallLeftByPeer" object:nil];
                isInCall = false;
            }
            // else let the user decide if in background where callkit ui is visible
        }
        else
        {
            //Not on Woo Call but you might be getting an incoming WOO call or you might be calling someone on Woo
            //and another call comes in
            NSLog(@"Woo Call is dailing or WooCall is Coming and another call call comes in");
            //VersionCheck if less than iOS 8
            if(self.incomingCallChannelId)
            {
                if([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive || [[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive )
                {
                    
                    [[AgoraConnectionManager sharedManager]declineInviteWithChannelId:self.incomingCallChannelId asUserWithAccount:incomingCallerAccount];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"currentCallLeftByPeer" object:nil];
                }
                else
                {
                    //Another Call is persistent and woo call in incoming if call count > 1
//                    if (currentCallsSet.count > 1)
//                    {
                        //Commented to enable the user to answer woo call if they want to.
                        //                            [[AgoraConnectionManager sharedManager]declineInviteWithChannelId:self.incomingCallChannelId asUserWithAccount:incomingCallerAccount];
                        //                            [[NSNotificationCenter defaultCenter] postNotificationName:@"currentCallLeftByPeer" object:nil];
//                    }
                    
                }
            }
            else
            {
                //cancel invite
                [[NSNotificationCenter defaultCenter] postNotificationName:@"cancelInvite" object:@"Call interrupted by GSM call."];
            }
        }

    }
    if([call hasConnected] == true && [call hasEnded] == false)
    {
        //Connected
        NSLog(@"Call is Connected");

    }
}

-(void)logCallEventForCallWithMatchId:(NSString *)matchId wasCallDeclined:(BOOL)declined  wasAnswered:(BOOL)answered
{
    /*
     DateTime
     Duration
     wasAnswered
     wasDeclined
     callersDeviceType
     matchsDeviceType
     callersAppVersion
     matchsAppVersion
     matchId
     */
    //@"callersDeviceType",@"matchsDeviceType",@"callersAppVersion",@"matchsAppVersion"
    NSString *userWooId = [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId];
    MyMatches *match = [MyMatches getMatchDetailForMatchID:matchId];
    
    long long callInitiationTime = [self.callInititationTime timeIntervalSince1970]*1000;
    
    NSMutableDictionary *fieldsDict = [[NSMutableDictionary alloc] initWithObjects:@[userWooId,[NSNumber numberWithLongLong:callInitiationTime],self.durationInSeconds,[NSNumber numberWithBool:answered],[NSNumber numberWithBool:declined],matchId,@"IPHONE",match.targetDeviceType,[[AppLaunchModel sharedInstance] appVersion] == nil ? @"3.6.7" : [[AppLaunchModel sharedInstance] appVersion] ,match.matchedUserId] forKeys:@[@"callerWooId",@"dateTime",@"duration",@"wasAnswered",@"wasDeclined",@"match_Id",@"callerDeviceType",@"receiverDeviceType",@"callerAppVersion",@"receiverWooId"]];
    [self makeCallDetailsEventCallToServerWithData:fieldsDict];
    self.callInititationTime = nil;
    // [APP_DELEGATE sendFirebaseEvent:@"Call_Record" andScreen:nil andAdditionalFields:fieldsDict];
}

-(void)makeCallDetailsEventCallToServerWithData:(NSDictionary *)eventData{
    
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    
    if (!reachability.reachable)
        return;
    
    
    NSString *productEventAPI = [NSString stringWithFormat:@"%@%@%lld/%@",kBaseURLV1,kPurchaseEventAPI,[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue],@"CALLING_RECORDS"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [manager setRequestSerializer:requestSerializer];
    
    [manager  POST:productEventAPI parameters:eventData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    } caching:GET_DATA_FROM_URL_ONLY andNumberOfRetries:3];
    
    
}

@end
