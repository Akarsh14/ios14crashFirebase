//
//  UStack.h
//  Woo
//
//  Created by Lokesh Sehgal on 31/03/14.
//  Copyright (c) 2014 U2opia Mobile. All Rights Reserved.
//

#import <Foundation/Foundation.h>

@interface UStack : NSObject {

        NSMutableArray *elementsArray;

}

- (void)push:(id)anObject;

- (id)pop;

- (void)clear;

-(int)count;

-(BOOL)contains:(id)obj;

-(id)lastObject;

-(void)removeElement:(id)obj;

-(id)firstElement;

-(id)getElement:(int)indexVal;

-(NSMutableArray*)allElements;

@property (nonatomic, readonly) int count;

@end