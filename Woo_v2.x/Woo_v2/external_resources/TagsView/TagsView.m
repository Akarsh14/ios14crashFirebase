//
//  TagsView.m
//  TagsView
//
//  Created by Vaibhav Gautam on 28/02/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "TagsView.h"

@implementation TagsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        currentXPosition = kStartXPosition;
        currentYPosition = 0;
    }
    return self;
}

-(TagsView *)initWithDataArray:(NSMutableArray *)tagsArray withWidthOfView:(float )widthOfView{
    
    widthOfTagView = widthOfView;
    
    if (!tagsArray){
        return nil;
    }else{
        _tagsDataArray = tagsArray;
    }
    self = [super init];
    
    [self createTagsArray:tagsArray];
    [self setFrame:CGRectMake(0, 0, widthOfTagView, heightOfView)];
    
    return self;
}


-(TagsView *)initWithDataArray:(NSMutableArray *)tagsArray withWidthOfView:(float )widthOfView andSelectedTag:(NSString *) selectedTag{
    
    widthOfTagView = widthOfView;
    
    if (!tagsArray){
        return nil;
    }else{
        _tagsDataArray = tagsArray;
    }
    self = [super init];
    
    [self setSelectedTag:selectedTag];
    
    [self createTagsArray:tagsArray];
    
    [self setFrame:CGRectMake(0, 0, widthOfTagView, heightOfView)];
    
    return self;
}




-(void)setTagDataArrayAndReloadView:(NSMutableArray *)tagsArray{
    if (tagsArray){
        _tagsDataArray = tagsArray;
    }
    currentXPosition = kStartXPosition;
    currentYPosition = 0;
    for (UIButton *buttonObj in self.subviews) {
        if ([buttonObj isKindOfClass:[UIButton class]]) {
            [buttonObj removeFromSuperview];
        }
    }
    [self createTagsArray:tagsArray];
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, widthOfTagView, heightOfView)];
}

-(void)createTagsArray:(NSMutableArray *)tagsArray{
    
    if (!placedTagsTempArray) {
        placedTagsTempArray = [[NSMutableArray alloc]init];
    }
    [placedTagsTempArray removeAllObjects];
    
    
    if (!tagsOfARow) {
        tagsOfARow = [[NSMutableArray alloc]init];
    }
    [tagsOfARow removeAllObjects];
    
    for (NSMutableDictionary *dataDictionary in tagsArray) {
    
        UIButton *tempButton = [self createTagFromData:dataDictionary];
    
        [self placeTagOnAppropriateLocation:tempButton];
    }
    [placedTagsTempArray addObject:tagsOfARow];
//    NSLog(@"placed tags > %@",placedTagsTempArray);
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, widthOfTagView, heightOfView)];
    [self centreAlignAllTheTags];
}


-(void)centreAlignAllTheTags{
    for (NSArray *rowTagsArray in placedTagsTempArray) {
        
        CGFloat totalWidthOfTags = 0;
        for (UIButton *tempTag in rowTagsArray) {
            
            totalWidthOfTags = tempTag.frame.origin.x + tempTag.frame.size.width+kLeftPadding;
        }
        
        CGFloat totalWidthOfView = widthOfTagView - kLeftPadding - kRightPadding;
        
        CGFloat marginToBeAdded = (totalWidthOfView - totalWidthOfTags) / 2;
        
        for (UIButton *tempTag in rowTagsArray) {
            
            [tempTag setFrame:CGRectMake(tempTag.frame.origin.x+marginToBeAdded, tempTag.frame.origin.y, tempTag.frame.size.width, tempTag.frame.size.height)];
        }
    }
}

-(void)placeTagOnAppropriateLocation:(UIButton *)tagView{

    if (widthOfTagView <= tagView.frame.size.width) {

        CGRect newFrame = tagView.frame;
        newFrame.size.width = widthOfTagView - kLeftPadding - kRightPadding - 20 - kStartXPosition;
        tagView.frame = newFrame;
    }

    if ((currentXPosition + kLeftPadding + tagView.frame.size.width) > (widthOfTagView - kLeftPadding-kRightPadding)) {
        currentXPosition = kStartXPosition;
        currentYPosition = currentYPosition + kTopPading + tagView.frame.size.height;
        
        [placedTagsTempArray addObject:tagsOfARow];
//        [tagsOfARow removeAllObjects];
        tagsOfARow = [NSMutableArray new];
        
        [self placeTagOnAppropriateLocation:tagView];
        return;
        
    }else{
        
        [tagView setFrame:CGRectMake(currentXPosition+kLeftPadding, currentYPosition+kTopPading, tagView.frame.size.width, tagView.frame.size.height)];
        currentXPosition = tagView.frame.origin.x + tagView.frame.size.width;
        
    }
    
    heightOfView = tagView.frame.origin.y+tagView.frame.size.height+kBottomPadding;

    [tagsOfARow addObject:tagView];
    [self addSubview:tagView];
    
    
}


-(UIButton *)createTagFromData:(NSMutableDictionary *)buttonData{

    UIButton *selectedTag = [UIButton buttonWithType:UIButtonTypeSystem];
//    [selectedTag setTag:[[buttonData objectForKey:kTappableTagIDKey] integerValue]];
    [selectedTag setCustomTagValue:[NSString stringWithFormat:@"%@",[buttonData objectForKey:kTappableTagIDKey]]];
    [selectedTag.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [selectedTag setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [selectedTag setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [selectedTag setContentEdgeInsets:UIEdgeInsetsMake(kTagTextTopBottomPadding, kTagTextLeftRightPadding, kTagTextTopBottomPadding, kTagTextLeftRightPadding)];

    selectedTag.layer.shouldRasterize = YES;
    selectedTag.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    [selectedTag.layer setCornerRadius:kTagsCornerRadius];
    
    [selectedTag addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    NSMutableAttributedString *attributedTagString;
    
    
    if ([[buttonData objectForKey:kTagSelectedKey] intValue]) {
        
        attributedTagString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ✕",[buttonData objectForKey:kTappableTagNameKey]]];

        [selectedTag.titleLabel setFont:kTagSelectedFont];
        [selectedTag setBackgroundColor:kTagSelectedBackgroundColor];
//        -------------------
        [attributedTagString addAttribute:NSForegroundColorAttributeName
                                     value:kTagSelectedTextColor
                                     range:NSMakeRange(0, [attributedTagString length])];
        
        [selectedTag setAttributedTitle:attributedTagString forState:UIControlStateNormal];
        
//        -------------------
    }else{
        attributedTagString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",[buttonData objectForKey:kTappableTagNameKey]]];

        [selectedTag.titleLabel setFont:kTagUnselectedFont];
        [selectedTag setBackgroundColor:kTagUnselectedBackgroundColor];

        //        -------------------
        
        [attributedTagString addAttribute:NSForegroundColorAttributeName
                                    value:kTagUnselectedTextColor
                                    range:NSMakeRange(0, [attributedTagString length])];
        
//        [attributedTagString addAttribute:NSForegroundColorAttributeName
//                                     value:kTagSelectedTextColor
//                                     range:NSMakeRange(([attributedTagString length] -2), 2)];
        [selectedTag setAttributedTitle:attributedTagString forState:UIControlStateNormal];


//        -------------------
    }
    [selectedTag sizeToFit];
    UIView *crossView = [selectedTag viewWithTag:9898];
    if (crossView) {
        [crossView removeFromSuperview];
    }
    
    if (selectedTag.frame.size.width >= (widthOfTagView -kStartXPosition-20)) {
//        NSLog(@"bada tha chota kiya hai");
        CGRect newFrame = selectedTag.frame;
        newFrame.size.width = widthOfTagView - kLeftPadding - kRightPadding - 20 - kStartXPosition;
        if ([[buttonData objectForKey:kTagSelectedKey] intValue]) {
            UILabel *crossLabel = [[UILabel alloc] init];
            crossLabel.font = kTagSelectedFont;
            crossLabel.textColor = kTagSelectedTextColor;
            crossLabel.text = @"✕";
            [crossLabel sizeToFit];
            crossLabel.tag = 9898;
            crossLabel.backgroundColor = [UIColor clearColor];
            crossLabel.frame = CGRectMake(newFrame.size.width-crossLabel.frame.size.width, 0, crossLabel.frame.size.width, newFrame.size.height);
            [selectedTag addSubview:crossLabel];
        }
        selectedTag.frame = newFrame;
    }
    
    return selectedTag;
}


-(void)buttonTapped:(id)sender{
    UIButton *btn;
    if ([sender isKindOfClass:[UIButton class]]) {
        btn = (UIButton *)sender;
    }


    
    
    [self updateTagsStatusWithNewSelectedTagID:btn.customTagValue];
    [self createTagsArray:_tagsDataArray];
//LUV_V2 why are we stillusing long value???
    NSLog(@"btn.customTagValue :%@",btn.customTagValue);
    NSString *buttonTagStr = [NSString stringWithFormat:@"%@",btn.customTagValue];
//    NSString *predicateStr = [NSString stringWithFormat:@"tagId==%@",buttonTagStr];
//    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(tagId == %@)",[NSString stringWithFormat:@"%@",buttonTagStr]];
//    NSArray *filteredArr = [_tagsDataArray filteredArrayUsingPredicate:pred];
    NSMutableArray *filteredArr = [APP_Utilities getArrayAfterFiltering:_tagsDataArray forKey:@"tagId" andForValue:[NSString stringWithFormat:@"%@",buttonTagStr]];
    
    NSDictionary *tagDetail = [filteredArr objectAtIndex:0];
    if ([[tagDetail objectForKey:@"isSelected"] boolValue]) {
        if ([_delegate respondsToSelector:_selectorForTagTapped]) {
//            [_delegate performSelectorInBackground:_selectorForTagTapped withObject:tagDetail];
            [_delegate performSelector:_selectorForTagTapped withObject:tagDetail afterDelay:0.0];
        }
    }
    else{
        if ([_delegate respondsToSelector:_selectorForTagTapped]) {
//            [_delegate performSelectorInBackground:_selectorForTagTapped withObject:nil];
            [_delegate performSelector:_selectorForTagTapped withObject:nil afterDelay:0.0];
        }
    }
    
//    if ([_delegate respondsToSelector:_selectorForTagTapped]) {
//        [_delegate performSelectorInBackground:_selectorForTagTapped withObject:tagDetail];
//    }
    
    
}

-(void)updateTagsStatusWithNewSelectedTagID:(NSString *)tappedTagID{
    
    for (NSDictionary *tagDict in [_tagsDataArray mutableCopy]) {
        
        UIView *tagRef = [self viewWithTag:[[tagDict objectForKey:kTappableTagIDKey] intValue]];
        [tagRef removeFromSuperview];
        currentXPosition = kStartXPosition;
        currentYPosition = 0;
    }
    [self setSelectedTag:tappedTagID];
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
        if ([[dict objectForKey:kTappableTagIDKey] intValue] == tagTapped) {
            hitIndex = iterator;
            dataDict = [dict mutableCopy];
        }
        iterator++;
    }
    
    if (kMaximumSelectableTags != -1) {
        if (totalSelectedTags >= kMaximumSelectableTags && [[[_tagsDataArray objectAtIndex:hitIndex] objectForKey:@"isSelected"] intValue] == 0) {
                        
//            [ALToastView toastInView:APP_DELEGATE.window withText:kMaxTagsAlert];
 
            return;
        }
    }

    NSMutableDictionary *modifiedDict = [[NSMutableDictionary alloc]init];
    [modifiedDict setObject:([[dataDict objectForKey:kTagSelectedKey] intValue]?@"0":@"1") forKey:kTagSelectedKey];
    [modifiedDict setObject:[dataDict objectForKey:kTappableTagNameKey] forKey:kTappableTagNameKey];
    [modifiedDict setObject:[dataDict objectForKey:kTappableTagIDKey] forKey:kTappableTagIDKey];
    [modifiedDict setObject:[dataDict objectForKey:kTappableTagTypeKey] forKey:kTappableTagTypeKey];
    
    if (!(hitIndex<0)) {
        [_tagsDataArray replaceObjectAtIndex:hitIndex withObject:modifiedDict];
    }

    [self toggleTagForData:modifiedDict];

    if ([_delegate respondsToSelector:_selectorForTagTapped]) {
//        [_delegate performSelectorInBackground:_selectorForTagTapped withObject:_tagsDataArray];
        [_delegate performSelector:_selectorForTagTapped withObject:_tagsDataArray afterDelay:0.0];
    }
    
}


-(void)toggleTagForData:(NSMutableDictionary *)data{
    UIButton *selectedTag = (UIButton *)[self viewWithTag:[[data objectForKey:kTappableTagIDKey]intValue]];
    
    NSMutableAttributedString *attributedTagString = [[NSMutableAttributedString alloc] initWithString:selectedTag.titleLabel.text];
    
    if ([[data objectForKey:kTagSelectedKey] intValue]) {
        
        [attributedTagString addAttribute:NSForegroundColorAttributeName
                                    value:kTagSelectedTextColor
                                    range:NSMakeRange(0, [attributedTagString length])];
        
        [selectedTag setAttributedTitle:attributedTagString forState:UIControlStateNormal];
        
        [selectedTag setTitleColor:kTagSelectedTextColor forState:UIControlStateNormal];
        [selectedTag setBackgroundColor:kTagSelectedBackgroundColor];
    }else{
        [attributedTagString addAttribute:NSForegroundColorAttributeName
                                    value:kTagUnselectedTextColor
                                    range:NSMakeRange(0, [attributedTagString length]-2)];
        
        [attributedTagString addAttribute:NSForegroundColorAttributeName
                                    value:kTagSelectedTextColor
                                    range:NSMakeRange(([attributedTagString length] -2), 2)];
        [selectedTag setAttributedTitle:attributedTagString forState:UIControlStateNormal];

        
        [selectedTag setTitleColor:kTagUnselectedTextColor forState:UIControlStateNormal];
        [selectedTag setBackgroundColor:kTagUnselectedBackgroundColor];
    }
}

-(void)setSelectedTag:(NSString *)selectedTagsID{
    if ([selectedTagsID longLongValue] < 0) {
        return;
    }
    BOOL shouldDeselectFirstTag = NO;
    
    if ([[[_tagsDataArray firstObject] objectForKey:kTagSelectedKey] longLongValue] && [[[_tagsDataArray firstObject] objectForKey:kTappableTagIDKey] longLongValue] == [selectedTagsID longLongValue]) {
        
        shouldDeselectFirstTag = YES;
        
    }
    
    for (int index= 0; index < [_tagsDataArray count]; index++) {
        NSMutableDictionary *tempDict = [[_tagsDataArray objectAtIndex:index] mutableCopy];
        [tempDict setObject:@"0" forKey:kTagSelectedKey];
        [_tagsDataArray replaceObjectAtIndex:index withObject:tempDict];
    }
    
    for (int index= 0; index < [_tagsDataArray count]; index++) {
        
        if ([[[_tagsDataArray objectAtIndex:index] objectForKey:kTappableTagIDKey] longLongValue] == [selectedTagsID longLongValue] ) {
            if (index !=0) {
                [_tagsDataArray exchangeObjectAtIndex:index withObjectAtIndex:0];
                NSMutableDictionary *tempDictionary = [[_tagsDataArray objectAtIndex:0] mutableCopy];
                [tempDictionary setObject:@"1" forKey:kTagSelectedKey];
                [_tagsDataArray replaceObjectAtIndex:0 withObject:tempDictionary];
                return;
            }else if (index == 0 && [[[_tagsDataArray firstObject] objectForKey:kTappableTagIDKey] longLongValue] == [selectedTagsID longLongValue]){
                NSMutableDictionary *tempDictionary = [[_tagsDataArray objectAtIndex:0] mutableCopy];
                
                if (shouldDeselectFirstTag) {
                    [tempDictionary setObject:@"0" forKey:kTagSelectedKey];
                }else{
                    [tempDictionary setObject:@"1" forKey:kTagSelectedKey];
                }
                [_tagsDataArray replaceObjectAtIndex:0 withObject:tempDictionary];
                
            }
        }
    }
}

-(void)selectFirstTagAutomatically{
    if ([_tagsDataArray count] <= 0) {
        return;
    }
    NSLog(@"_tagsDataArray : %@",_tagsDataArray);
    UIButton *firstTagButton = nil;
    for (id tagView in self.subviews) {
        if ([tagView isKindOfClass:[UIButton class]]) {
            UIButton *currectButton = (UIButton *)tagView;
            if ([currectButton.titleLabel.text isEqualToString:[[_tagsDataArray firstObject] objectForKey:kTappableTagNameKey]] ) {
                firstTagButton = currectButton;
                break;
            }
        }
    }
    if (firstTagButton) {
        [self buttonTapped:firstTagButton];
    }

}

@end
