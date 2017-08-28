//
//  UIControl+MMAdd.m
//  PracticeKit
//
//  Created by 晓东 on 16/12/2.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import "UIControl+MMAdd.h"
#import "MMKitMacro.h"
#import <objc/runtime.h>

MMSYNTH_DUMMY_CLASS(UIControl_MMAdd)

static const int block_key;
typedef void(^_ControlBlock)(id sender);

@interface _MMUIControlBlockTarget : NSObject

@property (nonatomic, copy) _ControlBlock block;
@property (nonatomic, assign) UIControlEvents events;

- (id)initWithBlock:(_ControlBlock)block events:(UIControlEvents)events;
- (void)invoke:(id)sender;

@end

@implementation _MMUIControlBlockTarget

- (id)initWithBlock:(_ControlBlock)block events:(UIControlEvents)events {
    self = [super init];
    if (self) {
        _block = [block copy];
        _events = events;
    }
    return self;
}

- (void)invoke:(id)sender {
    if (_block) _block(sender);
}


@end

@implementation UIControl (MMAdd)

- (void)removeAllTargets {
    [[self allTargets] enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self removeTarget:obj action:NULL forControlEvents:UIControlEventAllEvents];
    }];
    [[self _mm_allUIControlBlockTargets] removeAllObjects];
}

- (void)setTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    if (!target || !controlEvents) return;
    NSSet *targets = [self allTargets];
    for (id currentTarget in targets) {
        NSArray *actions = [self actionsForTarget:currentTarget forControlEvent:controlEvents];
        for (NSString *currentAction in actions) {
            [self removeTarget:currentTarget action:NSSelectorFromString(currentAction) forControlEvents:controlEvents];
        }
    }
    [self addTarget:target action:action forControlEvents:controlEvents];
}

- (void)addBlockForControlEvents:(UIControlEvents)controlEvents block:(void (^)(id sender))block {
    if (!controlEvents) return;
    _MMUIControlBlockTarget *target = [[_MMUIControlBlockTarget alloc] initWithBlock:block events:controlEvents];
    
    [self addTarget:target action:@selector(invoke:) forControlEvents:controlEvents];
    NSMutableArray *targets = [self _mm_allUIControlBlockTargets];
    [targets addObject:target];
}

- (void)setBlockForControlEvents:(UIControlEvents)controlEvents block:(void (^)(id sender))block {
    [self removeAllBlocksForControlEvents:controlEvents];
    [self addBlockForControlEvents:controlEvents block:block];
}

- (void)removeAllBlocksForControlEvents:(UIControlEvents)controlEvents {
    if (!controlEvents) return;
    
    NSMutableArray *targets = [self _mm_allUIControlBlockTargets];
    NSMutableArray *removes = [NSMutableArray array];
    for (_MMUIControlBlockTarget *target in targets) {
        if (target.events & controlEvents) {
            UIControlEvents newEvent = target.events & (~controlEvents);
            if (newEvent) {
                [self removeTarget:target action:@selector(invoke:) forControlEvents:target.events];
                target.events = newEvent;
                [self addTarget:target action:@selector(invoke:) forControlEvents:target.events];
            } else {
                [self removeTarget:target action:@selector(invoke:) forControlEvents:target.events];
                [removes addObject:target];
            }
        }
    }
    [targets removeObjectsInArray:removes];
}

- (NSMutableArray *)_mm_allUIControlBlockTargets {
    NSMutableArray *targets = objc_getAssociatedObject(self, &block_key);
    if (!targets) {
        targets = [NSMutableArray new];
        objc_setAssociatedObject(self, _cmd, targets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return targets;
}



@end
