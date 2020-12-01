////
////  LayerAuthenticationHelper.m
////  Woo_v2
////
////  Created by Umesh Mishraji on 20/04/16.
////  Copyright © 2016 Vaibhav Gautam. All rights reserved.
////
//
//#import "LayerAuthenticationHelper.h"
//
//@implementation LayerAuthenticationHelper
//
//
//SINGLETON_FOR_CLASS(LayerAuthenticationHelper)
//
//-(void)authenticateLayerWithUserID:(NSString *)userID layerClient:(LYRClient *)layerClientObj completion:(void (^)(BOOL success, NSError * error))completion{
//    layerClient = layerClientObj;
//    if (layerClient && layerClient.authenticatedUser) {
//        if ([layerClient.authenticatedUser.userID isEqualToString:userID])
//        {
////            if ([self checkIfAgoraSignalingTokenHasExpired])
////            {
////                [layerClient deauthenticateWithCompletion:^(BOOL success, NSError * _Nullable error) {
////                    if (success) {
////                        [self authenticationTokenWithUserId:userID completion:^(BOOL success, NSError *error) {
////                            if (completion) {
////                                completion(success, error);
////                            }
////                        }];
////                    }
////                    else{
////                        if (completion) {
////                            completion(FALSE, error);
////                        }
////                    }
////                }];
////            }
////            else
////            {
//                if (completion) {
//                    completion(TRUE, nil);
//                    return;
//                }
////            }
//        }
//        else{
//            // user id authenticated with different Id
//            [layerClient deauthenticateWithCompletion:^(BOOL success, NSError * _Nullable error) {
//                if (success) {
//                    [self authenticationTokenWithUserId:userID completion:^(BOOL success, NSError *error) {
//                        if (completion) {
//                            completion(success, error);
//                        }
//                    }];
//                }
//                else{
//                    if (completion) {
//                        completion(FALSE, error);
//                    }
//                }
//            }];
//        }
//    }
//    else{
//        [self authenticationTokenWithUserId:userID completion:^(BOOL success, NSError *error) {
//            if (completion) {
//                completion(success, error);
//            }
//        }];
//    }
//}
///*
//-(BOOL)checkIfAgoraSignalingTokenHasExpired
//{
//    NSDate *currentTime = [NSDate date];
//    NSDate *agora_signal_token_timestamp = [[NSUserDefaults standardUserDefaults] objectForKey:@"agora_signal_token_timestamp"];
//    NSTimeInterval secs = [currentTime timeIntervalSinceDate:agora_signal_token_timestamp];
//    //Signaling token time currently set to 2 hrs
//    double timeForSignalTokenExpiry = 2 * 24 * 3600.0;
//    return secs>timeForSignalTokenExpiry ;
//
//}
//*/
//
//- (void)authenticationTokenWithUserId:(NSString *)userID completion:(void (^)(BOOL success, NSError* error))completion{
//    if (layerClient) {
//        [layerClient requestAuthenticationNonceWithCompletion:^(NSString * _Nullable nonce, NSError * _Nullable error) {
//            if (!nonce) {
//                if (completion) {
//                    completion(FALSE, error);
//                }
//                return;
//            }
//            [self getIdentityTokenFromWooServerForNonce:nonce completion:^(BOOL success, NSString *identityToken) {
//                if (success && identityToken && [identityToken length]>0) {
//                    [layerClient authenticateWithIdentityToken:identityToken completion:^(LYRIdentity * _Nullable authenticatedUser, NSError * _Nullable error) {
//                        
//                        if (authenticatedUser &&  authenticatedUser.userID && [authenticatedUser.userID length]>0) {
//                            if (completion) {
//                                completion(TRUE, nil);
//                            }
//                        }
//                        else{
//                            if (completion) {
//                                completion(FALSE, nil);
//                            }
//                        }
//                    }];
//                }
//            }];
//        }];
//    }
//}
//
//-(void)reauthenticateUserWithNonceToken:(NSString *)nonce completion:(void (^)(BOOL success, NSError * error))completion{
//    
//    [self getIdentityTokenFromWooServerForNonce:nonce completion:^(BOOL success, NSString *identityToken) {
//        if (success && identityToken && [identityToken length]>0) {
//            [layerClient authenticateWithIdentityToken:identityToken completion:^(LYRIdentity * _Nullable authenticatedUser, NSError * _Nullable error) {
//                if (authenticatedUser &&  authenticatedUser.userID && [authenticatedUser.userID length]>0) {
//                    if (completion) {
//                        completion(TRUE, nil);
//                    }
//                }
//                else{
//                    if (completion) {
//                        completion(FALSE, nil);
//                    }
//                }
//            }];
//        }
//    }];
//}
//
//-(void)getIdentityTokenFromWooServerForNonce:(NSString *)nonce completion:(void (^)(BOOL success, NSString *identityToken))completion{
//    
//    NSString *getIdentifyTokenForNonce = [NSString stringWithFormat:@"%@%@?wooId=%@&nonce=%@",kBaseURLV1,kAuthenticateLayerWithServerAPI,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],[APP_Utilities encodeFromPercentEscapeString:nonce]];
//    
//    WooRequest *wooRequestObj = [[WooRequest alloc]init];
//    wooRequestObj.url =getIdentifyTokenForNonce;
//    wooRequestObj.time =0;
//    wooRequestObj.requestParams =nil;
//    wooRequestObj.methodType =postRequest;
//    wooRequestObj.numberOfRetries =3;
//    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
//    wooRequestObj.requestType = authenticateLayerWithServer;
//    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
//        if (success)
//        {
//            if ([response objectForKey:@"agora_signal_token"] && [[APP_Utilities validString:[response objectForKey:@"agora_signal_token"]] length] >0)
//            {
//
//                [[NSUserDefaults standardUserDefaults] setObject: [response objectForKey:@"agora_signal_token"] forKey:@"agora_signal_token"];
//                [[NSUserDefaults standardUserDefaults] setObject: [NSDate date] forKey:@"agora_signal_token_timestamp"];
//                
//                [[NSUserDefaults standardUserDefaults]synchronize];
//            }
//            
//            if ([response objectForKey:@"identity_token"] && [[APP_Utilities validString:[response objectForKey:@"identity_token"]] length]>0) {
//                if (completion) {
//                    completion(success, [response objectForKey:@"identity_token"]);
//                }
//            }
//            else{
//                if (completion) {
//                    completion(FALSE, nil);
//                }
//            }
//        }
//        else{
//            if (completion) {
//                completion(FALSE, nil);
//            }
//        }
//        
//    } shouldReachServerThroughQueue:YES];
//}
//
//
//-(void)updateDeviceTokenOnLayerServer:(LYRClient *)layerClientObj{
//    if (layerClientObj) {
//        NSData *deveTokenData= [[NSUserDefaults standardUserDefaults] objectForKey:kDeviceToken];
//        if (deveTokenData) {
//            NSError *errorObj;
//            BOOL success = [layerClient updateRemoteNotificationDeviceToken:deveTokenData error:&errorObj];
//            if (!success) {
//                [self updateDeviceTokenOnLayerServer:layerClientObj];
//            }
//            else{
////                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDeviceToken];
////                [[NSUserDefaults standardUserDefaults] synchronize];
//            }
//        }
//    }
//}
//
//-(void)deAuthenticateUserOnLayer:(LayerDeAuthSuccess)layerDeAuthSuccessBlock{
//    
//    // user id authenticated with different Id
//    if(layerClient!=nil && [layerClient currentSession]!=nil){
//        NSError *errorObj;
//        BOOL success = [layerClient destroySession:[layerClient currentSession] error:&errorObj];
//        layerClient = nil;
//        layerDeAuthSuccessBlock(success);
//    }else{
//        layerClient = nil;
//        layerDeAuthSuccessBlock(TRUE);
//    }
////
////        [layerClient deauthenticateWithCompletion:^(BOOL success, NSError * _Nullable error) {
////            if (success) {
////                layerDeAuthSuccessBlock(success);
////                layerClient = nil;
////            }
////        }];
//
//    
//}
//
//@end
