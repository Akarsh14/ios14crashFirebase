//
//  SIFloatingCollectionScene.m
//  testingObjcToSwitch
//
//  Created by Umesh Mishraji on 06/06/16.
//  Copyright © 2016 TP. All rights reserved.
//

#import "SIFloatingCollectionScene.h"
#import "SIFloatingNode.h"

@implementation SIFloatingCollectionScene



-(CGFloat)distanceBetweenPoints:(CGPoint)firstPoint andSecondPoint:(CGPoint)secondPoint{
    return hypot(secondPoint.x - firstPoint.x, secondPoint.y - firstPoint.y);
}

-(void)initialiseAllvalues{
    
    
    _magneticField = [SKFieldNode radialGravityField];
    mode = Normal;
    
    if (!floatingNodes) {
        floatingNodes = [[NSMutableArray alloc] init];
    }
    
    timeToStartRemove = 0.7;
    timeToRemove = 2;
    allowEditing = FALSE;
    allowMultipleSelection = TRUE;
    restrictedToBounds = FALSE;
    pushStrength = 10000*2.5;
    
}


-(void)setMode:(SIFloatingCollectionSceneMode)newModeValue{
    if (mode != newModeValue) {
        mode = newModeValue;
        [self modeUpdated];
    }
}




- (void)didMoveToView:(SKView *)view{
    [super didMoveToView:view];
    [self myConfigure];
}


// MARK: -
// MARK: Frame Updates
//@todo refactoring

-(void)update:(NSTimeInterval)currentTime{
//    NSLog(@"floatingNodes <<:%@",floatingNodes);
    
    
    [floatingNodes enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj) {
            SKNode *nodeObj = (SKNode*)obj;
            CGFloat distanceFromCenter = [self distanceBetweenPoints:_magneticField.position andSecondPoint:nodeObj.position];
            nodeObj.physicsBody.linearDamping = (distanceFromCenter > 100) ? 2: (2 + ((100 - distanceFromCenter)/10));
        }
    }];
    
    
    
    if ((mode == Moving) || !allowEditing) {
        return;
    }
    
    if (isTouchPointInitialise && isTouchStartedTimeInitialised) {
        NSTimeInterval dTime = currentTime - touchStartedTime;
        if (dTime >= timeToStartRemove) {
            isTouchStartedTimeInitialised = FALSE;
            id newNodeObj = [self nodeAtPoint:touchPoint];
            if (newNodeObj && [newNodeObj isKindOfClass:[SIFloatingNode class]]) {
                removingStartedTime = currentTime;
                [self startRemovingNode:newNodeObj];
                
            }
        }
    }
    else if (mode == Editing && isRemovingStartedTimeInitialised && isTouchPointInitialise){
        NSTimeInterval dTime = currentTime - removingStartedTime;
        if (dTime >= timeToRemove) {
            isRemovingStartedTimeInitialised = FALSE;
            id newNodeObj = [self nodeAtPoint:touchPoint];
            if (newNodeObj && [newNodeObj isKindOfClass:[SIFloatingNode class]]) {
                int indexOfNode = (int)[floatingNodes indexOfObject:newNodeObj];
                [self removeFloatinNodeAtIndex:indexOfNode];
                
            }
        }
    }
    
    
    NSLog(@"floatingNodes >>>:%@",floatingNodes);
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches allObjects].firstObject;
    if (touch && [touch isKindOfClass:[UITouch class]]) {
        touchPoint = [touch locationInNode:self];
        isTouchPointInitialise = TRUE;
        touchStartedTime = touch.timestamp;
        isTouchStartedTimeInitialised = TRUE;
        
    }
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (mode == Editing) {
        return;
    }
    UITouch *touch = [touches allObjects].firstObject;
    
    if (touch && [touch isKindOfClass:[UITouch class]]) {
        CGPoint plin = [touch previousLocationInNode:self];
        CGPoint lin = [touch locationInNode:self];
        CGFloat dx = lin.x - plin.x;
        CGFloat dy = lin.y - plin.y;
        CGFloat b = sqrt(pow(lin.x, 2)+pow(lin.y, 2));
        dx = (b == 0)? 0 : (dx/b);
        dy = (b == 0)? 0 : (dy/b);
        
        if ((dx==0) && (dy == 0)) {
            return;
        }
        else if (mode != Moving){
            mode = Moving;
        }
        
        for (SIFloatingNode * node in floatingNodes) {
            CGFloat w = node.frame.size.width/2;
            CGFloat h = node.frame.size.height/2;
            CGVector direction = CGVectorMake(pushStrength * dx, pushStrength * dy);
            if (restrictedToBounds) {
                if ([self isValue:node.position.x ExistBetween:-w andMaxValue:self.size.width+w] && ((node.position.x * dx) > 0)) {
                    direction.dx = 0;
                }
                if ([self isValue:node.position.y ExistBetween:-h andMaxValue:self.size.height + h] && ((node.position.y * dy) > 0)) {
                    direction.dy = 0;
                }
            }
            [node.physicsBody applyForce:direction];
        }
        
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if ((mode != Moving) && isTouchPointInitialise) {
        if (_maximumNumberOfTagsSelected) {
            //
            nodeSelected(nil);
        }
        else{
            id newNodeObj = [self nodeAtPoint:touchPoint];
            if (newNodeObj && [newNodeObj isKindOfClass:[SIFloatingNode class]]){
                [self updateNodeState:newNodeObj];
            }
        }
        
    }
    mode = Normal;
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    mode = Normal;
}

-(void)cancelRemovingNode:(SIFloatingNode *)node{
    mode = Normal;
    node.physicsBody.dynamic = TRUE;
    node.state = node.previousState;
    int index = (int)[floatingNodes indexOfObject:node];
    if (index > -1) {
        if (_floatingDelegate) {
            [_floatingDelegate floatingScene:self canceledRemovingOfFloatingNodeAtIndex:index];
        }
    }
}


//floatingNodeAtIndex

-(int)indexOfSelectedNode{
    __block int index = -1;
    
    for (int idx=0; idx<[floatingNodes count]; idx++) {
        SIFloatingNode *nodeObj = [floatingNodes objectAtIndex:idx];
        if (nodeObj.state == Selected_Node) {
            index = idx;
            break;
        }
    }
    return index;
}


//indexesOfSelectedNodes

- (SKNode *)nodeAtPoint:(CGPoint)p
{
    SKNode *node = [super nodeAtPoint:p];
    while(![node.parent isKindOfClass:[SKScene class]] &&
          ![node isKindOfClass:[SIFloatingNode class]] &&
          node.parent != nil &&
          !node.userInteractionEnabled)
    {
        node = node.parent;
    }
    return node;
}


-(void)removeFloatinNodeAtIndex:(int)index{
    if ([self shouldRemoveNodeAtIndex:index]) {
        SIFloatingNode *node = [floatingNodes objectAtIndex:index];
        [floatingNodes removeObjectAtIndex:index];
        [node removeFromParent];
        if (_floatingDelegate) {
            [_floatingDelegate floatingScene:self didRemoveFloatingNodeAtIndex:index];
        }
    }
}

-(void)removeShadowNodeAtIndex:(int)index{
    NSArray *allChild = [self children];
    
    for (SIFloatingNode *nodeObj in allChild) {
        if ([nodeObj isKindOfClass:[SIFloatingNode class]]) {
            if (nodeObj.labelIndex == index) {
                [nodeObj removeFromParent];
            }
        }
    }
}

-(void)startRemovingNode:(SIFloatingNode *)node{
    mode = Editing;
    node.physicsBody.dynamic = FALSE;
    node.state = Removing_Node;
    int indexOfNode = (int)[floatingNodes indexOfObject:node];
    if (indexOfNode>-1) {
        if (_floatingDelegate) {
            [_floatingDelegate floatingScene:self startedRemovingOfFloatingNodeAtIndex:indexOfNode];
        }
    }
}


-(void)updateNodeState:(SIFloatingNode *)node{
    int indexOfNode = (int)[floatingNodes indexOfObject:node];
    if (indexOfNode>-1) {
        switch (node.state) {
            case Normal_Node:{
                NSLog(@"updateNodeState >>> sifscene");
                if ([self shouldSelectNodeAtIndex:indexOfNode]) {
                    int selectedIndex = [self indexOfSelectedNode];
                    if (!allowMultipleSelection && selectedIndex>-1) {
                        
                        [self updateNodeState:[floatingNodes objectAtIndex:selectedIndex]];
                    }
                    if (!node.isNodeSelected) {
                        nodeSelected(node.nodeDetail);
                    }
                    node.state = Selected_Node;
                    if (_floatingDelegate) {
                        [_floatingDelegate floatingScene:self didSelectFloatingNodeAtIndex:indexOfNode];
                    }
                }
            }
                break;
            case Selected_Node:{
                if ([self shouldDeselectNodeAtIndex:indexOfNode]) {
                    node.state = Normal_Node;
                    if (_floatingDelegate) {
                        [_floatingDelegate floatingScene:self didDeselectFloatingNodeAtIndex:indexOfNode];
                    }
                }
            }
                break;
            case Removing_Node:{
//                [self cancelRemovingNode:node];
            }
                break;
                
            default:
                break;
        }
    }
}


//addChild

-(void)addChild:(SKNode *)node{
    if ([node isKindOfClass:[SIFloatingNode class]]) {
        SIFloatingNode *child = (SIFloatingNode *)node;
        [self configureNode:child];
        [floatingNodes addObject:child];
    }
    [super addChild:node];
}


-(void)myConfigure{
//    self.physicsWorld.gravity = CGVectorMake(0, 0);
    
    _magneticField = [SKFieldNode radialGravityField];
    self.scaleMode = SKSceneScaleModeAspectFill;
    
    
    CGRect frame = self.frame;
    frame.size.width = self.magneticField.minimumRadius*2.5;
    frame.origin.x -= frame.size.width*2.5/2;
    frame.size.height = frame.size.height*2.5;
    frame.origin.y = frame.size.height - frame.size.height;
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:frame];
    
//    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    
    _magneticField.region = [[SKRegion alloc] initWithRadius:10000*2.5];
    _magneticField.minimumRadius = 10000*2.5;
    _magneticField.strength = 4000*2.5;
    _magneticField.position = CGPointMake(self.size.width*2.5/2, self.size.height*2.5/2);
    [self addChild:_magneticField];
}

//configureNode

-(void)configureNode:(SIFloatingNode *)node{
    if (node.physicsBody == nil) {
//        CGPathRef path = CGPathCreateMutable();
//        if (node.path != nil) {
//            path = node.path;
//        }
        node.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:node.path];
    }
    node.physicsBody.dynamic = TRUE;
    node.physicsBody.affectedByGravity = FALSE;
    node.physicsBody.allowsRotation = FALSE;
    node.physicsBody.mass = 0.3;
    node.physicsBody.friction = 0;
    node.physicsBody.linearDamping = 3;
}


-(void)modeUpdated{
    switch (mode) {
        case Normal:
        case Moving:{
            touchStartedTime = 0.0;
            isTouchStartedTimeInitialised = FALSE;
            removingStartedTime = 0.0;
            isRemovingStartedTimeInitialised = FALSE;
            touchPoint = CGPointZero;
            isTouchPointInitialise = FALSE;
        }
            break;
        default:
            break;
    }
}

-(BOOL)shouldRemoveNodeAtIndex:(int)index{
    /**
     *  check it baby after some time
     */
    if ([self isValue:index ExistBetween:0 andMaxValue:floatingNodes.count - 1]) {
        if (_floatingDelegate) {
            BOOL shouldRemove = [_floatingDelegate floatingScene:self shouldRemoveFloatingNodeAtIndex:index];
            return shouldRemove;
        }
        return TRUE;
    }
    return FALSE;
}


-(BOOL)shouldSelectNodeAtIndex:(int)index{
    if (_floatingDelegate) {
        return [_floatingDelegate floatingScene:self shouldSelectFloatingNodeAtIndex:index];
    }
    return TRUE;
}
-(BOOL)shouldDeselectNodeAtIndex:(int)index{
    if (_floatingDelegate) {
        return [_floatingDelegate floatingScene:self shouldDeselectFloatingNodeAtIndex:index];
    }
    return TRUE;
}


// // // // // // -----##### >>>>>   " ~= "      <<<<<<  method to get funcatinality of thid operator

-(BOOL)isValue:(CGFloat)value ExistBetween:(float)minValue andMaxValue:(float)maxValue{
    
    if (value >= minValue && value <= maxValue) {
        return TRUE;
    }
    return FALSE;
}

@end
