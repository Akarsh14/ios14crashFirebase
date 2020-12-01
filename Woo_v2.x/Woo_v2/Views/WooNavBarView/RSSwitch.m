//
//  RSSwitch.m
//  
//
//  Created by Roman Simenok on 10/15/15.
//  Copyright © 2015 Roman Simenok. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


#import "RSSwitch.h"

@interface RSSwitch () {
    BOOL bMoved; // this variable need to detect if we move or just pressed swith
    BOOL prevState; // this variable need to check if value was changed or no
}

@end

@implementation RSSwitch

-(instancetype)init {
    if (self = [super init]) {
        [self mainInit];
    }
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self mainInit];
    }
    
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self mainInit];
    }

    return self;
}

-(void)mainInit {
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor blackColor];
    self.layer.cornerRadius = self.bounds.size.height/2;
    
    [self setBorderColor:[UIColor clearColor]];
    
    self.borderView = [[UIView alloc] initWithFrame:self.bounds];
    self.borderView.layer.cornerRadius = self.bounds.size.height/2;
    self.borderView.backgroundColor = [UIColor clearColor];
    self.borderView.layer.borderWidth = 1.0;
    self.borderView.layer.borderColor = [UIColor clearColor].CGColor;
    self.onState = [[UIView alloc] initWithFrame:CGRectMake(-(self.bounds.size.width-self.bounds.size.height), 0, self.bounds.size.width-self.bounds.size.height/2, self.bounds.size.height)];
    self.offState = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.height/2, 0, self.bounds.size.width-self.bounds.size.height/2, self.bounds.size.height)];
    self.handleView = [[UIImageView alloc] initWithFrame:CGRectMake(self.onState.bounds.size.width-self.onState.bounds.size.height/2 -1, -1, self.onState.bounds.size.height + 2, self.onState.bounds.size.height + 2)];
    self.handleView.layer.borderColor = [UIColor clearColor].CGColor;
    self.handleView.layer.borderWidth = 1.0;
    self.handleView.layer.cornerRadius = self.handleView.bounds.size.height/2;
}

#pragma mark - Setters

-(void)setOnColor:(UIColor *)onColor {
    self.onState.backgroundColor = onColor;
}

-(void)setOffColor:(UIColor *)offColor {
    self.backgroundColor = offColor;
    self.offState.backgroundColor = offColor;
}

-(void)setBorderColor:(UIColor *)borderColor {
    self.borderView.layer.borderColor = borderColor.CGColor;
}

-(void)setBorderWidth:(NSInteger)borderWidth {
    self.borderView.layer.borderWidth = borderWidth;
}

-(void)setHandleImage:(UIImage *)handleImage {
    self.handleView.backgroundColor = [UIColor clearColor];
    self.handleView.layer.borderColor = [UIColor clearColor].CGColor;
    self.handleView.layer.borderWidth = 0.0;
    self.handleView.layer.cornerRadius = 0.0;
    self.handleView.image = handleImage;
}

-(void)setOn:(BOOL)On {
    [self setOn:On animated:NO];
}

-(void)setOn:(BOOL)On animated:(BOOL)animated {
    [UIView animateWithDuration:animated ? 0.1 : 0.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (On) {
            self.onState.frame = CGRectMake(0, 0, self.onState.bounds.size.width, self.onState.bounds.size.height);
            self.offState.frame = CGRectMake(self.onState.bounds.size.width, 0, self.offState.bounds.size.width, self.offState.bounds.size.height);
        }else{
            self.onState.frame = CGRectMake(-(self.onState.bounds.size.width-self.onState.bounds.size.height/2), 0, self.onState.bounds.size.width, self.onState.bounds.size.height);
            self.offState.frame = CGRectMake(self.offState.bounds.size.height/2, 0, self.offState.bounds.size.width, self.offState.bounds.size.height);
        }
    } completion:nil];
}

#pragma mark - Getters

-(BOOL)isOn {
    return (self.onState.frame.origin.x+self.onState.frame.size.width == self.bounds.size.width-self.bounds.size.height/2);
}

#pragma mark - Gestures

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // save previous value to prevent sending actions when value wasn't changed.
    prevState = self.isOn;
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    bMoved = YES;
    CGPoint point = [[[event allTouches] anyObject] locationInView:self];
    
    if (point.x > self.bounds.size.height/2 && point.x < self.bounds.size.width-self.bounds.size.height/2) {
        self.onState.frame = CGRectMake(point.x-self.onState.frame.size.width, 0, self.onState.frame.size.width, self.onState.frame.size.height);
        self.offState.frame = CGRectMake(self.onState.frame.origin.x+self.onState.frame.size.width, 0, self.offState.frame.size.width, self.offState.frame.size.height);
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (bMoved) {
        bMoved = NO;
        [self setOn:(self.onState.frame.origin.x+self.onState.frame.size.width > self.bounds.size.width/2) animated:YES];
    }else{
        [self setOn:!self.isOn animated:YES];
    }
    
    if (prevState == self.isOn) {
        return;
    }
    
    [self sendActionsForControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
}

- (void)isShownInDiscover:(BOOL)shownInDiscover{

    if (shownInDiscover == true) {
        self.onState.backgroundColor = UIColorFromRGB(0x6D4BC3);
        self.offState.backgroundColor = UIColorFromRGB(0xC3B3EB);
        self.handleView.image = [UIImage imageNamed:@"ic_switch_wooglobe_white"];
        self.handleView.backgroundColor = [UIColor clearColor];
        [self.handleView setFrame:CGRectMake(self.onState.bounds.size.width-self.onState.bounds.size.height/2 -1, -1, self.onState.bounds.size.height + 2, self.onState.bounds.size.height + 2)];
    }
    else{
        self.onState.backgroundColor = UIColorFromRGB(0x4BA2BB);
        self.offState.backgroundColor = UIColorFromRGB(0x9ED5E5);
        self.handleView.image = nil;
        self.handleView.backgroundColor = [UIColor whiteColor];
        [self.handleView setFrame:CGRectMake(self.onState.bounds.size.width-self.onState.bounds.size.height/2, 0, self.onState.bounds.size.height, self.onState.bounds.size.height)];

    }
    
    [self addSubview:self.offState];
    [self addSubview:self.borderView];
    [self addSubview:self.onState];
    [self.onState addSubview:self.handleView];
}

@end
