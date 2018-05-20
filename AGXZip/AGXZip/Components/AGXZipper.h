//
//  AGXZipper.h
//  AGXZip
//
//  Created by Char Aznable on 2018/5/16.
//  Copyright © 2018年 AI-CUC-EC. All rights reserved.
//

//
//  Modify from:
//  ZipArchive/ZipArchive
//  https://github.com/ZipArchive/ZipArchive
//

//  SSZipArchive MIT license
//
//  Copyright (c) 2010-2015, Sam Soffes, http://soff.es
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//  Zlib license
//
//  zlib.h -- interface of the 'zlib' general purpose compression library
//  version 1.2.11, January 15th, 2017
//
//  Copyright (C) 1995-2017 Jean-loup Gailly and Mark Adler
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source distribution.
//
//  Jean-loup Gailly        Mark Adler
//  jloup@gzip.org          madler@alumni.caltech.edu

//  minizip LICENSE
//
//  nmoinvaz/minizip
//
//  Condition of use and distribution are the same as zlib:
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgement in the product documentation would be
//  appreciated but is not required.
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source distribution.

#ifndef AGXZip_AGXZipper_h
#define AGXZip_AGXZipper_h

#import <zlib.h>
#import <AGXCore/AGXCore/AGXObjC.h>
#import <AGXCore/AGXCore/AGXResources.h>

typedef NS_ENUM(NSInteger, AGXZipperCompressionLevel) {
    AGXZipperCompressionLevelNoCompression      = Z_NO_COMPRESSION,
    AGXZipperCompressionLevelBestSpeed          = Z_BEST_SPEED,
    AGXZipperCompressionLevelBestCompression    = Z_BEST_COMPRESSION,
    AGXZipperCompressionLevelDefaultCompression = Z_DEFAULT_COMPRESSION,
};

@interface AGXZipper : NSObject
+ (AGX_INSTANCETYPE)document;
+ (AGX_INSTANCETYPE)caches;
+ (AGX_INSTANCETYPE)temporary;

- (AGXZipper *(^)(NSString *))zipArchiveNamed;

- (AGXZipper *(^)(BOOL))keepParentDirectoryAs;
- (AGXZipper *(^)(AGXZipperCompressionLevel))compressionLevelAs;
- (AGXZipper *(^)(NSString *))passwordAs;
- (AGXZipper *(^)(BOOL))aesAs;

- (AGXZipper *(^)(void (^)(NSUInteger entryNumber, NSUInteger total)))progressHandleWith;

- (AGXZipper *(^)(AGXResources *))sourceAs;

- (BOOL (^)(void))zip;
- (BOOL (^)(AGXResources *))zipFrom;
@end

#endif /* AGXZip_AGXZipper_h */