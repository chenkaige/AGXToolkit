//
//  AGXSwitch.m
//  AGXWidget
//
//  Created by Char Aznable on 2016/6/13.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <AGXCore/AGXCore/NSNumber+AGXCore.h>
#import <AGXCore/AGXCore/UIView+AGXCore.h>
#import <AGXCore/AGXCore/UIColor+AGXCore.h>
#import "AGXSwitch.h"

@implementation AGXSwitch {
    NSNumber *_slideHeight;
    NSNumber *_thumbRadius;

    UIColor *_onColor;
    UIColor *_offColor;
    UIColor *_thumbColor;

    CALayer *_slideLayer;
    CALayer *_thumbLayer;
}

- (void)agxInitial {
    [super agxInitial];
    self.backgroundColor = UIColor.clearColor;

    _slideLayer = [[CALayer alloc] init];
    [self.layer addSublayer:_slideLayer];

    _thumbLayer = [[CALayer alloc] init];
    _thumbLayer.shadowOpacity = 0.3;
    _thumbLayer.shadowOffset = CGSizeMake(0, 3);
    [self.layer addSublayer:_thumbLayer];
}

- (void)dealloc {
    AGX_RELEASE(_slideHeight);
    AGX_RELEASE(_thumbRadius);
    AGX_RELEASE(_onColor);
    AGX_RELEASE(_offColor);
    AGX_RELEASE(_thumbColor);
    AGX_RELEASE(_slideLayer);
    AGX_RELEASE(_thumbLayer);
    AGX_SUPER_DEALLOC;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat slideHeight = self.slideHeight;
    _slideLayer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    _slideLayer.bounds = CGRectMake(0, 0, self.bounds.size.width, slideHeight);
    _slideLayer.cornerRadius = slideHeight/2;
    _slideLayer.backgroundColor = _on ? self.onColor.CGColor : self.offColor.CGColor;

    CGFloat thumbRadius = self.thumbRadius;
    _thumbLayer.position = CGPointMake(_on ? self.bounds.size.width-slideHeight/2 : slideHeight/2, self.bounds.size.height/2);
    _thumbLayer.bounds = CGRectMake(0, 0, thumbRadius*2, thumbRadius*2);
    _thumbLayer.cornerRadius = thumbRadius;
    _thumbLayer.backgroundColor = self.thumbColor.CGColor;
}

-(CGFloat)slideHeight {
    CGFloat defaultSlideHeight = MIN(self.bounds.size.width*3/5, self.bounds.size.height);
    return _slideHeight ? BETWEEN(_slideHeight.cgfloatValue, 0, defaultSlideHeight) : defaultSlideHeight;
}

- (void)setSlideHeight:(CGFloat)slideHeight {
    if AGX_EXPECT_F(_slideHeight.cgfloatValue == slideHeight) return;
    AGX_RELEASE(_slideHeight);
    _slideHeight = AGX_RETAIN([NSNumber numberWithCGFloat:slideHeight]);
    [self setNeedsLayout];
}

-(CGFloat)thumbRadius {
    CGFloat defaultThumbRadius = MIN(self.bounds.size.width*3/10, self.bounds.size.height/2);
    return _thumbRadius ? BETWEEN(_thumbRadius.cgfloatValue, 0, defaultThumbRadius) : MAX(0, defaultThumbRadius-1.5);
}

- (void)setThumbRadius:(CGFloat)thumbRadius {
    if AGX_EXPECT_F(_thumbRadius.cgfloatValue == thumbRadius) return;
    AGX_RELEASE(_thumbRadius);
    _thumbRadius = AGX_RETAIN([NSNumber numberWithCGFloat:thumbRadius]);
    [self setNeedsLayout];
}

- (UIColor *)onColor {
    return _onColor ?: AGXColor(@"4cd864");
}

- (void)setOnColor:(UIColor *)onColor {
    if AGX_EXPECT_F([_onColor isEqualToColor:onColor]) return;
    UIColor *temp = AGX_RETAIN(onColor);
    AGX_RELEASE(_onColor);
    _onColor = temp;
    [self setNeedsLayout];
}

- (UIColor *)offColor {
    return _offColor ?: AGXColor(@"e4e4e4");
}

- (void)setOffColor:(UIColor *)offColor {
    if AGX_EXPECT_F([_offColor isEqualToColor:offColor]) return;
    UIColor *temp = AGX_RETAIN(offColor);
    AGX_RELEASE(_offColor);
    _offColor = temp;
    [self setNeedsLayout];
}

- (UIColor *)thumbColor {
    return _thumbColor ?: UIColor.whiteColor;
}

- (void)setThumbColor:(UIColor *)thumbColor {
    if AGX_EXPECT_F([_thumbColor isEqualToColor:thumbColor]) return;
    UIColor *temp = AGX_RETAIN(thumbColor);
    AGX_RELEASE(_thumbColor);
    _thumbColor = temp;
    [self setNeedsLayout];
}

- (void)setOn:(BOOL)on {
    [self setOn:on animated:NO];
}

- (void)setOn:(BOOL)on animated:(BOOL)animated {
    _on = on;
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
    }
    _slideLayer.backgroundColor = _on ? self.onColor.CGColor : self.offColor.CGColor;
    CGFloat slideHeight = self.slideHeight;
    _thumbLayer.position = CGPointMake(_on ? self.bounds.size.width-slideHeight/2 : slideHeight/2, self.bounds.size.height/2);
    if (animated) {
        [UIView commitAnimations];
    }
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super endTrackingWithTouch:touch withEvent:event];

    if (!self.touchInside) return;
    [self setOn:!_on animated:YES];
}

@end
