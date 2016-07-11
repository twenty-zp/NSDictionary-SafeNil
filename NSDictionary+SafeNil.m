//
//  NSDictionary+SafeNil.m
//  NSDictionary遇到nil
//
//  Created by iLogiEMAC on 16/7/11.
//  Copyright © 2016年 zp. All rights reserved.
//

#import "NSDictionary+SafeNil.h"
#import <objc/runtime.h>
@implementation NSObject (SafeNil)

+ (BOOL)swizzing_method:(SEL)originalSelector  replaceMethod:(SEL)replaceSelector
{
    Method original = class_getInstanceMethod(self, originalSelector);
    Method replace = class_getInstanceMethod(self, replaceSelector);
    if (!original || !replace) {
        return NO;
    }
    class_addMethod(self, originalSelector, class_getMethodImplementation(self, originalSelector), method_getTypeEncoding(original));
    class_addMethod(self, replaceSelector, class_getMethodImplementation(self, replaceSelector), method_getTypeEncoding(replace));
    
    method_exchangeImplementations(original, replace);
    return YES;
}

+ (BOOL)swizzingClassMethod:(SEL)originSelector replaceMethod:(SEL)replaceSelector
{
    return [object_getClass((id)self) swizzing_method:originSelector replaceMethod:replaceSelector];
}


@end

@implementation NSDictionary (SafeNil)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzingClassMethod:@selector(initWithObjects:forKeys:count:) replaceMethod:@selector(zpSwizzing_initWithObjects:forKeys:count:)];
        [self swizzingClassMethod:@selector(dictionaryWithObjects:forKeys:count:) replaceMethod:@selector(zpSwizzingClass_dictionaryWithObjects:forKeys:count:)];
    });
}

- (instancetype)zpSwizzing_initWithObjects:(const id  _Nonnull __unsafe_unretained *)objects forKeys:(const id<NSCopying>  _Nonnull __unsafe_unretained *)keys count:(NSUInteger)cnt{
    id safeObjects[cnt];
    id safeKeys[cnt];
    
    NSUInteger j = 0;
    for (NSUInteger i = 0; i < cnt ; i++) {
        id key = keys[i];
        id obj = objects[i];
        if (!key || !obj) {
            continue;
        }
        safeObjects[j] = obj;
        safeKeys[j] = key;
        j++;
    }
    return  [self zpSwizzing_initWithObjects:safeObjects forKeys:safeKeys count:j];
}


+ (instancetype)zpSwizzingClass_dictionaryWithObjects:(const id  _Nonnull __unsafe_unretained *)objects forKeys:(const id<NSCopying>  _Nonnull __unsafe_unretained *)keys count:(NSUInteger)cnt
{
    id safeObjects[cnt];
    id safeKeys[cnt];
    
    NSUInteger j = 0;
    for (NSUInteger i = 0; i < cnt ; i++) {
        id key = keys[i];
        id obj = objects[i];
        if (!key || !obj) {
            continue;
        }
        safeObjects[j] = obj;
        safeKeys[j] = key;
        j++;
    }
    return [self zpSwizzingClass_dictionaryWithObjects:safeObjects forKeys:safeKeys count:j];
}

@end

@implementation NSMutableDictionary (safeNil)

//+ (void)load
//{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        
//        Class class = NSClassFromString(@"__NSDictionaryM");
//        [class swizzing_method:@selector(setObject:forKey:) replaceMethod:@selector(zpSwizzing_setObject:forKey:)];
//        [class swizzing_method:@selector(setObject:forKeyedSubscript:) replaceMethod:@selector(zpSwizzing_setObject:forKeyedSubscript:)];
//    });
//}
//- (void)zpSwizzing_setObject:(id)anObject forKey:(id<NSCopying>)aKey
//{
//    if (!anObject || !aKey) {
//        return ;
//    }
//    [self zpSwizzing_setObject:anObject forKey:aKey];
//}
//
//- (void)zpSwizzing_setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key
//{
//    if (!obj || !key) {
//        return ;
//    }
//    [self zpSwizzing_setObject:obj forKeyedSubscript:key];
//}
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = NSClassFromString(@"__NSDictionaryM");
        [class swizzing_method:@selector(setObject:forKey:) replaceMethod:@selector(gl_setObject:forKey:)];
        [class swizzing_method:@selector(setObject:forKeyedSubscript:) replaceMethod:@selector(gl_setObject:forKeyedSubscript:)];
    });
}

- (void)gl_setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (!aKey) {
        return;
    }
    if (!anObject) {
        anObject = [NSNull null];
    }
    [self gl_setObject:anObject forKey:aKey];
}

- (void)gl_setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
    if (!key) {
        return;
    }
    if (!obj) {
        obj = [NSNull null];
    }
    [self gl_setObject:obj forKeyedSubscript:key];
}



@end
