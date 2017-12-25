//
//  AGXAztecDetectorResult.m
//  AGXGcode
//
//  Created by Char Aznable on 2016/8/9.
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
#import "AGXAztecDetectorResult.h"

@implementation AGXAztecDetectorResult

+ (AGX_INSTANCETYPE)detectorResultWithBits:(AGXBitMatrix *)bits compact:(BOOL)compact nbDatablocks:(int)nbDatablocks nbLayers:(int)nbLayers {
    return AGX_AUTORELEASE([[self alloc] initWithBits:bits compact:compact nbDatablocks:nbDatablocks nbLayers:nbLayers]);
}

- (AGX_INSTANCETYPE)initWithBits:(AGXBitMatrix *)bits compact:(BOOL)compact nbDatablocks:(int)nbDatablocks nbLayers:(int)nbLayers {
    if AGX_EXPECT_T(self = [super initWithBits:bits]) {
        _compact = compact;
        _nbDatablocks = nbDatablocks;
        _nbLayers = nbLayers;
    }
    return self;
}

@end
