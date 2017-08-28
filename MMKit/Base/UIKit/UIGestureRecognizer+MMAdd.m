//
//  UIGestureRecognizer+MMAdd.m
//  PracticeKit
//
//  Created by 晓东 on 16/12/2.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import "UIGestureRecognizer+MMAdd.h"
#import "MMKitMacro.h"
#import <objc/runtime.h>

MMSYNTH_DUMMY_CLASS(UIGestureRecognizer_MMAdd)

@interface _MMUIGestureRecognizerBlockTarget : NSObject

@property (nonatomic, copy) void(^block)(id sender);

- (id)initWithBlock:(void (^)(id sender))block;

- (void)invoke:(id)sender;

@end

@implementation _MMUIGestureRecognizerBlockTarget

- (id)initWithBlock:(void (^)(id))block {
    self = [super init];
    if (self) {
        _block = block;
    }
    return self;
}

- (void)invoke:(id)sender {
    if (_block) _block(sender);
}

@end

@implementation UIGestureRecognizer (MMAdd)

#warning mark   这里为什么不能用 super
- (id)initWithActionBlock:(void (^)(id sender))block {
    self = [self init];//
    if (self) {
        [self addActionBlock:block];
    }
    return self;
}

- (void)addActionBlock:(void (^)(id sender))block {
    _MMUIGestureRecognizerBlockTarget *target = [[_MMUIGestureRecognizerBlockTarget alloc] initWithBlock:block];
    [self addTarget:target action:@selector(invoke:)];
    NSMutableArray *targets = [self _mm_allUIGestureRecognizerBlockTargets];
    [targets addObject:target];
}

- (void)removeAllActionBlocks {
    NSMutableArray *targes = [self _mm_allUIGestureRecognizerBlockTargets];
    [targes enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeTarget:obj action:@selector(invoke:)];
    }];
    [targes removeAllObjects];
}


- (NSMutableArray *)_mm_allUIGestureRecognizerBlockTargets {
    NSMutableArray *targets = objc_getAssociatedObject(self, _cmd);
    if (!targets) {
        targets = [NSMutableArray array];
        objc_setAssociatedObject(self, _cmd, targets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return targets;
}



@end
