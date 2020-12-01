//
//  UNetworkReachability.m
//  Woo
//
//  Created by Lokesh Sehgal on 07/08/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "UNetworkReachability.h"

@interface UNetworkReachability()
{
    BOOL firstTime;
}

@end

@implementation UNetworkReachability

UNetworkReachability *networkReachabilityObj = nil;

+(UNetworkReachability *) sharedNetworkReachability{
 
    if(nil == networkReachabilityObj)
	{
		networkReachabilityObj = [[UNetworkReachability alloc] init];
        
        [[UNetworkReachability sharedNetworkReachability] startMonitering];
        
	}
    
	return networkReachabilityObj;
}

-(void)startMonitering{
    
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    
    [reachability setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        if (firstTime == false) {
            firstTime = true;
            return;
        }
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:{
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

                    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pingGoogleAndCheck) object:nil];
                    
                    [self performSelector:@selector(pingGoogleAndCheck) withObject:self afterDelay:2.0f];
                    
                });

            }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:{

                [[NSNotificationCenter defaultCenter] postNotificationName:kInternetConnectionStatusChanged object:[NSNumber numberWithInt:status]];

            }
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:{

                [[NSNotificationCenter defaultCenter] postNotificationName:kInternetConnectionStatusChanged object:[NSNumber numberWithInt:status]];
                
                
            }
                break;
            default:
            {
                //                    NSLog(@"Unknown status here");
            }
                break;
        }
    }];
    
    [reachability startMonitoring];
}

-(void)pingGoogleAndCheck{
    
    bool success = false;
    const char *host_name = [@"google.com"
                             cStringUsingEncoding:NSASCIIStringEncoding];
    
    SCNetworkReachabilityRef localReachability = SCNetworkReachabilityCreateWithName(NULL,
                                                                                host_name);
    SCNetworkReachabilityFlags flags;
    success = SCNetworkReachabilityGetFlags(localReachability, &flags);
    bool isAvailable = success && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
    //CFRelease(localReachability);
    if (isAvailable) {
        NSLog(@"Host is reachable: %d", flags);
        [[NSNotificationCenter defaultCenter] postNotificationName:kInternetConnectionStatusChanged object:[NSNumber numberWithInt:AFNetworkReachabilityStatusReachableViaWiFi]];
        
    }else{
        NSLog(@"Host is unreachable");
        [[NSNotificationCenter defaultCenter] postNotificationName:kInternetConnectionStatusChanged object:[NSNumber numberWithInt:AFNetworkReachabilityStatusNotReachable]];
        
    }
}

- (BOOL)getInterentStatus{
    bool success = false;
    const char *host_name = [@"google.com"
                             cStringUsingEncoding:NSASCIIStringEncoding];
    
    SCNetworkReachabilityRef localReachability = SCNetworkReachabilityCreateWithName(NULL,
                                                                                host_name);
    SCNetworkReachabilityFlags flags;
    success = SCNetworkReachabilityGetFlags(localReachability, &flags);
    bool isAvailable = success && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
   // CFRelease(localReachability);
    if (isAvailable) {
        NSLog(@"Host is reachable: %d", flags);
        return YES;
        
    }else{
        NSLog(@"Host is unreachable");
        return NO;
        
    }
    
    return NO;
    

}
@end
