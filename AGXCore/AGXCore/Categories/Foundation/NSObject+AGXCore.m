//
//  NSObject+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "NSObject+AGXCore.h"
#import "AGXArc.h"
#import <objc/runtime.h>

@category_implementation(NSObject, AGXCore)

#pragma mark - add (replace)

+ (void)addInstanceMethodWithSelector:(SEL)selector andBlock:(id)block andTypeEncoding:(const char *)typeEncoding {
    addInstanceMethodIfNotExists(self, selector, imp_implementationWithBlock(block), typeEncoding);
}

+ (void)addOrReplaceInstanceMethodWithSelector:(SEL)selector andBlock:(id)block andTypeEncoding:(const char *)typeEncoding {
    addInstanceMethodReplaceExists(self, selector, imp_implementationWithBlock(block), typeEncoding);
}

+ (void)addClassMethodWithSelector:(SEL)selector andBlock:(id)block andTypeEncoding:(const char *)typeEncoding {
    addInstanceMethodIfNotExists(object_getClass(self), selector, imp_implementationWithBlock(block), typeEncoding);
}

+ (void)addOrReplaceClassMethodWithSelector:(SEL)selector andBlock:(id)block andTypeEncoding:(const char *)typeEncoding {
    addInstanceMethodReplaceExists(object_getClass(self), selector, imp_implementationWithBlock(block), typeEncoding);
}

#pragma mark - swizzle

+ (void)swizzleInstanceOriSelector:(SEL)oriSelector withNewSelector:(SEL)newSelector {
    [self swizzleInstanceOriSelector:oriSelector withNewSelector:newSelector fromClass:self];
}

+ (void)swizzleInstanceOriSelector:(SEL)oriSelector withNewSelector:(SEL)newSelector fromClass:(Class)clazz {
    swizzleInstanceMethod(self, oriSelector, newSelector, clazz);
}

+ (void)swizzleClassOriSelector:(SEL)oriSelector withNewSelector:(SEL)newSelector {
    [self swizzleClassOriSelector:oriSelector withNewSelector:newSelector fromClass:self];
}

+ (void)swizzleClassOriSelector:(SEL)oriSelector withNewSelector:(SEL)newSelector fromClass:(Class)clazz {
    swizzleInstanceMethod(object_getClass(self), oriSelector, newSelector, object_getClass(clazz));
}

AGX_STATIC void addInstanceMethodIfNotExists(Class targetClass, SEL selector, IMP imp, const char *typeEncoding) {
    class_addMethod(targetClass, selector, imp, typeEncoding);
}

AGX_STATIC void addInstanceMethodReplaceExists(Class targetClass, SEL selector, IMP imp, const char *typeEncoding) {
    if (!class_addMethod(targetClass, selector, imp, typeEncoding))
        method_setImplementation(class_getInstanceMethod(targetClass, selector), imp);
}

AGX_STATIC void swizzleInstanceMethod(Class swiClass, SEL oriSelector, SEL newSelector, Class impClass) {
    Method oriMethod = class_getInstanceMethod(impClass, oriSelector);
    Method newMethod = class_getInstanceMethod(impClass, newSelector);
    addInstanceMethodReplaceExists(swiClass, oriSelector, method_getImplementation(oriMethod),
                                   method_getTypeEncoding(oriMethod));
    addInstanceMethodReplaceExists(swiClass, newSelector, method_getImplementation(newMethod),
                                   method_getTypeEncoding(newMethod));
    method_exchangeImplementations(class_getInstanceMethod(swiClass, oriSelector),
                                   class_getInstanceMethod(swiClass, newSelector));
}

#pragma mark - observe

- (void)addObserver:(NSObject *)observer
        forKeyPaths:(NSArray *)keyPaths
            options:(NSKeyValueObservingOptions)options
            context:(void *)context {
    if (AGX_EXPECT_F(!keyPaths)) return;
    for (id keyPath in keyPaths) {
        NSString *k = [keyPath isKindOfClass:[NSString class]] ? keyPath : [keyPath description];
        [self addObserver:observer forKeyPath:k options:options context:context];
    }
}

- (void)removeObserver:(NSObject *)observer
           forKeyPaths:(NSArray *)keyPaths
               context:(void *)context {
    if (AGX_EXPECT_F(!keyPaths)) return;
    for (id keyPath in keyPaths) {
        NSString *k = [keyPath isKindOfClass:[NSString class]] ? keyPath : [keyPath description];
        [self removeObserver:observer forKeyPath:k context:context];
    }
}

- (void)removeObserver:(NSObject *)observer
           forKeyPaths:(NSArray *)keyPaths {
    [self removeObserver:observer forKeyPaths:keyPaths context:NULL];
}

#pragma mark - associate

- (id)propertyForAssociateKey:(NSString *)key {
    return objc_getAssociatedObject(self, (AGX_BRIDGE const void *)(key));
}

- (void)setProperty:(id)property forAssociateKey:(NSString *)key {
    id originalProperty = objc_getAssociatedObject(self, (AGX_BRIDGE const void *)(key));
    if (AGX_EXPECT_F([property isEqual:originalProperty])) return;
    
    [self willChangeValueForKey:key];
    [self assignProperty:property forAssociateKey:key];
    [self didChangeValueForKey:key];
}

- (void)assignProperty:(id)property forAssociateKey:(NSString *)key {
    objc_setAssociatedObject(self, (AGX_BRIDGE const void *)(key),
                             property, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
