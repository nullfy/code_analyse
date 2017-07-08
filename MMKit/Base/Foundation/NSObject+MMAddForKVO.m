//
//  NSObject+MMAddForKVO.m
//  PracticeKit
//
//  Created by 晓东 on 16/11/17.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import "NSObject+MMAddForKVO.h"
#import "MMKitMacro.h"
#import <objc/runtime.h>
#import <objc/objc.h>

MMSYNTH_DUMMY_CLASS(NSObject_MMAddForKVO)

static const int block_key;

@interface _MMNSObjectKVOBlockTarget : NSObject

@property (nonatomic, copy) void (^block)(__weak id obj, id oldVal, id newVal);

- (id)initWithBlock:(void (^)(__weak id obj, id oldVal, id newVal))block;

@end

@implementation _MMNSObjectKVOBlockTarget

- (id)initWithBlock:(void (^)(__weak id, id, id))block {
    self = [super init];
    if (self) {
        self.block = block;
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (!self.block) return;
    
    BOOL isPrior = [[change objectForKey:NSKeyValueChangeNotificationIsPriorKey] boolValue];
    if (isPrior) return;
    
    NSKeyValueChange changeKind = [[change objectForKey:NSKeyValueChangeKindKey] integerValue];
    if (changeKind != NSKeyValueChangeSetting) return;
    
    id oldVal = [change objectForKey:NSKeyValueChangeOldKey];
    if (oldVal == [NSNull null]) oldVal = nil;
    
    id newVal = [change objectForKey:NSKeyValueChangeNewKey];
    if (newVal == [NSNull null]) newVal = nil;
    
    self.block(object, oldVal, newVal);
}

@end


/*
    KVO 当一个controller绑定了一些KVO 当对同一个keyPath进行两次removeObserver时会导致crash，这种情况常常出现在父类有一个KVO，父类再delloc中remove了一次，子类中又remove一次的情况
    KVO的实现
        KVO的实现也依赖于Objective－C强大的Runtime，官方文档中提到其实现依赖于 isa-swizzling
        当你观察一个对象时，一个新的类会动态被创建，这个类继承自该对象原本的类，并重写了被观察属性的setter方法，自然重写了 setter 方法会负责在调用原 setter 方法之前和之后，通知所
        观察对象值的更改，最后把这个对象的 isa 指针，指向这个新创建的字类，对象就神奇的变成了新创建的字类的实例，
 
 
 
 */
@implementation NSObject (MMAddForKVO)

- (void)addObserverBlockForKeyPath:(NSString *)keyPath block:(void (^)(id _Nullable, id _Nullable, id _Nullable))block {
    if (!keyPath || !block) return;
    _MMNSObjectKVOBlockTarget *target = [[_MMNSObjectKVOBlockTarget alloc] initWithBlock:block];
    
    NSMutableDictionary *dic = [self _mm_allNSObjectObserverBlocks];
    NSMutableArray *array = dic[keyPath];
    if (!array) {
        array = [NSMutableArray new];
        dic[keyPath] = array;
    }
    [array addObject:target];
    [self addObserver:target forKeyPath:keyPath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL]; //NULL是函数的空
}

- (void)removeObserverBlocksForKeyPath:(NSString *)keyPath {
    if (!keyPath) return;
    NSMutableDictionary *dic = [self _mm_allNSObjectObserverBlocks];
    NSMutableArray *arr = dic[keyPath];
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeObserver:obj forKeyPath:keyPath];
    }];
    [dic removeObjectForKey:keyPath];
}

- (void)removeObserverBlocks {
    NSMutableDictionary *dic = [self _mm_allNSObjectObserverBlocks];
    [dic enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *arr, BOOL * _Nonnull stop) {
        [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self removeObserver:obj forKeyPath:key];
        }];
    }];
    [dic removeAllObjects];
}


- (NSMutableDictionary *)_mm_allNSObjectObserverBlocks {
    NSMutableDictionary *targets = objc_getAssociatedObject(self, &block_key);
    if (!targets) {
        targets = [NSMutableDictionary new];
        objc_setAssociatedObject(self, &block_key, targets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return targets;
}

@end
