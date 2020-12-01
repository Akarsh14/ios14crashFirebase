//
//  SIFloatingNode.m
//  testingObjcToSwitch
//
//  Created by Umesh Mishraji on 06/06/16.
//  Copyright © 2016 TP. All rights reserved.
//

#import "SIFloatingNode.h"

@implementation SIFloatingNode

-(SIFloatingNodeState)state{
    return myState;
}
-(void)setState:(SIFloatingNodeState)newStateValue{
    if (myState != newStateValue) {
        _previousState = myState;
        myState = newStateValue;
        [self stateChaged];
    }
}

-(void)initialiseValue{
    _labelIndex = -1;
    _previousState = Normal_Node;
    myState = Normal_Node;
    
}

-(void)stateChaged{
    switch (self.state) {
        case Normal_Node:{
            action = [self normalizeAnimation];
            actionKey = normalizeKey;
        }
            break;
        case Selected_Node:{
            action = [self selectingAnimation];
            actionKey = selectingKey;
        }
            break;
        case Removing_Node:{
            action = [self removingAnimation];
            actionKey = removingKey;
        }
            break;
            
        default:
            break;
    }
    
    if (actionKey && action) {
        NSLog(@"sif node action complete");
        [self runAction:action completion:^{
            if (actionKey == selectingKey) {
                [self selectAnimationDone];
            }
        }];
    }
}

-(void)removeFromParent{
    action = [self removeAnimation];
    if (action) {
        [self runAction:action completion:^{
            [super removeFromParent];
        }];
    }
    else{
        [super removeFromParent];
    }
}
-(SKAction *)selectingAnimation{
    return nil;
}
-(SKAction *)normalizeAnimation{
    return nil;
}
-(SKAction *)removeAnimation{
    return nil;
}
-(SKAction *)removingAnimation{
    return nil;
}
-(void)selectAnimationDone{
    return;
}


+(NSString *)getRemovingKey{
    return removingKey;
}
+(NSString *)getSelectingKey{
    return selectingKey;
}
+(NSString *)getNormalizeKey{
    return normalizeKey;
}

@end
