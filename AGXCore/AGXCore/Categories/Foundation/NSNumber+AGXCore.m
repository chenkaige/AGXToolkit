//
//  NSNumber+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "NSNumber+AGXCore.h"
#import "AGXArc.h"

@category_implementation(NSNumber, AGXCore)

+ (NSNumber *)numberWithFloatFromVaList:(va_list)vaList {
    AGX_CLANG_Diagnostic(-Wvarargs, return([self numberWithFloat:va_arg(vaList, float)]);)
}

+ (NSNumber *)numberWithDoubleFromVaList:(va_list)vaList {
    return [self numberWithDouble:va_arg(vaList, double)];
}

+ (NSNumber *)numberWithCGFloat:(CGFloat)value {
    return AGX_AUTORELEASE([[self alloc] initWithCGFloat:value]);
}

#if defined(__LP64__) && __LP64__

+ (NSNumber *)numberWithCGFloatFromVaList:(va_list)vaList {
    return [self numberWithDoubleFromVaList:vaList];
}

- (AGX_INSTANCETYPE)initWithCGFloat:(CGFloat)value {
    return [self initWithDouble:value];
}

- (CGFloat)cgfloatValue {
    return [self doubleValue];
}

#else // defined(__LP64__) && __LP64__

+ (NSNumber *)numberWithCGFloatFromVaList:(va_list)vaList {
    return [self numberWithFloatFromVaList:vaList];
}

- (AGX_INSTANCETYPE)initWithCGFloat:(CGFloat)value {
    return [self initWithFloat:value];
}

- (CGFloat)cgfloatValue {
    return [self floatValue];
}

#endif // defined(__LP64__) && __LP64__

@end

@category_implementation(NSString, AGXCoreNSNumber)

#if defined(__LP64__) && __LP64__

- (CGFloat)cgfloatValue {
    return [self doubleValue];
}

#else // defined(__LP64__) && __LP64__

- (CGFloat)cgfloatValue {
    return [self floatValue];
}

#endif // defined(__LP64__) && __LP64__

@end
