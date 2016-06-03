//
//  NSDictionary+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "NSDictionary+AGXCore.h"
#import "NSObject+AGXCore.h"
#import "NSNull+AGXCore.h"
#import "NSString+AGXCore.h"
#import "AGXBundle.h"
#import "AGXArc.h"

@category_implementation(NSDictionary, AGXCore)

- (NSDictionary *)deepCopy {
    return [[NSDictionary alloc] initWithDictionary:self.duplicate];
}

- (NSMutableDictionary *)mutableDeepCopy {
    return [[NSMutableDictionary alloc] initWithDictionary:self.duplicate];
}

- (NSDictionary *)deepMutableCopy {
    return [[NSDictionary alloc] initWithDictionary:AGX_AUTORELEASE([self mutableDeepMutableCopy])];
}

- (NSMutableDictionary *)mutableDeepMutableCopy {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:self.count];
    NSArray *keys = [self allKeys];
    for (id key in keys) {
        id value = [self objectForKey:key];

        id keyCopy = AGX_AUTORELEASE([key respondsToSelector:@selector(deepCopy)] ? [key deepCopy] : [key copy]);
        if ([value respondsToSelector:@selector(mutableDeepMutableCopy)])
            [dictionary setObject:AGX_AUTORELEASE([value mutableDeepMutableCopy]) forKey:keyCopy];
        else if ([value respondsToSelector:@selector(mutableCopy)])
            [dictionary setObject:AGX_AUTORELEASE([value mutableCopy]) forKey:keyCopy];
        else [dictionary setObject:AGX_AUTORELEASE([value copy]) forKey:keyCopy];
    }
    return dictionary;
}

- (id)objectForKey:(id)key defaultValue:(id)defaultValue {
    id value = [self objectForKey:key];
    return [NSNull isNull:value] ? defaultValue : value;
}

- (id)objectForCaseInsensitiveKey:(id)key {
    for (NSString *k in self.allKeys) {
        if ([k isCaseInsensitiveEqual:key]) {
            return [self objectForKey:key];
        }
    }
    return nil;
}

- (NSDictionary *)subDictionaryForKeys:(NSArray *)keys {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([keys containsObject:key]) [dict setValue:obj forKey:key];
    }];
    return AGX_AUTORELEASE([dict copy]);
}

@end

@category_implementation(NSMutableDictionary, AGXCore)

- (void)addAbsenceEntriesFromDictionary:(NSDictionary *)otherDictionary {
    NSMutableDictionary *temp = AGX_AUTORELEASE([otherDictionary mutableCopy]);
    [temp removeObjectsForKeys:self.allKeys];
    [self addEntriesFromDictionary:temp];
}

@end

@category_interface(NSDictionary, AGXCoreSafe)
@end
@category_implementation(NSDictionary, AGXCoreSafe)

- (AGX_INSTANCETYPE)AGXCoreSafe_NSDictionary_initWithObjects:(const id [])objects forKeys:(const id [])keys count:(NSUInteger)cnt {
    if (cnt == 0) return [self AGXCoreSafe_NSDictionary_initWithObjects:objects forKeys:keys count:cnt];
    id nonnull_objects[cnt];
    id nonnull_keys[cnt];
    int nonnull_index = 0;
    for (int index = 0; index < cnt; index++) {
        if (!objects[index] || !keys[index]) continue;
        nonnull_objects[nonnull_index] = objects[index];
        nonnull_keys[nonnull_index] = keys[index];
        nonnull_index++;
    }
    return [self AGXCoreSafe_NSDictionary_initWithObjects:nonnull_objects forKeys:nonnull_keys count:nonnull_index];
}

- (id)AGXCoreSafe_NSDictionary_objectForKey:(id)key {
    if (AGX_EXPECT_F(!key)) return nil;
    return [self AGXCoreSafe_NSDictionary_objectForKey:key];
}

- (id)AGXCoreSafe_NSDictionary_objectForKeyedSubscript:(id)key {
    if (AGX_EXPECT_F(!key)) return nil;
    return [self AGXCoreSafe_NSDictionary_objectForKeyedSubscript:key];
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [NSClassFromString(@"__NSPlaceholderDictionary")
         swizzleInstanceOriSelector:@selector(initWithObjects:forKeys:count:)
         withNewSelector:@selector(AGXCoreSafe_NSDictionary_initWithObjects:forKeys:count:)];

        [NSClassFromString(@"__NSDictionaryI")
         swizzleInstanceOriSelector:@selector(initWithObjects:forKeys:count:)
         withNewSelector:@selector(AGXCoreSafe_NSDictionary_initWithObjects:forKeys:count:)];
        [NSClassFromString(@"__NSDictionaryI")
         swizzleInstanceOriSelector:@selector(objectForKey:)
         withNewSelector:@selector(AGXCoreSafe_NSDictionary_objectForKey:)];
        [NSClassFromString(@"__NSDictionaryI")
         swizzleInstanceOriSelector:@selector(objectForKeyedSubscript:)
         withNewSelector:@selector(AGXCoreSafe_NSDictionary_objectForKeyedSubscript:)];
    });
}

@end

@category_interface(NSMutableDictionary, AGXCoreSafe)
@end
@category_implementation(NSMutableDictionary, AGXCoreSafe)

- (void)AGXCoreSafe_NSMutableDictionary_setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (AGX_EXPECT_F(!aKey)) return;
    if (!anObject) { [self removeObjectForKey:aKey]; return; }
    [self AGXCoreSafe_NSMutableDictionary_setObject:anObject forKey:aKey];
}

- (void)AGXCoreSafe_NSMutableDictionary_setObject:(id)anObject forKeyedSubscript:(id<NSCopying>)aKey {
    if (AGX_EXPECT_F(!aKey)) return;
    if (!anObject) { [self removeObjectForKey:aKey]; return; }
    [self AGXCoreSafe_NSMutableDictionary_setObject:anObject forKeyedSubscript:aKey];
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [NSClassFromString(@"__NSDictionaryM")
         swizzleInstanceOriSelector:@selector(initWithObjects:forKeys:count:)
         withNewSelector:@selector(AGXCoreSafe_NSDictionary_initWithObjects:forKeys:count:)];
        [NSClassFromString(@"__NSDictionaryM")
         swizzleInstanceOriSelector:@selector(objectForKey:)
         withNewSelector:@selector(AGXCoreSafe_NSDictionary_objectForKey:)];
        [NSClassFromString(@"__NSDictionaryM")
         swizzleInstanceOriSelector:@selector(objectForKeyedSubscript:)
         withNewSelector:@selector(AGXCoreSafe_NSDictionary_objectForKeyedSubscript:)];

        [NSClassFromString(@"__NSDictionaryM")
         swizzleInstanceOriSelector:@selector(setObject:forKey:)
         withNewSelector:@selector(AGXCoreSafe_NSMutableDictionary_setObject:forKey:)];
        [NSClassFromString(@"__NSDictionaryM")
         swizzleInstanceOriSelector:@selector(setObject:forKeyedSubscript:)
         withNewSelector:@selector(AGXCoreSafe_NSMutableDictionary_setObject:forKeyedSubscript:)];
    });
}

@end
