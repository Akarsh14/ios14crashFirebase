//
//  PurchaseHistory.h
//  Woo
//
//  Created by Umesh Mishra on 04/06/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PurchaseHistory : NSManagedObject

@property (nonatomic, retain) NSString * accessPassCategory;
@property (nonatomic, retain) NSNumber * colorCode;
@property (nonatomic, retain) NSNumber * endDate;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * productDescription;
@property (nonatomic, retain) NSString * productName;
@property (nonatomic, retain) NSNumber * productPrice;
@property (nonatomic, retain) NSNumber * purchaseDate;
@property (nonatomic, retain) NSNumber * startDate;
@property (nonatomic, retain) NSString * validityInDays;

@end
