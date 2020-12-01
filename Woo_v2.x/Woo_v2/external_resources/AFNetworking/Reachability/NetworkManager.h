//
//  NetworkManager.h
//  Woo
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@class Reachability;


@interface NetworkManager : NSObject {

	Reachability *networkReachability;
	NetworkStatus networkStatus;
    BOOL isInternetConnectionAvailable;
}

@property (nonatomic, retain) Reachability *networkReachability;
@property (nonatomic, assign) NetworkStatus networkStatus;
@property (nonatomic, assign) BOOL isInternetConnectionAvailable;

+(NetworkManager *) SharedNetworkManager;

-(BOOL)checkIfInternetConnectionAvailable;
-(void)displayNoInternetConnectionAlert;

-(void)removeSharedNetworkManager;

@end
