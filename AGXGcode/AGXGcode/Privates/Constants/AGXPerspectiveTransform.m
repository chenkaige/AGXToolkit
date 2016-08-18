//
//  AGXPerspectiveTransform.m
//  AGXGcode
//
//  Created by Char Aznable on 16/8/5.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

//
//  Modify from:
//  TheLevelUp/ZXingObjC
//

//
//  Copyright 2014 ZXing authors
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <AGXCore/AGXCore/AGXArc.h>
#import "AGXPerspectiveTransform.h"

@interface AGXPerspectiveTransform ()
@property (nonatomic, readonly) float a11;
@property (nonatomic, readonly) float a12;
@property (nonatomic, readonly) float a13;
@property (nonatomic, readonly) float a21;
@property (nonatomic, readonly) float a22;
@property (nonatomic, readonly) float a23;
@property (nonatomic, readonly) float a31;
@property (nonatomic, readonly) float a32;
@property (nonatomic, readonly) float a33;
@end

@implementation AGXPerspectiveTransform

+ (AGX_INSTANCETYPE)transformWithA11:(float)a11 a21:(float)a21 a31:(float)a31 a12:(float)a12 a22:(float)a22 a32:(float)a32 a13:(float)a13 a23:(float)a23 a33:(float)a33 {
    return AGX_AUTORELEASE([[self alloc] initWithA11:a11 a21:a21 a31:a31
                                                 a12:a12 a22:a22 a32:a32
                                                 a13:a13 a23:a23 a33:a33]);
}

- (AGX_INSTANCETYPE)initWithA11:(float)a11 a21:(float)a21 a31:(float)a31 a12:(float)a12 a22:(float)a22 a32:(float)a32 a13:(float)a13 a23:(float)a23 a33:(float)a33 {
    if (self = [super init]) {
        _a11 = a11; _a12 = a12; _a13 = a13;
        _a21 = a21; _a22 = a22; _a23 = a23;
        _a31 = a31; _a32 = a32; _a33 = a33;
    }
    return self;
}

- (void)transformPoints:(float *)points pointsLen:(int)pointsLen {
    int max = pointsLen;
    for (int i = 0; i < max; i += 2) {
        float x = points[i];
        float y = points[i + 1];
        float denominator = _a13 * x + _a23 * y + _a33;
        points[i] = (_a11 * x + _a21 * y + _a31) / denominator;
        points[i + 1] = (_a12 * x + _a22 * y + _a32) / denominator;
    }
}

- (void)transformPoints:(float *)xValues yValues:(float *)yValues pointsLen:(int)pointsLen {
    int n = pointsLen;
    for (int i = 0; i < n; i ++) {
        float x = xValues[i];
        float y = yValues[i];
        float denominator = _a13 * x + _a23 * y + _a33;
        xValues[i] = (_a11 * x + _a21 * y + _a31) / denominator;
        yValues[i] = (_a12 * x + _a22 * y + _a32) / denominator;
    }
}

+ (AGXPerspectiveTransform *)quadrilateralToQuadrilateral:(float)x0 y0:(float)y0 x1:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2 x3:(float)x3 y3:(float)y3 x0p:(float)x0p y0p:(float)y0p x1p:(float)x1p y1p:(float)y1p x2p:(float)x2p y2p:(float)y2p x3p:(float)x3p y3p:(float)y3p {
    AGXPerspectiveTransform *qToS = [self quadrilateralToSquare:x0 y0:y0 x1:x1 y1:y1 x2:x2 y2:y2 x3:x3 y3:y3];
    AGXPerspectiveTransform *sToQ = [self squareToQuadrilateral:x0p y0:y0p x1:x1p y1:y1p x2:x2p y2:y2p x3:x3p y3:y3p];
    return [sToQ times:qToS];
}

+ (AGXPerspectiveTransform *)squareToQuadrilateral:(float)x0 y0:(float)y0 x1:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2 x3:(float)x3 y3:(float)y3 {
    float dx3 = x0 - x1 + x2 - x3;
    float dy3 = y0 - y1 + y2 - y3;
    if (dx3 == 0.0f && dy3 == 0.0f) {
        // Affine
        return [AGXPerspectiveTransform transformWithA11:x1 - x0 a21:x2 - x1 a31:x0 a12:y1 - y0 a22:y2 - y1 a32:y0 a13:0.0f a23:0.0f a33:1.0f];
    } else {
        float dx1 = x1 - x2;
        float dx2 = x3 - x2;
        float dy1 = y1 - y2;
        float dy2 = y3 - y2;
        float denominator = dx1 * dy2 - dx2 * dy1;
        float a13 = (dx3 * dy2 - dx2 * dy3) / denominator;
        float a23 = (dx1 * dy3 - dx3 * dy1) / denominator;
        return [AGXPerspectiveTransform transformWithA11:x1 - x0 + a13 * x1 a21:x3 - x0 + a23 * x3 a31:x0 a12:y1 - y0 + a13 * y1 a22:y3 - y0 + a23 * y3 a32:y0 a13:a13 a23:a23 a33:1.0f];
    }
}

+ (AGXPerspectiveTransform *)quadrilateralToSquare:(float)x0 y0:(float)y0 x1:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2 x3:(float)x3 y3:(float)y3 {
    return [[self squareToQuadrilateral:x0 y0:y0 x1:x1 y1:y1 x2:x2 y2:y2 x3:x3 y3:y3] buildAdjoint];
}

- (AGXPerspectiveTransform *)buildAdjoint {
    return [AGXPerspectiveTransform transformWithA11:_a22 * _a33 - _a23 * _a32 a21:_a23 * _a31 - _a21 * _a33 a31:_a21 * _a32 - _a22 * _a31 a12:_a13 * _a32 - _a12 * _a33 a22:_a11 * _a33 - _a13 * _a31 a32:_a12 * _a31 - _a11 * _a32 a13:_a12 * _a23 - _a13 * _a22 a23:_a13 * _a21 - _a11 * _a23 a33:_a11 * _a22 - _a12 * _a21];
}

- (AGXPerspectiveTransform *)times:( AGXPerspectiveTransform *)other {
    return [AGXPerspectiveTransform transformWithA11:_a11 * other.a11 + _a21 * other.a12 + _a31 * other.a13 a21:_a11 * other.a21 + _a21 * other.a22 + _a31 * other.a23 a31:_a11 * other.a31 + _a21 * other.a32 + _a31 * other.a33 a12:_a12 * other.a11 + _a22 * other.a12 + _a32 * other.a13 a22:_a12 * other.a21 + _a22 * other.a22 + _a32 * other.a23 a32:_a12 * other.a31 + _a22 * other.a32 + _a32 * other.a33 a13:_a13 * other.a11 + _a23 * other.a12 + _a33 * other.a13 a23:_a13 * other.a21 + _a23 * other.a22 + _a33 * other.a23 a33:_a13 * other.a31 + _a23 * other.a32 + _a33 * other.a33];
}

@end
