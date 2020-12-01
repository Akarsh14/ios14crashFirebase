//
//  StickerCell.m
//  Woo
//
//  Created by Vaibhav Gautam on 08/05/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "StickerCell.h"

@implementation StickerCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *nibArray = [[NSBundle mainBundle]loadNibNamed:@"StickerCell" owner:self options:nil];
        
        [self addSubview:[nibArray lastObject]];
    }
    return self;
}

-(void)setDataOnCellFromDictionary:(NSMutableDictionary *)dataDictionary{
    if (!dataDictionary) {
        return;
    }
    cellData = dataDictionary;
    
    
    if (!activityView) {
        activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    
    [stickerThumbnail addSubview:activityView];
    activityView.center = CGPointMake(40, 40);
    [activityView startAnimating];
    activityView.hidden = FALSE;
    
  
    
    [stickerThumbnail sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kStickerBaseURL,[dataDictionary objectForKey:@"stickerURL"]]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        activityView.hidden = TRUE;
        [activityView stopAnimating];
    }];
    
}

- (IBAction)stickerTapped:(id)sender {
    if ([_delegate respondsToSelector:_selectorForStickerTapped]) {
        [_delegate performSelectorInBackground:_selectorForStickerTapped withObject:cellData];
    }
}

@end
