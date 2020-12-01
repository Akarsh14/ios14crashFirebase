//
//  BubblesScene.h
//  testingObjcToSwitch
//
//  Created by Umesh Mishraji on 08/06/16.
//  Copyright © 2016 TP. All rights reserved.
//

#import "SIFloatingCollectionScene.h"

@interface BubblesScene : SIFloatingCollectionScene{
    
}

@property(nonatomic, assign) CGFloat topOffset;
@property(nonatomic, assign) CGFloat bottomOffset;
@property(nonatomic, assign) NSInteger totalBubbleCount;


-(void)addChild:(SKNode *)node;

-(void)nodeSelectedBlock:(void(^)(NSDictionary * nodeDetail))block;

@end
