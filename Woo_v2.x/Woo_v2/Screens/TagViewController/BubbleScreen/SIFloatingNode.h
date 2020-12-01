//
//  SIFloatingNode.h
//  testingObjcToSwitch
//
//  Created by Umesh Mishraji on 06/06/16.
//  Copyright © 2016 TP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>

typedef enum {
    Normal_Node = 0,
    Selected_Node,
    Removing_Node
    
} SIFloatingNodeState;


static NSString *removingKey = @"action.removing";
static NSString *selectingKey = @"action.selecting";
static NSString *normalizeKey = @"action.normalize";

@interface SIFloatingNode : SKShapeNode{
    
    
//    SIFloatingNodeState previousState;
//    SIFloatingNodeState state;
//    SIFloatingNodeState removing;
    SIFloatingNodeState myState;
    
    SKAction *action;
    NSString *actionKey;
}
@property(nonatomic, assign) SIFloatingNodeState previousState;
@property(nonatomic, assign) SIFloatingNodeState state;
@property(nonatomic, assign) int labelIndex;;
@property(nonatomic, assign) BOOL isNodeSelected;
@property(nonatomic, retain) NSDictionary *nodeDetail;

-(SIFloatingNodeState)state;
-(void)setState:(SIFloatingNodeState)newStateValue;

+(NSString *)getRemovingKey;
+(NSString *)getSelectingKey;
+(NSString *)getNormalizeKey;

//methods to be overridden
-(SKAction *)selectingAnimation;
-(SKAction *)normalizeAnimation;
-(SKAction *)removeAnimation;
-(SKAction *)removingAnimation;
-(void)selectAnimationDone;



-(void)removeFromParent;

-(void)initialiseValue;

@end
