//
//  BubbleNode.m
//  testingObjcToSwitch
//
//  Created by Umesh Mishraji on 08/06/16.
//  Copyright © 2016 TP. All rights reserved.
//

#import "BubbleNode.h"

@implementation BubbleNode



+(BubbleNode *)instantiate{
    BubbleNode *node = [BubbleNode shapeNodeWithCircleOfRadius:kNodeRadius];
    [node initialiseValue];
    [self configureNode:node];
    return node;
}

+(BubbleNode *)instantiateWithTitle:(NSString *)title withIndex:(int)indexVal{
    CGFloat nodeRadius = kNodeRadius*2.5;
    
//    if ([title length] < 10) {
//        nodeRadius = 16;
//    }
//    else if([title length] < 20){
//        nodeRadius = 18;
//    }
//    else{
//        nodeRadius = kNodeRadius;
//    }
    
    if (indexVal%3 == 0) {
        nodeRadius = 18*2.5;
    }
    else if (indexVal%3 == 1){
        nodeRadius = 16*2.5;
    }
    
    if ([title length] > 16) {
        nodeRadius = 18*2.5;
    }
    
    if ([title length] > 18) {
        nodeRadius = kNodeRadius*2.5;
    }
    
    
    BubbleNode *node = [BubbleNode shapeNodeWithCircleOfRadius:nodeRadius];
    [node initialiseValue];
    [node setMyRadiusValue:nodeRadius];
    [self configureNode:node andTitle:title];
    return node;
}
-(void)initialiseValue{
    _labelNode = [[SKLabelNode alloc] init];
    _nodeBackgroundColor = [UIColor redColor];
    self.isNodeSelected = FALSE;
    [super initialiseValue];
}

-(void)setMyRadiusValue:(CGFloat)radiusValue{
    myNodeRaduis = radiusValue;
}


- (void)setTitle:(NSString *)title
{
    
    if ([title isEqualToString:@"\nFind"]) {
        SKSpriteNode *node = [[SKSpriteNode alloc]initWithImageNamed:@"findIcon"];
        node.name = @"findNode";
        node.size = CGSizeMake(8*2.5, 20*2.5);
        [self addChild:node];
    }    
    
    /*
     UIGraphicsBeginImageContextWithOptions(viewToGrab.bounds.size, NO, 0.0);  // high res
     
     // Make the CALayer to draw in our "canvas".
     [[viewToGrab layer] renderInContext: UIGraphicsGetCurrentContext()];
     
     // Fetch an UIImage of our "canvas".
     UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
     
     // Stop the "canvas" from accepting any input.
     UIGraphicsEndImageContext();
     
     // Return the image.
     return image;
     */
    
    _title = title;
    
    if ([title length] > 0) {
        UILabel *labelForImage = [[UILabel alloc] init];
        
        labelForImage.backgroundColor = [UIColor clearColor];
        labelForImage.textColor = [UIColor whiteColor];
        labelForImage.font = [UIFont fontWithName:@"Lato-Bold" size:10.0f];
        labelForImage.userInteractionEnabled = false;
        [labelForImage setTextAlignment:NSTextAlignmentCenter];
        labelForImage.numberOfLines = 0;
        labelForImage.text = _title;
        
        if ([_title length] > 26) {
           // labelForImage.font = [UIFont systemFontOfSize:9];
            
            labelForImage.font = [UIFont fontWithName:@"Lato-Bold" size:((9.0f)*2.5)];
        }else{
            //labelForImage.font = [UIFont systemFontOfSize:10];
            labelForImage.font = [UIFont fontWithName:@"Lato-Bold" size:((10.0f)*2.5)];
        }
        
        labelForImage.frame = CGRectMake(0, 0, (myNodeRaduis*1.414*2), (myNodeRaduis*1.414 *2));
        
        
        // Create a "canvas" (image context) to draw in.
        UIGraphicsBeginImageContextWithOptions(labelForImage.bounds.size, NO, 0.0);  // high res
        
        // Make the CALayer to draw in our "canvas".
        [[labelForImage layer] renderInContext: UIGraphicsGetCurrentContext()];
        
        // Fetch an UIImage of our "canvas".
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        
        // Stop the "canvas" from accepting any input.
        UIGraphicsEndImageContext();
        
        
        
        if (!_textNode) {
            SKTexture *imageTexture = [SKTexture textureWithImage:image];
            _textNode = [SKSpriteNode spriteNodeWithTexture:imageTexture];
            _textNode.name = @"title";
            _textNode.size = CGSizeMake(image.size.width/2, image.size.height/2);
            _textNode.texture.filteringMode = SKTextureFilteringNearest;
            [self addChild:_textNode];
        }
    }
    
    
    
    /**
     *  vaibhav's code ends here
     */
    
//    if (!_titleNode && [title length]>0)
//    {
//        _titleNode = [[DSMultilineLabelNode alloc] initWithFontNamed:@"Lato-Bold"];
//        
//        
//        [self addChild:_titleNode];
//    }
//    if ([title length]>26) {
//        _titleNode.fontSize = 5;
//    }
//    else{
//        _titleNode.fontSize = 6;
//    }
//    _titleNode.paragraphWidth = kNodeRadius*2 - 15;
//    _titleNode.name = @"title";
//    _titleNode.fontColor = [UIColor whiteColor];
//    _titleNode.position = CGPointZero;
//    _titleNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
//    _titleNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
//    _titleNode.userInteractionEnabled = NO;
//    _titleNode.text = title;
}



+(void)configureNode:(BubbleNode *)node{
    
    CGRect boundingBox = CGPathGetBoundingBox(node.path);
    CGFloat radius = boundingBox.size.width / 2.0;
    node.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:radius + 1.0];
    node.fillColor = [SKColor redColor];
    node.strokeColor = node.fillColor;

    node.labelNode.text = @"Hello";
    node.labelNode.position = CGPointZero;
    node.labelNode.fontSize = 15;
    node.labelNode.fontColor = [SKColor whiteColor];
    node.labelNode.userInteractionEnabled = FALSE;
    node.labelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    node.labelNode.horizontalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    [node addChild:node.labelNode];
}

+(void)configureNode:(BubbleNode *)node andTitle:(NSString *)title{
    
    CGRect boundingBox = CGPathGetBoundingBox(node.path);
    CGFloat radius = boundingBox.size.width / 2.0;
    node.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:radius + 0.8];
//    node.nodeBackgroundColor = [self getRandomColorForNode];
//    node.fillColor = node.nodeBackgroundColor;
//    node.strokeColor = node.fillColor;
    
    
    node.title = title;
//    if (!node.titleNode && [title length]>0)
//    {
//        node.titleNode = [[DSMultilineLabelNode alloc] initWithFontNamed:@"Lato-Bold"];
//        if ([title length]>26) {
//            node.titleNode.fontSize = 6;
//        }
//        else{
//            node.titleNode.fontSize = 8;
//        }
//        node.titleNode.paragraphWidth = kNodeRadius*2 - 15;
//        node.titleNode.name = @"title";
//        node.titleNode.text = title;
//        node.titleNode.fontColor = [UIColor whiteColor];
//        node.titleNode.position = CGPointZero;
//        node.titleNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
//        node.titleNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
//        node.titleNode.userInteractionEnabled = NO;
//        [node addChild:node.titleNode];
//    }
   
}

-(void)nodeDestroyed:(void(^)(BOOL success, int indexValue,BubbleNode *bubbleNodeObj))block{
    nodeDestroyedBlock = block;
}

-(void)setLabelIndexValue:(int)indexValue{
    self.labelIndex = indexValue;
}
-(void)setNodeDetailValue:(NSDictionary *)detail{
    self.nodeDetail = detail;
}
-(void)changeStateValueOfNode:(BOOL)state{
    self.isNodeSelected = state;
}

+(UIColor *)getRandomColorForNode{
    int randomValue = random()%7;
    switch (randomValue) {
        case 0:
            return [UIColor colorWithRed:0.47 green:0.64 blue:0.85 alpha:1.00];
            break;
        case 1:
            return [UIColor colorWithRed:0.57 green:0.47 blue:0.85 alpha:1.00];
            break;
        case 2:
            return [UIColor colorWithRed:0.77 green:0.85 blue:0.48 alpha:1.00];
            break;
        case 3:
            return [UIColor colorWithRed:0.85 green:0.46 blue:0.48 alpha:1.00];
            break;
        case 4:
            return [UIColor colorWithRed:0.85 green:0.56 blue:0.47 alpha:1.00];
            break;
        case 5:
            return [UIColor colorWithRed:0.47 green:0.85 blue:0.54 alpha:1.00];
            break;
        case 6:
            return [UIColor colorWithRed:0.90 green:0.35 blue:0.36 alpha:1.00];
            break;
        default:
            return [UIColor colorWithRed:0.47 green:0.64 blue:0.85 alpha:1.00];
            break;
    }
    return [UIColor colorWithRed:0.47 green:0.64 blue:0.85 alpha:1.00];
}

-(void)setBackgroundColor:(UIColor *)backgroundColorValue{
    _nodeBackgroundColor = backgroundColorValue;
    self.fillColor = backgroundColorValue;
    self.strokeColor = [UIColor clearColor];
}

-(SKAction *)selectingAnimation{
    if ([[self.nodeDetail valueForKey:kTagsIdKey] intValue] == 9991999) {
        return nil;
    }
    [self removeActionForKey:[BubbleNode getRemovingKey]];
    SKAction *scaleUp = [SKAction scaleTo:1.5 duration:kBubbleScaleUpTime];
    SKAction *scaleDown = [SKAction scaleTo:0.0 duration:kBubbleScaleDownTime];
    SKAction *animateNode = [SKAction sequence:[NSArray arrayWithObjects:scaleUp, scaleDown, nil]];
    
    
    if (!self.isNodeSelected) {
        return animateNode;
    }
    return nil;
}

-(void)selectAnimationDone{
    NSLog(@"yaha aa gaya hai");
//    [self.titleNode removeFromParent];
    nodeDestroyedBlock(TRUE, self.labelIndex, self);
}

-(SKAction *)normalizeAnimation{
    [self removeActionForKey:[BubbleNode getRemovingKey]];
    return [SKAction scaleTo:1 duration:0.2];
}

-(SKAction *)removeAnimation{
    [self removeActionForKey:[BubbleNode getRemovingKey]];
    return [SKAction fadeOutWithDuration:0.2];
}

-(SKAction *)removingAnimation{
    SKAction *pulseUp = [SKAction scaleTo:self.xScale+0.13 duration:0.0];
    SKAction *pulseDown = [SKAction scaleTo:self.xScale duration:0.3];
    SKAction *pulse = [SKAction sequence:[NSArray arrayWithObjects:pulseUp, pulseDown, nil]];
    SKAction *repeatPulse = [SKAction repeatActionForever:pulse];
    return repeatPulse;
}

@end
