//
//  NSObject+AGXRuntime.h
//  AGXRuntime
//
//  Created by Char Aznable on 16/2/19.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXRuntime_NSObject_AGXRuntime_h
#define AGXRuntime_NSObject_AGXRuntime_h

#import <Foundation/Foundation.h>
#import <AGXCore/AGXCore/AGXCategory.h>

@class AGXProtocol;
@class AGXIvar;
@class AGXProperty;
@class AGXMethod;

@category_interface(NSObject, AGXRuntime)
+ (NSArray *)agxProtocols;
+ (void)enumerateAGXProtocolsWithBlock:(void (^)(AGXProtocol *protocol))block;
- (void)enumerateAGXProtocolsWithBlock:(void (^)(id object, AGXProtocol *protocol))block;

+ (NSArray *)agxIvars;
+ (AGXIvar *)agxIvarForName:(NSString *)name;
+ (void)enumerateAGXIvarsWithBlock:(void (^)(AGXIvar *ivar))block;
- (void)enumerateAGXIvarsWithBlock:(void (^)(id object, AGXIvar *ivar))block;

+ (NSArray *)agxProperties;
+ (AGXProperty *)agxPropertyForName:(NSString *)name;
+ (void)enumerateAGXPropertiesWithBlock:(void (^)(AGXProperty *property))block;
- (void)enumerateAGXPropertiesWithBlock:(void (^)(id object, AGXProperty *property))block;

+ (NSArray *)agxMethods;
+ (AGXMethod *)agxInstanceMethodForName:(NSString *)name;
+ (AGXMethod *)agxClassMethodForName:(NSString *)name;
+ (void)enumerateAGXMethodsWithBlock:(void (^)(AGXMethod *method))block;
- (void)enumerateAGXMethodsWithBlock:(void (^)(id object, AGXMethod *method))block;
@end

#endif /* AGXRuntime_NSObject_AGXRuntime_h */