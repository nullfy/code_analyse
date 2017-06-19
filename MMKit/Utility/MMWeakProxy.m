//
//  MMWeakProxy.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/6/17.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "MMWeakProxy.h"

@implementation MMWeakProxy

- (instancetype)initWithTarget:(id)target {
    _target = target;
    return self;
}

+ (instancetype)initWithTarget:(id)target {
    return [[MMWeakProxy alloc] initWithTarget:target];
}

/*
 消息转发一共有三次机会
 1. +(BOOL)resolveInstanceMethod:(SEL)sel;
 2. -(id)forwardingTargetSelector:(SEL)selector; //return 能够处理这个方法等对象
 3. -(NSMethodSignature *)methodSignatureForSelector:(SEL)sel;
 */
- (id)forwardingTargetForSelector:(SEL)selector {
    return _target;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    /*
     这个函数可以修改很多信息，比如可以替换方法等处理者，替换选择器，修改参数等
     参数invocation 是被转发的选择器
     */
    void *null = NULL;
    [invocation setReturnValue:&null];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [_target respondsToSelector:aSelector];
}

- (BOOL)isEqual:(id)object {
    return [_target isEqual:object];
}

- (NSUInteger)hash {
    return [_target hash];
}

- (Class)superclass {
    return [_target superclass];
}

- (Class)class {
    return [_target class];
}

- (BOOL)isKindOfClass:(Class)aClass {
    return [_target isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass {
    return [_target isMemberOfClass:aClass];
}

- (BOOL)isProxy {
    return YES;
}

- (NSString *)description {
    return [_target description];
}

- (NSString *)debugDescription {
    return [_target debugDescription];
}

@end
