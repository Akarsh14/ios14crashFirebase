//
//  DefaultCropperView.m
//  Woo_v2
//
//  Created by Deepak Gupta on 8/23/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "DefaultCropperView.h"
#import "LoginModel.h"

@interface DefaultCropperView (){
    PhotoOptionsTappedBlock _tapBlock;
    __weak IBOutlet UIButton *btnFacebook;
}

@end

@implementation DefaultCropperView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



/*Description: This blocks is going to call in the method _cropperView actionPerformedWithBlock on VPImageCropeerViewController
 */
- (IBAction)btnCamera:(id)sender {
    _tapBlock(100);
}
- (IBAction)btnGallery:(id)sender {
    _tapBlock(200);
}
- (IBAction)btnFacebook:(id)sender {
   _tapBlock(300);
}

- (void)actionPerformedWithBlock:(PhotoOptionsTappedBlock)block{
    _tapBlock = block;
}




-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    //check if memory is allocated to self
    if (self) {
        //getting array of views from the xib
        NSArray *viewArrayFromXib = [[NSBundle mainBundle] loadNibNamed:@"DefaultCropperView" owner:self options:nil];
        UIView *viewObj = [viewArrayFromXib firstObject];
        
 //       int width = SCREEN_WIDTH * .7361;
//        viewObj.frame = CGRectMake((SCREEN_WIDTH - width)/2,0.122*SCREEN_HEIGHT, width, 0.655*SCREEN_HEIGHT);

        
        
        [_botImg sd_setImageWithURL:[LoginModel sharedInstance].botUrl completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        }];

        viewObj.frame = self.bounds;
        [self addSubview:viewObj];
        
        
        
    }
    return self;
}
@end
