//  ERJustifiedFlowLayout.m

/* Copyright (c) 2015 Evan Roth
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
 modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
 is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
 OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "ERJustifiedFlowLayout.h"

@implementation ERJustifiedFlowLayout

-(CGSize)collectionViewContentSize {
    if (self.horizontalJustification == FlowLayoutHorizontalJustificationLeft) {
        CGSize oldSize = [super collectionViewContentSize];
        NSArray *attributes = [self layoutAttributesForElementsInRect:CGRectMake(0, 0, oldSize.width, oldSize.height)];
        UICollectionViewLayoutAttributes *attrs = attributes.lastObject;
        CGFloat height = attrs.frame.origin.y + attrs.size.height;

        return CGSizeMake(CGRectGetWidth(self.collectionView.bounds), height + self.sectionInset.bottom);
    }

    return [super collectionViewContentSize];
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
	
    if (self.horizontalJustification == FlowLayoutHorizontalJustificationLeft) {
        CGSize oldSize = [super collectionViewContentSize];
        NSArray *attributesForElementsInRect = [super layoutAttributesForElementsInRect:CGRectMake(0, 0, oldSize.width, oldSize.height)];
        NSMutableArray *newAttributesForElementsInRect = [[NSMutableArray alloc] initWithCapacity:attributesForElementsInRect.count];
        
        CGFloat leftMargin = self.sectionInset.left;
        CGFloat topMargin = self.sectionInset.top;
        
        // Assumes attributes are in order by index path
        for (NSUInteger idx = 0; idx < attributesForElementsInRect.count; idx++) {
            UICollectionViewLayoutAttributes *attributes = attributesForElementsInRect[idx];
            
            CGRect newLeftAlignedFrame = attributes.frame;
            newLeftAlignedFrame.origin.x = leftMargin;
            newLeftAlignedFrame.origin.y = topMargin;
            attributes.frame = newLeftAlignedFrame;
            
            if (leftMargin + attributes.frame.size.width > CGRectGetWidth(rect) - self.sectionInset.right) {
                CGRect newLeftAlignedFrame = attributes.frame;
                newLeftAlignedFrame.origin.x = self.sectionInset.left;
                newLeftAlignedFrame.origin.y += CGRectGetHeight(newLeftAlignedFrame) + MAX(self.sectionInset.top, self.minimumLineSpacing);
                
                attributes.frame = newLeftAlignedFrame;
                leftMargin = self.sectionInset.left;
                topMargin = newLeftAlignedFrame.origin.y;
            }
            
            leftMargin += attributes.frame.size.width + self.horizontalCellPadding;
            
            [newAttributesForElementsInRect addObject:attributes];
        }
        
        return newAttributesForElementsInRect;
    }
	if (self.horizontalJustification == FlowLayoutHorizontalJustificationFull) {
		return [super layoutAttributesForElementsInRect:rect];
	}
	
    if (self.horizontalJustification == FlowLayoutHorizontalJustificationRight) {
        NSArray *attributesForElementsInRect = [super layoutAttributesForElementsInRect:rect];
        NSMutableArray *newAttributesForElementsInRect = [[NSMutableArray alloc] initWithCapacity:attributesForElementsInRect.count];
        
        CGFloat rightMargin = 0.0;
        int startingRowIndex = 0;
        int endingRowIndex = 0;
        int idx = 0;
        
        // Assumes attributes are in order by index path
        for (UICollectionViewLayoutAttributes *anAttribute in attributesForElementsInRect) {
            [newAttributesForElementsInRect addObject:anAttribute];
            
            // Pull out the last cell on each line, indicated by its x-origin and width adding up to the size of the collectionView minus
            // the right sectionInset.  On the last line of the collection view, the right-most cell may not be initially placed at the
            // far right-hand side, so we check if it's the last element in the array in that case
            if (anAttribute.frame.origin.x + anAttribute.frame.size.width == rect.size.width - self.sectionInset.right || [attributesForElementsInRect indexOfObjectIdenticalTo:anAttribute] == attributesForElementsInRect.count-1) {
                rightMargin = rect.size.width - anAttribute.bounds.size.width - self.sectionInset.right;
                CGRect newRightAlignedFrame = anAttribute.frame;
                newRightAlignedFrame.origin.x = rightMargin;
                anAttribute.frame = newRightAlignedFrame;
                endingRowIndex = idx;
                
                // Iterate back to the first cell in that row from the current position and readjust x-origin based on the last cell's position
                for (int i = endingRowIndex-1; i >= startingRowIndex; i--) {
                    UICollectionViewLayoutAttributes *prevAttribute = attributesForElementsInRect[i];
                    newRightAlignedFrame = prevAttribute.frame;
                    newRightAlignedFrame.origin.x = rightMargin - prevAttribute.bounds.size.width - self.horizontalCellPadding;
                    
                    if (newRightAlignedFrame.origin.x < 0) {
                        newRightAlignedFrame.origin.x = CGRectGetWidth(rect) - self.sectionInset.right - CGRectGetWidth(prevAttribute.frame);
                    }
                    
                    prevAttribute.frame = newRightAlignedFrame;
                    rightMargin = newRightAlignedFrame.origin.x;
                    [newAttributesForElementsInRect replaceObjectAtIndex:i withObject:prevAttribute];
                }
                
                startingRowIndex = ++endingRowIndex;
            }
            idx++;
        }
        
        return newAttributesForElementsInRect;
    }
    else if (self.horizontalJustification == FlowLayoutHorizontalJustificationCenter) {
        NSLog(@"rect : %@",NSStringFromCGRect(rect));
        NSArray *attributesForElementsInRect = [super layoutAttributesForElementsInRect:rect];
        NSMutableArray *newAttributesForElementsInRect = [[NSMutableArray alloc] initWithCapacity:attributesForElementsInRect.count];
        
        CGFloat rightMargin = 0.0;
        int startingRowIndex = 0;
        int endingRowIndex = 0;
        int idx = 0;
        
        CGFloat topMargin = self.sectionInset.top;
        
        float yPos = topMargin;
        
        NSLog(@"self.collectionView.frame.size.height : %f",(self.collectionView.frame.size.height));

        int numberOfRowThatAreVisible = (int)(self.collectionView.frame.size.height)/42.0;
        int maximumYPosThatWillBeSupported = ((numberOfRowThatAreVisible-1)*42) + topMargin;
        
        // Assumes attributes are in order by index path
        for (UICollectionViewLayoutAttributes *anAttribute in attributesForElementsInRect) {
            [newAttributesForElementsInRect addObject:anAttribute];
            
            
            if((yPos != anAttribute.frame.origin.y) || (idx == ([attributesForElementsInRect count]-1))){
                //Moved to next row >> adjust previous row
                BOOL yPosWasChanged = FALSE;
                if (yPos !=anAttribute.frame.origin.y) {
                    yPosWasChanged = TRUE;
                }
                endingRowIndex = idx-1;
                
                [self adjustViewStartValue:startingRowIndex endRow:endingRowIndex completeAttributeArray:attributesForElementsInRect withRect:rect withNewAttributeArray:newAttributesForElementsInRect];
                
                if (yPosWasChanged) {
                    startingRowIndex = ++endingRowIndex;
                }
                if ((anAttribute.frame.origin.y >maximumYPosThatWillBeSupported) && _notifyWhenTagWillGoBeyondViewHeight) {
                    NSLog(@"ye wala jayega bahar");
                    tagWillMoveOutOfSight(idx, TRUE);
                    return nil;
                }
                
                if (idx == ([attributesForElementsInRect count]-1)) {
                    [self adjustViewStartValue:startingRowIndex endRow:idx completeAttributeArray:attributesForElementsInRect withRect:rect withNewAttributeArray:newAttributesForElementsInRect];
                }
                
                
                
            }
            
            yPos = anAttribute.frame.origin.y;
            
            idx++;
        }
        
        return newAttributesForElementsInRect;
    }
	
	NSAssert(NO, @"Must provide a horizontal justification for FlowLayoutHorizontalJustification");
	return nil;
}

-(void)adjustViewStartValue:(int)startingRowIndex endRow:(int)endingRowIndex completeAttributeArray:(NSArray *)attributesForElementsInRect withRect:(CGRect)rect withNewAttributeArray:(NSMutableArray *)newAttributesForElementsInRect{
    
    int numberOfElementInRow = 0;
    int totalWidthOfAllTags = 0;
    for (int i=endingRowIndex; i >= startingRowIndex; i--) {
        numberOfElementInRow++;
        UICollectionViewLayoutAttributes *prevAttribute = attributesForElementsInRect[i];
        totalWidthOfAllTags += prevAttribute.bounds.size.width;
    }
    
    totalWidthOfAllTags += ((numberOfElementInRow-1)*self.horizontalCellPadding);
    int startXPosForCenterAllign = (rect.size.width - self.sectionInset.right-totalWidthOfAllTags)/2;
    if (startXPosForCenterAllign<self.sectionInset.left) {
        startXPosForCenterAllign = self.sectionInset.left;
    }
    
    for (int i=startingRowIndex; i<=endingRowIndex; i++) {
        UICollectionViewLayoutAttributes *prevAttribute = attributesForElementsInRect[i];
        CGRect newFrame = prevAttribute.frame;
        newFrame.origin.x = startXPosForCenterAllign;
        prevAttribute.frame = newFrame;
        startXPosForCenterAllign = startXPosForCenterAllign + newFrame.size.width + self.horizontalCellPadding;
        [newAttributesForElementsInRect replaceObjectAtIndex:i withObject:prevAttribute];
    }
}

-(void)setHorizontalJustification:(FlowLayoutHorizontalJustification)horizontalJustification {
	if (horizontalJustification == FlowLayoutHorizontalJustificationNone) {
		NSAssert(NO, @"Sorry, centered horizontal justification hasn't been implemented yet.");
	}
	else {
		_horizontalJustification = horizontalJustification;
	}
}
-(void)setVerticalJustification:(FlowLayoutVerticalJustification)verticalJustification {
	NSAssert(NO, @"Sorry, vertical justification hasn't been implemented yet.");
}
-(void)setTagIsMovingOutOfViewBlock:(void(^)(int indexOfTag, BOOL isTagMoving))block{
    tagWillMoveOutOfSight = block;
}

@end
