//
//  NetworkManager.mm
//  Woo
//
//  Created by Lokesh on 11/02/13.

#import "NetworkManager.h"
//#import "ALToastView.h"
NetworkManager *gSharedNetworkManager = nil;


@implementation NetworkManager

@synthesize networkReachability, networkStatus;
@synthesize isInternetConnectionAvailable;


+(NetworkManager *) SharedNetworkManager
{
	if(nil == gSharedNetworkManager)
	{
		gSharedNetworkManager = [[NetworkManager alloc] init];
	}
	
	return gSharedNetworkManager;
}

-(id)init
{
    self = [super init];
	
    if(self)
    {
        Reachability* newInternetReachability = [Reachability reachabilityForInternetConnection];
        [newInternetReachability startNotifier];
        self.networkReachability = newInternetReachability;
		
        networkStatus = [self.networkReachability currentReachabilityStatus];
		
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkReachabilityDidChange:) name:kReachabilityChangedNotification object:nil];
    }
	
    return self;
}


- (void) dealloc
{
//	[[NSNotificationCenter defaultCenter] removeObserver:self];
//	
//	gSharedNetworkManager = nil;
//	self.networkReachability = nil;
	
}


- (void) connectionStateChanged
{
    if(networkStatus==NotReachableAtAll){
        [self displayNoInternetConnectionAlert];
        
    }
    else
    {
        // Network is up - do pending apis calls here
        
        UIView *view = [APP_DELEGATE.window viewWithTag:100000];
        if (view)
            [view removeFromSuperview];


    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeInNotificationState" object:nil];

}


- (void)networkReachabilityDidChange:(NSNotification *)notification
{
    // try-catch block added by lokesh
    try {
        
        Reachability *currReach = [notification object];
        NSParameterAssert([currReach isKindOfClass: [Reachability class]]);
        
        self.networkStatus = [currReach currentReachabilityStatus];
        
        // Check that current reachability is not the same as the old one
        //if(currReach != self.networkReachability)
//        {
            switch (networkStatus) {
                case ReachableViaWiFi:
                    // fire off connection
                    [self connectionStateChanged];
                    break;
                case ReachableViaWWAN:
                    // Fire off connection (3G)
                    [self connectionStateChanged];
                    break;
                case NotReachableAtAll:
                    // Don't do anything internet not reachable
                    [self connectionStateChanged];
                    break;
                default:
                    break;
//            }
                                
        }
        
    } catch (NSException *exp) {
//        NSLog(@"Application has been crashed on launched - Please handle this exception");
    }
}


-(BOOL)checkIfInternetConnectionAvailable
{
    isInternetConnectionAvailable = (networkStatus == NotReachableAtAll)?NO:YES;
    return isInternetConnectionAvailable;
}

-(void)removeSharedNetworkManager
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	
	gSharedNetworkManager = nil;
	self.networkReachability = nil;
	
}

-(void)displayNoInternetConnectionAlert
{
//    [ALToastView toastInView:[APP_DELEGATE window] withText:kNoInternetConnectionAlert];
    
    if (![APP_Utilities reachable]){
        
        UIView *viewTrans = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        viewTrans.backgroundColor = [UIColor blackColor];
        viewTrans.tag = 100000;
        viewTrans.alpha = 0.1;
        [APP_DELEGATE.window addSubview:viewTrans];
        
    }
}

@end
