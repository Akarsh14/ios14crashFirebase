//
//  PhotoSelectionCell.m
//  Woo
//
//  Created by Vaibhav Gautam on 14/02/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "PhotoSelectionCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation PhotoSelectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *cellNib = [[NSBundle mainBundle]loadNibNamed:@"PhotoSelectionCell" owner:self options:nil];
        [self addSubview:[cellNib lastObject]];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


-(void)updateDataOnCellFromDictionay:(NSMutableDictionary *)dataDict{

    if (!dataDict) {
        return;
    }
    cellData = dataDict;
    
    
    NSString *urlString =[NSString stringWithFormat:@"%@?width=%d&height=%d&url=%@",kImageCroppingServerURL,IMAGE_SIZE_FOR_POINTS(108),IMAGE_SIZE_FOR_POINTS(108), [APP_Utilities encodeFromPercentEscapeString:[dataDict objectForKey:kBigImageSourceKey]]];
    
    
    [cellImage sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:GET_SAME_GENDER_PLACEHOLDER completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    }];
    
}

- (IBAction)imageButtonTapped:(id)sender {
    if ([_delegate respondsToSelector:_selectorOnButtonTapped]) {
        [_delegate performSelector:_selectorOnButtonTapped withObject:cellData];
    }
}

@end
