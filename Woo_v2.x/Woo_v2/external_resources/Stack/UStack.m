//
//  UStack.h
//  Woo
//
//  Created by Lokesh Sehgal on 31/03/14.
//  Copyright (c) 2014 U2opia Mobile. All Rights Reserved.

#import "UStack.h"

@implementation UStack

#define ResetCounter 0

- (id)init
{
    if( self=[super init] )
    {
        elementsArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)push:(id)anObject
{
    if(anObject!=nil)
        [elementsArray addObject:anObject];
}
- (id)pop
{
    id obj = nil;

    if(elementsArray.count > 0)
    {
        obj = [elementsArray lastObject];
        [elementsArray removeLastObject];
    }
    
    return obj;
}
- (void)clear
{
    if([elementsArray count])
        [elementsArray removeAllObjects];

}

-(BOOL)contains:(id)obj{
    return obj!=nil ? ([elementsArray count]>0 ? [elementsArray containsObject:obj] : FALSE):FALSE;
}

-(id)lastObject{
    return [elementsArray count]>0 ? [elementsArray lastObject] : nil;
}

-(void)removeElement:(id)obj{

    if([elementsArray containsObject:obj]){
        int indexOfElement = [elementsArray indexOfObject:obj];

        if([elementsArray count]>=indexOfElement){
             [elementsArray removeObject:obj];
        }
    }
}

-(id)firstElement{
    return [elementsArray count]>0 ? [elementsArray firstObject]:nil;
}

-(id)getElement:(int)indexVal{
    return [elementsArray count]>0 ? [elementsArray objectAtIndex:indexVal]:nil;
}

-(int)count{
    return [elementsArray count];
}

-(NSMutableArray*)allElements{
    return elementsArray;
}

@end
