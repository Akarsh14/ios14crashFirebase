//
//  UnderLineButton.m
//  UnderlineButton
//
//  Created by Deepak Gupta on 11/27/15.
//  Copyright © 2015 Deepak Gupta. All rights reserved.
//

#import "DY_UnderLineButton.h"

@implementation DY_UnderLineButton


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void) setIsTagable:(BOOL)isTagable{
    _isTagable = isTagable;
    if (_isTagable){
        self.userInteractionEnabled = true;
    }
    else
        self.userInteractionEnabled = false;
    
    self.titleLabel.lineBreakMode = (NSLineBreakByTruncatingTail);
    self.titleLabel.numberOfLines = 1;
    
}


- (void) setLineColor:(UIColor *)lineColor{
    _lineColor = lineColor;
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    // Drawing code
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    //    red color line = rgb(247,183,184)
    
    //    blue color line = rgb(124,210,241)
    
//    NSLog(@" LINE CGCOLOR = %@",self.lineColor.CGColor);
//    NSLog(@"LINE COLOR = %@",self.lineColor);
    const CGFloat* colors = CGColorGetComponents( self.lineColor.CGColor);
    if(context){
        if (colors) {
            CGContextSetRGBStrokeColor(context, colors[0] , colors[1], colors[2], 1.0);
        }else{
            CGContextSetRGBStrokeColor(context, 247.0f/255.0f, 183.0f/255.0f, 183.0f/255.0f, 1.0f);
        }
        CGContextSetLineWidth(context, 1.0f);
        CGContextMoveToPoint(context, 0, self.bounds.size.height - 2.0);
        CGContextAddLineToPoint(context, self.frame.size.width, self.bounds.size.height - 2.0);
        CGContextStrokePath(context);
    }
}


- (void) setButtonPropertyDataCommonWithName : (NSString *)name withTagId : (NSNumber *)tagId withTagsDToType : (NSString *)tagsDtoType withIsTagable : (BOOL)isTagable withIsCommon : (BOOL) isCommon{
    
    self.isTagable = isTagable ? isTagable : FALSE;   // Setting isTagable
    self.name = [name length] ? name : @"";  // Setting Taggable Name
    if ([tagId isKindOfClass:[NSString class]]) {
        self.tagId = (NSString *)tagId;
    }
    else{
        self.tagId = [[tagId stringValue] length] ? [tagId stringValue] : @""; // Setting Taggable TagId
    }
    
    self.tagsDtoType = [tagsDtoType length] ? tagsDtoType : @""; // Setting Taggable type
    self.isCommon = isCommon ? isCommon : FALSE;
    _tagDataDict = @{kTappableTagIDKey:self.tagId, kTappableTagNameKey:self.name, kTappableTagTypeKey:self.tagsDtoType, kIsCommon:[NSNumber numberWithBool:isCommon], kIsTaggable:[NSNumber numberWithBool:isTagable]};
}


- (void) setButtonLineColorBasedOnisTaggableIsCommonWithName : (NSString *)name withTagId : (NSNumber *)tagId withTagsDToType : (NSString *)tagsDtoType withIsTagable : (BOOL)isTagable withIsCommon : (BOOL) isCommon{

    [self setTitle:name forState:UIControlStateNormal];
    [self setTitle:name forState:UIControlStateSelected];
    
    if (isCommon && isTagable) {
        
        /******** if isCommon = 1  & isTaggable = 1, set text blue color  ********/
        
        [self setTitleColor:kBlueTagColor forState:UIControlStateNormal];
        self.lineColor = kBlueLineColor;

    }else if (isTagable){
        
        /******** if isCommon = 0  & isTaggable = 1, set text red color   **********/
        
        [self setTitleColor:kRedTagColor forState:UIControlStateNormal];
        [self setTitleColor:kRedTagColor forState:UIControlStateSelected];
        self.lineColor = kRedLineColor;


        
    }else{
        /******** if (isCommon = 0  && isTaggable = 0 ) or if (isCommon = 1 && isTaggable = 0) , set text gray color   **********/
        
        [self setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        self.lineColor = kWhiteColor;
        
    }
    [self setButtonPropertyDataCommonWithName:name
                                    withTagId:tagId
                              withTagsDToType:tagsDtoType
                                withIsTagable:isTagable
                                 withIsCommon:isCommon];
    
    [self setNeedsDisplay];
}

@end
