//
//  UIImage+AGXGcode.m
//  AGXGcode
//
//  Created by Char Aznable on 2016/7/26.
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

#import "UIImage+AGXGcode.h"

@category_implementation(UIImage, AGXGcode)

- (AGXBinaryBitmap *)AGXBinaryBitmap {
    if AGX_EXPECT_F(!self.CGImage) return nil;
    return [AGXBinaryBitmap binaryBitmapWithBinarizer:
            [AGXBinarizer binarizerWithSource:
             [AGXLuminanceSource luminanceSourceWithCGImage:self.CGImage]]];
}

@end
