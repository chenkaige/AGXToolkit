//
//  AGXColorSet.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/18.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXColorSet.h"
#import "AGXBundle.h"
#import "NSDictionary+AGXCore.h"
#import "UIColor+AGXCore.h"
#import "AGXArc.h"

@interface AGXColorSet ()
@property (nonatomic) NSString *fileName;
@property (nonatomic) NSString *subpath;
@property (nonatomic) AGXDirectory *directory;
@property (nonatomic) NSString *bundleName;
@end

@implementation AGXColorSet {
    NSDictionary *_colors;
}

- (AGX_INSTANCETYPE)initWithDictionary:(NSDictionary *)colors {
    if (AGX_EXPECT_T(self = [super init])) {
        _colors = AGX_RETAIN(buildColorDictionary(colors));
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_fileName);
    AGX_RELEASE(_subpath);
    AGX_RELEASE(_directory);
    AGX_RELEASE(_bundleName);
    AGX_RELEASE(_colors);
    AGX_SUPER_DEALLOC;
}

+ (AGXColorSet *(^)(NSDictionary *))colorsWithDictionary {
    return AGX_BLOCK_AUTORELEASE(^AGXColorSet *(NSDictionary *colors) {
        return AGX_AUTORELEASE([[AGXColorSet alloc] initWithDictionary:colors]);
    });
}

+ (AGX_INSTANCETYPE)colors {
    return AGX_AUTORELEASE([[AGXColorSet alloc] initWithDictionary:nil]);
}

- (AGXColorSet *(^)(NSString *))useFileNamed {
    return AGX_BLOCK_AUTORELEASE(^AGXColorSet *(NSString *fileName) {
        self.fileName = fileName;
        return self.reload;
    });
}

- (AGXColorSet *(^)(NSString *))inSubpath {
    return AGX_BLOCK_AUTORELEASE(^AGXColorSet *(NSString *subpath) {
        self.subpath = subpath;
        return self.reload;
    });
}

- (AGXColorSet *(^)(AGXDirectory *))inDirectory {
    return AGX_BLOCK_AUTORELEASE(^AGXColorSet *(AGXDirectory *directory) {
        self.directory = directory;
        return self.reload;
    });
}

- (AGXColorSet *(^)(NSString *))inBundleNamed {
    return AGX_BLOCK_AUTORELEASE(^AGXColorSet *(NSString *bundleName) {
        self.bundleName = bundleName;
        return self.reload;
    });
}

- (AGX_INSTANCETYPE)reload {
    if (!_fileName) return self;
    AGX_RELEASE(_colors);
    _colors = AGX_RETAIN(buildColorDictionary
                         ((_directory && _directory.inSubpath(_subpath).fileExists(_fileName))
                          ? _directory.dictionaryWithFile(_fileName)
                          : AGXBundle.bundleNamed(_bundleName).inSubpath(_subpath).dictionaryWithFile(_fileName)));
    return self;
}

- (UIColor *)colorForKey:(NSString *)key {
    return [_colors objectForKey:key];
}

- (UIColor *)objectForKeyedSubscript:(NSString *)key {
    return [_colors objectForKey:key];
}

- (UIColor *(^)(NSString *))colorForKey {
    return AGX_BLOCK_AUTORELEASE(^UIColor *(NSString *key) {
        return [_colors objectForKey:key];
    });
}

#pragma mark - implementation functions -

AGX_STATIC NSDictionary *buildColorDictionary(NSDictionary *srcDictionary) {
    if (AGX_EXPECT_F(!srcDictionary)) return nil;
    NSMutableDictionary *dstDictionary = AGX_AUTORELEASE([[NSMutableDictionary alloc] init]);
    [srcDictionary enumerateKeysAndObjectsUsingBlock:
     ^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
         if ([obj isKindOfClass:[UIColor class]]) {
             [dstDictionary setObject:obj forKey:key];
         } else if ([obj isKindOfClass:[NSString class]]) {
             [dstDictionary setObject:[UIColor colorWithRGBAHexString:obj] forKey:key];
         }
     }];
    return AGX_AUTORELEASE([dstDictionary copy]);
}

@end

NSString *AGXColorSetBundleName = nil;
