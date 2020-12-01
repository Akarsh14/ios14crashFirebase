//
//  BubbleNode.h
//  testingObjcToSwitch
//
//  Created by Umesh Mishraji on 08/06/16.
//  Copyright © 2016 TP. All rights reserved.
//

#import "SIFloatingNode.h"
#import "DSMultilineLabelNode.h"

@interface BubbleNode : SIFloatingNode{
    
//    SKLabelNode *labelNode;
    
    void(^nodeDestroyedBlock)(BOOL, int, BubbleNode *);
//    BOOL isNodeSelected;
    
    CGFloat myNodeRaduis;
    
}

@property(nonatomic, retain)SKLabelNode *labelNode;
@property(nonatomic, retain)UIColor *nodeBackgroundColor;
@property (nonatomic, strong) DSMultilineLabelNode *titleNode;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) SKSpriteNode *textNode;

+(BubbleNode *)instantiate;
+(BubbleNode *)instantiateWithTitle:(NSString *)title withIndex:(int)indexVal;


-(void)nodeDestroyed:(void(^)(BOOL success, int indexValue,BubbleNode *bubbleNodeObj))block;
-(void)setLabelIndexValue:(int)indexValue;
-(void)setNodeDetailValue:(NSDictionary *)detail;
-(void)changeStateValueOfNode:(BOOL)state;
-(void)setBackgroundColor:(UIColor *)backgroundColorValue;

- (void)setTitle:(NSString *)title;

@end
