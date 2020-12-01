//
//  SIFloatingCollectionScene.h
//  testingObjcToSwitch
//
//  Created by Umesh Mishraji on 06/06/16.
//  Copyright © 2016 TP. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class SIFloatingCollectionScene;

@protocol SIFloatingCollectionSceneDelegate

@optional
-(BOOL)floatingScene:(SIFloatingCollectionScene *)scene shouldSelectFloatingNodeAtIndex:(int)index;
-(void)floatingScene:(SIFloatingCollectionScene *)scene didSelectFloatingNodeAtIndex:(int)index;

-(BOOL)floatingScene:(SIFloatingCollectionScene *)scene shouldDeselectFloatingNodeAtIndex:(int)index;
-(void)floatingScene:(SIFloatingCollectionScene *)scene didDeselectFloatingNodeAtIndex:(int)index;

-(int)floatingScene:(SIFloatingCollectionScene *)scene startedRemovingOfFloatingNodeAtIndex:(int)index;
-(void)floatingScene:(SIFloatingCollectionScene *)scene canceledRemovingOfFloatingNodeAtIndex:(int)index;

-(BOOL)floatingScene:(SIFloatingCollectionScene *)scene shouldRemoveFloatingNodeAtIndex:(int)index;
-(void)floatingScene:(SIFloatingCollectionScene *)scene didRemoveFloatingNodeAtIndex:(int)index;

@end

typedef enum {
    Normal = 0,
    Editing,
    Moving
}SIFloatingCollectionSceneMode;

@interface SIFloatingCollectionScene : SKScene{
    
//    SKFieldNode *magneticField;             //public var karne hai
    SIFloatingCollectionSceneMode mode;     //current mode of the scene
    NSMutableArray *floatingNodes;          // array of all the nodes that will be present in the scene
    CGPoint touchPoint;     BOOL isTouchPointInitialise;
    NSTimeInterval touchStartedTime;    BOOL isTouchStartedTimeInitialised;
    NSTimeInterval removingStartedTime;     BOOL isRemovingStartedTimeInitialised;
    NSTimeInterval timeToStartRemove;
    NSTimeInterval timeToRemove;
    BOOL allowEditing;
    BOOL allowMultipleSelection;
    BOOL restrictedToBounds;
    CGFloat pushStrength;
    
    void(^nodeSelected)(NSDictionary * nodeDetail);
    
//    id floatingDelegate;
}


@property (nonatomic, weak) id<SIFloatingCollectionSceneDelegate> floatingDelegate;
@property (nonatomic, retain) SKFieldNode *magneticField;
@property (nonatomic, assign) BOOL maximumNumberOfTagsSelected;

-(CGFloat)distanceBetweenPoints:(CGPoint)firstPoint andSecondPoint:(CGPoint)secondPoint;

-(void)removeFloatinNodeAtIndex:(int)index;
-(void)initialiseAllvalues;

-(void)removeShadowNodeAtIndex:(int)index;
-(void)setNodeSelectedBlock:(void(^)(NSDictionary * nodeDetail))block;

@end
