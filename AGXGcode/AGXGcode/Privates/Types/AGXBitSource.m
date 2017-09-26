//
//  AGXBitSource.m
//  AGXGcode
//
//  Created by Char Aznable on 16/8/8.
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
#import "AGXBitSource.h"

@implementation AGXBitSource {
    AGXByteArray *_bytes;
}

+ (AGX_INSTANCETYPE)bitSourceWithBytes:(AGXByteArray *)bytes {
    return AGX_AUTORELEASE([[AGXBitSource alloc] initWithBytes:bytes]);
}

- (AGX_INSTANCETYPE)initWithBytes:(AGXByteArray *)bytes {
    if AGX_EXPECT_T(self = [super init]) {
        _bytes = AGX_RETAIN(bytes);
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_bytes);
    AGX_SUPER_DEALLOC;
}

- (int)readBits:(int)numBits {
    if AGX_EXPECT_F(numBits < 1 || numBits > 32 || numBits > self.available)
        [NSException raise:NSInvalidArgumentException format:@"Invalid number of bits: %d", numBits];

    int result = 0;
    // First, read remainder from current byte
    if (_bitOffset > 0) {
        int bitsLeft = 8 - _bitOffset;
        int toRead = numBits < bitsLeft ? numBits : bitsLeft;
        int bitsToNotRead = bitsLeft - toRead;
        int mask = (0xFF >> (8 - toRead)) << bitsToNotRead;
        result = (_bytes.array[_byteOffset] & mask) >> bitsToNotRead;
        numBits -= toRead;
        _bitOffset += toRead;
        if (_bitOffset == 8) {
            _bitOffset = 0;
            _byteOffset++;
        }
    }

    // Next read whole bytes
    if (numBits > 0) {
        while (numBits >= 8) {
            result = (result << 8) | (_bytes.array[_byteOffset] & 0xFF);
            _byteOffset++;
            numBits -= 8;
        }

        // Finally read a partial byte
        if (numBits > 0) {
            int bitsToNotRead = 8 - numBits;
            int mask = (0xFF >> bitsToNotRead) << bitsToNotRead;
            result = (result << numBits) | ((_bytes.array[_byteOffset] & mask) >> bitsToNotRead);
            _bitOffset += numBits;
        }
    }
    return result;
}

- (int)available {
    return 8 * (_bytes.length - _byteOffset) - _bitOffset;
}

@end
