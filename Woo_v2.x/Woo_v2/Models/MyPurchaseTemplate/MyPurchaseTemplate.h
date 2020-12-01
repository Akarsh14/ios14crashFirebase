//
//  MyPurchaseTemplate.h
//  Woo_v2
//
//  Created by Deepak Gupta on 7/14/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyPurchaseTemplate : NSObject
/*
 content
 imgUrl
 productType
 title
 */
@property (nonatomic , strong) NSString     *boostContent;
@property (nonatomic , strong) NSString     *boostImgUrl;
@property (nonatomic , strong) NSString     *boostProductType;
@property (nonatomic , strong) NSString     *boostTitle;

@property (nonatomic , strong) NSString     *crushContent;
@property (nonatomic , strong) NSString     *crushImgUrl;
@property (nonatomic , strong) NSString     *crushProductType;
@property (nonatomic , strong) NSString     *crushTitle;

@property (nonatomic , strong) NSString     *wooPlusContent;
@property (nonatomic , strong) NSString     *wooPlusImgUrl;
@property (nonatomic , strong) NSString     *wooPlusProductType;
@property (nonatomic , strong) NSString     *wooPlusTitle;


@property (nonatomic , strong) NSString     *wooGlobeContent;
@property (nonatomic , strong) NSString     *wooGlobeImgUrl;
@property (nonatomic , strong) NSString     *wooGlobeProductType;
@property (nonatomic , strong) NSString     *wooGlobeTitle;


- (void)updateDataWithMyPurchaseTemplate:(NSDictionary*)myPurchaseTemplateDict;
+ (MyPurchaseTemplate *)sharedInstance;

- (void)resetModel;
@end
