//
//  UNetworkReachability.h
//  Woo
//
//  Created by Lokesh Sehgal on 07/08/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UNetworkReachability : NSObject

{
    
}

+(UNetworkReachability *) sharedNetworkReachability;
-(void)startMonitering;
- (BOOL)getInterentStatus;
@end
