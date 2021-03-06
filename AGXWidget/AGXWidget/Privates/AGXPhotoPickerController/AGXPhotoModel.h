//
//  AGXPhotoModel.h
//  AGXWidget
//
//  Created by Char Aznable on 2018/1/16.
//  Copyright © 2018年 AI-CUC-EC. All rights reserved.
//

//
//  Modify from:
//  banchichen/TZImagePickerController
//

//  The MIT License (MIT)
//
//  Copyright (c) 2016 Zhen Tan
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#ifndef AGXWidget_AGXPhotoModel_h
#define AGXWidget_AGXPhotoModel_h

#import <Photos/Photos.h>
#import <AGXCore/AGXCore/AGXArc.h>

@class AGXAlbumModel;
@class AGXAssetModel;

@interface AGXAlbumModel : NSObject
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) PHAssetCollection *collection;
@property (nonatomic, assign)   BOOL allowPickingVideo;
@property (nonatomic, assign)   BOOL allowPickingGif;
@property (nonatomic, assign)   BOOL allowPickingLivePhoto;
@property (nonatomic, assign)   BOOL sortByCreateDateDescending;
@property (nonatomic, readonly) NSArray<PHAsset *> *assets;
@property (nonatomic, readonly) NSArray<AGXAssetModel *> *assetModels;
@property (nonatomic, readonly) NSInteger count;
@property (nonatomic, readonly) BOOL isCameraRollAlbum;

+ (AGX_INSTANCETYPE)albumModelWithCollection:(PHAssetCollection *)collection allowPickingVideo:(BOOL)allowPickingVideo allowPickingGif:(BOOL)allowPickingGif allowPickingLivePhoto:(BOOL)allowPickingLivePhoto sortByCreateDateDescending:(BOOL)sortByCreateDateDescending;
- (AGX_INSTANCETYPE)initWithCollection:(PHAssetCollection *)collection allowPickingVideo:(BOOL)allowPickingVideo allowPickingGif:(BOOL)allowPickingGif allowPickingLivePhoto:(BOOL)allowPickingLivePhoto sortByCreateDateDescending:(BOOL)sortByCreateDateDescending;
@end

typedef NS_ENUM(NSUInteger, AGXAssetModelMediaType) {
    AGXAssetModelMediaTypePhoto,
    AGXAssetModelMediaTypeLivePhoto,
    AGXAssetModelMediaTypeGif,
    AGXAssetModelMediaTypeVideo
};

@interface AGXAssetModel : NSObject
@property (nonatomic, readonly) PHAsset *asset;
@property (nonatomic, readonly) AGXAssetModelMediaType mediaType;
@property (nonatomic, readonly) NSString *timeLength;

+ (AGX_INSTANCETYPE)assetModelWithAsset:(PHAsset *)asset mediaType:(AGXAssetModelMediaType)mediaType;
+ (AGX_INSTANCETYPE)assetModelWithAsset:(PHAsset *)asset mediaType:(AGXAssetModelMediaType)mediaType timeLength:(NSString *)timeLength;
- (AGX_INSTANCETYPE)initWithAsset:(PHAsset *)asset mediaType:(AGXAssetModelMediaType)mediaType;
- (AGX_INSTANCETYPE)initWithAsset:(PHAsset *)asset mediaType:(AGXAssetModelMediaType)mediaType timeLength:(NSString *)timeLength;
@end

#endif /* AGXWidget_AGXPhotoModel_h */
