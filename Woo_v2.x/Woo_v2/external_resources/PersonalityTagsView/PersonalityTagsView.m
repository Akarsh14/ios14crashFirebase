//
//  PersonalityTagsView.m
//  PersonalityTagsView
//
//  Created by Vaibhav Gautam on 28/02/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "PersonalityTagsView.h"

@implementation PersonalityTagsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        currentXPosition = 0;
        currentYPosition = 0;
    }
    return self;
}

-(PersonalityTagsView *)initWithDataArray:(NSMutableArray *)tagsArray{

    if (!tagsArray){
        return nil;
    }else{
        _tagsDataArray = tagsArray;
    }
    self = [super init];
    
    [self createTagsArray:tagsArray];
    [self setFrame:CGRectMake(0, 0, kWidthOfTagView, heightOfView)];
    
    return self;
}

-(void)setTagDataArrayAndReloadView:(NSMutableArray *)tagsArray{
    if (tagsArray){
        _tagsDataArray = tagsArray;
    }
    currentXPosition = 0;
    currentYPosition = 0;
    for (UIButton *buttonObj in self.subviews) {
        if ([buttonObj isKindOfClass:[UIButton class]]) {
            [buttonObj removeFromSuperview];
        }
    }
    [self createTagsArray:tagsArray];
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, kWidthOfTagView, heightOfView)];
}

-(void)createTagsArray:(NSMutableArray *)tagsArray{
    
    for (NSMutableDictionary *dataDictionary in tagsArray) {
    
        UIButton *tempButton = [self createTagFromData:dataDictionary];
     
        [self placeTagOnAppropriateLocation:tempButton];
    }
    
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, kWidthOfTagView, heightOfView)];
}


-(void)placeTagOnAppropriateLocation:(UIButton *)tagView{
    //    NSLog(@"widthOfTagView : %f",widthOfTagView);
    //    NSLog(@"widht of tag : %f",tagView.frame.size.width);
    if (kWidthOfTagView <= tagView.frame.size.width) {
        //        NSLog(@"marega ab");
        CGRect newFrame = tagView.frame;
        newFrame.size.width = kWidthOfTagView - kLeftPadding - kRightPadding - 20 - kStartXPosition;
        tagView.frame = newFrame;
    }
    
    if ((currentXPosition + kLeftPadding + tagView.frame.size.width) > (kWidthOfTagView - kLeftPadding-kRightPadding)) {
        currentXPosition = kStartXPosition;
        currentYPosition = currentYPosition + kTopPading + tagView.frame.size.height;
        [self placeTagOnAppropriateLocation:tagView];
        return;
    }else{
        [tagView setFrame:CGRectMake(currentXPosition+kLeftPadding, currentYPosition+kTopPading, tagView.frame.size.width, tagView.frame.size.height)];
        currentXPosition = tagView.frame.origin.x + tagView.frame.size.width;
    }
    
    heightOfView = tagView.frame.origin.y+tagView.frame.size.height+kBottomPadding;
    [self addSubview:tagView];
    
}


-(UIButton *)createTagFromData:(NSMutableDictionary *)buttonData{

    UIButton *selectedTag = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [selectedTag setTag:[[buttonData objectForKey:kTagIDKey] intValue]];
    [selectedTag setTitle:[buttonData objectForKey:@"tagText"] forState:UIControlStateNormal];
    [selectedTag setTagTypeKey:[buttonData objectForKey:kTappableTagTypeKey]];
    
    [selectedTag setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [selectedTag setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [selectedTag setContentEdgeInsets:UIEdgeInsetsMake(kTagTextTopBottomPadding, kTagTextLeftRightPadding, kTagTextTopBottomPadding, kTagTextLeftRightPadding)];

    selectedTag.layer.shouldRasterize = YES;
    selectedTag.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    [selectedTag.layer setCornerRadius:kTagsCornerRadius];
    
    [selectedTag addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([[buttonData objectForKey:kTagSelectedKey] intValue]) {
        [selectedTag.titleLabel setFont:kTagSelectedFont];
        [selectedTag setTitleColor:kTagSelectedTextColor forState:UIControlStateNormal];
        [selectedTag setBackgroundColor:kTagSelectedBackgroundColor];
    }else{
        [selectedTag.titleLabel setFont:kTagUnselectedFont];
        [selectedTag setTitleColor:kPersonalityUnselectedTextColor forState:UIControlStateNormal];
        [selectedTag setBackgroundColor:kPersonalityUnselectedBackground];
    }
    [selectedTag sizeToFit];
    return selectedTag;
}


-(void)buttonTapped:(id)sender{
    UIButton *btn;
    if ([sender isKindOfClass:[UIButton class]]) {
        btn = (UIButton *)sender;
    }
    [self toggleStatusOfTagTapped:btn.tag];
}


-(void)toggleStatusOfTagTapped:(int )tagTapped{
    
    int hitIndex = -1;
    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc]init];

    int totalSelectedTags = 0;

    int iterator = 0;
    
    for (NSDictionary *dict in _tagsDataArray) {
        if ([[dict objectForKey:@"isSelected"] intValue] == 1) {
            totalSelectedTags++;
        }
        if ([[dict objectForKey:kTagIDKey] intValue] == tagTapped) {
            hitIndex = iterator;
            dataDict = [dict mutableCopy];
        }
        iterator++;
    }
    
    if (kMaximumSelectableTags != -1) {
        if (totalSelectedTags >= kMaximumSelectableTags && [[[_tagsDataArray objectAtIndex:hitIndex] objectForKey:@"isSelected"] intValue] == 0) {
                        
            SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"Please deselect a tag to select another tag",nil));
            return;
        }
    }

    NSMutableDictionary *modifiedDict = [[NSMutableDictionary alloc]init];
    [modifiedDict setObject:([[dataDict objectForKey:kTagSelectedKey] intValue]?@"0":@"1") forKey:kTagSelectedKey];
    [modifiedDict setObject:[dataDict objectForKey:@"tagText"] forKey:@"tagText"];
    [modifiedDict setObject:[dataDict objectForKey:kTagIDKey] forKey:kTagIDKey];
    [modifiedDict setObject:[dataDict objectForKey:kTappableTagTypeKey] forKey:kTappableTagTypeKey];
    
    if (!(hitIndex<0)) {
        [_tagsDataArray replaceObjectAtIndex:hitIndex withObject:modifiedDict];
    }

    [self toggleTagForData:modifiedDict];

    if ([_delegate respondsToSelector:_selectorForTagTapped]) {
        [_delegate performSelectorInBackground:_selectorForTagTapped withObject:_tagsDataArray];
    }
    
}


-(void)toggleTagForData:(NSMutableDictionary *)data{
    UIButton *selectedTag = (UIButton *)[self viewWithTag:[[data objectForKey:kTagIDKey]intValue]];
    
    if ([[data objectForKey:kTagSelectedKey] intValue]) {
        [selectedTag.titleLabel setFont:kTagSelectedFont];
        [selectedTag setTitleColor:kTagSelectedTextColor forState:UIControlStateNormal];
        [selectedTag setBackgroundColor:kTagSelectedBackgroundColor];
    }else{
        [selectedTag.titleLabel setFont:kTagUnselectedFont];
        [selectedTag setTitleColor:kPersonalityUnselectedTextColor forState:UIControlStateNormal];
        [selectedTag setBackgroundColor:kPersonalityUnselectedBackground];
    }
}



@end
