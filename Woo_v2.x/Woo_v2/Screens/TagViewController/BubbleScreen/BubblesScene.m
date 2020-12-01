//
//  BubblesScene.m
//  testingObjcToSwitch
//
//  Created by Umesh Mishraji on 08/06/16.
//  Copyright © 2016 TP. All rights reserved.
//

#import "BubblesScene.h"
#import "BubbleNode.h"

@implementation BubblesScene

//method for extension

-(CGFloat)random{
    CGFloat randomValue = ((CGFloat) arc4random())/ 0xFFFFFFFF;
    return randomValue;
}
-(CGFloat)randomWithMin:(CGFloat)min andMax:(CGFloat)max{
    return [self random] * (max - min) + min;
}

- (instancetype)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    if (self)
    {
        
    }
    [self initialiseAllValues];
    return self;
}

-(void)initialiseAllValues{
    _bottomOffset = 0;
    _topOffset = 0;
//    [super performSelector:@selector(initialiseAllvalues) withObject:nil afterDelay:0.3];
    [super initialiseAllvalues];
}


-(void)didMoveToView:(SKView *)view{
    [super didMoveToView:view];
    [self configure];
}

-(void)configure{
    self.backgroundColor = [SKColor whiteColor];
    self.scaleMode = SKSceneScaleModeAspectFill;
    allowMultipleSelection = FALSE;
    CGRect bodyFrame = self.frame;
    bodyFrame.size.width = (CGFloat)self.magneticField.minimumRadius;
    bodyFrame.origin.x -= bodyFrame.size.width / 2;
    bodyFrame.size.height = self.frame.size.height - _bottomOffset;
    bodyFrame.origin.y = self.frame.size.height - bodyFrame.size.height - _topOffset;
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:bodyFrame];
    self.magneticField.position = CGPointMake(self.frame.size.width/2, ((self.frame.size.height/2) + (_bottomOffset/2) - _topOffset));
}

-(void)addChild:(SKNode *)node{
    long minValue = 16*2.5 * _totalBubbleCount;
    long maxValue = 16*2.5 * _totalBubbleCount;
    if (minValue < self.frame.size.width) {
        minValue = self.frame.size.width;
    }
    if (maxValue < self.frame.size.width) {
        maxValue = self.frame.size.width;
    }
    if ([node isKindOfClass:[BubbleNode class]]) {
        CGFloat x = [self randomWithMin:-minValue andMax:maxValue];
        CGFloat y = [self randomWithMin:(self.frame.size.height - _bottomOffset - node.frame.size.height) andMax:(self.frame.size.height - _topOffset - node.frame.size.height)];
        if (([floatingNodes count]%2==0) || [floatingNodes count]<1) {
            x = [self randomWithMin:maxValue andMax:-minValue];
        }
        NSLog(@"node point >> %@", NSStringFromCGPoint(CGPointMake(x, y)));
        node.position = CGPointMake(x, y);
    }
    [super addChild:node];
}

-(void)performCommitSelectionAnimation{
    self.physicsWorld.speed = 0;
    NSArray *sortedArray = [self sortedFloatingNodes];
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    
    for (BubbleNode *node in sortedArray) {
        node.physicsBody = nil;
        SKAction *action = [self actionForFloatingNode:node];
        [actions addObject:action];
    }
    [self runAction:[SKAction sequence:actions]];
}

-(void)throwNode:(SKNode *)node toPoint:(CGPoint)point withCompletion:(void(^)())block{
    [node removeAllActions];
    SKAction *movingXAction = [SKAction moveToX:point.x duration:0.2];
    SKAction *movingYAction = [SKAction moveToY:point.y duration:0.4];
    SKAction *resize = [SKAction scaleTo:0.3 duration:0.4];
    SKAction *throwAction = [SKAction group:[NSArray arrayWithObjects:movingXAction, movingYAction, resize,  nil]];
    [node runAction:throwAction];
}



-(NSArray *)sortedFloatingNodes{
    NSMutableArray *sortedNodes = (NSMutableArray *)[floatingNodes sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        //
        SIFloatingNode *node = (SIFloatingNode *)obj1;
        SIFloatingNode *nextNode = (SIFloatingNode *)obj2;
        CGFloat distance = [self distanceBetweenPoints:node.position andSecondPoint:self.magneticField.position];
        CGFloat nextDistance = [self distanceBetweenPoints:nextNode.position andSecondPoint:self.magneticField.position];
        return (distance < nextDistance) && (node.state != Selected_Node);
    }];
    return sortedNodes;
}

-(SKAction *)actionForFloatingNode:(SIFloatingNode *)node{
    SKAction *action = [SKAction runBlock:^{
        int index = (int)[floatingNodes indexOfObject:node];
        if (index > -1 && index < [floatingNodes count]) {
            [self removeFloatinNodeAtIndex:index];
            if (node.state == Selected_Node) {
                [self throwNode:node toPoint:CGPointMake(self.size.width / 2, self.size.height + 40) withCompletion:^{
                    [node removeFromParent];
                }];
            }
        }
    }];
    return action;
}

-(void)nodeSelectedBlock:(void(^)(NSDictionary * nodeDetail))block{
    nodeSelected = block;
}



































@end
