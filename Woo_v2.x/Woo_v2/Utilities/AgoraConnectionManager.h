//
//  AgoraConnectionManager.h
//  Woo_v2
//
//  Created by Ankit Batra on 05/06/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^ApiCompletionBlock)(id,BOOL);
typedef void (^CompletionBlock)(BOOL);

@interface AgoraConnectionManager : NSObject
@property(nonatomic,assign)BOOL isLogin;
@property(nonatomic,strong)NSString *incomingCallChannelId;
@property(nonatomic,strong)NSNumber *durationInSeconds;
@property(nonatomic,strong)NSDate *callInititationTime;


/*!
 * @discussion This method return the shared instance of the AgoraConnectionManager
 * @return AgoraConnectionManager object
 */
+ (AgoraConnectionManager *)sharedManager;
-(void)pingInst;
-(void)loginToAgora:(NSString *)userId withCompletionHandler:(CompletionBlock)block;
-(void)logoutFromAgora:(NSString *)userId withCompletionHandler:(CompletionBlock)block;
-(void)getChannelKeyForMatchId:(NSString *)matchid andCompletionBlock:(ApiCompletionBlock)block;
-(void)joinChannelWithKey:(NSString *)channelKey andMatchId:(NSString *)string;
-(void)leaveChannelWithId:(NSString *)channelId;
-(void)inviteUserWithAccount:(NSString *)account andChannelId:(NSString *)channelId andHandle:(NSString *)userHandle;
-(void)acceptInviteFromUserWithUid:(unsigned)uid WithChannelID:(NSString *)channelId asUserWithAccount:(NSString *)account andMyChannelKey:(NSString *)myChannelKey;
-(void)declineInviteWithChannelId:(NSString *)channelId asUserWithAccount:(NSString *)account;
-(void)cancelInviteForChannelId:(NSString *)channelId asUserWithAccount:(NSString *)account;
-(void)endOngoingCallWithChannelId:(NSString *)channelId;
-(void)mute:(BOOL)ismuted;
-(void)speaker:(BOOL)isSpeaker;
-(unsigned)getIncomingCallUid;
-(NSString *)getIncomingCallerAccount;

-(BOOL)getIsAudioStreamMuted;
-(BOOL)getIsSpeakerOn;
-(void)recieveIncomingCallFRomUuid:(NSUUID *)uuid withHandle:(NSString *)handle withVideo:(BOOL)hasVideo;
-(void)acceptCallFromBackground;
-(void)endIncomingCall;
-(void)sendUserInstantMessage:(NSString*)msg ToAccount:(NSString*)account withUid:(unsigned)uid;
-(void)logCallEventForCallWithMatchId:(NSString *)matchId wasCallDeclined:(BOOL)declined  wasAnswered:(BOOL)answered;
@end

